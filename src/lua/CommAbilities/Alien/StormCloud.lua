Script.Load("lua/CommAbilities/CommanderAbility.lua")

class 'StormCloud' (CommanderAbility)

StormCloud.kMapName = "stormcloud"

local kSplashEffect = PrecacheAsset("cinematics/alien/drifter/stormcloud.cinematic")
StormCloud.kType = CommanderAbility.kType.Repeat
StormCloud.kLifeSpan = 10
StormCloud.kThinkTime = 0.2

--local kUnitSpeedBoostDuration = 1

StormCloud.kRadius = 17 --8

local networkVars = { }

function StormCloud:OnInitialized()
    if Server then
        -- sound feedback
        -- self:TriggerEffects("whip_trigger_fury")
        DestroyEntitiesWithinRange("StormCloud", self:GetOrigin(), StormCloud.kRadius, EntityFilterOne(self)) 
    end
    
    CommanderAbility.OnInitialized(self)

end

function StormCloud:GetRepeatCinematic()
    return kSplashEffect
end

function StormCloud:GetType()
    return StormCloud.kType
end

function StormCloud:GetUpdateTime()
    return StormCloud.kThinkTime
end

function StormCloud:GetLifeSpan()
    return StormCloud.kLifeSpan   
end

if Server then

    function StormCloud:Perform()
	
        for _, unit in ipairs(GetEntitiesWithMixinForTeamWithinRange("Storm", self:GetTeamNumber(), self:GetOrigin(), StormCloud.kRadius)) do
            if unit:isa("Player") then
                --unit:SetSpeedBoostDuration(kUnitSpeedBoostDuration)
                unit:TriggerStorm(kStormCloudDuration)
                --unit:TriggerEffects("shockwave_trail")
            end
        end

    end

end

Shared.LinkClassToMap("StormCloud", StormCloud.kMapName, networkVars)

--[[if Client then

    function StormCloud:Perform()
        
        for _, shift in ipairs(GetEntitiesForTeamWithinRange("FortressShift", self:GetTeamNumber(), self:GetOrigin(), kEnergizeRange)) do
            shift:StartStormCloud()
        end

    end

end--]]

