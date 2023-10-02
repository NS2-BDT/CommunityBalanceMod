

local oldArmoryOnResearchComplete = Armory.OnResearchComplete
function Armory:OnResearchComplete(researchId)

    oldArmoryOnResearchComplete(self, researchId)

    if researchId == kTechId.AdvancedArmoryUpgrade then
        if HasMixin(self, "MapBlip") then 
            self:MarkBlipDirty()
        end
    end
end
