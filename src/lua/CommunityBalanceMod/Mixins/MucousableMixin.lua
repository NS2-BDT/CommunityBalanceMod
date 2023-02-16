function MucousableMixin:GetShieldTimeRemaining()
    local percentLeft = 0
    local resilienceScalar = GetResilienceScalar(self, false)

    if self.mucousShield and self.lastMucousShield > 0 then
        percentLeft = Clamp( math.abs( (self.lastMucousShield + kMucousShieldDuration * resilienceScalar) - Shared.GetTime() ) / (kMucousShieldDuration * resilienceScalar), 0.0, 1.0 )
    end

    return percentLeft
end

local function SharedUpdate(self)
    if Server then
        local resilienceScalar = GetResilienceScalar(self, false)
        self.mucousShield = self.lastMucousShield + kMucousShieldDuration * resilienceScalar >= Shared.GetTime() and self.shieldRemaining > 0
        if not self.mucousShield and self.shieldRemaining > 0 then
            self.shieldRemaining = 0
        end
    end
end

function MucousableMixin:OnProcessMove(input)   
    SharedUpdate(self)
end

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
