-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\StormCloudMixin.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

StormCloudMixin = CreateMixin( StormCloudMixin )
StormCloudMixin.type = "Storm"

kStormCloudSpeed = 1.8

StormCloudMixin.networkVars =
{
    stormCloudSpeed = "private boolean",
}

function StormCloudMixin:__initmixin()
    
    PROFILE("StormCloudMixin:__initmixin")
    
    self.timeUntilStormCloud = 0
    self.stormCloudSpeed = false
    
end

function StormCloudMixin:ModifyMaxSpeed(maxSpeedTable)

    if self.stormed and GetHasCelerityUpgrade(self) and not (self:isa("Fade") or self:isa("Lerk") or self:isa("Skulk")) then 
		local SpurLevel = self:GetSpurLevel()
		local SpeedAdd = math.min(2.25 - SpurLevel*0.5,1.5)
        maxSpeedTable.maxSpeed = maxSpeedTable.maxSpeed + SpeedAdd
	elseif self.stormed and GetHasCelerityUpgrade(self) then 
		local SpurLevel = self:GetSpurLevel()
		local SpeedAdd = math.min(1.5 - SpurLevel*0.5,1.5)
		maxSpeedTable.maxSpeed = maxSpeedTable.maxSpeed + SpeedAdd
	elseif self.stormed then
		maxSpeedTable.maxSpeed = maxSpeedTable.maxSpeed + 1.5
    end
end

if Server then

    function StormCloudMixin:SetSpeedBoostDuration(duration)
        
        self.timeUntilStormCloud = Shared.GetTime() + duration
        self.stormCloudSpeed = true
        
    end
    
    local function SharedUpdate(self)
        self.stormCloudSpeed = self.timeUntilStormCloud >= Shared.GetTime()
    end

    function StormCloudMixin:OnProcessMove(input)    
        SharedUpdate(self)
    end
    
    function StormCloudMixin:OnUpdate(deltaTime)   
        PROFILE("StormCloudMixin:OnUpdate")
        SharedUpdate(self)
    end
    
end

