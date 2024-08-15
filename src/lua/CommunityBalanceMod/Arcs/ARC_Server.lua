
function ARC:OnTag(tagName)

    PROFILE("ARC:OnTag")
    
    if tagName == "fire_start" then
        self:PerformAttack()
		if self.ShotMulti < self.kMaxArcDamageMulti then
			self.ShotMulti = self.ShotMulti + self.kArcDamageIncrement
		end
    elseif tagName == "target_start" then
        self:TriggerEffects("arc_charge")
    elseif tagName == "attack_end" then
        self:SetMode(ARC.kMode.Targeting)
    elseif tagName == "deploy_start" then
        self:TriggerEffects("arc_deploying")
    elseif tagName == "undeploy_start" then
        self:TriggerEffects("arc_stop_charge")
    elseif tagName == "deploy_end" then
        if self.deployMode ~= ARC.kDeployMode.Deployed then

            -- Clear orders when deployed so new ARC attack order will be used
            self.deployMode = ARC.kDeployMode.Deployed
            self:ClearOrders()
            -- notify the target selector that we have moved.
            self.targetSelector:AttackerMoved()

            self:AdjustMaxHealth(kARCDeployedHealth)
            self.undeployedArmor = self:GetArmor()

            self:SetMaxArmor(kARCDeployedArmor)
            self:SetArmor(self.deployedArmor)
			
			self.ShotMulti = self.kMinArcDamageMulti

        end
    elseif tagName == "undeploy_end" then
        if self.deployMode ~= ARC.kDeployMode.Undeployed then

            self.deployMode = ARC.kDeployMode.Undeployed

            self:AdjustMaxHealth(kARCHealth)
            self.deployedArmor = self:GetArmor()

            self:SetMaxArmor(kARCArmor)
            self:SetArmor(self.undeployedArmor)
        end
    end
    
end

function ARC:PerformAttack()

    local distToTarget = self.targetPosition and (self.targetPosition - self:GetOrigin()):GetLengthXZ()

    if distToTarget and distToTarget >= ARC.kMinFireRange and distToTarget <= ARC.kFireRange then
    
        self:TriggerEffects("arc_firing")    
        -- Play big hit sound at origin
        
        -- don't pass triggering entity so the sound / cinematic will always be relevant for everyone
        GetEffectManager():TriggerEffects("arc_hit_primary", {effecthostcoords = Coords.GetTranslation(self.targetPosition)})
        
        local hitEntities = GetEntitiesWithMixinWithinRange("Live", self.targetPosition, ARC.kSplashRadius)

        -- Do damage to every target in range
        RadiusDamage(hitEntities, self.targetPosition, ARC.kSplashRadius, ARC.kAttackDamage*self.ShotMulti, self, true, nil, false)

        -- Play hit effect on each
        for _, target in ipairs(hitEntities) do
        
            if HasMixin(target, "Effects") then
                target:TriggerEffects("arc_hit_secondary")
            end 
           
        end
        
    end
    
    -- reset target position and acquire new target
    local currentOrder = self:GetCurrentOrder()
    if not currentOrder or currentOrder:GetType() ~= kTechId.Attack then
        self.targetPosition = nil
        self.targetedEntity = Entity.invalidId
    end
    
end