
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

            if leftWeapon:isa("PlasmaLauncher") then
                if leftWeapon:GetChargeAmount() > highestCharge then
                    highestCharge = leftWeapon:GetChargeAmount()
                end
            end
            
            if rightWeapon:isa("PlasmaLauncher") then
                if rightWeapon:GetChargeAmount() > highestCharge then
                    highestCharge = rightWeapon:GetChargeAmount()
                end
            end
			
			local shotAmount = math.floor(highestCharge/0.2)		
				
			if highestCharge < 0.95 then -- Can be 67% if dynamic colors (could go back to vanilla dial GUI)
				colorAmtC = 1 - 0.20*shotAmount
				colorAmtM = 1
				else
				colorAmtC = 1
				colorAmtM = 0.25
			end
					
			self.ammoText:SetColor(Color(colorAmtC, colorAmtM, 1, 1))   -- Replace colorAmt w/ 1 for solid color
        end
    end
end