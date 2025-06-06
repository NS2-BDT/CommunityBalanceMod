-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\GUIDeathMessages.lua
--
-- Created by: Brian Cronin (brianc@unknownworlds.com)
--
-- Manages messages displayed when something kills something else.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIDeathMessages' (GUIScript)

local kKillHighlight = PrecacheAsset("ui/killfeed_highlight.dds")
local kKillLeftBorderCoords = { 0, 0, 15, 64 }
local kKillMiddleBorderCoords = { 16, 0, 112, 64 }
local kKillRightBorderCoords = { 113, 0, 128, 64 }
local kFontName = Fonts.kAgencyFB_Small
local kBackgroundHeight = GUIScale(32)
local kScreenOffset = GUIScale(40)
local kScreenOffsetX = GUIScale(38)

local kSustainTime = 4
local kFadeOutTime = 1

local kSMGTexture = PrecacheAsset("ui/inventory_icon_smg.dds")

GUIDeathMessages.kKillfeedHighlightEnabled   = GetAdvancedOption("killfeedhighlight") == 1
GUIDeathMessages.kKillfeedCustomColorEnabled = GetAdvancedOption("killfeedcolorcustom")
GUIDeathMessages.kKillfeedCustomColor        = GetAdvancedOption("killfeedcolor")

GUIDeathMessages.kKillfeedScale = GetAdvancedOption("killfeedscale")

function GUIDeathMessages:Initialize()
    
    self.scale = GUIDeathMessages.kKillfeedScale

    kBackgroundHeight = GUIScale(32) * self.scale
    
    self.anchor = GUIManager:CreateGraphicItem()
    self.anchor:SetColor(Color(0, 0, 0, 0))
    self.anchor:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.anchor:SetLayer(kGUILayerPlayerHUD)
    
    self.messages = { }
    self.reuseMessages = { }
    
    self.visible = true
    
end

function GUIDeathMessages:Reset()
    
    for i, message in ipairs(self.messages) do
        GUI.DestroyItem(message["Background"])
    end
    self.messages = { }
    
    for i, message in ipairs(self.reuseMessages) do
        GUI.DestroyItem(message["Background"])
    end
    self.reuseMessages = { }
    
end

function GUIDeathMessages:OnResolutionChanged(oldX, oldY, newX, newY)
    self:Reset()
    
    kBackgroundHeight = GUIScale(32) * self.scale
    kScreenOffset = GUIScale(40)
    kScreenOffsetX = GUIScale(38)
end

function GUIDeathMessages:Uninitialize()
    
    for i, message in ipairs(self.messages) do
        GUI.DestroyItem(message["Background"])
    end
    self.messages = nil
    
    for i, message in ipairs(self.reuseMessages) do
        GUI.DestroyItem(message["Background"])
    end
    self.reuseMessages = nil
    
    GUI.DestroyItem(self.anchor)
end

function GUIDeathMessages:SetIsVisible(state)
    
    self.visible = state
    
    for i=1, #self.messages do
        self.messages[i].Background:SetIsVisible(state)
    end
    
end

function GUIDeathMessages:GetIsVisible()
    
    return self.visible
    
end

