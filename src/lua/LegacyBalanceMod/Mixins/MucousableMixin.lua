if Server then
    function MucousableMixin:SetMucousShield()
        -- Electrified effect prevents mucous.
        if self.GetElectrified and self:GetElectrified() then
            return
        end

        -- Hallucinations shouldn't have mucous applied to them
        if HasMixin(self, "PlayerHallucination") or self:isa("Hallucination") then
            return
        end

        local resilienceScalar = GetResilienceScalar(self, false)

        local time = Shared.GetTime()
        if self.lastMucousShield + kMucousShieldCooldown * resilienceScalar < time then
            self.shieldRemaining = self:GetMaxShieldAmount()
            self.mucousShield = true
            self.lastMucousShield = time
        end
    end 
end
