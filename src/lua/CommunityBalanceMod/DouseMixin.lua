-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\DouseMixin.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

--
-- DouseMixin drags out parts of an Douse cloud to protect an alien for additional DouseMixin.kDouseDragTime seconds.
--
DouseMixin = CreateMixin( DouseMixin )
DouseMixin.type = "Douse"

local DouseMixinkSegment1Cinematic = PrecacheAsset("cinematics/alien/crag/umbraTrail1.cinematic")
local DouseMixinkSegment2Cinematic = PrecacheAsset("cinematics/alien/crag/umbraTrail2.cinematic")
local DouseMixinkViewModelCinematic = PrecacheAsset("cinematics/alien/crag/umbra_1p.cinematic")

local kMaterialName = PrecacheAsset("cinematics/vfx_materials/umbra_red.material")
local kViewMaterialName = PrecacheAsset("cinematics/vfx_materials/umbra_red_view.material")

local precached1 = PrecacheAsset("cinematics/vfx_materials/umbra_red.surface_shader")
local precached2 = PrecacheAsset("cinematics/vfx_materials/umbra_view.surface_shader")
local precached3 = PrecacheAsset("cinematics/vfx_materials/2em_1mask_1norm_scroll_refract_tint.surface_shader")

local kEffectInterval = 0.1
local kStaticEffectInterval = .34

DouseMixin.expectedMixins =
{
}

DouseMixin.networkVars =
{
    -- as an override for the gameeffect mask
    dragsDouse = "boolean",
}

local kDouseModifier = {}
kDouseModifier["Shotgun"] = kDouseShotgunModifier
kDouseModifier["Rifle"] = kDouseBulletModifier
kDouseModifier["HeavyMachineGun"] = kDouseBulletModifier
kDouseModifier["Pistol"] = kDouseBulletModifier
kDouseModifier["Sentry"] = kDouseBulletModifier
kDouseModifier["Minigun"] = kDouseMinigunModifier
kDouseModifier["Railgun"] = kDouseRailgunModifier
kDouseModifier["Grenade"] = kDouseGrenadeModifier
kDouseModifier["ClusterGrenade"] = kDouseGrenadeModifier
kDouseModifier["PulseGrenade"] = kDouseGrenadeModifier

function DouseMixin:__initmixin()
    
    PROFILE("DouseMixin:__initmixin")
    
    self.dragsDouse = false
    DouseBulletCount = 0
    self.timeDouseExpires = 0
    
    if Client then
        self.timeLastDouseEffect = 0
        self.DouseIntensity = 0
    end
    
end

function DouseMixin:GetHasDouse()
    return self.dragsDouse
end

if Server then

    function DouseMixin:SetHasDouse(state, DouseTime, force)
    
        if HasMixin(self, "Live") and not self:GetIsAlive() then
            return
        end
        
        if HasMixin(self, "Fire") and self:GetIsOnFire() then
            self:SetGameEffectMask(kGameEffect.OnFire, false)
        end
    
        self.dragsDouse = state
        
        if not DouseTime then
            DouseTime = 0
        end
        
        if self.dragsDouse then        
            self.timeDouseExpires = Shared.GetTime() + DouseTime
        end
        
    end
    
end


local function SharedUpdate(self, deltaTime)

    if Server then
    
        self.dragsDouse = self.timeDouseExpires > Shared.GetTime()

    elseif Client then

        if self:GetHasDouse() then
        
            local effectInterval = kStaticEffectInterval
            if self.lastOrigin ~= self:GetOrigin() then
                effectInterval = kEffectInterval
                self.lastOrigin = self:GetOrigin()
            end

            if self.timeLastDouseEffect + effectInterval < Shared.GetTime() then
            
                local coords = self:GetCoords()
                
                if HasMixin(self, "Target") then
                    coords.origin = self:GetEngagementPoint()
                end
            
                self:TriggerEffects("Douse_drag", { effecthostcoords = coords } )
                self.timeLastDouseEffect = Shared.GetTime()
            end

            self.DouseIntensity = 1
            
        else
        
            self.DouseIntensity = 0
        
        end
    
    end
    
end

function DouseMixin:OnUpdate(deltaTime)
    PROFILE("DouseMixin:OnUpdate")
    SharedUpdate(self, deltaTime)
end

function DouseMixin:OnProcessSpectate(deltaTime)
    SharedUpdate(self, deltaTime)
end

function DouseMixin:OnProcessMove(input)
    SharedUpdate(self, input.time)
end

function DouseMixin:OnUpdateRender()

    local model = self:GetRenderModel()

    local localPlayer = Client.GetLocalPlayer()
    local intensityMod = HasMixin(self, "Cloakable") and self:GetIsCloaked() and GetAreEnemies(self, localPlayer) and 0 or 1
    
    if model then
    
        if not self.DouseMaterial then        
            self.DouseMaterial = AddMaterial(model, kMaterialName)  
        end
        
        self.DouseMaterial:SetParameter("intensity", self.DouseIntensity * intensityMod)
    
    end
    
    local viewModel = self.GetViewModelEntity and self:GetViewModelEntity() and self:GetViewModelEntity():GetRenderModel()
    if viewModel then
    
        if not self.DouseViewMaterial then        
            self.DouseViewMaterial = AddMaterial(viewModel, kViewMaterialName)        
        end
        
        self.DouseViewMaterial:SetParameter("intensity",  self.DouseIntensity * intensityMod)
    
    end

end

function DouseMixin:ModifyDamageTaken(damageTable, attacker, doer, damageType)

    if self:GetHasDouse() then
    
        local modifier = 1
        if not self:isa("Player") and doer then        
            modifier = kDouseModifier[doer:GetClassName()] or 1        
        end
    
        damageTable.damage = damageTable.damage * modifier
        
    end
    

end

