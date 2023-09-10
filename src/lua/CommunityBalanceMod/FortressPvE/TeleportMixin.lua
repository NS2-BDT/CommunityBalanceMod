-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\TeleportMixin.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
--    Teleports the entity with a delay to a destination entity. If the destination entity has an
--    active order it will spawn at the order location, unless it does not require to be attached.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

TeleportMixin = CreateMixin(TeleportMixin)
TeleportMixin.type = "TeleportAble"

TeleportMixin.kDefaultDelay = 3
TeleportMixin.kMaxRange = 4.5
TeleportMixin.kMinRange = 1
TeleportMixin.kAttachRange = 15
TeleportMixin.kDefaultSinkin = 1.4

TeleportMixin.optionalCallbacks = {

    OnTeleport = "Called when teleport is triggered.",
    OnTeleportEnd = "Called when teleport is done.",
    GetCanTeleportOverride = "Return true/false to allow/prevent teleporting."
    
}

TeleportMixin.networkVars = {
 
    isTeleporting = "boolean",
    teleportDelay = "float"
    
}

function TeleportMixin:OnIsTeleportingChanged()
    
    -- Update rate isn't sync'd, so when we start updating faster during an echo, also increase the
    -- client update rate.
    
    if self.isTeleporting and not self.clientTeleportingCallback then
        
        -- Create a callback that will update the teleporting in real-time (rather than adjusting
        -- the update rate).
        self.clientTeleportingCallback = true
        self:AddTimedCallback(self.ClientTeleportingCallback, kRealTimeUpdateRate)
        
    end
    
    return true -- preserve field watcher
    
end

-- Prevent sleeper mixin from sleeping this entity while being teleported.
local function TeleportMixin_GetCanSleep(self)

    local result = true
    if self.isTeleporting then
        result = false
    elseif self.oldGetCanSleep then
        result = self.oldGetCanSleep(self)
    end
    
    return result
    
end

function TeleportMixin:__initmixin()
    
    PROFILE("TeleportMixin:__initmixin")
    
    self.maxCatalystStacks = TeleportMixin.kDefaultStacks

    if Client then
    
        self.clientIsTeleporting = false
        self:AddFieldWatcher("isTeleporting", self.OnIsTeleportingChanged)
        
    elseif Server then
    
        self.isTeleporting = false
        self.destinationEntityId = Entity.invalidId
        self.timeUntilPort = 0
        self.teleportDelay = 0
    
        if self.GetCanSleep then
            self.oldGetCanSleep = self.GetCanSleep
            self.GetCanSleep = TeleportMixin_GetCanSleep
        end
        
    end
    
end

function TeleportMixin:GetTeleportSinkIn()

    if self.OverrideGetTeleportSinkin then
        return self:OverrideGetTeleportSinkin()
    end
    
    if HasMixin(self, "Extents") then
        return self:GetExtents().y * 2.5
    end    
    
    return TeleportMixin.kDefaultSinkin
    
end   

function TeleportMixin:GetIsTeleporting()
    return self.isTeleporting
end

function TeleportMixin:GetCanTeleport()

    local canTeleport = true
    if self.GetCanTeleportOverride then
        canTeleport = self:GetCanTeleportOverride()
    end

    --new
    if self:GetTechId() == kTechId.FortressShift 
        or self:GetTechId() == kTechId.FortressShade
        or self:GetTechId() == kTechId.FortressWhip
        or self:GetTechId() == kTechId.FortressCrag
    then 
        canTeleport = false 
    end
    
    return canTeleport and not self.isTeleporting
    
end

--
-- Forbid the update of model coordinates while we teleport(?)
--
function TeleportMixin:GetForbidModelCoordsUpdate()
    return self.isTeleporting
end

function TeleportMixin:UpdateTeleportClientEffects(deltaTime)

    if self.clientIsTeleporting ~= self.isTeleporting then
    
        self:TriggerEffects("teleport_start", { effecthostcoords = self:GetCoords(), classname = self:GetClassName() })
        self.clientIsTeleporting = self.isTeleporting
        self.clientTimeUntilPort = self.teleportDelay
        
    end
    
    local renderModel = self:GetRenderModel()
    
    if renderModel then
    
        self.clientTimeUntilPort = math.max(0, self.clientTimeUntilPort - deltaTime)

        local sinkCoords = self:GetCoords()
        local teleportFraction = 1 - (self.clientTimeUntilPort / self.teleportDelay)

        sinkCoords.origin = sinkCoords.origin - teleportFraction * self:GetTeleportSinkIn() * sinkCoords.yAxis
        renderModel:SetCoords(sinkCoords)

    end

end

local function GetAttachDestination(self, attachTo, destinationOrigin)

    local attachEntities = GetEntitiesWithinRange(attachTo, destinationOrigin, TeleportMixin.kAttachRange)
    
    for i=1,#attachEntities do
        local ent = attachEntities[i]
        if not ent:GetAttached() and GetInfestationRequirementsMet(self:GetTechId(), ent:GetOrigin()) then
            
            -- free up old attached entity and attach to new
            local attached = self:GetAttached()
            if attached then
                attached:ClearAttached()
            end
            self:ClearAttached()
            
            self:SetAttached(ent)
            
            local attachCoords = ent:GetCoords()
            attachCoords.origin.y = attachCoords.origin.y + LookupTechData(self:GetTechId(), kTechDataSpawnHeightOffset, 0)
            
            return attachCoords
            
        end
    end

