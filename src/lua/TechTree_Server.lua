-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\TechTree_Server.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

-- TODO(Salads): Further optimize by only sending changed instances instead of all of them when one of them changes.
function TechTree:SendTechNodeInstances(player, techNode)

    local removedInstances = {}
    if techNode.instances then

        for k, v in pairs(techNode.instances) do

            Server.SendNetworkMessage(player, "TechNodeInstance", BuildTechNodeInstanceMessage(techNode, k), true)

            if v.removed then
                table.insert(removedInstances, k)
            end

        end

    end

    return removedInstances

end

-- Send the entirety of every the tech node on team change or join. Returns true if it sent anything
function TechTree:SendTechTreeBase(player)

    local sent = false
    if self.complete then
    
        -- Tell client to empty tech tree before adding new nodes. Send reliably
        -- so players are always able to buy weapons, use commander mode, etc.
        Server.SendNetworkMessage(player, "ClearTechTree", {}, true)

        for _, nodeTechId in ipairs(self.techIdList) do

            local techNode = self:GetTechNode(nodeTechId)
        
            Server.SendNetworkMessage(player, "TechNodeBase", BuildTechNodeBaseMessage(techNode), true)

            sent = true
        
        end
        
    end
    
    return sent
    
end

function TechTree:SendTechTreeUpdates(playerList)

    for _, techNode in ipairs(self.techNodesChanged:GetList()) do
    
        local techNodeUpdateTable = BuildTechNodeUpdateMessage(techNode)
        local removedInstances = {}
        
        for _, player in ipairs(playerList) do
        
            Server.SendNetworkMessage(player, "TechNodeUpdate", techNodeUpdateTable, true)
            removedInstances = self:SendTechNodeInstances(player, techNode)
            
        end

        -- Remove any done-for research instances after we are done sending them to players.
        if techNode.instances then
            for i = 1, #removedInstances do
                techNode.instances[removedInstances[i]] = nil
            end
        end
        
    end
    
    self.techNodesChanged:Clear()
    
end

function TechTree:AddOrder(techId)

    local techNode = TechNode()
    
    techNode:Initialize(techId, kTechType.Order, kTechId.None, kTechId.None)
    techNode.requiresTarget = true
    
    self:AddNode(techNode)    
    
end

-- a child tech can be used a requirement in case there is no parent tech available (mature structures, upgraded robotics factory, etc)
function TechTree:AddTechInheritance(parentTech, childTech)

    if not self.techInheritance then
        self.techInheritance = {}
    end    

    table.insert(self.techInheritance, {parentTech, childTech} )
    
end

-- Contains a bunch of tech nodes
function TechTree:AddBuildNode(techId, prereq1, prereq2, isRequired)

    assert(techId)
    
    local techNode = TechNode()

    techNode:Initialize(techId, kTechType.Build, prereq1, prereq2)
    techNode.requiresTarget = true
    techNode.isRequired = isRequired
    
    self:AddNode(techNode)    
    
end

-- Contains a bunch of tech nodes
function TechTree:AddEnergyBuildNode(techId, prereq1, prereq2)

    local techNode = TechNode()

    techNode:Initialize(techId, kTechType.EnergyBuild, prereq1, prereq2)
    techNode.requiresTarget = true
    
    self:AddNode(techNode)    
    
end

function TechTree:AddManufactureNode(techId, prereq1, prereq2, isRequired)

    local techNode = TechNode()

    techNode:Initialize(techId, kTechType.Manufacture, prereq1, prereq2)
    
    local buildTime = LookupTechData(techId, kTechDataBuildTime, kDefaultBuildTime)
    techNode.time = ConditionalValue(buildTime ~= nil, buildTime, 0)
    techNode.isRequired = isRequired
    
    self:AddNode(techNode)  

end


function TechTree:AddBuyNode(techId, prereq1, prereq2, addOnTechId)

    local techNode = TechNode()
    
    techNode:Initialize(techId, kTechType.Buy, prereq1, prereq2)
    
    if addOnTechId ~= nil then
        techNode.addOnTechId = addOnTechId
    end
    
    self:AddNode(techNode)    
    
end

function TechTree:AddTargetedBuyNode(techId, prereq1, prereq2, addOnTechId)

    local techNode = TechNode()
    
    techNode:Initialize(techId, kTechType.Buy, prereq1, prereq2)
    
    if addOnTechId ~= nil then
        techNode.addOnTechId = addOnTechId
    end
    
    techNode.requiresTarget = true        
    
    self:AddNode(techNode)    

