-- ========= Community Balance Mod ===============================
--
--  "lua\Babbler.lua"
--
--    Created by:   Twiliteblue, Drey (@drey3982)
--
-- ===============================================================


--[[

Babbler didn't register when it did damage
It just uncloaked when it attacked
And they almost never stop moving completely so they couldn't cloak when free roaming

]]

function Babbler:GetSpeedScalar()
    if self.clinged then
        local parent = self:GetParent()
        if parent and parent.GetSpeedScalar then
            return parent:GetSpeedScalar()
        end
    end
    
    if Client and self.clientVelocity then
        return self.clientVelocity:GetLength() / self:GetMaxSpeed()
    end
    
    return self:GetVelocity():GetLength() / self:GetMaxSpeed()
end

function Babbler:OnDamageDone(doer, target)
    
    self.timeLastDamageDealt = Shared.GetTime()

end