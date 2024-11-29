-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\GUIExoHUD.lua
--
-- Created by: Brian Cronin (brianc@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIAnimatedScript.lua")

local kSheet1 = PrecacheAsset("ui/exosuit_HUD1.dds")
PrecacheAsset("ui/exosuit_HUD2.dds")
PrecacheAsset("ui/exosuit_HUD3.dds")
local kSheet4 = PrecacheAsset("ui/exosuit_HUD4.dds")
local kCrosshair = PrecacheAsset("ui/exo_crosshair.dds")

local kTargetingReticuleCoords = { 185, 0, 354, 184 }

local kStaticRingCoords = { 0, 490, 800, 1000 }

local kInfoBarRightCoords = { 354, 184, 800, 368 }
local kInfoBarLeftCoords = { 354, 0, 800, 184 }

local kInnerRingCoords = { 0, 316, 330, 646 }

local kOuterRingCoords = { 0, 0, 800, 490 }

local kCrosshairCoords = { 495, 403, 639, 547 }

local kTrackEntityDistance = 30

local function CoordsToSize(coords)
    return GUIScale(Vector(coords[3] - coords[1], coords[4] - coords[2], 0))
end

class 'GUIExoHUD' (GUIAnimatedScript)

function GUIExoHUD:Initialize()

    GUIAnimatedScript.Initialize(self, 0)

    self.updateInterval = 0

    local center = Vector(Client.GetScreenWidth() / 2, Client.GetScreenHeight() / 2, 0)
    
    self.background = self:CreateAnimatedGraphicItem()
    self.background:SetSize(Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0))
    self.background:SetPosition(Vector(0, 0, 0))
    self.background:SetIsVisible(true)
    self.background:SetLayer(kGUILayerPlayerHUDBackground)
    self.background:SetColor(Color(1, 1, 1, 0))
    
    self.crosshair = GUIManager:CreateGraphicItem()
    self.crosshair:SetTexture(kCrosshair)
    self.crosshair:SetSize(GUIScale(Vector(64, 64, 0)))
    self.crosshair:SetPosition(center-GUIScale(32))
    self.crosshair:SetLayer(kGUILayerPlayerHUDForeground1)
    self.background:AddChild(self.crosshair)
    
    local leftInfoBar = GUIManager:CreateGraphicItem()
    leftInfoBar:SetTexture(kSheet1)
    leftInfoBar:SetTexturePixelCoordinates(GUIUnpackCoords(kInfoBarLeftCoords))
    local size = CoordsToSize(kInfoBarLeftCoords)
    leftInfoBar:SetSize(size)
    leftInfoBar:SetPosition(Vector(center.x - size.x, 0, 0))
    leftInfoBar:SetLayer(kGUILayerPlayerHUDForeground1)
    self.background:AddChild(leftInfoBar)
    
    local rightInfoBar = GUIManager:CreateGraphicItem()
    rightInfoBar:SetTexture(kSheet1)
    rightInfoBar:SetTexturePixelCoordinates(GUIUnpackCoords(kInfoBarRightCoords))
    size = CoordsToSize(kInfoBarRightCoords)
    rightInfoBar:SetSize(size)
    rightInfoBar:SetPosition(Vector(center.x, 0, 0))
    rightInfoBar:SetLayer(kGUILayerPlayerHUDForeground1)
    self.background:AddChild(rightInfoBar)
    
    self.leftInfoBar = leftInfoBar
    self.rightInfoBar = rightInfoBar

    self.staticRing = GUIManager:CreateGraphicItem()
    self.staticRing:SetTexture(kSheet4)
    self.staticRing:SetTexturePixelCoordinates(GUIUnpackCoords(kStaticRingCoords))
    size = CoordsToSize(kStaticRingCoords)
    self.staticRing:SetSize(size)
    self.staticRing:SetPosition(center - size / 2)
    self.staticRing:SetLayer(kGUILayerPlayerHUDForeground1)
    self.background:AddChild(self.staticRing)
    
    self.innerRing = GUIManager:CreateGraphicItem()
    self.innerRing:SetTexture(kSheet1)
    self.innerRing:SetTexturePixelCoordinates(GUIUnpackCoords(kInnerRingCoords))
    size = CoordsToSize(kInnerRingCoords)
    self.innerRing:SetSize(size)
    self.innerRing:SetPosition(center - size / 2)
    self.innerRing:SetLayer(kGUILayerPlayerHUDForeground1)
    self.background:AddChild(self.innerRing)
    
    self.outerRing = GUIManager:CreateGraphicItem()
    self.outerRing:SetTexture(kSheet4)
    self.outerRing:SetTexturePixelCoordinates(GUIUnpackCoords(kOuterRingCoords))
    size = CoordsToSize(kOuterRingCoords)
    self.outerRing:SetSize(size)
    self.outerRing:SetPosition(center - size / 2)
    self.outerRing:SetLayer(kGUILayerPlayerHUDForeground1)
    self.background:AddChild(self.outerRing)
    
    self.targetcrosshair = GUIManager:CreateGraphicItem()
    self.targetcrosshair:SetTexture(kSheet1)
    self.targetcrosshair:SetTexturePixelCoordinates(GUIUnpackCoords(kCrosshairCoords))
    size = CoordsToSize(kCrosshairCoords)
    self.targetcrosshair:SetSize(size)
    self.targetcrosshair:SetLayer(kGUILayerPlayerHUDForeground1)
    self.targetcrosshair:SetIsVisible(false)
    self.background:AddChild(self.targetcrosshair)
    
    self.targets = { }

    self.playerStatusIcons = CreatePlayerStatusDisplay(self, kGUILayerPlayerHUDForeground1, self.background, kTeam1Index)

    self.visible = true

    self:Reset()

