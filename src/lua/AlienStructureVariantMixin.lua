-- ======= Copyright (c) 2003-2018, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\AlienStructureVariantMixin.lua
-- 
-- ==============================================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/NS2Utility.lua")


AlienStructureVariantMixin = CreateMixin(AlienStructureVariantMixin)
AlienStructureVariantMixin.type = "AlienStructureVariant"

AlienStructureVariantMixin.expectedMixins =
{
    Team = "For making friendly players visible"
}

AlienStructureVariantMixin.networkVars =
{
    structureVariant = "enum kAlienStructureVariants",
}

AlienStructureVariantMixin.optionalCallbacks =
{
    SetupStructureEffects = "Special per-structure callback to handle dealing with effects specific per type",
    UpdateStructureEffects = "Same as setup but for regular updates"
}


function AlienStructureVariantMixin:__initmixin()
    self.structureVariant = kDefaultAlienStructureVariant

    if Client then
        self.dirtySkinState = true
        self.clientStructureVariant = nil
        self:AddFieldWatcher( "structureVariant", self.OnStructureSkinChanged )
    end

    if Server then
        local gameInfo = GetGameInfoEntity()
        if gameInfo then
            local teamSkin = gameInfo:GetTeamCosmeticSlot( self:GetTeamNumber(), kTeamCosmeticSlot1 )
            if teamSkin ~= self.structureVariant then
                self.structureVariant = teamSkin
            end
        end
    end

    if self.SetupStructureEffects then
        self:SetupStructureEffects()
    end

end

local function UpdateStructureSkin(self)
    local gameInfo = GetGameInfoEntity()
    if gameInfo then
        local teamSkin = gameInfo:GetTeamCosmeticSlot( self:GetTeamNumber(), kTeamCosmeticSlot1 )
        if teamSkin ~= self.structureVariant then
            self.structureVariant = teamSkin
        end
    end

    if self.UpdateStructureEffects then
        self:UpdateStructureEffects()
    end
end

function AlienStructureVariantMixin:ForceStructureSkinsUpdate()
    UpdateStructureSkin(self)
end

function AlienStructureVariantMixin:OnUpdate(deltaTime)
    if not Shared.GetIsRunningPrediction() then
        UpdateStructureSkin(self)
    end
end

if Client then

    function AlienStructureVariantMixin:OnModelChanged(hasModel)
        if hasModel then
            self:OnStructureSkinChanged()
        end
    end

    function AlienStructureVariantMixin:OnStructureSkinChanged()
        self.dirtySkinState = true
        return true
    end
    
    function AlienStructureVariantMixin:OnUpdateRender()
		
		-- CBM: Update skin unless it's a biomass five hive.
        if self.dirtySkinState and self:GetIsAlive() and not self.biomassFiveHiveMaterial then
            local model = self:GetRenderModel()
            if model and model:GetReadyForOverrideMaterials() then
                local className = self:GetClassName()
				
                if self.structureVariant == kDefaultAlienStructureVariant then
                    model:ClearOverrideMaterials()
                else
                    local material = GetPrecachedCosmeticMaterial( className, self.structureVariant )
                    local materialIndex = 0
                    model:SetOverrideMaterial( materialIndex, material )
                end

                self:SetHighlightNeedsUpdate()
            else
                return false --skip to next frame
            end

            if self.OnStructureSkinChangedExtras then
                self:OnStructureSkinChangedExtras(self.structureVariant)
            end

            self.dirtySkinState = false
            self.clientStructureVariant = self.structureVariant
        end

    end

end --End-Client
