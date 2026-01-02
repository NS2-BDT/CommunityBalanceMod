-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\GUIInventory.lua
--
-- Created by: Andreas Urwalek (andi@unknownworlds.com)
--
-- Displays the ability/weapon icons.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIInventory'

local kFontName = Fonts.kAgencyFB_Small

GUIInventory.kActiveColor = Color(1,1,1,1)
GUIInventory.kInactiveColor = Color(0.6, 0.6, 0.6, 0.6)

GUIInventory.kItemSize = Vector(96, 48, 0)
GUIInventory.kItemPadding = 20

GUIInventory.kInventoryMode = GetAdvancedOption("inventory")

local kSMGTexture = PrecacheAsset("ui/inventory_icon_smg.dds")

local function UpdateItemsGUIScale()
    GUIInventory.kBackgroundYOffset = GUIScale(-120)
end

function CreateInventoryDisplay(scriptHandle, hudLayer, frame)

    local inventoryDisplay = GUIInventory()
    inventoryDisplay.script = scriptHandle
    inventoryDisplay.hudLayer = hudLayer
    inventoryDisplay.frame = frame
    inventoryDisplay:Initialize()
    
    return inventoryDisplay

end

function GUIInventory:CreateInventoryItem(_, alienStyle)

    local item = self.script:CreateAnimatedGraphicItem()
    
    item:SetSize(GUIInventory.kItemSize)
    item:SetTexture(kInventoryIconsTexture)
    item:AddAsChildTo(self.background)
    
    local key, keyText = GUICreateButtonIcon("Weapon1", alienStyle)
    key:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    key:SetInheritsParentAlpha(true)
    keyText:SetInheritsParentAlpha(true)
    keyText:SetFontName(kFontName)
    GUIMakeFontScale(keyText)
    
    local keySize = key:GetSize()    
    key:SetPosition(Vector(keySize.x * -.5, GUIScale(8), 0))
    
    item:AddChild(key)

    item.reserveFraction = -1

    local ammoLeft = self.script:CreateAnimatedTextItem()
    item.guiItem:AddChild(ammoLeft.guiItem)
    ammoLeft:SetText("")
    ammoLeft:SetFontName(Fonts.kAgencyFB_Smaller_Bordered)
    ammoLeft:SetInheritsParentAlpha(true)
    ammoLeft:SetScale(GetScaledVector())
    ammoLeft:SetTextAlignmentX(GUIItem.Align_Max)
    ammoLeft:SetPosition(Vector(GUIInventory.kItemSize.x/2.25, -GUIInventory.kItemSize.y/2, 0))

    local ammoCenter = self.script:CreateAnimatedTextItem()
    item.guiItem:AddChild(ammoCenter.guiItem)
    ammoCenter:SetText("")
    ammoCenter:SetFontName(Fonts.kAgencyFB_Smaller_Bordered)
    ammoCenter:SetInheritsParentAlpha(true)
    ammoCenter:SetScale(GetScaledVector())
    ammoCenter:SetTextAlignmentX(GUIItem.Align_Center)
    ammoCenter:SetPosition(Vector(GUIInventory.kItemSize.x/2, -GUIInventory.kItemSize.y/2, 0))

    local ammoRight = self.script:CreateAnimatedTextItem()
    item.guiItem:AddChild(ammoRight.guiItem)
    ammoRight:SetText("")
    ammoRight:SetFontName(Fonts.kAgencyFB_Smaller_Bordered)
    ammoRight:SetInheritsParentAlpha(true)
    ammoRight:SetScale(GetScaledVector())
    ammoRight:SetTextAlignmentX(GUIItem.Align_Min)
    ammoRight:SetPosition(Vector(GUIInventory.kItemSize.x/1.75, -GUIInventory.kItemSize.y/2, 0))

    local result =
    {
        Graphic = item,
        KeyText = keyText,
        AmmoDisplayLeft = ammoLeft,
        AmmoDisplayCenter = ammoCenter,
        AmmoDisplayRight = ammoRight
    }
    
    table.insert(self.inventoryIcons, result)
    
    return result

end

function GUIInventory:LocalAdjustSlot(index, hudSlot, techId, isActive, resetAnimations, alienStyle)

    local inventoryItem

    if self.inventoryIcons[index] then
        inventoryItem = self.inventoryIcons[index]
    else
        inventoryItem = self:CreateInventoryItem(index, alienStyle)
        inventoryItem.Graphic:Pause(2, "ANIM_INVENTORY_ITEM_PAUSE", AnimateLinear, function(_, item) item:FadeOut(0.5, "ANIM_INVENTORY_ITEM") end )
    end
    
    inventoryItem.KeyText:SetText(BindingsUI_GetInputValue("Weapon" .. hudSlot))
    inventoryItem.Graphic:SetUniformScale(self.scale)
    inventoryItem.Graphic:SetTexturePixelCoordinates(GetTexCoordsForTechId(techId))
    inventoryItem.Graphic:SetPosition(Vector( (GUIInventory.kItemPadding + GUIInventory.kItemSize.x) * (index-1) , 0, 0) )
    
    if resetAnimations then
        inventoryItem.Graphic:Pause(2, "ANIM_INVENTORY_ITEM_PAUSE", AnimateLinear, function(_, item) item:FadeOut(0.5, "ANIM_INVENTORY_ITEM") end )
    end
    
    if inventoryItem.Graphic:GetHasAnimation("ANIM_INVENTORY_ITEM_PAUSE") then
        inventoryItem.Graphic:SetColor(ConditionalValue(isActive, GUIInventory.kActiveColor, GUIInventory.kInactiveColor))
    end

end

