-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================

local removeTechDataValue = "BalanceModRemoveTechData"

local function GetTechToChange()
    return {
    
        [kTechId.DropJetpack] = 
        {
            [kStructureAttachId] = {kTechId.PrototypeLab, kTechId.AdvancedPrototypeLab}
        },
    }
end



local oldBuildTechData = BuildTechData
function BuildTechData()
    local techData = oldBuildTechData()
    local techToChange = GetTechToChange()

    for techIndex,record in ipairs(techData) do
        local techDataId = record[kTechDataId]
        if techToChange[techDataId] then
            for index, value in pairs(techToChange[techDataId]) do
                if value == removeTechDataValue then
                    techData[techIndex][index] = nil
                else
                    techData[techIndex][index] = value
                end
            end
        end
    end

    table.insert(techData, { 
        [kTechDataId] = kTechId.AdvancedPrototypeLab,
        [kTechDataHint] = "PROTOTYPE_LAB_HINT", -- "Jetpacks, Exos"
        [kTechDataTooltipInfo] = "PROTOTYPE_LAB_TOOLTIP", -- "You can buy Jetpacks and Exosuits from here."
        [kTechDataGhostModelClass] = "MarineGhostModel",
        [kTechIDShowEnables] = false,
        [kTechDataRequiresPower] = true,
        [kTechDataMapName] = AdvancedPrototypeLab.kMapName,
        [kTechDataDisplayName] = "PROTOTYPE_LAB", -- "Prototype lab"
        [kTechDataCostKey] = kAdvancedPrototypeLabUpgradeCost + kPrototypeLabCost,
        [kTechDataModel] = PrototypeLab.kModelName,
        [kTechDataMaxHealth] = kPrototypeLabHealth,
        [kTechDataMaxArmor] = kPrototypeLabArmor,
        [kTechDataEngagementDistance] = kArmoryEngagementDistance,
        [kTechDataUpgradeTech] = kTechId.PrototypeLab,
        [kTechDataPointValue] = kPrototypeLabPointValue,
        [kTechDataObstacleRadius] = 0.65,
    })


   table.insert(techData, { 
        [kTechDataId] = kTechId.UpgradeToAdvancedPrototypeLab,
        [kTechDataCostKey] = kAdvancedPrototypeLabUpgradeCost,
        [kTechIDShowEnables] = false,
        [kTechDataResearchTimeKey] = kAdvancedPrototypeLabResearchTime,
        [kTechDataDisplayName] = "RESEARCH_EXOSUITS", -- "Research Exosuits"            text for commander UI
        [kTechDataTooltipInfo] = "EXOSUIT_TECH_TOOLTIP", -- "Allows Exosuits to be purchased"   text for description
        [kTechDataResearchName] = "RESEARCH_EXOSUITS_TITLE" -- "Exosuits"               text for left side
    })

    return techData
end
