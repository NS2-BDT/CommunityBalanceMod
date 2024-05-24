--________________________________
--
--  NS2: Combat
--    Copyright 2014 Faultline Games Ltd.
--  and Unknown Worlds Entertainment Inc.
--
--________________________________


-- MarineStructureAbility.lua
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/TechMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponHolder.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponSlotMixin.lua")
Script.Load("lua/ModularExos/ExoWeapons/SentryAbility.lua")
Script.Load("lua/ModularExos/ExoWeapons/ArmoryAbility.lua")

class 'MarineStructureAbility'(Entity)

local kMaxStructures = {}
kMaxStructures[kTechId.Sentry] = 1
kMaxStructures[kTechId.WeaponCache] = 1
local kDropCooldown = 3

MarineStructureAbility.kMapName = "marine_drop_structure_ability"

local kCreateFailSound = PrecacheAsset("sound/NS2.fev/alien/gorge/create_fail")

MarineStructureAbility.kSupportedStructures = { SentryAbility, ArmoryAbility, }

local networkVars = {
    numSentriesLeft     = string.format("private integer (0 to %d)", kMaxStructures[kTechId.Sentry]),
    numMiniArmoriesLeft = string.format("private integer (0 to %d)", kMaxStructures[kTechId.WeaponCache]),
    
}

AddMixinNetworkVars(ExoWeaponSlotMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(TechMixin, networkVars)

function MarineStructureAbility:GetActiveStructure()
    
    if self.activeStructure == nil then
        return nil
    else
        return MarineStructureAbility.kSupportedStructures[self.activeStructure]
    end

end

function MarineStructureAbility:OnCreate()
    
    Entity.OnCreate(self)
    
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, ExoWeaponSlotMixin)
    
    self.dropping = false
    self.mouseDown = false
    self.activeStructure = nil
    
    if Server then
        self.lastCreatedId = Entity.invalidId
    end
    
    -- for GUI
    self.numSentriesLeft = 0
    self.numMiniArmoriesLeft = 0
    self.lastClickedPosition = nil

end

function MarineStructureAbility:SetActiveStructure(structureNum)
    self.activeStructure = structureNum
end

function MarineStructureAbility:GetHasDropCooldown()
    return self.timeLastDrop ~= nil and self.timeLastDrop + kDropCooldown > Shared.GetTime()
end

function MarineStructureAbility:GetCanBuildStructure(techId)
    return true
end

function MarineStructureAbility:GetNumStructuresBuilt(techId)
    
    if techId == kTechId.Sentry then
        return self.numSentriesLeft
    end
    
    if techId == kTechId.WeaponCache then
        return self.numMiniArmoriesLeft
    end
    
    -- unlimited
    return -1
end

function MarineStructureAbility:GetTechId()
    return nil
end

function MarineStructureAbility:OnPrimaryAttack(player)
    
    if Client then
        
        if self.activeStructure ~= nil
                and not self.dropping
                and not self.mouseDown then
            self.mouseDown = true
            
            if self:PerformPrimaryAttack(player) then
                
                self.dropping = true
            else
                player:TriggerInvalidSound()
            end
        
        end
    
    end

end

function MarineStructureAbility:OnPrimaryAttackEnd(player)
    
    if not Shared.GetIsRunningPrediction() then
        
        if Client and self.dropping then
            self:OnSetActive()
        end
        
        self.dropping = false
        self.mouseDown = false
    
    end

end

function MarineStructureAbility:GetIsDropping()
    return self.dropping
end

