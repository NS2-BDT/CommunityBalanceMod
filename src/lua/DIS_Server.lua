-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\DIS_Server.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- AI controllable "tank" that the Commander can move around, deploy and use for long-distance
-- siege attacks.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local kMoveParam = "move_speed"

function DIS:OnEntityChange(oldId)

    if HasMixin(self, "MapBlip") then 
        self:MarkBlipDirty()
    end

    if self.targetedEntity == oldId then
        self.targetedEntity = Entity.invalidId
    end   

end

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

-- to determine the roll and the pitch of the body, we measure the roll
-- at the back tracks only, then take the average of the back roll and
-- a single trace at the rear of the forward track
-- then we add a single trace at the front track (if we get individual
-- front track pitching, we can split that into two)
DIS.kFrontFrontOffset = {1, 0 }
DIS.kFrontRearOffset = {0.3, 0 }
DIS.kLeftRearOffset = {-0.8, -0.55 }
DIS.kRightRearOffset = {-0.8, 0.55 }

DIS.kTrackTurnSpeed = math.pi
DIS.kTrackMaxSpeedAngle = math.rad(5)
DIS.kTrackNoSpeedAngle = math.rad(20)

function DIS:SmoothTurnOverride(time, direction, movespeed)

    local dirYaw = GetYawFromVector(direction)
    local myYaw = self:GetAngles().yaw
    local trackYaw = self:GetDeltaYaw(myYaw,dirYaw)

    -- don't snap the tracks to our direction, need to smooth it
    local desiredTrackYaw = math.rad(Clamp(math.deg(trackYaw), -35, 35))
    local currentTrackYaw = math.rad(self.forwardTrackYawDegrees)
    local turnAmount,remainingYaw = self:CalcTurnAmount(desiredTrackYaw, currentTrackYaw, DIS.kTrackTurnSpeed, time)
    local newTrackYaw = currentTrackYaw + turnAmount

    self.forwardTrackYawDegrees = Clamp(math.deg(newTrackYaw), -35, 35)
    -- if our tracks isn't positioned right, we slow down.
    return movespeed * self:CalcYawSpeedFraction(remainingYaw, DIS.kTrackMaxSpeedAngle, DIS.kTrackNoSpeedAngle)

end

function DIS:TrackTrace(origin, coords, offsets)

    PROFILE("DIS:TrackTrace")

    local zOffset, xOffset = offsets[1], offsets[2]
    local pos = origin + coords.zAxis * zOffset + coords.xAxis * xOffset + Vector.yAxis
    -- TODO: change to EntityFilterOne(self)
    local trace = Shared.TraceRay(pos,pos - Vector.yAxis * 2, CollisionRep.Move, PhysicsMask.Movement,  EntityFilterAll())

    return trace.endPoint
    
end

local kAngleSmoothSpeed = 0.8
local kTrackPitchSmoothSpeed = 30 -- radians
function DIS:UpdateSmoothAngles(deltaTime)

    local angles = self:GetAngles()
    
    angles.pitch = Slerp(angles.pitch, self.desiredPitch, kAngleSmoothSpeed * deltaTime)
    angles.roll = Slerp(angles.roll, self.desiredRoll, kAngleSmoothSpeed * deltaTime)
    
    self:SetAngles(angles)
    
    self.forwardTrackPitchDegrees = Slerp(self.forwardTrackPitchDegrees, self.desiredForwardTrackPitchDegrees, kTrackPitchSmoothSpeed * deltaTime)

end

function DIS:AdjustPitchAndRoll()

    -- adjust our pitch. If we are moving, we trace below our front and rear wheels and set the pitch from there
    if self:GetCoords() ~= self.lastPitchCoords then
    
        self.lastPitchCoords = Coords(self:GetCoords())
        local origin = self:GetOrigin()
        local coords = self:GetCoords()
        local angles = self:GetAngles()
        
        -- first, do the roll
        -- the roll is based on the rear wheels only, as the model seems heavier in the back
        
        local leftRear = self:TrackTrace(origin, coords, DIS.kLeftRearOffset)
        local rightRear = self:TrackTrace(origin, coords, DIS.kRightRearOffset )
        local rearAvg = (leftRear + rightRear) / 2
        
        local rollVec = leftRear - rightRear
        rollVec:Normalize()
        local roll = GetPitchFromVector(rollVec)

        -- the whole-body pitch is based on the rear and the rear of the front tracks
        
        local frontAxel =  self:TrackTrace(origin, coords, DIS.kFrontRearOffset)
        local bodyPitchVec = frontAxel - rearAvg
        bodyPitchVec:Normalize()
        local bodyPitch = GetPitchFromVector(bodyPitchVec)

        -- those are set in OnUpdate and smoothed
        self.desiredPitch = bodyPitch
        self.desiredRoll = roll

        coords = self:GetCoords()
        
        -- Once we have pitched the front forward, the front axel is in a new position
        frontAxel =  self:TrackTrace(origin, coords, DIS.kFrontRearOffset )
     
        local frontOfTrack = self:TrackTrace(origin, coords, DIS.kFrontFrontOffset )
        local trackPitchVec = frontAxel - frontOfTrack
        trackPitchVec:Normalize()
        local trackPitch = GetPitchFromVector(trackPitchVec) + angles.pitch
        self.desiredForwardTrackPitchDegrees = math.ceil(Clamp(math.deg(trackPitch), -35, 35) * 100) * 0.01
        
    end
    
