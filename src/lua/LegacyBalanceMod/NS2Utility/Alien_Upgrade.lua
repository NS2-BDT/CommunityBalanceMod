function GetResilienceScalar(target, debuff)
    local scalar = 1.0

    if not target or not target:isa("Alien") then
        return scalar
    end

    local hasResilience = target:GetHasUpgrade(kTechId.Resilience)
    local shellCount = target:GetShellLevel()

    if not hasResilience then
        scalar = kResilienceScalar * shellCount
        if debuff then
            scalar = 1.0 - scalar
        end
    end

    return scalar
end
