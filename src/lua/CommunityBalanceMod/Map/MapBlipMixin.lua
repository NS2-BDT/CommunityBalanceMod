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