function GUIInventory:Initialize()

    self.scale = 1
    
    UpdateItemsGUIScale()
    
    self.lastPersonalResources = 0
    
    self.background = GetGUIManager():CreateGraphicItem()
    self.background:SetColor(Color(0,0,0,0))
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.frame:AddChild(self.background)
    
    self.inventoryIcons = {}
    
    -- Force it to display always
    self.forceAnimationReset = false

end

function GUIInventory:Reset(scale)

    self.scale = scale
    UpdateItemsGUIScale()
    self.background:SetPosition(Vector(0, GUIInventory.kBackgroundYOffset, 0) * self.scale)

end

function GUIInventory:SetIsVisible(visible)
    self.background:SetIsVisible(visible)
end

-- Call this with true to force inventory to stay on screen instead of fading out
function GUIInventory:SetForceAnimationReset(state)
    self.forceAnimationReset = state
end

function GUIInventory:Update(_, parameters)

    PROFILE("GUIInventory:Update")


    if GUIInventory.kInventoryMode == 1 then -- Inventory is hidden

        self:SetIsVisible(false)

    else -- Update inventory as normal. GUIInventory is set to be visible from the outside depending on exo or not.

        local activeWeaponTechId, inventoryTechIds = parameters[1], parameters[2]

        if #self.inventoryIcons > #inventoryTechIds then

            self.inventoryIcons[#self.inventoryIcons].Graphic:Destroy()
            table.remove(self.inventoryIcons, #self.inventoryIcons)

        end

        local resetAnimations = false
        if activeWeaponTechId ~= self.lastActiveWeaponTechId and gTechIdPosition and gTechIdPosition[activeWeaponTechId] then

            self.lastActiveWeaponTechId = activeWeaponTechId
            resetAnimations = true

        end

        if self.forceAnimationReset then
            resetAnimations = true
        end

        local numItems = #inventoryTechIds
        self.background:SetPosition(Vector(
                self.scale * -0.5 * (numItems*GUIInventory.kItemSize.x + (numItems-1)*GUIInventory.kItemPadding),
                GUIInventory.kBackgroundYOffset,
                0))

        local alienStyle = PlayerUI_GetTeamType() == kAlienTeamType

        local player = Client.GetLocalPlayer()
        local isMarine = player and player:isa("Marine")

        self:SetForceAnimationReset(GUIInventory.kInventoryMode > 2)

        for index, inventoryItem in ipairs(inventoryTechIds) do

            self:LocalAdjustSlot(index, inventoryItem.HUDSlot, inventoryItem.TechId, inventoryItem.TechId == activeWeaponTechId, resetAnimations, alienStyle)

            -- Update ammo displays
            if isMarine and (GUIInventory.kInventoryMode == 2 or GUIInventory.kInventoryMode == 4) then

                local weapon = player:GetWeaponInHUDSlot(inventoryItem.HUDSlot)
                if weapon and self.inventoryIcons[index] then

                    local ammo = GetWeaponAmmoString(weapon)
                    local reserveAmmo = GetWeaponReserveAmmoString(weapon)
                    local fraction = GetWeaponAmmoFraction(weapon)
                    local reserveFraction = GetWeaponReserveAmmoFraction(weapon)

                    if self.inventoryIcons[index].reserveFraction ~= reserveFraction then
                        self.inventoryIcons[index].reserveFraction = reserveFraction
                        self.inventoryIcons[index].Graphic:Pause(2, "ANIM_INVENTORY_ITEM_PAUSE", AnimateLinear, function(_, item) item:FadeOut(0.5, "ANIM_INVENTORY_ITEM") end )
                    end

                    if reserveFraction ~= -1 then
                        self.inventoryIcons[index].AmmoDisplayLeft:SetIsVisible(true)
                        self.inventoryIcons[index].AmmoDisplayCenter:SetIsVisible(true)
                        self.inventoryIcons[index].AmmoDisplayCenter:SetColor(kWhite)
                        self.inventoryIcons[index].AmmoDisplayRight:SetIsVisible(true)

                        if fraction > 0.4 then
                            self.inventoryIcons[index].AmmoDisplayLeft:SetColor(kWhite)
                        else
                            self.inventoryIcons[index].AmmoDisplayLeft:SetColor(kRed)
                        end

                        if reserveFraction > 0.4 then
                            self.inventoryIcons[index].AmmoDisplayRight:SetColor(kWhite)
                        else
                            self.inventoryIcons[index].AmmoDisplayRight:SetColor(kRed)
                        end

                        self.inventoryIcons[index].AmmoDisplayLeft:SetText(ammo)
                        self.inventoryIcons[index].AmmoDisplayCenter:SetText("/")
                        self.inventoryIcons[index].AmmoDisplayRight:SetText(reserveAmmo)
                    else
                        self.inventoryIcons[index].AmmoDisplayLeft:SetIsVisible(false)
                        self.inventoryIcons[index].AmmoDisplayCenter:SetIsVisible(true)
                        self.inventoryIcons[index].AmmoDisplayCenter:SetColor(kWhite)
                        self.inventoryIcons[index].AmmoDisplayRight:SetIsVisible(false)

                        self.inventoryIcons[index].AmmoDisplayCenter:SetText(ammo)
                    end
                else
                    self.inventoryIcons[index].AmmoDisplayLeft:SetIsVisible(false)
                    self.inventoryIcons[index].AmmoDisplayCenter:SetIsVisible(false)
                    self.inventoryIcons[index].AmmoDisplayRight:SetIsVisible(false)
                end

            end
        end
    end
end

function GUIInventory:Destroy()

    if self.background then
        GUI.DestroyItem(self.background)
        self.background = nil
    end

end