end

function TechTree:AddResearchNode(techId, prereq1, prereq2, addOnTechId)

    local techNode = TechNode()
    
    techNode:Initialize(techId, kTechType.Research, prereq1, prereq2)
    
    local researchTime = LookupTechData(techId, kTechDataResearchTimeKey)
    techNode.time = ConditionalValue(researchTime ~= nil, researchTime, 0)
    
    if addOnTechId ~= nil then
        techNode.addOnTechId = addOnTechId
    end

    self:AddNode(techNode)    
    
end

-- Same as research but can be triggered multiple times and concurrently
function TechTree:AddUpgradeNode(techId, prereq1, prereq2)

    local techNode = TechNode()
    
    techNode:Initialize(techId, kTechType.Upgrade, prereq1, prereq2)
    
    local researchTime = LookupTechData(techId, kTechDataResearchTimeKey)
    techNode.time = ConditionalValue(researchTime ~= nil, researchTime, 0)

    self:AddNode(techNode)    
    
end

function TechTree:AddAction(techId, prereq1, prereq2)

    local techNode = TechNode()

    techNode:Initialize(techId, kTechType.Action, prereq1, prereq2)
    
    self:AddNode(techNode)  

end

function TechTree:AddTargetedAction(techId, prereq1, prereq2)

    local techNode = TechNode()

    techNode:Initialize(techId, kTechType.Action, prereq1, prereq2)
    techNode.requiresTarget = true        
    
    self:AddNode(techNode)
    
end

-- If there's a cost, it's energy
function TechTree:AddActivation(techId, prereq1, prereq2)

    local techNode = TechNode()
    
    techNode:Initialize(techId, kTechType.Activation, prereq1, prereq2)
    
    self:AddNode(techNode)  
    
end

-- If there's a cost, it's energy
function TechTree:AddTargetedActivation(techId, prereq1, prereq2)

    local techNode = TechNode()
    
    techNode:Initialize(techId, kTechType.Activation, prereq1, prereq2)
    techNode.requiresTarget = true        
    
    self:AddNode(techNode)  
    
end

function TechTree:AddMenu(techId, prereq1, prereq2)

    local techNode = TechNode()
    
    if not prereq1 then
        prereq1 = kTechId.None
    end
    
    if not prereq2 then
        prereq2 = kTechId.None
    end
    
    techNode:Initialize(techId, kTechType.Menu, prereq1, prereq1)
    
    self:AddNode(techNode)  

end

function TechTree:AddEnergyManufactureNode(techId, prereq1, prereq2)

    local techNode = TechNode()

    techNode:Initialize(techId, kTechType.EnergyManufacture, prereq1, prereq2)
    
    local researchTime = LookupTechData(techId, kTechDataResearchTimeKey)
    techNode.time = ConditionalValue(researchTime ~= nil, researchTime, 0)
    
    self:AddNode(techNode)    
    
end

function TechTree:AddPlasmaManufactureNode(techId, prereq1, prereq2)

    local techNode = TechNode()

    techNode:Initialize(techId, kTechType.PlasmaManufacture, prereq1, prereq2)
    
    local researchTime = LookupTechData(techId, kTechDataResearchTimeKey)
    techNode.time = ConditionalValue(researchTime ~= nil, researchTime, 0)
    
    self:AddNode(techNode)    
    
end

function TechTree:AddSpecial(techId, prereq1, prereq2, requiresTarget)

    local techNode = TechNode()
    
    techNode:Initialize(techId, kTechType.Special, prereq1, prereq2)
    techNode.requiresTarget = ConditionalValue(requiresTarget, true, false)
    
    self:AddNode(techNode)  

end

function TechTree:AddPassive(techId, prereq1, prereq2)

    local techNode = TechNode()
    
    techNode:Initialize(techId, kTechType.Passive, prereq1, prereq2)
    techNode.requiresTarget = false
    
    self:AddNode(techNode)  

end

function TechTree:SetTechChanged()
    self.techChanged = true
end

-- Pre-compute stuff
function TechTree:SetComplete()

    if not self.complete then

        table.sort(self.techIdList) --We need to sort the table to resolve tech dependecies correctly later on
        
        self:ComputeUpgradedTechIdsSupporting()
        
        self.complete = true
        
    end
    
end

function TechTree:SetTeamNumber(teamNumber)
    self.teamNumber = teamNumber
end

