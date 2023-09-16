            -- ======= Copyright (c) 2003-2018, Unknown Worlds Entertainment, Inc. All rights reserved. =======
            --
            -- lua\GUIPlayerStatus.lua
            --
            -- Created by: Brian Arneson (samusdroid@gmail.com)
            --
            -- Manages the health and armor display for the marine hud.
            --
            -- ========= For more information, visit us at http://www.unknownworlds.com =====================

            Script.Load("lua/Hud/Marine/GUIMarineHUDElement.lua")
            Script.Load("lua/Hud/Marine/GUIMarineHUDStyle.lua")

            class 'GUIPlayerStatus' (GUIMarineHUDElement)

            function CreatePlayerStatusDisplay(scriptHandle, hudLayer, frame, teamNum)

                local marineStatus = GUIPlayerStatus()
                marineStatus.script = scriptHandle
                marineStatus.hudLayer = hudLayer
                marineStatus.frame = frame
                marineStatus.teamNum = teamNum
                marineStatus:Initialize()
                
                return marineStatus
                
            end

            --The background size
            GUIPlayerStatus.kIconSize = 64
            --The status icon itself
            GUIPlayerStatus.kStatusIconSize = 54
            --The +/- arrow icons
            GUIPlayerStatus.kEffectIconSize = 25

            local hintsEnabled = false

            local STATUS_OFF = 1
            local STATUS_ON = 2
            local ON_INFESTATION = 3

            --Top left is 0, 0
            local function GetTextureCoordinates(indexX, indexY)
                return {GUIPlayerStatus.kIconSize * indexX, GUIPlayerStatus.kIconSize * indexY, GUIPlayerStatus.kIconSize + (GUIPlayerStatus.kIconSize * indexX), GUIPlayerStatus.kIconSize + (GUIPlayerStatus.kIconSize * indexY)}
            end

            GUIPlayerStatus.kStatusIconsTexture = PrecacheAsset("ui/player_status_icons.dds")
            GUIPlayerStatus.kIconSizeVector = Vector(GUIPlayerStatus.kIconSize, GUIPlayerStatus.kIconSize, 0)
            GUIPlayerStatus.kStatusIconSizeVector = Vector(GUIPlayerStatus.kStatusIconSize, GUIPlayerStatus.kStatusIconSize, 0)
            GUIPlayerStatus.kEffectIconSizeVector = Vector(GUIPlayerStatus.kEffectIconSize, GUIPlayerStatus.kEffectIconSize, 0)

            GUIPlayerStatus.kStatusIconPosition = Vector(75, 0, 0)

            GUIPlayerStatus.kIconColor = {}
            GUIPlayerStatus.kIconColor[STATUS_OFF] = Color(0,0,0,0)
            GUIPlayerStatus.kIconColor[STATUS_ON] = Color(1, 1, 1, 1)
            GUIPlayerStatus.kIconColor[ON_INFESTATION] = Color(0.7, 0.4, 0.4, 0.8)

            GUIPlayerStatus.kBackgroundTexture = PrecacheAsset("ui/objective_banner_marine.dds")
            GUIPlayerStatus.kTimerIconTexture = PrecacheAsset("ui/alien_hud_health_old.dds")

            GUIPlayerStatus.kTextXOffset = 95

            GUIPlayerStatus.kBackgroundCoords = { 0, 0, 1024, 64 }
            GUIPlayerStatus.kBackgroundPos = Vector(45, -260, 0)
            GUIPlayerStatus.kBackgroundSize = Vector(GUIPlayerStatus.kBackgroundCoords[3], GUIPlayerStatus.kBackgroundCoords[4], 0)
            GUIPlayerStatus.kStencilCoords = { 0, 140, 300, 140 + 121 }

            GUIPlayerStatus.kFontName = Fonts.kAgencyFB_Large_Bold

            GUIPlayerStatus.kAnimSpeedDown = 0.2
            GUIPlayerStatus.kAnimSpeedUp = 0.5

            GUIPlayerStatus.kIconPadding = 15

            GUIPlayerStatus.kTimerSize = 105
            GUIPlayerStatus.kTimerPosition = Vector( -GUIPlayerStatus.kTimerSize * 0.505, GUIPlayerStatus.kTimerSize * 0.505, 0)

            GUIPlayerStatus.kParasiteTextureCoords = GetTextureCoordinates(1, 4)
            GUIPlayerStatus.kNanoshieldTextureCoordinates = GetTextureCoordinates(0, 8)
            GUIPlayerStatus.kCatPackTextureCoordinates = GetTextureCoordinates(0, 9)
            GUIPlayerStatus.kMucousTextureCoordinates = GetTextureCoordinates(0, 1)
            GUIPlayerStatus.kFireTextureCoordinates = GetTextureCoordinates(0, 2)
            GUIPlayerStatus.kEnzymeTextureCoordinates = GetTextureCoordinates(0, 4)
