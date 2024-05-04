if not Server then return end

-- THIS FILE IS NOTHING BUT ENDLESS FUN

local BuildDamageTypeRules = debug.getupvaluex(GetDamageByType, "BuildDamageTypeRules")
local oldApplyTargetModifiers = debug.getupvaluex(BuildDamageTypeRules, "ApplyTargetModifiers")

local function ApplyTargetModifiers(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint, weapon, overshieldDamage)
    damage, armorFractionUsed, healthPerArmor, overshieldDamage = oldApplyTargetModifiers(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint, weapon, overshieldDamage)

    if target:isa("Alien") and damage > 0 then
        target:OnHealthArmorDamageTaken()
    end

    return damage, armorFractionUsed, healthPerArmor, overshieldDamage
end

debug.setupvaluex(BuildDamageTypeRules, "ApplyTargetModifiers", ApplyTargetModifiers)
debug.setupvaluex(GetDamageByType, "BuildDamageTypeRules", BuildDamageTypeRules)
