if Server then
    function CragUmbra:Perform()
        for _, target in ipairs(GetEntitiesWithMixinForTeamWithinRange("Umbra", self:GetTeamNumber(), self:GetOrigin(), CragUmbra.kRadius)) do
            local resilienceScalar = GetResilienceScalar(target, false)
            target:SetHasUmbra(true, kUmbraRetainTime * resilienceScalar)
        end     
    end
end