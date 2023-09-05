kTechDataSwitchUpgradeCost = "switchupgradecost"

local removeTechDataValue = "BalanceModRemoveTechData"

kShowTechTreeCooldown = "kshowtechtreecooldown"

local function GetTechToAdd()
    return {
        {
            [kTechDataId] = kTechId.Resilience,
            [kTechDataCategory] = kTechId.CragHive,
            [kTechDataDisplayName] = "RESILIENCE",
            [kTechDataCostKey] = kResilienceCost,
            [kTechDataTooltipInfo] = "RESILIENCE_TOOLTIP",
        },
        {
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
        },
        {
            [kTechDataId] = kTechId.UpgradeToAdvancedPrototypeLab,
            [kTechDataCostKey] = kAdvancedPrototypeLabUpgradeCost,
            [kTechIDShowEnables] = false,
            [kTechDataResearchTimeKey] = kAdvancedPrototypeLabResearchTime,
            [kTechDataDisplayName] = "RESEARCH_EXOSUITS", -- "Research Exosuits"            text for commander UI
            [kTechDataTooltipInfo] = "EXOSUIT_TECH_TOOLTIP", -- "Allows Exosuits to be purchased"   text for desciption
            [kTechDataResearchName] = "RESEARCH_EXOSUITS_TITLE" -- "Exosuits"               text for left side
        },
    }
end

local function GetTechToChange()
    return {
        [kTechId.Skulk] = {
            [kTechDataSwitchUpgradeCost] = kSkulkSwitchUpgradeCost
        },
        [kTechId.Gorge] = {
            [kTechDataSwitchUpgradeCost] = kGorgeSwitchUpgradeCost
        },
        [kTechId.Lerk] = {
            [kTechDataSwitchUpgradeCost] = kLerkSwitchUpgradeCost
        },
        [kTechId.Fade] = {
            [kTechDataSwitchUpgradeCost] = kFadeSwitchUpgradeCost
        },
        [kTechId.Onos] = {
            [kTechDataSwitchUpgradeCost] = kOnosSwitchUpgradeCost
        },
        [kTechId.ShiftHive] = 
        {
            [kTechDataUpgradeTech] = kTechId.Hive,
        },

        [kTechId.CragHive] = 
        {
            [kTechDataUpgradeTech] = kTechId.Hive,
        },

        [kTechId.ShadeHive] = 
        {
            [kTechDataUpgradeTech] = kTechId.Hive,
        },
        [kTechId.DropJetpack] = 
        {
            [kStructureAttachId] = {kTechId.PrototypeLab, kTechId.AdvancedPrototypeLab}
        },

        -- In vanilla EN its called "Advanced Support" and in every other language except russian "Advanced Assistance"
        -- this will overwrite the russian translation
        [kTechId.AdvancedMarineSupport] = 
        {
            [kTechDataDisplayName] = "ADVANCED_SUPPORT",
            [kTechDataResearchName] = "ADVANCED_SUPPORT",
        }

    }
end

local function GetTechToRemove() 
    return {
        [kTechId.Carapace] = true
    }
end

local function TechDataChanges(techData)
    -- Handle changes / removes
    local techToChange = GetTechToChange()
    local techToRemove = GetTechToRemove()
    local indexToRemove = {}

    for techIndex,record in ipairs(techData) do
        local techDataId = record[kTechDataId]

        if techToRemove[techDataId] then
            table.insert(indexToRemove, techIndex)
        elseif techToChange[techDataId] then
            for index, value in pairs(techToChange[techDataId]) do
                if value == removeTechDataValue then
                    techData[techIndex][index] = nil
                else
                    techData[techIndex][index] = value
                end
            end
        end
    end

    -- Remove tech
    local offset = 0
    for _,idx in ipairs(indexToRemove) do
        table.remove(techData, idx - offset)
        offset = offset + 1
    end

    -- Add new tech
    local techToAdd = GetTechToAdd()
    for _,v in ipairs(techToAdd) do
        table.insert(techData, v)
    end
end

local oldBuildTechData = BuildTechData
function BuildTechData()
    local techData = oldBuildTechData()
    TechDataChanges(techData)
    return techData
end
