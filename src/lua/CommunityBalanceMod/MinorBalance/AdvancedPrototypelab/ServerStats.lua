
local OldStatsUI_AddTechStat = StatsUI_AddTechStat
function StatsUI_AddTechStat(teamNumber, techId, built, destroyed, recycled)

	if  techId ~= kTechId.UpgradeToAdvancedPrototypeLab then
		OldStatsUI_AddTechStat(teamNumber, techId, built, destroyed, recycled)
	end
end
