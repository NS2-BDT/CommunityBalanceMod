Script.Load("lua/GUIMarineBuyMenu.lua")
Script.Load("lua/ModularExos/GUI/GUIMarineBuyMenu_Data.lua")

local kWeaponGroupButtonPositions = {
    [GUIMarineBuyMenu.kButtonGroupFrame_Unlabeled_x2] = {
        Vector(4, 4, 0),
        Vector(4, 122, 0)
    },
    [GUIMarineBuyMenu.kButtonGroupFrame_Labeled_x3]   = {
        Vector(4, 20, 0),
        Vector(4, 140, 0),
        Vector(4, 258, 0),
    },
    [GUIMarineBuyMenu.kButtonGroupFrame_Labeled_x4]   = {
        Vector(4, 25, 0),
        Vector(4, 143, 0),
        Vector(4, 262, 0),
        Vector(4, 380, 0)
    }
}

--local kButtonShowState = enum(
--        {
--            'Uninitialized',
--            'NotHosted',
--            'Occupied',
--            'Equipped',
--            'Unresearched',
--            'InsufficientFunds',
--            'Available',
--            'Disabled', -- Tutorial should block 'Axe' purchasing, for example. Override 'GUIMarineBuyMenu:GetTechIDDisabled(techID)' for this.
--        }
--)
--
--local kButtonShowStateDefinitions = {
--    [kButtonShowState.Disabled]          = {
--        ShowError = true,
--        Text      = "BUYMENU_ERROR_DISABLED",
--        TextColor = Color(239 / 255, 94 / 255, 80 / 255)
--    },
--
--    [kButtonShowState.NotHosted]         = {
--        ShowError = true,
--        Text      = "BUYMENU_ERROR_UNAVAILABLE",
--        TextColor = Color(94 / 255, 116 / 255, 128 / 255)
--    },
--
--    [kButtonShowState.Occupied]          = {
--        ShowError = true,
--        Text      = "BUYMENU_ERROR_OCCUPIED",
--        TextColor = Color(94 / 255, 116 / 255, 128 / 255)
--    },
--
--    [kButtonShowState.Equipped]          = {
--        ShowError = true,
--        Text      = "BUYMENU_ERROR_EQUIPPED",
--        TextColor = Color(2 / 255, 230 / 255, 255 / 255)
--    },
--
--    [kButtonShowState.Unresearched]      = {
--        ShowError = true,
--        Text      = "BUYMENU_ERROR_NOTRESEARCHED",
--        TextColor = Color(94 / 255, 116 / 255, 128 / 255)
--    },
--
--    [kButtonShowState.InsufficientFunds] = {
--        ShowError = true,
--        Text      = "BUYMENU_ERROR_INSUFFICIENTFUNDS",
--        TextColor = Color(239 / 255, 94 / 255, 80 / 255)
--    },
--
--    [kButtonShowState.Available]         = {
--        ShowError = false,
--    },
--}

local kResourceIconTexture = "ui/pres_icon_big.dds"
local kButtonTexture = "ui/marine_buymenu_button.dds"
local kMenuSelectionTexture = "ui/buymenu_marine/button_highlight.dds"
local kResourceIconWidth = (32)
local kResourceIconHeight = (32)

local kFont = Fonts.kAgencyFB_Small

local kCloseButtonColorHover = Color(1, 1, 1, 1)
local kCloseButtonColor = Color(0.82, 0.98, 1, 1)
local kTextColor = Color(kMarineFontColor)

local kDisabledColor = Color(0.82, 0.98, 1, 0.5)
local kCannotBuyColor = Color(0.98, 0.24, 0.17, 1)
local kEnabledColor = Color(1, 1, 1, 1)

local orig_MarineBuy_GetCosts = MarineBuy_GetCosts
function MarineBuy_GetCosts(techId)
    if techId == kTechId.Exosuit then
        local minResCost = 1337
        --for moduleType, moduleTypeName in ipairs(kExoModuleTypes) do
        --	local moduleTypeData = kExoModuleTypesData[moduleType]
        --	if moduleTypeData and moduleTypeData.category == kExoModuleCategories.PowerSupply then
        --		minResCost = math.min(minResCost, moduleTypeData.resourceCost)
        --	end
        --end
        return minResCost
    end
    return orig_MarineBuy_GetCosts(techId)
