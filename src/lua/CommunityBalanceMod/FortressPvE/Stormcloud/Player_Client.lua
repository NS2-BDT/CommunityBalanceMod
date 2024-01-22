-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


function PlayerUI_GetIsStormed()

    local player = Client.GetLocalPlayer()
    if player and player:isa("Alien") then
        return player:GetIsStormed()
    end

    return false

end

