-- ========= Community Balance Mod ===============================
--
--  "lua\Onos.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


function Onos:GetPlayFootsteps()

    if GetHasCamouflageUpgrade(self) and self:GetCrouching() then
       return false
    end

    return self:GetVelocityLength() > .75 and self:GetIsOnGround() and self:GetIsAlive()
end




function Onos:UpdateRumbleSound()

    if Client then
    
        local rumbleSound = Shared.GetEntity(self.rumbleSoundId)

        if rumbleSound then

            if GetHasCamouflageUpgrade(self) and self:GetCrouching() then
                rumbleSound:SetParameter("speed", 0, 1)
            else 
                rumbleSound:SetParameter("speed", self:GetSpeedScalar(), 1)
            end
        end
        
    end
    
end
