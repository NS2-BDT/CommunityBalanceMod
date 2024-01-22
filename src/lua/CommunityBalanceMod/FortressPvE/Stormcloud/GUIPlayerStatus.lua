 -- ========= Community Balance Mod ===============================
--
--  "lua\Hud\GUIPlayerStatus.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================

 --Top left is 0, 0


local GetTextureCoordinates = debug.getupvaluex(GUIPlayerStatus.Initialize, "GetTextureCoordinates")
local globalSettings = debug.getupvaluex(GUIPlayerStatus.Initialize, "globalSettings")
local CreateStatusIndicator = debug.getupvaluex(GUIPlayerStatus.Initialize, "CreateStatusIndicator")


GUIPlayerStatus.kStormTextureCoordinates = GetTextureCoordinates(0, 10)
            
local stormedSettings = {}
stormedSettings.Name = "Stormed"
stormedSettings.Texture = GUIPlayerStatus.kStatusIconsTexture
stormedSettings.TextureCoordinates = GUIPlayerStatus.kStormTextureCoordinates
stormedSettings.BackgroundWidth = globalSettings.IconBackgroundWidth
stormedSettings.BackgroundHeight = globalSettings.IconBackgroundHeight
stormedSettings.BackgroundOffset = globalSettings.BackgroundOffset
stormedSettings.Simple = true
stormedSettings.EffectIconCoords = GUIPlayerStatus.kArrowUpCoords
stormedSettings.StatusBackgroundCoords = GUIPlayerStatus.kBackgroundGreen

local statusSettings = debug.getupvaluex(GUIPlayerStatus.Initialize, "statusSettings")
statusSettings["Stormed"] = stormedSettings

-- Use new statusSettings
local StatusTimerLogic = debug.getupvaluex(GUIPlayerStatus.Update, "StatusTimerLogic")
local SimpleStatusLogic = debug.getupvaluex(GUIPlayerStatus.Update, "SimpleStatusLogic")

debug.setupvaluex(StatusTimerLogic, "statusSettings", statusSettings)
debug.setupvaluex(SimpleStatusLogic, "statusSettings", statusSettings)
debug.setupvaluex(GUIPlayerStatus.Initialize, "statusSettings", statusSettings)

debug.setupvaluex(GUIPlayerStatus.Update, "StatusTimerLogic", StatusTimerLogic)
debug.setupvaluex(GUIPlayerStatus.Update, "SimpleStatusLogic", SimpleStatusLogic)

-- Add new stormedSettings to self.statusIcons
local oldInit = GUIPlayerStatus.Initialize
function GUIPlayerStatus:Initialize()
    oldInit(self)

    if self.teamNum == kTeam2Index then
        table.insert(self.statusIcons, CreateStatusIndicator(self, stormedSettings))
    end
end