end

function DIS:SetTargetDirection(targetPosition)
    self.targetDirection = GetNormalizedVector(targetPosition - self:GetOrigin())
end

function DIS:ClearTargetDirection()
    self.targetDirection = nil
end

function DIS:UpdateTargetingPosition()

    local targetEntity = Shared.GetEntity(self.targetedEntity)
    if targetEntity then
        self.targetPosition = GetTargetOrigin(targetEntity)
    end

    if self:ValidateTargetPosition(self.targetPosition) then
        self:SetTargetDirection(self.targetPosition)
        return true
    else
        self.targetPosition = nil
        self.targetedEntity = Entity.invalidId
        return false
    end
    
end

function DIS:UpdateOrders(deltaTime)

    -- If deployed, check for targets.
    local currentOrder = self:GetCurrentOrder()
    local isCurrentOrderAttack  = currentOrder and currentOrder:GetType() == kTechId.Attack
    
    if currentOrder then

        -- Move DIS if it has an order and it can be moved.
        local canMove = self.deployMode == DIS.kDeployMode.Undeployed
        if currentOrder:GetType() == kTechId.Move and canMove then
            self:UpdateMoveOrder(deltaTime)
        elseif currentOrder:GetType() == kTechId.DISDeploy then
            self:Deploy()
        elseif currentOrder:GetType() == kTechId.Attack then

            local targetEnt = (self.targetedEntity and self.targetedEntity ~= Entity.invalidId and Shared.GetEntity(self.targetedEntity)) or nil
            if self.targetPosition and targetEnt and HasMixin(targetEnt, "Live") and targetEnt:GetIsAlive() then
                if self.mode ~= DIS.kMode.Targeting then
                    self:SetMode(DIS.kMode.Targeting)
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

function DIS:AcquireTarget()
    
    local finalTarget = self.targetSelector:AcquireTarget()
    
    if finalTarget ~= nil and self:ValidateTargetPosition(finalTarget:GetOrigin()) then
    
        self:SetMode(DIS.kMode.Targeting)
        self.targetPosition = GetTargetOrigin(finalTarget)
        self.targetedEntity = finalTarget:GetId()
        
    else
    
        self:SetMode(DIS.kMode.Stationary)
        self.targetPosition = nil    
        self.targetedEntity = Entity.invalidId
        
    end
    
end

function DIS:PerformAttack()

    local distToTarget = self.targetPosition and (self.targetPosition - self:GetOrigin()):GetLengthXZ()

    if distToTarget and distToTarget >= DIS.kMinFireRange and distToTarget <= DIS.kFireRange then
    
        self:TriggerEffects("arc_firing")    
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

function DIS:SetMode(mode)

    if self.mode ~= mode then
    
        local triggerEffectName = "arc_" .. string.lower(EnumToString(DIS.kMode, mode))        
        self:TriggerEffects(triggerEffectName)
        
        self.mode = mode
        
        local currentOrder = self:GetCurrentOrder()
        
        -- Now process actions per mode
        if self:GetInAttackMode() and (not currentOrder or currentOrder:GetType() ~= kTechId.Attack) then
            self:AcquireTarget()
        end
        
    end
    
end

function DIS:GetCanReposition()
    return true
end

function DIS:OverrideRepositioningSpeed()
    return DIS.kMoveSpeed * 0.7
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

function DIS:AdjustPathingPitch(_, pitch)

    local angles = self:GetAngles()
    angles.pitch = pitch
    self:SetAngles(angles)
    
end
