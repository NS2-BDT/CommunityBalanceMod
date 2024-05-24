function PlayerUI_GetExoRepairAvailable()
    
    local player = Client.GetLocalPlayer()
    
    if player and player:GetIsPlaying() and player:isa("Exo") and player.GetRepairAllowed then
        
        return player:GetRepairAllowed(), player:GetFuel() >= kExoRepairMinFuel, player.repairActive
    
    end
    
    return false, false, false

end

function PlayerUI_GetExoThrustersAvailable()
    
    local player = Client.GetLocalPlayer()
    
    if player and player:GetIsPlaying() and player:isa("Exo") and player.GetIsThrusterAllowed then
        
        return player:GetIsThrusterAllowed(), player:GetFuel() >= kExoThrusterMinFuel, player.thrustersActive
    
    end
    
    return false, false, false

end

function PlayerUI_GetExoNanoShieldAvailable()

    local player = Client.GetLocalPlayer()

    if player and player:GetIsPlaying() and player:isa("Exo") and player.GetNanoShieldAllowed then

        return player:GetNanoShieldAllowed(), player:GetFuel() >= kExoNanoShieldMinFuel, player.nanoshieldActive

    end

    return false, false, false

end

function PlayerUI_GetExoCatPackAvailable()
    
    local player = Client.GetLocalPlayer()
    
    if player and player:GetIsPlaying() and player:isa("Exo") and player.GetCatPackAllowed then
        
        return player:GetCatPackAllowed(), player:GetFuel() >= kExoCatPackMinFuel, player.catpackActive
    
    end
    
    return false, false, false

end

function PlayerUI_GetHasThrusters()
    
    local player = Client.GetLocalPlayer()
    if player and player:GetIsPlaying() and player:isa("Exo") and player.GetHasThrusters then
        return player:GetHasThrusters()
    end
    return false

end

function PlayerUI_GetHasNanoShield()
    
    local player = Client.GetLocalPlayer()
    
    if player and player:GetIsPlaying() and player:isa("Exo") and player.GetHasNanoShield then
        return player:GetHasNanoShield()
    end
    
    return false

end

function PlayerUI_GetHasNanoRepair()
    local player = Client.GetLocalPlayer()
    if player and player:GetIsPlaying() and player:isa("Exo") and player.GetHasRepair then
        return player:GetHasRepair()
    end
    return false
end

function PlayerUI_GetHasCatPack()
    local player = Client.GetLocalPlayer()
    if player and player:GetIsPlaying() and player:isa("Exo") and player.GetHasCatPack then
        return player:GetHasCatPack()
    end
    return false
end