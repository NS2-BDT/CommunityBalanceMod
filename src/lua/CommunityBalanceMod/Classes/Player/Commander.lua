
gTeamTechIdCooldowns = {}
function GetTeamTechIdCooldowns(teamNumber)

    if not gTeamTechIdCooldowns[teamNumber] then        
        gTeamTechIdCooldowns[teamNumber] = {}        
    end
    
    return gTeamTechIdCooldowns[teamNumber]

end


-- Saves Cooldowns in a non local gTeamTechIdCooldowns too
oldCommanderSetTechCooldown = Commander.SetTechCooldown
function Commander:SetTechCooldown(techId, cooldownDuration, startTime)
    oldCommanderSetTechCooldown(self, techId, cooldownDuration, startTime)


    if techId == kTechId.None or not techId then
        return
    end    

    local reusedEntry = false
    
    for _, techIdCD in ipairs(GetTeamTechIdCooldowns(self:GetTeamNumber())) do
    
        if techIdCD.TechId == techId then
        
            techIdCD.StartTime = startTime
            techIdCD.CooldownDuration = cooldownDuration
            reusedEntry = true
            break
        end
    end
    
    if not reusedEntry then    
        table.insert( GetTeamTechIdCooldowns(self:GetTeamNumber()), { StartTime = startTime, TechId = techId, CooldownDuration = cooldownDuration } )    
    end
    
end
