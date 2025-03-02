-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\AlienUpgradeManager.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
--    Used by client and server to determine if adding / removing upgrades is allowed.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'AlienUpgradeManager'

function AlienUpgradeManager:GetLifeFormTechId()
    return self.lifeFormTechId
end

function AlienUpgradeManager:Populate(player)

    assert(player)
    assert(HasMixin(player, "Upgradable"))

    local upgrades = player:GetUpgrades()
    self.upgrades = unique_set()
    self.upgrades:InsertAll(upgrades)
    self.upgrades:Insert(player:GetTechId())

    self.availableResources = player:GetPersonalResources()
    self.initialResources = player:GetPersonalResources()
    self.lifeFormTechId = player:GetTechId()
    self.initialLifeFormTechId = player:GetTechId()
    self.teamNumber = player:GetTeamNumber()

    self.initialUpgrades = unique_set()
    self.initialUpgrades:InsertAll(self.upgrades:GetList())
end

function AlienUpgradeManager:UpdateResources(newResources)
    self.availableResources = self.availableResources + (newResources - self.initialResources)
    self.initialResources = newResources
end

local function GetHasCategory(currentUpgrades, categoryId)

    if not categoryId then
        return false
    end

    for currentUpgradeId in currentUpgrades:Iterate() do

        local currentCategory = LookupTechData(currentUpgradeId, kTechDataCategory)
        if currentCategory and currentCategory == categoryId then
            return true
        end

    end

    return false

end

function AlienUpgradeManager:RemoveCategoryUpgrades(categoryId)

    for oldUpgradeId in self.upgrades:IterateBackwards() do

        local oldCategoryId = LookupTechData(oldUpgradeId, kTechDataCategory)
        if oldCategoryId == categoryId then
            self:RemoveUpgrade(oldUpgradeId)
        end

    end

end

function AlienUpgradeManager:GetCostRecuperationFor(upgradeId)

    local costRecuperation = 0
    local categoryId = LookupTechData(upgradeId, kTechDataCategory)

    if LookupTechData(upgradeId, kTechDataGestateName) and not self.initialUpgrades:Contains(self.lifeFormTechId) then
        costRecuperation = GetCostForTech(self.lifeFormTechId)
    elseif categoryId then

        for  currentUpgradeId in self.upgrades:Iterate() do

            if LookupTechData(currentUpgradeId, kTechDataCategory) == categoryId and not self.initialUpgrades:Contains(currentUpgradeId) then
                costRecuperation = costRecuperation + GetCostForTech(currentUpgradeId)
            end

        end

    end

    return costRecuperation

end

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


function AlienUpgradeManager:GetCanAffordUpgrade(upgradeId)

    local availableResources = self.availableResources + self:GetCostRecuperationFor(upgradeId)
    local cost = LookupTechData(upgradeId, kTechDataGestateName) and GetCostForTech(upgradeId) or self:GetCostForUpgrade(upgradeId)
    return cost <= availableResources

end

function AlienUpgradeManager:GetIsUpgradeAllowed(upgradeId, override)

    if not self.upgrades then
        self.upgrades = unique_set()
    end

    local allowed = GetIsTechUseable(upgradeId, self.teamNumber)

    if allowed then

        -- check if adding this upgrade is allowed
        local categoryId = LookupTechData(upgradeId, kTechDataCategory)
        if categoryId then

            if self.lifeFormTechId == self.initialLifeFormTechId then
                allowed = allowed and (override or self.initialUpgrades:Contains(upgradeId) or not GetHasCategory(self.initialUpgrades, categoryId))
            end

        end

    end

    return allowed

end

function AlienUpgradeManager:RemoveUpgrade(upgradeId)

    if self.upgrades:Remove(upgradeId) then

        if not self.initialUpgrades:Contains(upgradeId) then
            self.availableResources = self.availableResources + GetCostForTech(upgradeId)
        end

    end

end

function AlienUpgradeManager:RemoveAbilities()
    for upgradeId in self.upgrades:IterateBackwards() do

        if LookupTechData(upgradeId, kTechDataAbilityType) then
            self:RemoveUpgrade(upgradeId)
        end

    end
end

function AlienUpgradeManager:RestoreAbilities()

    for initialUpgradeId in self.initialUpgrades:Iterate() do

        if LookupTechData(initialUpgradeId, kTechDataAbilityType) then
            self.upgrades:Insert(initialUpgradeId)
        end

    end

end

function AlienUpgradeManager:RestoreUpgrades()

    for initialUpgradeId in self.initialUpgrades:Iterate() do

        if not LookupTechData(initialUpgradeId, kTechDataAbilityType) and not LookupTechData(initialUpgradeId, kTechDataGestateName) then
            self.upgrades:Insert(initialUpgradeId)
        end

    end

end

function AlienUpgradeManager:RemoveUpgrades()
    for upgradeId in self.upgrades:IterateBackwards() do

        if not LookupTechData(upgradeId, kTechDataAbilityType) and not LookupTechData(upgradeId, kTechDataGestateName) then
            self.upgrades:Remove(upgradeId)
        end

    end

end

function AlienUpgradeManager:GetHasChanged()

    local changed = self.upgrades:GetCount() ~= self.initialUpgrades:GetCount()

    if not changed then

        for _, upgradeId in ipairs(self.upgrades:GetList()) do

            if not self.initialUpgrades:Contains(upgradeId) then
                changed = true
                break
            end

        end

    end

    return changed
end

function AlienUpgradeManager:AddUpgrade(upgradeId, override)

    if not upgradeId or upgradeId == kTechId.None then
        return false
    end

    local categoryId = LookupTechData(upgradeId, kTechDataCategory)
    if override or not GetHasCategory(self.initialUpgrades, categoryId) or self.initialLifeFormTechId ~= self.lifeFormTechId then

        -- simple remove overlapping upgrades first
        if categoryId then
            self:RemoveCategoryUpgrades(categoryId)
        end

    end

    local allowed = self:GetIsUpgradeAllowed(upgradeId, override)
    local canAfford = self:GetCanAffordUpgrade(upgradeId)

    if allowed and canAfford then

        local cost = 0

        if LookupTechData(upgradeId, kTechDataGestateName) then

            self.upgrades:Clear() -- Remove all upgrades

            if self.initialUpgrades:Contains(upgradeId) then
                -- Restore initial upgrades when initial lifeform is readded
                self:RestoreAbilities()
                self:RestoreUpgrades()
            end

            self.lifeFormTechId = upgradeId
            cost = GetCostForTech(upgradeId)

        else
            cost = self:GetCostForUpgrade(upgradeId)
        end

        self.upgrades:Insert(upgradeId)
        self.availableResources = self.availableResources - cost

        return true

    end

    return false

end

function AlienUpgradeManager:GetHasUpgrade(upgradeId)
    return self.upgrades:Contains(upgradeId)
end

function AlienUpgradeManager:GetUpgrades()
    return self.upgrades:GetList()
end

function AlienUpgradeManager:GetAvailableResources()
    return self.availableResources
end