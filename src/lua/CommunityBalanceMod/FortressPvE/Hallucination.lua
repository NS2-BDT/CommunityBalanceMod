-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Hallucination.lua
--
--    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
--
--
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/ScriptActor.lua")

Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/DoorMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/SleeperMixin.lua")
Script.Load("lua/RepositioningMixin.lua")
Script.Load("lua/SoftTargetMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/CloakableMixin.lua")
Script.Load("lua/TargetCacheMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DetectableMixin.lua")

PrecacheAsset("cinematics/vfx_materials/hallucination.surface_shader")
local kHallucinationMaterial = PrecacheAsset( "cinematics/vfx_materials/hallucination.material")

local kDrifterHoverHeight = kDrifterHoverHeight
local kLerkHoverHeight = kLerkHallucinationHoverHeight

class 'Hallucination' (ScriptActor)

Hallucination.kMapName = "hallucination"

Hallucination.kSpotRange = 15.0
Hallucination.kLOSDistance = 8.0
Hallucination.kTurnSpeed  = 4 * math.pi
Hallucination.kDefaultMaxSpeed = 1
Hallucination.kTouchRange = 3.5 -- Max model extents for "touch" uncloaking since we have no collision

local kEnemyDetectInterval = 0.25

local networkVars =
{
    assignedTechId = "enum kTechId",
    moving = "boolean",
    attacking = "boolean",
    hallucinationIsVisible = "boolean",
    creationTime = "time",
    modelScale = "interpolated float (0 to 3 by 0.01)",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)

local gTechIdAttacking
local function GetTechIdAttacks(techId)
    
    if not gTechIdAttacking then
        gTechIdAttacking = {}
        gTechIdAttacking[kTechId.Skulk] = true
        gTechIdAttacking[kTechId.Gorge] = true
        gTechIdAttacking[kTechId.Lerk] = true
        gTechIdAttacking[kTechId.Fade] = true
        gTechIdAttacking[kTechId.Onos] = true
        gTechIdAttacking[kTechId.Whip] = true
        gTechIdAttacking[kTechId.Hydra] = true
    end
    
    return gTechIdAttacking[techId]
    
end

local ghallucinateIdToTechId
function GetTechIdToEmulate(techId)

    if not ghallucinateIdToTechId then
    
        ghallucinateIdToTechId = {}
        ghallucinateIdToTechId[kTechId.HallucinateDrifter] = kTechId.Drifter
        ghallucinateIdToTechId[kTechId.HallucinateSkulk] = kTechId.Skulk
        ghallucinateIdToTechId[kTechId.HallucinateGorge] = kTechId.Gorge
        ghallucinateIdToTechId[kTechId.HallucinateLerk] = kTechId.Lerk
        ghallucinateIdToTechId[kTechId.HallucinateFade] = kTechId.Fade
        ghallucinateIdToTechId[kTechId.HallucinateOnos] = kTechId.Onos
        
        ghallucinateIdToTechId[kTechId.HallucinateHive] = kTechId.Hive
        ghallucinateIdToTechId[kTechId.HallucinateWhip] = kTechId.Whip
        ghallucinateIdToTechId[kTechId.HallucinateShade] = kTechId.Shade
        ghallucinateIdToTechId[kTechId.HallucinateCrag] = kTechId.Crag
        ghallucinateIdToTechId[kTechId.HallucinateShift] = kTechId.Shift
        ghallucinateIdToTechId[kTechId.HallucinateHarvester] = kTechId.Harvester
        ghallucinateIdToTechId[kTechId.HallucinateHydra] = kTechId.Hydra
        
        ghallucinateIdToTechId[kTechId.HallucinateShell] = kTechId.Shell
        ghallucinateIdToTechId[kTechId.HallucinateSpur] = kTechId.Spur
        ghallucinateIdToTechId[kTechId.HallucinateVeil] = kTechId.Veil
        ghallucinateIdToTechId[kTechId.HallucinateEgg] = kTechId.Egg
    
    end
    
    return ghallucinateIdToTechId[techId]

end

