if Server then
    local kGrenadeMinShakeIntensity = debug.getupvaluex(PulseGrenade.Detonate, "kGrenadeMinShakeIntensity")
    local kGrenadeMaxShakeIntensity = debug.getupvaluex(PulseGrenade.Detonate, "kGrenadeMaxShakeIntensity")
    local kGrenadeCameraShakeDistance = debug.getupvaluex(PulseGrenade.Detonate, "kGrenadeCameraShakeDistance")

    function PulseGrenade:Detonate(targetHit)
        local hitEntitiesEnergy = GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), kPulseGrenadeEnergyDamageRadius)
        local hitEntitiesDamage = GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), kPulseGrenadeDamageRadius)
        table.removevalue(hitEntitiesEnergy, self)
        table.removevalue(hitEntitiesDamage, self)

        if targetHit then
            table.removevalue(hitEntitiesEnergy, targetHit)
            table.removevalue(hitEntitiesDamage, targetHit)
            self:DoDamage(kPulseGrenadeDamage, targetHit, targetHit:GetOrigin(), GetNormalizedVector(targetHit:GetOrigin() - self:GetOrigin()), "none")

            if targetHit.SetElectrified then
                -- LegacyBalanceMod: Scale electrified duration based on Resilience
                local electrifiedScalar = GetResilienceScalar(targetHit)
                if electrifiedScalar > 0 then
                    targetHit:SetElectrified(kElectrifiedDuration * electrifiedScalar)
                end
            end
        end

        -- Handle damage.
        for _, entity in ipairs(hitEntitiesDamage) do
            local targetOrigin = GetTargetOrigin(entity)
            self:DoDamage(kPulseGrenadeDamage, entity, targetOrigin, GetNormalizedVector(entity:GetOrigin() - self:GetOrigin()), "none")
        end

        -- Handle electrify.
        for _, entity in ipairs(hitEntitiesEnergy) do
            if entity.SetElectrified then
                -- LegacyBalanceMod: Scale electrified duration based on Resilience
                local electrifiedScalar = GetResilienceScalar(entity)
                if electrifiedScalar > 0 then
                    entity:SetElectrified(kElectrifiedDuration * electrifiedScalar)
                end
            end
        end

        local surface = GetSurfaceFromEntity(targetHit)

        local params = { surface = surface }
        if not targetHit then
            params[kEffectHostCoords] = Coords.GetLookIn( self:GetOrigin(), self:GetCoords().zAxis)
        end

        if GetDebugGrenadeDamage() then
            DebugWireSphere( self:GetOrigin(), kPulseGrenadeEnergyDamageRadius, 0.75, 0, 1, 1, 1 )
            DebugWireSphere( self:GetOrigin(), kPulseGrenadeDamageRadius, 0.75, 1, 0, 0, 1 )
        end

        self:TriggerEffects("pulse_grenade_explode", params)
        CreateExplosionDecals(self)
        TriggerCameraShake(self, kGrenadeMinShakeIntensity, kGrenadeMaxShakeIntensity, kGrenadeCameraShakeDistance)

        DestroyEntity(self)
    end
end