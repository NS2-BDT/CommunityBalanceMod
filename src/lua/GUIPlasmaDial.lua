
-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\GUIDial.lua
--
-- Created by: Brian Cronin (brianc@unknownworlds.com)
--
-- Manages displaying a circular dial. Used to show health, armor, progress, etc.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIScript.lua")

class 'GUIDial' (GUIScript)

function GUIDial:Initialize(settingsTable)

	BWidth = settingsTable.BackgroundWidth
	BHeight = settingsTable.BackgroundHeight
	
	SingleHeight = Vector(BWidth, BHeight, 0)
	DoubleHeight = Vector(BWidth, BHeight*2, 0)
	HalfHeight = Vector(BWidth, BHeight/2, 0)
	Quarter = Vector(BWidth/2, BHeight/2, 0)
	DoubleDouble = Vector(BWidth*2, BHeight*2, 0)
	
    self.percentage = 1
	
    -- Background.
    self.dialBackground = GUIManager:CreateGraphicItem()
    self.dialBackground:SetSize(Vector(BWidth, BHeight, 0))
    self.dialBackground:SetAnchor(settingsTable.BackgroundAnchorX, settingsTable.BackgroundAnchorY)
    self.dialBackground:SetPosition(Vector(0, -BHeight, 0) + settingsTable.BackgroundOffset)

    if settingsTable.BackgroundTextureName ~= nil then
        self.dialBackground:SetTexture(settingsTable.BackgroundTextureName)
        self.dialBackground:SetTexturePixelCoordinates(settingsTable.BackgroundTextureX1, settingsTable.BackgroundTextureY1,
                settingsTable.BackgroundTextureX2, settingsTable.BackgroundTextureY2)
    else
        self.dialBackground:SetColor(Color(1, 1, 1, 0))
    end

    self.dialBackground:SetClearsStencilBuffer(true)


    -- Left side.
    self.leftSideMask = GUIManager:CreateGraphicItem()
    self.leftSideMask:SetIsStencil(true)
    self.leftSideMask:SetSize(Vector(BWidth, BHeight * 2, 0))
    self.leftSideMask:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.leftSideMask:SetPosition(Vector(0, -(BHeight), 0))
    self.leftSideMask:SetRotationOffset(Vector(-BWidth, 0, 0))
    self.leftSideMask:SetInheritsParentAlpha(settingsTable.InheritParentAlpha)

    self.leftSide = GUIManager:CreateGraphicItem()
    self.leftSide:SetStencilFunc(GUIItem.Equal)
    self.leftSide:SetSize(Quarter)
    self.leftSide:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.leftSide:SetPosition(Vector(-BWidth/2, -BHeight/2, 0)) 		-- [-246/2,-256/2,0]
    self.leftSide:SetRotationOffset(Vector(BWidth/2, 0, 0))				-- [246/2,0,0]
    self.leftSide:SetTexture(settingsTable.ForegroundTextureName)
    self.leftSide:SetInheritsParentAlpha(settingsTable.InheritParentAlpha)

    -- Right side.
    self.rightSideMask = GUIManager:CreateGraphicItem()
    self.rightSideMask:SetIsStencil(true)
    self.rightSideMask:SetSize(Vector(BWidth, BHeight * 2, 0))
    self.rightSideMask:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.rightSideMask:SetPosition(Vector(-BWidth, -(BHeight), 0))
    self.rightSideMask:SetRotationOffset(Vector(BWidth, 0, 0))
    self.rightSideMask:SetInheritsParentAlpha(settingsTable.InheritParentAlpha)

    self.rightSide = GUIManager:CreateGraphicItem()
    self.rightSide:SetStencilFunc(GUIItem.Equal)
    self.rightSide:SetSize(Quarter)
    self.rightSide:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.rightSide:SetPosition(Vector(0, -(BHeight/2), 0))				-- [0,-256/2,0]
    self.rightSide:SetTexture(settingsTable.ForegroundTextureName)
    self.rightSide:SetInheritsParentAlpha(settingsTable.InheritParentAlpha)

	-- Bottom side.
    self.bottomSideMask = GUIManager:CreateGraphicItem()
    self.bottomSideMask:SetIsStencil(true)
    self.bottomSideMask:SetSize(SingleHeight)
    self.bottomSideMask:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.bottomSideMask:SetPosition(Vector(-BWidth, -BHeight/2, 0))
    self.bottomSideMask:SetRotationOffset(Vector(BWidth, 0, 0))
    self.bottomSideMask:SetInheritsParentAlpha(settingsTable.InheritParentAlpha)

    self.bottomSide = GUIManager:CreateGraphicItem()
    self.bottomSide:SetStencilFunc(GUIItem.Equal)
    self.bottomSide:SetSize(HalfHeight)
    self.bottomSide:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.bottomSide:SetPosition(Vector(-BWidth/2, 0, 0))
    self.bottomSide:SetTexture(settingsTable.ForegroundTextureName)
    self.leftSide:SetRotationOffset(Vector(BWidth/2, 0, 0))
    self.bottomSide:SetInheritsParentAlpha(settingsTable.InheritParentAlpha)

    self:SetTextureCoordinatesFromSettings(settingsTable)

    self.globalRotation = Vector(0,0,0)

    self.dialBackground:AddChild(self.leftSideMask)
    self.dialBackground:AddChild(self.leftSide)

    self.dialBackground:AddChild(self.rightSideMask)
    self.dialBackground:AddChild(self.rightSide)
	
	self.dialBackground:AddChild(self.bottomSideMask)
    self.dialBackground:AddChild(self.bottomSide)