function MarineStructureAbility:PerformPrimaryAttack(player)
    if self.activeStructure == nil then
        return false
    end
    
    local success = false
    
    -- Ensure the current location is valid for placement.
    local coords, valid = self:GetPositionForStructure(player:GetEyePos(), player:GetViewCoords().zAxis, self:GetActiveStructure(), self.lastClickedPosition)
    local secondClick = true
    
    if LookupTechData(self:GetActiveStructure().GetDropStructureId(), kTechDataSpecifyOrientation, false) then
        secondClick = self.lastClickedPosition ~= nil
    end
    
    if secondClick then
        if valid then
            
            -- Ensure they have enough resources.
            local cost = GetCostForTech(self:GetActiveStructure().GetDropStructureId())
            
            if player:GetResources() >= cost and not self:GetHasDropCooldown() then
                local message = BuildMarineDropStructureMessage(player:GetEyePos(), player:GetViewCoords().zAxis, self.activeStructure, self.lastClickedPosition)
                Client.SendNetworkMessage("MarineBuildStructure", message, true)
                self.timeLastDrop = Shared.GetTime()
                success = true
            
            end
        
        end
        
        self.lastClickedPosition = nil
    
    else
        self.lastClickedPosition = Vector(coords.origin)
    end
    
    if not valid then
        Print("%s 3", notvalid)
        player:TriggerInvalidSound()
    end
    
    return success

end

local function DropStructure(self, player, origin, direction, structureAbility, lastClickedPosition)
    
    -- If we have enough resources
    if Server then
        local coords, valid, onEntity = self:GetPositionForStructure(origin, direction, structureAbility, lastClickedPosition)
        local techId = structureAbility:GetDropStructureId()
        
        local maxStructures = -1
        
        if not LookupTechData(techId, kTechDataAllowConsumeDrop, false) then
            maxStructures = LookupTechData(techId, kTechDataMaxAmount, 0)
        end
        
        valid = valid and self:GetNumStructuresBuilt(techId) ~= maxStructures -- -1 is unlimited
        local cost = LookupTechData(structureAbility:GetDropStructureId(), kTechDataCostKey, 0)
        local enoughRes = player:GetResources() >= cost
        
        if valid and enoughRes and structureAbility:IsAllowed(player) and not self:GetHasDropCooldown() then
            -- Create structure
            local structure = self:CreateStructure(coords, player, structureAbility)
            if structure then
                Print("%s struct", ToString(structure))
                Print("%s structureAbility", ToString(structureAbility))
                structure:SetOwner(player)
                player:GetTeam():AddMarineStructure(player, structure)
                
                -- Check for space
                if structure:SpaceClearForEntity(coords.origin) then
                    
                    local angles = Angles()
                    angles:BuildFromCoords(coords)
                    structure:SetAngles(angles)
                    
                    if structure.OnCreatedByGorge then
                        structure:OnCreatedByGorge(self.lastCreatedId)
                    end
                    player:AddResources(-cost)
                    
                    if structureAbility:GetStoreBuildId() then
                        self.lastCreatedId = structure:GetId()
                    end
                    
                    self:TriggerEffects("spawn", { effecthostcoords = Coords.GetLookIn(origin, direction) })
                    
                    if structureAbility.OnStructureCreated then
                        structureAbility:OnStructureCreated(structure, lastClickedPosition)
                    end
                    
                    self.timeLastDrop = Shared.GetTime()
                    
                    return true
                
                else
                    Print("invalid  1")
                    player:TriggerInvalidSound()
                    DestroyEntity(structure)
                
                end
            
            else
                Print("invalid  2")
                player:TriggerInvalidSound()
            end
        
        else
            
            if not valid then
                Print("invalid  3")
                
                player:TriggerInvalidSound()
            elseif not enoughRes then
                Print("%s bla", enoughRes)
                Print("invalid  4")
                
                player:TriggerInvalidSound()
            end
        
        end
    
    end
    
    return true

end

function MarineStructureAbility:OnDropStructure(origin, direction, structureIndex, lastClickedPosition)
    
    local player = self:GetParent()
    
    if player then
        
        local structureAbility = MarineStructureAbility.kSupportedStructures[structureIndex]
        if structureAbility then
            DropStructure(self, player, origin, direction, structureAbility, lastClickedPosition)
        end
    
    end

