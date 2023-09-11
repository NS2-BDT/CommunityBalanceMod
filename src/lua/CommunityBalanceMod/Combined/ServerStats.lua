
local OldStatsUI_AddTechStat = StatsUI_AddTechStat
function StatsUI_AddTechStat(teamNumber, techId, built, destroyed, recycled)

	if     techId ~= kTechId.UpgradeToAdvancedPrototypeLab
		and techId ~= kTechId.UpgradeToFortressCrag
		and techId ~= kTechId.UpgradeToFortressShift
		and techId ~= kTechId.UpgradeToFortressShade
		and techId ~= kTechId.UpgradeToFortressWhip
		then
		OldStatsUI_AddTechStat(teamNumber, techId, built, destroyed, recycled)
	end
end
