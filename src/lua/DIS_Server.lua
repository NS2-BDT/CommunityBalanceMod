local kMoveParam = "move_speed"

function DIS:UpdateMoveOrder(deltaTime)

    local currentOrder = self:GetCurrentOrder()
    ASSERT(currentOrder)

    self:SetMode(DIS.kMode.Moving)

    local moveSpeed = self:GetIsInCombat() and DIS.kCombatMoveSpeed or DIS.kMoveSpeed
    local maxSpeedTable = { maxSpeed = moveSpeed }
    self:ModifyMaxSpeed(maxSpeedTable)

    self:MoveToTarget(PhysicsMask.AIMovement, currentOrder:GetLocation(), maxSpeedTable.maxSpeed, deltaTime)

    self:AdjustPitchAndRoll()

    if self:IsTargetReached(currentOrder:GetLocation(), kAIMoveOrderCompleteDistance) then

        self:CompletedCurrentOrder()
        self:SetPoseParam(kMoveParam, 0)

        -- If no more orders, we're done
        if self:GetCurrentOrder() == nil then
            self:SetMode(DIS.kMode.Stationary)
        end

    else
        self:SetPoseParam(kMoveParam, .5)
    end

end


function DIS:PerformAttack()

    local distToTarget = self.targetPosition and (self.targetPosition - self:GetOrigin()):GetLengthXZ()

    if distToTarget and distToTarget >= DIS.kMinFireRange and distToTarget <= DIS.kFireRange then
    
        self:TriggerEffects("dis_firing")    
        -- Play big hit sound at origin
        
        -- don't pass triggering entity so the sound / cinematic will always be relevant for everyone
        GetEffectManager():TriggerEffects("dis_hit_primary", {effecthostcoords = Coords.GetTranslation(self.targetPosition)})
        
        local hitEntities = GetEntitiesWithMixinWithinRange("Maturity", self.targetPosition, DIS.kSplashRadius)

        -- Do damage to every target in range
        RadiusDamage(hitEntities, self.targetPosition, DIS.kSplashRadius, DIS.kAttackDamage, self, true, nil, false)

        -- Play hit effect on each
        for _, target in ipairs(hitEntities) do
        
			if target.SetElectrified then
				target:SetElectrified(kDISElectrifiedDuration)
			end
		
            if HasMixin(target, "Effects") then
                target:TriggerEffects("dis_hit_secondary")
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

function DIS:OnTag(tagName)

    PROFILE("DIS:OnTag")
    
    if tagName == "fire_start" then
        self:PerformAttack()
    elseif tagName == "target_start" then
        self:TriggerEffects("arc_charge")
    elseif tagName == "attack_end" then
        self:SetMode(DIS.kMode.Targeting)
    elseif tagName == "deploy_start" then
        self:TriggerEffects("arc_deploying")
    elseif tagName == "undeploy_start" then
        self:TriggerEffects("arc_stop_charge")
    elseif tagName == "deploy_end" then
        if self.deployMode ~= DIS.kDeployMode.Deployed then

            -- Clear orders when deployed so new DIS attack order will be used
            self.deployMode = DIS.kDeployMode.Deployed
            self:ClearOrders()
            -- notify the target selector that we have moved.
            self.targetSelector:AttackerMoved()

            self:AdjustMaxHealth(kDISDeployedHealth)
            self.undeployedArmor = self:GetArmor()

            self:SetMaxArmor(kDISDeployedArmor)
            self:SetArmor(self.deployedArmor)

        end
    elseif tagName == "undeploy_end" then
        if self.deployMode ~= DIS.kDeployMode.Undeployed then

            self.deployMode = DIS.kDeployMode.Undeployed

            self:AdjustMaxHealth(kDISHealth)
            self.deployedArmor = self:GetArmor()

            self:SetMaxArmor(kDISArmor)
            self:SetArmor(self.undeployedArmor)
        end
    end
    
end