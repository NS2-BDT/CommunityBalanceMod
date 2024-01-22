-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================



function PrototypeLab:UpdateResearch()

    local researchId = self:GetResearchingId()

    if researchId == kTechId.UpgradeToAdvancedPrototypeLab then
    
        local techTree = self:GetTeam():GetTechTree()    
        local researchNode = techTree:GetTechNode(kTechId.ExosuitTech)   
        researchNode:SetResearchProgress(self.researchProgress)
        techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress)) 
        
    end

end


function PrototypeLab:OnResearchCancel(researchId)

    if researchId == kTechId.UpgradeToAdvancedPrototypeLab then
    
        local team = self:GetTeam()
        
        if team then
        
            local techTree = team:GetTechTree()
            local researchNode = techTree:GetTechNode(kTechId.ExosuitTech)
            if researchNode then
                researchNode:ClearResearching()
                techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", 0))   
            end
        end  
    end
end

-- Called when research or upgrade complete
function PrototypeLab:OnResearchComplete(researchId)

    if researchId == kTechId.UpgradeToAdvancedPrototypeLab then
    
        self:SetTechId(kTechId.AdvancedPrototypeLab)
        
        local techTree = self:GetTeam():GetTechTree()
        local researchNode = techTree:GetTechNode(kTechId.ExosuitTech)
        
        if researchNode then     
   
            researchNode:SetResearchProgress(1)
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress))
            researchNode:SetResearched(true)
            techTree:QueueOnResearchComplete(kTechId.ExosuitTech, self)
            
        end
        
    end
end