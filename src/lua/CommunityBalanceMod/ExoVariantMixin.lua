-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\ExoVariantMixin.lua
--
-- ==============================================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/NS2Utility.lua")

ExoVariantMixin = CreateMixin(ExoVariantMixin)
ExoVariantMixin.type = "ExoVariant"

ExoVariantMixin.networkVars =
{
    exoVariant = "enum kExoVariants"
}


function ExoVariantMixin:__initmixin()
    
    PROFILE("ExoVariantMixin:__initmixin")
    
    self.exoVariant = kDefaultExoVariant
    if Server then
        self.lastExoVariant = kDefaultExoVariant
    end

    if Client then
        self.dirtySkinState = false
        self.clientExoVariant = nil
    end

end

function ExoVariantMixin:GetExoVariant()
    return self.exoVariant
end

function ExoVariantMixin:SetExoVariant(variant)
    self.exoVariant = variant
end

if Server then

    function ExoVariantMixin:OnClientUpdated(client, isPickup)
        Player.OnClientUpdated(self, client, isPickup)

        local data = client.variantData
        if data == nil or isPickup then
            return
        end

        if GetHasVariant(kExoVariantsData, data.exoVariant, client) or client:GetIsVirtual() then
            self.exoVariant = data.exoVariant
            self.lastExoVariant = self.exoVariant
        else
            Log("ERROR: Client tried to request Exo variant they do not have yet")
        end
    end

    function ExoVariantMixin:TransferExoVariant(exosuit)
        self:SetExoVariant(exosuit:GetExoVariant())
    end

end

if Client then

    function ExoVariantMixin:GetWeaponLoadoutClass()

        if self:isa("Exosuit") or self:isa("ReadyRoomExo") then
            local modelName = self:GetModelName()   --hacks
            if StringEndsWith( modelName, "_mm.model" ) then
                return "Minigun"
            elseif StringEndsWith( modelName, "_rr.model" ) then
                return "Railgun"
            end
        else
            local wep = self:GetActiveWeapon()
            if wep then
            --This assumes no mixed weapons are allowed (only sets)
                return wep:GetLeftSlotWeapon():GetClassName()
            end
            return false
        end
    end

    function ExoVariantMixin:OnExoSkinChanged()

        if self.clientExoVariant == self.exoVariant then
            return false
        end

        self.dirtySkinState = true
    end

    function ExoVariantMixin:OnModelChanged(hasModel)

        if hasModel then
            if self:isa("Exosuit") then
                self:OnExoSkinChanged()
            end
        end
    end

    function ExoVariantMixin:OnUpdate(deltaTime)
        if not Shared.GetIsRunningPrediction() then
            if self:isa("Exosuit") and ( self.clientExoVariant ~= self.exoVariant ) then
                self:OnExoSkinChanged()
            end
        end
    end

    function ExoVariantMixin:OnUpdatePlayer(deltaTime)
        
        if not Shared.GetIsRunningPrediction() then

            if self.clientExoVariant ~= self.exoVariant then
                --Always run at least once to allow local client to have model-data in scope
                self:OnExoSkinChanged()
            end

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

            --Handle world model
            local worldModel = self:GetRenderModel()
            if worldModel and worldModel:GetReadyForOverrideMaterials() then

                if self.exoVariant ~= kDefaultExoVariant then

                    local worldMats = GetPrecachedCosmeticMaterial( weaponClass, self.exoVariant )
                    assert(worldMats and type(worldMats) == "table")

                    for i = 1, #worldMats do
                        local worldMaterial = worldMats[i].mat
                        local worldMatIndex = worldMats[i].idx
                        assert(worldMaterial)
                        assert(worldMatIndex)
                        worldModel:SetOverrideMaterial( worldMatIndex, worldMaterial )
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

                            local viewMats = GetPrecachedCosmeticMaterial( weaponClass, self.exoVariant, true )
                            assert(viewMats and type(viewMats) == "table")

                            if weaponClass == "Minigun" then
                                assert(#viewMats == 1)
                                viewModel:SetOverrideMaterial( 0, viewMats[1] )
                            elseif weaponClass == "Railgun" then
                                assert(#viewMats == 2)
                                viewModel:SetOverrideMaterial( 0, viewMats[1] )
                                viewModel:SetOverrideMaterial( 1, viewMats[2] )
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
    
    PrecacheCosmeticMaterials("ClawMinigun", kExoVariantsData)
    PrecacheCosmeticMaterials("ClawRailgun", kExoVariantsData)
    
    local exoVariantNames = {
        mm = "Minigun",
        rr = "Railgun",
        cm = "ClawMinigun",
        cr = "ClawRailgun",
		pp = "PlasmaLauncher",
		cp = "ClawPlasmaLauncher",
		rp = "RailgunPlasmaLauncher",
		pr = "PlasmaLauncherRailgun",
		ff = "ExoFlamer",
		fp = "ExoFlamerPlasmaLauncher",
		pf = "PlasmaLauncherExoFlamer",
		fr = "ExoFlamerRailgun",
		rf = "RailgunExoFlamer",
		cf = "ClawExoFlamer",
    }
	
	local DualRailgunModelList = {
	"PlasmaLauncher",
	"RailgunPlasmaLauncher",
	"PlasmaLauncherRailgun",
	"ExoFlamer",
	"ExoFlamerPlasmaLauncher",
	"PlasmaLauncherExoFlamer",
	"ExoFlamerRailgun",
	"RailgunExoFlamer",
	}
	
	local ClawRailgunModelList = {
	"ClawPlasmaLauncher",
	"ClawExoFlamer",
	}
	
	local function LocateItem(table, value)
		for i = 1, #table do
			if table[i] == value then return true end
		end
		return false
	end
	
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
				
				if LocateItem(DualRailgunModelList, className) then
					className = "Railgun"
				end
				
				if LocateItem(ClawRailgunModelList, className) then
					className = "ClawRailgun"
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
				
					if LocateItem(DualRailgunModelList, weaponClass) then
						weaponClass = "Railgun"
					elseif LocateItem(ClawRailgunModelList, weaponClass) then
						weaponClass = "ClawRailgun"
					end			
				
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