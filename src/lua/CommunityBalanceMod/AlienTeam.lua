-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\AlienTeam.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- This class is used for teams that are actually playing the game, e.g. Marines or Aliens.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/TechData.lua")
Script.Load("lua/Skulk.lua")
Script.Load("lua/PlayingTeam.lua")
Script.Load("lua/bots/AlienTeamBrain.lua")


class 'AlienTeam' (PlayingTeam)

-- Innate alien regeneration
AlienTeam.kAutoHealInterval = 2
AlienTeam.kStructureAutoHealInterval = 0.5
AlienTeam.kAutoHealUpdateNum = 20 -- number of structures to update per autoheal update

AlienTeam.kInfestationUpdateRate = 2

function AlienTeam:GetTeamType()
    return kAlienTeamType
end

function AlienTeam:GetIsAlienTeam()
    return true
end

function AlienTeam:GetTeamBrain()  --TODO Ideally, this should NOT late-init. Better to init, and perform conditional updates than get hit at run-time
    if self.brain == nil then
        self.brain = AlienTeamBrain()
        self.brain:Initialize(self.teamName.."-Brain", self:GetTeamNumber())
    end

    return self.brain
end

function AlienTeam:Initialize(teamName, teamNumber)

    PlayingTeam.Initialize(self, teamName, teamNumber)

    self.respawnEntity = Skulk.kMapName

    -- List stores all the structures owned by builder player types such as the Gorge.
    -- This list stores them based on the player platform ID in order to maintain structure
    -- counts even if a player leaves and rejoins a server.
    self.clientOwnedStructures = { }
    self.clientStructuresOwner = { }
    self.lastAutoHealIndex = 1

    self.updateAlienArmorInTicks = nil

    self.timeLastWave = 0
    self.bioMassLevel = 0
    self.inProgressBiomassLevel = 0
    self.bioMassAlertLevel = 0
    self.maxBioMassLevel = 0
    self.bioMassFraction = 0

end

function AlienTeam:OnInitialized()

    PlayingTeam.OnInitialized(self)

    self.lastAutoHealIndex = 1

    self.clientOwnedStructures = { }
    self.clientStructuresOwner = { }

    self.timeLastWave = 0
    self.bioMassLevel = 0
    self.bioMassAlertLevel = 0
    self.maxBioMassLevel = 0
    self.bioMassFraction = 0

    self.activeStructureSkin = kDefaultAlienStructureVariant
    self.activeTunnelSkin = kDefaultAlienTunnelVariant
    self.activeHarvesterSkin = kDefaultHarvesterVariant
    self.activeEggSkin = kDefaultEggVariant
    self.activeDrifterSkin = kDefaultAlienDrifterVariant
    self.activeCystSkin = kDefaultAlienCystVariant

end

function AlienTeam:OnResetComplete()

    --adjust first power node
    local initialTechPoint = self:GetInitialTechPoint()
    local locationName = initialTechPoint:GetLocationName()
    DestroyPowerForLocation(locationName, true)

    local commander = self:GetCommander()
    local gameInfo = GetGameInfoEntity()
    local teamIdx = self:GetTeamNumber()
    
    if commander then

        local commStructSkin = commander:GetCommanderStructureSkin()
        local commDrifterSkin = commander:GetCommanderDrifterSkin()
        local commHarvesterSkin = commander:GetCommanderHarvesterSkin()
        local commEggSkin = commander:GetCommanderEggSkin()
        local commCystSkin = commander:GetCommanderCystSkin()
        local commTunnelSkin = commander:GetCommanderTunnelSkin()
        
        if commStructSkin then
            self.activeStructureSkin = commStructSkin
            local skinnedEnts = GetEntitiesWithMixinForTeam( "AlienStructureVariant", teamIdx )
            for i, ent in ipairs(skinnedEnts) do
                ent.structureVariant = commStructSkin
            end
            gameInfo:SetTeamCosmeticSlot( teamIdx, kTeamCosmeticSlot1, commStructSkin )
        end

        if commHarvesterSkin then
            self.activeHarvesterSkin = commHarvesterSkin
            local skinnedEnts = GetEntitiesWithMixinForTeam( "HarvesterVariant", teamIdx )
            for i, ent in ipairs(skinnedEnts) do
                ent.harvesterVariant = commHarvesterSkin
            end
            gameInfo:SetTeamCosmeticSlot( teamIdx, kTeamCosmeticSlot2, commHarvesterSkin )
        end

        if commTunnelSkin then
            self.activeTunnelSkin = commTunnelSkin
            local skinnedEnts = GetEntitiesWithMixinForTeam( "AlienTunnelVariant", teamIdx )
            for i, ent in ipairs(skinnedEnts) do
                ent.tunnelVariant = commTunnelSkin
            end
            gameInfo:SetTeamCosmeticSlot( teamIdx, kTeamCosmeticSlot3, commTunnelSkin )
        end

        if commEggSkin then
            self.activeEggSkin = commEggSkin
            local skinnedEnts = GetEntitiesWithMixinForTeam( "EggVariant", teamIdx )
            for i, ent in ipairs(skinnedEnts) do
                ent.eggVariant = commEggSkin
            end
            gameInfo:SetTeamCosmeticSlot( teamIdx, kTeamCosmeticSlot4, commEggSkin )
        end

        if commCystSkin then
            self.activeEggSkin = commCystSkin
            local skinnedEnts = GetEntitiesWithMixinForTeam( "CystVariant", teamIdx )
            for i, ent in ipairs(skinnedEnts) do
                ent.eggVariant = commCystSkin
            end
            gameInfo:SetTeamCosmeticSlot( teamIdx, kTeamCosmeticSlot5, commCystSkin )
        end

        if commDrifterSkin then
            self.activeDrifterSkin = commDrifterSkin
            local skinnedEnts = GetEntitiesWithMixinForTeam( "DrifterVariant", teamIdx )
            for i, ent in ipairs(skinnedEnts) do
                ent.drifterVariant = commDrifterSkin
            end
            gameInfo:SetTeamCosmeticSlot( teamIdx, kTeamCosmeticSlot6, commDrifterSkin )
        end

    else

        gameInfo:SetTeamCosmeticSlot( teamIdx, kTeamCosmeticSlot1, kDefaultAlienStructureVariant )
        gameInfo:SetTeamCosmeticSlot( teamIdx, kTeamCosmeticSlot2, kDefaultHarvesterVariant )
        gameInfo:SetTeamCosmeticSlot( teamIdx, kTeamCosmeticSlot3, kDefaultAlienTunnelVariant )
        gameInfo:SetTeamCosmeticSlot( teamIdx, kTeamCosmeticSlot4, kDefaultEggVariant )
        gameInfo:SetTeamCosmeticSlot( teamIdx, kTeamCosmeticSlot5, kDefaultAlienCystVariant )
        gameInfo:SetTeamCosmeticSlot( teamIdx, kTeamCosmeticSlot6, kDefaultAlienDrifterVariant )
        
    end

