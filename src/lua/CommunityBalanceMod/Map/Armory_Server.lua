-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Armory_Server.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local function OnDeploy(self)

    self.deployed = true
    return false
    
end

local kDeployTime = 3

local function AddChildModel(self)

    local scriptActor = CreateEntity(ArmoryAddon.kMapName, nil, self:GetTeamNumber())
    scriptActor:SetParent(self)
    scriptActor:SetAttachPoint(Armory.kAttachPoint)

    return scriptActor

end

function Armory:OnWarmupCreate()

    -- Add the advanced armory child model if warmup is active, since it doesn't normally get added.
    if self:GetTechId() == kTechId.AdvancedArmory then

        local addon = AddChildModel(self)

        -- Set the creation time of the the addon so it just immediately has the advance armory module on top already deployed.
        -- Negative is fine since it's only being used as a normalized (and clamped) animation input.
        addon.creationTime = Shared.GetTime() - kAdvancedArmoryResearchTime
    end
end

function Armory:OnConstructionComplete()
    self:AddTimedCallback(OnDeploy, kDeployTime)
end

-- west/east = x/-x
-- north/south = -z/z

local indexToUseOrigin =
{
    -- West
    Vector(Armory.kResupplyUseRange, 0, 0), 
    -- North
    Vector(0, 0, -Armory.kResupplyUseRange),
    -- South
    Vector(0, 0, Armory.kResupplyUseRange),
    -- East
    Vector(-Armory.kResupplyUseRange, 0, 0)
}

function Armory:GetTimeToResupplyPlayer(player)

    assert(player ~= nil)
    
    local timeResupplied = self.resuppliedPlayers[player:GetId()]
    
    if timeResupplied ~= nil then
    
        -- Make sure we haven't done this recently
        if Shared.GetTime() < (timeResupplied + Armory.kResupplyInterval) then
            return false
        end
        
    end
    
    return true
    
end

function Armory:GetShouldResupplyPlayer(player)

    if not player:GetIsAlive() then
        return false
    end
    
    local stunned = HasMixin(player, "Stun") and player:GetIsStunned()
    
    if stunned then
        return false
    end
    
    local inNeed = false
    
    -- Don't resupply when already full
    if (player:GetHealth() < player:GetMaxHealth()) then
        inNeed = true
    else

        -- Do any weapons need ammo?
        for i = 1, player:GetNumChildren() do
            local child = player:GetChildAtIndex(i - 1)
            if child:isa("ClipWeapon") and child:GetNeedsAmmo(false) then
                inNeed = true
                break
            end
        end
        
    end
    
    if inNeed then
    
        -- Check player facing so players can't fight while getting benefits of armory
        local viewVec = player:GetViewAngles():GetCoords().zAxis

        local toArmoryVec = self:GetOrigin() - player:GetOrigin()
        
        if(GetNormalizedVector(viewVec):DotProduct(GetNormalizedVector(toArmoryVec)) > .75) then
        
            if self:GetTimeToResupplyPlayer(player) then
        
                return true
                
            end
            
        end
        
    end
    
    return false
    
end