end

local kConfigAreaWidth = 1000
local kConfigAreaHeight = 900

local kSlotPanelBackgroundColor = Color(0, 0, 0, 0.6)
local kModuleButtonSize = Vector(220, 84, 0)
local kWeaponImageSize = Vector(80, 40, 0)
local kUtilityImageSize = Vector(59, 59, 0)

GUIMarineBuyMenu.kExoSlotData = {
    [kExoModuleSlots.RightArm] = {
        label      = "Secondary Weapon", --label = "EXO_MODULESLOT_RIGHT_ARM",
        xp         = 0.0,
        yp         = 0.16,
        anchorX    = GUIItem.Left,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeModuleButton(moduleType, moduleTypeData, offsetX, offsetY, kExoModuleSlots.RightArm, false)
        end,
    },
    [kExoModuleSlots.LeftArm]  = {
        label      = "Primary Weapon", --label = "EXO_MODULESLOT_LEFT_ARM",
        xp         = 1.00,
        yp         = 0.16,
        anchorX    = GUIItem.Right,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeModuleButton(moduleType, moduleTypeData, offsetX, offsetY, kExoModuleSlots.LeftArm, false)
        end,
    },
    
    [kExoModuleSlots.Utility]  = {
        label      = "Core Module", --label = "EXO_MODULESLOT_UTILITY",
        xp         = 0.0,
        yp         = 0.65,
        anchorX    = GUIItem.Left,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeModuleButton(moduleType, moduleTypeData, offsetX, offsetY, kExoModuleSlots.Utility, true)
        end,
    },
    [kExoModuleSlots.Ability]  = {
        label      = "Squad Support", --label = "EXO_MODULESLOT_ABILITY",
        xp         = 0.0,
        yp         = 0.85,
        anchorX    = GUIItem.Left,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeModuleButton(moduleType, moduleTypeData, offsetX, offsetY, kExoModuleSlots.Ability, true)
        end,
    },
}

local orig_GUIMarineBuyMenu_SetHostStructure = GUIMarineBuyMenu.SetHostStructure
function GUIMarineBuyMenu:SetHostStructure(hostStructure)
    orig_GUIMarineBuyMenu_SetHostStructure(self, hostStructure)
    if hostStructure:isa("PrototypeLab") then
        self:_InitializeExoModularButtons()
        self:_RefreshExoModularButtons()
    end
end