GUIPlayerStatus.kStormTextureCoordinates = GetTextureCoordinates(0, 10)

            GUIPlayerStatus.kDetectedTextureCoords = GetTextureCoordinates(0, 5)
            GUIPlayerStatus.kCloakedTextureCoords = GetTextureCoordinates(0, 6)
            GUIPlayerStatus.kCorrodedTextureCoords = GetTextureCoordinates(0, 7)
            GUIPlayerStatus.kElectrifiedTextureCoords = GetTextureCoordinates(0, 3)
            GUIPlayerStatus.kUmbraTextureCoords = GetTextureCoordinates(0, 11)
            GUIPlayerStatus.kEnergizeTextureCoords = GetTextureCoordinates(1, 10)
            GUIPlayerStatus.kCragRangeTextureCoords = GetTextureCoordinates(0, 0)
            GUIPlayerStatus.kNerveGasTextureCoords = GetTextureCoordinates(1, 2)
            GUIPlayerStatus.kSporeCloudTextureCoords = GetTextureCoordinates(1, 1)
            GUIPlayerStatus.kBeingWeldedTextureCoords = GetTextureCoordinates(1, 0)

            GUIPlayerStatus.kPlusCoords = {64, 320, 96, 352}
            GUIPlayerStatus.kMinusCoords = {96, 320, 128, 352}
            GUIPlayerStatus.kArrowUpCoords = {96, 352, 128, 384}
            GUIPlayerStatus.kArrowDownCoords = {64, 352, 96, 384}
            GUIPlayerStatus.kBackgroundGrey = GetTextureCoordinates(1, 7)
            GUIPlayerStatus.kBackgroundRed = GetTextureCoordinates(1, 8)
            GUIPlayerStatus.kBackgroundGreen = GetTextureCoordinates(1, 9)

            local globalSettings = {}
            globalSettings.BackgroundWidth = GUIScale( GUIPlayerStatus.kTimerSize )
            globalSettings.BackgroundHeight = GUIScale( GUIPlayerStatus.kTimerSize )
            globalSettings.IconBackgroundWidth = GUIScale( GUIPlayerStatus.kIconSize )
            globalSettings.IconBackgroundHeight = GUIScale( GUIPlayerStatus.kIconSize )
            globalSettings.BackgroundOffset = GUIScale( GUIPlayerStatus.kTimerPosition )

            local parasiteTimerSettings = {}
            parasiteTimerSettings.Name = "Parasite"
            parasiteTimerSettings.BackgroundWidth = globalSettings.BackgroundWidth
            parasiteTimerSettings.BackgroundHeight = globalSettings.BackgroundHeight
            parasiteTimerSettings.BackgroundAnchorX = GUIItem.Middle
            parasiteTimerSettings.BackgroundAnchorY = GUIItem.Center
            parasiteTimerSettings.BackgroundOffset = globalSettings.BackgroundOffset
            parasiteTimerSettings.BackgroundTextureName = nil
            parasiteTimerSettings.ForegroundTextureName = GUIPlayerStatus.kTimerIconTexture
            parasiteTimerSettings.ForegroundTextureWidth = 128
            parasiteTimerSettings.ForegroundTextureHeight = 128
            parasiteTimerSettings.ForegroundTextureX1 = 0
            parasiteTimerSettings.ForegroundTextureY1 = 128
            parasiteTimerSettings.ForegroundTextureX2 = 128
            parasiteTimerSettings.ForegroundTextureY2 = 256
            parasiteTimerSettings.InheritParentAlpha = false
            parasiteTimerSettings.TextureCoordinates = GUIPlayerStatus.kParasiteTextureCoords
            parasiteTimerSettings.Texture = GUIPlayerStatus.kStatusIconsTexture
            parasiteTimerSettings.Color = GUIPlayerStatus.kIconColor[STATUS_OFF]
            parasiteTimerSettings.ParameterNumbers = {"ParasiteState", "ParasiteTime"}
            parasiteTimerSettings.EffectIconCoords = GUIPlayerStatus.kArrowDownCoords
            parasiteTimerSettings.StatusBackgroundCoords = GUIPlayerStatus.kBackgroundRed
            parasiteTimerSettings.DefaultValue = 1
            parasiteTimerSettings.ShowWithLowHUDDetails = true

            local catpackSettings = {}
            catpackSettings.Name = "CatPack"
            catpackSettings.BackgroundWidth = globalSettings.BackgroundWidth
            catpackSettings.BackgroundHeight = globalSettings.BackgroundHeight
            catpackSettings.BackgroundAnchorX = GUIItem.Middle
            catpackSettings.BackgroundAnchorY = GUIItem.Center
            catpackSettings.BackgroundOffset = globalSettings.BackgroundOffset
            catpackSettings.BackgroundTextureName = nil
            catpackSettings.ForegroundTextureName = GUIPlayerStatus.kTimerIconTexture
            catpackSettings.ForegroundTextureWidth = 128
            catpackSettings.ForegroundTextureHeight = 128
            catpackSettings.ForegroundTextureX1 = 0
            catpackSettings.ForegroundTextureY1 = 128
            catpackSettings.ForegroundTextureX2 = 128
            catpackSettings.ForegroundTextureY2 = 256
            catpackSettings.InheritParentAlpha = false
            catpackSettings.TextureCoordinates = GUIPlayerStatus.kCatPackTextureCoordinates
            catpackSettings.Texture = GUIPlayerStatus.kStatusIconsTexture
            catpackSettings.Color = GUIPlayerStatus.kIconColor[STATUS_OFF]
            catpackSettings.ParameterNumbers = {"CatPackState", "CatPackTime"}
            catpackSettings.EffectIconCoords = GUIPlayerStatus.kArrowUpCoords
            catpackSettings.StatusBackgroundCoords = GUIPlayerStatus.kBackgroundGreen
            catpackSettings.DefaultValue = 1

            local nanoshieldSettings = {}
            nanoshieldSettings.Name = "Nanoshield"
            nanoshieldSettings.BackgroundWidth = globalSettings.BackgroundWidth
            nanoshieldSettings.BackgroundHeight = globalSettings.BackgroundHeight
            nanoshieldSettings.BackgroundAnchorX = GUIItem.Middle
            nanoshieldSettings.BackgroundAnchorY = GUIItem.Center
            nanoshieldSettings.BackgroundOffset = globalSettings.BackgroundOffset
            nanoshieldSettings.BackgroundTextureName = nil
            nanoshieldSettings.ForegroundTextureName = GUIPlayerStatus.kTimerIconTexture
            nanoshieldSettings.ForegroundTextureWidth = 128
            nanoshieldSettings.ForegroundTextureHeight = 128
            nanoshieldSettings.ForegroundTextureX1 = 0
            nanoshieldSettings.ForegroundTextureY1 = 128
            nanoshieldSettings.ForegroundTextureX2 = 128
            nanoshieldSettings.ForegroundTextureY2 = 256
            nanoshieldSettings.InheritParentAlpha = false
            nanoshieldSettings.TextureCoordinates = GUIPlayerStatus.kNanoshieldTextureCoordinates
            nanoshieldSettings.Texture = GUIPlayerStatus.kStatusIconsTexture
            nanoshieldSettings.Color = GUIPlayerStatus.kIconColor[STATUS_OFF]
            nanoshieldSettings.ParameterNumbers = {"NanoShieldState" , "NanoShieldTime"}
            nanoshieldSettings.EffectIconCoords = GUIPlayerStatus.kArrowUpCoords
            nanoshieldSettings.StatusBackgroundCoords = GUIPlayerStatus.kBackgroundGreen
            nanoshieldSettings.DefaultValue = 1

            local mucousedSettings = {}
            mucousedSettings.Name = "Mucoused"
            mucousedSettings.BackgroundWidth = globalSettings.BackgroundWidth
            mucousedSettings.BackgroundHeight = globalSettings.BackgroundHeight
            mucousedSettings.BackgroundAnchorX = GUIItem.Middle
            mucousedSettings.BackgroundAnchorY = GUIItem.Center
            mucousedSettings.BackgroundOffset = globalSettings.BackgroundOffset
            mucousedSettings.BackgroundTextureName = nil
            mucousedSettings.ForegroundTextureName = GUIPlayerStatus.kTimerIconTexture
            mucousedSettings.ForegroundTextureWidth = 128
            mucousedSettings.ForegroundTextureHeight = 128
            mucousedSettings.ForegroundTextureX1 = 0
            mucousedSettings.ForegroundTextureY1 = 128
            mucousedSettings.ForegroundTextureX2 = 128
            mucousedSettings.ForegroundTextureY2 = 256
            mucousedSettings.InheritParentAlpha = false
            mucousedSettings.TextureCoordinates = GUIPlayerStatus.kMucousTextureCoordinates
            mucousedSettings.Texture = GUIPlayerStatus.kStatusIconsTexture
            mucousedSettings.Color = GUIPlayerStatus.kIconColor[STATUS_OFF]
            mucousedSettings.ParameterNumbers = {"MucousedState", "MucousedTime"}
            mucousedSettings.EffectIconCoords = GUIPlayerStatus.kArrowUpCoords
            mucousedSettings.DefaultValue = 1

            local detectedSettings = {}
            detectedSettings.Name = "Detected"
            detectedSettings.Texture = GUIPlayerStatus.kStatusIconsTexture
            detectedSettings.TextureCoordinates = GUIPlayerStatus.kDetectedTextureCoords
            detectedSettings.BackgroundWidth = globalSettings.IconBackgroundWidth
            detectedSettings.BackgroundHeight = globalSettings.IconBackgroundHeight
            detectedSettings.BackgroundOffset = globalSettings.BackgroundOffset
            detectedSettings.Simple = true
            detectedSettings.Color = Color(1, 0.15, 0.15, 0.85)
            detectedSettings.EffectIconCoords = GUIPlayerStatus.kArrowDownCoords
            detectedSettings.StatusBackgroundCoords = GUIPlayerStatus.kBackgroundRed
            detectedSettings.ShowWithLowHUDDetails = true

            local enzymedSettings = {}
            enzymedSettings.Name = "Enzymed"
            enzymedSettings.Texture = GUIPlayerStatus.kStatusIconsTexture
            enzymedSettings.TextureCoordinates = GUIPlayerStatus.kEnzymeTextureCoordinates
            enzymedSettings.BackgroundWidth = globalSettings.IconBackgroundWidth
            enzymedSettings.BackgroundHeight = globalSettings.IconBackgroundHeight
            enzymedSettings.BackgroundOffset = globalSettings.BackgroundOffset
            enzymedSettings.Simple = true
            enzymedSettings.EffectIconCoords = GUIPlayerStatus.kArrowUpCoords
            enzymedSettings.StatusBackgroundCoords = GUIPlayerStatus.kBackgroundGreen


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

            local corrodedSettings = {}
            corrodedSettings.Name = "Corroded"
            corrodedSettings.Texture = GUIPlayerStatus.kStatusIconsTexture
            corrodedSettings.TextureCoordinates = GUIPlayerStatus.kCorrodedTextureCoords
            corrodedSettings.BackgroundWidth = globalSettings.IconBackgroundWidth
            corrodedSettings.BackgroundHeight = globalSettings.IconBackgroundHeight
            corrodedSettings.BackgroundOffset = globalSettings.BackgroundOffset
            corrodedSettings.Simple = true
            corrodedSettings.EffectIconCoords = GUIPlayerStatus.kArrowDownCoords
            corrodedSettings.StatusBackgroundCoords = GUIPlayerStatus.kBackgroundRed

            local cloakedSettings = {}
            cloakedSettings.Name = "Cloaked"
            cloakedSettings.Texture = GUIPlayerStatus.kStatusIconsTexture
            cloakedSettings.TextureCoordinates = GUIPlayerStatus.kCloakedTextureCoords
            cloakedSettings.BackgroundWidth = globalSettings.IconBackgroundWidth
            cloakedSettings.BackgroundHeight = globalSettings.IconBackgroundHeight
            cloakedSettings.BackgroundOffset = globalSettings.BackgroundOffset
            cloakedSettings.Simple = true
            cloakedSettings.EffectIconCoords = GUIPlayerStatus.kArrowUpCoords
            cloakedSettings.StatusBackgroundCoords = GUIPlayerStatus.kBackgroundGreen

            local onFireSettings = {}
            onFireSettings.Name = "OnFire"
            onFireSettings.Texture = GUIPlayerStatus.kStatusIconsTexture
            onFireSettings.TextureCoordinates = GUIPlayerStatus.kFireTextureCoordinates
            onFireSettings.BackgroundWidth = globalSettings.IconBackgroundWidth
            onFireSettings.BackgroundHeight = globalSettings.IconBackgroundHeight
            onFireSettings.BackgroundOffset = globalSettings.BackgroundOffset
            onFireSettings.Simple = true
            onFireSettings.EffectIconCoords = GUIPlayerStatus.kArrowDownCoords
            onFireSettings.StatusBackgroundCoords = GUIPlayerStatus.kBackgroundRed

            local electrifiedSettings = {}
            electrifiedSettings.Name = "Electrified"
            electrifiedSettings.Texture = GUIPlayerStatus.kStatusIconsTexture
            electrifiedSettings.TextureCoordinates = GUIPlayerStatus.kElectrifiedTextureCoords
            electrifiedSettings.BackgroundWidth = globalSettings.IconBackgroundWidth
            electrifiedSettings.BackgroundHeight = globalSettings.IconBackgroundHeight
            electrifiedSettings.BackgroundOffset = globalSettings.BackgroundOffset
            electrifiedSettings.Simple = true
            electrifiedSettings.EffectIconCoords = GUIPlayerStatus.kArrowDownCoords
            electrifiedSettings.StatusBackgroundCoords = GUIPlayerStatus.kBackgroundRed

            local wallWalkingSettings = {}
            wallWalkingSettings.Name = "WallWalking"
            wallWalkingSettings.Texture = GUIPlayerStatus.kStatusIconsTexture
            wallWalkingSettings.TextureCoordinates = GUIPlayerStatus.kParasiteTextureCoords
            wallWalkingSettings.BackgroundWidth = globalSettings.IconBackgroundWidth
            wallWalkingSettings.BackgroundHeight = globalSettings.IconBackgroundHeight
            wallWalkingSettings.BackgroundOffset = globalSettings.BackgroundOffset
            wallWalkingSettings.Simple = true
            wallWalkingSettings.NoSizeAnimations = true

            local umbraSettings = {}
            umbraSettings.Name = "Umbra"
            umbraSettings.Texture = GUIPlayerStatus.kStatusIconsTexture
            umbraSettings.TextureCoordinates = GUIPlayerStatus.kUmbraTextureCoords
            umbraSettings.BackgroundWidth = globalSettings.IconBackgroundWidth
            umbraSettings.BackgroundHeight = globalSettings.IconBackgroundHeight
            umbraSettings.BackgroundOffset = globalSettings.BackgroundOffset
            umbraSettings.Simple = true
            umbraSettings.EffectIconCoords = GUIPlayerStatus.kArrowUpCoords
            umbraSettings.StatusBackgroundCoords = GUIPlayerStatus.kBackgroundGreen

            local energizeSettings = {}
            energizeSettings.Name = "Energize"
            energizeSettings.Texture = GUIPlayerStatus.kStatusIconsTexture
            energizeSettings.TextureCoordinates = GUIPlayerStatus.kEnergizeTextureCoords
            energizeSettings.BackgroundWidth = globalSettings.IconBackgroundWidth
            energizeSettings.BackgroundHeight = globalSettings.IconBackgroundHeight
            energizeSettings.BackgroundOffset = globalSettings.BackgroundOffset
            energizeSettings.Simple = true
            energizeSettings.EffectIconCoords = GUIPlayerStatus.kArrowUpCoords
            energizeSettings.StatusBackgroundCoords = GUIPlayerStatus.kBackgroundGreen
            energizeSettings.ShowWithHintsOnly = true

            local cragRangeSettings = {}
            cragRangeSettings.Name = "CragRange"
            cragRangeSettings.Texture = GUIPlayerStatus.kStatusIconsTexture
            cragRangeSettings.TextureCoordinates = GUIPlayerStatus.kCragRangeTextureCoords
            cragRangeSettings.BackgroundWidth = globalSettings.IconBackgroundWidth
            cragRangeSettings.BackgroundHeight = globalSettings.IconBackgroundHeight
            cragRangeSettings.BackgroundOffset = globalSettings.BackgroundOffset
            cragRangeSettings.ParameterNumber = detectedSettings.Name
            cragRangeSettings.Simple = true
            cragRangeSettings.EffectIconCoords = GUIPlayerStatus.kArrowUpCoords
            cragRangeSettings.StatusBackgroundCoords = GUIPlayerStatus.kBackgroundGreen
            cragRangeSettings.ShowWithHintsOnly = true

            local nerveGasSettings = {}
            nerveGasSettings.Name = "NerveGas"
            nerveGasSettings.Texture = GUIPlayerStatus.kStatusIconsTexture
            nerveGasSettings.TextureCoordinates = GUIPlayerStatus.kNerveGasTextureCoords
            nerveGasSettings.BackgroundWidth = globalSettings.IconBackgroundWidth
            nerveGasSettings.BackgroundHeight = globalSettings.IconBackgroundHeight
            nerveGasSettings.BackgroundOffset = globalSettings.BackgroundOffset
            nerveGasSettings.Simple = true
            nerveGasSettings.EffectIconCoords = GUIPlayerStatus.kArrowDownCoords
            nerveGasSettings.StatusBackgroundCoords = GUIPlayerStatus.kBackgroundRed

            local sporeCloudSettings = {}
            sporeCloudSettings.Name = "SporeCloud"
            sporeCloudSettings.Texture = GUIPlayerStatus.kStatusIconsTexture
            sporeCloudSettings.TextureCoordinates = GUIPlayerStatus.kSporeCloudTextureCoords
            sporeCloudSettings.BackgroundWidth = globalSettings.IconBackgroundWidth
            sporeCloudSettings.BackgroundHeight = globalSettings.IconBackgroundHeight
            sporeCloudSettings.BackgroundOffset = globalSettings.BackgroundOffset
            sporeCloudSettings.Simple = true
            sporeCloudSettings.EffectIconCoords = GUIPlayerStatus.kArrowDownCoords
            sporeCloudSettings.StatusBackgroundCoords = GUIPlayerStatus.kBackgroundRed

            local beingWeldedSettings = {}
            beingWeldedSettings.Name = "BeingWelded"
            beingWeldedSettings.Texture = GUIPlayerStatus.kStatusIconsTexture
            beingWeldedSettings.TextureCoordinates = GUIPlayerStatus.kBeingWeldedTextureCoords
            beingWeldedSettings.BackgroundWidth = globalSettings.IconBackgroundWidth
            beingWeldedSettings.BackgroundHeight = globalSettings.IconBackgroundHeight
            beingWeldedSettings.BackgroundOffset = globalSettings.BackgroundOffset
            beingWeldedSettings.Simple = true
            beingWeldedSettings.EffectIconCoords = GUIPlayerStatus.kArrowUpCoords
            beingWeldedSettings.StatusBackgroundCoords = GUIPlayerStatus.kBackgroundGreen

            local statusSettings = {}
            statusSettings["Parasite"] = parasiteTimerSettings
            statusSettings["Nanoshield"] = nanoshieldSettings
            statusSettings["CatPack"] = catpackSettings
            statusSettings["Detected"] = detectedSettings
            statusSettings["Mucoused"] = mucousedSettings
            statusSettings["Enzymed"] = enzymedSettings