end

function MarineStructureAbility:CreateStructure(coords, player, structureAbility, lastClickedPosition)
    local created_structure = structureAbility:CreateStructure(coords, player, lastClickedPosition)
    if created_structure then
        return created_structure
    else
        return CreateEntity(structureAbility:GetDropMapName(), coords.origin, player:GetTeamNumber())
    end
end

local function FilterBabblersAndTwo(ent1, ent2)
    return function(test)
        return test == ent1 or test == ent2 or test:isa("Babbler")
    end
end

-- Given a gorge player's position and view angles, return a position and orientation
-- for structure. Used to preview placement via a ghost structure and then to create it.
-- Also returns bool if it's a valid position or not.
function MarineStructureAbility:GetPositionForStructure(startPosition, direction, structureAbility, lastClickedPosition)
    
    PROFILE("MarineStructureAbility:GetPositionForStructure")
    
    local validPosition = false
    local range = structureAbility.GetDropRange()
    local origin = startPosition + direction * range
    local player = self:GetParent()
    
    -- Trace short distance in front
    local trace = Shared.TraceRay(player:GetEyePos(), origin, CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, FilterBabblersAndTwo(player, self))
    
    local displayOrigin = trace.endPoint
    
    -- If we hit nothing, trace down to place on ground
    if trace.fraction == 1 then
        
        origin = startPosition + direction * range
        trace = Shared.TraceRay(origin, origin - Vector(0, range, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, EntityFilterTwo(player, self))
    
    end
    
    -- If it hits something, position on this surface (must be the world or another structure)
    if trace.fraction < 1 then
        
        if trace.entity == nil then
            validPosition = true
        end
        
        displayOrigin = trace.endPoint
    
    end
    
    if not structureAbility.AllowBackfacing() and trace.normal:DotProduct(GetNormalizedVector(startPosition - trace.endPoint)) < 0 then
        validPosition = false
    end
    
    -- Don't allow dropped structures to go too close to techpoints and resource nozzles
    if GetPointBlocksAttachEntities(displayOrigin) then
        validPosition = false
    end
    
    if not structureAbility:GetIsPositionValid(displayOrigin, player, trace.normal, lastClickedPosition, trace.entity) then
        validPosition = false
    end
    
    -- Don't allow placing above or below us and don't draw either
    local structureFacing = Vector(direction)
    
    if math.abs(Math.DotProduct(trace.normal, structureFacing)) > 0.9 then
        structureFacing = trace.normal:GetPerpendicular()
    end
    
    -- Coords.GetLookIn will prioritize the direction when constructing the coords,
    -- so make sure the facing direction is perpendicular to the normal so we get
    -- the correct y-axis.
    local perp = Math.CrossProduct(trace.normal, structureFacing)
    structureFacing = Math.CrossProduct(perp, trace.normal)
    
    local coords = Coords.GetLookIn(displayOrigin, structureFacing, trace.normal)
    
    if structureAbility.ModifyCoords then
        structureAbility:ModifyCoords(coords, lastClickedPosition)
    end
    
    return coords, validPosition, trace.entity

end

function MarineStructureAbility:OnUpdateAnimationInput(modelMixin)

end

function MarineStructureAbility:ProcessMoveOnWeapon(input)
    
    -- Show ghost if we're able to create structure, and if menu is not visible
    local player = self:GetParent()
    if player then
        if Server then
            
            -- This is where you limit the number of entities that are alive
            local team = player:GetTeam()
            local numAllowedSentries = LookupTechData(kTechId.Sentry, kTechDataMaxAmount, -1)
            local numAllowedMiniArmories = LookupTechData(kTechId.WeaponCache, kTechDataMaxAmount, -1)
            
            if numAllowedSentries >= 0 then
                self.numSentriesLeft = team:GetNumDroppedMarineStructures(player, kTechId.Sentry)
            end
            
            if numAllowedMiniArmories >= 0 then
                self.numMiniArmoriesLeft = team:GetNumDroppedMarineStructures(player, kTechId.WeaponCache)
            end
        
        end
    
    end

end

function MarineStructureAbility:GetShowGhostModel()
    return self.activeStructure ~= nil and not self:GetHasDropCooldown()
end

function MarineStructureAbility:GetGhostModelCoords()
    return self.ghostCoords
end

function MarineStructureAbility:GetIsPlacementValid()
    return self.placementValid
end

function MarineStructureAbility:GetGhostModelTechId()
    
    if self.activeStructure == nil then
        return nil
    else
        return self:GetActiveStructure():GetDropStructureId()
    end

end

if Client then
    
    function MarineStructureAbility:OnProcessIntermediate(input)
        local player = self:GetParent()
        local viewDirection = player:GetViewCoords().zAxis
        
        if player and self.activeStructure then
            self.ghostCoords, self.placementValid = self:GetPositionForStructure(player:GetEyePos(), viewDirection, self:GetActiveStructure(), self.lastClickedPosition)
            
            if player:GetResources() < LookupTechData(self:GetActiveStructure():GetDropStructureId(), kTechDataCostKey) then
                self.placementValid = false
            end
        
        end
    
    end
    
    function MarineStructureAbility:CreateBuildMenu()
        
        if not self.buildMenu then
            self.buildMenu = GetGUIManager():CreateGUIScript("ModularExos/GUI/GUIMarineBuildMenu")
        end
    
    end
    
    function MarineStructureAbility:DestroyBuildMenu()
        
        if self.buildMenu ~= nil then
            
            GetGUIManager():DestroyGUIScript(self.buildMenu)
            self.buildMenu = nil
        
        end
    
    end
    
    function MarineStructureAbility:OnDestroy()
        
        self:DestroyBuildMenu()
        Entity.OnDestroy(self)
    
    end
    
    function MarineStructureAbility:OnKillClient()
        self.menuActive = false
    end
    
    local function UpdateGUI(self, player)
        
        local localPlayer = Client.GetLocalPlayer()
        if localPlayer == player then
            self:CreateBuildMenu()
        end
        
        if self.buildMenu then
            self.buildMenu:SetIsVisible(player and localPlayer == player and player:isa("ExoMarine") and self.menuActive)
        end
    
    end
    
    function MarineStructureAbility:OverrideInput(input)
        if self.buildMenu then
            Print("poop 1")
            
            -- Build menu is up, let it handle input
            if self.buildMenu:GetIsVisible() then
                
                local selected = false
                input, selected = self.buildMenu:OverrideInput(input)
                self.menuActive = not selected
            
            else
                Print("poop 3")
                
                -- If player wants to switch to this, open build menu immediately
                local weaponSwitchCommands = { Move.Weapon1, Move.Weapon2, Move.Weapon3, Move.Weapon4, Move.Weapon5 }
                local thisCommand = weaponSwitchCommands[self:GetHUDSlot()]
                
                if bit.band(input.commands, Move.Reload) ~= 0 then
                    self.menuActive = true
                    Print("poop 2")
                end
            
            end
        
        end
        
        return input
    
    end
    
    function MarineStructureAbility:OnUpdateRender()
        UpdateGUI(self, self:GetParent())
    end

end

function MarineStructureAbility:GetIsLeftSlot()
    return true
end
function MarineStructureAbility:GetIsRightSlot()
    return false
end

function MarineStructureAbility:OnTag(tagName)
    
    PROFILE("ExoWelder:OnTag")
    
    if not self:GetIsLeftSlot() then
        
        if tagName == "deploy_end" then
            self.deployed = true
        end
    
    end

end

function MarineStructureAbility:GetIsAffectedByWeaponUpgrades()
    return false
end

Shared.LinkClassToMap("MarineStructureAbility", MarineStructureAbility.kMapName, networkVars)