end


function AlienTeam:SetHiveSkinVariant( skinIndex )
    self.activeStructureSkin = skinIndex
end

function AlienTeam:SetDrifterSkinVariant( skinIndex )
    self.activeDrifterSkin = skinIndex
end

function AlienTeam:SetTunnelSkinVariant( skinIndex )
    self.activeTunnelSkin = skinIndex
end

function AlienTeam:SetHarvesterSkinVariant( skinIndex )
    self.activeHarvesterSkin = skinIndex
end

function AlienTeam:SetCystSkinVariant( skinIndex )
    self.activeCystSkin = skinIndex
end

function AlienTeam:SetEggSkinVariant( skinIndex )
    self.activeEggSkin = skinIndex
end

function AlienTeam:GetTeamInfoMapName()
    return AlienTeamInfo.kMapName
end

function AlienTeam:GetEggCount()
    return self.eggCount or 0
end

local kBioMassTechIds =
{
    kTechId.BioMassOne,
    kTechId.BioMassTwo,
    kTechId.BioMassThree,
    kTechId.BioMassFour,
    kTechId.BioMassFive,
    kTechId.BioMassSix,
    kTechId.BioMassSeven,
    kTechId.BioMassEight,
    kTechId.BioMassNine,
    kTechId.BioMassTen,
    kTechId.BioMassEleven,
    kTechId.BioMassTwelve
}
function AlienTeam:UpdateBioMassLevel()

    local newBiomass = 0
    self.bioMassAlertLevel = 0
    self.bioMassFraction = 0
    self.inProgressBiomassLevel = 0
    local progress = 0

    local ents = GetEntitiesForTeam("Hive", self:GetTeamNumber())

    for _, entity in ipairs(ents) do

        if entity:GetIsAlive() then

            local currentBioMass = entity:GetBioMassLevel()
            newBiomass = newBiomass + currentBioMass

            self.inProgressBiomassLevel = self.inProgressBiomassLevel + currentBioMass

            local bioMassAdd = entity.biomassResearchFraction

            if bioMassAdd > 0 then
                self.inProgressBiomassLevel = self.inProgressBiomassLevel + 1
            end

            if not entity:GetIsBuilt() then
                bioMassAdd = bioMassAdd + entity:GetBuiltFraction()
                self.inProgressBiomassLevel = self.inProgressBiomassLevel + 1
            end

            if bioMassAdd > progress then
                progress = bioMassAdd
            end

            currentBioMass = currentBioMass + bioMassAdd

            currentBioMass = currentBioMass * entity:GetHealthScalar()

            self.bioMassFraction = self.bioMassFraction + currentBioMass

            if Shared.GetTime() - entity:GetTimeLastDamageTaken() < 7 then
                self.bioMassAlertLevel = self.bioMassAlertLevel + currentBioMass
            end

        end

    end

    self:SetBiomassLevel(newBiomass)

    if self.techTree then

        for i = 1, #kBioMassTechIds do

            local techId = kBioMassTechIds[i]
            local techNode = self.techTree:GetTechNode(techId)
            if techNode then

                local techNodeProgress = i == self.bioMassLevel + 1 and progress or 0
                if techNode:GetResearchProgress() ~= techNodeProgress then
                    techNode:SetResearchProgress(techNodeProgress)
                    self.techTree:SetTechNodeChanged(techNode, string.format("researchProgress = %.2f", techNodeProgress))
                end
            end

        end

    end

    self.maxBioMassLevel = 0

    for _, hive in ipairs(GetEntitiesForTeam("Hive", self:GetTeamNumber())) do

        if GetIsUnitActive(hive) then
            self.maxBioMassLevel = self.maxBioMassLevel + 4
        end

    end

end

function AlienTeam:GetInProgressBiomassLevel()
    return self.inProgressBiomassLevel
end

function AlienTeam:OnUpdateBiomass(oldBiomass, newBiomass)
    if self.techtree then
        self.techTree:SetTechChanged()
    end

    local ents = GetEntitiesWithMixin("BiomassHealth")
    for i = 1, #ents do
        local ent = ents[i]
        ent:UpdateHealthAmount(newBiomass)
    end
end

function AlienTeam:SetBiomassLevel(newBiomass)
    newBiomass = math.min(12, newBiomass)
    if self.bioMassLevel == newBiomass then return end

    self:OnUpdateBiomass(self.bioMassLevel, newBiomass)
    self.bioMassLevel = newBiomass
end

function AlienTeam:GetMaxBioMassLevel()
    if GetWarmupActive() then return 9 end

    return self.maxBioMassLevel
end

function AlienTeam:GetBioMassLevel()
    if GetWarmupActive() then return 9 end

    return self.bioMassLevel
end

function AlienTeam:GetBioMassAlertLevel()
    if GetWarmupActive() then return 0 end

    return self.bioMassAlertLevel
end

function AlienTeam:GetBioMassFraction()
    if GetWarmupActive() then return 9 end

    return self.bioMassFraction
end

