-- ======= Copyright (c) 2013, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
--
-- lua\GUILeftRailgunDisplay.lua
--
-- Created by: Brian Cronin (brianc@unknownworlds.com)
--
-- Displays the charge amount for the Exo's Left Railgun.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

-- Global state that can be externally set to adjust the display.
chargeAmountleft = 0
Modeleft = "MultiShot"
minEnergyleft = 0.35

function Update(dt)
    UpdateCharge(dt, chargeAmountleft, Modeleft, minEnergyleft)
end

Script.Load("lua/GUIPlasma.lua")