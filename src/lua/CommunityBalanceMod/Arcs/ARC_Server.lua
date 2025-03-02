
function ARC:OnTag(tagName)

    PROFILE("ARC:OnTag")
    
    if tagName == "fire_start" then
        self:PerformAttack()
		if self.ShotMulti < self.kMaxArcDamageMulti then
			self.ShotMulti = (self.ShotNumber/self.kArcShotScaling)^2 + ARC.kMinArcDamageMulti
			self.ShotNumber = self.ShotNumber + 1
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
			
			-- Start discharging arc weapon
			self.ShotNumber = math.max(self.ShotNumber - self.kArcDeployPunishment, 0)
			self.ShotMulti = self.kMinArcDamageMulti
			self.timeOfLastUndeployDischarge = Shared.GetTime()
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

function ARC:UpdateOrders(deltaTime)

    -- If deployed, check for targets.
    local currentOrder = self:GetCurrentOrder()
    local isCurrentOrderAttack  = currentOrder and currentOrder:GetType() == kTechId.Attack
    
	if self.deployMode == ARC.kDeployMode.Undeployed and (Shared.GetTime() > self.timeOfLastUndeployDischarge + ARC.kDischargeRate) then
		self.ShotNumber = math.max(self.ShotNumber - 1, 0)
		self.timeOfLastUndeployDischarge = Shared.GetTime()
	end
	
    if currentOrder then

        -- Move ARC if it has an order and it can be moved.
        local canMove = self.deployMode == ARC.kDeployMode.Undeployed
		
        if currentOrder:GetType() == kTechId.Move and canMove then
            self:UpdateMoveOrder(deltaTime)
        elseif currentOrder:GetType() == kTechId.ARCDeploy then
            self:Deploy()
        elseif currentOrder:GetType() == kTechId.Attack then

            local targetEnt = (self.targetedEntity and self.targetedEntity ~= Entity.invalidId and Shared.GetEntity(self.targetedEntity)) or nil
            if self.targetPosition and targetEnt and HasMixin(targetEnt, "Live") and targetEnt:GetIsAlive() then
                if self.mode ~= ARC.kMode.Targeting then
                    self:SetMode(ARC.kMode.Targeting)
                end

                if not self:UpdateTargetingPosition() then
                    self:CompletedCurrentOrder()
                end
            else
                self.targetPosition = nil
                self.targetedEntity = Entity.invalidId
                self:CompletedCurrentOrder()
            end
            
        end

    elseif self:GetInAttackMode() then

        -- Make sure we immediately update our target if we just finished with a manual attack order
        if self.lastHadAttackOrder ~= isCurrentOrderAttack then
            self:AcquireTarget()
        end
        
        if self.targetPosition then
        
            self:UpdateTargetingPosition()
            
        else
        
            -- Check for new target every so often, but not every frame.
            local time = Shared.GetTime()
            if self.timeOfLastAcquire == nil or (time > self.timeOfLastAcquire + 0.2) then
            
                self:AcquireTarget()
                self.timeOfLastAcquire = time
                
            end
            
        end
    
    else
        self.targetPosition = nil
        self.targetedEntity = Entity.invalidId
    end
    
    self.lastHadAttackOrder = isCurrentOrderAttack
    
end