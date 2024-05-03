function PlayerUI_GetIsHeatplated()
    local player = Client.GetLocalPlayer()
    if player and player:isa("Alien") then
        return Shared.GetTime() < player.heatplatingTimeEnd
    end

    return false
end