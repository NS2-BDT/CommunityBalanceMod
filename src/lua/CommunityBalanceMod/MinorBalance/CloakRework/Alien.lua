function Alien:GetIsCamouflaged()
    return GetHasCamouflageUpgrade(self) --and not self:GetIsInCombat()
end