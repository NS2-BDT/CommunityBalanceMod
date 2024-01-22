-- ========= Community Balance Mod ===============================
--
-- "lua\Weapons\Weapon_Server.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


function Weapon:OnTakeDamage(damage, attacker, doer, point)

    -- Max Weapon Decay = 16 seconds
    -- Max Weapon HP = 400

    -- for balance we use /450 *12 instead of /400 *16
    -- 2 biles deal close to 450 damage and should shorten lifespan by 12 seconds

    local deductTime = damage /450 *12

    if self.expireTime and self.expireTime > 0.1 then 

        self.expireTime = self.expireTime - deductTime
        if self.expireTime <= 0.1 then 
            self.expireTime = 0.1
        end
    end
end