function TechTree:GiveUpgrade(techId)

    local node = self:GetTechNode(techId)
    if(node ~= nil) then
    
        if(node:GetIsResearch()) then
        
            local newResearchState = not node.researched
            node:SetResearched(newResearchState)
            
            self:SetTechNodeChanged(node, string.format("researched: %s", ToString(newResearchState)))

            if(newResearchState) then
            
                self:QueueOnResearchComplete(techId)
                
            end
            
            return true

        end
        
    else
        Print("TechTree:GiveUpgrade(%d): Couldn't lookup tech node.", techId)
    end
    
    return false
    
end

function TechTree:AddSupportingTechId(techId, idList)

    if self.upgradedTechIdsSupporting == nil then
        self.upgradedTechIdsSupporting = {}
    end
    
    if table.icount(idList) > 0 then
        table.insert(self.upgradedTechIdsSupporting, {techId, idList})        
    end
    
end

function TechTree:ComputeUpgradedTechIdsSupporting()

    self.upgradedTechIdsSupporting = {}

    for _, techId in ipairs(self.techIdList) do
    
        local idList = self:ComputeUpgradedTechIdsSupportingId(techId)
        self:AddSupportingTechId(techId, idList)
        
    end
    
end

function TechTree:GetUpgradedTechIdsSupporting(techId)

    for _, idTablePair in ipairs(self.upgradedTechIdsSupporting) do
    
        if idTablePair[1] == techId then
        
            return idTablePair[2]
            
        end
        
    end
    
    return {}
    
end

-- Compute if active structures on our team that support this technology.
function TechTree:ComputeHasTech(structureTechIdList, techIdCount)

    -- Iterate in order
    for _, techId in ipairs(self.techIdList) do

        local node = self:GetTechNode(techId)
        if node then
            
            local hasTech = false
        
            if(self:GetTechSpecial(techId)) then
            
                hasTech = self:GetSpecialTechSupported(techId, structureTechIdList, techIdCount)

            -- If it's research, see if it's researched
            elseif node:GetIsResearch() then
            
                -- Pre-reqs must be defined already
                local prereq1 = node:GetPrereq1()
                local prereq2 = node:GetPrereq2()
                assert(prereq1 == kTechId.None or (prereq1 < techId), string.format("Prereq %s bigger then %s", EnumToString(kTechId, prereq1), EnumToString(kTechId, techId)))
                assert(prereq2 == kTechId.None or (prereq2 < techId), string.format("Prereq %s bigger then %s", EnumToString(kTechId, prereq2), EnumToString(kTechId, techId)))
                
                hasTech =   node:GetResearched() and 
                            self:GetHasTech(node:GetPrereq1()) and 
                            self:GetHasTech(node:GetPrereq2())

            else
        
                -- Also look for tech that replaces this tech but counts towards it (upgraded Armories, Infantry Portals, etc.)
                local supportingTechIds = self:GetUpgradedTechIdsSupporting(techId)
                
                table.insert(supportingTechIds, techId)

                for _, entityTechId in ipairs(structureTechIdList) do
                
                    if(table.find(supportingTechIds, entityTechId)) then
                    
                        hasTech = true
                            
                        break
                            
                    end
                   
                end
                
            end 
            
            -- Update node
            if node:GetHasTech() ~= hasTech then
                node:SetHasTech(hasTech)
                self:SetTechNodeChanged(node, string.format("hasTech = %s", ToString(hasTech)))
           end
           
        end
       
    end
        
end

function TechTree:GetTechSpecial(techId)

    local techNode = self:GetTechNode(techId)
    return techNode ~= nil and techNode:GetIsSpecial()
    
end

local kBioMassTech = { kTechId.BioMassOne, kTechId.BioMassTwo, kTechId.BioMassThree, kTechId.BioMassFour, 
                       kTechId.BioMassFive, kTechId.BioMassSix, kTechId.BioMassSeven, kTechId.BioMassEight,
                       kTechId.BioMassNine, kTechId.BioMassTen, kTechId.BioMassEleven, kTechId.BioMassTwelve }
                       
function BioMassTechToLevel(techId)

    for i = 1, #kBioMassTech do
        if kBioMassTech[i] == techId then
            return i
        end
    end
    
    return -1

end