statusSettings["Stormed"] = stormedSettings  
            statusSettings["Corroded"] = corrodedSettings
            statusSettings["Cloaked"] = cloakedSettings
            statusSettings["OnFire"] = onFireSettings
            statusSettings["Electrified"] = electrifiedSettings
            statusSettings["WallWalking"] = wallWalkingSettings
            statusSettings["Umbra"] = umbraSettings
            statusSettings["Energize"] = energizeSettings
            statusSettings["CragRange"] = cragRangeSettings
            statusSettings["NerveGas"] = nerveGasSettings
            statusSettings["SporeCloud"] = sporeCloudSettings
            statusSettings["BeingWelded"] = beingWeldedSettings

            local function CreateStatusIndicator(self, settings)

                if not settings.Color then
                    settings.Color = Color(1, 1, 1, 1)
                end

                if not settings.StatusBackgroundCoords then
                    settings.StatusBackgroundCoords = GetTextureCoordinates(1, 7)
                end

                local statusStateBG = self.script:CreateAnimatedGraphicItem()
                statusStateBG:SetAnchor(GUIItem.Left, GUIItem.Center)
                statusStateBG:SetPosition(Vector(0, 0, 0))
                statusStateBG:SetSize(GUIScale(GUIPlayerStatus.kIconSizeVector))
                statusStateBG:SetLayer(self.hudLayer + 1)
                statusStateBG:SetTexture(GUIPlayerStatus.kStatusIconsTexture)
                statusStateBG:SetTexturePixelCoordinates(GUIUnpackCoords(settings.StatusBackgroundCoords))
                statusStateBG:SetIsVisible(false)
                statusStateBG:AddAsChildTo(self.statusBackground)

                local statusState = self.script:CreateAnimatedGraphicItem()
                statusState:SetTexture(settings.Texture)
                statusState:SetTexturePixelCoordinates(GUIUnpackCoords(settings.TextureCoordinates))
                statusState:SetAnchor(GUIItem.Middle, GUIItem.Center)
                statusState:SetSize(GUIScale(GUIPlayerStatus.kStatusIconSizeVector))
                statusState:SetPosition(-GUIPlayerStatus.kStatusIconSizeVector * 0.5)
                statusState:SetColor(settings.Color)
                statusState:SetIsVisible(true)
                statusState:AddAsChildTo(statusStateBG)
                statusState:SetInheritsParentAlpha(true)

                local statusTimer
                if not settings.Simple then
                    statusTimer = GUIDial()
                    statusTimer:Initialize(settings)
                    statusState:AddChild(statusTimer:GetBackground())
                    statusTimer:SetIsVisible(false)
                end

                local statusEffectIcon
                if settings.EffectIconCoords then
                    statusEffectIcon = self.script:CreateAnimatedGraphicItem()
                    statusEffectIcon:SetTexture(settings.Texture)
                    statusEffectIcon:SetTexturePixelCoordinates(GUIUnpackCoords(settings.EffectIconCoords))
                    statusEffectIcon:SetSize(GUIScale(Vector(GUIPlayerStatus.kEffectIconSize, GUIPlayerStatus.kEffectIconSize, 0)))
                    statusEffectIcon:SetPosition(Vector(-GUIPlayerStatus.kEffectIconSize , -GUIPlayerStatus.kEffectIconSize, 0))
                    statusEffectIcon:SetAnchor(GUIItem.Right, GUIItem.Bottom)
                    statusEffectIcon:SetColor(Color(1,1,1))
                    statusEffectIcon:SetIsVisible(true)
                    statusEffectIcon:AddAsChildTo(statusState)
                    statusEffectIcon:SetInheritsParentAlpha(true)
                    statusEffectIcon:SetLayer(self.hudLayer + 3)
                end

                return { Background = statusStateBG, Icon = statusState, Timer = statusTimer, EffectIcon = statusEffectIcon, Settings = settings, Active = false, PercentLeft = 0 }

            end

            function GUIPlayerStatus:Initialize()

                self.statusIcons = {}
                self.scale = 1
                self.lastNumActive = 0

                self.lastStatusState = {}
                for _, state in pairs(statusSettings) do
                    self.lastStatusState[state.Name] = state.DefaultValue or true
                end

                self.statusBackground = self.script:CreateAnimatedGraphicItem()
                self.statusBackground:SetAnchor(GUIItem.Left, GUIItem.Bottom)
                self.statusBackground:SetTexture(GUIPlayerStatus.kBackgroundTexture)
                self.statusBackground:SetTexturePixelCoordinates(GUIUnpackCoords(GUIPlayerStatus.kBackgroundCoords))
                self.statusBackground:SetColor(Color( 1, 1, 1, 0))
                self.statusBackground:AddAsChildTo(self.frame)

                self.statusStencil = GetGUIManager():CreateGraphicItem()
                self.statusStencil:SetTexture(GUIPlayerStatus.kBackgroundTexture)
                self.statusStencil:SetTexturePixelCoordinates(GUIUnpackCoords(GUIPlayerStatus.kStencilCoords))
                self.statusStencil:SetIsStencil(true)
                self.statusStencil:SetClearsStencilBuffer(false)
                self.statusBackground:AddChild(self.statusStencil)

                globalSettings.BackgroundWidth = GUIPlayerStatus.kTimerSize * self.scale
                globalSettings.BackgroundHeight = GUIPlayerStatus.kTimerSize * self.scale
                globalSettings.BackgroundOffset = GUIPlayerStatus.kTimerPosition * self.scale

                if self.teamNum == kTeam1Index then

                    GUIPlayerStatus.kNS1HudBarsOffset = ConditionalValue(GetAdvancedOption("hudbars_m") == 2, Vector(38, 0, 0), Vector(0,0,0))
                    GUIPlayerStatus.kBackgroundPos = Vector(90, -260, 0)
                    table.insert(self.statusIcons, CreateStatusIndicator(self, parasiteTimerSettings))
                    table.insert(self.statusIcons, CreateStatusIndicator(self, catpackSettings))
                    table.insert(self.statusIcons, CreateStatusIndicator(self, nanoshieldSettings))
                    table.insert(self.statusIcons, CreateStatusIndicator(self, corrodedSettings))
                    table.insert(self.statusIcons, CreateStatusIndicator(self, sporeCloudSettings))
                    table.insert(self.statusIcons, CreateStatusIndicator(self, beingWeldedSettings))

                elseif self.teamNum == kTeam2Index then

                    GUIPlayerStatus.kNS1HudBarsOffset = ConditionalValue(GetAdvancedOption("hudbars_a") == 2, Vector(38, 0, 0), Vector(0,0,0))
                    GUIPlayerStatus.kBackgroundPos = Vector(45, -370, 0)
                    table.insert(self.statusIcons, CreateStatusIndicator(self, detectedSettings))
                    table.insert(self.statusIcons, CreateStatusIndicator(self, enzymedSettings))
