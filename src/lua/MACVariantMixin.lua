-- ======= Copyright (c) 2003-2018, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\MACVariantMixin.lua
-- 
-- ==============================================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/NS2Utility.lua")


MACVariantMixin = CreateMixin(MACVariantMixin)
MACVariantMixin.type = "MACVariant"

MACVariantMixin.expectedMixins =
{
    Team = "For making friendly players visible"
}

MACVariantMixin.networkVars =
{
    macVariant = "enum kMarineMacVariants",
}

MACVariantMixin.optionalCallbacks =
{
    SetupSkinEffects = "Special per-structure callback to handle dealing with effects specific per type",
    UpdateSkinEffects = "Same as setup but for regular updates",
    OnMacSkinChangedExtras = "Optional rendering related extras for skin-specific effects",
}


function MACVariantMixin:__initmixin()
    self.macVariant = kDefaultMarineMacVariant

    if Client then
        self.dirtySkinState = true
        self.clientMacVariant = nil
        self:AddFieldWatcher( "macVariant", self.OnMacSkinChanged )
    end

    if Server then
        local gameInfo = GetGameInfoEntity()
        if gameInfo then
            local macSkin = gameInfo:GetTeamCosmeticSlot( self:GetTeamNumber(), kTeamCosmeticSlot3 )
            if macSkin ~= self.macVariant then
                self.macVariant = macSkin
            end
        end
    end

    if self.SetupSkinEffects then
        self:SetupSkinEffects()
    end

end

local function UpdateMacSkin(self)
    local gameInfo = GetGameInfoEntity()
    if gameInfo then
        local macSkin = gameInfo:GetTeamCosmeticSlot( self:GetTeamNumber(), kTeamCosmeticSlot3 )
        if macSkin ~= self.macVariant then
            self.macVariant = macSkin
        end
    end

    if self.UpdateSkinEffects then
        self:UpdateSkinEffects()
    end
end

function MACVariantMixin:ForceSkinUpdate()
    UpdateMacSkin(self)
end

function MACVariantMixin:OnUpdate(deltaTime)
    if not Shared.GetIsRunningPrediction() then
        UpdateMacSkin(self)
    end
end

if Client then

    function MACVariantMixin:OnModelChanged(hasModel)
        if hasModel then
            self:OnMacSkinChanged()
        end
    end

    function MACVariantMixin:OnMacSkinChanged()
        self.dirtySkinState = true
        return true
    end
    
    function MACVariantMixin:OnUpdateRender()

        if self.dirtySkinState and self:GetIsAlive() and not self:isa("BattleMAC") then
            local model = self:GetRenderModel()
            if model and model:GetReadyForOverrideMaterials() then
                local className = self:GetClassName()

                if self.macVariant == kDefaultMarineMacVariant then
                    model:ClearOverrideMaterials()
                else
                    local material = GetPrecachedCosmeticMaterial( className, self.macVariant )
                    local materialIndex = 0
                    model:SetOverrideMaterial( materialIndex, material )
                end

                self:SetHighlightNeedsUpdate()
            else
                return false --skip to next frame
            end

            if self.OnMacSkinChangedExtras then
                self:OnMacSkinChangedExtras(self.macVariant)
            end

            self.dirtySkinState = false
            self.clientMacVariant = self.macVariant
        end

    end

end --End-Client
