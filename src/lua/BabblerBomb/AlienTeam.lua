local oldInitTechTree = AlienTeam.InitTechTree
function AlienTeam:InitTechTree()

    local oldSetComplete = TechTree.SetComplete
    TechTree.SetComplete = function() end
    
    oldInitTechTree(self)
        
    self.techTree:AddResearchNode(kTechId.BabblerBombAbility,            kTechId.BioMassSeven, kTechId.None, kTechId.AllAliens)
    
    TechTree.SetComplete = oldSetComplete
    self.techTree:SetComplete()
    
end