function GUIDeathMessages:Update(deltaTime)
    
    PROFILE("GUIDeathMessages:Update")
    
    local addDeathMessages = DeathMsgUI_GetMessages()
    local numberElementsPerMessage = 6 -- FIXME - pretty error prone
    local numberMessages = table.icount(addDeathMessages) / numberElementsPerMessage
    local currentIndex = 1
    while numberMessages > 0 do
    
        local killerColor = addDeathMessages[currentIndex]
        local killerName = addDeathMessages[currentIndex + 1]
        local targetColor = addDeathMessages[currentIndex + 2]
        local targetName = addDeathMessages[currentIndex + 3]
        local iconIndex = addDeathMessages[currentIndex + 4]
        local targetIsPlayer = addDeathMessages[currentIndex + 5]
        self:AddMessage(killerColor, killerName, targetColor, targetName, iconIndex, targetIsPlayer)
        currentIndex = currentIndex + numberElementsPerMessage
        numberMessages = numberMessages - 1
        
    end
    
    self.updateInterval = #self.messages > 0 and 0 or 0.2
    
    self.anchor:SetPosition(Vector(0, ConditionalValue(CommanderUI_IsLocalPlayerCommander(), GUIScale(50), 0), 0))
    
    local removeMessages = { }
    -- Update existing messages.
    for i, message in ipairs(self.messages) do
    
        local currentPosition = Vector(message["Background"]:GetPosition())
        currentPosition.y = kScreenOffset + GUIScale(8) + (kBackgroundHeight * (i - 1))
        currentPosition.x = message["BackgroundXOffset"]
        message["Background"]:SetPosition(currentPosition)
        message["Time"] = message["Time"] + deltaTime

        if message["Time"] >= message.sustainTime then

            local fadeFraction = (message["Time"]-message.sustainTime) / kFadeOutTime
            local alpha = Clamp( 1-fadeFraction, 0, 1 )
            local currentColor = message["Killer"]:GetColor()
            currentColor.a = alpha
            message["Killer"]:SetColor(currentColor)
            currentColor = message["Weapon"]:GetColor()
            currentColor.a = alpha
            message["Weapon"]:SetColor(currentColor)
            currentColor = message["Target"]:GetColor()
            currentColor.a = alpha
            message["Target"]:SetColor(currentColor)
            currentColor = message["Background"]:GetColor()
            if currentColor.a > 0 then
                currentColor.a = alpha
            end
            message["Background"]:SetColor(currentColor)

            if fadeFraction > 1.0 then
                table.insert(removeMessages, message)
            end
        end
    end
    
    -- Remove faded out messages.
    for i, removeMessage in ipairs(removeMessages) do
    
        removeMessage["Background"]:SetIsVisible(false)
        table.insert(self.reuseMessages, removeMessage)
        table.removevalue(self.messages, removeMessage)
        
    end
    
end

