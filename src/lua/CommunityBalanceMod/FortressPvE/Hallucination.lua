-- ========= Community Balance Mod ===============================
--
-- "lua\Hallucination.lua"
--
--    Created by:   Twiliteblue, Drey (@drey3982)
--
-- ===============================================================



-- known issues: 
-- Casting drifter hallucinations will get rid of shade hallucinations and vice versa
-- eggs will have the vanilla skin on their initial spawn

Script.Load("lua/CloakableMixin.lua")
Script.Load("lua/TargetCacheMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DetectableMixin.lua")

Hallucination.kTouchRange = 3.5 -- Max model extents for "touch" uncloaking since we have no collision

local kHallucinationMaterial = PrecacheAsset( "cinematics/vfx_materials/hallucination.material")
local kEnemyDetectInterval = 0.25

local networkVars =
{
    modelScale = "interpolated float (0 to 3 by 0.01)",
}

AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)


-- These Structures can be created by ShadeHallucination and behave differently than lifeform hallucinations
local ShadeHallucinationTypes = {
    kTechId.HallucinateShade,
    kTechId.HallucinateWhip,
    kTechId.HallucinateCrag,
    kTechId.HallucinateShift,
    kTechId.HallucinateShell,
    kTechId.HallucinateSpur,
    kTechId.HallucinateVeil,
    kTechId.HallucinateEgg,
}

-- small helper function to go over the list above
function ShadeHallucinationContains( hallucinateTechId)
    for i = 1, #ShadeHallucinationTypes do
      if (ShadeHallucinationTypes[i] == hallucinateTechId) then
        return true
      end
    end
    return false
end



-- function to convert a hallucinate techId to a normal one
-- vanilla function already contains some structures
local oldGetTechIdToEmulate = GetTechIdToEmulate
local ghallucinateIdToTechId
function GetTechIdToEmulate(techId)

    if not ghallucinateIdToTechId then
    
        ghallucinateIdToTechId = {}
        ghallucinateIdToTechId[kTechId.HallucinateShell] = kTechId.Shell
        ghallucinateIdToTechId[kTechId.HallucinateSpur] = kTechId.Spur
        ghallucinateIdToTechId[kTechId.HallucinateVeil] = kTechId.Veil
        ghallucinateIdToTechId[kTechId.HallucinateEgg] = kTechId.Egg
    
    end
    return ghallucinateIdToTechId[techId] or oldGetTechIdToEmulate(techId)

end

-- current list of valid Shade Hallucinations types
local techIdToShadeHallucinationId = {}
techIdToShadeHallucinationId[kTechId.Whip] = kTechId.HallucinateWhip
techIdToShadeHallucinationId[kTechId.Shade] = kTechId.HallucinateShade
techIdToShadeHallucinationId[kTechId.Crag] = kTechId.HallucinateCrag
techIdToShadeHallucinationId[kTechId.Shift] = kTechId.HallucinateShift
techIdToShadeHallucinationId[kTechId.Shell] = kTechId.HallucinateShell
techIdToShadeHallucinationId[kTechId.Spur] = kTechId.HallucinateSpur
techIdToShadeHallucinationId[kTechId.Veil] = kTechId.HallucinateVeil
techIdToShadeHallucinationId[kTechId.Egg] = kTechId.HallucinateEgg

techIdToShadeHallucinationId[kTechId.FortressWhip] = kTechId.HallucinateWhip
techIdToShadeHallucinationId[kTechId.FortressShade] = kTechId.HallucinateShade
techIdToShadeHallucinationId[kTechId.FortressCrag] = kTechId.HallucinateCrag
techIdToShadeHallucinationId[kTechId.FortressShift] = kTechId.HallucinateShift



-- add these structures to the moveable table
local oldGetHallucinationCanMove = debug.getupvaluex(Hallucination.GetCanReposition, "GetHallucinationCanMove")
local gTechIdCanMove
local function GetHallucinationCanMove(techId)

    if not gTechIdCanMove then
        gTechIdCanMove = {}
        -- whip is already included in vanilla
        gTechIdCanMove[kTechId.Crag] = true
        gTechIdCanMove[kTechId.Shade] = true
        gTechIdCanMove[kTechId.Shift] = true
        gTechIdCanMove[kTechId.Shell] = true
        gTechIdCanMove[kTechId.Spur] = true
        gTechIdCanMove[kTechId.Veil] = true
        gTechIdCanMove[kTechId.Egg] = true
    end 
    return gTechIdCanMove[techId] or oldGetHallucinationCanMove(techId)
