
local oldBuildTechData = BuildTechData
function BuildTechData()
    
    local techData = oldBuildTechData()    
    table.insert(techData, { 
		[kTechDataId] = kTechId.ShadeHallucination,
		[kTechDataMapName] = ShadeHallucination.kMapName,
        [kTechDataCooldown] = kShadeHallucinationCooldown,
		[kTechDataDisplayName] = "HALLUCINATION",  
		[kTechDataTooltipInfo] = "FORTRESS_SHADE_ABILITY_TOOLTIP",
        [kTechDataHotkey] = Move.D,
		[kTechDataCostKey] = kShadeHallucinationCost,
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
    
    return techData

end
