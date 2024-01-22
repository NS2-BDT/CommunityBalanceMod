-- ========= Community Balance Mod ===============================
--
--  "lua\Alien.lua"
--
--    Created by:   Twiliteblue, Drey (@drey3982)
--
-- ===============================================================

function Alien:GetIsCamouflaged()
    return GetHasCamouflageUpgrade(self) --and not self:GetIsInCombat()
end