function AlienTeam:RemoveGorgeStructureFromClient(techId, clientId)

    local structureTypeTable = self.clientOwnedStructures[clientId]

    if structureTypeTable then

        if not structureTypeTable[techId] then

            structureTypeTable[techId] = { }
            return

        end

        local removeIndex = 0
        local structure
        for index, id in ipairs(structureTypeTable[techId])  do

            if id then

                removeIndex = index
                structure = Shared.GetEntity(id)
                break

            end

        end

        if structure then

            table.remove(structureTypeTable[techId], removeIndex)
            structure.consumed = true
            if structure:GetCanDie() then
                structure:Kill()
            else
                DestroyEntity(structure)
            end

        end

    end

end

function AlienTeam:AddGorgeStructure(player, structure)

    if player ~= nil and structure ~= nil then

        local clientId = Server.GetOwner(player):GetUserId()
        local structureId = structure:GetId()
        local techId = structure:GetTechId()

        if not self.clientOwnedStructures[clientId] then
            table.insert(self.clientStructuresOwner, clientId)
            self.clientOwnedStructures[clientId] = {
                techIds = {}
            }
        end

        local structureTypeTable = self.clientOwnedStructures[clientId]

        if not structureTypeTable[techId] then
            structureTypeTable[techId] = {}
            table.insert(structureTypeTable.techIds, techId)
        end

        table.insertunique(structureTypeTable[techId], structureId)

        local numAllowedStructure = LookupTechData(techId, kTechDataMaxAmount, -1) --* self:GetNumHives()

        if numAllowedStructure >= 0 and #structureTypeTable[techId] > numAllowedStructure then
            self:RemoveGorgeStructureFromClient(techId, clientId)
        end

    end

end

function AlienTeam:GetDroppedGorgeStructures(player, techId)

    local owner = Server.GetOwner(player)

    if owner then

        local clientId = owner:GetUserId()
        local structureTypeTable = self.clientOwnedStructures[clientId]

        if structureTypeTable then
            return structureTypeTable[techId]
        end

    end

end

function AlienTeam:GetNumDroppedGorgeStructures(player, techId)

    local structureTypeTable = self:GetDroppedGorgeStructures(player, techId)
    return (not structureTypeTable and 0) or #structureTypeTable

end

function AlienTeam:UpdateClientOwnedStructures(oldEntityId)

    if oldEntityId then

        for _, clientId in ipairs(self.clientStructuresOwner) do

            local structureTypeTable = self.clientOwnedStructures[clientId]
            for _, techId in ipairs(structureTypeTable.techIds) do

                local structureList = structureTypeTable[techId]
                for i, structureId in ipairs(structureList) do

                    if structureId == oldEntityId then

                        table.remove(structureList, i)
                        break

                    end

                end

            end

        end

    end

end

function AlienTeam:OnEntityChange(oldEntityId, newEntityId)

    PlayingTeam.OnEntityChange(self, oldEntityId, newEntityId)

    -- Check if the oldEntityId matches any client's built structure and
    -- handle the change.

    self:UpdateClientOwnedStructures(oldEntityId)

end

local function CreateCysts(hive, harvester, teamNumber)

    local hiveOrigin = hive:GetOrigin()
    local harvesterOrigin = harvester:GetOrigin()

    -- Spawn all the Cyst spawn points close to the hive.
    local dist = (hiveOrigin - harvesterOrigin):GetLength()
    for c = 1, #Server.cystSpawnPoints do

        local spawnPoint = Server.cystSpawnPoints[c]
        if (spawnPoint - hiveOrigin):GetLength() <= (dist * 3) then

            local cyst = CreateEntityForTeam(kTechId.Cyst, spawnPoint, teamNumber, nil)
            cyst:SetConstructionComplete()
            cyst:SetInfestationFullyGrown()
            cyst:SetImmuneToRedeploymentTime(1)

        end

    end

end

function AlienTeam:SpawnInitialStructures(techPoint)

    local tower, hive = PlayingTeam.SpawnInitialStructures(self, techPoint)

    hive:SetFirstLogin()
    hive:SetInfestationFullyGrown()

    -- It is possible there was not an available tower if the map is not designed properly.
    if tower then
        CreateCysts(hive, tower, self:GetTeamNumber())
    end

    return tower, hive

end

function AlienTeam:GetHasAbilityToRespawn()

    local hives = GetEntitiesForTeam("Hive", self:GetTeamNumber())
    return table.icount(hives) > 0

end

function AlienTeam:UpdateEggCount()

    self.eggCount = 0

    for _, egg in ipairs(GetEntitiesForTeam("Egg", self:GetTeamNumber())) do

        if egg:GetIsFree() and egg:GetGestateTechId() == kTechId.Skulk then
            self.eggCount = self:GetEggCount() + 1
        end

    end

end

function AlienTeam:AssignPlayerToEgg(player, enemyTeamPosition)

    local success = false

    local spawnPoint = player:GetDesiredSpawnPoint()

    if not spawnPoint then
        spawnPoint = enemyTeamPosition or player:GetOrigin()
    end

    local eggs = GetEntitiesForTeam("Egg", self:GetTeamNumber())
    Shared.SortEntitiesByDistance(spawnPoint, eggs)

    -- Find the closest egg, doesn't matter which Hive owns it.
    for _, egg in ipairs(eggs) do

        -- Any unevolved egg is fine as long as it is free, and make sure its not a lifeform egg.
        if egg:GetIsFree() then

            if egg:GetGestateTechId() == kTechId.Skulk then

                egg:SetQueuedPlayerId(player:GetId())
                success = true
                break

            end

        end

    end

    return success

end

function AlienTeam:GetCriticalHivePosition()

    -- get position of enemy team, ignore commanders
    local numPositions = 0
    local teamPosition = Vector(0, 0, 0)

    for _, player in ipairs( GetEntitiesForTeam("Player", GetEnemyTeamNumber(self:GetTeamNumber())) ) do

        if (player:isa("Marine") or player:isa("Exo")) and player:GetIsAlive() then

            numPositions = numPositions + 1
            teamPosition = teamPosition + player:GetOrigin()

        end

    end

    if numPositions > 0 then
        return teamPosition / numPositions
    end

