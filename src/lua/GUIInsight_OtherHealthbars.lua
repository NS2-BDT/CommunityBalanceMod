-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\GUIInsight_OtherHealthbars.lua
--
-- Created by: Jon 'Huze' Hughes (jon@jhuze.com)
--
-- Commander: Displays structure/AI healthbars
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIInsight_OtherHealthbars' (GUIScript)

local kOtherHealthDrainRate = 0.1 --Percent per ???

local kOtherHealthBarTexture = "ui/healthbarsmall.dds"
local kOtherHealthBarTextureSize = Vector(64, 6, 0)
local kHealthDrainColor = Color(1, 0, 0, 1)
local kOtherTypes = {
    "CommandStructure",
    "ResourceTower",
    -- marine
    "Armory",
    "ArmsLab",
    "Observatory",
    "PhaseGate",
    "RoboticsFactory",
    "PowerPoint",
    "PrototypeLab",
    "PowerPack",
    "Sentry",
    "SentryBattery",
    "InfantryPortal",
    "MAC",
    "ARC",
    "Flamethrower",
    "GrenadeLauncher",
    "HeavyMachineGun",
    "Shotgun",
    "Submachinegun",
    "LayMines",
    -- alien
    "Whip",
    "Crag",
    "Shade",
    "Shift",
    "Hydra",
    "Shell",
    "Veil",
    "Spur",
    "Drifter",
    "TunnelEntrance"
}

local kAmmoColors = GUIInsight_PlayerHealthbars.kAmmoColors or {}

function GUIInsight_OtherHealthbars:Initialize()

    self.updateInterval = 0
    
    self.isVisible = true
	
	self.kOtherHealthBarSize = GUIScale(Vector(64, 6, 0))
	
    self.otherList = {}
    self.otherIds = {}
    self.reuseItems = {}

end

function GUIInsight_OtherHealthbars:Uninitialize()

    -- All healthbars
    for _, id in ipairs(self.otherIds) do
        local other = self.otherList[id]
        GUI.DestroyItem(other.Background)
    end

    self.otherIds = nil
    self.otherList = nil

    -- Reuse items
    for _, background in ipairs(self.reuseItems) do
        GUI.DestroyItem(background["Background"])
    end

    self.reuseItems = nil

end

function GUIInsight_OtherHealthbars:OnResolutionChanged()

    self:Uninitialize()
    self.kOtherHealthBarSize = GUIScale(Vector(64, 6, 0))
    self:Initialize()

end

function GUIInsight_OtherHealthbars:SetisVisible(bool)

    self.isVisible = bool

end

