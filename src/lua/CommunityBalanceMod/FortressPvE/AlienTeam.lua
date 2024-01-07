
local oldInitTechTree = AlienTeam.InitTechTree
function AlienTeam:InitTechTree()

    local oldSetComplete = TechTree.SetComplete
    TechTree.SetComplete = function() end
    
    oldInitTechTree(self)    
    
    self.techTree:AddActivation(kTechId.HallucinateRandom)
    self.techTree:AddTargetedActivation(kTechId.HallucinateCloning)

    self.techTree:AddBuildNode(kTechId.FortressCrag,               kTechId.Crag,        kTechId.None)
    self.techTree:AddActivation(kTechId.FortressCragAbility,                kTechId.FortressCrag,          kTechId.CragHive)
    self.techTree:AddUpgradeNode(kTechId.UpgradeToFortressCrag,  kTechId.Crag)
    self.techTree:AddBuildNode(kTechId.FortressShift,               kTechId.Shift,        kTechId.None)
    self.techTree:AddActivation(kTechId.FortressShiftAbility,                kTechId.FortressShift,          kTechId.ShiftHive)
    self.techTree:AddUpgradeNode(kTechId.UpgradeToFortressShift,  kTechId.Shift)
    self.techTree:AddBuildNode(kTechId.FortressShade,               kTechId.Shade,        kTechId.None)
    self.techTree:AddActivation(kTechId.ShadeHallucination,                kTechId.FortressShade,          kTechId.ShadeHive)
    self.techTree:AddUpgradeNode(kTechId.UpgradeToFortressShade,  kTechId.Shade)
    self.techTree:AddBuildNode(kTechId.FortressWhip,               kTechId.Whip,        kTechId.None)
    self.techTree:AddActivation(kTechId.WhipAbility,               kTechId.None,          kTechId.None)
    self.techTree:AddActivation(kTechId.FortressWhipAbility,                kTechId.FortressWhip,          kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.UpgradeToFortressWhip,  kTechId.Whip)


    self.techTree:ChangeNode(kTechId.ShiftEcho) -- removed Shifthive prereq
    self.techTree:ChangeNode(kTechId.SelectShift) -- removed Shifthive prereq
    self.techTree:ChangeNode(kTechId.HealWave) -- removed Craghive prereq
    self.techTree:ChangeNode(kTechId.ShadeInk) -- removed Shadethive prereq

    self.techTree:ChangeNode(kTechId.TeleportHarvester) -- removed Shifthive prereq
    self.techTree:ChangeNode(kTechId.TeleportWhip) -- removed Shifthive prereq
    self.techTree:ChangeNode(kTechId.TeleportCrag) -- removed Shifthive prereq
    self.techTree:ChangeNode(kTechId.TeleportShade) -- removed Shifthive prereq
    self.techTree:ChangeNode(kTechId.TeleportShift) -- removed Shifthive prereq
    self.techTree:ChangeNode(kTechId.TeleportVeil) -- removed Shifthive prereq
    self.techTree:ChangeNode(kTechId.TeleportShell) -- removed Shifthive prereq
    self.techTree:ChangeNode(kTechId.TeleportHive) -- removed Shifthive prereq
    self.techTree:ChangeNode(kTechId.TeleportEgg) -- removed Shifthive prereq


    
    TechTree.SetComplete = oldSetComplete
    self.techTree:SetComplete()
    
end