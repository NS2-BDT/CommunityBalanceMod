-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\MapBlipMixin.lua
--
--    Created by:   Brian Cronin (brianc@unknownworlds.com)
--    Modified by: Mats Olsson (mats.olsson@matsotech.se)
--
-- Creates a mapblip for an entity that may have one.
--
-- Also marks a mapblip as dirty for later updates if it changes, by
-- listening on SetLocation, SetAngles and SetSighted calls.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

MapBlipMixin = CreateMixin( MapBlipMixin )
MapBlipMixin.type = "MapBlip"

--
-- Listen on the state that the mapblip depends on
--
MapBlipMixin.expectedCallbacks =
{
    SetOrigin = "Sets the location of an entity",
    SetAngles = "Sets the angles of an entity",
    SetCoords = "Sets both both location and angles"
}

MapBlipMixin.optionalCallbacks =
{
    GetDestroyMapBlipOnKill = "Return true to destroy map blip when units is killed.",
    OnGetMapBlipInfo = "Override for getting the Map Blip Info",
}

-- What entities have become dirty.
-- Flushed in the UpdateServer hook by MapBlipMixin.OnUpdateServer
local mapBlipMixinDirtyTable = unique_set()

--
-- Update all dirty mapblips
--
local function MapBlipMixinOnUpdateServer()
    PROFILE("MapBlipMixin:OnUpdateServer")

    for entityId in mapBlipMixinDirtyTable:Iterate() do
        local entity = Shared.GetEntity(entityId)
        local mapBlip = entity and entity.mapBlipId and Shared.GetEntity(entity.mapBlipId)
        if mapBlip then
            mapBlip:Update()
        end

    end

    mapBlipMixinDirtyTable:Clear()

end


local function CreateMapBlip(self, blipType, blipTeam, _)

    local mapName = MapBlip.kMapName
    --special mapblips
    if self:isa("Player") then
        mapName = PlayerMapBlip.kMapName
    elseif self:isa("Scan") then
        mapName = ScanMapBlip.kMapName
    end

    local mapBlip = Server.CreateEntity(mapName)
    -- This may fail if there are too many entities.
    if mapBlip then

        mapBlip:SetOwner(self:GetId(), blipType, blipTeam)
        self.mapBlipId = mapBlip:GetId()

    end

end

function MapBlipMixin:__initmixin()
    
    PROFILE("MapBlipMixin:__initmixin")
    
    assert(Server)

    -- Check if the new entity should have a map blip to represent it.
    local success, blipType, blipTeam, isInCombat = self:GetMapBlipInfo()
    if success then
        CreateMapBlip(self, blipType, blipTeam, isInCombat)
    end

end

function MapBlipMixin:OnInitialized()
    UpdateEntityForTeamBrains(self)
end

--
-- Intercept the functions that changes the state the mapblip depends on
--
function MapBlipMixin:SetOrigin()
    mapBlipMixinDirtyTable:Insert(self:GetId())
end

function MapBlipMixin:SetAngles()
    mapBlipMixinDirtyTable:Insert(self:GetId())
end

function MapBlipMixin:SetCoords()
    mapBlipMixinDirtyTable:Insert(self:GetId())
end

function MapBlipMixin:OnEnterCombat()
    mapBlipMixinDirtyTable:Insert(self:GetId())
end

function MapBlipMixin:OnLeaveCombat()
    mapBlipMixinDirtyTable:Insert(self:GetId())
end

function MapBlipMixin:MarkBlipDirty()
    mapBlipMixinDirtyTable:Insert(self:GetId())
end

function MapBlipMixin:OnConstructionComplete()
    mapBlipMixinDirtyTable:Insert(self:GetId())
end

function MapBlipMixin:OnPowerOn()
    mapBlipMixinDirtyTable:Insert(self:GetId())
end

function MapBlipMixin:OnPowerOff()
    mapBlipMixinDirtyTable:Insert(self:GetId())
end

function MapBlipMixin:OnPhaseGateEntry()
    mapBlipMixinDirtyTable:Insert(self:GetId())
end

function MapBlipMixin:OnCargoGateEntry()
    mapBlipMixinDirtyTable:Insert(self:GetId())
end

function MapBlipMixin:OnUseGorgeTunnel()
    mapBlipMixinDirtyTable:Insert(self:GetId())
end

function MapBlipMixin:OnPreBeacon()
    mapBlipMixinDirtyTable:Insert(self:GetId())
end

function MapBlipMixin:OnSighted(sighted)

    -- because sighted is always set during each LOS calc, we need to keep track of
    -- what the previous value was so we don't mark it dirty unnecessarily
    if self.previousSighted ~= sighted then
        self.previousSighted = sighted
        mapBlipMixinDirtyTable:Insert(self:GetId())
    end