end

local function GetRandomSpawn(self, destinationOrigin)

    local extents = self:GetExtents()
    local randomSpawn
    local requiresInfestation = LookupTechData(self:GetTechId(), kTechDataRequiresInfestation, false)
    
    for i = 1, 25 do
    
        randomSpawn = GetRandomSpawnForCapsule(extents.y, extents.x, destinationOrigin, TeleportMixin.kMinRange, TeleportMixin.kMaxRange)
        if randomSpawn and GetInfestationRequirementsMet(self:GetTechId(), randomSpawn) then
            randomSpawn = GetGroundAtPosition(randomSpawn, nil, PhysicsMask.CommanderBuild) --, self:GetExtents())
            return Coords.GetTranslation(randomSpawn)
        end
        
    end

end

local function AddObstacle(self)

    if self.obstacleId == -1 then
        self:AddToMesh()
    end    
       
    return false
 
end

local function PerformTeleport(self)

    local destinationEntity = Shared.GetEntity(self.destinationEntityId)
    
    if destinationEntity then

        local destinationCoords
        local attachTo = LookupTechData(self:GetTechId(), kStructureAttachClass, nil)
        
        -- find a free attach entity
        if attachTo then
            destinationCoords = GetAttachDestination(self, attachTo, self.destinationPos)
        else
            destinationCoords = Coords.GetTranslation(self.destinationPos)
        end
        
        if destinationCoords then

            if HasMixin(self, "Obstacle") then
                self:RemoveFromMesh()
            end
        
            self:SetCoords(destinationCoords)

            if HasMixin(self, "Obstacle") then
                -- this needs to be delayed, otherwise the obstacle is created too early and stacked up structures would not be able to push each other away
                self:AddTimedCallback(AddObstacle, 3)
            end
            
            local location = GetLocationForPoint(self:GetOrigin())
            local locationName = location and location:GetName() or ""
            
            self:SetLocationName(locationName, true)
            
            self:TriggerEffects("teleport_end", { classname = self:GetClassName() })
            
            if self.OnTeleportEnd then
                self:OnTeleportEnd(destinationEntity)
            end
            
            if HasMixin(self, "StaticTarget") then
                self:StaticTargetMoved()
            end

        else
            -- teleport has failed, give back resources to shift

            if destinationEntity then
                destinationEntity:GetTeam():AddTeamResources(self.teleportCost)
            end
        
        end
    
    end
    
    self.destinationEntityId = Entity.invalidId
    self.isTeleporting = false
    self.timeUntilPort = 0
    self.teleportDelay = 0

end 

local function SharedUpdate(self, deltaTime)
    
    if Server then
    
        if self.isTeleporting then 
  
            self.timeUntilPort = math.max(0, self.timeUntilPort - deltaTime)
            if self.timeUntilPort == 0 then
                PerformTeleport(self)
            end
            
        end
    
    elseif Client then
    
        if self.isTeleporting then        
            self:UpdateTeleportClientEffects(deltaTime)
            
        elseif self.clientIsTeleporting then
            self.clientIsTeleporting = false
        end 
        
    end


end

function TeleportMixin:OnProcessMove(input)
    SharedUpdate(self, input.time)
end

function TeleportMixin:OnUpdate(deltaTime)
    
    PROFILE("TeleportMixin:OnUpdate")
    
    if Server then
        SharedUpdate(self, deltaTime)
    end
    
    -- Use normal OnUpdate to call SharedUpdate for client, but only if we're not telporting.
    -- Otherwise, use full-speed update callback below.
    if Client and not self.isTeleporting then
        SharedUpdate(self, deltaTime)
    end
    
end

function TeleportMixin:ClientTeleportingCallback(deltaTime)
    
    if not self.isTeleporting then
        self.clientTeleportingCallback = false
        return false -- terminate the callback
    end

    SharedUpdate(self, deltaTime)
    
    return true -- preserve the callback

end

function TeleportMixin:TriggerTeleport(delay, destinationEntityId, destinationPos, cost)

    if Server then
    
        self.teleportDelay = ConditionalValue(delay, delay, TeleportMixin.kDefaultDelay)
        self.timeUntilPort = ConditionalValue(delay, delay, TeleportMixin.kDefaultDelay)
        self.destinationEntityId = destinationEntityId
        self.destinationPos = destinationPos
        self.isTeleporting = true
        self.teleportCost = cost
        
        if self.OnTeleport then
            self:OnTeleport()
        end

        StatsUI_AddExportBuilding(self:GetTeamNumber(),
            self.GetTechId and self:GetTechId(),
            self:GetId(),
            destinationPos,
            StatsUI_kLifecycle.Teleported,
            not self.GetIsBuilt or self:GetIsBuilt())
        
    end
    
end

function TeleportMixin:OnUpdateAnimationInput(modelMixin)

    modelMixin:SetAnimationInput("isTeleporting", self.isTeleporting)

end

