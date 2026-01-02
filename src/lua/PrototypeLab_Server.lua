-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\PrototypeLab.lua
--
--    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local function OnDeploy(self)

    self.deployed = true
    return false
    
end

local kDeployTime = 5.5

function PrototypeLab:OnConstructionComplete()
    self:AddTimedCallback(OnDeploy, kDeployTime)
end

-- west/east = x/-x
-- north/south = -z/z
local indexToUseOrigin =
{
    -- West
    Vector(PrototypeLab.kResupplyUseRange, 0, 0), 
    -- North
    Vector(0, 0, -PrototypeLab.kResupplyUseRange),
    -- South
    Vector(0, 0, PrototypeLab.kResupplyUseRange),
    -- East
    Vector(-PrototypeLab.kResupplyUseRange, 0, 0)
}

function PrototypeLab:UpdateLoggedIn()

    local players = GetEntitiesForTeamWithinRange("Marine", self:GetTeamNumber(), self:GetOrigin(), 2 * PrototypeLab.kResupplyUseRange)
    local ptLabCoords = self:GetAngles():GetCoords()
    
    for i = 1, 4 do
    
        local newState = false
        
        if GetIsUnitActive(self) and self.deployed then
        
            local worldUseOrigin = self:GetModelOrigin() + ptLabCoords:TransformVector(indexToUseOrigin[i])
            
            for playerIndex, player in ipairs(players) do
            
                -- See if player is nearby
                if player:GetIsAlive() and (player:GetModelOrigin() - worldUseOrigin):GetLength() < PrototypeLab.kResupplyUseRange then
                
                    newState = true
                    break
                    
                end
                
            end
            
        end
        
        if newState ~= self.loggedInArray[i] then
        
            if newState then
                self:TriggerEffects("prototypelab_open")
            else
                self:TriggerEffects("prototypelab_close")
            end
            
            self.loggedInArray[i] = newState
            
        end
        
    end
    
    -- Copy data to network variables (arrays not supported)
    self.loggedInWest = self.loggedInArray[1]
    self.loggedInNorth = self.loggedInArray[2]
    self.loggedInSouth = self.loggedInArray[3]
    self.loggedInEast = self.loggedInArray[4]
    
    return true
    
end

-- %%% New CBM Functions %%% --
function PrototypeLab:UpdateResearch()

    local researchId = self:GetResearchingId()

    if researchId == kTechId.UpgradeToExoPrototypeLab then
    
        local techTree = self:GetTeam():GetTechTree()
		
        local researchNode = techTree:GetTechNode(kTechId.ExoPrototypeLab)   
        researchNode:SetResearchProgress(self.researchProgress)
        techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress)) 

    elseif researchId == kTechId.UpgradeToInfantryPrototypeLab then
    
        local techTree = self:GetTeam():GetTechTree()    
        local researchNode = techTree:GetTechNode(kTechId.JetpackTech)   
        researchNode:SetResearchProgress(self.researchProgress)
        techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress)) 
	
    end

end


function PrototypeLab:OnResearchCancel(researchId)

    if researchId == kTechId.UpgradeToExoPrototypeLab then
    
        local team = self:GetTeam()
        
        if team then
        
            local techTree = team:GetTechTree()
            local researchNode = techTree:GetTechNode(kTechId.ExoPrototypeLab)
            if researchNode then
                researchNode:ClearResearching()
                techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", 0))   
            end
        end

	elseif researchId == kTechId.UpgradeToInfantryPrototypeLab then

        local team = self:GetTeam()
        
        if team then
        
            local techTree = team:GetTechTree()
            local researchNode = techTree:GetTechNode(kTechId.JetpackTech)
            if researchNode then
                researchNode:ClearResearching()
                techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", 0))   
            end
        end	
		
    end
end

-- Called when research or upgrade complete
function PrototypeLab:OnResearchComplete(researchId)
    if researchId == kTechId.UpgradeToExoPrototypeLab then
    
        self:SetTechId(kTechId.ExoPrototypeLab)
        
        local techTree = self:GetTeam():GetTechTree()
        local researchNode = techTree:GetTechNode(kTechId.ExosuitTech)
        
        if researchNode then     
   
            researchNode:SetResearchProgress(1)
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", 1))
            researchNode:SetResearched(true)
            techTree:QueueOnResearchComplete(kTechId.ExosuitTech, self)
            
        end

    elseif researchId == kTechId.UpgradeToInfantryPrototypeLab then
    
        self:SetTechId(kTechId.InfantryPrototypeLab)
        
        local techTree = self:GetTeam():GetTechTree()
        local researchNode = techTree:GetTechNode(kTechId.JetpackTech)
        
        if researchNode then     
   
            researchNode:SetResearchProgress(1)
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", 1))
            researchNode:SetResearched(true)
            techTree:QueueOnResearchComplete(kTechId.JetpackTech, self)
            
        end
        
    end
	
	
	if HasMixin(self, "MapBlip") then 
		self:MarkBlipDirty()
	end       
end