-- current list of valid hallucination types
local techIdToHallucinateId = {}
techIdToHallucinateId[kTechId.Drifter] = kTechId.HallucinateDrifter
techIdToHallucinateId[kTechId.Whip] = kTechId.HallucinateWhip
techIdToHallucinateId[kTechId.Shade] = kTechId.HallucinateShade
techIdToHallucinateId[kTechId.Crag] = kTechId.HallucinateCrag
techIdToHallucinateId[kTechId.Shift] = kTechId.HallucinateShift
techIdToHallucinateId[kTechId.Shell] = kTechId.HallucinateShell
techIdToHallucinateId[kTechId.Spur] = kTechId.HallucinateSpur
techIdToHallucinateId[kTechId.Veil] = kTechId.HallucinateVeil
techIdToHallucinateId[kTechId.Egg] = kTechId.HallucinateEgg

techIdToHallucinateId[kTechId.FortressWhip] = kTechId.HallucinateWhip
techIdToHallucinateId[kTechId.FortressShade] = kTechId.HallucinateShade
techIdToHallucinateId[kTechId.FortressCrag] = kTechId.HallucinateCrag
techIdToHallucinateId[kTechId.FortressShift] = kTechId.HallucinateShift

local hallucinateStructureTypes = {
    kTechId.HallucinateShade,
    kTechId.HallucinateWhip,
    kTechId.HallucinateCrag,
    kTechId.HallucinateShift,
    kTechId.HallucinateShell,
    kTechId.HallucinateSpur,
    kTechId.HallucinateVeil,
    kTechId.HallucinateDrifter,
    kTechId.HallucinateEgg,
}

local gTechIdCanMove
local function GetHallucinationCanMove(techId)

    if not gTechIdCanMove then
        gTechIdCanMove = {}
        gTechIdCanMove[kTechId.Skulk] = true
        gTechIdCanMove[kTechId.Gorge] = true
        gTechIdCanMove[kTechId.Lerk] = true
        gTechIdCanMove[kTechId.Fade] = true
        gTechIdCanMove[kTechId.Onos] = true
        
        gTechIdCanMove[kTechId.Drifter] = true
        gTechIdCanMove[kTechId.Whip] = true
        gTechIdCanMove[kTechId.Crag] = true
        gTechIdCanMove[kTechId.Shade] = true
        gTechIdCanMove[kTechId.Shift] = true
        
        gTechIdCanMove[kTechId.Shell] = true
        gTechIdCanMove[kTechId.Spur] = true
        gTechIdCanMove[kTechId.Veil] = true
        gTechIdCanMove[kTechId.Egg] = true
    end 
       
    return gTechIdCanMove[techId]

end

local gTechIdCanBuild
local function GetHallucinationCanBuild(techId)

    if not gTechIdCanBuild then
        gTechIdCanBuild = {}
        gTechIdCanBuild[kTechId.Gorge] = true
    end 
       
    return gTechIdCanBuild[techId]

end

local function GetEmulatedClassName(techId)
    return EnumToString(kTechId, techId)
end