function GUIMarineBuyMenu:_InitializeExoModularButtons()
    self.activeExoConfig = nil
    local player = Client.GetLocalPlayer()
    if player and player:isa("Exo") then
        self.activeExoConfig = ModularExo_ConvertNetMessageToConfig(player)
        -- isValid, badReason, resourceCost
        local _, _, resourceCost = ModularExo_GetIsConfigValid(self.activeExoConfig)
        self.activeExoConfigResCost = resourceCost
        self.exoConfig = self.activeExoConfig
    else
        self.activeExoConfig = {}
        self.activeExoConfigResCost = 0
        self.exoConfig = {
            [kExoModuleSlots.RightArm] = kExoModuleTypes.Minigun,
            [kExoModuleSlots.LeftArm]  = kExoModuleTypes.Claw,
            [kExoModuleSlots.Utility]  = kExoModuleTypes.None,
            [kExoModuleSlots.Ability]  = kExoModuleTypes.None,
        }
    end
    
    self.modularExoConfigActive = false
    self.modularExoGraphicItemsToDestroyList = {}
    self.modularExoModuleButtonList = {}
    
    local kFontSize = 40
    -------UPGRADE/BUY Button ---
    local kButtonWidth = 220
    local bPadding = 0
    self.modularExoBuyButtonBackground = self:CreateAnimatedGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, self.modularExoBuyButtonBackground)
    self.modularExoBuyButtonBackground:SetIsScaling(false)
    
    self.modularExoBuyButtonBackground:SetSize(Vector(kModuleButtonSize.x + bPadding * 2, kModuleButtonSize.y + bPadding * 2, 0))
    self.modularExoBuyButtonBackground:SetPosition(Vector(kConfigAreaWidth - kButtonWidth, 0.86 * kConfigAreaHeight, 0))
    self.modularExoBuyButtonBackground:SetTexture(kButtonTexture)
    self.modularExoBuyButtonBackground:SetColor(kSlotPanelBackgroundColor)
    self.modularExoBuyButtonBackground:SetOptionFlag(GUIItem.CorrectScaling)
    self.rightSideRoot:AddChild(self.modularExoBuyButtonBackground)
    
    self.modularExoBuyButton = self:CreateAnimatedGraphicItem()
    self.modularExoBuyButton:SetIsScaling(false)
    self.modularExoBuyButton:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.modularExoBuyButton:SetSize(kModuleButtonSize)
    self.modularExoBuyButton:SetPosition(Vector(bPadding, bPadding, 0))
    self.modularExoBuyButton:SetTexture(kMenuSelectionTexture)
    self.modularExoBuyButton:SetLayer(kGUILayerMarineBuyMenu)
    self.modularExoBuyButton:SetOptionFlag(GUIItem.CorrectScaling)
    self.modularExoBuyButtonBackground:AddChild(self.modularExoBuyButton)
    
    self.modularExoBuyButtonText = self:CreateAnimatedTextItem()
    self.modularExoBuyButtonText:SetIsScaling(false)
    self.modularExoBuyButtonText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.modularExoBuyButtonText:SetPosition(Vector(0, 0, 0))
    self.modularExoBuyButtonText:SetFontName(kFont)
    self.modularExoBuyButtonText:SetTextAlignmentX(GUIItem.Align_Center)
    self.modularExoBuyButtonText:SetTextAlignmentY(GUIItem.Align_Center)
    self.modularExoBuyButtonText:SetText(Locale.ResolveString("BUY"))
    self.modularExoBuyButtonText:SetFontIsBold(true)
    self.modularExoBuyButtonText:SetColor(kCloseButtonColor)
    self.modularExoBuyButtonText:SetOptionFlag(GUIItem.CorrectScaling)
    GUIMakeFontScale(self.modularExoBuyButtonText, "kAgencyFB", kFontSize + 3)
    self.modularExoBuyButton:AddChild(self.modularExoBuyButtonText)
    
    self.modularExoCostText = self:CreateAnimatedTextItem()
    self.modularExoCostText:SetIsScaling(false)
    self.modularExoCostText:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.modularExoCostText:SetPosition(Vector(kResourceIconWidth + 10, 0, 0))
    self.modularExoCostText:SetFontName(kFont)
    self.modularExoCostText:SetTextAlignmentX(GUIItem.Align_Min)
    self.modularExoCostText:SetTextAlignmentY(GUIItem.Align_Center)
    self.modularExoCostText:SetText("0")
    self.modularExoCostText:SetFontIsBold(true)
    self.modularExoCostText:SetColor(kTextColor)
    self.modularExoCostText:SetOptionFlag(GUIItem.CorrectScaling)
    GUIMakeFontScale(self.modularExoCostText, "kAgencyFB", kFontSize)
    self.modularExoBuyButton:AddChild(self.modularExoCostText)
    
    self.modularExoCostIcon = self:CreateAnimatedGraphicItem()
    self.modularExoCostIcon:SetIsScaling(false)
    self.modularExoCostIcon:SetSize(Vector(kResourceIconWidth * 0.7, kResourceIconHeight * 0.7, 0))
    self.modularExoCostIcon:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.modularExoCostIcon:SetPosition(Vector(10, -kResourceIconHeight * 0.4, 0))
    self.modularExoCostIcon:SetTexture(kResourceIconTexture)
    self.modularExoCostIcon:SetColor(kTextColor)
    self.modularExoCostIcon:SetOptionFlag(GUIItem.CorrectScaling)
    self.modularExoBuyButton:AddChild(self.modularExoCostIcon)
    
    
    --BUY/UPGRADE BUTTON ENDS HERE
    
    for slotType, slotGUIDetails in pairs(GUIMarineBuyMenu.kExoSlotData) do
        local panelBackground = self:CreateAnimatedGraphicItem()
        table.insert(self.modularExoGraphicItemsToDestroyList, panelBackground)
        panelBackground:SetIsScaling(false)
        panelBackground:SetTexture(kButtonTexture)
        panelBackground:SetColor(kSlotPanelBackgroundColor)
        panelBackground:SetOptionFlag(GUIItem.CorrectScaling)
        local panelSize
        
        local slotTypeData = kExoModuleSlotsData[slotType]
        
        local panelTitle = self:CreateAnimatedTextItem()
        panelTitle:SetIsScaling(false)
        panelTitle:SetFontName(kFont)
        panelTitle:SetFontIsBold(true)
        panelTitle:SetPosition(Vector(-1, -50, 0))
        panelTitle:SetAnchor(GUIItem.Left, GUIItem.Top)
        panelTitle:SetTextAlignmentX(GUIItem.Align_Min)
        panelTitle:SetTextAlignmentY(GUIItem.Align_Min)
        panelTitle:SetColor(kTextColor)
        panelTitle:SetOptionFlag(GUIItem.CorrectScaling)
        panelTitle:SetText(slotGUIDetails.label)--(Locale.ResolveString("BUY"))
        GUIMakeFontScale(panelTitle, "kAgencyFB", kFontSize)
        panelBackground:AddChild(panelTitle)
        local padding = 5
        local startOffsetX = padding
        local startOffsetY = padding
        local offsetX, offsetY = startOffsetX, startOffsetY
        -- moduleType, moduleTypeName
        for moduleType, _ in ipairs(kExoModuleTypes) do
            local moduleTypeData = kExoModuleTypesData[moduleType]
            local isSameType = (moduleTypeData and moduleTypeData.category == slotTypeData.category)
            if moduleType == kExoModuleTypes.None and not slotTypeData.required then
                isSameType = true
                moduleTypeData = {}
            end
            -- excludes claw on secondary weapon (right) slot
            if isSameType and slotTypeData.category == kExoModuleCategories.Weapon and moduleTypeData.leftArmOnly and kExoModuleSlots.RightArm == slotType then
                isSameType = false
            end
            if isSameType then
                local buttonGraphic, newOffsetX, newOffsetY = slotGUIDetails.makeButton(self, moduleType, moduleTypeData, offsetX, offsetY)
                offsetX, offsetY = newOffsetX, newOffsetY
                panelBackground:AddChild(buttonGraphic)
            end
        end
        if offsetX == startOffsetX then
            offsetX = offsetX + kModuleButtonSize.x
        end
        
        if offsetY == startOffsetY then
            offsetY = offsetY + kModuleButtonSize.y
        end
        panelSize = Vector(offsetX + padding, offsetY + padding, 0)
        
        panelBackground:SetSize(panelSize)
        local panelX = slotGUIDetails.xp * kConfigAreaWidth
        local panelY = slotGUIDetails.yp * kConfigAreaHeight
        if slotGUIDetails.anchorX == GUIItem.Right then
            panelX = panelX - panelSize.x
        end
        
        panelBackground:SetPosition(Vector(panelX, panelY, 0))
        self.rightSideRoot:AddChild(panelBackground)
    end
