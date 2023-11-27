
function Veil:OnUpdate(deltaTime)

    if Server then
        self.camouflaged = not self:GetIsInCombat()
    end
end

function Veil:GetIsCamouflaged()
    return self.camouflaged and self:GetIsBuilt()
end