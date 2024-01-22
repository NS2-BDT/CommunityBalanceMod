-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


--only change at line 35-37

local kBurnUpdateRate = 0.5

function FireMixin:UpdateFireState()
    PROFILE("FireMixin:UpdateFireState")

    if Client then
        self:UpdateFireMaterial()
        self:_UpdateClientFireEffects()
    end

    if Server and self:GetIsOnFire() then
        local time = Shared.GetTime()
        if self:GetIsAlive() and (not self.timeLastFireDamageUpdate or self.timeLastFireDamageUpdate + kBurnUpdateRate <= time) then

            local attacker
            if self.fireAttackerId ~= Entity.invalidId then
                attacker = Shared.GetEntity(self.fireAttackerId)
            end

            local doer
            if self.fireDoerId ~= Entity.invalidId then
                doer = Shared.GetEntity(self.fireDoerId)
            end

            local damageOverTime = kBurnUpdateRate * kBurnDamagePerSecond

            -- Upgrade damage based on marine weapons upgrades if we are on that team.
            local scalar = 1

            if attacker then -- Sanity check, but EntityChangeMixin should cause us to update our attacker entity id here.

                --Balance Mod: add target for DamageTypes.lua
                local target = self
                scalar = NS2Gamerules_GetUpgradedDamageScalar( attacker, kTechId.Flamethrower, target)
            end

            damageOverTime = damageOverTime * scalar

            if self.GetReceivesStructuralDamage and self:GetReceivesStructuralDamage() then
                damageOverTime = damageOverTime * kStructuralDamageScalar
            end

            if self.GetIsFlameAble and self:GetIsFlameAble() then
                damageOverTime = damageOverTime * kFlameableMultiplier
            end

            local _, damageDone = self:DeductHealth(damageOverTime, attacker, doer)

            if attacker then
                SendDamageMessage( attacker, self:GetId(), damageDone, self:GetOrigin(), damageDone )
            end

            self.timeLastFireDamageUpdate = time

        end

        -- See if we put ourselves out
        if time - self.timeBurnRefresh > self.timeBurnDuration then
            self:SetGameEffectMask(kGameEffect.OnFire, false)
        end

    end

    return self:GetIsOnFire() -- remove timed callback when we are not burning
end
