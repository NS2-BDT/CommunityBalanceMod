-- ========= Community Balance Mod ===============================
--
-- "lua\DamageTypes.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================








kDamageType = enum(
        {
            'Normal', 'Light', 'Heavy', 'Puncture',
            'Structural', 'StructuralHeavy', 'Splash',
            'Gas', 'NerveGas', 'StructuresOnly',
            'Falling', 'Door', 'Flame',
            'Corrode', 'ArmorOnly', 'Biological', 'StructuresOnlyLight',
            'Spreading', 'GrenadeLauncher', 'MachineGun', 'ClusterFlame',
            'ClusterFlameFragment',
            "Mine", "Rail", "PulseGrenade" --CommunityBalanceMod
            
        })



local BuildDamageTypeRules = debug.getupvaluex(GetDamageByType, "BuildDamageTypeRules")
local MultiplyForStructures = debug.getupvaluex(BuildDamageTypeRules, "MultiplyForStructures")



local function BuildResilienceDamageTypeRules()
    --CommunityBalanceMod
     -- Mine damage rules
     kDamageTypeRules[kDamageType.Mine] = {
    }
    -- ------------------------------

    --CommunityBalanceMod
     -- Rail damage rules
     kDamageTypeRules[kDamageType.Rail] = {
        MultiplyForStructures
    }
    -- ------------------------------

    --CommunityBalanceMod
     -- PulseGrenade damage rules
     kDamageTypeRules[kDamageType.PulseGrenade] = {
    }
    -- ------------------------------
end





-- applies all rules and returns damage, armorUsed, healthUsed
function GetDamageByType(target, attacker, doer, damage, damageType, hitPoint, weapon)

    assert(target)

    if not kDamageTypeGlobalRules or not kDamageTypeRules then
        BuildDamageTypeRules()

        BuildResilienceDamageTypeRules() -- Balance Mod
    end

    -- at first check if damage is possible, if not we can skip the rest
    if not CanEntityDoDamageTo(attacker, target, Shared.GetCheatsEnabled(), Shared.GetDevMode(), GetFriendlyFire(), damageType) then
        return 0, 0, 0, 0
    end

    local armorUsed = 0
    local healthUsed = 0

    local armorFractionUsed = 0
    local healthPerArmor = 0
    local overshieldDamage = 0

    -- apply global rules at first
    for _, rule in ipairs(kDamageTypeGlobalRules) do
        damage, armorFractionUsed, healthPerArmor, overshieldDamage = rule(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint, weapon, overshieldDamage)
    end

    --Account for Alien Chamber Upgrades damage modifications (must be before damage-type rules)
    if attacker:GetTeamType() == kAlienTeamType and attacker:isa("Player") then
        damage, armorFractionUsed = NS2Gamerules_GetUpgradedAlienDamage( target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint, weapon )
    end



    -- Balance Mod
    if target:GetTeamType() == kAlienTeamType then
        damage, armorFractionUsed = NS2Gamerules_ResilienceAlienDamage( target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint, weapon )
    end



    -- apply damage type specific rules
    for _, rule in ipairs(kDamageTypeRules[damageType]) do
        damage, armorFractionUsed, healthPerArmor = rule(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    end

    if target.ModifyDamageTakenPostRules then
        local damageTable = {}
        damageTable.damage = damage
        damageTable.armorFractionUsed = armorFractionUsed
        damageTable.healthPerArmor = healthPerArmor
        damage, armorFractionUsed, healthPerArmor = target:ModifyDamageTakenPostRules(damageTable, attacker, doer, damageType, hitPoint)
    end

    if damage > 0 and healthPerArmor > 0 then

        -- Each point of armor blocks a point of health but is only destroyed at half that rate (like NS1)
        -- Thanks Harimau!
        local healthPointsBlocked = math.min(healthPerArmor * target.armor, armorFractionUsed * damage)
        armorUsed = healthPointsBlocked / healthPerArmor

        -- Anything left over comes off of health
        healthUsed = damage - healthPointsBlocked

    end

    return damage, armorUsed, healthUsed, overshieldDamage

end



--CommunityBalanceMod
local kResilienceDamageReduceTypes = {
    kDamageType.Rail,
    kDamageType.Mine,
    kDamageType.GrenadeLauncher,
    kDamageType.Flame,
    kDamageType.ClusterFlame,
    kDamageType.ClusterFlameFragment,
    kDamageType.PulseGrenade,
    kDamageType.NerveGas,
}

--CommunityBalanceMod
function NS2Gamerules_ResilienceAlienDamage( target, attacker, doer, damage, armorFractionUsed, _, damageType )

    if target:isa("Player") and target:GetHasUpgrade( kTechId.Resilience) and table.contains(kResilienceDamageReduceTypes, damageType) then
        
        damage = damage - damage * target:GetShellLevel() * kAlienResilienceDamageReductionPercentByLevel / 100
    end

    return damage, armorFractionUsed
end








