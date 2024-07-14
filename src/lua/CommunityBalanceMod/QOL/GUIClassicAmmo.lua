
local oldInit = GUIClassicAmmo.Initialize
function GUIClassicAmmo:Initialize()
    oldInit(self)

    self.updateInterval = kUpdateIntervalFull
end

local pulseCharge1 = Color(1, 1, 1, 1)
local pulseCharge2 = Color(0.25, 1, 1, 1)
local pulseCharge3 = Color(1, 0.25, 1, 1)

local oldUpdate = GUIClassicAmmo.Update
function GUIClassicAmmo:Update(deltaTime)
    oldUpdate(self, deltaTime)

	if not self.enabled then
		return
	end

	local player = Client.GetLocalPlayer()
	local activeWeapon = player:GetActiveWeapon()    

    if activeWeapon and activeWeapon:isa("Weapon") then
        if activeWeapon:isa("ExoWeaponHolder") then
            local leftWeapon = Shared.GetEntity(activeWeapon.leftWeaponId)
            local rightWeapon = Shared.GetEntity(activeWeapon.rightWeaponId)
            local highestCharge = -1
			local Mode = "None"

            if leftWeapon:isa("PlasmaLauncher") then
                if leftWeapon:GetChargeAmount() > highestCharge then
                    highestCharge = leftWeapon:GetChargeAmount()
					Mode = leftWeapon:GetMode()
                end
            end
            
            if rightWeapon:isa("PlasmaLauncher") then
                if rightWeapon:GetChargeAmount() > highestCharge then
                    highestCharge = rightWeapon:GetChargeAmount()
					Mode = rightWeapon:GetMode()
                end
            end
			
							
			if Mode == "MultiShot" then
				if highestCharge < kPlasmaMultiEnergyCost then
					colorAmtC = 1
					colorAmtM = 0.25
					colorAmtY = 0.25
				else
					colorAmtC = 0.25
					colorAmtM = 1
					colorAmtY = 1
				end
			elseif Mode == "Bomb" then
				if highestCharge < kPlasmaBombEnergyCost then
					colorAmtC = 1
					colorAmtM = 0.25
					colorAmtY = 0.25
				else
					colorAmtC = 1
					colorAmtM = 0.25
					colorAmtY = 1
				end
			else
				colorAmtC = 1
				colorAmtM = 1
				colorAmtY = 1
			end
				
			self.ammoText:SetColor(Color(colorAmtC, colorAmtM, colorAmtY, 1))   -- Replace colorAmt w/ 1 for solid color
        end
    end
end