-- ========= Community Balance Mod ===============================
--
--  "lua\AdvancedOptions.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


local kMainVM = decoda_name == "Main"

AdvancedOptions["statusicon"] =
{
	label = Locale.ResolveString("STATUS ICONS"),
	tooltip = Locale.ResolveString("Show all status icons despite low hud details"),
	category = "HUD",

	optionPath = "CHUD_StatusIcons",
	optionType = "bool",
	default = true,
	guiType = "checkbox",

	immediateUpdate = function()

		if not kMainVM and StatusIconDisplay_SetStatusIconEnabled then

			StatusIconDisplay_SetStatusIconEnabled(GetAdvancedOption("statusicon"))

		end

	end,

	hideValues = { false },
}
