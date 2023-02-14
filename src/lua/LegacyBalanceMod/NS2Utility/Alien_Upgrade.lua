function GetResilienceScalar(target)
    local scalar = 1.0

    if not target or not target:isa("Alien") then
        return scalar
    end

    local hasResilience = target:GetHasUpgrade(kTechId.Resilience)
    local shellCount = target:GetShellLevel()

    if not hasResilience then
        scalar = 1.0 - kResilienceScalar * shellCount
    end

    return scalar
end