end

function GUIMarineBuyMenu:MakeModuleButton(moduleType, moduleTypeData, offsetX, offsetY, slotType, vertical)
    local moduleTypeGUIDetails = GUIMarineBuyMenu.kExoModuleData[moduleType]
    local kFontSize = 40
    local buttonGraphic = self:CreateAnimatedGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, buttonGraphic)
    buttonGraphic:SetIsScaling(false)
    buttonGraphic:SetSize(kModuleButtonSize)
    buttonGraphic:SetAnchor(GUIItem.Left, GUIItem.Top)
    buttonGraphic:SetPosition(Vector(offsetX, offsetY, 0))
    buttonGraphic:SetTexture(kMenuSelectionTexture)
    buttonGraphic:SetOptionFlag(GUIItem.CorrectScaling)
    
    local contentPaddingX = 15
    local contentPaddingY = 5.5
    local label = self:CreateAnimatedTextItem()
    label:SetIsScaling(false)
    label:SetFontName(kFont)
    label:SetPosition(Vector(contentPaddingX, contentPaddingY, 0))
    label:SetAnchor(GUIItem.Left, GUIItem.Top)
    label:SetTextAlignmentX(GUIItem.Align_Min)
    label:SetTextAlignmentY(GUIItem.Align_Min)
    label:SetColor(kTextColor)
    label:SetText(tostring(moduleTypeGUIDetails.label))
    label:SetOptionFlag(GUIItem.CorrectScaling)
    GUIMakeFontScale(label, "kAgencyFB", kFontSize)
    buttonGraphic:AddChild(label)
    
    local resourceCost = moduleTypeData.resourceCost or 0
    
    local image = self:CreateAnimatedGraphicItem()
    image:SetIsScaling(false)
    if vertical then
        image:SetPosition(Vector(-kUtilityImageSize.x - contentPaddingX, -kUtilityImageSize.y * 0.5, 0))
        image:SetSize(kUtilityImageSize)
    else
        image:SetPosition(Vector(-kWeaponImageSize.x - contentPaddingX, -kWeaponImageSize.y * 0.5, 0))
        image:SetSize(kWeaponImageSize)
    end
    image:SetAnchor(GUIItem.Right, GUIItem.Center)
    image:SetTexture(moduleTypeGUIDetails.image)
    image:SetTexturePixelCoordinates(unpack(moduleTypeGUIDetails.imageTexCoords))
    image:SetColor(Color(1, 1, 1, 1))
    image:SetOptionFlag(GUIItem.CorrectScaling)
    buttonGraphic:AddChild(image)
    
    local icon, cost
    if resourceCost > 0 then
        cost = self:CreateAnimatedTextItem()
        cost:SetIsScaling(false)
        cost:SetPosition(Vector(contentPaddingX + kResourceIconWidth, -contentPaddingY, 0))
        cost:SetFontName(kFont)
        cost:SetAnchor(GUIItem.Left, GUIItem.Bottom)
        cost:SetTextAlignmentX(GUIItem.Align_Min)
        cost:SetTextAlignmentY(GUIItem.Align_Max)
        cost:SetColor(kTextColor)
        cost:SetText(tostring(resourceCost))--(Locale.ResolveString("BUY"))
        cost:SetOptionFlag(GUIItem.CorrectScaling)
        GUIMakeFontScale(cost, "kAgencyFB", kFontSize)
        buttonGraphic:AddChild(cost)
        
        icon = self:CreateAnimatedGraphicItem()
        icon:SetIsScaling(false)
        icon:SetPosition(Vector(kResourceIconWidth * 0.7 - 6, -(kResourceIconHeight * 0.7 + 4 + contentPaddingY), 0))
        icon:SetSize(Vector(kResourceIconWidth * 0.7, kResourceIconHeight * 0.7, 0))
        icon:SetAnchor(GUIItem.Left, GUIItem.Bottom)
        icon:SetTexture(kResourceIconTexture)
        --local iconX, iconY = GetMaterialXYOffset(kTechId.PowerSurge)
        --powerIcon:SetTexturePixelCoordinates(iconX*80, iconY*80, iconX*80+80, iconY*80+80)
        icon:SetColor(kTextColor)
        icon:SetOptionFlag(GUIItem.CorrectScaling)
        buttonGraphic:AddChild(icon)
    end
    
    if vertical then
        offsetX = offsetX + kModuleButtonSize.x
    else
        offsetY = offsetY + kModuleButtonSize.y
    end
    
    table.insert(self.modularExoModuleButtonList, {
        slotType        = slotType,
        moduleType      = moduleType,
        buttonGraphic   = buttonGraphic,
        weaponLabel     = label,
        weaponImage     = image,
        costLabel       = cost,
        costIcon        = icon,
        thingsToRecolor = { label, image, cost, icon },
    })
    return buttonGraphic, offsetX, offsetY
