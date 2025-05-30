-- ====**** Scripts\GUIBetaBalanceChangelog.lua ****====
-- ======= Copyright (c) 2021, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/Changelog/GUIBetaBalanceChangelog.lua
--
--    Created by:   Darrell Gentry (darrell@naturalselection2.com)
--
--    Simple window that displays the changelog for the balance mod
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/menu2/GUIMenuTabbedBox.lua")
Script.Load("lua/menu2/widgets/GUIMenuTabButtonWidget.lua")
Script.Load("lua/menu2/widgets/GUIMenuScrollPane.lua")
Script.Load("lua/GUIBetaBalanceChangelog.lua")
Script.Load("lua/GUI/GUIText.lua")
Script.Load("lua/GUI/GUIParagraph.lua")
Script.Load("lua/GUIBetaBalanceChangelogData.lua")


local kInnerBackgroundSideSpacing = 32 -- horizontal spacing between edge of outer background and inner background.
local kInnerBackgroundTopSpacing = 212 -- spacing between top edge of outer background and inner background.
-- spacing between bottom edge of outer background and inner background (not including tab height!).
local kInnerBackgroundBottomSpacing = 18

local kUnderlapYSize = 113

local kTabHeight = 94
local kTabMinWidth = 150

local kTabButtonFont = {family = "MicrogrammaBold", size = 48}

local kTitleStyle =
{
    padding = 17, -- extra pixels added to all 4 sides to make room for outer glow.  Scales with gui object.
    shader = "shaders/GUI/menu/mainBarButtonGlow.surface_shader",
    inputs =
    {
        [1] = {
            name = "innerGlowBlur",
            value = GUIStyle.TextBlur(3)
        },
        [2] = { name = "innerGlowColor", value = HexToColor("7df7ff", 0.1) },

        [3] = {
            name = "outerGlowBlur",
            value = GUIStyle.TextBlur(15)
        },
        [4] = { name = "outerGlowColor", value = HexToColor("75c6ff", 0.49) },

        [5] = { name = "baseTexture", value = "__Text", },
        [6] = { name = "textColor", value = HexToColor("ffffff") },
    }
}

local kTitleFont = {family = "AgencyBold", size = 60}

local baseClass = GUIMenuTabbedBox
class "GUIBetaBalanceChangelog" (baseClass)

GUIBetaBalanceChangelog:AddClassProperty("IsOpen", false)

function GUIBetaBalanceChangelog:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1

    baseClass.Initialize(self, params, errorDepth)

    self.contentObs = {}

    self:AlignCenter()
    self:SetLayer(999)

    self.title = CreateGUIObject("title", GUIStyledText, self,
    {
        style = kTitleStyle,
        font  = kTitleFont,
        align = "top",
    })
    self.title:SetText("BALANCE CHANGELOG")
    self.title:SetY(-23)

    self:InitializeContentHolders()

    self.tabButton = CreateGUIObject("tabButton", GUIMenuTabButtonWidget, self)
    self.tabButton:SetTabHeight(kTabHeight)
    self.tabButton:SetTabMinWidth(kTabMinWidth)
    self.tabButton:AlignBottom()
    self.tabButton:SetFont(kTabButtonFont)
    self.tabButton:SetLabel("CLOSE")
    self:HookEvent(self.tabButton, "OnPressed", self.Close)
    self:HookEvent(self.tabButton, "OnTabSizeChanged", self.SetTabSize)
    self:SetTabSize(self.tabButton:GetTabSize())

    self:SetSize(2300, 1600)
    self:SetY(900)
    self:Close()

end

function GUIBetaBalanceChangelog:InitializeContentHolders()

    self.innerBack = CreateGUIObject("innerBack", GUIMenuBasicBox, self)
    self.innerBack:SetPosition(kInnerBackgroundSideSpacing, kInnerBackgroundTopSpacing - kUnderlapYSize)
    self:HookEvent(self, "OnSizeChanged", self.UpdateInnerBackgroundSize)

    self.scrollPane = CreateGUIObject("scrollPane", GUIMenuScrollPane, self.innerBack)

    self.listLayout = CreateGUIObject("listLayout", GUIListLayout, self.scrollPane,
    {
        orientation = "vertical",
        spacing = 0,
    })

    self.scrollPane:HookEvent(self.listLayout, "OnSizeChanged", self.scrollPane.SetPaneSize)

