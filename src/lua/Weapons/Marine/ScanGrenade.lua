-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Marine\ScanGrenade.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Projectile.lua")
Script.Load("lua/CommAbilities/Marine/ScanMini.lua")

class 'ScanGrenade' (PredictedProjectile)

PrecacheAsset("cinematics/vfx_materials/elec_trails.surface_shader")

ScanGrenade.kMapName = "ScanGrenadeprojectile"
ScanGrenade.kModelName = PrecacheAsset("models/marine/grenades/gr_pulse_world.model")

ScanGrenade.kDetonateRadius = 0.17
ScanGrenade.kClearOnImpact = true
ScanGrenade.kClearOnEnemyImpact = true

local networkVars = { }

local kLifeTime = 1.2

local kGrenadeCameraShakeDistance = 15
local kGrenadeMinShakeIntensity = 0.01
local kGrenadeMaxShakeIntensity = 0.14

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

function ScanGrenade:OnCreate()

    PredictedProjectile.OnCreate(self)

    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, DamageMixin)

    if Server then

        self:AddTimedCallback(ScanGrenade.TimedDetonateCallback, kLifeTime)

    end

end

function ScanGrenade:ProcessHit(targetHit)
    if Server then
        self:Detonate(targetHit)
    end

    return true
end


function ScanGrenade:ProcessNearMiss( targetHit, endPoint )
    if targetHit and GetAreEnemies(self, targetHit) then
        if Server then
            self:Detonate( targetHit )
        end

        return true
    end
end

if Server then

    function ScanGrenade:TimedDetonateCallback()
        self:Detonate()
    end
	
	local function NoFalloff(distanceFraction)
        return 0 
    end

    function ScanGrenade:Detonate(targetHit)

		CreateEntity(ScanMini.kMapName, self:GetOrigin(), self:GetTeamNumber())        

        local surface = GetSurfaceFromEntity(targetHit)

        local params = { surface = surface }
        if not targetHit then
            params[kEffectHostCoords] = Coords.GetLookIn( self:GetOrigin(), self:GetCoords().zAxis)
        end

        --self:TriggerEffects("pulse_grenade_explode", params)
        CreateExplosionDecals(self)
        --TriggerCameraShake(self, kGrenadeMinShakeIntensity, kGrenadeMaxShakeIntensity, kGrenadeCameraShakeDistance)

        DestroyEntity(self)

    end

    function ScanGrenade:OnUpdate(deltaTime)

        PredictedProjectile.OnUpdate(self, deltaTime)

        for _, enemy in ipairs( GetEntitiesForTeamWithinRange("Alien", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), ScanGrenade.kDetonateRadius) ) do
        
            if enemy:GetIsAlive() then
                self:Detonate()
                break
            end
        
        end

    end

end

function ScanGrenade:GetDeathIconIndex()
    return kDeathMessageIcon.PulseGrenade
end

Shared.LinkClassToMap("ScanGrenade", ScanGrenade.kMapName, networkVars)