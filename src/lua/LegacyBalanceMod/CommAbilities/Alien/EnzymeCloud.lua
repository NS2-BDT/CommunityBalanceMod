if Server then
    function EnzymeCloud:Perform()
        -- search for aliens in range and buff their speed by 25%
        for _, alien in ipairs(GetEntitiesForTeamWithinRange("Alien", self:GetTeamNumber(), self:GetOrigin(), EnzymeCloud.kRadius)) do
            local resilienceScalar = GetResilienceBuffScalar(alien, false)
            alien:TriggerEnzyme(EnzymeCloud.kOnPlayerDuration * resilienceScalar)
        end
        
        --[[ Disabled faster speed
        for _, unit in ipairs(GetEntitiesWithMixinForTeamWithinRange("Storm", self:GetTeamNumber(), self:GetOrigin(), EnzymeCloud.kRadius)) do
            unit:SetSpeedBoostDuration(kUnitSpeedBoostDuration)
        end
        --]]
    end
end