end
debug.setupvaluex(Hallucination.GetCanReposition, "GetHallucinationCanMove", GetHallucinationCanMove)
if Server then 
    debug.setupvaluex(Hallucination.UpdateOrders, "GetHallucinationCanMove", GetHallucinationCanMove)
end



-- add missing animation graphs for Shade Hallucinations
local gTechIdAnimationGraph
local function GetAnimationGraphShadeHallucinations(techId)

    if not gTechIdAnimationGraph then
        gTechIdAnimationGraph = {}
        gTechIdAnimationGraph[kTechId.Whip] = "models/alien/whip/whip_1.animation_graph" -- twilites new animation
        gTechIdAnimationGraph[kTechId.Shade] = "models/alien/shade/shade.animation_graph"
        gTechIdAnimationGraph[kTechId.Crag] = "models/alien/crag/crag.animation_graph"
        gTechIdAnimationGraph[kTechId.Shift] = "models/alien/shift/shift.animation_graph"
        gTechIdAnimationGraph[kTechId.Shell] = "models/alien/shell/shell.animation_graph"
        gTechIdAnimationGraph[kTechId.Spur] = "models/alien/spur/spur.animation_graph"
        gTechIdAnimationGraph[kTechId.Veil] = "models/alien/veil/veil.animation_graph"
        gTechIdAnimationGraph[kTechId.Egg] = "models/alien/egg/egg.animation_graph"
    end
    return  gTechIdAnimationGraph[techId]
end

-- 3.625 is the movement speed of non fortress structures. Upgrades move slower by a arbitrary amount
local gTechIdMaxMovementSpeed
local function GetMaxMovementSpeedShadeHallucinations(techId)

    if not gTechIdMaxMovementSpeed then
        gTechIdMaxMovementSpeed = {}

        gTechIdMaxMovementSpeed[kTechId.Whip] = 3.625
        gTechIdMaxMovementSpeed[kTechId.Shade] = 3.625
        gTechIdMaxMovementSpeed[kTechId.Crag] = 3.625
        gTechIdMaxMovementSpeed[kTechId.Shift] = 3.625
        
        gTechIdMaxMovementSpeed[kTechId.Shell] = 2
        gTechIdMaxMovementSpeed[kTechId.Spur] = 2
        gTechIdMaxMovementSpeed[kTechId.Veil] = 2
        gTechIdMaxMovementSpeed[kTechId.Egg] = 2
    end
    
    local moveSpeed = gTechIdMaxMovementSpeed[techId]
    
    return ConditionalValue(moveSpeed == nil, Hallucination.kDefaultMaxSpeed, moveSpeed)
end

local OldSetAssignedAttributes = debug.getupvaluex(Hallucination.OnInitialized, "SetAssignedAttributes")

-- this function gets called in vanilla with kTechId.HallucinateSkulk at OnInitialized and hallucination lifeform techIds at SetEmulation
-- with ShadeHallucinations it gets called with Shade hallucination techIds at SetEmulation
local function SetAssignedAttributes(self, hallucinationTechId)

    -- Shade hallucinations can change their appearance and have to keep their old HP values with self.storedHealthFraction, self.storedArmorScalar
    if ShadeHallucinationContains(hallucinationTechId) then 
        
        local model = LookupTechData(self.assignedTechId, kTechDataModel, Shade.kModelName)
        local hallucinatedTechDataId = techIdToShadeHallucinationId[self.assignedTechId]
        local health = hallucinatedTechDataId and LookupTechData(hallucinatedTechDataId, kTechDataMaxHealth)
                        or math.min(LookupTechData(self.assignedTechId, kTechDataMaxHealth, kMatureShadeHealth) * kHallucinationHealthFraction, kHallucinationMaxHealth)
        local armor = hallucinatedTechDataId and LookupTechData(hallucinatedTechDataId, kTechDataMaxArmor)
                        or LookupTechData(self.assignedTechId, kTechDataMaxArmor, kMatureShadeArmor) * kHallucinationArmorFraction
            
        self.maxSpeed = GetMaxMovementSpeedShadeHallucinations(self.assignedTechId)    
        self:SetModel(model, GetAnimationGraphShadeHallucinations(self.assignedTechId))
        self:SetMaxHealth(health)
        self:SetHealth(health * self.storedHealthFraction)
        self:SetMaxArmor(armor)
        self:SetArmor(armor * self.storedArmorScalar)
            
        if self.assignedTechId == kTechId.Hive then
    
            local attachedTechPoint = self:GetAttached()
            if attachedTechPoint then
                attachedTechPoint:SetIsSmashed(true)
            end
    
        end

    else 
        -- vanilla
        OldSetAssignedAttributes(self, hallucinationTechId)
    end

