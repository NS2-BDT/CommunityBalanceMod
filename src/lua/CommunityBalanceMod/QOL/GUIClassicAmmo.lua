
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

            if highestCharge < 0.33 then
                self.ammoText:SetColor(pulseCharge1)
            elseif highestCharge < 0.67 then
                self.ammoText:SetColor(pulseCharge2)
            else
                self.ammoText:SetColor(pulseCharge3)
            end
        end
    end
end