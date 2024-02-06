

local oldCanEntityDoDamageTo = CanEntityDoDamageTo
function CanEntityDoDamageTo(attacker, target, cheats, devMode, friendlyFire, damageType)
   
    -- only arcs deal splash damage. attacker would be marinecommander or marine
    if target:isa("ARC") and damageType == kDamageType.Splash  then
        return false
    end

    return oldCanEntityDoDamageTo(attacker, target, cheats, devMode, friendlyFire, damageType)
end