-- ========= Community Balance Mod ===============================
--
-- "lua\GUIAlienBuyMenu.lua"
--
--    Created by:   4sdfg
--
-- ===============================================================

local function GetUpgradeCostForLifeForm(player, alienType, upgradeId)
    if player then
        local alienTechNode = GetAlienTechNode(alienType, true)
        if alienTechNode then
            if player:GetTechId() == alienTechNode:GetTechId() and player:GetHasUpgrade(upgradeId) then
                return 0
            end

            if player:GetTechId() ~= alienTechNode:GetTechId() then
                return LookupTechData(alienTechNode:GetTechId(), kTechDataUpgradeCost, 0)
            end

            for _,traitId in ipairs(kTraitsInChamberMap[upgradeId]) do
                if player:GetHasUpgrade(traitId) then
                    return LookupTechData(alienTechNode:GetTechId(), kTechDataSwitchUpgradeCost, 0)
                end
            end

            return LookupTechData(alienTechNode:GetTechId(), kTechDataUpgradeCost, 0)
        end
    end

    return 0
end


local UpdateEvolveButton = debug.getupvaluex(GUIAlienBuyMenu.Update, "UpdateEvolveButton")
local GetCanAffordAlienTypeAndUpgrades = debug.getupvaluex(UpdateEvolveButton, "GetCanAffordAlienTypeAndUpgrades")
local GetSelectedUpgradesCost = debug.getupvaluex(GetCanAffordAlienTypeAndUpgrades, "GetSelectedUpgradesCost")

debug.setupvaluex(GUIAlienBuyMenu._UpdateUpgrades, "GetUpgradeCostForLifeForm", GetUpgradeCostForLifeForm)

-- Follow the local function train choo choo
debug.setupvaluex(GetSelectedUpgradesCost, "GetUpgradeCostForLifeForm", GetUpgradeCostForLifeForm)
debug.setupvaluex(GetCanAffordAlienTypeAndUpgrades, "GetSelectedUpgradesCost", GetSelectedUpgradesCost)
debug.setupvaluex(UpdateEvolveButton, "GetSelectedUpgradesCost", GetSelectedUpgradesCost)
debug.setupvaluex(UpdateEvolveButton, "GetCanAffordAlienTypeAndUpgrades", GetCanAffordAlienTypeAndUpgrades)
debug.setupvaluex(GUIAlienBuyMenu.Update, "UpdateEvolveButton", UpdateEvolveButton)

debug.setupvaluex(GUIAlienBuyMenu.SendKeyEvent, "GetCanAffordAlienTypeAndUpgrades", GetCanAffordAlienTypeAndUpgrades)