end

function GUIExoHUD:Uninitialize()

    GUIAnimatedScript.Uninitialize(self)
    
    GUI.DestroyItem(self.background)
    self.background = nil

    if self.playerStatusIcons then
        self.playerStatusIcons:Destroy()
        self.playerStatusIcons = nil
    end


end

function GUIExoHUD:SetIsVisible(isVisible)
    
    self.visible = isVisible
    self.background:SetIsVisible(isVisible)
    self.playerStatusIcons:SetIsVisible(isVisible)

end

function GUIExoHUD:GetIsVisible()
    
    return self.visible
    
end

local function GetFreeTargetItem(self)

    for r = 1, #self.targets do
    
        local target = self.targets[r]
        if not target:GetIsVisible() then
        
            target:SetIsVisible(true)
            return target
            
        end
        
    end
    
    local target = GUIManager:CreateGraphicItem()
    target:SetTexture(kSheet1)
    target:SetTexturePixelCoordinates(GUIUnpackCoords(kTargetingReticuleCoords))
    local size = CoordsToSize(kTargetingReticuleCoords)
    target:SetSize(size)
    target:SetLayer(kGUILayerPlayerHUDForeground1)
    self.background:AddChild(target)
    
    table.insert(self.targets, target)
    
    return target
    
end

local function Gaussian(mean, stddev, x) 

    local variance2 = stddev * stddev * 2.0
    local term = x - mean
    return math.exp(-(term * term) / variance2) / math.sqrt(math.pi * variance2)
    
end