end

function GUIBetaBalanceChangelog:OnListSizeChanged()
    self.scrollPane:SetPaneSize(self.listLayout:GetSize().x, self.listLayout:GetSize().y + 200)
end

local kStyleToFontsMap =
{
    [1] = {family = "AgencyBold", size = 68  }, -- largest header
    [2] = {family = "AgencyBold", size = 56  },
    [3] = {family = "Agency", size = 50  },
    [0] = {family = "Arial", size = 28  } -- normal text
}

local kStyleToColorMap =
{
    [1] = MenuStyle.kHighlight,
    [2] = MenuStyle.kOptionHeadingColor,
    [3] = MenuStyle.kOptionHeadingColor,
    [0] = Color(1, 1, 1),
}

local function AddLineGroup(self, lineGroup, style, lineNumber)

    local lineGroupObj = CreateGUIObject(string.format("lineGroup_%d", lineNumber), GUIParagraph, self.listLayout,
    {
        justification = GUIItem.Align_Min,
        font = kStyleToFontsMap[style],
        color = kStyleToColorMap[style],
        paragraphSize = Vector(self.scrollPane:GetSize().x, -1, 0),
        text = lineGroup
    })
    table.insert(self.contentObs, lineGroupObj)

end

function GUIBetaBalanceChangelog:LoadChangelog(changelogData)

    for i = 1, #self.contentObs do
        self.contentObs[i]:Destroy()
    end

    self.contentObs = {}

    local changelogStyleToken = GetChangelogStyleToken()
    local changelogLines = string.Explode(changelogData, "\n")

    -- Keep track of consecutive lines that have the same style so we can minimize the amount of objects created
    local lineGroup = ""
    local lineGroupStyle = 0

    for i = 1, #changelogLines do

        local rawLine = changelogLines[i]
        local processedLine, numTokens = string.gsub(rawLine, changelogStyleToken, "")
        processedLine = string.format("  %s", processedLine)

        --Log("$ Line: %s (Style: %s)", processedLine, numTokens)

        if i == 1 then

            lineGroup = processedLine
            lineGroupStyle = numTokens

        else

            local groupLenIfAdded = string.len(lineGroup) + string.len(processedLine)
            if numTokens ~= lineGroupStyle or i == #changelogLines or groupLenIfAdded > 500 then -- We found a string with a different style, so we create a gui obj

                AddLineGroup(self, lineGroup, lineGroupStyle, i)

                lineGroup = processedLine
                lineGroupStyle = numTokens

            else
                lineGroup = string.format("%s\n%s", lineGroup, processedLine)
            end

        end

    end

    AddLineGroup(self, lineGroup, lineGroupStyle, #changelogLines)

end

function GUIBetaBalanceChangelog:UpdateInnerBackgroundSize()
    self.innerBack:SetSize(self:GetSize() - Vector(kInnerBackgroundSideSpacing * 2, kInnerBackgroundBottomSpacing + kInnerBackgroundTopSpacing, 0))
    self.scrollPane:SetSize(self.innerBack:GetSize().x, self.innerBack:GetSize().y)
end

function GUIBetaBalanceChangelog:OnKey(key, down)
    if key == InputKey.Escape then
        self:Close()
    end
end

function GUIBetaBalanceChangelog:Close()
    self:StopListeningForKeyInteractions()
    self:SetVisible(false)
    self:ClearModal()
    self:SetIsOpen(false)
    self:FireEvent("Closed")
end

function GUIBetaBalanceChangelog:Open()
    self:ListenForKeyInteractions()
    self:SetVisible(true)
    self:SetModal()
    self:SetIsOpen(true)
    self:FireEvent("Opened")
end

