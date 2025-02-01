--=============================================================================
--
-- lua\Weapons\Alien\PlasmaT1.lua
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

class 'PlasmaT1' (PierceProjectile)

local kPlasmaT1MapName            = "PlasmaT1"

local kPlasmaT1ModelName            = PrecacheAsset("models/marine/exosuit/plasma.model")
local kPlasmaT1ProjectileCinematic  = PrecacheAsset("cinematics/modularexo/plasma_fly_t1.cinematic")

local kPlasmaT1ClearOnImpact      = true
local kPlasmaT1ClearOnEnemyImpact = false

-- The max amount of time a Plasma can last for
local kPlasmaT1Lifetime = kPlasmaT1LifeTime

local networkVars = { }

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

function PlasmaT1:OnCreate()
    
    PierceProjectile.OnCreate(self)
    
	InitMixin(self, DamageMixin)
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)

    if Server then
        self:AddTimedCallback(PlasmaT1.TimeUp, kPlasmaT1Lifetime)
    end

end

function PlasmaT1:GetIsAffectedByWeaponUpgrades()
    return true
end

function PlasmaT1:GetDeathIconIndex()
    return kDeathMessageIcon.PulseGrenade
end

if Server then

    function PlasmaT1:ProcessHit(targetHit, surface, normal, hitPoint, shotDamage, shotDOTDamage, shotDamageRadius, ChargePercent)        
		
		--local hitEntities = GetEntitiesForTeamWithinRange("Alien", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), shotDamageRadius)
		local hitEntities = GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), shotDamageRadius)
		table.removevalue(hitEntities, self)
		table.removevalue(hitEntities, self:GetOwner())
		
		if targetHit and targetHit ~= self:GetOwner() then

            table.removevalue(hitEntities, targetHit)
            self:DoDamage(shotDamage, targetHit, self:GetOrigin(), GetNormalizedVector(targetHit:GetOrigin() - self:GetOrigin()), "none")

			if targetHit.SetElectrified then
				targetHit:SetElectrified(kElectrifiedDuration)
			end
        end
		
		for _, entity in ipairs(hitEntities) do

			local targetOrigin = GetTargetOrigin(entity)
			self:DoDamage(shotDamage, entity, self:GetOrigin(), GetNormalizedVector(entity:GetOrigin() - self:GetOrigin()), "none")
			
			if entity.SetElectrified then
				entity:SetElectrified(kElectrifiedDuration)
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
    
    function PlasmaT1:TimeUp(currentRate)
	
		self:TriggerEffects("plasma_impact", params)
        DestroyEntity(self)
        return false
    
    end

end

function PlasmaT1:GetNotifiyTarget()
    return false
end

Shared.LinkClassToMap("PlasmaT1", kPlasmaT1MapName, networkVars)