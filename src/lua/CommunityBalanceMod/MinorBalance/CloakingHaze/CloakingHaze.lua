-- ========= Community Balance Mod ===============================
--
-- 
--
--    Created by:   Twiliteblue, Drey (@drey3982)
--
-- ===============================================================


Script.Load("lua/CommAbilities/CommanderAbility.lua")


class 'CloakingHaze' (CommanderAbility)

CloakingHaze.kMapName = "cloakinghaze"

CloakingHaze.kSplashEffect = PrecacheAsset("cinematics/alien/hallucinationcloud.cinematic")
CloakingHaze.kType = CommanderAbility.kType.Repeat
CloakingHaze.kLifeSpan = 13.1  -- was 4.1
CloakingHaze.kThinkTime = 0.5
CloakingHaze.kRadius = 10

local networkVars = { }

function CloakingHaze:OnInitialized()
    
    if Server then
        -- sound feedback
        self:TriggerEffects("enzyme_cloud")    
    end
    
    CommanderAbility.OnInitialized(self)

end

function CloakingHaze:GetStartCinematic()
    return CloakingHaze.kSplashEffect
end

function CloakingHaze:GetRepeatCinematic()
    return CloakingHaze.kSplashEffect
end

function CloakingHaze:GetType()
    return CloakingHaze.kType
end

function CloakingHaze:GetLifeSpan()
    return CloakingHaze.kLifeSpan
end

function CloakingHaze:GetUpdateTime()
    return CloakingHaze.kThinkTime 
end


if Server then

    function CloakingHaze:Perform()
 
        local teamNumber = self:GetTeamNumber()
        local origin = self:GetOrigin()
        -- only cloak players, drifters and eggs
        local targets = GetEntitiesForTeamWithinXZRange("Player", teamNumber, origin, CloakingHaze.kRadius)
        table.copy(GetEntitiesForTeamWithinXZRange("Drifter", teamNumber, origin, CloakingHaze.kRadius), targets, true)
        table.copy(GetEntitiesForTeamWithinXZRange("Egg", teamNumber, origin, CloakingHaze.kRadius), targets, true)
        
        for _, cloakable in ipairs( targets ) do
            if HasMixin(cloakable, "Detectable")then
                cloakable:SetDetected(false)
            end
            if HasMixin(cloakable, "Cloakable")then
                cloakable:HazeCloak()  -- apply special cloaking status
            end
		end
    end

end

Shared.LinkClassToMap("CloakingHaze", CloakingHaze.kMapName, networkVars)

