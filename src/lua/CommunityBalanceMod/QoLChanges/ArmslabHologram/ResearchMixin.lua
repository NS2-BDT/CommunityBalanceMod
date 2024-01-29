-- ========= Community Balance Mod ===============================
--
-- "lua\ArmsLab.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


function ResearchMixin:OnUpdateAnimationInput(modelMixin)

    if self.researchingId == kTechId.Weapons1
    or self.researchingId == kTechId.Weapons2
    or self.researchingId == kTechId.Weapons3
    or self.researchingId == kTechId.Armor1
    or self.researchingId == kTechId.Armor2
    or self.researchingId == kTechId.Armor3 then 
        return
    end

    PROFILE("ResearchMixin:OnUpdateAnimationInput")
    modelMixin:SetAnimationInput("researching", self:GetIsResearching())
    
end
