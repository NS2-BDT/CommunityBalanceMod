-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\WebableMixin.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

WebableMixin = CreateMixin( WebableMixin )
WebableMixin.type = "Webable"

WebableMixin.optionalCallbacks =
{
    OnWebbed = "Called when entity is being webbed.",
    OnWebbedEnd = "Called when entity leaves webbed state."
}

WebableMixin.networkVars =
{
    webbed = "boolean",
	timeWebbed = "time",
    timeWebEnds = "private time",
	webDuration = "private float (0 to 45 by 0.1)",
}

function WebableMixin:__initmixin()
    
    PROFILE("WebableMixin:__initmixin")
    
    if Server then
        self.webbed = false
        self.timeWebEnds = 0
		self.timeWebbed = 0
		self.webDuration = 0
    end
    
end

function WebableMixin:ModifyMaxSpeed(maxSpeedTable)

    if self.webbed then
    
        local slowDown = kWebSlowVelocityScalar
        
        if self.GetWebSlowdownScalar then
            slowDown = self:GetWebSlowdownScalar() or 1
        end
        
        -- Taper off the slowdown over the amount of time the entity has been webbed.
        local now = Shared.GetTime()
        local timeRemaining = self.timeWebEnds - now
        local timeFraction = Clamp(timeRemaining / kWebbedDuration, 0, 1)
        slowDown = 1 - (1 - slowDown) * timeFraction
    
        maxSpeedTable.maxSpeed = maxSpeedTable.maxSpeed * slowDown
    end

end

function WebableMixin:GetIsWebbed()
    return self.webbed
end

function WebableMixin:GetRemainingWebbedDuration()

    local now = Shared.GetTime()

    if self.webbed and self.timeWebEnds > now then
        return self.timeWebEnds - now
    else
        return 0
    end

end

function WebableMixin:GetWebPercentageRemaining()

    local percentLeft = 0

    if self.webbed and self.webDuration > 0 then
        percentLeft = Clamp( math.abs( (self.timeWebbed + self.webDuration) - Shared.GetTime() ) / self.webDuration, 0.0, 1.0 )
    end

    return percentLeft

end

function WebableMixin:SetWebbed(duration, playEffects)

    local oldTimeWebEnds = self.timeWebEnds or Shared.GetTime()
    local newTimeWebEnds = Shared.GetTime() + duration

    local shouldPlayEffects = ConditionalValue(not playEffects, false, true)

    if shouldPlayEffects and newTimeWebEnds - oldTimeWebEnds > 0.2 then
        self:TriggerEffects("webbed")
    end

    self.timeWebEnds = Shared.GetTime() + duration
	self.timeWebbed = Shared.GetTime()
	self.webDuration = duration
	
    if not self.webbed and self.OnWebbed then
        self:OnWebbed()
    end

    self.webbed = true
    
    if self:isa("Player") then
        
        local slowdown = kWebSlowVelocityScalar
        
        if self.GetWebSlowdownScalar then
            slowdown = self:GetWebSlowdownScalar() or 1
        end
        
        local velocity = self:GetVelocity()
        velocity.x = velocity.x * slowdown
        velocity.z = velocity.z * slowdown
        if velocity.y < 0 then -- Only slow down the fall, not jumping
            velocity.y = math.min(1, velocity.y * slowdown) --?? Examine for falling and not adjust?
        end
        self:SetVelocity(velocity)
        
    end
    
end

local function SharedUpdate(self)

    local wasWebbed = self.webbed
    self.webbed = self.timeWebEnds > Shared.GetTime()
    
    if wasWebbed and not self.webbed and self.OnWebbedEnd then
        self:OnWebbedEnd()
    end
    
end

if Server then

    function WebableMixin:OnUpdate(deltaTime)
        PROFILE("WebableMixin:OnUpdate")
        SharedUpdate(self)
    end
    
end

function WebableMixin:OnProcessMove(input)

    SharedUpdate(self)
    
    for _, web in ipairs(GetEntitiesForTeamWithinRange("Web", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kMaxWebLength * 2)) do
        web:UpdateWebOnProcessMove(self)
    end
    
end

function WebableMixin:OnUpdateAnimationInput(modelMixin)
    modelMixin:SetAnimationInput("webbed", self.webbed)
end

function WebableMixin:OnUpdateRender()

    -- TODO: custom material?

end
