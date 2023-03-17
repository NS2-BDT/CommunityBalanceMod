local kSpreadDelay = debug.getupvaluex(NerveGasCloud.DoNerveGasDamage, "kSpreadDelay")
local kCloudUpdateRate = debug.getupvaluex(NerveGasCloud.DoNerveGasDamage, "kCloudUpdateRate")

local GetRecentlyDamaged = debug.getupvaluex(NerveGasCloud.DoNerveGasDamage, "GetRecentlyDamaged")
local SetRecentlyDamaged = debug.getupvaluex(NerveGasCloud.DoNerveGasDamage, "SetRecentlyDamaged")
local GetIsInCloud = debug.getupvaluex(NerveGasCloud.DoNerveGasDamage, "GetIsInCloud")

local debugVisUpdateRate = 0.1
local lastVisUpdate = 0
function NerveGasCloud:DoNerveGasDamage()
    local radius = math.min(1, (Shared.GetTime() - self.creationTime) / kSpreadDelay) * kNerveGasCloudRadius

    local time = Shared.GetTime()
    for _, entity in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), 2*kNerveGasCloudRadius)) do
        if not GetRecentlyDamaged(entity:GetId(), (Shared.GetTime() - kCloudUpdateRate)) and GetIsInCloud(self, entity, radius) then
            local resilienceScalar = GetResilienceScalar(entity, true)
            if resilienceScalar > 0 then
                self:DoDamage(kNerveGasDamagePerSecond * kCloudUpdateRate * resilienceScalar, entity, entity:GetOrigin(), GetNormalizedVector(self:GetOrigin() - entity:GetOrigin()), "none")
                SetRecentlyDamaged(entity:GetId())
            end
        end
    end

    if GetDebugGrenadeDamage() then
        if lastVisUpdate + debugVisUpdateRate < time then
        --throttled to prevent net-msg spam
            lastVisUpdate = time
            DebugWireSphere( self:GetOrigin(), radius, 0.45, 1, 1, 0, 1 )
        end
    end

    return true
end
