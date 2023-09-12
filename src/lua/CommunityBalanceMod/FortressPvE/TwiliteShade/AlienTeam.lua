local oldInitTechTree = AlienTeam.InitTechTree
function AlienTeam:InitTechTree()

    local oldSetComplete = TechTree.SetComplete
    TechTree.SetComplete = function() end
    
    oldInitTechTree(self)    
    
    --self.techTree:AddTargetedActivation(kTechId.ShadeHallucination,      kTechId.FortressShade,      kTechId.None)
    self.techTree:AddActivation(kTechId.ShadeHallucination,      kTechId.None,      kTechId.None)
    
    TechTree.SetComplete = oldSetComplete
    self.techTree:SetComplete()
    
end