local function UpdateTargets(self)

    for r = 1, #self.targets do
        self.targets[r]:SetIsVisible(false)
    end
    
    if not PlayerUI_GetHasMinigun() then
        return
    end
    
    local trackEntities = GetEntitiesWithinRange("Alien", PlayerUI_GetOrigin(), kTrackEntityDistance)
    local closestToCrosshair
    local closestDistToCrosshair = math.huge
    local closestToCrosshairScale
    local closestToCrosshairOpacity
    for t = 1, #trackEntities do
    
        local trackEntity = trackEntities[t]
        local player = Client.GetLocalPlayer()
        local inFront = player:GetViewCoords().zAxis:DotProduct(GetNormalizedVector(trackEntity:GetModelOrigin() - player:GetEyePos())) > 0
        -- Only really looks good on Skulks currently.
        if inFront and trackEntity:GetIsAlive() and trackEntity:isa("Skulk") and not trackEntity:GetIsCloaked() then
        
            local trace = Shared.TraceRay(player:GetEyePos(), trackEntity:GetModelOrigin(), CollisionRep.Move, PhysicsMask.All, EntityFilterOne(player))
            if trace.entity == trackEntity then
            
                local targetItem = GetFreeTargetItem(self)
                
                local _, max = trackEntity:GetModelExtents()
                local distance = trackEntity:GetDistance(PlayerUI_GetOrigin())
                local scalar = max:GetLength() / distance * 8
                local size = CoordsToSize(kTargetingReticuleCoords)
                local scaledSize = size * scalar
                targetItem:SetSize(scaledSize)
                
                local targetScreenPos = Client.WorldToScreen(trackEntity:GetModelOrigin())
                targetItem:SetPosition(targetScreenPos - scaledSize / 2)
                
                local opacity = math.min(1, Gaussian(0.5, 0.1, distance / kTrackEntityDistance))
                
                -- Factor distance to the crosshair into opacity.
                local distToCrosshair = (targetScreenPos - Vector(Client.GetScreenWidth() / 2, Client.GetScreenHeight() / 2, 0)):GetLength()
                opacity = opacity * (1 - (distToCrosshair / 300))
                
                targetItem:SetColor(Color(1, 1, 1, opacity))
                
                if distToCrosshair < closestDistToCrosshair then
                
                    closestDistToCrosshair = distToCrosshair
                    closestToCrosshair = targetScreenPos
                    closestToCrosshairScale = scalar
                    closestToCrosshairOpacity = opacity
                    
                end
                
            end
            
        end
        
    end
    
    if closestToCrosshair ~= nil and closestDistToCrosshair < 50 then
    
        self.targetcrosshair:SetIsVisible(true)
        local size = CoordsToSize(kCrosshairCoords) * (0.75 + (0.25 * ((math.sin(Shared.GetTime() * 7) + 1) / 2)))
        local scaledSize = size * closestToCrosshairScale
        self.targetcrosshair:SetSize(scaledSize)
        self.targetcrosshair:SetPosition(closestToCrosshair - scaledSize / 2)
        self.targetcrosshair:SetColor(Color(1, 1, 1, closestToCrosshairOpacity))
        
    else
        self.targetcrosshair:SetIsVisible(false)
    end
    
end

function GUIExoHUD:Update(deltaTime)

    PROFILE("GUIExoHUD:Update")

    local fullMode = Client.GetHudDetail() == kHUDMode.Full

    if fullMode then
    
        self.ringRotation = self.ringRotation or 0
        self.lastPlayerYaw = self.lastPlayerYaw or PlayerUI_GetYaw()

        local currentYaw = PlayerUI_GetYaw()
        self.ringRotation = self.ringRotation + (GetAnglesDifference(self.lastPlayerYaw, currentYaw) * 0.25)
        self.lastPlayerYaw = currentYaw
        
        self.innerRing:SetRotation(Vector(0, 0, -self.ringRotation))
        self.outerRing:SetRotation(Vector(0, 0, self.ringRotation))

    end
    
    self.innerRing:SetIsVisible(fullMode)
    self.outerRing:SetIsVisible(fullMode)
    self.leftInfoBar:SetIsVisible(fullMode)
    self.rightInfoBar:SetIsVisible(fullMode)
   

	local _, timePassedPercent = PlayerUI_GetShowGiveDamageIndicator()
	
	local color = Color(1, 0.5 + timePassedPercent * 0.5, 0.5 + timePassedPercent * 0.5, 1 )
	self.staticRing:SetColor(color)    
	self.innerRing:SetColor(color)
	self.outerRing:SetColor(color)
   
    self.staticRing:SetIsVisible(fullMode)
    
    UpdateTargets(self)

    -- Update player status icons
    local playerStatusIcons = {
        ParasiteState = PlayerUI_GetPlayerParasiteState(),
        ParasiteTime = PlayerUI_GetPlayerParasiteTimeRemaining(),
        NanoShieldState = PlayerUI_GetPlayerNanoShieldState(),
        NanoShieldTime = PlayerUI_GetNanoShieldTimeRemaining(),
        CatPackState = PlayerUI_GetPlayerCatPackState(),
        CatPackTime = PlayerUI_GetCatPackTimeRemaining(),
        Corroded = PlayerUI_GetIsCorroded(),
        BeingWelded = PlayerUI_IsBeingWelded(),
		BlightState = PlayerUI_GetPlayerBlightState(),
        BlightTime = PlayerUI_GetPlayerBlightTimeRemaining(),
    }

    -- Updates animations
    GUIAnimatedScript.Update(self, deltaTime)
    self.playerStatusIcons:Update(deltaTime, playerStatusIcons, fullMode)

end

function GUIExoHUD:Reset()
    self.playerStatusIcons:Reset(self.scale)
end

function GUIExoHUD:OnResolutionChanged(oldX, oldY, newX, newY)

    self:Reset()

    self:Uninitialize()
    self:Initialize()
    
end