function GUIInsight_OtherHealthbars:Update(deltaTime)

    PROFILE("GUIInsight_OtherHealthbars:Update")

    local others
    for i = 1, #kOtherTypes do

        others = Shared.GetEntitiesWithClassname(kOtherTypes[i])
        -- Add new and Update all units
        
        for _, other in ientitylist(others) do

            local otherIndex = other:GetId()
            local relevant = other:GetIsVisible() and self.isVisible and other:GetIsAlive()

            if relevant then
                if other:isa("PowerPoint") then
                    relevant = other:GetHealth() > 0
                elseif other:isa("Weapon") then
                    relevant = other:GetWeaponWorldState() and other:GetExpireTime() > 0
                end
            end

            if relevant then

                local health = other:GetHealth() + other:GetArmor() * kHealthPointsPerArmor
                local maxHealth = other:GetMaxHealth() + other:GetMaxArmor() * kHealthPointsPerArmor
                local healthFraction = health / maxHealth

                if other:isa("Weapon") then
                    healthFraction = math.min(healthFraction, other:GetExpireTimeFraction()) -- display expire time as hp
                end

                -- Get/Create Healthbar
                local otherGUI
                if not self.otherList[otherIndex] then -- Add new GUI for new units
                
                    otherGUI = self:CreateOtherGUIItem()
                    otherGUI.StoredValues.HealthFraction = healthFraction
                    table.insert(self.otherIds, otherIndex)
                    table.insert(self.otherList, otherIndex, otherGUI)
                    
                else
                
                    otherGUI = self.otherList[otherIndex]
                    
                end
                
                self.otherList[otherIndex].Visited = true
                
                local barScale = maxHealth/2400 -- Based off ARC health
                local backgroundSize = math.max(self.kOtherHealthBarSize.x, barScale * self.kOtherHealthBarSize.x)
                local kHealthbarOffset = Vector(-backgroundSize/2, -self.kOtherHealthBarSize.y - GUIScale(8), 0)

                -- Calculate Health Bar Screen position
                local _, max = other:GetModelExtents()
                local nameTagWorldPosition = other:GetOrigin() + Vector(0, max.y, 0)
                local nameTagInScreenspace = Client.WorldToScreen(nameTagWorldPosition) + kHealthbarOffset

                local color = kAmmoColors[other.kMapName] or ConditionalValue(other:GetTeamType() == kAlienTeamType, kRedColor, kBlueColor)
                otherGUI.Background:SetIsVisible(true)

                -- Set Info

                -- background
                local background = otherGUI.Background
                background:SetPosition(nameTagInScreenspace)

                background:SetSize(Vector(backgroundSize,self.kOtherHealthBarSize.y, 0))

                -- healthbar
                local healthBar = otherGUI.HealthBar
                local healthBarSize =  healthFraction * backgroundSize - GUIScale(2)
                local healthBarTextureSize = healthFraction * kOtherHealthBarTextureSize.x
                healthBar:SetTexturePixelCoordinates(0, 0, healthBarTextureSize, kOtherHealthBarTextureSize.y)
                healthBar:SetSize(Vector(healthBarSize, self.kOtherHealthBarSize.y, 0))
                healthBar:SetColor(color)

                -- health change bar
                local healthChangeBar = otherGUI.HealthChangeBar
                local previousHealthFraction = otherGUI.StoredValues.HealthFraction
                if previousHealthFraction > healthFraction then

                    healthChangeBar:SetIsVisible(true)
                    local changeBarSize = (previousHealthFraction - healthFraction) * backgroundSize
                    local changeBarTextureSize = (previousHealthFraction - healthFraction) * kOtherHealthBarTextureSize.x
                    healthChangeBar:SetTexturePixelCoordinates(healthBarTextureSize, 0, healthBarTextureSize + changeBarTextureSize, kOtherHealthBarTextureSize.y)
                    healthChangeBar:SetSize(Vector(changeBarSize, self.kOtherHealthBarSize.y, 0))
                    healthChangeBar:SetPosition(Vector(healthBarSize, 0, 0))
                    otherGUI.StoredValues.HealthFraction = math.max(healthFraction, previousHealthFraction - (deltaTime * kOtherHealthDrainRate))

                else

                    healthChangeBar:SetIsVisible(false)
                    otherGUI.StoredValues.HealthFraction = healthFraction

                end

                -- location text
                if other.GetDestinationLocationName then
                    otherGUI.Location:SetIsVisible(true)
                    otherGUI.Location:SetText(other:GetDestinationLocationName() or "")
                    otherGUI.Location:SetColor(color)
                    otherGUI.Location:SetPosition(Vector(backgroundSize/2, 0, 0))
                else
                    otherGUI.Location:SetIsVisible(false)
                end
            end
        end
    end

    -- Slay any Others that were not visited during the update.
    -- dragonglass lol
    for i, id in ipairs(self.otherIds) do
        local other = self.otherList[id]
        if not other.Visited then
            other.Background:SetIsVisible(false)
            table.insert(self.reuseItems, other)
            self.otherList[id] = nil
            table.remove(self.otherIds, i)
        end
        other.Visited = false
    end

end

function GUIInsight_OtherHealthbars:CreateOtherGUIItem()

    -- Reuse an existing healthbar item if there is one.
    if #self.reuseItems > 0 then
        local returnbackground = table.remove(self.reuseItems, 1)
        return returnbackground
    end

    local background = GUIManager:CreateGraphicItem()
    background:SetLayer(kGUILayerPlayerNameTags-1)
    background:SetColor(Color(0,0,0,0.75))

    local otherHealthBar = GUIManager:CreateGraphicItem()
    otherHealthBar:SetAnchor(GUIItem.Left, GUIItem.Top)
    otherHealthBar:SetTexture(kOtherHealthBarTexture)
    otherHealthBar:SetPosition(Vector(GUIScale(1),0,0))
    background:AddChild(otherHealthBar)

    local otherHealthChangeBar = GUIManager:CreateGraphicItem()
    otherHealthChangeBar:SetAnchor(GUIItem.Left, GUIItem.Top)
    otherHealthChangeBar:SetTexture(kOtherHealthBarTexture)
    otherHealthChangeBar:SetColor(kHealthDrainColor)
    otherHealthChangeBar:SetIsVisible(false)
    background:AddChild(otherHealthChangeBar)

    local locationItem = GUIManager:CreateTextItem()
    locationItem:SetFontName(Fonts.kInsight)
    locationItem:SetScale(GUIScale(Vector(1,1,1)) * 0.8)
    locationItem:SetTextAlignmentX(GUIItem.Align_Center)
    locationItem:SetTextAlignmentY(GUIItem.Align_Max)
    background:AddChild(locationItem)

    return { Background = background, HealthBar = otherHealthBar, HealthChangeBar = otherHealthChangeBar,
             Location = locationItem, StoredValues = {HealthFraction = -1} }

end