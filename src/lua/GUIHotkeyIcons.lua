-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\GUIHotkeyIcons.lua
--
-- Created by: Brian Cronin (brianc@unknownworlds.com)
--
-- Manages the displaying the hotkey icons and registering mouse presses on them.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIHotkeyIcons' (GUIScript)

local function UpdateItemsGUIScale(self)
    GUIHotkeyIcons.kHotkeyIconSize = GUIScale(40)
    -- The buffer between icons.
    GUIHotkeyIcons.kHotkeyIconXOffset = GUIScale(6)

    GUIHotkeyIcons.kBackgroundWidth = (GUIHotkeyIcons.kHotkeyIconSize + GUIHotkeyIcons.kHotkeyIconXOffset) * kMaxHotkeyGroups
    GUIHotkeyIcons.kBackgroundHeight = 2 * GUIHotkeyIcons.kHotkeyIconSize
    
    if self.background then
        self.background:SetPosition(Vector(0, -GUIHotkeyIcons.kBackgroundHeight, 0))
    end
    
    if self.hotkeys then
        for index, item in ipairs(self.hotkeys) do
            item.Icon:SetSize(Vector(GUIHotkeyIcons.kHotkeyIconSize, GUIHotkeyIcons.kHotkeyIconSize, 0))
            item.Icon:SetPosition(Vector((index - 1) * (GUIHotkeyIcons.kHotkeyIconSize + GUIHotkeyIcons.kHotkeyIconXOffset), 0, 0))
            item.Text:SetFontName(Fonts.kArial_15)
            item.Text:SetScale(GetScaledVector())
            GUIMakeFontScale(item.Text)
        end
    end
end

function GUIHotkeyIcons:OnResolutionChanged(oldX, oldY, newX, newY)
    UpdateItemsGUIScale(self)
end

function GUIHotkeyIcons:Initialize()

    UpdateItemsGUIScale(self)
    
    self.mousePressed = nil
    
    self.hotkeys = { }
    
    self.teamType = PlayerUI_GetTeamType()
    
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize(Vector(GUIHotkeyIcons.kBackgroundWidth, GUIHotkeyIcons.kBackgroundHeight, 0))
    -- The background is an invisible container only.
    self.background:SetColor(Color(0, 0, 0, 0))
    self.background:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.background:SetPosition(Vector(0, -GUIHotkeyIcons.kBackgroundHeight, 0))
    
    local currentHotkey = 0
    while currentHotkey < kMaxHotkeyGroups do
    
        local hotkeyIcon = GUIManager:CreateGraphicItem()
        hotkeyIcon:SetSize(Vector(GUIHotkeyIcons.kHotkeyIconSize, GUIHotkeyIcons.kHotkeyIconSize, 0))
        hotkeyIcon:SetAnchor(GUIItem.Left, GUIItem.Top)
        hotkeyIcon:SetPosition(Vector(currentHotkey * (GUIHotkeyIcons.kHotkeyIconSize + GUIHotkeyIcons.kHotkeyIconXOffset), 0, 0))
        hotkeyIcon:SetTexture("ui/buildmenu.dds")
        hotkeyIcon:SetIsVisible(false)
        hotkeyIcon:SetColor(kIconColors[self.teamType])
        self.background:AddChild(hotkeyIcon)
        
        local hotkeyText = GUIManager:CreateTextItem()
        hotkeyText:SetFontName(Fonts.kArial_15)
        hotkeyText:SetScale(GetScaledVector())
        GUIMakeFontScale(hotkeyText)
        hotkeyText:SetAnchor(GUIItem.Middle, GUIItem.Top)
        hotkeyText:SetTextAlignmentX(GUIItem.Align_Center)
        hotkeyText:SetTextAlignmentY(GUIItem.Align_Max)
        hotkeyText:SetColor(Color(1, 1, 1, 1))
        hotkeyText:SetText(ToString(currentHotkey + 1))
        hotkeyIcon:AddChild(hotkeyText) 
        
        table.insert(self.hotkeys, { Icon = hotkeyIcon, Text = hotkeyText })
        
        currentHotkey = currentHotkey + 1
        
    end

