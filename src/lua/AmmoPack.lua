-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\AmmoPack.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/DropPack.lua")

class 'AmmoPack' (DropPack)

AmmoPack.kMapName = "ammopack"

AmmoPack.kModelNameWinter = PrecacheAsset("seasonal/holiday2012/models/gift_ammopack_01.model")
AmmoPack.kModelName = PrecacheAsset("models/marine/ammopack/ammopack.model")
local function GetModelName()
    return GetSeason() == Seasons.kWinter and AmmoPack.kModelNameWinter or AmmoPack.kModelName
end

AmmoPack.kNumClips = 5


function AmmoPack:OnInitialized()

    DropPack.OnInitialized(self)
    
    self:SetModel(GetModelName())
	
end

function AmmoPack:OnTouch(recipient)

    local consumedPack = false
    local oldAmmo = 0
    
    for i = 0, recipient:GetNumChildren() - 1 do
    
        local child = recipient:GetChildAtIndex(i)
        if child:isa("ClipWeapon") then

            oldAmmo = oldAmmo + child:GetAmmo()

            if child:GiveAmmo(AmmoPack.kNumClips, false) then
                consumedPack = true
            end
            
        end
        
    end
    
    if consumedPack then

        local newAmmo = 0
        for i = 0, recipient:GetNumChildren() - 1 do

            local child = recipient:GetChildAtIndex(i)
            if child:isa("ClipWeapon") then
                newAmmo = newAmmo + child:GetAmmo()
            end
        end

        self:TriggerEffects("ammopack_pickup", { effecthostcoords = recipient:GetCoords()})

        -- Handle Stats
        if Server then

            local commanderStat = StatsUI_GetStatForCommander(StatsUI_GetMarineCommmaderSteamID())

            if self:GetMapName() ~= "ammopack" or not commanderStat then
                return
            end

            commanderStat["ammopack"].misses   = commanderStat["ammopack"].misses - 1
            commanderStat["ammopack"].picks    = commanderStat["ammopack"].picks + 1
            commanderStat["ammopack"].refilled = commanderStat["ammopack"].refilled + newAmmo - oldAmmo
        end
    end
    
end

function AmmoPack:GetIsValidRecipient(recipient)

	if not recipient:isa("Marine") then
		return false
	end
	
    local needsAmmo = false
    
    for i = 0, recipient:GetNumChildren() - 1 do
    
        local child = recipient:GetChildAtIndex(i)
        if child:isa("ClipWeapon") and child:GetNeedsAmmo(false) then
        
            needsAmmo = true
            break
            
        end
        
    end 

    -- Ammo packs give ammo to clip as well (so pass true to GetNeedsAmmo())
    return needsAmmo
    
end

Shared.LinkClassToMap("AmmoPack", AmmoPack.kMapName)

class 'WeaponAmmoPack' (AmmoPack)
WeaponAmmoPack.kMapName = "weapoanammopack"

function WeaponAmmoPack:SetAmmoPackSize(size)
    self.ammoPackSize = size
end

function WeaponAmmoPack:OnTouch(recipient)

    local weapon = recipient:GetActiveWeapon()
    weapon:GiveReserveAmmo(self.ammoPackSize)
    self:TriggerEffects("ammopack_pickup", { effecthostcoords = recipient:GetCoords()})
    
end

function WeaponAmmoPack:GetIsValidRecipient(recipient)
    local valid = AmmoPack.GetIsValidRecipient(self, recipient)
    if not valid then return false end

    local weapon = recipient:GetActiveWeapon()
    local correctWeaponType = weapon and weapon:isa(self:GetWeaponClassName())
    return self.ammoPackSize ~= nil and correctWeaponType
end

Shared.LinkClassToMap("WeaponAmmoPack", WeaponAmmoPack.kMapName)

-- -------------

class 'RifleAmmo' (WeaponAmmoPack)
RifleAmmo.kMapName = "rifleammo"
RifleAmmo.kModelName = PrecacheAsset("models/marine/rifle/rifleammo.model")

function RifleAmmo:OnInitialized()

    WeaponAmmoPack.OnInitialized(self)
    self:SetModel(RifleAmmo.kModelName)

end

function RifleAmmo:GetWeaponClassName()
    return "Rifle"
end

Shared.LinkClassToMap("RifleAmmo", RifleAmmo.kMapName)

-- -------------

class 'ShotgunAmmo' (WeaponAmmoPack)
ShotgunAmmo.kMapName = "shotgunammo"
ShotgunAmmo.kModelName = PrecacheAsset("models/marine/shotgun/shotgunammo.model")

function ShotgunAmmo:OnInitialized()

    WeaponAmmoPack.OnInitialized(self)    
    self:SetModel(ShotgunAmmo.kModelName)

end

function ShotgunAmmo:GetWeaponClassName()
    return "Shotgun"
end    

Shared.LinkClassToMap("ShotgunAmmo", ShotgunAmmo.kMapName)

-- -------------

class 'FlamethrowerAmmo' (WeaponAmmoPack)
FlamethrowerAmmo.kMapName = "flamethrowerammo"
FlamethrowerAmmo.kModelName = PrecacheAsset("models/marine/flamethrower/flamethrowerammo.model")

function FlamethrowerAmmo:OnInitialized()

    WeaponAmmoPack.OnInitialized(self)    
    self:SetModel(FlamethrowerAmmo.kModelName)

end

function FlamethrowerAmmo:GetWeaponClassName()
    return "Flamethrower"
end

Shared.LinkClassToMap("FlamethrowerAmmo", FlamethrowerAmmo.kMapName)

-- -------------

class 'GrenadeLauncherAmmo' (WeaponAmmoPack)
GrenadeLauncherAmmo.kMapName = "grenadelauncherammo"
GrenadeLauncherAmmo.kModelName = PrecacheAsset("models/marine/grenadelauncher/grenadelauncherammo.model")

function GrenadeLauncherAmmo:OnInitialized()

    WeaponAmmoPack.OnInitialized(self)    
    self:SetModel(GrenadeLauncherAmmo.kModelName)

end

function GrenadeLauncherAmmo:GetWeaponClassName()
    return "GrenadeLauncher"
end

Shared.LinkClassToMap("GrenadeLauncherAmmo", GrenadeLauncherAmmo.kMapName)

-- -------------

class 'HeavyMachineGunAmmo' (WeaponAmmoPack)
HeavyMachineGunAmmo.kMapName = "heavymachinegunammo"
HeavyMachineGunAmmo.kModelName = PrecacheAsset("models/marine/hmg/hmgammo.model")

function HeavyMachineGunAmmo:OnInitialized()

    WeaponAmmoPack.OnInitialized(self)
    self:SetModel(HeavyMachineGunAmmo.kModelName)

end

function HeavyMachineGunAmmo:GetWeaponClassName()
    return "HeavyMachineGun"
end

Shared.LinkClassToMap("HeavyMachineGunAmmo", HeavyMachineGunAmmo.kMapName)

-- -------------

class 'SMGAmmo' (WeaponAmmoPack)
SMGAmmo.kMapName = "smgammo"
SMGAmmo.kModelName = PrecacheAsset("models/marine/rifle/RifleAmmo.model")

function SMGAmmo:OnInitialized()

    WeaponAmmoPack.OnInitialized(self)
    self:SetModel(SMGAmmo.kModelName)

end

function SMGAmmo:GetWeaponClassName()
    return "Submachinegun"
end

Shared.LinkClassToMap("SMGAmmo", SMGAmmo.kMapName)