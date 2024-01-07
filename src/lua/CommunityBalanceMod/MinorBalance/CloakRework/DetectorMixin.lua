
-- Should be smaller than DetectableMixin:kResetDetectionInterval
local kUpdateDetectionInterval = 0.5

local function PerformDetection(self)

    -- Get list of Detectables in range.
    local range = self:GetDetectionRange()
    
    if range > 0 then
    
        local teamNumber = GetEnemyTeamNumber(self:GetTeamNumber())
        local origin = self:GetOrigin()
        local detectables = GetEntitiesWithMixinForTeamWithinXZRange("Detectable", teamNumber, origin, range)
        
        -- Mark them as detected.
        for index, detectable in ipairs(detectables) do
            -- Ink prevents stationary alien from observatory passive detection
            local undetectable = detectable.GetIsInInk and detectable:GetIsInInk()
            if not undetectable then
                detectable:SetDetected(true)
            end
        end
        
    end
    
    return true
    
end

function DetectorMixin:__initmixin()
    
    PROFILE("DetectorMixin:__initmixin")
    
    self.timeSinceLastDetected = 0
    
    if Server then
        self:AddTimedCallback(PerformDetection, kUpdateDetectionInterval)
    end
    
end