end
debug.setupvaluex(Hallucination.OnInitialized, "SetAssignedAttributes", SetAssignedAttributes)
debug.setupvaluex(Hallucination.SetEmulation, "SetAssignedAttributes", SetAssignedAttributes)


-- vanilla hallucinations didnt took structural damage
local gTechIdReceivesStructuralDamage
local function _GetReceivesStructuralDamage(techId)
    if not gTechIdReceivesStructuralDamage then
        gTechIdReceivesStructuralDamage = {}
        
        gTechIdReceivesStructuralDamage[kTechId.Hive] = true
        gTechIdReceivesStructuralDamage[kTechId.Whip] = true
        gTechIdReceivesStructuralDamage[kTechId.Shade] = true
        gTechIdReceivesStructuralDamage[kTechId.Crag] = true
        gTechIdReceivesStructuralDamage[kTechId.Shift] = true
        gTechIdReceivesStructuralDamage[kTechId.Harvester] = true
        gTechIdReceivesStructuralDamage[kTechId.Hydra] = true
        gTechIdReceivesStructuralDamage[kTechId.Shell] = true
        gTechIdReceivesStructuralDamage[kTechId.Spur] = true
        gTechIdReceivesStructuralDamage[kTechId.Veil] = true
    end
    
    return gTechIdReceivesStructuralDamage[techId] or false
end
function Hallucination:GetReceivesStructuralDamage()
    return _GetReceivesStructuralDamage(self.assignedTechId)
end



local oldHallucinationOnCreate = Hallucination.OnCreate
function Hallucination:OnCreate()
    
    oldHallucinationOnCreate(self)

    InitMixin(self, CloakableMixin)
    InitMixin(self, DetectableMixin)
    
    if Server then
		
        self.storedHealthFraction = 1
        self.storedArmorScalar = 1
    end

    -- test the uncloak timing. As structures they dont have the faster player updates
    self:SetUpdates(true, kRealTimeUpdateRate) --kDefaultUpdateRate)
    self.modelScale = 1.0
    
end

local oldHallucinationOnInitialized = Hallucination.OnInitialized
function Hallucination:OnInitialized()

    oldHallucinationOnInitialized(self)

    if Server then
        self:AddTimedCallback(self.ScanForNearbyEnemy, kEnemyDetectInterval) -- uncloak when enemy is near	
    elseif Client then
        InitMixin(self, UnitStatusMixin)
    end
end


-- These models are 80% sized down with the fortress pve mod
local gCustomSizeModel = {}
gCustomSizeModel[kTechId.HallucinateShade] = true
gCustomSizeModel[kTechId.HallucinateWhip] = true
gCustomSizeModel[kTechId.HallucinateCrag] = true
gCustomSizeModel[kTechId.HallucinateShift] = true

-- gets called in SetEmulation for shift, crag, shade, whips
function Hallucination:SetAssignedTechModelScaling(techId)
    if techId then
        local className = EnumToString(kTechId, techId)
        local scale = _G[className].kModelScale
        self.modelScale = scale or 1.0       
    end
end


function Hallucination:OnAdjustModelCoords(modelCoords)
    if self.modelScale ~= 1 then    
        modelCoords.xAxis = modelCoords.xAxis * self.modelScale
        modelCoords.yAxis = modelCoords.yAxis * self.modelScale
        modelCoords.zAxis = modelCoords.zAxis * self.modelScale
    end
    return modelCoords
end

local oldHallucinationSetEmulation = Hallucination.SetEmulation
function Hallucination:SetEmulation(hallucinationTechId)

    oldHallucinationSetEmulation(self, hallucinationTechId)
    
    -- scale down basic pve due to fortress mod
    if gCustomSizeModel[hallucinationTechId] then 
        self:SetAssignedTechModelScaling(self.assignedTechId)
    else 
        self.modelScale = 1.0  
    end
    
    -- drifter should float
    local yOffset = self:GetIsFlying() and self:GetHoverHeight() or 0
    self:SetOrigin(GetGroundAt(self, self:GetOrigin(), PhysicsMask.Movement, EntityFilterOne(self)) + Vector(0, yOffset, 0))

