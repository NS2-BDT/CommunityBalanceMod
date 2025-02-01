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

Script.Load("lua/Weapons/Projectile.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/Mixins/ModelMixin.lua")

Script.Load("lua/CommunityBalanceMod/Weapons/DotMarker.lua")
Script.Load("lua/CommunityBalanceMod/MarineWeaponEffects.lua")
Script.Load("lua/CommunityBalanceMod/Weapons/PierceProjectile.lua")

PrecacheAsset("models/marine/exosuit/plasma_effect.surface_shader")
PrecacheAsset("cinematics/modularexo/plasma_impact_small.cinematic")

class 'PlasmaT3' (PierceProjectile)

PlasmaT3.kMapName            = "PlasmaT3"

PlasmaT3.kModelName            = PrecacheAsset("models/marine/exosuit/plasma.model")
PlasmaT3.kProjectileCinematic  = PrecacheAsset("cinematics/modularexo/plasma_fly_t3.cinematic")

PlasmaT3.kClearOnImpact      = true
PlasmaT3.kClearOnEnemyImpact = false

-- The max amount of time a Plasma can last for
local kPlasmaT3Lifetime = kPlasmaT3LifeTime

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
        self:AddTimedCallback(PlasmaT3.TimeUp, kPlasmaT3Lifetime)
    end

end

function PlasmaT3:GetIsAffectedByWeaponUpgrades()
    return true
end

function PlasmaT3:GetDeathIconIndex()
    return kDeathMessageIcon.EMPBlast
end

function PlasmaT3:GetDamageType()
    return kPlasmaDamageType
end

if Server then

    local function NoFalloff(distanceFraction)
        return 0 
    end

    function PlasmaT3:ProcessHit(targetHit, surface, normal, hitPoint, shotDamage, shotDOTDamage, shotDamageRadius, ChargePercent)        
		--local hitEntities = GetEntitiesForTeamWithinRange("Alien", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), shotDamageRadius)

		--Log('Shot Hit')
		--Log('%s',self:GetOrigin())
		--Log('%s',self:GetOrigin() + normal * 0.2)

		local dotMarker = CreateEntity(DotMarker.kMapName, self:GetOrigin(), self:GetTeamNumber())
		dotMarker:SetDamageType(kPlasmaDamageType)        
        dotMarker:SetLifeTime(kPlasmaDOTDuration)
        dotMarker:SetDamage(shotDOTDamage)
        dotMarker:SetRadius(kPlasmaBombDamageRadius)
        dotMarker:SetDamageIntervall(kPlasmaDOTInterval)
        dotMarker:SetDotMarkerType(DotMarker.kType.StaticNoLOS)
        dotMarker:SetDeathIconIndex(kDeathMessageIcon.EMPBlast)
        dotMarker:SetOwner(self:GetOwner())
		dotMarker:SetDebuff('pulse')
		dotMarker:SetFallOffFunc(NoFalloff)
		
		local hitEntities = GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), kPlasmaBombDamageRadius)
		table.removevalue(hitEntities, self)
		table.removevalue(hitEntities, self:GetOwner())
		
		--[[if targetHit and targetHit ~= self:GetOwner() then
		
			table.removevalue(hitEntities, targetHit)
			self:DoDamage(shotDamage, targetHit, self:GetOrigin(), GetNormalizedVector(targetHit:GetOrigin() - self:GetOrigin()), "none")
			
			if targetHit.SetElectrified then
				targetHit:SetElectrified(kElectrifiedDuration)
			end
		end]]
		
		for _, entity in ipairs(hitEntities) do

			self:DoDamage(shotDamage, entity, self:GetOrigin(), GetNormalizedVector(entity:GetOrigin() - self:GetOrigin()), "none")

			if entity.SetElectrified then
				entity:SetElectrified(kElectrifiedDuration)		
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