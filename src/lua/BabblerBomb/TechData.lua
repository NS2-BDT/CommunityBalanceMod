

local oldBuildTechData = BuildTechData
function BuildTechData()
    
    local techData = oldBuildTechData()
			
	table.insert(techData, {
			[kTechDataId] = kTechId.BabblerBombAbility, 
			[kTechDataCategory] = kTechId.Gorge,
			[kTechDataMapName] = BabblerBombAbility.kMapName,
			[kTechDataDamageType] = kBileBombDamageType, 
			[kTechDataDisplayName] = "Babbler Bomb",
			[kTechDataCostKey] = kBabblerBombResearchCost,
			[kTechDataResearchTimeKey] = kBabblerBombResearchTime,
			[kTechDataTooltipInfo] = "Throw a bomb which on hitting a wall or player explodes and releases babblers for a short period." })
			
	table.insert(techData,         {
            [kTechDataId] = kTechId.Bombler,
            [kTechDataMapName] = Bombler.kMapName,
            [kTechDataDisplayName] = "BOMBLER",
            [kTechDataModel] = Bombler.kModelName,
            [kTechDataMaxHealth] = kBabblerHealth,
            [kTechDataMaxArmor] = kBabblerArmor,
            [kTechDataDamageType] = kBabblerDamageType,
            [kTechDataPointValue] = kBabblerPointValue,
            [kTechDataTooltipInfo] = "BABBLER_TOOLTIP",
        })
	
    return techData

end

local oldBuildTechData = BuildTechData
function BuildTechData()
    local techData = oldBuildTechData()
    return techData
end
