function AlienUpgradeManager:GetCostForUpgrade(upgradeId)
    if self.initialUpgrades:Contains(upgradeId) and self.initialLifeFormTechId == self.lifeFormTechId then
        return 0
    end

    if self.initialLifeFormTechId ~= self.lifeFormTechId then
        return LookupTechData(self.lifeFormTechId, kTechDataUpgradeCost, 0)
    end

    for _,traitId in ipairs(kTraitsInChamberMap[upgradeId]) do
        if self.initialUpgrades:Contains(traitId) then
            return LookupTechData(self.lifeFormTechId, kTechDataSwitchUpgradeCost, 0)
        end
    end

    return LookupTechData(self.lifeFormTechId, kTechDataUpgradeCost, 0)
end
