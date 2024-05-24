-- Natural Selection 2 Competitive Mod
-- Source located at - https://github.com/xToken/CompMod
-- lua\CompMod\Mixins\NanoShieldMixin\shared.lua
-- - Dragon


function NanoShieldMixin:ComputeDamageOverrideMixin(attacker, damage, damageType, time)
    
    if self.nanoShielded == true then
        if self.NanoShieldDamageReductionOverride then
            return damage * self:NanoShieldDamageReductionOverride(), damageType
        end
        return damage * kNanoShieldDamageReductionDamage, damageType
    end
    
    return damage

end

local ClearNanoShield = debug.getupvaluex(NanoShieldMixin.OnDestroy, "ClearNanoShield")
function NanoShieldMixin:DeactivateNanoShield()
    ClearNanoShield(self, true)
end