-- ========= Community Balance Mod ===============================
--
-- "lua\DamageTypes.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================




local BuildDamageTypeRules = debug.getupvaluex(GetDamageByType, "BuildDamageTypeRules")

local function ApplyFriendlyFireModifier(target, attacker, _, damage, armorFractionUsed, healthPerArmor, _, _, _, overshieldDamage)

    if target and attacker and target ~= attacker and HasMixin(target, "Team") and HasMixin(attacker, "Team") and target:GetTeamNumber() == attacker:GetTeamNumber() then
        damage = damage * kFriendlyFireScalar
    end

    -- selfharm by grenade, cluster or mine
    if target and attacker and target == attacker and HasMixin(target, "Team") and HasMixin(attacker, "Team") and target:GetTeamNumber() == attacker:GetTeamNumber() then
        damage = damage * kFriendlyFireScalar
    end

    return damage, armorFractionUsed, healthPerArmor, overshieldDamage
end

debug.setupvaluex(BuildDamageTypeRules, "ApplyFriendlyFireModifier", ApplyFriendlyFireModifier)
debug.setupvaluex(GetDamageByType, "BuildDamageTypeRules",  BuildDamageTypeRules)