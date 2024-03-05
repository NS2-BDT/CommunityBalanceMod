--Top left is 0, 0

local GetTextureCoordinates = debug.getupvaluex(GUIPlayerStatus.Initialize, "GetTextureCoordinates")
local globalSettings = debug.getupvaluex(GUIPlayerStatus.Initialize, "globalSettings")
local CreateStatusIndicator = debug.getupvaluex(GUIPlayerStatus.Initialize, "CreateStatusIndicator")

GUIPlayerStatus.kHeatplatingTextureCoordinates = GetTextureCoordinates(1, 11)

local heatplatingSettings = {}
heatplatingSettings.Name = "Heatplated"
heatplatingSettings.Texture = GUIPlayerStatus.kStatusIconsTexture
heatplatingSettings.TextureCoordinates = GUIPlayerStatus.kHeatplatingTextureCoordinates
heatplatingSettings.BackgroundWidth = globalSettings.IconBackgroundWidth
heatplatingSettings.BackgroundHeight = globalSettings.IconBackgroundHeight
heatplatingSettings.BackgroundOffset = globalSettings.BackgroundOffset
heatplatingSettings.Simple = true
heatplatingSettings.EffectIconCoords = GUIPlayerStatus.kArrowUpCoords
heatplatingSettings.StatusBackgroundCoords = GUIPlayerStatus.kBackgroundGreen

local statusSettings = debug.getupvaluex(GUIPlayerStatus.Initialize, "statusSettings")
statusSettings["Heatplated"] = heatplatingSettings

-- Use new statusSettings
local StatusTimerLogic = debug.getupvaluex(GUIPlayerStatus.Update, "StatusTimerLogic")
local SimpleStatusLogic = debug.getupvaluex(GUIPlayerStatus.Update, "SimpleStatusLogic")

debug.setupvaluex(StatusTimerLogic, "statusSettings", statusSettings)
debug.setupvaluex(SimpleStatusLogic, "statusSettings", statusSettings)
debug.setupvaluex(GUIPlayerStatus.Initialize, "statusSettings", statusSettings)

debug.setupvaluex(GUIPlayerStatus.Update, "StatusTimerLogic", StatusTimerLogic)
debug.setupvaluex(GUIPlayerStatus.Update, "SimpleStatusLogic", SimpleStatusLogic)

-- Add new heatplatingSettings to self.statusIcons
local oldInit = GUIPlayerStatus.Initialize
function GUIPlayerStatus:Initialize()
    oldInit(self)

    if self.teamNum == kTeam2Index then
        table.insert(self.statusIcons, CreateStatusIndicator(self, heatplatingSettings))
    end
end

local oldUpdate = GUIPlayerStatus.Update
function GUIPlayerStatus:Update(deltaTime, parameters, fullMode)
    -- Hack in our new one :}
    if self.teamNum == kTeam2Index then
        parameters["Heatplated"] = PlayerUI_GetIsHeatplated()
    end

    oldUpdate(self, deltaTime, parameters, fullMode)

end
