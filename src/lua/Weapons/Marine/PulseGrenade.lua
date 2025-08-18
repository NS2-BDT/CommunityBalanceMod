-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Marine\PulseGrenade.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Projectile.lua")

class 'PulseGrenade' (PredictedProjectile)

PrecacheAsset("cinematics/vfx_materials/elec_trails.surface_shader")

PulseGrenade.kMapName = "pulsegrenadeprojectile"
PulseGrenade.kModelName = PrecacheAsset("models/marine/grenades/gr_pulse_world.model")

PulseGrenade.kDetonateRadius = 0.17
PulseGrenade.kClearOnImpact = true
PulseGrenade.kClearOnEnemyImpact = true

local networkVars = { }

local kLifeTime = 1.2

local kGrenadeCameraShakeDistance = 15
local kGrenadeMinShakeIntensity = 0.01
local kGrenadeMaxShakeIntensity = 0.14

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

function PulseGrenade:OnCreate()

    PredictedProjectile.OnCreate(self)

    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, DamageMixin)

    if Server then

        self:AddTimedCallback(PulseGrenade.TimedDetonateCallback, kLifeTime)

    end

end

function PulseGrenade:ProcessHit(targetHit)
    if Server then
        self:Detonate(targetHit)
    end

    return true
end


function PulseGrenade:ProcessNearMiss( targetHit, endPoint )
    if targetHit and GetAreEnemies(self, targetHit) then
        if Server then
            self:Detonate( targetHit )
        end

        return true
    end
end

local function EnergyDamage(hitEntities, origin, radius, damage)

    for _, entity in ipairs(hitEntities) do

        if entity.GetEnergy and entity.SetEnergy then

            local targetPoint = HasMixin(entity, "Target") and entity:GetEngagementPoint() or entity:GetOrigin()
            local energyToDrain = damage *  (1 - Clamp( (targetPoint - origin):GetLength() / radius, 0, 1))
            entity:SetEnergy(entity:GetEnergy() - energyToDrain)

        end

        if entity.SetElectrified then
            entity:SetElectrified(kElectrifiedDuration)
        end

    end

end

if Server then

    function PulseGrenade:TimedDetonateCallback()
        self:Detonate()
    end
	
	local function NoFalloff(distanceFraction)
        return 0 
    end

    function PulseGrenade:Detonate(targetHit)

        local hitEntitiesEnergy = GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), kPulseGrenadeEnergyDamageRadius)
        local hitEntitiesDamage = GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), kPulseGrenadeDamageRadius)
		local hitEntitiesDamageDoT = GetEntitiesWithMixinForTeamWithinRange("Live", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kPulseGrenadeEnergyDamageRadius)
        table.removevalue(hitEntitiesEnergy, self)
        table.removevalue(hitEntitiesDamage, self)
		--table.removevalue(hitEntitiesDamageDoT, self)
		
		local dotMarker = CreateEntity(DotMarker.kMapName, self:GetOrigin(), self:GetTeamNumber())
		dotMarker:SetDamageType(kPulseDamageType)        
        dotMarker:SetLifeTime(kPulseDOTDuration)
        dotMarker:SetDamage(kPulseDOTDamage)
		dotMarker:SetRadius(kPulseGrenadeEnergyDamageRadius)
        dotMarker:SetDamageIntervall(kPulseDOTInterval)
        dotMarker:SetDotMarkerType(DotMarker.kType.Static)
        dotMarker:SetDeathIconIndex(kDeathMessageIcon.PulseGrenade)
        dotMarker:SetOwner(self:GetOwner())
		dotMarker:SetDebuff('pulse')
		dotMarker:SetFallOffFunc(NoFalloff)
		--dotMarker:SetTargetListHitEntities(hitEntitiesDamageDoT)

        if targetHit then

            table.removevalue(hitEntitiesEnergy, targetHit)
            table.removevalue(hitEntitiesDamage, targetHit)
			
            self:DoDamage(kPulseGrenadeDamage, targetHit, targetHit:GetOrigin(), GetNormalizedVector(targetHit:GetOrigin() - self:GetOrigin()), "none")

            if targetHit.SetElectrified then
                targetHit:SetElectrified(kElectrifiedDuration)
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
                entity:SetElectrified(kElectrifiedDuration)
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

    function PulseGrenade:OnUpdate(deltaTime)

        PredictedProjectile.OnUpdate(self, deltaTime)

        for _, enemy in ipairs( GetEntitiesForTeamWithinRange("Alien", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), PulseGrenade.kDetonateRadius) ) do
        
            if enemy:GetIsAlive() then
                self:Detonate()
                break
            end
        
        end

    end

end

function PulseGrenade:GetDeathIconIndex()
    return kDeathMessageIcon.PulseGrenade
end

Shared.LinkClassToMap("PulseGrenade", PulseGrenade.kMapName, networkVars)