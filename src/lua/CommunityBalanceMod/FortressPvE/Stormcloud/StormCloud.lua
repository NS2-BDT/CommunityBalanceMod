

StormCloud.kRadius = 17 --8



function StormCloud:OnInitialized()
    
    if Server then
        -- sound feedback
        self:TriggerEffects("shade_ink") -- its only the sound
        DestroyEntitiesWithinRange("StormCloud", self:GetOrigin(), 25, EntityFilterOne(self)) 
    end
    
    CommanderAbility.OnInitialized(self)

end

if Server then

    function StormCloud:Perform()
        
        for _, unit in ipairs(GetEntitiesWithMixinForTeamWithinRange("Storm", self:GetTeamNumber(), self:GetOrigin(), StormCloud.kRadius)) do
            if unit:isa("Player") then
                unit:TriggerStorm(kStormCloudDuration)
            end
        end
    end
end
