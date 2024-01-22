-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


if Server then

    local UnsightImmediately = debug.getupvaluex(LOSMixin.OnTeamChange, "UnsightImmediately")

    function LOSMixin:OnCloak()
        UnsightImmediately(self)
    end
end
