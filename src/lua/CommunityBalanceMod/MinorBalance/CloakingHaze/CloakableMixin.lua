
CloakableMixin.networkVars =
{
    -- set server side to true when cloaked fraction is > kFullyCloakedThreshold
    fullyCloaked = "boolean",
    -- so client knows in which direction to update the cloakFraction
    cloakingDesired = "boolean",
    cloakRate = "integer (0 to 3)",
	timeHazeCloakEnd = "time (by 0.01)",
    timeInkCloakEnd = "time (by 0.01)"

}

-- recloak cooldown while hazed, 2.5 vanilla
CloakableMixin.kHazeUncloakDuration  = 5

-- recloak cooldown after an attack
CloakableMixin.kAttackHazeUncloakDuration  = 0.1



local oldinit = CloakableMixin.__initmixin
function CloakableMixin:__initmixin()
    oldinit(self)
    self.cloakRate = 0
    
	self.timeHazeCloakEnd = 0
end

function CloakableMixin:HazeCloak()
    local timeNow = Shared.GetTime()
    self:TriggerCloak()
    self.timeHazeCloakEnd = timeNow + kHazeCloakDuration
end

function CloakableMixin:GetIsHazed()
    local timeNow = Shared.GetTime()
    return self.timeHazeCloakEnd > timeNow
end


-- reduced re-cloaking delay when not actively engaging in combat
-- (bool, time-seconds)
local OldCloakableMixinTriggerUncloak = CloakableMixin.TriggerUncloak
function CloakableMixin:TriggerUncloak(reducedDelay, customDelay)

    local timeNow = Shared.GetTime()
    if self:GetIsHazed() then
        self.timeUncloaked = timeNow + CloakableMixin.kHazeUncloakDuration
    else
        OldCloakableMixinTriggerUncloak(self, reducedDelay, customDelay)
    end
end


local UpdateCloakState = debug.getupvaluex(CloakableMixin.OnUpdate, "UpdateCloakState")

local UpdateDesiredCloakFraction = debug.getupvaluex(UpdateCloakState, "UpdateDesiredCloakFraction")

function NewUpdateDesiredCloakFraction(self, deltaTime)

    local timeNow = Shared.GetTime()

    if self.timeHazeCloakEnd > timeNow and self.cloakRate < 1 then 

        -- add small cooldown maybe?
        -- cloak has to fade in slower
        self.cloakRate = 1
 
        local dealtDamageRecently = self.timeLastDamageDealt and (self.timeLastDamageDealt + CloakableMixin.kAttackHazeUncloakDuration >= timeNow) or false
        self.cloakingDesired = not dealtDamageRecently


    else
        UpdateDesiredCloakFraction(self, deltaTime)
    end

end


debug.setupvaluex(UpdateCloakState, "UpdateDesiredCloakFraction", NewUpdateDesiredCloakFraction)

debug.setupvaluex(CloakableMixin.OnUpdate, "UpdateCloakState", UpdateCloakState)
debug.setupvaluex(CloakableMixin.OnProcessMove, "UpdateCloakState", UpdateCloakState)
debug.setupvaluex(CloakableMixin.OnProcessSpectate, "UpdateCloakState", UpdateCloakState)


