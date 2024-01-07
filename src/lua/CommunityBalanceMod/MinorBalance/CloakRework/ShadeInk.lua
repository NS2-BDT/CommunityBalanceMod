if Server then
    function ShadeInk:Perform()
        for _, target in ipairs(GetEntitiesWithMixinForTeamWithinRange("Detectable", self:GetTeamNumber(), self:GetOrigin(), ShadeInk.kShadeInkDisorientRadius)) do
            target:SetDetected(false)
        end
        
        for _, target in ipairs(GetEntitiesWithMixinForTeamWithinRange("Cloakable", self:GetTeamNumber(), self:GetOrigin(), ShadeInk.kShadeInkDisorientRadius)) do
            target:InkCloak()
        end
    end
end

function ShadeInk:GetRepeatCinematic()
    
    --if GetLocalPlayerSeesThrough() then
        return ShadeInk.kShadeInkAlienEffect
    --end
    
    --return ShadeInk.kShadeInkMarineEffect
end