

StormCloud.kRadius = 17 --8

if Server then

    function StormCloud:Perform()
        
        for _, unit in ipairs(GetEntitiesWithMixinForTeamWithinRange("Storm", self:GetTeamNumber(), self:GetOrigin(), StormCloud.kRadius)) do
            if unit:isa("Player") then
                unit:TriggerStorm(kStormCloudDuration)
            end
        end
    end
end