-- model graphs should already be precached elsewhere
local gTechIdAnimationGraph
local function GetAnimationGraph(techId)

    if not gTechIdAnimationGraph then
        gTechIdAnimationGraph = {}
        gTechIdAnimationGraph[kTechId.Skulk] = "models/alien/skulk/skulk.animation_graph"
        gTechIdAnimationGraph[kTechId.Gorge] = "models/alien/gorge/gorge.animation_graph"
        gTechIdAnimationGraph[kTechId.Lerk] = "models/alien/lerk/lerk.animation_graph"
        gTechIdAnimationGraph[kTechId.Fade] = "models/alien/fade/fade.animation_graph"         
        gTechIdAnimationGraph[kTechId.Onos] = "models/alien/onos/onos.animation_graph"
        gTechIdAnimationGraph[kTechId.Drifter] = "models/alien/drifter/drifter.animation_graph"  
        
        gTechIdAnimationGraph[kTechId.Hive] = "models/alien/hive/hive.animation_graph"
        gTechIdAnimationGraph[kTechId.Whip] = "models/alien/whip/whip_1.animation_graph" -- new
        gTechIdAnimationGraph[kTechId.Shade] = "models/alien/shade/shade.animation_graph"
        gTechIdAnimationGraph[kTechId.Crag] = "models/alien/crag/crag.animation_graph"
        gTechIdAnimationGraph[kTechId.Shift] = "models/alien/shift/shift.animation_graph"
        gTechIdAnimationGraph[kTechId.Harvester] = "models/alien/harvester/harvester.animation_graph"
        gTechIdAnimationGraph[kTechId.Hydra] = "models/alien/hydra/hydra.animation_graph"
        
        gTechIdAnimationGraph[kTechId.Shell] = "models/alien/shell/shell.animation_graph"
        gTechIdAnimationGraph[kTechId.Spur] = "models/alien/spur/spur.animation_graph"
        gTechIdAnimationGraph[kTechId.Veil] = "models/alien/veil/veil.animation_graph"
        gTechIdAnimationGraph[kTechId.Egg] = "models/alien/egg/egg.animation_graph"
        
    end
    
    return gTechIdAnimationGraph[techId]

end

local gTechIdMaxMovementSpeed
local function GetMaxMovementSpeed(techId)

    if not gTechIdMaxMovementSpeed then
        gTechIdMaxMovementSpeed = {}
        gTechIdMaxMovementSpeed[kTechId.Skulk] = 8
        gTechIdMaxMovementSpeed[kTechId.Gorge] = 5.1
        gTechIdMaxMovementSpeed[kTechId.Lerk] = 9
        gTechIdMaxMovementSpeed[kTechId.Fade] = 7
        gTechIdMaxMovementSpeed[kTechId.Onos] = 7
        
        gTechIdMaxMovementSpeed[kTechId.Drifter] = 11
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

local gTechIdMoveState
local function GetMoveName(techId)

    if not gTechIdMoveState then
        gTechIdMoveState = {}
        gTechIdMoveState[kTechId.Lerk] = "fly"    
    end
    
    local moveState = gTechIdMoveState[techId]
    
    return ConditionalValue(moveState == nil, "run", moveState)

end

local function SetAssignedAttributes(self, hallucinationTechId, reset)

    -- hallucinationTechId is ignored...
    local model = LookupTechData(self.assignedTechId, kTechDataModel, Shade.kModelName)
    local hallucinatedTechDataId = techIdToHallucinateId[self.assignedTechId]
    local health = hallucinatedTechDataId and LookupTechData(hallucinatedTechDataId, kTechDataMaxHealth)
                    or math.min(LookupTechData(self.assignedTechId, kTechDataMaxHealth, kMatureShadeHealth) * kHallucinationHealthFraction, kHallucinationMaxHealth)
    local armor = hallucinatedTechDataId and LookupTechData(hallucinatedTechDataId, kTechDataMaxArmor)
                    or LookupTechData(self.assignedTechId, kTechDataMaxArmor, kMatureShadeArmor) * kHallucinationArmorFraction
		
    self.maxSpeed = GetMaxMovementSpeed(self.assignedTechId)    
    self:SetModel(model, GetAnimationGraph(self.assignedTechId))

    -- do not reset health when changing model
    --[[if (reset == true) or not self.emulationDone then
        self:SetMaxHealth(health)
        self:SetHealth(health)
        self:SetMaxArmor(armor)
        self:SetArmor(armor)
    end--]]
	
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

    self.emulationDone = true

end

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

function Hallucination:OnCreate()
    
    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, DoorMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin, { kPlayFlinchAnimations = true })
    InitMixin(self, TeamMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, PathingMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, SoftTargetMixin)
    InitMixin(self, CloakableMixin)
    InitMixin(self, DetectableMixin)
    
    if Server then
		
        self.emulationDone = false
        self.hallucinationIsVisible = true
        self.attacking = false
        self.moving = false
        self.assignedTechId = kTechId.Shade --kTechId.Skulk
        
        self.storedHealthFraction = 1
        self.storedArmorScalar = 1
        
        InitMixin(self, SleeperMixin)
        
    end

    self:SetUpdates(true, kRealTimeUpdateRate) --kDefaultUpdateRate)
    self.modelScale = 1.0
    
