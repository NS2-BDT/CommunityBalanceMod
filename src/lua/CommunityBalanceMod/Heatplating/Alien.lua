local netVars = {
    heatplatingTimeEnd = "time"
}

oldOnCreate = Alien.OnCreate
function Alien:OnCreate()
    oldOnCreate(self)

    self.heatplatingTimeEnd = Shared.GetTime()
end

function Alien:GetRecuperationRate()
    local scalar = ConditionalValue(self:GetGameEffectMask(kGameEffect.OnFire), kOnFireEnergyRecuperationScalar, 1)
    scalar = scalar * (self.electrified and kElectrifiedEnergyRecuperationScalar or 1)

    local canHaveHeatplatingBoost = self:GetHasUpgrade(kTechId.Heatplating) and Shared.GetTime() < self.heatplatingTimeEnd
    local shellCount = self:GetShellLevel()
    scalar = scalar * ConditionalValue(canHaveHeatplatingBoost, 1 + ((1.25 / 3) * shellCount), 1)

    local rate = self:GetLifeformEnergyRechargeRate()
    rate = rate * scalar

    return rate
end

Shared.LinkClassToMap("Alien", Alien.kMapName, netVars, true)