end

local oldHallucinationGetCanReposition = Hallucination.GetCanReposition
function Hallucination:GetCanReposition()

    -- all ShadeHallucinations dont reposition
    if techIdToShadeHallucinationId[self.assignedTechId] ~= nil then
        return false
    else
        return oldHallucinationGetCanReposition(self)
    end
end
 
local oldHallucinationOverrideRepositioningDistance = Hallucination.OverrideRepositioningDistance
function Hallucination:OverrideRepositioningDistance()
   
    if techIdToShadeHallucinationId[self.assignedTechId] ~= nil then
        return 0.8  -- allow ShadeHallucinations to spawn closer?
    else 
        return oldHallucinationOverrideRepositioningDistance(self)
    end
end


local oldHallucinationOnUpdate = Hallucination.OnUpdate
function Hallucination:OnUpdate(deltaTime)

    -- with ShadeHallucinations we dont update the lifetime and calculate the moveSpeed differently
    if self.assignedTechId and techIdToShadeHallucinationId[self.assignedTechId] ~= nil then
       
        ScriptActor.OnUpdate(self, deltaTime)

        if Server then
            self:UpdateServer(deltaTime)
            --UpdateHallucinationLifeTime(self)
        elseif Client then
            self:UpdateClient(deltaTime)
        end    
        
        --self.moveSpeed = 1
        self.moveSpeed = self:GetIsMoving() and self.maxSpeed or 0
        
        self:SetPoseParam("move_yaw", 90)
        self:SetPoseParam("move_speed", self.moveSpeed)

    else 
        oldHallucinationOnUpdate(self, deltaTime)
    end
end

-- ShadeHallucinations open doors at 2 meter instead of 4 meters
local oldHallucinationOnOverrideDoorInteraction = Hallucination.OnOverrideDoorInteraction
function Hallucination:OnOverrideDoorInteraction(inEntity)   

    if self.assignedTechId and techIdToShadeHallucinationId[self.assignedTechId] ~= nil then
        return true, 2
    else
        return oldHallucinationOnOverrideDoorInteraction(self, inEntity)
    end
end


-- copied from CommanderAbility
local function GetClosestFromTable(entities, CheckFunc, position)

    Shared.SortEntitiesByDistance(position, entities)
    
    for index, entity in ipairs(entities) do

        if not CheckFunc or CheckFunc(entity) then        
            return entity
        end
    end
end