table.insert(self.statusIcons, CreateStatusIndicator(self, stormedSettings))
                    table.insert(self.statusIcons, CreateStatusIndicator(self, mucousedSettings))
                    table.insert(self.statusIcons, CreateStatusIndicator(self, cloakedSettings))
                    table.insert(self.statusIcons, CreateStatusIndicator(self, onFireSettings))
                    table.insert(self.statusIcons, CreateStatusIndicator(self, electrifiedSettings))
                    --table.insert(self.statusIcons, CreateStatusIndicator(self, wallWalkingSettings)) No icon for this yet
                    table.insert(self.statusIcons, CreateStatusIndicator(self, umbraSettings)) -- No icon for this yet
                    table.insert(self.statusIcons, CreateStatusIndicator(self, energizeSettings)) -- No icon for this yet
                    table.insert(self.statusIcons, CreateStatusIndicator(self, cragRangeSettings)) -- No icon for this yet
                    table.insert(self.statusIcons, CreateStatusIndicator(self, nerveGasSettings))

                end

                hintsEnabled = Client.GetOptionBoolean("showHints", true)

            end

           


            function GUIPlayerStatus:OnResolutionChanged(oldX, oldY, newX, newY)
                self:Reset( newY / kBaseScreenHeight )
            end

            function GUIPlayerStatus:Reset(scale)

                self.scale = scale

                if self.teamNum == kTeam1Index then
                    GUIPlayerStatus.kBackgroundPos = Vector(90, -260, 0)
                elseif self.teamNum == kTeam2Index then
                    GUIPlayerStatus.kBackgroundPos = Vector(45, -370, 0)
                end

                GUIPlayerStatus.kBackgroundPos.y = GUIPlayerStatus.kBackgroundPos.y - Clamp(((1 - self.scale) * 150),0, 275)

                self.statusBackground:SetUniformScale(self.scale)
                self.statusBackground:SetPosition(GUIPlayerStatus.kBackgroundPos + GUIPlayerStatus.kNS1HudBarsOffset)
                self.statusBackground:SetSize(GUIPlayerStatus.kBackgroundSize)

                self.statusStencil:SetSize(GUIPlayerStatus.kBackgroundSize * self.scale)

                for i, bar in ipairs(self.statusIcons) do

                    bar.Background:SetUniformScale(self.scale)
                    bar.Background:SetSize(GUIPlayerStatus.kIconSizeVector)
                    bar.Background:SetPosition((i-1) * GUIPlayerStatus.kStatusIconPosition)

                    bar.Icon:SetUniformScale(self.scale)
                    bar.Icon:SetSize(GUIPlayerStatus.kStatusIconSizeVector)
                    bar.Icon:SetPosition(-GUIPlayerStatus.kStatusIconSizeVector * 0.5)

                    bar.EffectIcon:SetUniformScale(self.scale)
                    bar.EffectIcon:SetSize(GUIPlayerStatus.kEffectIconSizeVector)

                    if bar.Timer then

                        bar.Timer:Uninitialize()
                        bar.Settings.BackgroundWidth = GUIPlayerStatus.kTimerSize * self.scale
                        bar.Settings.BackgroundHeight = GUIPlayerStatus.kTimerSize * self.scale
                        bar.Settings.BackgroundOffset = GUIPlayerStatus.kTimerPosition * self.scale
                        bar.Timer:Initialize( bar.Settings )
                        bar.Icon:AddChild( bar.Timer:GetBackground() )

                    end
                end
            end

            local function GetFreeStatus(self, settings)

                for _, bar in ipairs(self.statusIcons) do
                    if bar.Settings.Name == settings.Name then
                        return bar
                    end
                end

                local newStatus = CreateStatusIndicator(self, settings)
                table.insert(self.statusIcons, newStatus)
                return newStatus

            end

            local function ClearAllStatuses(self)

                for _, bar in ipairs(self.statusIcons) do
                    bar.Background:SetIsVisible(false)
                end

            end

            function GUIPlayerStatus:Uninitialize()

            end

            function GUIPlayerStatus:Destroy()

                for _, bar in ipairs(self.statusIcons) do

                    GUI.DestroyItem(bar.Background)
                    bar.Background = nil

                    if bar.Timer then
                        bar.Timer:Uninitialize()
                        bar.Timer = nil
                    end
                end

                if self.statusBackground then
                    self.statusBackground:Destroy()
                end

                self.statusIcons = nil

            end

            function GUIPlayerStatus:SetIsVisible(visible)
                self.statusBackground:SetIsVisible(visible)
            end

            local function StatusTimerLogic(self, parameters, fullMode)

                for _, bar in ipairs(self.statusIcons) do

                    if not bar.Settings.Simple and bar.Settings.Name and table.icount(bar.Settings.ParameterNumbers) == 2 then

                        local statusIcon = GetFreeStatus(self, statusSettings[bar.Settings.Name])
                        local statusState = parameters[bar.Settings.ParameterNumbers[1]] or 0
                        local statusPercentLeft = parameters[bar.Settings.ParameterNumbers[2]] or 0

                        assert(statusState ~= nil and statusPercentLeft ~= nil)

                        statusIcon.PercentLeft = statusPercentLeft

                        if self.lastStatusState[bar.Settings.Name] ~= statusState then

                            statusIcon.Background:DestroyAnimations()
                            statusIcon.Icon:DestroyAnimations()
                            statusIcon.Icon:SetColor(GUIPlayerStatus.kIconColor[statusState], 0)

                            if self.lastStatusState[bar.Settings.Name] < statusState then

                                if not bar.Settings.NoSizeAnimations then

                                    statusIcon.Background:SetSize(GUIPlayerStatus.kIconSizeVector * 1.55)
                                    statusIcon.Background:SetSize(GUIPlayerStatus.kIconSizeVector, 0.4)
                                    statusIcon.Icon:SetSize(GUIPlayerStatus.kStatusIconSizeVector * 1.55)
                                    statusIcon.Icon:SetSize(GUIPlayerStatus.kStatusIconSizeVector, 0.4)

                                end
                            end

                            self.lastStatusState[bar.Settings.Name] = statusState
                        end

                        if self.lastStatusState[bar.Settings.Name] then

                            statusIcon.Timer:GetLeftSide():SetColor(GUIPlayerStatus.kIconColor[statusState])
                            statusIcon.Timer:GetRightSide():SetColor(GUIPlayerStatus.kIconColor[statusState])

                        else

                            statusIcon.Timer:GetLeftSide():SetColor(GUIPlayerStatus.kIconColor[STATUS_OFF])
                            statusIcon.Timer:GetRightSide():SetColor(GUIPlayerStatus.kIconColor[STATUS_OFF])

                        end

                        local visible = statusPercentLeft > 0

                        if bar.Settings.ShowWithHintsOnly then
                            visible = visible and hintsEnabled
                        end

                        if not bar.Settings.ShowWithLowHUDDetails then
                            visible = visible and fullMode
                        end

                        statusIcon.Timer:SetPercentage( statusPercentLeft )
                        statusIcon.Timer:SetIsVisible( visible )
                        statusIcon.Background:SetIsVisible( visible )
                        statusIcon.Timer:Update(deltaTime)
                        statusIcon.Active = visible

                        if visible or statusState then
                            self.script.updateInterval = kUpdateIntervalFull
                        end

                    end
                end
            end

            local function SimpleStatusLogic(self, parameters, fullMode)

                for _, bar in ipairs(self.statusIcons) do

                    if bar.Settings.Simple and bar.Settings.Name then

                        local statusIcon = GetFreeStatus(self, statusSettings[bar.Settings.Name])
                        local statusState = parameters[bar.Settings.Name] or false

                        local visible = statusState

                        if bar.Settings.ShowWithHintsOnly then
                            visible = visible and hintsEnabled
                        end

                        if not bar.Settings.ShowWithLowHUDDetails then
                            visible = visible and fullMode
                        end

                        if self.lastStatusState[bar.Settings.Name] ~= statusState then

                            statusIcon.Background:DestroyAnimations()
                            statusIcon.Icon:DestroyAnimations()

                            if not bar.Settings.NoSizeAnimations then

                                statusIcon.Background:SetSize(GUIPlayerStatus.kIconSizeVector * 1.55)
                                statusIcon.Background:SetSize(GUIPlayerStatus.kIconSizeVector, 0.4)
                                statusIcon.Icon:SetSize(GUIPlayerStatus.kStatusIconSizeVector * 1.55)
                                statusIcon.Icon:SetSize(GUIPlayerStatus.kStatusIconSizeVector, 0.4)

                            end

                            self.lastStatusState[bar.Settings.Name] = statusState
                        end

                        statusIcon.Active = visible
                        statusIcon.Background:SetIsVisible( visible )

                        if visible or statusState then
                            self.script.updateInterval = kUpdateIntervalFull
                        end

                    end
                end

            end


            local function compare(a, b)
                local a1 = a.Active == true and 1 or 0
                local b1 = b.Active == true and 1 or 0
                return a1 > b1
            end

            function GUIPlayerStatus:Update(deltaTime, parameters, fullMode)

                local numActive = 0

                ClearAllStatuses(self)

                StatusTimerLogic(self, parameters, fullMode)

                SimpleStatusLogic(self, parameters, fullMode)

                --Order is important here. Sort then set position
                for _, bar in ipairs(self.statusIcons) do
                    if bar.Active == true then
                        numActive = numActive + 1
                    end
                end

                if self.lastNumActive ~= numActive then
                    table.sort(self.statusIcons, compare)
                    self.lastNumActive = numActive
                end

                for i, bar in ipairs(self.statusIcons) do
                    bar.Background:SetPosition((i-1) * GUIPlayerStatus.kStatusIconPosition)
                end

                hintsEnabled = Client.GetOptionBoolean("showHints", true)

            end



