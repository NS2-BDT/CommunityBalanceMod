



function Whip:UpdateRootState()

    local infested = self:GetGameEffectMask(kGameEffect.OnInfestation)
    local moveOrdered = self:GetCurrentOrder() and self:GetCurrentOrder():GetType() == kTechId.Move
    

    -- unroot if we have a move order or infestation recedes
    if self.rooted and (moveOrdered or (not infested  and not self:GetIsMature()  )) then --Balance Mod: No infestation requirement for matured whips to root
        self:Unroot()
    end

    -- root if on infestation and not moving/teleporting
    if not self.rooted and (infested or self:GetIsMature() )  and not (moveOrdered or self:GetIsTeleporting()) then --Balance Mod: No infestation requirement for matured whips to root
        self:Root()
    end

end
