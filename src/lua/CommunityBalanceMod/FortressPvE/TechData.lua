
local oldBuildTechData = BuildTechData
function BuildTechData()
    
    local techData = oldBuildTechData()    

        table.insert(techData, { 
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
        })


        table.insert(techData, { 
            [kTechDataId] = kTechId.UpgradeToFortressCrag,
            [kTechDataCostKey] = kFortressUpgradeCost,
            [kTechIDShowEnables] = false,
            [kTechDataResearchTimeKey] = kFortressResearchTime,
            [kTechDataDisplayName] = "FORTRESS_CRAG_UPGRADE",
            [kTechDataTooltipInfo] = "FORTRESS_CRAG_UPGRADE_TOOLTIP",
            [kTechDataResearchName] = "FORTRESS_CRAG_UPGRADE_RESEARCHNAME",
            [kTechDataOneAtATime] = true,
        })


        table.insert(techData, { 
            [kTechDataId] = kTechId.FortressCragAbility,
            [kTechDataCooldown] = kFortressAbilityCooldown, 
            [kTechDataDisplayName] = "FORTRESS_CRAG_ABILITY", 
            [kTechDataCostKey] = kFortressAbilityCost,
            [kTechDataTooltipInfo] = "FORTRESS_CRAG_ABILITY_TOOLTIP", 
            [kTechDataOneAtATime] = true,  
        })


        table.insert(techData, { 
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
        })


        table.insert(techData, {  
            [kTechDataId] = kTechId.UpgradeToFortressShift,
            [kTechDataCostKey] = kFortressUpgradeCost,
            [kTechIDShowEnables] = false,
            [kTechDataResearchTimeKey] = kFortressResearchTime,
            [kTechDataDisplayName] = "FORTRESS_SHIFT_UPGRADE",
            [kTechDataTooltipInfo] = "FORTRESS_SHIFT_UPGRADE_TOOLTIP",
            [kTechDataResearchName] = "FORTRESS_SHIFT_UPGRADE_RESEARCHNAME",
            [kTechDataOneAtATime] = true,
        })


        table.insert(techData, { 
            [kTechDataId] = kTechId.FortressShiftAbility,
            [kTechDataCooldown] = kFortressAbilityCooldown, 
            [kTechDataDisplayName] = "FORTRESS_SHIFT_ABILITY", 
            [kTechDataCostKey] = kFortressAbilityCost,
            [kTechDataTooltipInfo] = "FORTRESS_SHIFT_ABILITY_TOOLTIP", 
            [kTechDataOneAtATime] = true,  
        })


        table.insert(techData, { 
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
        })


        table.insert(techData, { 
            [kTechDataId] = kTechId.UpgradeToFortressShade,
            [kTechDataCostKey] = kFortressUpgradeCost,
            [kTechIDShowEnables] = false,
            [kTechDataResearchTimeKey] = kFortressResearchTime,
            [kTechDataDisplayName] = "FORTRESS_SHADE_UPGRADE",
            [kTechDataTooltipInfo] = "FORTRESS_SHADE_UPGRADE_TOOLTIP",
            [kTechDataResearchName] = "FORTRESS_SHADE_UPGRADE_RESEARCHNAME",
            [kTechDataOneAtATime] = true, 
        })


       


        table.insert(techData, { 
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
        })


        table.insert(techData, { 
            [kTechDataId] = kTechId.UpgradeToFortressWhip,
            [kTechDataCostKey] = kFortressUpgradeCost,
            [kTechIDShowEnables] = false,
            [kTechDataResearchTimeKey] = kFortressResearchTime,
            [kTechDataDisplayName] = "FORTRESS_WHIP_UPGRADE",
            [kTechDataTooltipInfo] = "FORTRESS_WHIP_UPGRADE_TOOLTIP",
            [kTechDataResearchName] = "FORTRESS_WHIP_UPGRADE_RESEARCHNAME",
            [kTechDataOneAtATime] = true, 
        })


        table.insert(techData, { 
            [kTechDataId] = kTechId.FortressWhipAbility,
            [kTechDataCooldown] = kFortressAbilityCooldown, 
            [kTechDataDisplayName] = "FORTRESS_WHIP_ABILITY", 
            [kTechDataCostKey] = kFortressAbilityCost,
            [kTechDataTooltipInfo] = "FORTRESS_WHIP_ABILITY_TOOLTIP", 
            [kTechDataOneAtATime] = true,  
        })


        table.insert(techData, { 
            [kTechDataId] = kTechId.WhipAbility,
            [kTechDataCooldown] = kWhipAbilityCooldown, 
            [kTechDataDisplayName] = "WHIP_ABILITY", 
            [kTechDataCostKey] = kWhipAbilityCost,
            [kTechDataTooltipInfo] = "WHIP_ABILITY_TOOLTIP", 
            [kTechDataOneAtATime] = true,  
        })


        table.insert(techData, { 
            [kTechDataId] = kTechId.ShadeHallucination,
            [kTechDataMapName] = ShadeHallucination.kMapName,
            [kTechDataCooldown] = kFortressAbilityCooldown,
            [kTechDataDisplayName] = "FORTRESS_SHADE_ABILITY",  
            [kTechDataTooltipInfo] = "FORTRESS_SHADE_ABILITY_TOOLTIP",
            [kTechDataHotkey] = Move.D,
            [kTechDataCostKey] = kFortressAbilityCost,
            [kVisualRange] = ShadeHallucination.kRadius,
            [kTechDataGhostModelClass] = "AlienGhostModel",
            [kTechDataIgnorePathingMesh] = true,
            [kTechDataAllowStacking] = true,
            [kTechDataOneAtATime] = true,
            [kTechDataModel] = BoneWall.kModelName,
        })
    
        table.insert(techData, {
            [kTechDataId] = kTechId.HallucinateShell,
            [kTechDataRequiresMature] = false,
            [kTechDataRequiresInfestation] = true,
            [kTechDataDisplayName] = "HALLUCINATE_SHIFT",
            [kTechDataModel] = Shell.kModelName,
            [kTechDataTooltipInfo] = "HALLUCINATE_SHIFT_TOOLTIP",
            [kTechDataCostKey] = kHallucinateShiftEnergyCost,
        })
            
        table.insert(techData, {
            [kTechDataId] = kTechId.HallucinateSpur,
            [kTechDataRequiresMature] = false,
            [kTechDataRequiresInfestation] = true,
            [kTechDataDisplayName] = "HALLUCINATE_SHIFT",
            [kTechDataModel] = Spur.kModelName,
            [kTechDataTooltipInfo] = "HALLUCINATE_SHIFT_TOOLTIP",
            [kTechDataCostKey] = kHallucinateShiftEnergyCost,
        })
            
        table.insert(techData, {
            [kTechDataId] = kTechId.HallucinateVeil,
            [kTechDataRequiresMature] = false,
            [kTechDataRequiresInfestation] = true,
            [kTechDataDisplayName] = "HALLUCINATE_SHIFT",
            [kTechDataModel] = Veil.kModelName,
            [kTechDataTooltipInfo] = "HALLUCINATE_SHIFT_TOOLTIP",
            [kTechDataCostKey] = kHallucinateShiftEnergyCost,
        })
        
        table.insert(techData, {
            [kTechDataId] = kTechId.HallucinateEgg,
            [kTechDataRequiresMature] = false,
            [kTechDataRequiresInfestation] = true,
            [kTechDataDisplayName] = "HALLUCINATE_SHIFT",
            [kTechDataModel] = Egg.kModelName,
            [kTechDataTooltipInfo] = "HALLUCINATE_SHIFT_TOOLTIP",
            [kTechDataCostKey] = kHallucinateShiftEnergyCost,
        })

        table.insert(techData, {
            [kTechDataId] = kTechId.HallucinateCloning,
            [kTechDataDisplayName] = "HALLUCINATE_CLONING",
            [kTechDataTooltipInfo] = "HALLUCINATE_CLONING_TOOLTIP",
            [kTechDataCostKey] = kHallucinateCloningCost,
            [kTechDataCooldown] = kHallucinateCloningCooldown,
            [kTechDataOrderSound] = AlienCommander.kBuildStructureSound,
        })
    
    return techData
end

