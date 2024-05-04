function PlayerUI_GetIsHeatplated()
    local player = Client.GetLocalPlayer()
    if player and player:isa("Alien") then
        return Shared.GetTime() < player.resilienceTimeEnd
    end

    return false
end