-- ========= Community Balance Mod ===============================
--
-- "lua\Veil.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


function Veil:OnUpdate(deltaTime)

    if Server then
        self.camouflaged = not self:GetIsInCombat()
    end
end

function Veil:GetIsCamouflaged()
    return self.camouflaged and self:GetIsBuilt()
end