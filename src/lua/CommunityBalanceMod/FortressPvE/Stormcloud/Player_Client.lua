
function PlayerUI_GetIsStormed()

    local player = Client.GetLocalPlayer()
    if player and player:isa("Alien") then
        return player:GetIsStormed()
    end

    return false

end

