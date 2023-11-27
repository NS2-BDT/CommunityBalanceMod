

function Skulk:GetMaxWallJumpSpeed()
    local celerityMod = (GetHasCelerityUpgrade(self) and self:GetSpurLevel() or 0) * Skulk.kWallJumpMaxSpeedCelerityBonus/3.0

    if self.stormed then 
        return Skulk.kWallJumpMaxSpeed + celerityMod + Skulk.kWallJumpMaxSpeed * 0.2
    end

    return Skulk.kWallJumpMaxSpeed + celerityMod
end


function Skulk:GetMaxBunnyHopSpeed()
    local celerityMod = (GetHasCelerityUpgrade(self) and self:GetSpurLevel() or 0) * Skulk.kBunnyHopMaxSpeedCelerityBonus / 3.0

    if self.stormed then 
        return Skulk.kBunnyHopMaxSpeed + celerityMod + Skulk.kBunnyHopMaxSpeed * 0.2
    end

    return Skulk.kBunnyHopMaxSpeed + celerityMod
end

