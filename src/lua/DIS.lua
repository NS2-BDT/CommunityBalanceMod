-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\DIS.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- AI controllable "tank" that the Commander can move around, deploy and use for long-distance
-- siege attacks.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/DoorMixin.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/UpgradableMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/AchievementGiverMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/MobileTargetMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/RepositioningMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/SleeperMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/TargetCacheMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/CorrodeMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/SupplyUserMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/WebableMixin.lua")
Script.Load("lua/ParasiteMixin.lua")
Script.Load("lua/BlightMixin.lua")
Script.Load("lua/BlowtorchTargetMixin.lua")
Script.Load("lua/RolloutMixin.lua")

class 'DIS' (ScriptActor)

DIS.kMapName = "dis"

DIS.kModelName = PrecacheAsset("models/marine/arc/arc.model")
local kAnimationGraph = PrecacheAsset("models/marine/arc/arc.animation_graph")

local kArcSilencerMaterial = PrecacheAsset("models/marine/arc/arc_silencer.material")

-- Animations
local kDisPitchParam = "arc_pitch"
local kDisYawParam = "arc_yaw"

DIS.kArcForwardTrackYawParam = "move_yaw"
DIS.kArcForwardTrackPitchParam = "move_pitch"

-- Balance
DIS.kHealth                 = kDISHealth
DIS.kStartDistance          = 4
DIS.kAttackDamage           = kDISDamage
DIS.kFireRange              = kDISRange
DIS.kMinFireRange           = kDISMinRange
DIS.kSplashRadius           = 7
DIS.kUpgradedSplashRadius   = 13
DIS.kMoveSpeed              = 2.5
DIS.kCombatMoveSpeed        = 2.25
DIS.kFov                    = 360
DIS.kBarrelMoveRate         = 100
DIS.kMaxPitch               = 45
DIS.kMaxYaw                 = 180
DIS.kCapsuleHeight = .05
DIS.kCapsuleRadius = .5

DIS.kMode = enum( {'Stationary', 'Moving', 'Targeting', 'Destroyed'} )

DIS.kDeployMode = enum( { 'Undeploying', 'Undeployed', 'Deploying', 'Deployed' } )

DIS.kTurnSpeed = math.pi / 2 -- an DIS turns slowly
DIS.kMaxSpeedLimitAngle = math.pi / 36 -- 5 degrees
DIS.kNoSpeedLimitAngle = math.pi / 4 -- 24 degrees

if Server then
    Script.Load("lua/DIS_Server.lua")
end

