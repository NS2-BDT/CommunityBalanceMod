kResilienceCost = 0
kResilienceScalarBuffs = 0.3334
kResilienceScalarDebuffs = 0.3334

kAdvancedPrototypeLabResearchTime = kExosuitTechResearchTime -- 90
kAdvancedPrototypeLabUpgradeCost = kExosuitTechResearchCost -- 20
kAdvancedPrototypeLabHealth = kPrototypeLabHealth  -- 3000
kAdvancedPrototypeLabArmor = kPrototypeLabArmor -- 500   
kAdvancedPrototypeLabPointValue = kPrototypeLabPointValue -- 20

-- higher = less points for building
kAlienBuildPointDivider = 5 
kMarineBuildPointDivider = 2

--kMineDamage = 130
kMineDamageType = kDamageType.Mine -- vanilla: kDamageType.Normal

kPulseGrenadeDamage = 60 -- vanilla: 50
kPulseGrenadeDamageType = kDamageType.PulseGrenade --vanilla -- kDamageType.Normal

kAlienResilienceDamageReductionPercentByLevel = 10

--kRailgunDamage = 10
--kRailgunChargeDamage = 140
kRailgunDamageType = kDamageType.Rail -- vanilla: Structural

kStompDamage = 50 -- vanilla: 40

kHallucinationCloudAbilityCooldown = 10 -- vanilla: 12
kCystDetectRange = 5 -- vanilla: 8

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