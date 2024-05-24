--=============================================================================
--
-- lua\Weapons\Alien\PlasmaT3.lua
--
-- Created by Charlie Cleveland (charlie@unknownworlds.com)
-- Copyright (c) 2011, Unknown Worlds Entertainment, Inc.
--
-- Plasma projectile
--
--=============================================================================

Script.Load("lua/ModularExos/ExoWeapons/PierceProjectile.lua")
Script.Load("lua/Weapons/Projectile.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/ModularExos/ExoWeapons/DotMarker.lua")
Script.Load("lua/ModularExos/Balance.lua")
Script.Load("lua/ModularExos/MarineWeaponEffects.lua")

PrecacheAsset("models/marine/exosuit/plasma_effect.surface_shader")
PrecacheAsset("cinematics/modularexo/plasma_impact.cinematic")

class 'PlasmaT3' (PierceProjectile)

PlasmaT3.kMapName            = "PlasmaT3"

PlasmaT3.kModelName            = PrecacheAsset("models/marine/exosuit/plasma.model")
PlasmaT3.kProjectileCinematic  = PrecacheAsset("cinematics/modularexo/plasma_fly_t3.cinematic")

PlasmaT3.kClearOnImpact      = true
PlasmaT3.kClearOnEnemyImpact = false

-- The max amount of time a Plasma can last for
PlasmaT3.kLifetime = kPlasmaT3LifeTime

local networkVars = { }

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

function PlasmaT3:OnCreate()
    
    PierceProjectile.OnCreate(self)
    
	InitMixin(self, DamageMixin)
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)

    if Server then
        self:AddTimedCallback(PlasmaT3.TimeUp, PlasmaT3.kLifetime)
    end

end

function PlasmaT3:GetIsAffectedByWeaponUpgrades()
    return true
end

function PlasmaT3:GetDeathIconIndex()
    return kDeathMessageIcon.PulseGrenade
end

if Server then

    function PlasmaT3:ProcessHit(targetHit, surface, normal, hitPoint, shotDamage, shotDOTDamage, shotDamageRadius, ChargePercent)        
		
		--local hitEntities = GetEntitiesForTeamWithinRange("Alien", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), shotDamageRadius)
		local hitEntities = GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), shotDamageRadius)
		table.removevalue(hitEntities, self)
		table.removevalue(hitEntities, self:GetOwner())
		
		if targetHit and targetHit ~= self:GetOwner() then

            table.removevalue(hitEntities, targetHit)
            self:DoDamage(shotDamage, targetHit, self:GetOrigin(), GetNormalizedVector(targetHit:GetOrigin() - self:GetOrigin()), "none")

            if targetHit.SetElectrified then
                targetHit:SetElectrified(kElectrifiedDuration)
				
				local dotMarker = CreateEntity(DotMarker.kMapName, self:GetOrigin() + normal * 0.2, self:GetTeamNumber())
				
				targetHit.id = targetHit:GetId()
				
				dotMarker:SetOwner(self:GetOwner())
				dotMarker:SetDamageType(kPlasmaDamageType)        
				dotMarker:SetLifeTime(kPlasmaDOTDuration)
				dotMarker:SetDamage(shotDOTDamage)
				dotMarker:SetDamageIntervall(kPlasmaDOTInterval)
				dotMarker:SetDotMarkerType(DotMarker.kType.SingleTarget)
				dotMarker:SetAttachToTarget(targetHit, targetHit:GetOrigin())		
				dotMarker:SetDeathIconIndex(kDeathMessageIcon.BileBomb)
				dotMarker:SetRadius(0)
            end
        end
		
		for _, entity in ipairs(hitEntities) do

			local targetOrigin = GetTargetOrigin(entity)
			self:DoDamage(shotDamage, entity, self:GetOrigin(), GetNormalizedVector(entity:GetOrigin() - self:GetOrigin()), "none")

			if entity.SetElectrified then
				entity:SetElectrified(kElectrifiedDuration)
				
				local dotMarker = CreateEntity(DotMarker.kMapName, self:GetOrigin() + normal * 0.2, self:GetTeamNumber())
			
				entity.id = entity:GetId()
				
				dotMarker:SetOwner(self:GetOwner())
				dotMarker:SetDamageType(kPlasmaDamageType)        
				dotMarker:SetLifeTime(kPlasmaDOTDuration)
				dotMarker:SetDamage(shotDOTDamage)
				dotMarker:SetDamageIntervall(kPlasmaDOTInterval)
				dotMarker:SetDotMarkerType(DotMarker.kType.SingleTarget)
				dotMarker:SetAttachToTarget(entity, entity:GetOrigin())		
				dotMarker:SetDeathIconIndex(kDeathMessageIcon.BileBomb)
				dotMarker:SetRadius(0)
				
			end
		end
		
		local params = { surface = surface }
		if not targetHit then
			params[kEffectHostCoords] = Coords.GetLookIn( self:GetOrigin(), self:GetCoords().zAxis)
		end

		self:TriggerEffects("pulse_grenade_explode", params)

        CreateExplosionDecals(self)
		DestroyEntity(self)
		
    end
    
    function PlasmaT3:TimeUp(currentRate)
	
		self:TriggerEffects("plasma_impact", params)
        DestroyEntity(self)
        return false
    
    end

end

function PlasmaT3:GetNotifiyTarget()
    return false
end

Shared.LinkClassToMap("PlasmaT3", PlasmaT3.kMapName, networkVars)