function Hallucination:PerformActivation(techId, position, normal, commander)
    if techId == kTechId.HallucinateCloning then
        local cooldown = LookupTechData(techId, kTechDataCooldown, 0)

        if commander and cooldown ~= 0 then
            commander:SetTechCooldown(techId, cooldown, Shared.GetTime())
        end

        local team = self:GetTeam()
        local cost = GetCostForTech(techId)
        if cost > team:GetTeamResources() then
            return false, true
        end
		
        local entities = GetEntitiesWithMixinForTeamWithinXZRange("Live", self:GetTeamNumber(), position, 2)
		
        local CheckFunc = function(entity)
            return techIdToShadeHallucinationId[entity:GetTechId()] and true or entity:isa("Hallucination") or false
        end
		
        local closest = GetClosestFromTable(entities, CheckFunc, position)

        if closest then
            local hallucType = techIdToShadeHallucinationId[closest:GetTechId()] or closest:isa("Hallucination") and techIdToShadeHallucinationId[closest.assignedTechId]
            if hallucType then
                self:SetEmulation(hallucType)
            end

            return true, true
        end
        
    elseif techId == kTechId.HallucinateRandom then
        
        local cooldown = LookupTechData(techId, kTechDataCooldown, 0)

        if commander and cooldown ~= 0 then
            commander:SetTechCooldown(techId, cooldown, Shared.GetTime())
        end
        
        -- remember our health and armour percentage to prevent health gain after changing form
        self.storedHealthFraction = self:GetHealthFraction()
        self.storedArmorScalar = (self:GetMaxArmor() == 0) and self.storedArmorScalar or self:GetArmorScalar()
    
        local hallucType = ShadeHallucinationTypes[ math.random(#ShadeHallucinationTypes) ]
        self:SetEmulation(hallucType)
        return true, true
        
    elseif techId == kTechId.DestroyHallucination then

        self:Kill()
        return true, true

    end
    
    return false, true

end


function Hallucination:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player)
    
    if techId == kTechId.DestroyHallucination then
        allowed = true
    end

    return allowed, canAfford

end

function Hallucination:GetTechButtons(techId)

    return { kTechId.HallucinateCloning, kTechId.Stop, kTechId.HallucinateRandom, kTechId.None,
             kTechId.None, kTechId.None, kTechId.None, kTechId.DestroyHallucination }
    
end


local oldHallucinationOnUpdateAnimationInput = Hallucination.OnUpdateAnimationInput
local GetMoveName = debug.getupvaluex(Hallucination.OnUpdateAnimationInput, "GetMoveName")


function Hallucination:OnUpdateAnimationInput(modelMixin)

    oldHallucinationOnUpdateAnimationInput(self, modelMixin)

    -- set to build, Shade hallucinations are created finished
    if self.assignedTechId and techIdToShadeHallucinationId[self.assignedTechId] ~= nil then
        modelMixin:SetAnimationInput("built", true)
    end

end


-- Shade Hallucinations take more damage. Since Eggs are more squishy their damage increases less
function Hallucination:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    if self.assignedTechId and techIdToShadeHallucinationId[self.assignedTechId] ~= nil then

        local multiplier = self.assignedTechId == kTechId.Egg and kHallucinateEggDamageMulti or kHallucinationDamageMulti
         damageTable.damage = damageTable.damage * multiplier
    end
end


if Server then

    function Hallucination:ScanForNearbyEnemy()

        self.lastDetectedTime = self.lastDetectedTime or 0
        if self.lastDetectedTime + kEnemyDetectInterval <= Shared.GetTime() then

            local done = false

            if not done and #GetEntitiesForTeamWithinRange("Player", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), Hallucination.kTouchRange) > 0 then
                self:TriggerUncloak()
                done = true
            end

            self.lastDetectedTime = Shared.GetTime()
        end

        return self:GetIsAlive()
    end
    
end


if Client then

    local oldHallucinationOnUpdateRender = Hallucination.OnUpdateRender
    function Hallucination:OnUpdateRender()

        oldHallucinationOnUpdateRender(self)

        -- structures should glow
        if self.assignedTechId and techIdToShadeHallucinationId[self.assignedTechId] ~= nil then
            local model = self:GetRenderModel()
            if model then
                model:SetMaterialParameter("glowIntensity", 1)
            end
        end
    end
    
    function Hallucination:UpdateVariant(renderModel)

        local gameInfo = GetGameInfoEntity()
        if gameInfo and renderModel and renderModel:GetReadyForOverrideMaterials() then

            local skinVariant
            local defaultSkinVariant
            local className
            local materialIndex

            if self.assignedTechId == kTechId.Hive then
                skinVariant = gameInfo:GetTeamCosmeticSlot( self:GetTeamNumber(), kTeamCosmeticSlot1 )
                defaultSkinVariant = kDefaultAlienStructureVariant
                className = "Hive"
                materialIndex = 0
            elseif self.assignedTechId == kTechId.Harvester then
                skinVariant = gameInfo:GetTeamCosmeticSlot( self:GetTeamNumber(), kTeamCosmeticSlot2 )
                defaultSkinVariant = kDefaultHarvesterVariant
                className = "Harvester"
                materialIndex = 0
            elseif self.assignedTechId == kTechId.Drifter then
                    skinVariant = gameInfo:GetTeamCosmeticSlot( self:GetTeamNumber(), kTeamCosmeticSlot6 )
                    defaultSkinVariant = kDefaultAlienDrifterVariant
                    className = "Drifter"
                    materialIndex = 0
            elseif self.assignedTechId == kTechId.Egg then
                skinVariant = gameInfo:GetTeamCosmeticSlot( self:GetTeamNumber(), kTeamCosmeticSlot4 )
                defaultSkinVariant = kDefaultEggVariant
                className = "Egg"
                materialIndex = 0
            else
                return true -- ignore
            end

            if skinVariant == defaultSkinVariant then
                renderModel:ClearOverrideMaterials()
            else
                local material = GetPrecachedCosmeticMaterial( className, skinVariant )
                renderModel:SetOverrideMaterial( materialIndex, material )
            end

            self:SetHighlightNeedsUpdate()
            return false
        else
            return true
        end
        
    end


end

Shared.LinkClassToMap("Hallucination", Hallucination.kMapName, networkVars)