end

function Hallucination:OnInitialized()
    
    ScriptActor.OnInitialized(self)

    if Server then
    
        SetAssignedAttributes(self, kTechId.HallucinateShade)

        InitMixin(self, RepositioningMixin)

        self:SetPhysicsType(PhysicsType.Kinematic)
        
        InitMixin(self, MobileTargetMixin)
        
        self:AddTimedCallback(self.ScanForNearbyEnemy, kEnemyDetectInterval) -- uncloak when enemy is near
				
        -- TargetSelectors require the TargetCacheMixin for cleanup.
        InitMixin(self, TargetCacheMixin)
        
        self.targetSelector = TargetSelector():Init(
                self,
                Hallucination.kSpotRange,
                true, 
                { kAlienStaticTargets, kAlienMobileTargets })
                
    elseif Client then
        InitMixin(self, UnitStatusMixin)
    end
    
    self:SetPhysicsGroup(PhysicsGroup.SmallStructuresGroup)
    
end

function Hallucination:OnDestroy()

    ScriptActor.OnDestroy(self)
    
    
    if Client then
    
        if self.hallucinationMaterial then
        
            Client.DestroyRenderMaterial(self.hallucinationMaterial)
            self.hallucinationMaterial = nil
            
        end
    
    end

end

function Hallucination:GetIsFlying()
    return self.assignedTechId == kTechId.Drifter
end

function Hallucination:GetAssignedTechId()
    return self.assignedTechId
end    

function Hallucination:SetAssignedTechModelScaling(hallucinationTechId)
    local techId = ghallucinateIdToTechId[hallucinationTechId]
    if techId then
        local className = EnumToString(kTechId, techId)
        local scale = _G[className].kModelScale
        self.modelScale = scale or 1        
    end
end

function Hallucination:SetEmulation(hallucinationTechId, reset)

    self.assignedTechId = GetTechIdToEmulate(hallucinationTechId)
    SetAssignedAttributes(self, hallucinationTechId, reset)
        
    if not HasMixin(self, "MapBlip") then
        InitMixin(self, MapBlipMixin)
    end
    
    self:SetAssignedTechModelScaling(hallucinationTechId)
    
    local yOffset = self:GetIsFlying() and self:GetHoverHeight() or 0
    self:SetOrigin(GetGroundAt(self, self:GetOrigin(), PhysicsMask.Movement, EntityFilterOne(self)) + Vector(0, yOffset, 0))

end

function Hallucination:GetMaxSpeed()
    if self.assignedTechId == kTechId.Fade and not self.hallucinationIsVisible then
        return self.maxSpeed * 2
    end

    return self.maxSpeed
end

--[[
function Hallucination:GetSurfaceOverride()
    return "hallucination"
end
--]]

function Hallucination:GetCanReposition()
    return false -- GetHallucinationCanMove(self.assignedTechId)
end
 
function Hallucination:OverrideGetRepositioningTime()
    return 0.4
end    

function Hallucination:OverrideRepositioningSpeed()
    return self.maxSpeed * 1.2 --* 0.8
end

function Hallucination:OverrideRepositioningDistance()
    if self.assignedTechId == kTechId.Onos then
        return 4
    end
    
    return 0.8
end

function Hallucination:GetCanSleep()
    return self:GetCurrentOrder() == nil    
end

function Hallucination:GetTurnSpeedOverride()
    return Hallucination.kTurnSpeed
end

function Hallucination:OnUpdate(deltaTime)

    ScriptActor.OnUpdate(self, deltaTime)

    if Server then
        self:UpdateServer(deltaTime)
        --UpdateHallucinationLifeTime(self)
    elseif Client then
        self:UpdateClient(deltaTime)
    end    
    
    self.moveSpeed = self:GetIsMoving() and self.maxSpeed or 0
    
    self:SetPoseParam("move_yaw", 90)
    self:SetPoseParam("move_speed", self.moveSpeed)

