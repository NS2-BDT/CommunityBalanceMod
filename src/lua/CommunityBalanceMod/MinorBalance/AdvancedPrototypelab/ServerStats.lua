-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


local OldStatsUI_AddTechStat = StatsUI_AddTechStat
function StatsUI_AddTechStat(teamNumber, techId, built, destroyed, recycled)

	if  techId ~= kTechId.UpgradeToAdvancedPrototypeLab then
		OldStatsUI_AddTechStat(teamNumber, techId, built, destroyed, recycled)
	end
end
