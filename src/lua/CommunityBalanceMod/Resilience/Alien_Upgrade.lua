-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================

function GetResilienceScalar(target, debuff)
    local scalar = 1.0

    if not target or not target:isa("Alien") then
        return scalar
    end

    local hasResilience = target:GetHasUpgrade(kTechId.Resilience)
    local shellCount = target:GetShellLevel()

    if hasResilience then
        if debuff then
            scalar = 1.0 - kResilienceScalarDebuffs * shellCount
        else
            scalar = 1.0 + kResilienceScalarBuffs * shellCount
        end
    end

    return math.max(0, scalar)
end
