

function Exosuit:OnWeldOverride(doer, elapsedTime, weldPerSecOverride)

    -- macs weld marines by only 50% of the rate
    local macMod = (HasMixin(self, "Combat") and self:GetIsInCombat()) and 0.1 or 0.5    
    local weldMod = ( doer ~= nil and doer:isa("MAC") ) and macMod or 1

    --balance mod
    local catpackBonus = 1
    if doer ~= nil then 
        local doerParent = doer:GetParent()
        if doerParent ~= nil and doerParent:isa("Marine") and doerParent:GetHasCatPackBoost() then 
        catpackBonus = 1.125
    end

    if self:GetArmor() < self:GetMaxArmor() then
    
        local addArmor = (weldPerSecOverride or kPlayerArmorWeldRate) * elapsedTime * weldMod * catpackBonus
        self:SetArmor(self:GetArmor() + addArmor)
        
    end
    
end