function Armory:ResupplyPlayer(player)
    
    local resuppliedPlayer = false
    
    -- Heal player first
    if (player:GetHealth() < player:GetMaxHealth()) then

        -- third param true = ignore armor
        player:AddHealth(Armory.kHealAmount, false, true)

        self:TriggerEffects("armory_health", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
        
        resuppliedPlayer = true
        --[[
        if HasMixin(player, "ParasiteAble") and player:GetIsParasited() then
        
            player:RemoveParasite()
            
        end
        --]]
        
        if player:isa("Marine") and player.poisoned then
        
            player.poisoned = false
            
        end
        
    end

    -- Give ammo to all their weapons, one clip at a time, starting from primary
    local weapons = player:GetHUDOrderedWeaponList()
    
    for _, weapon in ipairs(weapons) do
    
        if weapon:isa("ClipWeapon") then
        
            if weapon:GiveAmmo(1, false) then
            
                self:TriggerEffects("armory_ammo", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
                
                resuppliedPlayer = true
                
                break
                
            end 
                   
        end
        
    end
        
    if resuppliedPlayer then
    
        -- Insert/update entry in table
        self.resuppliedPlayers[player:GetId()] = Shared.GetTime()
        
        -- Play effect
        --self:PlayArmoryScan(player:GetId())

    end

end

function Armory:ResupplyPlayers()

    local playersInRange = GetEntitiesForTeamWithinRange("Marine", self:GetTeamNumber(), self:GetOrigin(), Armory.kResupplyUseRange)
    for _, player in ipairs(playersInRange) do
    
        if self:GetShouldResupplyPlayer(player) then
            self:ResupplyPlayer(player)
        end
            
    end

end

function Armory:UpdateResearch()

    local researchId = self:GetResearchingId()

    if researchId == kTechId.AdvancedArmoryUpgrade then
    
        local techTree = self:GetTeam():GetTechTree()    
        local researchNode = techTree:GetTechNode(kTechId.AdvancedArmory)    
        researchNode:SetResearchProgress(self.researchProgress)
        techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress)) 
        
    end

end

function Armory:OnResearch(researchId)

    if researchId == kTechId.AdvancedArmoryUpgrade then

        -- Create visual add-on
        AddChildModel(self)
        
    end
    
end

function Armory:OnResearchCancel(researchId)

    if researchId == kTechId.AdvancedArmoryUpgrade then
    
        local team = self:GetTeam()
        
        if team then
        
            local techTree = team:GetTechTree()
            local researchNode = techTree:GetTechNode(kTechId.AdvancedArmory)
            if researchNode then
            
                researchNode:ClearResearching()
                techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", 0))   
         
            end
            
            for i = 0, self:GetNumChildren() - 1 do
            
                local child = self:GetChildAtIndex(i)
                if child:isa("ArmoryAddon") then
                    DestroyEntity(child)
                    break
                end
                
            end  

        end  
    
    end

end

-- Called when research or upgrade complete
function Armory:OnResearchComplete(researchId)

    if researchId == kTechId.AdvancedArmoryUpgrade then
    
        self:SetTechId(kTechId.AdvancedArmory)
        
        local techTree = self:GetTeam():GetTechTree()
        local researchNode = techTree:GetTechNode(kTechId.AdvancedWeaponry)
        
        if researchNode then     
   
            researchNode:SetResearchProgress(1)
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress))
            researchNode:SetResearched(true)
            techTree:QueueOnResearchComplete(kTechId.AdvancedWeaponry, self)
            
        end
        
    end
    
end

function Armory:UpdateLoggedIn()

    local players = GetEntitiesForTeamWithinRange("Marine", self:GetTeamNumber(), self:GetOrigin(), 2 * Armory.kResupplyUseRange)
    local armoryCoords = self:GetAngles():GetCoords()
    
    for i = 1, 4 do
    
        local newState = false
        
        if GetIsUnitActive(self) then
        
            local worldUseOrigin = self:GetModelOrigin() + armoryCoords:TransformVector(indexToUseOrigin[i])
        
            for _, player in ipairs(players) do
            
                -- See if valid player is nearby
                if player:GetIsAlive() and (player:GetModelOrigin() - worldUseOrigin):GetLength() < Armory.kResupplyUseRange then
                
                    newState = true
                    break
                    
                end
                
            end
            
        end
        
        if newState ~= self.loggedInArray[i] then
        
            if newState then
                self:TriggerEffects("armory_open")
            else
                self:TriggerEffects("armory_close")
            end
            
            self.loggedInArray[i] = newState
            
        end
        
    end
    
    -- Copy data to network variables (arrays not supported)
    self.loggedInWest = self.loggedInArray[1]
    self.loggedInNorth = self.loggedInArray[2]
    self.loggedInSouth = self.loggedInArray[3]
    self.loggedInEast = self.loggedInArray[4]

end