local kSyncTech = { kTechId.SyncTechOne,kTechId.SyncTechTwo,kTechId.SyncTechThree,kTechId.SyncTechFour,kTechId.SyncTechFive,
					kTechId.SyncTechSix,kTechId.SyncTechSeven,kTechId.SyncTechEight,kTechId.SyncTechNine,kTechId.SyncTechTen,
					kTechId.SyncTechEleven,kTechId.SyncTechTwelve,kTechId.SyncTechThirteen,kTechId.SyncTechFourteen,kTechId.SyncTechFifteen,
					kTechId.SyncTechSixteen,kTechId.SyncTechSeventeen,kTechId.SyncTechEighteen,kTechId.SyncTechNineteen,kTechId.SyncTechTwenty,
					kTechId.SyncTechTwentyone}
                       
function SyncTechToLevel(techId)

    for i = 1, #kSyncTech do
        if kSyncTech[i] == techId then
            return i
        end
    end
    
    return -1

end

function TechTree:GetSpecialTechSupported(techId, structureTechIdList, techIdCount)

    local supportingIds

    if techId == kTechId.TwoShells or techId == kTechId.ThreeShells then
        supportingIds = { kTechId.Shell }

    elseif techId == kTechId.TwoSpurs or techId == kTechId.ThreeSpurs then
        supportingIds = { kTechId.Spur }

    elseif techId == kTechId.TwoVeils or techId == kTechId.ThreeVeils then
        supportingIds = { kTechId.Veil }

    elseif techId == kTechId.TwoCommandStations or techId == kTechId.ThreeCommandStations then
        supportingIds = { kTechId.CommandStation }

    elseif techId == kTechId.TwoHives or techId == kTechId.ThreeHives then
        supportingIds = { kTechId.Hive, kTechId.ShadeHive, kTechId.ShiftHive, kTechId.CragHive }

    elseif BioMassTechToLevel(techId) ~= -1 then

        local bioMassLevel = BioMassTechToLevel(techId)
        if bioMassLevel > 0 then

            -- check if alien team reached the bio mass level, mark the tech as available if level is equal or above
            local alienTeam = GetGamerules():GetTeam(kTeam2Index)
            if alienTeam and alienTeam.GetBioMassLevel and alienTeam.GetMaxBioMassLevel then

                local effectiveBioMassLevel = math.min(alienTeam:GetBioMassLevel(), alienTeam:GetMaxBioMassLevel())

                if effectiveBioMassLevel >= bioMassLevel then
                    return true
                else
                    return false
                end
            end
        end
		
    elseif SyncTechToLevel(techId) ~= -1 then

        local syncLevel = SyncTechToLevel(techId)
        if syncLevel > 0 then

            -- check if marine team reached the sync level, mark the tech as available if level is equal or above
            local marineTeam = GetGamerules():GetTeam(kTeam1Index)
            if marineTeam and marineTeam.GetSyncTechLevel then

                if marineTeam:GetSyncTechLevel() >= syncLevel then
                    return true
                else
                    return false
                end
            end
        end
	
	--[[elseif techId == kTechId.Armor1 or techId == kTechId.Armor2 or techId == kTechId.Armor3 or techId == kTechId.Weapons1 or techId == kTechId.Weapons2 or techId == kTechId.Weapons3 then

		local node = self:GetTechNode(techId)
		local prereq1 = node:GetPrereq1()	
		local prereq2 = node:GetPrereq2()
		
		if self:GetHasTech(prereq1) and self:GetHasTech(prereq2) then
			return true
		else
			return false
		end]]
    end

    if not supportingIds then
        return false
    end

    local numBuiltSpecials = 0

    for _, supportingId in ipairs(supportingIds) do

        if techIdCount[supportingId] then
            numBuiltSpecials = numBuiltSpecials + techIdCount[supportingId]
        end

    end

    --[[
    local structureTechIdListText = ""
    for _, structureTechId in ipairs(structureTechIdList) do
        structureTechIdListText = structureTechIdListText .. ", " .. EnumToString(kTechId, structureTechId) .. "(" .. ToString(techIdCount[structureTechId]) .. ")"
    end

    Print(structureTechIdListText)
    Print("TechTree:GetSpecialTechSupported(%s), numBuiltSpecials: %s", EnumToString(kTechId, techId), ToString(numBuiltSpecials))
    --]]

    if techId == kTechId.TwoCommandStations or
            techId == kTechId.TwoHives or
            techId == kTechId.TwoShells or
            techId == kTechId.TwoSpurs or
            techId == kTechId.TwoVeils then

        return numBuiltSpecials >= 2
    else
        return numBuiltSpecials >= 3
    end

end