end

local orig_GUIMarineBuyMenu_Update = GUIMarineBuyMenu.Update
function GUIMarineBuyMenu:Update()
    orig_GUIMarineBuyMenu_Update(self)
    self:_UpdateExoModularButtons()
end

local function GetIsMouseOver(self, overItem)
    
    local mouseX, mouseY = Client.GetCursorPosScreen()
    local mouseOver = GUIItemContainsPoint(overItem, mouseX, mouseY, true)
    if mouseOver and not self.mouseOverStates[overItem] then
        MarineBuy_OnMouseOver()
    end
    
    local changed = self.mouseOverStates[overItem] ~= mouseOver
    self.mouseOverStates[overItem] = mouseOver
    return mouseOver, changed

end

function GUIMarineBuyMenu:_UpdateExoModularButtons(deltaTime)
    if self.hoveringExo then
        
        self:_RefreshExoModularButtons()
        if not MarineBuy_IsResearched(kTechId.DualMinigunExosuit) or PlayerUI_GetPlayerResources() < self.exoConfigResourceCost - self.activeExoConfigResCost then
            self.modularExoBuyButton:SetColor(Color(1, 0, 0, 1))
            
            self.modularExoBuyButtonText:SetColor(Color(0.5, 0.5, 0.5, 1))
            self.modularExoCostText:SetColor(kCannotBuyColor)
            self.modularExoCostIcon:SetColor(kCannotBuyColor)
        else
            if GetIsMouseOver(self, self.modularExoBuyButton) then
                self.modularExoBuyButton:SetColor(kCloseButtonColorHover)
                self.modularExoCostText:SetColor(kCloseButtonColorHover)
                self.modularExoCostIcon:SetColor(kCloseButtonColorHover)
                self.modularExoBuyButtonText:SetColor(kCloseButtonColorHover)
            else
                self.modularExoBuyButton:SetColor(kCloseButtonColor)
                self.modularExoCostText:SetColor(kCloseButtonColor)
                self.modularExoCostIcon:SetColor(kCloseButtonColor)
                self.modularExoBuyButtonText:SetColor(kCloseButtonColor)
            end
            
            --self.modularExoBuyButtonText:SetColor(kCloseButtonColor)
            --self.modularExoCostText:SetColor(kTextColor)
            --self.modularExoCostIcon:SetColor(kTextColor)
        end
        for buttonI, buttonData in ipairs(self.modularExoModuleButtonList) do
            if GetIsMouseOver(self, buttonData.buttonGraphic) then
                if buttonData.state == "enabled" then
                    buttonData.buttonGraphic:SetColor(Color(0, 0.7, 1, 1))
                end
            else
                buttonData.buttonGraphic:SetColor(buttonData.col)
            end
        end
    end
