
local function OnCommandStorm(client)
    if Shared.GetCheatsEnabled() then
    
        local player = client:GetControllingPlayer()
        if player and player.TriggerStorm then
            player:TriggerStorm(10)
        end
        
    end
end

Event.Hook("Console_storm", OnCommandStorm)            
   