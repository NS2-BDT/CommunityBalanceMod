

-- Resilience
kResilienceCost = 0
kResilienceScalarBuffs = 0.3334
kResilienceScalarDebuffs = 0.3334
kAlienResilienceDamageReductionPercentByLevel = 10
kPulseGrenadeDamageType = kDamageType.PulseGrenade --vanilla -- kDamageType.Normal
kMineDamageType = kDamageType.Mine -- vanilla: kDamageType.Normal
kRailgunDamageType = kDamageType.Rail -- vanilla: Structural


-- Advanced Protolab
kAdvancedPrototypeLabResearchTime = kExosuitTechResearchTime -- 90
kAdvancedPrototypeLabUpgradeCost = kExosuitTechResearchCost -- 20
kAdvancedPrototypeLabHealth = kPrototypeLabHealth  -- 3000
kAdvancedPrototypeLabArmor = kPrototypeLabArmor -- 500   
kAdvancedPrototypeLabPointValue = kPrototypeLabPointValue -- 20


-- Buffs
kPulseGrenadeDamage = 60 -- vanilla: 50
kStompDamage = 50 -- vanilla: 40


-- Reduced switching cost
kSkulkSwitchUpgradeCost = 0
kGorgeSwitchUpgradeCost = 1
kLerkSwitchUpgradeCost = 2
kFadeSwitchUpgradeCost = 3
kOnosSwitchUpgradeCost = 4

-- Not really the right place for this but it'll be fine
local kUpgradesGroupedByChamber = {
    { kTechId.Crush, kTechId.Celerity, kTechId.Adrenaline },
    { kTechId.Camouflage, kTechId.Aura, kTechId.Focus },
    { kTechId.Vampirism, kTechId.Resilience, kTechId.Regeneration },
}

kTraitsInChamberMap = {}
for _,chamberTraits in ipairs(kUpgradesGroupedByChamber) do
    for i = 1,3 do
        kTraitsInChamberMap[chamberTraits[i]] = chamberTraits
    end
end


-- FortressPvE
kFortressUpgradeCost = 24
kFortressResearchTime = 10
kFortressAbilityCooldown = 10
kFortressAbilityCost = 3
kCragCost = 8
kShiftCost = 8
kShadeCost = 8
kWhipCost = 8
kShadeHallucinationCost = 3
kShadeHallucinationCooldown = 10
kMaxHallucinations = 5
kHallucinationLifeTime = 30

kWhipAbilityCost = 4
kWhipAbilityCooldown = 9


-- MDS Marines only
kARCDamage = 610 -- vanilla 530
kFlamethrowerDamage = 9 --vanilla 9.918
kGrenadeLauncherGrenadeDamage = 65 --vanilla 74.381

-- GL and FT for their playerdamage change have to be removed at damagetypes.lua from their special damage table "upgradedDamageScalars"
local kDamagePerUpgradeScalarStructure = 0.1 * 2
kWeapons1DamageScalarStructure = 1 + kDamagePerUpgradeScalarStructure
kWeapons2DamageScalarStructure = 1 + kDamagePerUpgradeScalarStructure * 2
kWeapons3DamageScalarStructure = 1 + kDamagePerUpgradeScalarStructure * 3

local kShotgunDamagePerUpgradeScalarStructure = 0.0784 * 2
kShotgunWeapons1DamageScalarStructure = 1 + kShotgunDamagePerUpgradeScalarStructure
kShotgunWeapons2DamageScalarStructure = 1 + kShotgunDamagePerUpgradeScalarStructure * 2
kShotgunWeapons3DamageScalarStructure = 1 + kShotgunDamagePerUpgradeScalarStructure * 3


-- Gorge energy reduction
kDropHydraEnergyCost = 28 -- vanilla 40
kDropBabblerEggEnergyCost = 10 -- vanilla 15

