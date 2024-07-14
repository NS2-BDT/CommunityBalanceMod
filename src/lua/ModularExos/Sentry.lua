local SentryOnWeldOverride = Sentry.OnWeldOverride
function Sentry:OnWeldOverride(entity, elapsedTime)
    
    SentryOnWeldOverride(self, entity, elapsedTime)
    
    if entity:isa("ExoWelder") then
        Print("blabla")
        local amount = kWelderSentryRepairRate * elapsedTime
        self:AddHealth(amount)
    end
end