end

-- Todo: Add per frame time cache
function MapBlipMixin:GetMapBlipInfo()
    PROFILE("MapBlipMixin:GetMapBlipInfo")

    if self.OnGetMapBlipInfo then
        return self:OnGetMapBlipInfo()
    end

    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    local isParasited = HasMixin(self, "ParasiteAble") and self:GetIsParasited()

    -- World entities
    if self:isa("Door") then
        blipType = kMinimapBlipType.Door
    elseif self:isa("ResourcePoint") then
        blipType = kMinimapBlipType.ResourcePoint
    elseif self:isa("TechPoint") then
        blipType = kMinimapBlipType.TechPoint
        -- Don't display PowerPoints unless they are in an unpowered state.
    elseif self:isa("PowerPoint") then

        if self:GetIsDisabled() then
            blipType = kMinimapBlipType.DestroyedPowerPoint
        elseif self:GetIsBuilt() then
            blipType = kMinimapBlipType.PowerPoint
        elseif self:GetIsSocketed() then
            blipType = kMinimapBlipType.BlueprintPowerPoint
        else
            blipType = kMinimapBlipType.UnsocketedPowerPoint
        end

        blipTeam = self:GetTeamNumber()

    elseif self:isa("Cyst") then

        blipType = kMinimapBlipType.Infestation

        if not self:GetIsConnected() then
            blipType = kMinimapBlipType.InfestationDying
        end

        blipTeam = self:GetTeamNumber()
        isAttacked = false

    elseif self:isa("Hallucination") then

        local hallucinatedTechId = self:GetAssignedTechId()

        if hallucinatedTechId == kTechId.Drifter then
            blipType = kMinimapBlipType.Drifter
        elseif hallucinatedTechId == kTechId.Hive then
            blipType = kMinimapBlipType.Hive
        elseif hallucinatedTechId == kTechId.Harvester then
            blipType = kMinimapBlipType.Harvester
        end

        blipTeam = self:GetTeamNumber()

    elseif self.GetMapBlipType then
        blipType = self:GetMapBlipType()
        blipTeam = self:GetTeamNumber()

        -- Everything else that is supported by kMinimapBlipType.
    elseif self:GetIsVisible() then

        if rawget( kMinimapBlipType, self:GetClassName() ) ~= nil then
            blipType = kMinimapBlipType[self:GetClassName()]
        else
            Shared.Message( "Element '"..tostring(self:GetClassName()).."' doesn't exist in the kMinimapBlipType enum" )
        end

        blipTeam = HasMixin(self, "Team") and self:GetTeamNumber() or kTeamReadyRoom

    end

    if blipType ~= 0 then
        success = true
    end

	-- %%% CBM Blips %%% --
	if self:GetTechId() == kTechId.FortressCrag then 
        blipType = kMinimapBlipType.FortressCrag
        blipTeam = self:GetTeamNumber()
        return success, blipType, blipTeam, isAttacked, isParasited

    elseif self:GetTechId() == kTechId.FortressShade then 
        blipType = kMinimapBlipType.FortressShade
        blipTeam = self:GetTeamNumber()
        return success, blipType, blipTeam, isAttacked, isParasited

    elseif self:GetTechId() == kTechId.FortressShift then 
        blipType = kMinimapBlipType.FortressShift
        blipTeam = self:GetTeamNumber()
        return success, blipType, blipTeam, isAttacked, isParasited
      
    elseif self:GetTechId() == kTechId.FortressWhip then 
        local mature = self:GetIsMature()
        blipTeam = self:GetTeamNumber()
        if mature then 
            blipType = kMinimapBlipType.FortressWhipMature
        else 
            blipType = kMinimapBlipType.FortressWhip
        end
        return success, blipType, blipTeam, isAttacked, isParasited

	elseif self:isa("CommandStation") then 
        local occupied = not ( self:GetCommander() == nil )
        blipTeam = self:GetTeamNumber()  

        if occupied then 
            blipType = kMinimapBlipType.CommandStationOccupied
        else 
            blipType = kMinimapBlipType.CommandStation
        end

        return success, blipType, blipTeam, isAttacked, isParasited
         
    elseif self:isa("Whip") then 
        local mature = self:GetIsMature()
        blipTeam = self:GetTeamNumber()  

        if mature then 
            blipType = kMinimapBlipType.WhipMature
        else 
            blipType = kMinimapBlipType.Whip
        end

        return success, blipType, blipTeam, isAttacked, isParasited

    elseif self:isa("Hive") then
        local maturityLevel =  self:GetMaturityFraction()
        local occupied = not ( self:GetCommander() == nil )
        blipTeam = self:GetTeamNumber()  

		if self.bioMassLevel == 5 then
			if maturityLevel < 0.34 then 
				if occupied then 
					blipType = kMinimapBlipType.HiveFreshOccupiedFifthBio
				else 
					blipType = kMinimapBlipType.HiveFreshFifthBio
				end

			elseif maturityLevel > 0.65 then 
				if occupied then 
					blipType = kMinimapBlipType.HiveMatureOccupiedFifthBio
				else 
					blipType = kMinimapBlipType.HiveMatureFifthBio
				end

			else 
				if occupied then 
					blipType = kMinimapBlipType.HiveOccupiedFifthBio
				else 
					blipType = kMinimapBlipType.HiveFifthBio
				end
			end
		else
			if maturityLevel < 0.34 then 
				if occupied then 
					blipType = kMinimapBlipType.HiveFreshOccupied
				else 
					blipType = kMinimapBlipType.HiveFresh
				end

			elseif maturityLevel > 0.65 then 
				if occupied then 
					blipType = kMinimapBlipType.HiveMatureOccupied
				else 
					blipType = kMinimapBlipType.HiveMature
				end

			else 
				if occupied then 
					blipType = kMinimapBlipType.HiveOccupied
				else 
					blipType = kMinimapBlipType.Hive
				end
			end
		end

        return success, blipType, blipTeam, isAttacked, isParasited

    elseif self:isa("Armory") then
        blipTeam = self:GetTeamNumber()  
        
        if self:GetIsAdvanced() then 
            blipType = kMinimapBlipType.AdvancedArmory
        else
            blipType = kMinimapBlipType.Armory
        end
        return success, blipType, blipTeam, isAttacked, isParasited

	elseif self:isa("DIS") then
        blipTeam = self:GetTeamNumber()  

        if self:GetPlayIdleSound() then
            blipType = kMinimapBlipType.DIS
        else
            blipType = kMinimapBlipType.DISDeployed
        end
      
        return success, blipType, blipTeam, isAttacked, isParasited

    elseif self:isa("ARC") then
        blipTeam = self:GetTeamNumber()  

        if self:GetPlayIdleSound() then
            blipType = kMinimapBlipType.ARC
        else
            blipType = kMinimapBlipType.ARCDeployed
        end
      
        return success, blipType, blipTeam, isAttacked, isParasited
    
	elseif self:isa("SentryBattery") then
        blipTeam = self:GetTeamNumber()  
		
		if self:GetTechId() == kTechId.ShieldBattery then
            blipType = kMinimapBlipType.ShieldedSentryBattery
        else
            blipType = kMinimapBlipType.SentryBattery
        end
      
        return success, blipType, blipTeam, isAttacked, isParasited
			
	elseif self:isa("Observatory") then
        blipTeam = self:GetTeamNumber()  
		
		if self:GetTechId() == kTechId.AdvancedObservatory then
            blipType = kMinimapBlipType.AdvancedObservatory
        else
            blipType = kMinimapBlipType.Observatory
        end
      
        return success, blipType, blipTeam, isAttacked, isParasited
	
	elseif self:isa("RoboticsFactory") then
        blipTeam = self:GetTeamNumber()  
		
		if self:GetTechId() == kTechId.ARCRoboticsFactory then
            blipType = kMinimapBlipType.ARCRoboticsFactory
        else
            blipType = kMinimapBlipType.RoboticsFactory
        end
      
        return success, blipType, blipTeam, isAttacked, isParasited
	
	elseif self:isa("PrototypeLab") then
        blipTeam = self:GetTeamNumber()  
		
		if self:GetTechId() == kTechId.InfantryPrototypeLab then
            blipType = kMinimapBlipType.InfantryPrototypeLab
        elseif self:GetTechId() == kTechId.ExoPrototypeLab then
			blipType = kMinimapBlipType.ExoPrototypeLab
		else
            blipType = kMinimapBlipType.PrototypeLab
        end
      
        return success, blipType, blipTeam, isAttacked, isParasited
		
	end

    return success, blipType, blipTeam, isAttacked, isParasited

end

function MapBlipMixin:DestroyBlip()

    local mapBlip = self.mapBlipId and Shared.GetEntity(self.mapBlipId)
    if mapBlip then

        DestroyEntity(mapBlip)
        self.mapBlipId = nil

    end

end

function MapBlipMixin:OnKill()

    if not self.GetDestroyMapBlipOnKill or self:GetDestroyMapBlipOnKill() then
        self:DestroyBlip()
        UpdateEntityForTeamBrains(self, true)
    end

end

function MapBlipMixin:OnDestroy()
    self:DestroyBlip()
    UpdateEntityForTeamBrains(self, true)
end

Event.Hook("UpdateServer", MapBlipMixinOnUpdateServer)