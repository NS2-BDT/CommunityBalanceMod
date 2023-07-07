

function Alien:GetCooldownFraction(techId)

    for _, techIdCD in ipairs(GetTeamTechIdCooldowns(self:GetTeamNumber())) do
    
        if techIdCD.TechId == techId then
            
            local timePassed = Shared.GetTime() - techIdCD.StartTime
            return 1 - math.min(1, timePassed / techIdCD.CooldownDuration)

        end
    
    end
    
    return 0

end
