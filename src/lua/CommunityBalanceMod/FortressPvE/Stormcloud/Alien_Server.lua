-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================



function Alien:TriggerStorm(duration)

    if not self:GetIsOnFire() and not self:GetElectrified() then
        self.timeWhenStormExpires = math.max(self.timeWhenStormExpires, duration + Shared.GetTime())
    end
end



local oldAlienOnProcessMove = Alien.OnProcessMove
function Alien:OnProcessMove(input)
    oldAlienOnProcessMove(self, input)
    if not self:GetIsDestroyed() then
        self.stormed = self.timeWhenStormExpires > Shared.GetTime() 
    end
end