function GUIDeathMessages:AddMessage(killerColor, killerName, targetColor, targetName, iconIndex, targetIsPlayer)

    local xOffset = DeathMsgUI_GetTechOffsetX(iconIndex)
    local yOffset = DeathMsgUI_GetTechOffsetY(iconIndex)
    local iconWidth = DeathMsgUI_GetTechWidth(iconIndex)
    local iconHeight = DeathMsgUI_GetTechHeight(iconIndex)
    
    local insertMessage = { Background = nil, Killer = nil, Weapon = nil, Target = nil, Time = 0 }
    
    -- Check if we can reuse an existing message.
    if table.icount(self.reuseMessages) > 0 then
    
        insertMessage = self.reuseMessages[1]
        insertMessage["Time"] = 0
        insertMessage["Background"]:SetIsVisible(self.visible)
        table.remove(self.reuseMessages, 1)
        
    end
    
    if insertMessage["Killer"] == nil then
        insertMessage["Killer"] = GUIManager:CreateTextItem()
    end
    
    insertMessage["Killer"]:SetFontName(kFontName)
    insertMessage["Killer"]:SetAnchor(GUIItem.Left, GUIItem.Center)
    insertMessage["Killer"]:SetTextAlignmentX(GUIItem.Align_Max)
    insertMessage["Killer"]:SetTextAlignmentY(GUIItem.Align_Center)
    insertMessage["Killer"]:SetColor(ColorIntToColor(killerColor))
    insertMessage["Killer"]:SetText(killerName .. " ")
    insertMessage["Killer"]:SetScale(GetScaledVector()*self.scale)
    GUIMakeFontScale(insertMessage["Killer"])
    
    if insertMessage["Weapon"] == nil then
        insertMessage["Weapon"] = GUIManager:CreateGraphicItem()
    end
    
    local scaledIconHeight = kBackgroundHeight - GUIScale(4)
    -- Preserve aspect ratio
    local scaledIconWidth = GUIScale(iconWidth)/(GUIScale(iconHeight)/scaledIconHeight)
    
    insertMessage["Weapon"]:SetSize(Vector(scaledIconWidth, scaledIconHeight, 0))
    insertMessage["Weapon"]:SetAnchor(GUIItem.Left, GUIItem.Center)
	
	if iconIndex == kDeathMessageIcon.Submachinegun then
        insertMessage["Weapon"]:SetTexture(kSMGTexture)
    else
		insertMessage["Weapon"]:SetTexture(kInventoryIconsTexture)
	end

    insertMessage["Weapon"]:SetTexturePixelCoordinates(xOffset, yOffset, xOffset + iconWidth, yOffset + iconHeight)
    insertMessage["Weapon"]:SetColor(Color(1, 1, 1, 1))
    
    if insertMessage["Target"] == nil then
        insertMessage["Target"] = GUIManager:CreateTextItem()
    end
    
    insertMessage["Target"]:SetFontName(kFontName)
    insertMessage["Target"]:SetAnchor(GUIItem.Right, GUIItem.Center)
    insertMessage["Target"]:SetTextAlignmentX(GUIItem.Align_Min)
    insertMessage["Target"]:SetTextAlignmentY(GUIItem.Align_Center)
    insertMessage["Target"]:SetColor(ColorIntToColor(targetColor))
    insertMessage["Target"]:SetText(" " .. targetName)
    insertMessage["Target"]:SetScale(GetScaledVector()*self.scale)
    GUIMakeFontScale(insertMessage["Target"])
    
    local killerTextWidth = insertMessage["Killer"]:GetTextWidth(killerName .. " ") * insertMessage["Killer"]:GetScale().x
    local targetTextWidth = insertMessage["Target"]:GetTextWidth(targetName .. " ") * insertMessage["Target"]:GetScale().x
    local textWidth = killerTextWidth + targetTextWidth
    
    insertMessage["Weapon"]:SetPosition(Vector(killerTextWidth, -scaledIconHeight / 2, 0))
    
    if insertMessage["Background"] == nil then
    
        insertMessage["Background"] = GUIManager:CreateGraphicItem()
        insertMessage["Background"].left = GUIManager:CreateGraphicItem()
        insertMessage["Background"].left:SetAnchor(GUIItem.Left, GUIItem.Top)
        insertMessage["Background"].right = GUIManager:CreateGraphicItem()
        insertMessage["Background"].right:SetAnchor(GUIItem.Right, GUIItem.Top)
        insertMessage["Background"]:AddChild(insertMessage["Background"].right)
        insertMessage["Background"]:AddChild(insertMessage["Background"].left)
        insertMessage["Weapon"]:AddChild(insertMessage["Killer"])
        insertMessage["Background"]:AddChild(insertMessage["Weapon"])
        insertMessage["Weapon"]:AddChild(insertMessage["Target"])
        self.anchor:AddChild(insertMessage["Background"])
        
    end

    local player = Client.GetLocalPlayer()
    local backgroundColor = ConditionalValue(GUIDeathMessages.kKillfeedCustomColorEnabled, GUIDeathMessages.kKillfeedCustomColor, ColorIntToColor(killerColor))
    backgroundColor.a = ConditionalValue(player and GUIDeathMessages.kKillfeedHighlightEnabled and Client.GetIsControllingPlayer() and player:GetName() == killerName and targetIsPlayer and killerColor ~= targetColor, 1, 0)
    
    insertMessage["BackgroundWidth"] = textWidth + scaledIconWidth
    insertMessage["Background"]:SetSize(Vector(insertMessage["BackgroundWidth"], kBackgroundHeight, 0))
    insertMessage["Background"]:SetAnchor(GUIItem.Right, GUIItem.Top)
    insertMessage["BackgroundXOffset"] = -textWidth - scaledIconWidth - kScreenOffset - kScreenOffsetX
    insertMessage["Background"]:SetPosition(Vector(insertMessage["BackgroundXOffset"], 0, 0))
    insertMessage["Background"]:SetColor(backgroundColor)
    insertMessage["Background"]:SetTexture(kKillHighlight)
    insertMessage["Background"]:SetTexturePixelCoordinates(GUIUnpackCoords(kKillMiddleBorderCoords))

    insertMessage["Background"].left:SetColor(backgroundColor)
    insertMessage["Background"].left:SetTexture(kKillHighlight)
    insertMessage["Background"].left:SetTexturePixelCoordinates(GUIUnpackCoords(kKillLeftBorderCoords))
    insertMessage["Background"].left:SetSize(Vector(GUIScale(8), kBackgroundHeight, 0))
    insertMessage["Background"].left:SetInheritsParentAlpha(true)
    insertMessage["Background"].left:SetPosition(Vector(-GUIScale(8), 0, 0))

    insertMessage["Background"].right:SetColor(backgroundColor)
    insertMessage["Background"].right:SetTexture(kKillHighlight)
    insertMessage["Background"].right:SetTexturePixelCoordinates(GUIUnpackCoords(kKillRightBorderCoords))
    insertMessage["Background"].right:SetSize(Vector(GUIScale(8), kBackgroundHeight, 0))
    insertMessage["Background"].right:SetInheritsParentAlpha(true)
    insertMessage.sustainTime = kSustainTime
    
    table.insert(self.messages, insertMessage)
    
end