end

local oldSetDetails = GUIMarineBuyMenu._SetDetailsSectionTechId
function GUIMarineBuyMenu:_SetDetailsSectionTechId(techId, techCost)
    
    oldSetDetails(self, techId, techCost)
    
    if techId == kTechId.DualMinigunExosuit then
        self.itemTitle:SetIsVisible(false)
        self.costText:SetIsVisible(false)
        self.itemDescription:SetIsVisible(false)
        self.bigPicture:SetPosition(Vector(285, 100, 0))
        self.bigPicture:SetAnchor(GUIItem.Top, GUIItem.Left)
        
        self.currentMoneyText:SetIsVisible(false)
        self.currentMoneyTextIcon:SetIsVisible(false)
        self.rangeBar:SetIsVisible(false)
        self.vsStructuresBar:SetIsVisible(false)
        self.vsLifeformBar:SetIsVisible(false)
        
        self.rangeText:SetIsVisible(false)
        self.vsStructuresText:SetIsVisible(false)
        self.vsLifeformsText:SetIsVisible(false)
    else
        self.itemTitle:SetIsVisible(true)
        self.costText:SetIsVisible(true)
        self.itemDescription:SetIsVisible(true)
        self.bigPicture:SetIsVisible(true)
        self.currentMoneyText:SetIsVisible(true)
        self.currentMoneyTextIcon:SetIsVisible(true)
    
    end

end

