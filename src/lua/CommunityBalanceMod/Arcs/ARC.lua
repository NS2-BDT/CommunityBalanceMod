ARC.kMaxArcDamageMulti = 1.75
ARC.kMinArcDamageMulti = 0.75
ARC.kArcShotScaling = 35 -- Point of forced hive death shot amount
ARC.kArcDeployPunishment = 5
ARC.kDischargeRate = 3

function ARC:OnCreate()

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
    InitMixin(self, RolloutMixin)
    
    if Server then
    
        InitMixin(self, RepositioningMixin)
        InitMixin(self, SleeperMixin)
        
        self.targetPosition = nil
        self.targetedEntity = Entity.invalidId
		self.ShotMulti = self.kMinArcDamageMulti
		self.ShotNumber = 0
		self.timeOfLastUndeployDischarge = Shared.GetTime()
        
    elseif Client then
        InitMixin(self, CommanderGlowMixin)
    end
    
    self.deployMode = ARC.kDeployMode.Undeployed
    
    self:SetLagCompensated(true)

    self:SetUpdates(true, kRealTimeUpdateRate)
    
end

function ARC:GetCanFireAtTargetActual(target, targetPoint, manuallyTargeted)

    if not target.GetReceivesStructuralDamage or not target:GetReceivesStructuralDamage() then        
        return false
    end
    

    -- don't target eggs (they take only splash damage)
    -- Hydra exclusion has to due with people using them to prevent ARC shooting Hive. 
    if target:isa("Egg") or target:isa("Cyst") or target:isa("Contamination") then
        return false
    end

    if not manuallyTargeted and target:isa("Hydra") then
        return false
    end

    if not manuallyTargeted and target:isa("Hallucination") then
        return false
    end
    
    if not target:GetIsSighted() and not GetIsTargetDetected(target) then
        return false
    end

    local distToTarget = (target:GetOrigin() - self:GetOrigin()):GetLengthXZ()
    if (distToTarget > ARC.kFireRange) or (distToTarget < ARC.kMinFireRange) then
        return false
    end
    
    return true

end
