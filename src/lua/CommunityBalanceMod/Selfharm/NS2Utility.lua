

local oldCanEntityDoDamageTo = CanEntityDoDamageTo
function CanEntityDoDamageTo(attacker, target, cheats, devMode, friendlyFire, damageType)
   
    if target:isa("ARC") and attacker:isa("ARC") then
        return false
    end

    return oldCanEntityDoDamageTo(attacker, target, cheats, devMode, friendlyFire, damageType)
end