-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\Hydra_Server.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- Creepy plant turret the Gorge can create.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Hydra.kUpdateInterval = .5

function Hydra:OnKill(attacker, doer, point, direction)

    ScriptActor.OnKill(self, attacker, doer, point, direction)
    
    local team = self:GetTeam()
    if team then
        team:UpdateClientOwnedStructures(self:GetId())
    end

end

function Hydra:GetSendDeathMessageOverride()
    return not self.consumed
end

function Hydra:GetDistanceToTarget(target)
    return (target:GetEngagementPoint() - self:GetModelOrigin()):GetLength()           
end

-- Spread changes based on target distance.
function Hydra:CreateSpikeProjectile()

    -- TODO: make hitscan at account for target velocity (more inaccurate at higher speed)

    local startPoint = self:GetBarrelPoint()
    local directionToTarget = self.target:GetEngagementPoint() - self:GetEyePos()
    local targetDistance = directionToTarget:GetLength()
    local theTimeToReachEnemy = targetDistance / Hydra.kSpikeSpeed
    local engagementPoint = self.target:GetEngagementPoint()
    if self.target.GetVelocity then

        local targetVelocity = self.target:GetVelocity()
        engagementPoint = self.target:GetEngagementPoint() - ((targetVelocity:GetLength() * Hydra.kTargetVelocityFactor * theTimeToReachEnemy) * GetNormalizedVector(targetVelocity))

    end

    local fireDirection = GetNormalizedVector(engagementPoint - startPoint)
    local fireCoords = Coords.GetLookIn(startPoint, fireDirection)

    local spreadFraction = Clamp((targetDistance - Hydra.kNearDistance) / (Hydra.kFarDistance - Hydra.kNearDistance), 0, 1)
    local spread = Hydra.kNearSpread * (1.0 - spreadFraction) + Hydra.kFarSpread * spreadFraction

    local spreadDirection = CalculateSpread(fireCoords, spread, math.random)

    local endPoint = startPoint + spreadDirection * Hydra.kRange

    local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOneAndIsa(self, "Hydra"))

    if trace.fraction < 1 then

        local surface

        -- Disable friendly fire.
        trace.entity = (not trace.entity or GetAreEnemies(trace.entity, self)) and trace.entity or nil

        if not trace.entity then
            surface = trace.surface
        end

        -- local direction = (trace.endPoint - startPoint):GetUnit()
        self:DoDamage(Hydra.kDamage, trace.entity, trace.endPoint, fireDirection, surface, false, true)

    end

end

function Hydra:GetRateOfFire()
    return Hydra.kRateOfFire
end

-- No changes (incorporating a change to a local function).
function Hydra:AttackTarget()

    self:TriggerUncloak()

    self:CreateSpikeProjectile()
    self:TriggerEffects("hydra_attack")


    self.timeOfNextFire = Shared.GetTime() + self:GetRateOfFire()

end

function Hydra:OnOwnerChanged(_, newOwner)

    self.hydraParentId = Entity.invalidId
    if newOwner ~= nil then
        self.hydraParentId = newOwner:GetId()
    end
    
end

function Hydra:OnUpdate(deltaTime)

    PROFILE("Hydra:OnUpdate")
    
    ScriptActor.OnUpdate(self, deltaTime)
    
	self.electrified = self.timeElectrifyEnds > Shared.GetTime()
	
    if not self.timeLastUpdate then
        self.timeLastUpdate = Shared.GetTime()
    end
    
    if self.timeLastUpdate + Hydra.kUpdateInterval < Shared.GetTime() then
    
        if GetIsUnitActive(self) and not (self:GetIsOnFire() or self.electrified) then
            self.target = self.targetSelector:AcquireTarget()

            -- Check for obstacles between the origin and barrel point of the hydra so it doesn't shoot while sticking through walls
            self.attacking = self.target and not GetWallBetween(self:GetBarrelPoint(), self:GetOrigin(), self) and not GetIsPointInsideClogs(self:GetBarrelPoint())

            if self.attacking and (not self.timeOfNextFire or Shared.GetTime() > self.timeOfNextFire) then
                self:AttackTarget()
            elseif not self.target then
                -- Play alert animation if marines nearby and we're not targeting (ARCs?)
                if not self.timeLastAlertCheck or Shared.GetTime() > self.timeLastAlertCheck + Hydra.kAlertCheckInterval then
                
                    self.alerting = false
                    
                    if self:GetIsEnemyNearby() then
                    
                        self.alerting = true
                        self.timeLastAlertCheck = Shared.GetTime()
                        
                    end
                    
                end
            end

        else
            self.attacking = false
        end
        
        self.timeLastUpdate = Shared.GetTime()
        
    end
    
end

function Hydra:GetIsEnemyNearby()

    local enemyPlayers = GetEntitiesForTeam("Player", GetEnemyTeamNumber(self:GetTeamNumber()))
    
    for _, player in ipairs(enemyPlayers) do
    
        if player:GetIsVisible() and not player:isa("Commander") then
        
            local dist = self:GetDistanceToTarget(player)
            if dist < Hydra.kRange then
                return true
            end
            
        end
        
    end
    
    return false
    
end
