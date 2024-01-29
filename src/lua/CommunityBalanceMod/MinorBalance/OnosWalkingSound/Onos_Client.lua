-- ========= Community Balance Mod ===============================
--
--  "lua\Onos_Client.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================




function Onos:PlayFootstepEffects(scalar)

    ASSERT(Client)

    scalar = ConditionalValue(scalar == nil, 1, scalar)
    
    -- shake the local players screen, if close enough.
    local player = Client.GetLocalPlayer()
    if player and player.GetIsAlive and player:GetIsAlive() and not player:isa("Commander") then
    
        self:_PlayFootstepShake(player, scalar)
        
        local distToOnos = (player:GetOrigin() - self:GetOrigin()):GetLength()
        local lightShakeAmount = 1 - Clamp((distToOnos / kOnosLightDistance), 0, 1)
        player:SetLightShakeAmount(lightShakeAmount, kOnosLightShakeDuration, scalar)
        
    end
        

    if not GetHasCamouflageUpgrade(self) or not self:GetCrouching() then
        self:TriggerFootstep()
     end
        
end




-- Shake camera for for given player
function Onos:_PlayFootstepShake(player, scalar)

    if GetHasCamouflageUpgrade(self) and self:GetCrouching() then
        return
    end


    if player ~= nil and player:GetIsAlive() and player ~= self then
        
        local kMaxDist = 25
        
        local dist = (player:GetOrigin() - self:GetOrigin()):GetLength()
        
        if dist < kMaxDist then
        
            local amount = (kMaxDist - dist)/kMaxDist
            
            local shakeAmount = .002 + amount * amount * .002
            local shakeSpeed = 5 + amount * amount * 9
            local shakeTime = .4 - (amount * amount * .2)
            
            player:SetCameraShake(shakeAmount * scalar, shakeSpeed, shakeTime)
            
        end
        
    end
        
end
