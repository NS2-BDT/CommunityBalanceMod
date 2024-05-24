-- local oldBuildClassToGrid = BuildClassToGrid
-- function BuildClassToGrid()
    
--     local ClassToGrid = oldBuildClassToGrid()
    
--     ClassToGrid["WeaponCache"] = { 2, 5 }
    
--     return ClassToGrid

-- end

local function checkLeftWeaponAmmo(leftWeapon)
    local leftAmmo = -1
    if leftWeapon:isa("Railgun") or leftWeapon:isa("PlasmaLauncher") then
        leftAmmo = leftWeapon:GetChargeAmount() * 100
    elseif leftWeapon:isa("Minigun") then
        leftAmmo = leftWeapon.heatAmount * 100
    end

    return leftAmmo
end

local function checkLeftWeaponFraction(leftWeapon, fraction)
    if leftWeapon:isa("Minigun") then
        fraction = (fraction + leftWeapon.heatAmount) / 2.0
    elseif leftWeapon:isa("Railgun") or leftWeapon:isa("PlasmaLauncher") then
        fraction = (fraction + leftWeapon:GetChargeAmount()) / 2.0
    end

    return fraction
end

local oldGetWeaponAmmoString = GetWeaponAmmoString
function GetWeaponAmmoString(weapon)
    local ammo = oldGetWeaponAmmoString(weapon)

    if weapon and weapon:isa("Weapon") then
        if weapon:isa("ExoWeaponHolder") then
            local leftWeapon = Shared.GetEntity(weapon.leftWeaponId)
            local rightWeapon = Shared.GetEntity(weapon.rightWeaponId)
            local leftAmmo = -1
            local rightAmmo = -1
            if rightWeapon:isa("Railgun") or rightWeapon:isa("PlasmaLauncher") then
                rightAmmo = rightWeapon:GetChargeAmount() * 100
                leftAmmo = checkLeftWeaponAmmo(leftWeapon)
            elseif rightWeapon:isa("Minigun") then
                rightAmmo = rightWeapon.heatAmount * 100
                leftAmmo = checkLeftWeaponAmmo(leftWeapon)
            end
            if leftAmmo > -1 and rightAmmo > -1 then
                ammo = string.format("%d%% / %d%%", leftAmmo, rightAmmo)
            elseif rightAmmo > -1 then
                ammo = string.format("%d%%", rightAmmo)
            end
        end
    end

    return ammo
end

local oldGetWeaponAmmoFraction = GetWeaponAmmoFraction
function GetWeaponAmmoFraction(weapon)
    local fraction = oldGetWeaponAmmoFraction(weapon)
    if weapon and weapon:isa("Weapon") then
        if weapon:isa("ExoWeaponHolder") then
            local leftWeapon = Shared.GetEntity(weapon.leftWeaponId)
            local rightWeapon = Shared.GetEntity(weapon.rightWeaponId)

            if rightWeapon:isa("Railgun") or rightWeapon:isa("PlasmaLauncher") then
                fraction = rightWeapon:GetChargeAmount()
                fraction = checkLeftWeaponFraction(leftWeapon, fraction)
            elseif rightWeapon:isa("Minigun") then
                fraction = rightWeapon.heatAmount
                fraction = checkLeftWeaponFraction(leftWeapon, fraction)
                fraction = 1 - fraction -- TODO: This will break if we allow miniguns and rails together
            end
        end
    end

    return fraction
end
