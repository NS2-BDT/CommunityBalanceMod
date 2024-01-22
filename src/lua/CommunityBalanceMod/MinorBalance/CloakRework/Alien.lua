-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================

function Alien:GetIsCamouflaged()
    return GetHasCamouflageUpgrade(self) --and not self:GetIsInCombat()
end