end

function GUIHotkeyIcons:Uninitialize()
    
    -- Everything is attached to the background so destroying it will destroy everything else.
    if self.background then
        GUI.DestroyItem(self.background)
        self.background = nil
        self.hotkeys = { }
    end
    
end

local function GetIsGroupInCombat(group)

    local inCombat = false
    
    for i = 1, #group do

        local entity = group[i]
        if HasMixin(entity, "Combat") and entity:GetIsInCombat() then
            inCombat = true
            break
        end

    end   
    
    return inCombat

end

function GUIHotkeyIcons:Update(deltaTime)
    
    PROFILE("GUIHotkeyIcons:Update")
    
    local hotKeyGroups = CommanderUI_GetHotKeyGroups()
    local numHotkeys = 0
    for index, group in pairs(hotKeyGroups) do
        numHotkeys = numHotkeys + 1
    end

    if numHotkeys > 0 then
        self.background:SetIsVisible(true)
        
        local currentHotkey = 0
        while currentHotkey < kMaxHotkeyGroups do
        
            local hotkeyTable = self.hotkeys[currentHotkey + 1]
            local group = hotKeyGroups[currentHotkey + 1]
            
            if group and group[1] and HasMixin(group[1], "Tech") then
            
                local techId = group[1]:GetTechId()
                local coordinates = GetTextureCoordinatesForIcon(techId)
            
                hotkeyTable.Icon:SetIsVisible(true)
                hotkeyTable.Text:SetText(CommanderUI_GetHotkeyName(currentHotkey + 1))
                hotkeyTable.Icon:SetTexturePixelCoordinates(GUIUnpackCoords(coordinates))
                
                local useColor = Color(kIconColors[self.teamType])
                if GetIsGroupInCombat(group) then
                    
                    local anim = 0.2 + (1 + math.cos(Shared.GetTime() * 6)) * 0.2
                    useColor.g = anim
                    useColor.b = anim
                    
                end
                
                hotkeyTable.Icon:SetColor(useColor)                
                
            else
                -- No coordinates, this hotkey is not valid (has no entities in the group).
                hotkeyTable.Icon:SetIsVisible(false)
            end
            
            currentHotkey = currentHotkey + 1
        end
    else
        self.background:SetIsVisible(false)
    end
    
end

function GUIHotkeyIcons:SendKeyEvent(key, down)

    local mouseX, mouseY = Client.GetCursorPosScreen()
    
    if key == InputKey.MouseButton0 and self.mousePressed ~= down then
        self.mousePressed = down
        if down then
            self:MousePressed(key, mouseX, mouseY)
        end
    end
    
end

function GUIHotkeyIcons:MousePressed(key, mouseX, mouseY)

    if key == InputKey.MouseButton0 then
        local currentHotkey = 0
        while currentHotkey < kMaxHotkeyGroups do
            local hotkeyTable = self.hotkeys[currentHotkey + 1]
            if hotkeyTable.Icon:GetIsVisible() and GUIItemContainsPoint(hotkeyTable.Icon, mouseX, mouseY) then
                CommanderUI_SelectHotkey(currentHotkey + 1)
                break
            end
            currentHotkey = currentHotkey + 1
        end
    end

end

function GUIHotkeyIcons:GetBackground()

    return self.background

end

function GUIHotkeyIcons:ContainsPoint(pointX, pointY)

    for i = 1, #self.hotkeys do
    
        local hotKeyTable = self.hotkeys[i]
        if hotKeyTable.Icon:GetIsVisible() and GUIItemContainsPoint(hotKeyTable.Icon, pointX, pointY) then
            return true
        end
    
    end

    return false

end