local networkVars =
{
    -- DISs can only fire when deployed and can only move when not deployed
    mode = "enum DIS.kMode",
    deployMode = "enum DIS.kDeployMode",
    
    barrelYawDegrees = "compensated float",
    barrelPitchDegrees = "compensated float",
    
    -- pose parameters for forward track (should be compensated??)
    forwardTrackYawDegrees = "float",
    forwardTrackPitchDegrees = "float",
    
    -- So we can update angles and pose parameters smoothly on client
    targetDirection = "vector",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(UpgradableMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(CorrodeMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(WebableMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)
AddMixinNetworkVars(BlightMixin, networkVars)


function DIS:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin, { kTriggeringEnabledDefault = true })
    InitMixin(self, ClientModelMixin)
    InitMixin(self, DoorMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, UpgradableMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin, { kPlayFlinchAnimations = true })
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, AchievementGiverMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, PathingMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, WebableMixin)
    InitMixin(self, ParasiteMixin)
	InitMixin(self, BlightMixin)
    InitMixin(self, RolloutMixin)
    
	self.DisMaterial = false
	
    if Server then
    
        InitMixin(self, RepositioningMixin)
        InitMixin(self, SleeperMixin)
        
        self.targetPosition = nil
        self.targetedEntity = Entity.invalidId
        
    elseif Client then
        InitMixin(self, CommanderGlowMixin)
		InitMixin(self, BlowtorchTargetMixin)
    end
    
    self.deployMode = DIS.kDeployMode.Undeployed
    
    self:SetLagCompensated(true)

    self:SetUpdates(true, kRealTimeUpdateRate)
    
end

function DIS:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    
    self:SetModel(DIS.kModelName, kAnimationGraph)
    
    if Server then
    
        local angles = self:GetAngles()
        self.desiredPitch = angles.pitch
        self.desiredRoll = angles.roll
    
        InitMixin(self, MobileTargetMixin)
        InitMixin(self, SupplyUserMixin)
        
        -- TargetSelectors require the TargetCacheMixin for cleanup.
        InitMixin(self, TargetCacheMixin)
        
        -- Prioritize targetting non-Eggs first.
        self.targetSelector = TargetSelector():Init(
                self,
                DIS.kFireRange,
                false, 
                { kMarineStaticTargets, kMarineMobileTargets },
                { self.FilterTarget(self) },
                { function(target) return target:isa("Hive") end })

        
        self:SetPhysicsType(PhysicsType.Kinematic)
        
        -- Cannons start out mobile
        self:SetMode(DIS.kMode.Stationary)
        
        self.undeployedArmor = kDISArmor
        self.deployedArmor = kDISDeployedArmor
        
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
    
        self.desiredForwardTrackPitchDegrees = 0
        
        InitMixin(self, InfestationTrackerMixin)
    
    elseif Client then
    
        self.lastModeClient = self.mode
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
    
    end
    
    InitMixin(self, IdleMixin)    
end

function DIS:GetHealthbarOffset()
    return 0.7
end 

function DIS:GetPlayIdleSound()
    return self.deployMode == DIS.kDeployMode.Undeployed
end

function DIS:GetReceivesStructuralDamage()
    return true
end

function DIS:GetTurnSpeedOverride()
    return DIS.kTurnSpeed
end

function DIS:GetSpeedLimitAnglesOverride()
    return { DIS.kMaxSpeedLimitAngle, DIS.kNoSpeedLimitAngle }
end

function DIS:GetCanSleep()
    return self.mode == DIS.kMode.Stationary
end

function DIS:GetDeathIconIndex()
    return kDeathMessageIcon.ARC
end

--
-- Put the eye up 1 m.
--
function DIS:GetViewOffset()
    return self:GetCoords().yAxis * 1.0
end

function DIS:GetEyePos()
    return self:GetOrigin() + self:GetViewOffset()
end

function DIS:Deploy(commander)

    local queuedDeploy = commander ~= nil and commander.shiftDown

    if queuedDeploy then
    
        local lastOrder = self:GetLastOrder()        
        local orderOrigin = lastOrder ~=  nil and lastOrder:GetLocation() or self:GetOrigin()
        
        self:GiveOrder(kTechId.DISDeploy, self:GetId(), orderOrigin, nil, false, false)
        
    else

        self:ClearOrders()
        self.deployMode = DIS.kDeployMode.Deploying
        self:TriggerEffects("arc_deploying")
    
    end

end

function DIS:UnDeploy()

end

function DIS:PerformActivation(techId, position, normal, commander)

    if techId == kTechId.DISDeploy then
    
        self:Deploy(commander)
        return true, true
        
    elseif techId == kTechId.DISUndeploy then
        
        if self:GetTarget() ~= nil then
            self:CompletedCurrentOrder()
        end
        
        self:SetMode(DIS.kMode.Stationary)
        
        self.deployMode = DIS.kDeployMode.Undeploying
        
        self:TriggerEffects("arc_stop_charge")
        self:TriggerEffects("arc_undeploying")
        
        return true, true
        
    end  
    
    self.targetPosition = nil
    
    return false, true
    
end

function DIS:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player)
    
    if self.deployMode == DIS.kDeployMode.Deployed and techId == kTechId.DISUndeploy then
        allowed = true
    end
    
    return allowed, canAfford

end

function DIS:GetActivationTechAllowed(techId)

    if techId == kTechId.DISDeploy then
        return self.deployMode == DIS.kDeployMode.Undeployed
    elseif techId == kTechId.Move then
        return self.deployMode == DIS.kDeployMode.Undeployed
    elseif techId == kTechId.DISUndeploy then
        return self.deployMode == DIS.kDeployMode.Deployed
    elseif techId == kTechId.Stop then
        return self.mode == DIS.kMode.Moving or self.mode == DIS.kMode.Targeting
    end
    
    return true
    
end

function DIS:GetTechButtons(techId)

    local attackTechId = self:GetInAttackMode() and kTechId.Attack or kTechId.None
    
    return  { kTechId.Move, kTechId.Stop, attackTechId, kTechId.None,
              kTechId.DISDeploy, kTechId.DISUndeploy, kTechId.None, kTechId.None }
              
end

function DIS:GetInAttackMode()
    return self.deployMode == DIS.kDeployMode.Deployed
end

function DIS:GetCanGiveDamageOverride()
    return true
end

function DIS:GetFov()
    return DIS.kFov
end

function DIS:OnOverrideDoorInteraction(inEntity)
    return true, 4
end

function DIS:GetEffectParams(tableParams)
    tableParams[kEffectFilterDeployed] = self:GetInAttackMode()
