-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\UmbraMixin.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

--
-- UmbraMixin drags out parts of an umbra cloud to protect an alien for additional UmbraMixin.kUmbraDragTime seconds.
--
UmbraMixin = CreateMixin( UmbraMixin )
UmbraMixin.type = "Umbra"

local kSegment1Cinematic = PrecacheAsset("cinematics/alien/crag/umbraTrail1.cinematic")
local kSegment2Cinematic = PrecacheAsset("cinematics/alien/crag/umbraTrail2.cinematic")
local kViewModelCinematic = PrecacheAsset("cinematics/alien/crag/umbra_1p.cinematic")

local kMaterialName = PrecacheAsset("cinematics/vfx_materials/umbra.material")
local kViewMaterialName = PrecacheAsset("cinematics/vfx_materials/umbra_view.material")

local precached1 = PrecacheAsset("cinematics/vfx_materials/umbra.surface_shader")
local precached2 = PrecacheAsset("cinematics/vfx_materials/umbra_view.surface_shader")
local precached3 = PrecacheAsset("cinematics/vfx_materials/2em_1mask_1norm_scroll_refract_tint.surface_shader")

local kEffectInterval = 0.1
local kStaticEffectInterval = .34

UmbraMixin.expectedMixins =
{
}

UmbraMixin.networkVars =
{
    -- as an override for the gameeffect mask
    dragsUmbra = "boolean",
}

local kUmbraModifier = {}
kUmbraModifier["Shotgun"] = kUmbraShotgunModifier
kUmbraModifier["Rifle"] = kUmbraBulletModifier
kUmbraModifier["HeavyMachineGun"] = kUmbraBulletModifier
kUmbraModifier["Pistol"] = kUmbraBulletModifier
kUmbraModifier["Sentry"] = kUmbraBulletModifier
kUmbraModifier["Minigun"] = kUmbraMinigunModifier
kUmbraModifier["Railgun"] = kUmbraRailgunModifier
kUmbraModifier["Grenade"] = kUmbraGrenadeModifier
kUmbraModifier["ClusterGrenade"] = kUmbraGrenadeModifier
kUmbraModifier["PulseGrenade"] = kUmbraGrenadeModifier
kUmbraModifier["Submachinegun"] = kUmbraBulletModifier

function UmbraMixin:__initmixin()
    
    PROFILE("UmbraMixin:__initmixin")
    
    self.dragsUmbra = false
    umbraBulletCount = 0
    self.timeUmbraExpires = 0
    
    if Client then
        self.timeLastUmbraEffect = 0
        self.umbraIntensity = 0
    end
    
end

function UmbraMixin:GetHasUmbra()
    return self.dragsUmbra
end

if Server then

    function UmbraMixin:SetOnFire()
        self.dragsUmbra = false
        self.timeUmbraExpires = 0
    end

    function UmbraMixin:SetHasUmbra(state, umbraTime, force)
    
        if HasMixin(self, "Live") and not self:GetIsAlive() then
            return
        end
        
        if HasMixin(self, "Fire") and self:GetIsOnFire() then
            return
        end
    
        self.dragsUmbra = state
        
        if not umbraTime then
            umbraTime = 0
        end
        
        if self.dragsUmbra then        
            self.timeUmbraExpires = Shared.GetTime() + umbraTime
        end
        
    end
    
end


local function SharedUpdate(self, deltaTime)

    if Server then
    
        self.dragsUmbra = self.timeUmbraExpires > Shared.GetTime()

    elseif Client then

        if self:GetHasUmbra() then
        
            local effectInterval = kStaticEffectInterval
            if self.lastOrigin ~= self:GetOrigin() then
                effectInterval = kEffectInterval
                self.lastOrigin = self:GetOrigin()
            end

            if self.timeLastUmbraEffect + effectInterval < Shared.GetTime() then
            
                local coords = self:GetCoords()
                
                if HasMixin(self, "Target") then
                    coords.origin = self:GetEngagementPoint()
                end
            
                self:TriggerEffects("umbra_drag", { effecthostcoords = coords } )
                self.timeLastUmbraEffect = Shared.GetTime()
            end

            self.umbraIntensity = 1
            
        else
        
            self.umbraIntensity = 0
        
        end
    
    end
    
end

function UmbraMixin:OnUpdate(deltaTime)
    PROFILE("UmbraMixin:OnUpdate")
    SharedUpdate(self, deltaTime)
end

function UmbraMixin:OnProcessSpectate(deltaTime)
    SharedUpdate(self, deltaTime)
end

function UmbraMixin:OnProcessMove(input)
    SharedUpdate(self, input.time)
end

function UmbraMixin:OnUpdateRender()

    local model = self:GetRenderModel()

    local localPlayer = Client.GetLocalPlayer()
    local intensityMod = HasMixin(self, "Cloakable") and self:GetIsCloaked() and GetAreEnemies(self, localPlayer) and 0 or 1
    
    if model then
    
        if not self.umbraMaterial then        
            self.umbraMaterial = AddMaterial(model, kMaterialName)  
        end
        
        self.umbraMaterial:SetParameter("intensity", self.umbraIntensity * intensityMod)
    
    end
    
    local viewModel = self.GetViewModelEntity and self:GetViewModelEntity() and self:GetViewModelEntity():GetRenderModel()
    if viewModel then
    
        if not self.umbraViewMaterial then        
            self.umbraViewMaterial = AddMaterial(viewModel, kViewMaterialName)        
        end
        
        self.umbraViewMaterial:SetParameter("intensity",  self.umbraIntensity * intensityMod)
    
    end

end

function UmbraMixin:ModifyDamageTaken(damageTable, attacker, doer, damageType)

    if self:GetHasUmbra() then
    
        local modifier = 1
        if doer then        
            modifier = kUmbraModifier[doer:GetClassName()] or 1        
        end
    
        damageTable.damage = damageTable.damage * modifier
        
    end
    

end