function GUIMarineBuyMenu:_RefreshExoModularButtons()
    local _, _, resourceCost, _, _ = ModularExo_GetIsConfigValid(self.exoConfig)
    resourceCost = resourceCost or 0
    self.exoConfigResourceCost = resourceCost
    self.modularExoCostText:SetText(tostring(resourceCost - self.activeExoConfigResCost))
    
    for buttonI, buttonData in ipairs(self.modularExoModuleButtonList) do
        local current = self.exoConfig[buttonData.slotType]
        local col = nil
        local canAfford = true
        if current == buttonData.moduleType then
            if PlayerUI_GetPlayerResources() < self.exoConfigResourceCost - self.activeExoConfigResCost then
                --buttonData.state = "disabled"
                -- buttonData.buttonGraphic:SetColor(kDisabledColor)
                col = kDisabledColor
                --canAfford = false
            else
                buttonData.state = "selected"
                buttonData.buttonGraphic:SetColor(kEnabledColor)
                col = kEnabledColor
            end
        else
            self.exoConfig[buttonData.slotType] = buttonData.moduleType
            local isValid, badReason, _, _, _ = ModularExo_GetIsConfigValid(self.exoConfig)
            
            if buttonData.slotType == kExoModuleSlots.RightArm and badReason == "bad model left" then
                isValid = true
                buttonData.forceLeftToClaw = true
            else
                buttonData.forceLeftToClaw = false
            end
            if isValid then
                buttonData.state = "enabled"
                buttonData.buttonGraphic:SetColor(kDisabledColor)
                col = kDisabledColor
            else
                buttonData.state = "disabled"
                buttonData.buttonGraphic:SetColor(kDisabledColor)
                col = kDisabledColor
                if badReason == "not enough power" then
                    canAfford = false
                end
            end
            if not isValid and (badReason == "bad model right" or badReason == "bad model left") then
                col = Color(0.2, 0.2, 0.2, 0.4)
                buttonData.weaponImage:SetColor(Color(0.2, 0.2, 0.2, 0.4))
            elseif buttonData.weaponImage ~= nil then
                buttonData.weaponImage:SetColor(Color(1, 1, 1, 1))
            end
            self.exoConfig[buttonData.slotType] = current
        end
        buttonData.col = col
        for thingI, thing in ipairs(buttonData.thingsToRecolor) do
            thing:SetColor(col)
        end
        if not canAfford then
            if buttonData.costLabel then
                buttonData.costLabel:SetColor(kCannotBuyColor)
            end
            if buttonData.costIcon then
                buttonData.costIcon:SetColor(kCannotBuyColor)
            end
        end
    end
end

local function HandleItemClicked(self)
    
    if self.hoveredBuyButton then
        
        local item = self.hoveredBuyButton
        
        local researched = self:_GetResearchInfo(item.TechID)
        local itemCost = MarineBuy_GetCosts(item.TechID)
        local canAfford = PlayerUI_GetPlayerResources() >= itemCost
        local hasItem = PlayerUI_GetHasItem(item.TechID)
        
        if not item.Disabled and researched and canAfford and not hasItem and item.TechID ~= kTechId.DualMinigunExosuit then
            
            MarineBuy_PurchaseItem(item.TechID)
            MarineBuy_OnClose()
            
            return true, true
        
        end
    
    end
    if self.hoveringExo then
        if GetIsMouseOver(self, self.modularExoBuyButton) and MarineBuy_IsResearched(kTechId.Exosuit) then
            Client.SendNetworkMessage("ExoModularBuy", ModularExo_ConvertConfigToNetMessage(self.exoConfig))
            MarineBuy_OnClose()
            return true, true
        end
        for buttonI, buttonData in ipairs(self.modularExoModuleButtonList) do
            if GetIsMouseOver(self, buttonData.buttonGraphic) then
                if buttonData.state == "enabled" then
                    self.exoConfig[buttonData.slotType] = buttonData.moduleType
                    if buttonData.forceToDefaultConfig then
                        self.exoConfig[kExoModuleSlots.RightArm] = kExoModuleTypes.Minigun
                        self.exoConfig[kExoModuleSlots.LeftArm] = kExoModuleTypes.Claw
                        self.exoConfig[kExoModuleSlots.Utility] = kExoModuleTypes.None
                        self.exoConfig[kExoModuleSlots.Ability] = kExoModuleTypes.None
                    end
                    if buttonData.forceLeftToClaw then
                        self.exoConfig[kExoModuleSlots.LeftArm] = kExoModuleTypes.Claw
                    end
                    self:_RefreshExoModularButtons()
                end
            end
        end
    end
    return false, false

end

