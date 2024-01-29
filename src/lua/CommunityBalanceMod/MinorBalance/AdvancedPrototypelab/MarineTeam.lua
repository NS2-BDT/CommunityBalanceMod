-- ========= Community Balance Mod ===============================
--
-- "lua\MarineTeam.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================




local oldInitTechTree = MarineTeam.InitTechTree
function MarineTeam:InitTechTree()

    local oldSetComplete = TechTree.SetComplete
    TechTree.SetComplete = function() end
    
    oldInitTechTree(self)    
    
    self.techTree:AddBuildNode(kTechId.AdvancedPrototypeLab,               kTechId.PrototypeLab,        kTechId.None)
    self.techTree:ChangeNode(kTechId.ExosuitTech, kTechId.AdvancedPrototypeLab)
    self.techTree:AddUpgradeNode(kTechId.UpgradeToAdvancedPrototypeLab,  kTechId.PrototypeLab)

    TechTree.SetComplete = oldSetComplete
    self.techTree:SetComplete()
    
end



function MarineTeam:SpawnWarmUpStructures()
    local techPoint = self.startTechPoint
    if not (Shared.GetCheatsEnabled() and MarineTeam.gSandboxMode) and #self.warmupStructures == 0 then
        self.warmupStructures[#self.warmupStructures+1] = MakeTechEnt(techPoint, AdvancedArmory.kMapName, 3.5, -2, kMarineTeamType)
        self.warmupStructures[#self.warmupStructures+1] = MakeTechEnt(techPoint, AdvancedPrototypeLab.kMapName, -3.5, 2, kMarineTeamType)
    end
end

function MarineTeam:SpawnInitialStructures(techPoint)

    self.warmupStructures = {}
    self.startTechPoint = techPoint
    self.spawnedInfantryPortal = 0
    takenInfantryPortalPoints = {}

    local tower, commandStation = PlayingTeam.SpawnInitialStructures(self, techPoint)

    self:SpawnInfantryPortal(techPoint)
    -- Spawn a second IP when marines have 9 or more players
    if self:GetNumPlayers() >= kSecondInitialInfantryPortalMinPlayerCount then
        self:SpawnInfantryPortal(techPoint)
    end

    if Shared.GetCheatsEnabled() and MarineTeam.gSandboxMode then
        MakeTechEnt(techPoint, AdvancedArmory.kMapName, 3.5, -2, kMarineTeamType)
        MakeTechEnt(techPoint, AdvancedPrototypeLab.kMapName, -3.5, 2, kMarineTeamType)
    end

    return tower, commandStation

end
