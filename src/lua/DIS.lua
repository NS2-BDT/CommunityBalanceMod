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

Script.Load("lua/ARC.lua")

class 'DIS' (ARC)

DIS.kMapName = "dis"

DIS.kModelName = PrecacheAsset("models/marine/arc/arc.model")
local kAnimationGraph = PrecacheAsset("models/marine/arc/arc.animation_graph")
local kArcSilencerMaterial = PrecacheAsset("models/marine/arc/arc_silencer.material")

-- Balance
DIS.kHealth                 = kDISHealth
DIS.kStartDistance          = 4
DIS.kAttackDamage           = kDISDamage
DIS.kFireRange              = kDISRange
DIS.kMinFireRange           = kDISMinRange
DIS.kSplashRadius           = 9
DIS.kMoveSpeed              = 2.5
DIS.kCombatMoveSpeed        = 2.25

if Server then
    Script.Load("lua/DIS_Server.lua")
end

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
    
	self.arcVariant = kDefaultMarineArcVariant
	
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
		self.dirtySkinState = true
		
    end
    
    InitMixin(self, IdleMixin)    
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
    if target:isa("Egg") or target:isa("Contamination") or target:isa("Clog") then
        return false
    end

    if not manuallyTargeted and target:isa("Cyst") then
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

if Client then
    
    function DIS:OnUpdateRender()

		local model = self:GetRenderModel()

		if self.dirtySkinState and self:GetIsAlive() then

			if model and model:GetReadyForOverrideMaterials() then
			
				model:ClearOverrideMaterials()
				local material = kArcSilencerMaterial
				assert(material)
				model:SetOverrideMaterial( 0, material )

				model:SetMaterialParameter("highlight", 0.91)
				
				self.dirtySkinState = false
				self:SetHighlightNeedsUpdate()
			end
		end
    end
end

function DIS:ValidateTargetPosition(position)

    local distance = (self:GetOrigin() - position):GetLength()
    if distance < DIS.kMinFireRange or distance > DIS.kFireRange then
        return false
    end

    return true

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
