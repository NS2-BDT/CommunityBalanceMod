function Onos:_PlayFootstepShake(player, scalar)

    if player ~= nil and player:GetIsAlive() and player ~= self then
        
        local kMaxDist = self:GetCrouching() and 10 or 25
        
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