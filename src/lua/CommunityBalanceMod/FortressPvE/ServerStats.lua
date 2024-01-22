-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


local OldStatsUI_AddTechStat = StatsUI_AddTechStat
function StatsUI_AddTechStat(teamNumber, techId, built, destroyed, recycled)

	if      techId ~= kTechId.UpgradeToFortressCrag
		and techId ~= kTechId.UpgradeToFortressShift
		and techId ~= kTechId.UpgradeToFortressShade
		and techId ~= kTechId.UpgradeToFortressWhip
		and techId ~= kTechId.Crag
		and techId ~= kTechId.Shift
		and techId ~= kTechId.Shade
		and techId ~= kTechId.Whip
		and techId ~= kTechId.RoboticsFactory
		and techId ~= kTechId.Armory
		then
		OldStatsUI_AddTechStat(teamNumber, techId, built, destroyed, recycled)
	end
end


local OldStatsUI_AddBuildingStat = StatsUI_AddBuildingStat
function StatsUI_AddBuildingStat(teamNumber, techId, lost)

	if techId == kTechId.FortressCrag then
		techId = kTechId.Crag
	elseif techId == kTechId.FortressShift then
		techId = kTechId.Shift
	elseif techId == kTechId.FortressShade then
		techId = kTechId.Shade
	elseif techId == kTechId.FortressWhip then
		techId = kTechId.Whip
	end

	OldStatsUI_AddBuildingStat(teamNumber, techId, lost)
end



local techLogBuildings = set {
	"ArmsLab",
	"PrototypeLab",
	"Observatory",
	"InfantryPortal",
	"CommandStation",
	"Veil",
	"Shell",
	"Spur",
	"Hive",

	"Armory",
	"RoboticsFactory",
	"Whip",
	"Shade",
	"Shift",
	"Crag",

}

function StatsUI_GetBuildingLogged(structureName)
	return techLogBuildings[structureName]
end
