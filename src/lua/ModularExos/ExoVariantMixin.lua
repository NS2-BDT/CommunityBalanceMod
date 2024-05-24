if Client then
    
    PrecacheCosmeticMaterials("ClawMinigun", kExoVariantsData)
    PrecacheCosmeticMaterials("ClawRailgun", kExoVariantsData)
    
    local exoVariantNames = {
        mm = "Minigun",
        rr = "Railgun",
        cm = "ClawMinigun",
        cr = "ClawRailgun",
    }
    function ExoVariantMixin:GetWeaponLoadoutClass()
        
        if self:isa("Exosuit") or self:isa("ReadyRoomExo") then
            -- exosuit_mm.model
            local modelName = self:GetModelName()
            -- exosuit_mm.model => mm.model => mm
            local modelNamePart = string.lower(string.sub(string.sub(modelName, -8), 1, 2))
            return exoVariantNames[modelNamePart]
        else
            local wep = self:GetActiveWeapon()
            if wep then
                local className = wep:GetLeftSlotWeapon():GetClassName()
                
				if className == "ExoShield" then
                    className = "Claw"
                end
				
				if className == "PlasmaLauncher" then
					className = "Railgun"
				end
				
                if className == "Claw" then
                    local weaponHolder = self:GetWeapon(ExoWeaponHolder.kMapName)
                    if weaponHolder:GetRightSlotWeapon():isa("Minigun") then
                        className = className .. "Minigun"
                    else
                        className = className .. "Railgun"
                    end
                end
                return className
            end
            return false
        end
    end
    
    function ExoVariantMixin:OnUpdateRender()
        PROFILE("ExoVariantMixin:OnUpdateRender")
        
        if self.dirtySkinState then
            
            local weaponClass = self:GetWeaponLoadoutClass()
            if not weaponClass then
                Log("ERROR: Exo with invalid weapon class, skin update failure")
                self.dirtySkinState = false
                return false
            end
            --Print(weaponClass)
            
            --Handle world model
            local worldModel = self:GetRenderModel()
            if worldModel and worldModel:GetReadyForOverrideMaterials() then
                
                if self.exoVariant ~= kDefaultExoVariant then
                    local worldMats = GetPrecachedCosmeticMaterial(weaponClass, self.exoVariant)
                    assert(worldMats and type(worldMats) == "table")
                    
                    for i = 1, #worldMats do
                        local worldMaterial = worldMats[i].mat
                        local worldMatIndex = worldMats[i].idx
                        assert(worldMaterial)
                        assert(worldMatIndex)
                        worldModel:SetOverrideMaterial(worldMatIndex, worldMaterial)
                    end
                
                else
                    worldModel:ClearOverrideMaterials()
                end
                
                self:SetHighlightNeedsUpdate()
            else
                return false --delay a frame
            end
            
            --only try to update view models for players, not Exosuits
            if self:isa("Exo") and self:GetIsLocalPlayer() then
                
                local viewModelEnt = self:GetViewModelEntity()
                
                if viewModelEnt then
                    
                    local viewModel = viewModelEnt:GetRenderModel()
                    if viewModel and viewModel:GetReadyForOverrideMaterials() then
                        
                        if self.exoVariant ~= kDefaultExoVariant then
                            local viewMats = GetPrecachedCosmeticMaterial(weaponClass, self.exoVariant, true)
                            assert(viewMats and type(viewMats) == "table")
                            if weaponClass == "Minigun" then
                                assert(#viewMats == 1)
                                viewModel:SetOverrideMaterial(0, viewMats[1])
                            elseif weaponClass == "Railgun" then
                                assert(#viewMats == 2)
                                viewModel:SetOverrideMaterial(0, viewMats[1])
                                viewModel:SetOverrideMaterial(1, viewMats[2])
                            elseif weaponClass == "ClawRailgun" then
                                assert(#viewMats == 3)
                                viewModel:SetOverrideMaterial(0, viewMats[1])
                                viewModel:SetOverrideMaterial(1, viewMats[2])
                                viewModel:SetOverrideMaterial(2, viewMats[3])
                            elseif  weaponClass == "ClawMinigun" then
                                assert(#viewMats == 3)
                                viewModel:SetOverrideMaterial(0, viewMats[1])
                                viewModel:SetOverrideMaterial(1, viewMats[2])
                                viewModel:SetOverrideMaterial(9, viewMats[3])
                            end
                        else
                            viewModel:ClearOverrideMaterials()
                        end
                    else
                        return false
                    end
                    
                    viewModelEnt:SetHighlightNeedsUpdate()
                end
            
            end
            
            self.dirtySkinState = false
            self.clientExoVariant = self.exoVariant
        end
    
    end

end

-- viewModel:LogAllMaterials()
-- Claw Minigun model:
--    0 - models/marine/exosuit/claw_view.material
--    1 - models/marine/exosuit/minigun_view.material
--    2 - models/marine/exosuit/exosuit_view.material
--    3 - models/marine/exosuit/exosuit_view_screen.material
--    4 - models/marine/exosuit/exosuit_view_panel_claw2.material
--    5 - models/marine/exosuit/exosuit_view_panel_claw1.material
--    6 - models/marine/exosuit/exosuit_view_panel_mini1.material
--    7 - models/marine/exosuit/exosuit_view_panel_mini2.material
--    8 - models/marine/exosuit/exosuit_view_panel_armor.material
--    9 - models/marine/exosuit/forearm.material