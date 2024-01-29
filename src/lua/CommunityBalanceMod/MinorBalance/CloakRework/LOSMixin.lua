-- ========= Community Balance Mod ===============================
--
--  "lua\LOSMixin.lua"
--
--    Created by:   Twiliteblue, Drey (@drey3982)
--
-- ===============================================================


if Server then

    local UnsightImmediately = debug.getupvaluex(LOSMixin.OnTeamChange, "UnsightImmediately")

    function LOSMixin:OnCloak()
        UnsightImmediately(self)
    end
end
