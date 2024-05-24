--local oldInitialize = MarineTeam.Initialize
--function MarineTeam:Initialize(teamName, teamNumber)
--    oldInitialize(self, teamName, teamNumber)
--    self.clientOwnedStructures = { }
--
--end

local oldInitTechTree = MarineTeam.InitTechTree
function MarineTeam:InitTechTree()
    
    
    local oldSetComplete = TechTree.SetComplete
    TechTree.SetComplete = function()
    end
    
    oldInitTechTree(self)
    
    self.techTree:AddResearchNode(kTechId.ClawRailgunExosuit, kTechId.ExosuitTech, kTechId.None)
    self.techTree:AddBuyNode(kTechId.Exosuit, kTechId.ExosuitTech, kTechId.None)
    
    TechTree.SetComplete = oldSetComplete
    self.techTree:SetComplete()

end

--[[local oldAddResearchNode = TechTree.AddResearchNode
function TechTree:AddResearchNode(techId, prereq1, prereq2, addOnTechId)

    if techId == kTechId.JetpackTech then
	   prereq1 = kTechId.AdvancedArmory
    end
    oldAddResearchNode(self, techId, prereq1, prereq2, addOnTechId)
end

local oldAddBuildNode = TechTree.AddBuildNode
function TechTree:AddBuildNode(techId, prereq1, prereq2, isRequired)

    if techId == kTechId.PrototypeLab then
	   prereq1 = kTechId.Armory
    end
    oldAddBuildNode(self, techId, prereq1, prereq2, addOnTechId)
end]]--
--
--function MarineTeam:GetNumDroppedStructures(player, techId)
--
--    local structureTypeTable = self:GetDroppedMarineStructures(player, techId)
--    return (not structureTypeTable and 0) or #structureTypeTable
--
--end
--
--local function RemoveMarineStructureFromClient(self, techId, clientId)
--
--    local structureTypeTable = self.clientOwnedStructures[clientId]
--
--    if structureTypeTable then
--
--        if not structureTypeTable[techId] then
--
--            structureTypeTable[techId] = { }
--            return
--
--        end
--
--        local removeIndex = 0
--        local structure = nil
--        for index, id in ipairs(structureTypeTable[techId]) do
--
--            if id then
--
--                removeIndex = index
--                structure = Shared.GetEntity(id)
--                break
--
--            end
--
--        end
--
--        if structure then
--
--            table.remove(structureTypeTable[techId], removeIndex)
--            structure.consumed = true
--            if structure:GetCanDie() then
--                structure:Kill()
--            else
--                DestroyEntity(structure)
--            end
--
--        end
--
--    end
--
--end
--
--function MarineTeam:AddMarineStructure(player, structure)
--
--    if player ~= nil and structure ~= nil then
--
--        local clientId = Server.GetOwner(player):GetUserId()
--        local structureId = structure:GetId()
--        local techId = structure:GetTechId()
--
--        if not self.clientOwnedStructures[clientId] then
--            self.clientOwnedStructures[clientId] = { }
--        end
--
--        local structureTypeTable = self.clientOwnedStructures[clientId]
--
--        if not structureTypeTable[techId] then
--            structureTypeTable[techId] = { }
--        end
--
--        table.insertunique(structureTypeTable[techId], structureId)
--
--        local numAllowedStructure = LookupTechData(techId, kTechDataMaxAmount, -1) --* self:GetNumHives()
--
--        if numAllowedStructure >= 0 and table.count(structureTypeTable[techId]) > numAllowedStructure then
--            RemoveMarineStructureFromClient(self, techId, clientId)
--        end
--
--    end
--
--end
--
--function MarineTeam:GetDroppedMarineStructures(player, techId)
--
--    local owner = Server.GetOwner(player)
--
--    if owner then
--
--        local clientId = owner:GetUserId()
--        local structureTypeTable = self.clientOwnedStructures[clientId]
--
--        if structureTypeTable then
--            return structureTypeTable[techId]
--        end
--
--    end
--
--end
--
--function MarineTeam:GetNumDroppedMarineStructures(player, techId)
--
--    local structureTypeTable = self:GetDroppedMarineStructures(player, techId)
--    return (not structureTypeTable and 0) or #structureTypeTable
--
--end
--
--function MarineTeam:UpdateClientOwnedStructures(oldEntityId)
--
--    if oldEntityId then
--
--        for clientId, structureTypeTable in pairs(self.clientOwnedStructures) do
--
--            for techId, structureList in pairs(structureTypeTable) do
--
--                for i, structureId in ipairs(structureList) do
--
--                    if structureId == oldEntityId then
--
--                        table.remove(structureList, i)
--                        break
--
--                    end
--
--                end
--
--            end
--
--        end
--
--    end
--
--end
--
--function MarineTeam:OnEntityChange(oldEntityId, newEntityId)
--
--    PlayingTeam.OnEntityChange(self, oldEntityId, newEntityId)
--
--    -- Check if the oldEntityId matches any client's built structure and
--    -- handle the change.
--
--    self:UpdateClientOwnedStructures(oldEntityId)
--
--end