end

function Hallucination:OnOverrideDoorInteraction(inEntity)   
    return true, 2
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
		
        local entities = GetEntitiesWithMixinForTeamWithinRange("Live", self:GetTeamNumber(), position, 2)
		
        local CheckFunc = function(entity)
            return techIdToHallucinateId[entity:GetTechId()] and true or entity:isa("Hallucination") or false
        end
		
        local closest = GetClosestFromTable(entities, CheckFunc, position)

        if closest then
            local hallucType = techIdToHallucinateId[closest:GetTechId()] or closest:isa("Hallucination") and techIdToHallucinateId[closest.assignedTechId]
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
    
        local hallucType = hallucinateStructureTypes[ math.random(#hallucinateStructureTypes) ]
        self:SetEmulation(hallucType)
        return true, true
        
    elseif techId == kTechId.DestroyHallucination then

        self:Kill()
        return true, true

    end
    
    return false, true

end

--[[function Hallucination:PerformAction(techNode, _)

end--]]

function Hallucination:GetIsMoving()
    return self.moving
end

function Hallucination:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player)
    
    if techId == kTechId.DestroyHallucination then
        allowed = true
    end

    return allowed, canAfford

end

function Hallucination:GetTechButtons(techId)

    return { kTechId.HallucinateCloning, kTechId.None, kTechId.HallucinateRandom, kTechId.None,
             kTechId.None, kTechId.None, kTechId.None, kTechId.DestroyHallucination }
    
end

local function OnUpdateAnimationInputCustom(self, techId, modelMixin, moveState)

    if techId == kTechId.Lerk then
        modelMixin:SetAnimationInput("flapping", self:GetIsMoving())
    elseif techId == kTechId.Fade and not self.hallucinationIsVisible then
        modelMixin:SetAnimationInput("move", "blink")
    end

end

function Hallucination:OnUpdateAnimationInput(modelMixin)

    local moveState = "idle"
    
    if self:GetIsMoving() then
        moveState = GetMoveName(self.assignedTechId)
    end

    modelMixin:SetAnimationInput("built", true)
    modelMixin:SetAnimationInput("move", moveState) 
    OnUpdateAnimationInputCustom(self, self.assignedTechId, modelMixin, moveState)

end

function Hallucination:GetIsMoveable()
    return true
end

function Hallucination:OnUpdatePoseParameters()
    self:SetPoseParam("grow", 1.0)
end

function Hallucination:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    local multiplier = self.assignedTechId == kTechId.Egg and 1.16 or
                       self.assignedTechId == kTechId.Drifter and 1.7 or
                       kHallucinationDamageMulti

    damageTable.damage = damageTable.damage * multiplier

end

if Server then

    function Hallucination:UpdateServer(deltaTime)
    
        if self.timeInvisible and not self.hallucinationIsVisible then
            self.timeInvisible = math.max(self.timeInvisible - deltaTime, 0)
            
            if self.timeInvisible == 0 then
            
                self.hallucinationIsVisible = true
            
            end
            
        end
            
        self:UpdateOrders(deltaTime)
    
    end
    
    function Hallucination:GetDestroyOnKill()
        return true
    end

    function Hallucination:OnKill(attacker, doer, point, direction)
    
        ScriptActor.OnKill(self, attacker, doer, point, direction)
        
        self:TriggerEffects("death_hallucination")
        
    end
    --[[
    function Hallucination:OnScan()
        self:Kill()
    end
    --]]
    function Hallucination:GetHoverHeight()

        if self.assignedTechId == kTechId.Lerk then
            return kLerkHoverHeight
        elseif self.assignedTechId == kTechId.Drifter then
            return kDrifterHoverHeight
        else
            return 0
        end

    end
    
    local function PerformSpecialMovement(self)
        
        if self.assignedTechId == kTechId.Fade then
            
            -- blink every now and then
            if not self.nextTimeToBlink then
                self.nextTimeToBlink = Shared.GetTime()
            end    
            
            local distToTarget = (self:GetCurrentOrder():GetLocation() - self:GetOrigin()):GetLengthXZ()
            if self.nextTimeToBlink <= Shared.GetTime() and distToTarget > 17 then -- 17 seems to be a good value as minimum distance to trigger blink

                self.hallucinationIsVisible = false
                self.timeInvisible = 0.5 + math.random() * 2
                self.nextTimeToBlink = Shared.GetTime() + 2 + math.random() * 8
            
            end
            
        end
    
    end
    
    function Hallucination:UpdateMoveOrder(deltaTime)
    
        local currentOrder = self:GetCurrentOrder()
        ASSERT(currentOrder)
        
        self:MoveToTarget(PhysicsMask.AIMovement, currentOrder:GetLocation(), self:GetMaxSpeed(), deltaTime)
        
        if self:IsTargetReached(currentOrder:GetLocation(), kAIMoveOrderCompleteDistance) then
            self:CompletedCurrentOrder()
        else
        
            self:SetOrigin(GetHoverAt(self, self:GetOrigin()))
            PerformSpecialMovement(self)
            self.moving = true
            
        end
        
    end
    
    function Hallucination:UpdateAttackOrder(deltaTime)
    
        if not GetTechIdAttacks(self.assignedTechId) then
            self:ClearCurrentOrder()
            return
        end    
        
    end

    
    function Hallucination:UpdateBuildOrder(deltaTime)
    
        local currentOrder = self:GetCurrentOrder()
        local techId = currentOrder:GetParam()
        local engagementDist = LookupTechData(techId, kTechDataEngagementDistance, 0.35)
        local distToTarget = (currentOrder:GetLocation() - self:GetOrigin()):GetLengthXZ()
        
        if (distToTarget < engagementDist) then   
        
            local commander = self:GetOwner()
            if (not commander) then
                self:ClearOrders(true, true)
                return
            end
            
            local techIdToEmulate = GetTechIdToEmulate(techId)
            
            local origin = currentOrder:GetLocation()
            local trace = Shared.TraceRay(Vector(origin.x, origin.y + .1, origin.z), Vector(origin.x, origin.y - .2, origin.z), CollisionRep.Select, PhysicsMask.CommanderBuild, EntityFilterOne(self))
            local legalBuildPosition, position, attachEntity = GetIsBuildLegal(techIdToEmulate, trace.endPoint, 0, 4, self:GetOwner(), self)

            if (not legalBuildPosition) then
                self:ClearOrders()
                return
            end
            
            --[[ deprecated
            local createdHallucination = CreateEntity(Hallucination.kMapName, position, self:GetTeamNumber())
            if createdHallucination then
            
                createdHallucination:SetEmulation(techId)
                
                -- Drifter hallucinations are destroyed when they construct something
                if self.assignedTechId == kTechId.Drifter then
                    self:Kill()
                else
                
                    local costs = LookupTechData(techId, kTechDataCostKey, 0)
                    self:AddEnergy(-costs)
                    self:TriggerEffects("spit_structure")
                    self:CompletedCurrentOrder()
                
                end
                
            else--]]
            
                self:ClearOrders(true, true)
                return
                
            -- end
            
        else
            self:UpdateMoveOrder(deltaTime)
        end
        
    end
    
    function Hallucination:UpdateOrders(deltaTime)
    
        local currentOrder = self:GetCurrentOrder()

        if currentOrder then
        
            if currentOrder:GetType() == kTechId.Move and GetHallucinationCanMove(self.assignedTechId) then
                self:UpdateMoveOrder(deltaTime)
            elseif currentOrder:GetType() == kTechId.Attack then
                self:UpdateAttackOrder(deltaTime)
            elseif currentOrder:GetType() == kTechId.Build and GetHallucinationCanBuild(self.assignedTechId) then
                self:UpdateBuildOrder(deltaTime)
            else
                self:ClearCurrentOrder()
            end
            
        else

            self.moving = false
            self.attacking = false

        end    
    
    end
    
    function Hallucination:ScanForNearbyEnemy()

        self.lastDetectedTime = self.lastDetectedTime or 0
        if self.lastDetectedTime + kEnemyDetectInterval <= Shared.GetTime() then

            local done = false

            -- Finally check if the cysts have players in range.
            if not done and #GetEntitiesForTeamWithinRange("Player", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), Hallucination.kTouchRange) > 0 then
                self:TriggerUncloak()
                done = true
            end

            self.lastDetectedTime = Shared.GetTime()
        end

        return self:GetIsAlive()
    end
    
end

function Hallucination:GetEngagementPointOverride()
    return self:GetOrigin() + Vector(0, 0.35, 0)
end

function Hallucination:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

function Hallucination:GetSendDeathMessage()
    return not self.consumed
end

function Hallucination:GetReceivesStructuralDamage()
    return _GetReceivesStructuralDamage(self.assignedTechId)
end

function Hallucination:OnAdjustModelCoords(modelCoords)
    if self.modelScale ~= 1 then    
        modelCoords.xAxis = modelCoords.xAxis * self.modelScale
        modelCoords.yAxis = modelCoords.yAxis * self.modelScale
        modelCoords.zAxis = modelCoords.zAxis * self.modelScale
    end
    return modelCoords
end

function Hallucination:OverrideVisionRadius()
    return Hallucination.kLOSDistance -- kPlayerLOSDistance
end

if Client then

    function Hallucination:OnUpdateRender()
    
        PROFILE("Hallucination:OnUpdateRender")
    
        local showMaterial = not GetAreEnemies(self, Client.GetLocalPlayer())
    
        local model = self:GetRenderModel()
        if model then

            model:SetMaterialParameter("glowIntensity", 0)

            if showMaterial then
                
                if not self.hallucinationMaterial then
                    self.hallucinationMaterial = AddMaterial(model, kHallucinationMaterial)
                end
                
                self:SetOpacity(0, "hallucination")
            
            else
            
                if self.hallucinationMaterial then
                    RemoveMaterial(model, self.hallucinationMaterial)
                    self.hallucinationMaterial = nil
                end
                
                self:SetOpacity(1, "hallucination")
            
            end

            if self.clientDirty == nil or (self.clientAssignedTechId ~= self.assignedTechId) then
                self.clientDirty = not self:UpdateVariant(model)
                if not self.clientDirty then
                    self.clientAssignedTechId = self.assignedTechId
                end
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
            return true
        else
            return false
        end
        
    end

    function Hallucination:UpdateClient(deltaTime)
    
        if self.clientHallucinationIsVisible == nil then
            self.clientHallucinationIsVisible = self.hallucinationIsVisible
        end    
    
        if self.clientHallucinationIsVisible ~= self.hallucinationIsVisible then
        
            self.clientHallucinationIsVisible = self.hallucinationIsVisible
            if self.hallucinationIsVisible then
                self:OnShow()
            else
                self:OnHide()
            end  
        end
    
        self:SetIsVisible(self.hallucinationIsVisible)
        
        if self:GetIsVisible() and self:GetIsMoving() then
            self:UpdateMoveSound(deltaTime)
        end
    
    end
    
    function Hallucination:UpdateMoveSound(deltaTime)
    
        if not self.timeUntilMoveSound then
            self.timeUntilMoveSound = 0
        end
        
        if self.timeUntilMoveSound == 0 then
        
            local surface = GetSurfaceAndNormalUnderEntity(self)            
            self:TriggerEffects("footstep", {classname = GetEmulatedClassName(self.assignedTechId), surface = surface, left = true, sprinting = false, forward = true, crouch = false})
            self.timeUntilMoveSound = 0.3
            
        else
            self.timeUntilMoveSound = math.max(self.timeUntilMoveSound - deltaTime, 0)     
        end
    
    end
    
    function Hallucination:OnHide()
    
        if self.assignedTechId == kTechId.Fade then
            self:TriggerEffects("blink_out")
        end
    
    end
    
    function Hallucination:OnShow()
    
        if self.assignedTechId == kTechId.Fade then
            self:TriggerEffects("blink_in")
        end
    
    end

end

Shared.LinkClassToMap("Hallucination", Hallucination.kMapName, networkVars)