-- Second param is optional
function TechTree:QueueOnResearchComplete(researchId, ent)

    ASSERT(type(researchId) == "number")
    ASSERT(ent == nil or type(ent) == "userdata")

    -- Research just finished on this structure. Queue call to OnResearchComplete
    -- until after we next update the tech tree
    if not self.queuedOnResearchComplete then
        self.queuedOnResearchComplete = unique_set()
    end
    
    local id = Entity.invalidId
    if ent then
        id = ent:GetId()
    end
    self.queuedOnResearchComplete:Insert{id, researchId}
    
end

function TechTree:TriggerQueuedResearchComplete()

    if self.queuedOnResearchComplete then
    
        for _, pair in ipairs(self.queuedOnResearchComplete:GetList()) do
        
            local entId = pair[1]
            local researchId = pair[2]
            
            local ent
            if entId ~= Entity.invalidId then
            
                -- It's possible that entity has been destroyed before here
                ent = Shared.GetEntity(entId)
                
            end
            
            local team = GetGamerules():GetTeam(self:GetTeamNumber())
            if ent then
                team = ent:GetTeam()
            end                    
            
            assert(team ~= nil)
            assert(team.OnResearchComplete ~= nil)
            
            team:OnResearchComplete(ent, researchId)
            
        end

        -- Clear out table
        self.queuedOnResearchComplete:Clear()
    end
end

function TechTree:GetIsResearchQueued(techId)

    if self.queuedOnResearchComplete then
    
        for r = 1, self.queuedOnResearchComplete:GetCount() do
        
            local queuedResearch = self.queuedOnResearchComplete:GetValueAtIndex(r)
            local researchId = queuedResearch[2]
            if techId == researchId then
                return true
            end
            
        end
        
    end
    
    return false
    
end

function TechTree:GetNumberOfQueuedResearch()
    return self.queuedOnResearchComplete and self.queuedOnResearchComplete:GetCount() or 0
end

--TODO: Refactor this to resolve tech dependencies correctly.
--Currently dependencies are only resoloved correctly as long as the required tech has a lower techId than the depending tech
function TechTree:Update(techIdList, techIdCount)

    -- Only compute if needed
    if self.techChanged then
    
        self:ComputeHasTech(techIdList, techIdCount)
        
        self:ComputeAvailability()
        
        self.techChanged = false
        
        self:TriggerQueuedResearchComplete()
        
    end
    
end

--
-- Compute "available" field for all nodes in tech tree. Should be called whenever a structure
-- is added or removed, and whenever global research starts or is canceled.
--
function TechTree:ComputeAvailability()

    for _, nodeTechId in ipairs(self.techIdList) do

        local node = self:GetTechNode(nodeTechId)
        assert(node)
    
        local newAvailableState = false
        
        -- Don't allow researching items that are currently being researched (unless multiples allowed)
        if (node:GetIsResearch() or node:GetIsPlasmaManufacture()) and (self:GetHasTech(node:GetPrereq1()) and self:GetHasTech(node:GetPrereq2())) then
            newAvailableState = node:GetCanResearch()
        -- Disable anything with this as a prereq if no longer available
        elseif self:GetHasTech(node:GetPrereq1()) and self:GetHasTech(node:GetPrereq2()) then
            newAvailableState = true
        end
        
        -- Check for "alltech" cheat
        if GetGamerules():GetAllTech() then
            newAvailableState = true
        end
        
        -- Don't allow use of stuff that's unavailable
        if LookupTechData(nodeTechId, kTechDataImplemented) == false and not Shared.GetDevMode() then
            newAvailableState = false
        end
        
        if node.available ~= newAvailableState then
        
            node.available = newAvailableState
            
            -- Queue tech node update to clients
            self:SetTechNodeChanged(node, string.format("available = %s", ToString(newAvailableState)))
            
        end
        
    end
    
end

function TechTree:SetTechNodeChanged(node, logMsg)

    if self.techNodesChanged:Insert(node) then
    
        -- Print("TechNode %s changed %s", EnumToString(kTechId, node.techId), ToString(logMsg))
        self.techChanged = true
        
    end
    
end

-- Utility functions
function GetHasTech(callingEntity, techId, silenceError)

    if callingEntity ~= nil and HasMixin(callingEntity, "Team") then
    
        local team = GetGamerules():GetTeam(callingEntity:GetTeamNumber())
        
        if team ~= nil and team:isa("PlayingTeam") then
        
            local techTree = team:GetTechTree()
            
            if techTree ~= nil then
                return techTree:GetHasTech(techId, silenceError)
            end
            
        end
        
    end
    
    return false
    
end
