kResilienceCost = 0
kResilienceScalarBuffs = 0.3334
kResilienceScalarDebuffs = 0.3334

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
