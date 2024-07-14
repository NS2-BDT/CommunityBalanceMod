-- ======= Copyright (c) 2013, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
--
-- lua\GUIRailgun.lua
--
-- Created by: Brian Cronin (brianc@unknownworlds.com)
--
-- Displays the charge amount for the Exo's Railgun.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIRailgun.lua")

local kTexture = "models/marine/exosuit/exosuit_view_panel_rail2.dds"

local chargeCircle
local shootSquares = { }
local cooldownSquares = { }
local time = 0

function UpdateCharge(dt, chargeAmount, Mode, minEnergy)

    PROFILE("GUIRailgun:UpdateCharge")
    
	local pulseAmt = (1 + math.cos(time * 20)) * 0.5
	local colorAmt = pulseAmt * 0.25
		
	if Mode == "MultiShot" then
	
		if chargeAmount < minEnergy then
			chargeCircle:GetLeftSide():SetColor(Color(1-colorAmt, colorAmt, colorAmt, 1))
			chargeCircle:GetRightSide():SetColor(Color(1-colorAmt, colorAmt, colorAmt, 1))
		else
			chargeCircle:GetLeftSide():SetColor(Color(0.25, 1, 1, 1))   -- Replace colorAmt w/ 1 for solid color
			chargeCircle:GetRightSide():SetColor(Color(0.25, 1, 1, 1))  -- Replace colorAmt w/ 0.33 for solid color
		end
		
	elseif Mode == "Bomb" then

		if chargeAmount < minEnergy then
			chargeCircle:GetLeftSide():SetColor(Color(1-colorAmt, colorAmt, colorAmt, 1))
			chargeCircle:GetRightSide():SetColor(Color(1-colorAmt, colorAmt, colorAmt, 1))
		else
			chargeCircle:GetLeftSide():SetColor(Color(1, 0.25, 1, 1))   -- Replace colorAmt w/ 1 for solid color
			chargeCircle:GetRightSide():SetColor(Color(1, 0.25, 1, 1))  -- Replace colorAmt w/ 0.33 for solid color
		end

	end
    
    chargeCircle:SetPercentage(chargeAmount)
    chargeCircle:Update(dt)
    
    time = time + dt
    
end

local kWidth = 246
local kHeight = 256
local kTexWidth = 450
local kTexHeight = 452
function Initialize()

    GUI.SetSize(kWidth, kHeight)
    
    local chargeCircleSettings = { }
    chargeCircleSettings.BackgroundWidth = kWidth
    chargeCircleSettings.BackgroundHeight = kHeight
    chargeCircleSettings.BackgroundAnchorX = GUIItem.Left
    chargeCircleSettings.BackgroundAnchorY = GUIItem.Bottom
    chargeCircleSettings.BackgroundOffset = Vector(0, 0, 0)
    chargeCircleSettings.BackgroundTextureName = kTexture
	
    chargeCircleSettings.BackgroundTextureX1 = 0
    chargeCircleSettings.BackgroundTextureY1 = 0
    chargeCircleSettings.BackgroundTextureX2 = kTexWidth
    chargeCircleSettings.BackgroundTextureY2 = kTexHeight
		
    chargeCircleSettings.ForegroundTextureName = kTexture
    chargeCircleSettings.ForegroundTextureWidth = kTexWidth
    chargeCircleSettings.ForegroundTextureHeight = kTexHeight
	
    chargeCircleSettings.ForegroundTextureX1 = kTexWidth
    chargeCircleSettings.ForegroundTextureY1 = 0
    chargeCircleSettings.ForegroundTextureX2 = kTexWidth * 2
    chargeCircleSettings.ForegroundTextureY2 = kTexHeight
	
	
    chargeCircleSettings.InheritParentAlpha = true
    chargeCircle = GUIDial()
    chargeCircle:Initialize(chargeCircleSettings)
    chargeCircle:GetBackground():SetIsVisible(true)
    
    local x = 80
    for s = 1, 4 do
    
        table.insert(shootSquares, GUIManager:CreateGraphicItem())
        table.insert(cooldownSquares, GUIManager:CreateGraphicItem())
        
        shootSquares[s]:SetSize(Vector(20, 48, 0))
        cooldownSquares[s]:SetSize(Vector(20, 48, 0))
        shootSquares[s]:SetTexturePixelCoordinates(900, 0, 936, 87)
        cooldownSquares[s]:SetTexturePixelCoordinates(900, 89, 936, 176)
        shootSquares[s]:SetPosition(Vector(x, 100, 0))
        cooldownSquares[s]:SetPosition(Vector(x, 100, 0))
        x = x + 22
        shootSquares[s]:SetTexture(kTexture)
        cooldownSquares[s]:SetTexture(kTexture)
        
        cooldownSquares[s]:SetIsVisible(false)
        
    end
    
end

Initialize()