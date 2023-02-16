Railgun.kDamageFalloffStart = 10 -- in meters, full damage closer than this.
Railgun.kDamageFalloffEnd = 20 -- in meters, minimum damage further than this, gradient between start/end.
Railgun.kDamageFalloffReductionFactor = 0.5 -- 50% reduction
Railgun.kPierceDamageReductionFactor = 0.5

-- We need kChargeTime and kBulletSize for ExecuteShot...
-- TODO: These should really be attributes of the Railgun class
local Shoot = debug.getupvaluex(Railgun.OnTag, "Shoot")
local OldExecuteShot = debug.getupvaluex(Shoot, "ExecuteShot")
local kChargeTime = debug.getupvaluex(OldExecuteShot, "kChargeTime")
local kBulletSize = debug.getupvaluex(OldExecuteShot, "kBulletSize")

local function ExecuteShot(self, startPoint, endPoint, player)
    -- Filter ourself out of the trace so that we don't hit ourselves.
    local filter = EntityFilterTwo(player, self)
    local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAllButIsa("Tunnel"))
    local hitPointOffset = trace.normal * 0.3
    local direction = (endPoint - startPoint):GetUnit()
    local damage = kRailgunDamage + math.min(1, (Shared.GetTime() - self.timeChargeStarted) / kChargeTime) * kRailgunChargeDamage
    
    local extents = GetDirectedExtentsForDiameter(direction, kBulletSize)

    --[[
         NOTE(Salads)

         This tracebox loop needs to happen every time since we need to find penetration targets,
         and the initial trace ignores everything except gorge tunnels in order to find the max distance
         we should keep checking targets for...

         The loop will break if the leftover distance is small enough, however.
    --]]

    local hitEntities = {}
    local totalDistance = 0
    for _ = 1, 20 do
        local capsuleTrace = Shared.TraceBox(extents, startPoint, trace.endPoint, CollisionRep.Damage, PhysicsMask.Bullets, filter)
        if capsuleTrace.entity then

            if not table.find(hitEntities, capsuleTrace.entity) then
                -- LegacyBalanceMod: Apply falloff damage
                local distance = (capsuleTrace.endPoint - startPoint):GetLength() + totalDistance
                local falloffFactor = Clamp((distance - self.kDamageFalloffStart) / (self.kDamageFalloffEnd - self.kDamageFalloffStart), 0, 1)
                local nearDamage = damage
                local farDamage = damage * self.kDamageFalloffReductionFactor
                local thisDamage = nearDamage * (1.0 - falloffFactor) + farDamage * falloffFactor

                for i = 1, #hitEntities do
                    thisDamage = thisDamage * Railgun.kPierceDamageReductionFactor
                end

                table.insert(hitEntities, capsuleTrace.entity)
                self:DoDamage(thisDamage, capsuleTrace.entity, capsuleTrace.endPoint + hitPointOffset, direction, capsuleTrace.surface, false, false)

                totalDistance = distance
            end
        end

        -- Stop looping early if we've reached the end.
        if (capsuleTrace.endPoint - trace.endPoint):GetLength() <= extents.x then
            break
        end

        -- use new start point
        startPoint = Vector(capsuleTrace.endPoint) + direction * extents.x * 3
    end

    local effectFrequency = self:GetTracerEffectFrequency()
    local showTracer = (math.random() < effectFrequency)

    -- Tell other players in relevancy to show the tracer. Does not tell the shooting player.
    self:DoDamage(0, nil, trace.endPoint + hitPointOffset, direction, trace.surface, false, showTracer)

    -- Tell the player who shot to show the tracer.
    if Client and showTracer then
        TriggerFirstPersonTracer(self, trace.endPoint)
    end
end

debug.setupvaluex(Shoot, "ExecuteShot", ExecuteShot)
debug.setupvaluex(Railgun.OnTag, "Shoot", Shoot)
