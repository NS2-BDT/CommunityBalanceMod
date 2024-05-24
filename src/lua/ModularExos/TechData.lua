local oldBuildTechData = BuildTechData
function BuildTechData()
    
    local techData = oldBuildTechData()
    
    --table.insert(techData, {[kTechDataId] = kTechId.ExoWelder })
    
    --table.insert(techData, {[kTechDataId] = kTechId.ExoFlamer })
    
    table.insert(techData, {[kTechDataId] = kTechId.ExoShield })
    
    --table.insert(techData, { [kTechDataId]                 = kTechId.WeaponCache,
    --                         [kTechDataHint]               = "WEAPON_CACHE_HINT",
    --                         [kTechDataGhostModelClass]    = "MarineGhostModel",
    --                         [kTechDataRequiresPower]      = true,
    --                         [kTechDataMapName]            = WeaponCache.kMapName,
    --                         [kTechDataDisplayName]        = "WEAPON_CACHE",
    --                         [kTechDataCostKey]            = kArmoryCost,
    --                         [kTechDataBuildTime]          = kArmoryBuildTime,
    --                         [kTechDataMaxHealth]          = kWeaponCacheHealth,
    --                         [kTechDataMaxArmor]           = kWeaponCacheArmor,
    --                         [kTechDataEngagementDistance] = kArmoryEngagementDistance,
    --                         [kTechDataModel]              = WeaponCache.kModelName,
    --                         [kTechDataPointValue]         = kWeaponCachePointValue,
    --                         [kTechDataInitialEnergy]      = kArmoryInitialEnergy,
    --                         [kTechDataMaxEnergy]          = kArmoryMaxEnergy,
    --                         [kTechDataNotOnInfestation]   = true,
    --                         [kTechDataTooltipInfo]        = "ARMORY_TOOLTIP",
    --                         [kTechDataAllowConsumeDrop]   = true,
    --                         [kTechDataMaxAmount]          = kNumArmoriesPerPlayer })
    --
    --table.insert(techData, { [kTechDataId]          = kTechId.MarineStructureAbility,
    --                         [kTechDataTooltipInfo] = "MARINE_BUILD_TOOLTIP",
    --                         [kTechDataPointValue]  = kWeaponPointValue,
    --                         [kTechDataMapName]     = MarineStructureAbility.kMapName,
    --                         [kTechDataDisplayName] = "MARINE_BUILD", })
    
    return techData

end
--[[

local function TechDataChanges(techData)

    for techIndex, record in ipairs(techData) do
--[[        local techDataId = record[kTechDataId]
		if techDataId == kTechId.Observatory then
            record[kTechDataSupply] = kObservatorySupply
        elseif techDataId == kTechId.SentryBattery then
            record[kTechDataSupply] = kSentryBatterySupply
		end]]--[[
    end

end

local oldBuildTechData = BuildTechData
function BuildTechData()
    local techData = oldBuildTechData()
    TechDataChanges(techData)
    return techData
end]]