local origUpdate = GUIMarineBuyMenu.Update
function GUIMarineBuyMenu:Update(deltaTime)
    origUpdate(self, deltaTime)
    
    if self.hoveredBuyButton and self.hoveredBuyButton.TechID == kTechId.DualMinigunExosuit or (self.hoveredBuyButton == nil and self.hoveringExo) then
        self.hoveringExo = true
        self.modularExoConfigActive = true
        for elementI, element in ipairs(self.modularExoGraphicItemsToDestroyList) do
            element:SetIsVisible(true)
        end
        
        return
    end
    if self.modularExoGraphicItemsToDestroyList then
        self.hoveringExo = false
        self.modularExoConfigActive = false
        for elementI, element in ipairs(self.modularExoGraphicItemsToDestroyList) do
            element:SetIsVisible(false)
        end
    end
end

function GUIMarineBuyMenu:SendKeyEvent(key, down)
    
    local closeMenu = false
    local inputHandled = false
    
    if key == InputKey.MouseButton0 and self.mousePressed ~= down then
        
        self.mousePressed = down
        
        if down then
            inputHandled, closeMenu = HandleItemClicked(self)
        end
    
    end
    
    -- No matter what, this menu consumes MouseButton0/1.
    if key == InputKey.MouseButton0 or key == InputKey.MouseButton1 then
        inputHandled = true
    end
    
    if InputKey.Escape == key and not down then
        
        closeMenu = true
        inputHandled = true
        MarineBuy_OnClose()
    
    end
    
    if closeMenu then
        MarineBuy_Close()
    end
    
    return inputHandled

end

function GUIMarineBuyMenu:CreatePrototypeLabUI()
    
    self.defaultTechId = kTechId.Jetpack
    
    self.background = self:CreateAnimatedGraphicItem()
    self.background:SetTexture(self.kPrototypeLabBackgroundTexture)
    self.background:SetSizeFromTexture()
    self.background:SetIsScaling(false)
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.background:SetHotSpot(Vector(0.5, 0.5, 0))
    self.background:SetScale(self.customScaleVector)
    self.background:SetOptionFlag(GUIItem.CorrectScaling)
    self.background:SetLayer(kGUILayerMarineBuyMenu)
    
    local buttonGroupX = 97
    local buttonGroupY = 149
    
    local buttonPositions = kWeaponGroupButtonPositions[self.kButtonGroupFrame_Unlabeled_x2]
    
    local buttonGroup = self:CreateAnimatedGraphicItem()
    buttonGroup:AddAsChildTo(self.background)
    buttonGroup:SetIsScaling(false)
    buttonGroup:SetPosition(Vector(buttonGroupX, buttonGroupY, 0))
    buttonGroup:SetTexture(self.kButtonGroupFrame_Unlabeled_x2)
    buttonGroup:SetSizeFromTexture()
    buttonGroup:SetOptionFlag(GUIItem.CorrectScaling)
    
    self:_InitializeWeaponGroup(buttonGroup, buttonPositions,
                                {
                                    kTechId.Jetpack,
                                    kTechId.DualMinigunExosuit,
                                })
    
    --local groupLabel = self:CreateAnimatedTextItem()
    --groupLabel:SetIsScaling(false)
    --groupLabel:AddAsChildTo(buttonGroup)
    --groupLabel:SetPosition(Vector(330, -1, 0))
    --groupLabel:SetAnchor(GUIItem.Left, GUIItem.Top)
    --groupLabel:SetTextAlignmentX(GUIItem.Align_Min)
    --groupLabel:SetTextAlignmentY(GUIItem.Align_Min)
    --groupLabel:SetText(Locale.ResolveString("BUYMENU_GROUPLABEL_SPECIAL"))
    --groupLabel:SetOptionFlag(GUIItem.CorrectScaling)
    --GUIMakeFontScale(groupLabel, "kAgencyFB", 24)
    
    local rightSideStartPos = Vector(580, 38, 0)
    self:_CreateRightSide(rightSideStartPos)

end

local oldGUIMarineBuyMenu_CreateRightSide = GUIMarineBuyMenu._CreateRightSide
function GUIMarineBuyMenu:_CreateRightSide(startPos)
    oldGUIMarineBuyMenu_CreateRightSide(self, startPos)
    if self.hostStructure:isa("PrototypeLab") then
        local buttonGroupX = 97
        local buttonGroupY = (149 + 373 + 20) + 150
        self.specialFrame:SetPosition(Vector(buttonGroupX, buttonGroupY, 0))
    end
end