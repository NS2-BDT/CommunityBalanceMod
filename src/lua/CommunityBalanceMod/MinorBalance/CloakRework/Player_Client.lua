-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================

function PlayerUI_GetIsCloaked()

    local player = Client.GetLocalPlayer()
    if player and HasMixin(player, "Cloakable") then
        return player:GetIsCloaked()
    end

    return false

end