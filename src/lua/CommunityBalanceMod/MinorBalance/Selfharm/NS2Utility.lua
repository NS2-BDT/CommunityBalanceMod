-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================



local oldCanEntityDoDamageTo = CanEntityDoDamageTo
function CanEntityDoDamageTo(attacker, target, cheats, devMode, friendlyFire, damageType)
   
    if not cheats and not friendlyFire then 

        -- only arcs are able to deal splash damage
        if target:isa("ARC") and damageType == kDamageType.Splash then
            return false
        end

    end

    return oldCanEntityDoDamageTo(attacker, target, cheats, devMode, friendlyFire, damageType)
end