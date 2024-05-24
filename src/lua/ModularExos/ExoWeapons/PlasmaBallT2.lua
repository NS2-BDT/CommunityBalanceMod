--=============================================================================
--
-- lua\Weapons\Alien\PlasmaT2.lua
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

class 'PlasmaT2' (PierceProjectile)

PlasmaT2.kMapName            = "PlasmaT2"

PlasmaT2.kModelName            = PrecacheAsset("models/marine/exosuit/plasma.model")
PlasmaT2.kProjectileCinematic  = PrecacheAsset("cinematics/modularexo/plasma_fly_t2.cinematic")

PlasmaT2.kClearOnImpact      = true
PlasmaT2.kClearOnEnemyImpact = false

-- The max amount of time a Plasma can last for
PlasmaT2.kLifetime = kPlasmaT2LifeTime

local networkVars = { }

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

function PlasmaT2:OnCreate()
    
    PierceProjectile.OnCreate(self)
    
	InitMixin(self, DamageMixin)
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)

    if Server then
        self:AddTimedCallback(PlasmaT2.TimeUp, PlasmaT2.kLifetime)
    end

end

function PlasmaT2:GetIsAffectedByWeaponUpgrades()
    return true
end

function PlasmaT2:GetDeathIconIndex()
    return kDeathMessageIcon.PulseGrenade
end

if Server then

    function PlasmaT2:ProcessHit(targetHit, surface, normal, hitPoint, shotDamage, shotDOTDamage, shotDamageRadius, ChargePercent)        

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
		
		self:TriggerEffects("plasma_impact", params)

        CreateExplosionDecals(self)
		DestroyEntity(self)
		
    end
    
    function PlasmaT2:TimeUp(currentRate)
	
		self:TriggerEffects("plasma_impact", params)
        DestroyEntity(self)
        return false
    
    end

end

function PlasmaT2:GetNotifiyTarget()
    return false
end

Shared.LinkClassToMap("PlasmaT2", PlasmaT2.kMapName, networkVars)