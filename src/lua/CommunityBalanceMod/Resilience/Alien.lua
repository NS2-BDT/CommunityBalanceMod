local netVars = {
    resilienceTimeEnd = "time"
}

oldOnCreate = Alien.OnCreate
function Alien:OnCreate()
    oldOnCreate(self)

    self.resilienceTimeEnd = Shared.GetTime()
end

function Alien:GetRecuperationRate()
    local scalar = ConditionalValue(self:GetGameEffectMask(kGameEffect.OnFire), kOnFireEnergyRecuperationScalar, 1)
    scalar = scalar * (self.electrified and kElectrifiedEnergyRecuperationScalar or 1)

    local canHaveResilienceBoost = self:GetHasUpgrade(kTechId.Resilience) and Shared.GetTime() < self.resilienceTimeEnd
    local shellCount = self:GetShellLevel()
    scalar = scalar * ConditionalValue(canHaveResilienceBoost, 1 + ((1.25 / 3) * shellCount), 1)

    local rate = self:GetLifeformEnergyRechargeRate()
    rate = rate * scalar

    return rate
end

Shared.LinkClassToMap("Alien", Alien.kMapName, netVars, true)
