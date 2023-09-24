kTechDataSwitchUpgradeCost = "switchupgradecost"

local removeTechDataValue = "BalanceModRemoveTechData"

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
            [kTechDataTooltipInfo] = "EXOSUIT_TECH_TOOLTIP", -- "Allows Exosuits to be purchased"   text for description
            [kTechDataResearchName] = "RESEARCH_EXOSUITS_TITLE" -- "Exosuits"               text for left side
        },

        {
            [kTechDataId] = kTechId.FortressCrag,
            [kTechDataBioMass] = kCragBiomass,
            [kTechDataSupply] = kCragSupply,
            [kTechDataGhostModelClass] = "AlienGhostModel", 
            [kTechDataMapName] = FortressCrag.kMapName, 
            [kTechDataDisplayName] = "FORTRESS_CRAG", 
            [kTechDataRequiresInfestation] = true, 
            [kTechDataModel] = Crag.kModelName, 
            [kTechDataMaxHealth] = kFortressCragHealth,
            [kTechDataMaxArmor] = kFortressCragArmor,
            [kTechDataInitialEnergy] = kCragInitialEnergy,
            [kTechDataMaxEnergy] = kCragMaxEnergy, 
            [kTechDataPointValue] = kCragPointValue * 2,
            [kVisualRange] = Crag.kHealRadius, 
            [kTechDataTooltipInfo] = "FORTRESS_CRAG_TOOLTIP", 
            [kTechDataGrows] = false, 
            [kTechDataObstacleRadius] = 1.15, 
        },
        {
            
            
            [kTechDataId] = kTechId.UpgradeToFortressCrag,
            [kTechDataCostKey] = kFortressUpgradeCost,
            [kTechIDShowEnables] = false,
            [kTechDataResearchTimeKey] = kFortressResearchTime,
            [kTechDataDisplayName] = "FORTRESS_CRAG_UPGRADE",
            [kTechDataTooltipInfo] = "FORTRESS_CRAG_UPGRADE_TOOLTIP",
            [kTechDataResearchName] = "FORTRESS_CRAG_UPGRADE_RESEARCHNAME",
            [kTechDataOneAtATime] = true,
        },

        {
            [kTechDataId] = kTechId.FortressCragAbility,
            [kTechDataCooldown] = kFortressAbilityCooldown, 
            [kTechDataDisplayName] = "FORTRESS_CRAG_ABILITY", 
            [kTechDataCostKey] = kFortressAbilityCost,
            [kTechDataTooltipInfo] = "FORTRESS_CRAG_ABILITY_TOOLTIP", 
            [kTechDataOneAtATime] = true,  
        },

        {
            [kTechDataId] = kTechId.FortressShift,
            [kTechDataBioMass] = kShiftBiomass,
            [kTechDataSupply] = kShiftSupply,
            [kTechDataGhostModelClass] = "ShiftGhostModel", 
            [kTechDataMapName] = FortressShift.kMapName, 
            [kTechDataDisplayName] = "FORTRESS_SHIFT", 
            [kTechDataRequiresInfestation] = true, 
            [kTechDataModel] = Shift.kModelName, 
            [kTechDataMaxHealth] = kFortressShiftHealth,
            [kTechDataMaxArmor] = kFortressShiftArmor, 
            [kTechDataInitialEnergy] = kShiftInitialEnergy, 
            [kTechDataMaxEnergy] = kShiftMaxEnergy, 
            [kTechDataPointValue] = kShiftPointValue * 2,
            [kVisualRange] =  {
                kEchoRange,
                kEnergizeRange
            },
            [kTechDataTooltipInfo] = "FORTRESS_SHIFT_TOOLTIP", 
            [kTechDataGrows] = false, 
            [kTechDataObstacleRadius] = 1.3,
        },
        {
            
            
            [kTechDataId] = kTechId.UpgradeToFortressShift,
            [kTechDataCostKey] = kFortressUpgradeCost,
            [kTechIDShowEnables] = false,
            [kTechDataResearchTimeKey] = kFortressResearchTime,
            [kTechDataDisplayName] = "FORTRESS_SHIFT_UPGRADE",
            [kTechDataTooltipInfo] = "FORTRESS_SHIFT_UPGRADE_TOOLTIP",
            [kTechDataResearchName] = "FORTRESS_SHIFT_UPGRADE_RESEARCHNAME",
            [kTechDataOneAtATime] = true,
        },

        {
            [kTechDataId] = kTechId.FortressShiftAbility,
            [kTechDataCooldown] = kFortressAbilityCooldown, 
            [kTechDataDisplayName] = "FORTRESS_SHIFT_ABILITY", 
            [kTechDataCostKey] = kFortressAbilityCost,
            [kTechDataTooltipInfo] = "FORTRESS_SHIFT_ABILITY_TOOLTIP", 
            [kTechDataOneAtATime] = true,  
        },

            
        {
            [kTechDataId] = kTechId.FortressShade,
            [kTechDataBioMass] = kShadeBiomass,
            [kTechDataSupply] = kShadeSupply,
            [kTechDataGhostModelClass] = "AlienGhostModel",
            [kTechDataMapName] = FortressShade.kMapName, 
            [kTechDataDisplayName] = "FORTRESS_SHADE", 
            [kTechDataRequiresInfestation] = true, 
            [kTechDataModel] = Shade.kModelName, 
            [kTechDataMaxHealth] = kFortressShadeHealth,
            [kTechDataMaxArmor] = kFortressShadeArmor, 
            [kTechDataInitialEnergy] = kShadeInitialEnergy, 
            [kTechDataMaxEnergy] = kShadeMaxEnergy, 
            [kTechDataPointValue] = kShadePointValue * 2,
            [kVisualRange] =  Shade.kCloakRadius,
            [kTechDataTooltipInfo] = "FORTRESS_SHADE_TOOLTIP", 
            [kTechDataGrows] = false, 
            [kTechDataObstacleRadius] = 1.25,
            [kTechDataMaxExtents] = Vector(1, 1.3, .4),
        },
        {
            
            
            [kTechDataId] = kTechId.UpgradeToFortressShade,
            [kTechDataCostKey] = kFortressUpgradeCost,
            [kTechIDShowEnables] = false,
            [kTechDataResearchTimeKey] = kFortressResearchTime,
            [kTechDataDisplayName] = "FORTRESS_SHADE_UPGRADE",
            [kTechDataTooltipInfo] = "FORTRESS_SHADE_UPGRADE_TOOLTIP",
            [kTechDataResearchName] = "FORTRESS_SHADE_UPGRADE_RESEARCHNAME",
            [kTechDataOneAtATime] = true, 
        },

        {
            [kTechDataId] = kTechId.ShadeHallucination,
            [kTechDataCooldown] = kFortressAbilityCooldown, 
            [kTechDataDisplayName] = "FORTRESS_SHADE_ABILITY", 
            [kTechDataCostKey] = kFortressAbilityCost,
            [kTechDataTooltipInfo] = "FORTRESS_SHADE_ABILITY_TOOLTIP", 
            [kTechDataOneAtATime] = true,  
        },
            
        {
            [kTechDataId] = kTechId.FortressWhip,
            [kTechDataBioMass] = kWhipBiomass,
            [kTechDataSupply] = kWhipSupply,
            [kTechDataGhostModelClass] = "AlienGhostModel",
            [kTechDataMapName] = FortressWhip.kMapName,  
            [kTechDataDisplayName] = "FORTRESS_WHIP", 
            [kTechDataRequiresInfestation] = true, 
            [kTechDataModel] = Whip.kModelName, 
            [kTechDataMaxHealth] = kFortressWhipHealth,
            [kTechDataMaxArmor] = kFortressWhipArmor, 
            [kTechDataInitialEnergy] = kWhipInitialEnergy,  
            [kTechDataDamageType] = kDamageType.Structural,
            [kTechDataMaxEnergy] = kWhipMaxEnergy, 
            [kTechDataPointValue] = kWhipPointValue * 2,
            [kVisualRange] = Whip.kRange,
            [kTechDataTooltipInfo] = "FORTRESS_WHIP_TOOLTIP", 
            [kTechDataGrows] = false, 
            [kTechDataObstacleRadius] = 0.85,
       
        },
        {
            
            
            [kTechDataId] = kTechId.UpgradeToFortressWhip,
            [kTechDataCostKey] = kFortressUpgradeCost,
            [kTechIDShowEnables] = false,
            [kTechDataResearchTimeKey] = kFortressResearchTime,
            [kTechDataDisplayName] = "FORTRESS_WHIP_UPGRADE",
            [kTechDataTooltipInfo] = "FORTRESS_WHIP_UPGRADE_TOOLTIP",
            [kTechDataResearchName] = "FORTRESS_WHIP_UPGRADE_RESEARCHNAME",
            [kTechDataOneAtATime] = true, 
        },

        {
            [kTechDataId] = kTechId.FortressWhipAbility,
            [kTechDataCooldown] = kFortressAbilityCooldown, 
            [kTechDataDisplayName] = "FORTRESS_WHIP_ABILITY", 
            [kTechDataCostKey] = kFortressAbilityCost,
            [kTechDataTooltipInfo] = "FORTRESS_WHIP_ABILITY_TOOLTIP", 
            [kTechDataOneAtATime] = true,  
        },

        {
            [kTechDataId] = kTechId.WhipAbility,
            [kTechDataCooldown] = kWhipAbilityCooldown, 
            [kTechDataDisplayName] = "WHIP_ABILITY", 
            [kTechDataCostKey] = kWhipAbilityCost,
            [kTechDataTooltipInfo] = "WHIP_ABILITY_TOOLTIP", 
            [kTechDataOneAtATime] = true,  
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
        -- this will overwrite the russian translation too
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
