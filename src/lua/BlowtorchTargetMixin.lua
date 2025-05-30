-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\CloakableMixin.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
--    Outlines targets blue when SetBlowtorchTarget() is called for kBlowtorchTargetDuration seconds.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

BlowtorchTargetMixin = CreateMixin( BlowtorchTargetMixin )
BlowtorchTargetMixin.type = "BlowtorchTarget"

--PrecacheAsset("cinematics/vfx_materials/highlightmodel.surface_shader")

local kBlowtorchTargetDuration = 0.3
local kHighlightmodel_Material = PrecacheAsset("cinematics/vfx_materials/highlightmodel.material")

BlowtorchTargetMixin.expectedMixins =
{
    Model = "Required to add to shader mask."
}

function BlowtorchTargetMixin:__initmixin()
    
    PROFILE("BlowtorchTargetMixin:__initmixin")
    
    assert(Client)
    self.isBlowtorchTarget = false
    self.timeBlowtorchTargeted = -1
	self.isWeldTarget = false
	self.isDamageTarget = false
end

function BlowtorchTargetMixin:SetBlowtorchTargetDamage()
    self.timeBlowtorchTargeted = Shared.GetTime()
	self.isDamageTarget = true
end

function BlowtorchTargetMixin:SetBlowtorchTargetWeld()
    self.timeBlowtorchTargeted = Shared.GetTime()
	self.isWeldTarget = true
end

function BlowtorchTargetMixin:OnUpdate(deltaTime)
    PROFILE("BlowtorchTargetMixin:OnUpdate")
    local isTarget = self.timeBlowtorchTargeted + kBlowtorchTargetDuration > Shared.GetTime()
    local model = self:GetRenderModel()
    
    if self.isBlowtorchTarget ~= isTarget and model then
    
        if isTarget and self.isWeldTarget then
            EquipmentOutline_AddModel(model, kEquipmentOutlineColor.TSFBlue)
        elseif isTarget and self.isDamageTarget then
            EquipmentOutline_AddModel(model, kEquipmentOutlineColor.Red)
        else
            EquipmentOutline_RemoveModel(model)
        end
        
        self.isBlowtorchTarget = isTarget
    
    end

end

--[[ disabled since it doesnt look very good and distracts too much
function BlowtorchTargetMixin:OnUpdateRender()

    local model = self:GetRenderModel()

    if model then
    
        local intensity = 1 - Clamp( (Shared.GetTime() - self.timeBlowtorchTargeted) / 0.3, 0, 1 )
        local showMaterial = intensity ~= 0
    
        if not self.BlowtorchHighlightMaterial and showMaterial then
            self.BlowtorchHighlightMaterial = AddMaterial(model, kHighlightmodel_Material)
        elseif not showMaterial and self.BlowtorchHighlightMaterial then
            RemoveMaterial(model, self.BlowtorchHighlightMaterial)
            self.BlowtorchHighlightMaterial = nil
        end

        if self.BlowtorchHighlightMaterial then
            self.BlowtorchHighlightMaterial:SetParameter("intensity", intensity * 0.5)
        end
    
    end

end
--]]