end

function GUIDial:SetTextureCoordinatesFromSettings(settingsTable)
	
	-- Global Texture File Coordinates
	local X1 = settingsTable.ForegroundTextureX1 				-- Left Limit of fill texture   [kTexWidth]
	local X2 = settingsTable.ForegroundTextureX2 				-- Right Limit of fill texture  [2*kTextWidth]
	local Y1 = settingsTable.ForegroundTextureY1 				-- Bottom Limit of fill texture [0]
	local Y2 = settingsTable.ForegroundTextureY2 				-- Top Limit of fill texture	[kTexHeight]
	
	local TexWidth = settingsTable.ForegroundTextureWidth	   	-- Total Width of fill texture  [kTexWidth]
	local TexHeight = settingsTable.ForegroundTextureHeight	   	-- Total Width of fill texture  [kTexHeight]
	
	local XMid = X1 + TexWidth / 2 							    -- At midpoint of fill texture
	local YMid = Y1 + TexHeight / 2
	
	self.leftSide:SetTexturePixelCoordinates(X1, Y1, XMid, YMid)
	self.bottomSide:SetTexturePixelCoordinates(X1, YMid, X2, Y2)
    self.rightSide:SetTexturePixelCoordinates(XMid, Y1, X2, YMid)
	
end

function GUIDial:Uninitialize()

    GUI.DestroyItem(self.dialBackground)
    self.dialBackground = nil
    
end

-- 'global' rotation. rotates all elements
function GUIDial:SetRotation(rotation)
    self.globalRotation.z = rotation
end

function GUIDial:SetForegroundTexture(texture)

    self.leftSide:SetTexture(texture)
    self.rightSide:SetTexture(texture)

end

function GUIDial:SetBackgroundTexture(texture)
    --self.dialBackground:SetTexture(texture)
end

function GUIDial:Update(deltaTime)

    PROFILE("GUIDial:Update")

    local leftPercentage = math.max(0, (self.percentage - 0.5) / 0.5)
    self.leftSideMask:SetRotation(self.globalRotation + Vector(0, 0, math.pi * (1 - leftPercentage)))
    
    local rightPercentage = math.max(0, math.min(0.5, self.percentage) / 0.5)
    self.rightSideMask:SetRotation(self.globalRotation + Vector(0, 0, math.pi * (1 - rightPercentage)))
    	
	local bottomPercentage = math.max(0, math.min(1,(self.percentage/0.5 - 0.5)))
    self.bottomSideMask:SetRotation(self.globalRotation + Vector(0, 0, math.pi * (0.5 - bottomPercentage)))
    	
    self.dialBackground:SetRotation(self.globalRotation)
    self.leftSide:SetRotation(self.globalRotation)
	self.bottomSide:SetRotation(self.globalRotation)
	self.rightSide:SetRotation(self.globalRotation)
 
end

function GUIDial:SetPercentage(setPercentage)

    self.percentage = setPercentage

end

function GUIDial:GetBackground()

    return self.dialBackground

end

function GUIDial:GetLeftSide()

    return self.leftSide
    
end

function GUIDial:GetRightSide()

    return self.rightSide
    
end

function GUIDial:GetBottomSide()

    return self.bottomSide
    
end

function GUIDial:SetIsVisible(isVisible)
    self.dialBackground:SetIsVisible(isVisible)
end    