end

function DIS:FilterTarget()

    local attacker = self
    return function (target, targetPosition) return attacker:GetCanFireAtTargetActual(target, targetPosition) end
    
end

-- for marquee selection
function DIS:GetIsMoveable()
    return true
end

--
-- Do a complete check if the target can be fired on.
--
function DIS:GetCanFireAtTarget(target, targetPoint)    

    if target == nil then        
        return false
    end
    
    if not HasMixin(target, "Live") or not target:GetIsAlive() then
        return false
    end
    
    if not GetAreEnemies(self, target) then        
        return false
    end
    
    if not target.GetReceivesStructuralDamage or not target:GetReceivesStructuralDamage() then        
        return false
    end
    
    -- don't target eggs (they take only splash damage)
    if target:isa("Egg") or target:isa("Cyst") then
        return false
    end
    
    return self:GetCanFireAtTargetActual(target, targetPoint)
    
end

function DIS:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

--
-- the checks made in GetCanFireAtTarget has already been made by the TargetCache, this
-- is the extra, actual target filtering done.
--
function DIS:GetCanFireAtTargetActual(target, targetPoint, manuallyTargeted)

    if not target.GetReceivesStructuralDamage or not target:GetReceivesStructuralDamage() then        
        return false
    end
    

    -- don't target eggs (they take only splash damage)
    -- Hydra exclusion has to due with people using them to prevent DIS shooting Hive. 
    if target:isa("Egg") or target:isa("Cyst") or target:isa("Contamination") then
        return false
    end

    if not manuallyTargeted and target:isa("Hydra") then
        return false
    end

    if not manuallyTargeted and target:isa("Hallucination") then
        return false
    end
    
    --[[if not target:GetIsSighted() and not GetIsTargetDetected(target) then
        return false
    end]]

    local distToTarget = (target:GetOrigin() - self:GetOrigin()):GetLengthXZ()
    if (distToTarget > DIS.kFireRange) or (distToTarget < DIS.kMinFireRange) then
        return false
    end
    
    return true
    
end

function DIS:UpdateAngles(deltaTime)

    if not self:GetInAttackMode() or not self:GetIsAlive() then
        return
    end
    
    if self.mode == DIS.kMode.Targeting then
    
        if self.targetDirection then
        
            local yawDiffRadians = GetAnglesDifference(GetYawFromVector(self.targetDirection), self:GetAngles().yaw)
            local yawDegrees = DegreesTo360(math.deg(yawDiffRadians))    
            self.desiredYawDegrees = Clamp(yawDegrees, -DIS.kMaxYaw, DIS.kMaxYaw)
            
            local pitchDiffRadians = GetAnglesDifference(GetPitchFromVector(self.targetDirection), self:GetAngles().pitch)
            local pitchDegrees = DegreesTo360(math.deg(pitchDiffRadians))
            self.desiredPitchDegrees = -Clamp(pitchDegrees, -DIS.kMaxPitch, DIS.kMaxPitch)       
            
            self.barrelYawDegrees = Slerp(self.barrelYawDegrees, self.desiredYawDegrees, DIS.kBarrelMoveRate * deltaTime)
            
        end
        
    elseif self.deployMode == DIS.kDeployMode.Deployed or self.mode == DIS.kMode.Targeting then
    
        self.desiredYawDegrees = 0
        self.desiredPitchDegrees = 0
        
        self.barrelYawDegrees = Slerp(self.barrelYawDegrees, self.desiredYawDegrees, DIS.kBarrelMoveRate * deltaTime)
        
    end
    
    self.barrelPitchDegrees = Slerp(self.barrelPitchDegrees, self.desiredPitchDegrees, DIS.kBarrelMoveRate * deltaTime)
    
end

function DIS:OnUpdatePoseParameters()

    PROFILE("DIS:OnUpdatePoseParameters")
    
    self:SetPoseParam(kDisPitchParam, self.barrelPitchDegrees)
    self:SetPoseParam(kDisYawParam , self.barrelYawDegrees)
    self:SetPoseParam(DIS.kArcForwardTrackYawParam , self.forwardTrackYawDegrees)
    self:SetPoseParam(DIS.kArcForwardTrackPitchParam , self.forwardTrackPitchDegrees)
    
end

