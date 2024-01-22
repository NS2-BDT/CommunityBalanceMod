-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================

local kMaterialName = debug.getupvaluex(UmbraMixin.OnUpdateRender, "kMaterialName") or PrecacheAsset("cinematics/vfx_materials/umbra.material")
local kViewMaterialName = debug.getupvaluex(UmbraMixin.OnUpdateRender, "kViewMaterialName") or PrecacheAsset("cinematics/vfx_materials/umbra_view.material")

function UmbraMixin:OnUpdateRender()

    local model = self:GetRenderModel()

    local localPlayer = Client.GetLocalPlayer()
    --local showUmbra = not HasMixin(self, "Cloakable") or not self:GetIsCloaked() or not GetAreEnemies(self, localPlayer)
    local intensityMod = HasMixin(self, "Cloakable") and self:GetIsCloaked() and GetAreEnemies(self, localPlayer) and 0
                         or 1
    
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