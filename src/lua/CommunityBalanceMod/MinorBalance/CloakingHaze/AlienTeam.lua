
local oldInitTechTree = AlienTeam.InitTechTree
function AlienTeam:InitTechTree()

    local oldSetComplete = TechTree.SetComplete
    TechTree.SetComplete = function() end
    
    oldInitTechTree(self)    
    
    self.techTree:AddTargetedActivation(kTechId.CloakingHaze,      kTechId.ShadeHive,      kTechId.None)
    
    TechTree.SetComplete = oldSetComplete
    self.techTree:SetComplete()
    
end