-- ========= Community Balance Mod ===============================
--
-- "lua\DamageTypes.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================



local upgradedDamageScalars
local upgradedDamageScalarsStructure --MDS Marines
function NS2Gamerules_GetUpgradedDamageScalar( attacker, weaponTechId, target ) --MDS added target

    -- kTechId gets loaded after this, and i don't want to load it. :T
    if not upgradedDamageScalars then

        upgradedDamageScalars =
        {
            [kTechId.Shotgun]         = { kShotgunWeapons1DamageScalar,         kShotgunWeapons2DamageScalar,         kShotgunWeapons3DamageScalar },
           -- [kTechId.GrenadeLauncher] = { kGrenadeLauncherWeapons1DamageScalar, kGrenadeLauncherWeapons2DamageScalar, kGrenadeLauncherWeapons3DamageScalar },
           -- [kTechId.Flamethrower]    = { kFlamethrowerWeapons1DamageScalar,    kFlamethrowerWeapons2DamageScalar,    kFlamethrowerWeapons3DamageScalar },
            ["Default"]               = { kWeapons1DamageScalar,                kWeapons2DamageScalar,                kWeapons3DamageScalar },
        }

    end

    --MDS Marines
    if not upgradedDamageScalarsStructure then

        upgradedDamageScalarsStructure =
        {
            [kTechId.Shotgun]         = { kShotgunWeapons1DamageScalarStructure,         kShotgunWeapons2DamageScalarStructure,         kShotgunWeapons3DamageScalarStructure },
           -- [kTechId.GrenadeLauncher] = { kGrenadeLauncherWeapons1DamageScalarStructure, kGrenadeLauncherWeapons2DamageScalarStructure, kGrenadeLauncherWeapons3DamageScalarStructure },
           -- [kTechId.Flamethrower]    = { kFlamethrowerWeapons1DamageScalarStructure,    kFlamethrowerWeapons2DamageScalarStructure,    kFlamethrowerWeapons3DamageScalarStructure },
            ["Default"]               = { kWeapons1DamageScalarStructure,                kWeapons2DamageScalarStructure,                kWeapons3DamageScalarStructure },
        }

    end

    local upgradeScalars = upgradedDamageScalars["Default"]
    if upgradedDamageScalars[weaponTechId] then
        upgradeScalars = upgradedDamageScalars[weaponTechId]
    end

    --MDS Marines
    local upgradeScalarsStructure = upgradedDamageScalarsStructure["Default"]
    if upgradedDamageScalarsStructure[weaponTechId] then
        upgradeScalarsStructure = upgradedDamageScalarsStructure[weaponTechId]
    end

    --MDS Marines
    -- Hitsounds.lua calls this function without target, but since structures dont produce a hitsound anyways we dont need to apply it.
    if target and GetReceivesStructuralDamage(target) then 
        if GetHasTech(attacker, kTechId.Weapons3, true) then
            return upgradeScalarsStructure[3]
        elseif GetHasTech(attacker, kTechId.Weapons2, true) then
            return upgradeScalarsStructure[2]
        elseif GetHasTech(attacker, kTechId.Weapons1, true) then
            return upgradeScalarsStructure[1]
        end
    else


        if GetHasTech(attacker, kTechId.Weapons3, true) then
            return upgradeScalars[3]
        elseif GetHasTech(attacker, kTechId.Weapons2, true) then
            return upgradeScalars[2]
        elseif GetHasTech(attacker, kTechId.Weapons1, true) then
            return upgradeScalars[1]
        end
    end
    
    return 1.0

end

-- MDS Marines
-- Use this function to change damage according to current upgrades
function NS2Gamerules_GetUpgradedDamage(attacker, doer, damage, _, _, target)

    local damageScalar = 1

    if attacker ~= nil and target ~= nil then

        -- Damage upgrades only affect weapons, not ARCs, Sentries, MACs, Mines, etc.
        if doer.GetIsAffectedByWeaponUpgrades and doer:GetIsAffectedByWeaponUpgrades() then
           
            --MDS Marines added last argument
            damageScalar = NS2Gamerules_GetUpgradedDamageScalar( attacker, ConditionalValue(HasMixin(doer, "Tech"), doer:GetTechId(), kTechId.None), target) -- added target
        end

    end

    return damage * damageScalar

end




-- MDS adds target for _
local function ApplyAttackerModifiers(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint, _, overshieldDamage)

    -- MDS adds target to function
    damage = NS2Gamerules_GetUpgradedDamage(attacker, doer, damage, damageType, hitPoint, target) 
    damage = damage * Gamerules_GetDamageMultiplier()

    if attacker and attacker.ComputeDamageAttackerOverride then
        damage, overshieldDamage = attacker:ComputeDamageAttackerOverride(attacker, damage, damageType, doer, hitPoint, overshieldDamage)
    end

    if doer and doer.ComputeDamageAttackerOverride then
        damage, overshieldDamage = doer:ComputeDamageAttackerOverride(attacker, damage, damageType, doer, hitPoint, overshieldDamage)
    end

    if attacker and attacker.ComputeDamageAttackerOverrideMixin then
        damage, overshieldDamage = attacker:ComputeDamageAttackerOverrideMixin(attacker, damage, damageType, doer, hitPoint, overshieldDamage)
    end

    if doer and doer.ComputeDamageAttackerOverrideMixin then
        damage, overshieldDamage = doer:ComputeDamageAttackerOverrideMixin(attacker, damage, damageType, doer, hitPoint, overshieldDamage)
    end

    return damage, armorFractionUsed, healthPerArmor, overshieldDamage

end


local BuildDamageTypeRules = debug.getupvaluex(GetDamageByType, "BuildDamageTypeRules")
debug.setupvaluex( BuildDamageTypeRules, "ApplyAttackerModifiers", ApplyAttackerModifiers)


