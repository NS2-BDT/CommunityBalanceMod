-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\CargoGateUserMixin.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

CargoGateUserMixin = CreateMixin( CargoGateUserMixin )
CargoGateUserMixin.type = "CargoGateUser"

local kPhaseDelay = 5.0
local kPhaseRange = 1.0

CargoGateUserMixin.networkVars =
{
    timeOfLastPhase = "compensated private time"
}

local function SharedUpdate(self)
    PROFILE("CargoGateUserMixin:OnUpdate")
    if self:GetCanPhase() then

        for _, CargoGate in ipairs(GetEntitiesForTeamWithinRange("CargoGate", self:GetTeamNumber(), self:GetOrigin(), kPhaseRange)) do
        
            -- don't phase if bot move order destination is not the cargo gate
            if HasMixin(self, "Pathing") and HasMixin(self, "Orders") then
                local currentOrder = self:GetCurrentOrder()
                if currentOrder then

                    local orderLocation = currentOrder:GetLocation()
                    local distToGate = (orderLocation - CargoGate:GetOrigin()):GetLength()
                    if distToGate > kPhaseRange + 0.2 then
                        --Print("don't phase "..distToGate)
                        break
                    end
                    --Print("phase "..distToGate)
                end
            end
        
            if CargoGate:GetIsDeployed() and GetIsUnitActive(CargoGate) and CargoGate:Phase(self) then

                self.timeOfLastPhase = Shared.GetTime()
                
                if Client then               
                    self.timeOfLastPhaseClient = Shared.GetTime()
                    local viewAngles = self:GetViewAngles()
                    Client.SetYaw(viewAngles.yaw)
                    Client.SetPitch(viewAngles.pitch)     
                end
                --[[
                if HasMixin(self, "Controller") then
                    self:SetIgnorePlayerCollisions(1.5)
                end
                --]]
                break
                
            end
        
        end
    
    end

end

function CargoGateUserMixin:__initmixin()
    
    PROFILE("CargoGateUserMixin:__initmixin")
    
    self.timeOfLastPhase = 0
end

local kOnCargoPhase =
{
    CargoGateId = "entityid",
    phasedEntityId = "entityid"
}
Shared.RegisterNetworkMessage("OnCargoPhase", kOnCargoPhase)

if Server then

    function CargoGateUserMixin:OnProcessMove(input)
        PROFILE("CargoGateUserMixin:OnProcessMove")

        if self:GetCanPhase() then
            for _, CargoGate in ipairs(GetEntitiesForTeamWithinRange("CargoGate", self:GetTeamNumber(), self:GetOrigin(), kPhaseRange)) do
                if CargoGate:GetIsDeployed() and GetIsUnitActive(CargoGate) and CargoGate:Phase(self) then
                    -- If we can found a CargoGate we can phase through, inform the server
                    self.timeOfLastPhase = Shared.GetTime()
                    local id = self:GetId()
                    Server.SendNetworkMessage(self:GetClient(), "OnCargoPhase", { CargoGateId = CargoGate:GetId(), phasedEntityId = id or Entity.invalidId }, true)
                    return
                end
            end
        end
    end

    function CargoGateUserMixin:OnUpdate(deltaTime)
        SharedUpdate(self)
    end
    
end

if Client then

    local function OnMessagePhase(message)
        PROFILE("CargoGateUserMixin:OnMessagePhase")

        -- TODO: Is there a better way to do this?
        local CargoGate = Shared.GetEntity(message.CargoGateId)
        local phasedEnt = Shared.GetEntity(message.phasedEntityId)

        -- Need to keep this var updated so that client side effects work correctly
        phasedEnt.timeOfLastPhaseClient = Shared.GetTime()

        CargoGate:Phase(phasedEnt)
        local viewAngles = phasedEnt:GetViewAngles()

        -- Update view angles
        Client.SetYaw(viewAngles.yaw)
        Client.SetPitch(viewAngles.pitch)
    end

    Client.HookNetworkMessage("OnCargoPhase", OnMessagePhase)

end

function CargoGateUserMixin:GetCanPhase()
    if Server then
        -- don't phase entity if it got involuntarily repositioned into the phase gate
        if HasMixin(self, "Repositioning") and self.isRepositioning then
            return false
        end
        if HasMixin(self, "Pathing") and HasMixin(self, "Orders") then
            local currentOrder = self:GetCurrentOrder()
            local isHoldingPosition = currentOrder and currentOrder:GetType() == kTechId.HoldPosition
            if isHoldingPosition then
                return false
            end
        end
        return self:GetIsAlive() and Shared.GetTime() >= self.timeOfLastPhase + kPhaseDelay and not GetConcedeSequenceActive()
    else
        return self:GetIsAlive() and Shared.GetTime() >= self.timeOfLastPhase + kPhaseDelay
    end
    
end

function CargoGateUserMixin:OnCargoGateEntry(destinationOrigin)
    if Server and HasMixin(self, "LOS") then
        self:MarkNearbyDirtyImmediately()
    end
end

function CargoGateUserMixin:OnCargoGateExit(destinationOrigin)
    if not self:isa("Player") then
        if HasMixin(self, "Pathing") then
            self:ResetPathing()
        end
        if HasMixin(self, "Repositioning") then
            self:ToggleRepositioning()
        end
        if HasMixin(self, "Repositioning") then
            --TODO: allow queuing of orders and auto routing using cargo gate like bots
            self:CompletedCurrentOrder()
        end
    end
end

function CargoGateUserMixin:GetForbidModelCoordsUpdate()
    -- Fail. Not sure if this does anything
    return self.timeOfLastPhase + 0.2 > Shared.GetTime() --and self.timeOfLastPhase ~= Shared.GetTime()
end