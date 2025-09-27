-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\PowerConsumerMixin.lua
--
--    Created by: Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/PowerUtility.lua")
Script.Load("lua/CommAbilities/Marine/EMPBlast.lua")

PowerConsumerMixin = CreateMixin(PowerConsumerMixin)
PowerConsumerMixin.type = "PowerConsumer"

PowerConsumerMixin.ClientPowerNodeCheckIntervall = 10

-- This is needed so alien structures can be cloaked, but not marine structures
PowerConsumerMixin.expectedCallbacks =
{
    GetRequiresPower = "Return true/false if this object requires power"
}

PowerConsumerMixin.optionalCallbacks =
{
    OnPowerOff = "called on power loss",
    OnPowerOn = "called on power gain",
    GetIsPoweredOverride = "override power state"
}

PowerConsumerMixin.networkVars =
{
    powered = "boolean",
    powerSurge = "boolean",
	powerBattery = "boolean",
	lastBatteryCheckTime = "time"
}

function PowerConsumerMixin:__initmixin()
    
    PROFILE("PowerConsumerMixin:__initmixin")
    
    self.powered = false
    self.powerSurge = false
	self.powerBattery = false
	self.lastBatteryCheckTime = 0
    self.timePowerSurgeEnds = 0 --Does this not need to be contained pure server-side?
end

if Server then

    function PowerConsumerMixin:OnLocationChange(locationName)
    
        self.powerSourceId = Entity.invalidId
        if self:GetRequiresPower() then
            SocketPowerForLocation(locationName)
        end
        
    end
    
end

function PowerConsumerMixin:SetPowerSurgeDuration(duration)

    if kPowerSurgeTriggerEMP and self:GetIsPowered() then
        CreateEntity( EMPBlast.kMapName, self:GetOrigin(), self:GetTeamNumber() )
    end

    self.timePowerSurgeEnds = Shared.GetTime() + duration
    self.powerSurge = true

    --Make sure to call this after setting up the powersurge parameters!
    if self.OnPowerOn then
        self:OnPowerOn()
    end
    
end

function PowerConsumerMixin:GetIsPowered() 
    return self.powered or self.powerSurge or self.powerBattery
end

function PowerConsumerMixin:GetIsPowerSurged()
    return self.powerSurge
end

function PowerConsumerMixin:GetCanBeUsed(player, useSuccessTable)

    if not self:GetIsPowered() then
        useSuccessTable.useSuccess = false
    end
    
end

if Server then

    local function CheckForPowerSource(self)
    
        if self:GetRequiresPower() then
            
            if not self.powerSourceId or self.powerSourceId == Entity.invalidId then
            
                local powerSource = FindNewPowerSource(self)
                if powerSource then
                    
                    powerSource:AddConsumer(self)
                    self.powerSourceId = powerSource:GetId()
                    self:SetPowerOn()
                    
                end
			
            elseif self.powerSourceId then
                local powerSource = Shared.GetEntity(self.powerSourceId)
                if powerSource and powerSource:GetIsPowering() then
                    self:SetPowerOn()
                else
                    self:SetPowerOff()
                end
            end
            
        end
        
    end
    
    local function Deploy(self)
        self:TriggerEffects("deploy")
    end
    
    function PowerConsumerMixin:OnInitialized()
        CheckForPowerSource(self)
    end
    
    function PowerConsumerMixin:SetOrigin()
        CheckForPowerSource(self)
    end
    
    function PowerConsumerMixin:SetCoords()
        CheckForPowerSource(self)
    end
    
    function PowerConsumerMixin:OnConstructionComplete()
        CheckForPowerSource(self)
        
        if not self:GetRequiresPower() or self:GetIsPowered() then
            Deploy(self)
        else
            self.updateDeployOnPower = true
        end
        
    end
    
    function PowerConsumerMixin:OnUpdate(deltaTime)
        PROFILE("PowerConsumerMixin:OnUpdate")
        
        if self.powerSurge then
        
            local endSurge = self.timePowerSurgeEnds < Shared.GetTime() 
            
            if endSurge then
                
                self.powerSurge = false
                
                if self.OnPowerOff and not self.powerBattery then
                    self:OnPowerOff()
                end
            end
        end
        
		if not self.powered then -- Don't bother checking battery power if power is up!
			if (self.lastBatteryCheckTime == nil or (Shared.GetTime() > self.lastBatteryCheckTime + 0.5)) and HasMixin(self, "Team") then
			
				self.powerBattery = false
			
				local ents = GetEntitiesForTeamWithinRange("SentryBattery", self:GetTeamNumber(), self:GetOrigin(), SentryBattery.kRange)
				
				for index, ent in ipairs(ents) do
				
					--if GetIsUnitActive(ent) and ent:GetLocationName() == self:GetLocationName() then
					if GetIsUnitActive(ent) then
					
						self.powerBattery = true				
						break
						
					end
				end
				self.lastBatteryCheckTime = Shared.GetTime()
			end
		end
    end
    
    -- no need to trigger power on and power off events
    function PowerConsumerMixin:OnEntityChange(oldId, newId)
    
        if oldId == self.powerSourceId then
        
            if newId and not newId == Entity.invalidId then
            
                local powerSource = Shared.GetEntity(newId)
                
                if powerSource and HasMixin(powerSource, "PowerSource") then
                
                    if powerSource:GetCanPower(self) then
                    
                        powerSource:AddConsumer(self)
                        self.powerSourceId = newId
                        
                    end
                    
                end
                
            else
            
                self.powerSourceId = Entity.invalidId
                CheckForPowerSource(self)
                
            end
            
        end
        
    end
    
    function PowerConsumerMixin:SetPowerOn()
    
        if not self.powered then
        
            self.powered = true
            
            if self.OnPowerOn then
                self:OnPowerOn()
            end
            
            if self.updateDeployOnPower then
            
                Deploy(self)
                self.updateDeployOnPower = false
                
            end
            
        end
        
    end
    
    function PowerConsumerMixin:SetPowerOff()
        
        if self.powered then
        
            self.powered = false
            			
            if self.OnPowerOff and not self.powerSurge and not self.powerBattery then
            --powerSurge is handled in OnUpdate safe to ignore expiration of effect here
                self:OnPowerOff()
            end
            
        end
        
    end
	    
elseif Client then

    -- TODO: listen to power state changes and trigger effects
    
end

function PowerConsumerMixin:OnUpdateAnimationInput(modelMixin)

    PROFILE("PowerConsumerMixin:OnUpdateAnimationInput")
    
    modelMixin:SetAnimationInput("powered", self:GetIsPowered())
    
end

function PowerConsumerMixin:OnUpdateRender()

    if self.powerSurge then
    
        if not self.timeLastPowerSurgeEffect or self.timeLastPowerSurgeEffect + 1 < Shared.GetTime() then
        
            self:TriggerEffects("power_surge")
            self.timeLastPowerSurgeEffect = Shared.GetTime()
        
        end
    
    end


end