

local oldCanEntityDoDamageTo = CanEntityDoDamageTo
function CanEntityDoDamageTo(attacker, target, cheats, devMode, friendlyFire, damageType)
   
    if not cheats and not friendlyFire then 

        -- only arcs are able to deal splash damage
        if target:isa("ARC") and damageType == kDamageType.Splash then
            return false
        end


        if attacker:isa("Grenade") then
            local owner = attacker:GetOwner()
            if owner and owner:GetId() == target:GetId() then
                return false
            end
        end

        if attacker == target and not attacker:isa("Mine") then
            return false
        end

    end

    return oldCanEntityDoDamageTo(attacker, target, cheats, devMode, friendlyFire, damageType)
end