function DIS:OnUpdate(deltaTime)

    PROFILE("DIS:OnUpdate")
    
    ScriptActor.OnUpdate(self, deltaTime)
    
    if Server then
    
        self:UpdateOrders(deltaTime)
        self:UpdateSmoothAngles(deltaTime)

    end
    
    if self.mode ~= DIS.kMode.Stationary and self.mode ~= DIS.kMode.Moving and self.deployMode ~= DIS.kDeployMode.Deploying and self.mode ~= DIS.kMode.Destroyed then
        self:UpdateAngles(deltaTime)
    end
    
    if Client then
    
        if self.lastModeClient ~= self.mode then
            self:OnModeChangedClient(self.lastModeClient, self.mode)
        end
    
        self.lastModeClient = self.mode
    
    end
    
end

if Client then
    
    function DIS:OnUpdateRender()

		local model = self:GetRenderModel()

		if not self.DisMaterial then

			if model and model:GetReadyForOverrideMaterials() then
			
				model:ClearOverrideMaterials()
				local material = kArcSilencerMaterial
				assert(material)
				model:SetOverrideMaterial( 0, material )

				model:SetMaterialParameter("highlight", 0.91)
				
				self.DisMaterial = true
				self:SetHighlightNeedsUpdate()
			end
		end
    end
end

function DIS:OnModeChangedClient(oldMode, newMode)

    if oldMode == DIS.kMode.Targeting and newMode ~= DIS.kMode.Targeting then
        self:TriggerEffects("arc_stop_effects")
    end

end

function DIS:OnKill(attacker, doer, point, direction)

    self:TriggerEffects("arc_stop_effects")
    
    if Server then
    
        self:ClearTargetDirection()
        self:ClearOrders()
        
        self:SetMode(DIS.kMode.Destroyed)
        
    end 
  
end

function DIS:OnUpdateAnimationInput(modelMixin)

    PROFILE("DIS:OnUpdateAnimationInput")
    
    local activity = "none"
    if self.mode == DIS.kMode.Targeting and self.deployMode == DIS.kDeployMode.Deployed then
        activity = "primary"
    end
    modelMixin:SetAnimationInput("activity", activity)
    
    local deployed = self.deployMode == DIS.kDeployMode.Deploying or self.deployMode == DIS.kDeployMode.Deployed
    modelMixin:SetAnimationInput("deployed", deployed)
    
    local move = "idle"
    if self.mode == DIS.kMode.Moving and self.deployMode == DIS.kDeployMode.Undeployed then
        move = "run"
    end
    modelMixin:SetAnimationInput("move", move)
    
end

function DIS:GetShowHitIndicator()
    return false
end

function DIS:ValidateTargetPosition(position)

    -- ink clouds will screw up with arcs
    --[[local inkClouds = GetEntitiesForTeamWithinRange("ShadeInk", GetEnemyTeamNumber(self:GetTeamNumber()), position, ShadeInk.kShadeInkDisorientRadius)
    if #inkClouds > 0 then
        return false
    end]]

    local distance = (self:GetOrigin() - position):GetLength()
    if distance < DIS.kMinFireRange or distance > DIS.kFireRange then
        return false
    end

    return true

end

function DIS:ValidateTarget(target)

    if not HasMixin(target, "Live") or 
       not target:GetIsAlive() or 
       not GetAreEnemies(self, target) or
       not target.GetReceivesStructuralDamage or not target:GetReceivesStructuralDamage() then
        return false
    end
    
    return true
    
end

function DIS:OnValidateOrder(order)
	
    if order:GetType() == kTechId.Attack then
        local entId = order:GetParam()
        local ent = entId and Shared.GetEntity(entId) or nil
        if not ent or not self:GetCanFireAtTargetActual(ent, nil, true) or not self:ValidateTargetPosition(ent:GetOrigin()) or not self:ValidateTarget(ent) then
            return false
        end
    end
    
    return true
end

function DIS:OnOverrideOrder(order)
    if order:GetType() == kTechId.Default then
        if self.deployMode == DIS.kDeployMode.Deployed then
            order:SetType(kTechId.Attack)
        else
            order:SetType(kTechId.Move)
        end
    end
end

function DIS:OnOrderGiven(order)
    if order ~= nil and (order:GetType() == kTechId.Attack or order:GetType() == kTechId.SetTarget) then
	
        local target = Shared.GetEntity(order:GetParam())
        if target then
            local dist = (self:GetOrigin() - target:GetOrigin()):GetLength()
            local valid = self:ValidateTarget(target)
            if dist and valid and dist >= DIS.kMinFireRange and dist <= DIS.kFireRange then
                self.targetedEntity = order:GetParam()
                self.orderedEntity = order:GetParam()
                self:UpdateTargetingPosition()
            end
        end
    end
end

Shared.LinkClassToMap("DIS", DIS.kMapName, networkVars, true)
