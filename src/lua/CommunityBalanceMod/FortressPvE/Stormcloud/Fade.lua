

local oldFadeGetAirFriction = Fade.GetAirFriction
function Fade:GetAirFriction()

    if not self.stormed then
        return oldFadeGetAirFriction(self)
    else


        local currentSpeed = self:GetVelocityLength()
        local baseFriction = 0.17
        local kBlinkMaxSpeedBase = 19
        local kBlinkMaxSpeedCelerity = 20.5
        local kFastMovingAirFriction = 0.40

        local stormFriction = baseFriction - 0.03
        local stormBonus = 0.20

        if self:GetIsBlinking() then

            return 0
    
        elseif GetHasCelerityUpgrade(self) then
    
            if currentSpeed > kBlinkMaxSpeedCelerity * ( 1 + stormBonus) then
    
                -- celerity allow for +1.5 faster maxspeed before applying fastmoving reduction
                return kFastMovingAirFriction
            end
    
                -- celerity decreases base friction from 0.17 to 0.14 at lower speeds
            return stormFriction - self:GetSpurLevel() * 0.01
    
        elseif currentSpeed > kBlinkMaxSpeedBase * ( 1 + stormBonus) then
    
            -- no celerity, but fast
            return kFastMovingAirFriction
    
        else
    
            -- no celerity and slow
            return stormFriction
    
        end

    end
end