end

function AlienTeam:UpdateEggGeneration()

    if not self.timeLastEggUpdate then
        self.timeLastEggUpdate = Shared.GetTime()
    end

    if self.timeLastEggUpdate + ScaleWithPlayerCount(kEggGenerationRate, #GetEntitiesForTeam("Player", self:GetTeamNumber())) < Shared.GetTime() then

        local hives = GetEntitiesForTeam("Hive", self:GetTeamNumber())
        local builtHives = {}

        -- allow only built hives to spawn eggs
        for _, hive in ipairs(hives) do

            if hive:GetIsBuilt() and hive:GetIsAlive() then
                table.insert(builtHives, hive)
            end

        end

        for _, hive in ipairs(builtHives) do
            hive:UpdateSpawnEgg()
        end

        self.timeLastEggUpdate = Shared.GetTime()
    end

end

function AlienTeam:UpdateAlienSpectators()

    if self.timeLastSpectatorUpdate == nil then
        self.timeLastSpectatorUpdate = Shared.GetTime() - 1
    end

    if self.timeLastSpectatorUpdate + 1 <= Shared.GetTime() then

        local alienSpectators = self:GetSortedRespawnQueue()
        local enemyTeamPosition = self:GetCriticalHivePosition()

        for i = 1, #alienSpectators do

            local alienSpectator = alienSpectators[i]
            -- Do not spawn players waiting in the auto team balance queue.
            if alienSpectator:isa("AlienSpectator") and not alienSpectator:GetIsWaitingForTeamBalance() then

                -- Consider min death time.
                if alienSpectator:GetRespawnQueueEntryTime() + kAlienSpawnTime < Shared.GetTime() then

                    local egg
                    if alienSpectator.GetHostEgg then
                        egg = alienSpectator:GetHostEgg()
                    end

                    -- Player has no egg assigned, check for free egg.
                    if egg == nil then

                        local success = self:AssignPlayerToEgg(alienSpectator, enemyTeamPosition)

                        -- We have no eggs currently, makes no sense to check for every spectator now.
                        if not success then
                            break
                        end

                    end

                end

            end

        end

        self.timeLastSpectatorUpdate = Shared.GetTime()

    end

end

function AlienTeam:Update(timePassed)

    PROFILE("AlienTeam:Update")

    PlayingTeam.Update(self, timePassed)

    self:UpdateTeamAutoHeal(timePassed)
    self:UpdateEggGeneration()
    self:UpdateEggCount()
    self:UpdateAlienSpectators()
    self:UpdateBioMassLevel()

    -- Todo: Make this event driven
    for _, alien in ipairs(GetEntitiesForTeam("Alien", self:GetTeamNumber())) do
        local shellLevel = alien:GetShellLevel()
        alien:UpdateArmorAmount(shellLevel, alien:GetUpgradeLevel("bioMassLevel"))
    end

end

function AlienTeam:OnTechTreeUpdated()

    if self.updateAlienArmor then

        self.updateAlienArmor = false
        self.updateAlienArmorInTicks = 100

    end

end

-- update every tick but only a small amount of structures
function AlienTeam:UpdateTeamAutoHeal()

    PROFILE("AlienTeam:UpdateTeamAutoHeal")

    local now = Shared.GetTime()

    if self.timeOfLastAutoHeal == nil then
        self.timeOfLastAutoHeal = now
    end

    if now > (self.timeOfLastAutoHeal + AlienTeam.kStructureAutoHealInterval) then

        local gameEnts = GetEntitiesWithMixinForTeam("InfestationTracker", self:GetTeamNumber())
        local numEnts = #gameEnts
        local toIndex = self.lastAutoHealIndex + AlienTeam.kAutoHealUpdateNum - 1
        toIndex = ConditionalValue(toIndex <= numEnts , toIndex, numEnts)
        for index = self.lastAutoHealIndex, toIndex do

            local entity = gameEnts[index]

            -- players update the auto heal on their own
            if not entity:isa("Player") then

                -- we add whips and tunnel entrances as an exception here. construction should
                -- still be restricted to onInfestation, we only don't want whips to take damage
                -- off infestation
                local requiresInfestation = LookupTechData(entity:GetTechId(), kTechDataRequiresInfestation)
                if entity:isa("Whip") or entity:isa("TunnelEntrance") then
                    requiresInfestation = false
                end
                local isOnInfestation       = entity:GetGameEffectMask(kGameEffect.OnInfestation)
                local deltaTime             = 0

                if not entity.timeLastAutoHeal then
                    entity.timeLastAutoHeal = Shared.GetTime()
                else
                    deltaTime = Shared.GetTime() - entity.timeLastAutoHeal
                    entity.timeLastAutoHeal = Shared.GetTime()
                end

                if requiresInfestation and not isOnInfestation then

                    -- Take damage!
                    local damagePerSecondPercentage = kBalanceOffInfestationHurtPercentPerSecond
                    if entity.GetOffInfestationHurtPercentPerSecond then
                        damagePerSecondPercentage = entity:GetOffInfestationHurtPercentPerSecond()
                    end

                    local damagePerSecond = entity:GetMaxHealth() * damagePerSecondPercentage
                    damagePerSecond = math.max(damagePerSecond, kMinOffInfestationHurtPerSecond)
                    local damage = damagePerSecond * deltaTime

                    local attacker
                    if entity.lastAttackerDidDamageTime and Shared.GetTime() < entity.lastAttackerDidDamageTime + 60 then
                        attacker = entity:GetLastAttacker()
                    end

                    entity:DeductHealth(damage, attacker)

                end

            end

        end

        if self.lastAutoHealIndex + AlienTeam.kAutoHealUpdateNum >= numEnts then
            self.lastAutoHealIndex = 1
        else
            self.lastAutoHealIndex = self.lastAutoHealIndex + AlienTeam.kAutoHealUpdateNum
        end

        self.timeOfLastAutoHeal = Shared.GetTime()

    end

end

function AlienTeam:InitTechTree()

    PlayingTeam.InitTechTree(self)

    -- Add special alien menus
    self.techTree:AddMenu(kTechId.MarkersMenu)
    self.techTree:AddMenu(kTechId.UpgradesMenu)
    self.techTree:AddMenu(kTechId.ShadePhantomMenu)
    self.techTree:AddMenu(kTechId.ShadePhantomStructuresMenu)
    self.techTree:AddMenu(kTechId.ShiftEcho, kTechId.None) --Fortress, removed requirement
    self.techTree:AddMenu(kTechId.LifeFormMenu)
    self.techTree:AddMenu(kTechId.SkulkMenu)
    self.techTree:AddMenu(kTechId.GorgeMenu)
    self.techTree:AddMenu(kTechId.LerkMenu)
    self.techTree:AddMenu(kTechId.FadeMenu)
    self.techTree:AddMenu(kTechId.OnosMenu)
    self.techTree:AddMenu(kTechId.Return)

    self.techTree:AddOrder(kTechId.Grow)
    self.techTree:AddAction(kTechId.FollowAlien)

    self.techTree:AddPassive(kTechId.Infestation)
    self.techTree:AddPassive(kTechId.SpawnAlien)
    self.techTree:AddPassive(kTechId.CollectResources, kTechId.Harvester)

    -- Add markers (orders)
    self.techTree:AddSpecial(kTechId.ThreatMarker, kTechId.None, kTechId.None, true)
    self.techTree:AddSpecial(kTechId.LargeThreatMarker, kTechId.None, kTechId.None, true)
    self.techTree:AddSpecial(kTechId.NeedHealingMarker, kTechId.None, kTechId.None, true)
    self.techTree:AddSpecial(kTechId.WeakMarker, kTechId.None, kTechId.None, true)
    self.techTree:AddSpecial(kTechId.ExpandingMarker, kTechId.None, kTechId.None, true)

    -- bio mass levels (required to unlock new abilities)
    self.techTree:AddSpecial(kTechId.BioMassOne)
    self.techTree:AddSpecial(kTechId.BioMassTwo)
    self.techTree:AddSpecial(kTechId.BioMassThree)
    self.techTree:AddSpecial(kTechId.BioMassFour)
    self.techTree:AddSpecial(kTechId.BioMassFive)
    self.techTree:AddSpecial(kTechId.BioMassSix)
    self.techTree:AddSpecial(kTechId.BioMassSeven)
    self.techTree:AddSpecial(kTechId.BioMassEight)
    self.techTree:AddSpecial(kTechId.BioMassNine)
    self.techTree:AddSpecial(kTechId.BioMassTen)
    self.techTree:AddSpecial(kTechId.BioMassEleven)
    self.techTree:AddSpecial(kTechId.BioMassTwelve)

    -- Commander abilities
    self.techTree:AddBuildNode(kTechId.Cyst)
    self.techTree:AddBuildNode(kTechId.NutrientMist)
    self.techTree:AddBuildNode(kTechId.Rupture, kTechId.BioMassTwo)
    self.techTree:AddBuildNode(kTechId.BoneWall, kTechId.BioMassThree)
    self.techTree:AddBuildNode(kTechId.Contamination, kTechId.BioMassTwelve)
    self.techTree:AddAction(kTechId.SelectDrifter)
    self.techTree:AddAction(kTechId.SelectHallucinations, kTechId.FortressShade, kTechId.ShadeHive)
    self.techTree:AddAction(kTechId.SelectShift, kTechId.None) --Fortress, removed requirement

    -- Count consume like an upgrade so we can have multiples
    self.techTree:AddUpgradeNode(kTechId.Consume, kTechId.None, kTechId.None)

    -- Drifter triggered abilities
    self.techTree:AddTargetedActivation(kTechId.EnzymeCloud,      kTechId.ShiftHive,      kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.Hallucinate,      kTechId.ShadeHive,      kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.MucousMembrane,   kTechId.CragHive,      kTechId.None)
    --self.techTree:AddTargetedActivation(kTechId.Storm,            kTechId.ShiftHive,       kTechId.None)
    self.techTree:AddActivation(kTechId.DestroyHallucination)
    self.techTree:AddActivation(kTechId.HallucinateRandom)
    self.techTree:AddTargetedActivation(kTechId.HallucinateCloning)

    -- Cyst passives
    self.techTree:AddPassive(kTechId.CystCamouflage, kTechId.ShadeHive,      kTechId.None)
    self.techTree:AddPassive(kTechId.CystCelerity, kTechId.ShiftHive,      kTechId.None)
    self.techTree:AddPassive(kTechId.CystCarapace, kTechId.CragHive,      kTechId.None)

    -- Drifter passive abilities
    self.techTree:AddPassive(kTechId.DrifterCamouflage, kTechId.ShadeHive,      kTechId.None)
    self.techTree:AddPassive(kTechId.DrifterCelerity, kTechId.ShiftHive,      kTechId.None)
    self.techTree:AddPassive(kTechId.DrifterRegeneration, kTechId.CragHive,      kTechId.None)

    -- Hive types
    self.techTree:AddBuildNode(kTechId.Hive,                    kTechId.None,           kTechId.None)
    self.techTree:AddPassive(kTechId.HiveHeal)
    self.techTree:AddBuildNode(kTechId.CragHive,                kTechId.Hive,                kTechId.None)
    self.techTree:AddBuildNode(kTechId.ShadeHive,               kTechId.Hive,                kTechId.None)
    self.techTree:AddBuildNode(kTechId.ShiftHive,               kTechId.Hive,                kTechId.None)

    self.techTree:AddTechInheritance(kTechId.Hive, kTechId.CragHive)
    self.techTree:AddTechInheritance(kTechId.Hive, kTechId.ShiftHive)
    self.techTree:AddTechInheritance(kTechId.Hive, kTechId.ShadeHive)

    self.techTree:AddUpgradeNode(kTechId.ResearchBioMassOne)
    self.techTree:AddUpgradeNode(kTechId.ResearchBioMassTwo)
    self.techTree:AddUpgradeNode(kTechId.ResearchBioMassThree)
    self.techTree:AddUpgradeNode(kTechId.ResearchBioMassFour)

    self.techTree:AddUpgradeNode(kTechId.UpgradeToCragHive,     kTechId.Hive,                kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.UpgradeToShadeHive,    kTechId.Hive,                kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.UpgradeToShiftHive,    kTechId.Hive,                kTechId.None)

    self.techTree:AddBuildNode(kTechId.Harvester)
    self.techTree:AddBuildNode(kTechId.DrifterEgg)
    self.techTree:AddBuildNode(kTechId.Drifter, kTechId.None, kTechId.None, true)

    -- Whips
    self.techTree:AddBuildNode(kTechId.Whip,                      kTechId.None,                kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.EvolveBombard,             kTechId.None,                kTechId.None)

    self.techTree:AddPassive(kTechId.WhipBombard)
    self.techTree:AddPassive(kTechId.Slap)
    self.techTree:AddActivation(kTechId.WhipUnroot)
    self.techTree:AddActivation(kTechId.WhipRoot)

    -- Tier 1 lifeforms
    self.techTree:AddAction(kTechId.Skulk,                     kTechId.None,                kTechId.None)
    self.techTree:AddAction(kTechId.Gorge,                     kTechId.None,                kTechId.None)
    self.techTree:AddAction(kTechId.Lerk,                      kTechId.None,                kTechId.None)
    self.techTree:AddAction(kTechId.Fade,                      kTechId.None,                kTechId.None)
    self.techTree:AddAction(kTechId.Onos,                      kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Egg,                      kTechId.None,                kTechId.None)

    self.techTree:AddUpgradeNode(kTechId.GorgeEgg, kTechId.BioMassTwo)
    self.techTree:AddUpgradeNode(kTechId.LerkEgg, kTechId.BioMassFour)
    self.techTree:AddUpgradeNode(kTechId.FadeEgg, kTechId.BioMassEight)
    self.techTree:AddUpgradeNode(kTechId.OnosEgg, kTechId.BioMassNine)

    -- Special alien structures. These tech nodes are modified at run-time, depending when they are built, so don't modify prereqs.
    self.techTree:AddBuildNode(kTechId.Crag,                      kTechId.Hive,          kTechId.None)
    self.techTree:AddBuildNode(kTechId.Shift,                     kTechId.Hive,          kTechId.None)
    self.techTree:AddBuildNode(kTechId.Shade,                     kTechId.Hive,          kTechId.None)


    
    --Fortress
    self.techTree:AddBuildNode(kTechId.FortressCrag,               kTechId.Crag,        kTechId.None)
    self.techTree:AddPassive(kTechId.FortressCragAbility,                kTechId.FortressCrag,          kTechId.CragHive)
    self.techTree:AddUpgradeNode(kTechId.UpgradeToFortressCrag,  kTechId.Crag)

    self.techTree:AddBuildNode(kTechId.FortressShift,               kTechId.Shift,        kTechId.None)
    self.techTree:AddPassive(kTechId.FortressShiftAbility,                kTechId.FortressShift,          kTechId.ShiftHive)
    self.techTree:AddUpgradeNode(kTechId.UpgradeToFortressShift,  kTechId.Shift)

    self.techTree:AddBuildNode(kTechId.FortressShade,               kTechId.Shade,        kTechId.None)
    self.techTree:AddActivation(kTechId.ShadeHallucination,                kTechId.FortressShade,          kTechId.ShadeHive)
    self.techTree:AddUpgradeNode(kTechId.UpgradeToFortressShade,  kTechId.Shade)
	self.techTree:AddPassive(kTechId.ShadeSonar,                kTechId.FortressShade,          kTechId.ShadeHive)

    self.techTree:AddBuildNode(kTechId.FortressWhip,               kTechId.Whip,        kTechId.None)
    self.techTree:AddActivation(kTechId.WhipAbility,               kTechId.None,          kTechId.None)
    self.techTree:AddActivation(kTechId.FortressWhipAbility,                kTechId.FortressWhip,          kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.UpgradeToFortressWhip,  kTechId.Whip)
	self.techTree:AddPassive(kTechId.FortressWhipCragPassive,  kTechId.FortressWhip, kTechId.CragHive)
	self.techTree:AddPassive(kTechId.FortressWhipShiftPassive, kTechId.FortressWhip, kTechId.ShiftHive)
	self.techTree:AddPassive(kTechId.FortressWhipShadePassive, kTechId.FortressWhip, kTechId.ShadeHive)
 
    self.techTree:AddPassive(kTechId.ShellPassive)
    self.techTree:AddPassive(kTechId.SpurPassive)
    self.techTree:AddPassive(kTechId.VeilPassive)	

    -- Alien upgrade structure
    self.techTree:AddBuildNode(kTechId.Shell, kTechId.CragHive)
    self.techTree:AddSpecial(kTechId.TwoShells, kTechId.Shell)
    self.techTree:AddSpecial(kTechId.ThreeShells, kTechId.TwoShells)

    self.techTree:AddBuildNode(kTechId.Veil, kTechId.ShadeHive)
    self.techTree:AddSpecial(kTechId.TwoVeils, kTechId.Veil)
    self.techTree:AddSpecial(kTechId.ThreeVeils, kTechId.TwoVeils)

    self.techTree:AddBuildNode(kTechId.Spur, kTechId.ShiftHive)
    self.techTree:AddSpecial(kTechId.TwoSpurs, kTechId.Spur)
    self.techTree:AddSpecial(kTechId.ThreeSpurs, kTechId.TwoSpurs)


    -- personal upgrades (all alien types)
    self.techTree:AddBuyNode(kTechId.Vampirism, kTechId.Shell, kTechId.None, kTechId.AllAliens)
    self.techTree:AddBuyNode(kTechId.Resilience, kTechId.Shell, kTechId.None, kTechId.AllAliens)
    self.techTree:AddBuyNode(kTechId.Regeneration, kTechId.Shell, kTechId.None, kTechId.AllAliens)

    self.techTree:AddBuyNode(kTechId.Focus, kTechId.Veil, kTechId.None, kTechId.AllAliens)
    self.techTree:AddBuyNode(kTechId.Aura, kTechId.Veil, kTechId.None, kTechId.AllAliens)
    self.techTree:AddBuyNode(kTechId.Camouflage, kTechId.Veil, kTechId.None, kTechId.AllAliens)

    self.techTree:AddBuyNode(kTechId.Crush, kTechId.Spur, kTechId.None, kTechId.AllAliens)
    self.techTree:AddBuyNode(kTechId.Celerity, kTechId.Spur, kTechId.None, kTechId.AllAliens)
    self.techTree:AddBuyNode(kTechId.Adrenaline, kTechId.Spur, kTechId.None, kTechId.AllAliens)


    -- Crag
    self.techTree:AddPassive(kTechId.CragHeal)
    --self.techTree:AddActivation(kTechId.HealWave,                kTechId.CragHive,          kTechId.None)
    self.techTree:AddActivation(kTechId.HealWave,                kTechId.None,          kTechId.None) --Fortress, removed requirement

    -- Shift
    self.techTree:AddActivation(kTechId.ShiftHatch,               kTechId.None,         kTechId.None)
    self.techTree:AddPassive(kTechId.ShiftEnergize,               kTechId.None,         kTechId.None)


    self.techTree:AddTargetedActivation(kTechId.TeleportHydra,       kTechId.ShiftHive,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.TeleportWhip,        kTechId.None,         kTechId.None) --Fortress, removed requirement
    self.techTree:AddTargetedActivation(kTechId.TeleportTunnel,      kTechId.ShiftHive,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.TeleportCrag,        kTechId.None,         kTechId.None) --Fortress, removed requirement
    self.techTree:AddTargetedActivation(kTechId.TeleportShade,       kTechId.None,         kTechId.None) --Fortress, removed requirement
    self.techTree:AddTargetedActivation(kTechId.TeleportShift,       kTechId.None,         kTechId.None) --Fortress, removed requirement
    self.techTree:AddTargetedActivation(kTechId.TeleportVeil,        kTechId.None,         kTechId.None) --Fortress, removed requirement
    self.techTree:AddTargetedActivation(kTechId.TeleportSpur,        kTechId.None,         kTechId.None) --Fortress, removed requirement
    self.techTree:AddTargetedActivation(kTechId.TeleportShell,       kTechId.None,         kTechId.None) --Fortress, removed requirement
    self.techTree:AddTargetedActivation(kTechId.TeleportHive,        kTechId.None,         kTechId.None) --Fortress, removed requirement
    self.techTree:AddTargetedActivation(kTechId.TeleportEgg,         kTechId.None,         kTechId.None) --Fortress, removed requirement
    self.techTree:AddTargetedActivation(kTechId.TeleportHarvester,   kTechId.None,         kTechId.None) --Fortress, removed requirement

    -- Shade
    self.techTree:AddPassive(kTechId.ShadeDisorient)
    self.techTree:AddPassive(kTechId.ShadeCloak)
    self.techTree:AddActivation(kTechId.ShadeInk,                 kTechId.None,         kTechId.None) --Fortress, removed requirement

    self.techTree:AddSpecial(kTechId.TwoHives)
    self.techTree:AddSpecial(kTechId.ThreeHives)

    self.techTree:AddSpecial(kTechId.TwoWhips)
    self.techTree:AddSpecial(kTechId.TwoShifts)
    self.techTree:AddSpecial(kTechId.TwoShades)
    self.techTree:AddSpecial(kTechId.TwoCrags)

    -- Tunnel
    self.techTree:AddBuildNode(kTechId.TunnelExit)
    self.techTree:AddBuildNode(kTechId.TunnelRelocate)
    self.techTree:AddActivation(kTechId.TunnelCollapse)

    --self.techTree:AddBuildNode(kTechId.InfestedTunnel)
    --self.techTree:AddUpgradeNode(kTechId.UpgradeToInfestedTunnel)

    self.techTree:AddAction(kTechId.BuildTunnelMenu)

    self.techTree:AddBuildNode(kTechId.BuildTunnelEntryOne)
    self.techTree:AddBuildNode(kTechId.BuildTunnelEntryTwo)
    self.techTree:AddBuildNode(kTechId.BuildTunnelEntryThree)
    self.techTree:AddBuildNode(kTechId.BuildTunnelEntryFour)
    self.techTree:AddBuildNode(kTechId.BuildTunnelExitOne)
    self.techTree:AddBuildNode(kTechId.BuildTunnelExitTwo)
    self.techTree:AddBuildNode(kTechId.BuildTunnelExitThree)
    self.techTree:AddBuildNode(kTechId.BuildTunnelExitFour)
    self.techTree:AddAction(kTechId.SelectTunnelEntryOne)
    self.techTree:AddAction(kTechId.SelectTunnelEntryTwo)
    self.techTree:AddAction(kTechId.SelectTunnelEntryThree)
    self.techTree:AddAction(kTechId.SelectTunnelEntryFour)
    self.techTree:AddAction(kTechId.SelectTunnelExitOne)
    self.techTree:AddAction(kTechId.SelectTunnelExitTwo)
    self.techTree:AddAction(kTechId.SelectTunnelExitThree)
    self.techTree:AddAction(kTechId.SelectTunnelExitFour)

    -- abilities unlocked by bio mass:

    -- skulk researches
    self.techTree:AddResearchNode(kTechId.Leap,              kTechId.BioMassFour, kTechId.None, kTechId.AllAliens)
    self.techTree:AddResearchNode(kTechId.Xenocide,          kTechId.BioMassNine, kTechId.None, kTechId.AllAliens)

    -- gorge researches
    self.techTree:AddBuyNode(kTechId.BabblerAbility,        kTechId.None)
    self.techTree:AddPassive(kTechId.WebTech,            kTechId.None) --, kTechId.None, kTechId.AllAliens
    --FIXME Above still shows in Alien-Comm buttons/menu
    self.techTree:AddBuyNode(kTechId.Web,                   kTechId.None)
    self.techTree:AddBuyNode(kTechId.BabblerEgg,            kTechId.None)
    self.techTree:AddResearchNode(kTechId.BileBomb,         kTechId.BioMassTwo, kTechId.None, kTechId.AllAliens)
	self.techTree:AddResearchNode(kTechId.BabblerBombAbility,            kTechId.BioMassSeven, kTechId.None, kTechId.AllAliens)

    -- lerk researches
    self.techTree:AddResearchNode(kTechId.Umbra,               kTechId.BioMassSix, kTechId.None, kTechId.AllAliens)
    self.techTree:AddResearchNode(kTechId.Spores,              kTechId.BioMassSix, kTechId.None, kTechId.AllAliens)

    -- fade researches
    self.techTree:AddResearchNode(kTechId.MetabolizeEnergy,        kTechId.BioMassThree, kTechId.None, kTechId.AllAliens)
    self.techTree:AddResearchNode(kTechId.MetabolizeHealth,        kTechId.BioMassFive, kTechId.MetabolizeEnergy, kTechId.AllAliens)
    self.techTree:AddResearchNode(kTechId.Stab,              kTechId.BioMassSeven, kTechId.None, kTechId.AllAliens)

    -- onos researches
    self.techTree:AddPassive(kTechId.Charge)
    self.techTree:AddResearchNode(kTechId.BoneShield,        kTechId.BioMassSix, kTechId.None, kTechId.AllAliens)
    self.techTree:AddResearchNode(kTechId.Stomp,             kTechId.BioMassEight, kTechId.None, kTechId.AllAliens)

    -- gorge structures
    self.techTree:AddBuildNode(kTechId.Hydra)
    self.techTree:AddBuildNode(kTechId.Clog)

    self.techTree:SetComplete()

end

function AlienTeam:GetNumHives()

    local teamInfoEntity = Shared.GetEntity(self.teamInfoEntityId)
    return teamInfoEntity:GetNumCapturedTechPoints()

end

function AlienTeam:GetActiveHiveCount()

    local activeHiveCount = 0

    for _, hive in ipairs(GetEntitiesForTeam("Hive", self:GetTeamNumber())) do

        if hive:GetIsAlive() and hive:GetIsBuilt() then
            activeHiveCount = activeHiveCount + 1
        end

    end

    return activeHiveCount

end

function AlienTeam:GetActiveEggCount()

    local activeEggCount = 0

    for _, egg in ipairs(GetEntitiesForTeam("Egg", self:GetTeamNumber())) do

        if egg:GetIsAlive() and egg:GetIsEmpty() then
            activeEggCount = activeEggCount + 1
        end

    end

    return activeEggCount

end

--
-- Inform all alien players about the hive construction (add new abilities).
--
function AlienTeam:OnHiveConstructed(newHive)

    local activeHiveCount = self:GetActiveHiveCount()

    for _, alien in ipairs(GetEntitiesForTeam("Alien", self:GetTeamNumber())) do

        if alien:GetIsAlive() and alien.OnHiveConstructed then
            alien:OnHiveConstructed(newHive, activeHiveCount)
        end

    end

    SendTeamMessage(self, kTeamMessageTypes.HiveConstructed, newHive:GetLocationId())

end

--
-- Inform all alien players about the hive destruction (remove abilities).
--
function AlienTeam:OnHiveDestroyed(destroyedHive)

    local activeHiveCount = self:GetActiveHiveCount()

    for _, alien in ipairs(GetEntitiesForTeam("Alien", self:GetTeamNumber())) do

        if alien:GetIsAlive() and alien.OnHiveDestroyed then
            alien:OnHiveDestroyed(destroyedHive, activeHiveCount)
        end

    end

end

local kUpgradeStructureTable =
{
    {
        name = "Shell",
        techId = kTechId.Shell,
        upgrades = {
            kTechId.Vampirism, kTechId.Resilience, kTechId.Regeneration
        }
    },
    {
        name = "Veil",
        techId = kTechId.Veil,
        upgrades = {
            kTechId.Camouflage, kTechId.Aura, kTechId.Focus
        }
    },
    {
        name = "Spur",
        techId = kTechId.Spur,
        upgrades = {
            kTechId.Crush, kTechId.Celerity, kTechId.Adrenaline
        }
    }
}

function AlienTeam.GetUpgradeStructureTable()
    return kUpgradeStructureTable
end

function AlienTeam:GetSpectatorMapName()
    return AlienSpectator.kMapName
end

function AlienTeam:OnEvolved(techId)

    local listeners = self.eventListeners['OnEvolved']

    if listeners then

        for _, listener in ipairs(listeners) do
            listener(techId)
        end

    end

end

local function OnSetDesiredSpawnPoint(client, message)

    local player = client:GetControllingPlayer()
    if player then
        player.desiredSpawnPoint = message.desiredSpawnPoint
    end

end
Server.HookNetworkMessage("SetDesiredSpawnPoint", OnSetDesiredSpawnPoint)

function AlienTeam:GetTotalInRespawnQueue()
    
    local numPlayers = 0
    
    -- Count players waiting to respawn.
    for i=1, self.respawnQueue:GetCount() do
        local player = Shared.GetEntity(self.respawnQueue:GetValueAtIndex(i))
        if player then
            numPlayers = numPlayers + 1
        end
    end
    
    -- Count players just about to hatch from eggs.
    local allEggs = GetEntitiesForTeam("Egg", self:GetTeamNumber())
    for i=1, #allEggs do
        local egg = allEggs[i]
        if GetIsUnitActive(egg) and egg.queuedPlayerId ~= nil and egg.queuedPlayerId ~= Entity.invalidId then
            numPlayers = numPlayers + 1
        end
    end
    
    return numPlayers
    
end
