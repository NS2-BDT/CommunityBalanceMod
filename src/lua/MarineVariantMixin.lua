-- ======= Copyright (c) 2003-2019, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\MarineVariantMixin.lua
--
-- ==============================================================================================

Script.Load("lua/Globals.lua")
Script.Load("lua/NS2Utility.lua")

MarineVariantMixin = CreateMixin(MarineVariantMixin)
MarineVariantMixin.type = "MarineVariant"

local kDefaultVariantData = kMarineVariantsData[ kDefaultMarineVariant ]
local kDefaultMacVariantData = kMarineVariantsData[ kDefaultMarineBigmacVariant ]
--local kDefaultAngryMacVariantData = kMarineVariantsData[ kDefaultMarineMilitaryMacVariant ]

-- Utiliy function for other models that are dependent on marine variant
function GenerateMarineViewModelPaths(weaponName)

    local viewModels = { male = { }, female = { }, bigmac = {} }

    local function MakePath( prefix, suffix )
        return "models/marine/"..weaponName.."/"..prefix..weaponName.."_view"..suffix..".model"
    end

    local defaultMale =  PrecacheAsset(MakePath("", kDefaultVariantData.viewModelFilePart) )
    local defaultFemale =  PrecacheAssetSafe( MakePath("female_", kDefaultVariantData.viewModelFilePart), defaultMale )
    local defaultBigmac =  PrecacheAsset(MakePath("", kDefaultMacVariantData.viewModelFilePart) )

    for variant, data in pairs(kMarineVariantsData) do
        if data.isRobot and not viewModels.bigmac[variant] then
            viewModels.bigmac[variant] = PrecacheAssetSafe( MakePath("", data.viewModelFilePart), defaultBigmac )
        else
            viewModels.male[variant] = PrecacheAssetSafe( MakePath("", data.viewModelFilePart), defaultMale )
            viewModels.female[variant] = PrecacheAssetSafe( MakePath("female_", data.viewModelFilePart), defaultFemale )
        end
    end

    return viewModels
end


if Client then

--FIXME Below lists need explicit destroys on client shutdown (not Entity Destroy), e.g. Lua VM shutdown (exit to Menu)
kBigMacViewMaterials = 
{
    [kMarineVariants.bigmac02] = PrecacheAsset("models/marine/bigmac/bigmac02_view.material"),
    [kMarineVariants.bigmac03] = PrecacheAsset("models/marine/bigmac/bigmac03_view.material"),
    [kMarineVariants.bigmac04] = PrecacheAsset("models/marine/bigmac/bigmac04_view.material"),
    [kMarineVariants.bigmac05] = PrecacheAsset("models/marine/bigmac/bigmac05_view.material"),
    [kMarineVariants.bigmac06] = PrecacheAsset("models/marine/bigmac/bigmac06_view.material"),
    [kMarineVariants.chromabmac] = PrecacheAsset("models/marine/bigmac/bigmac07_view.material"),
}

kMilitaryViewMaterials = --shared view model
{
    [kMarineVariants.militarymac] = PrecacheAsset("models/marine/bigmac/bigmac_military_view.material"),
    [kMarineVariants.militarymac02] = PrecacheAsset("models/marine/bigmac/bigmac_military02_view.material"),
    [kMarineVariants.militarymac03] = PrecacheAsset("models/marine/bigmac/bigmac_military03_view.material"),
    [kMarineVariants.militarymac04] = PrecacheAsset("models/marine/bigmac/bigmac_military04_view.material"),
    [kMarineVariants.militarymac05] = PrecacheAsset("models/marine/bigmac/bigmac_military05_view.material"),
    [kMarineVariants.militarymac06] = PrecacheAsset("models/marine/bigmac/bigmac_military06_view.material"),
    [kMarineVariants.chromamilbmac] = PrecacheAsset("models/marine/bigmac/bigmac_military07_view.material"),
}

kDefaultViewMaterialVariant = kMarineVariants.bigmac

kBmacMaterialViewIndices = --Zero-based indices (shared view model for all bmacs)
{
    ["Axe"] = 1,
    ["Pistol"] = 2,
    ["Rifle"] = 2,
    ["Builder"] = 2,
    ["Welder"] = 2,
    ["Shotgun"] = 4,
    ["Flamethrower"] = 2,
    ["GrenadeLauncher"] = 3,
    ["HeavyMachineGun"] = 2,
    ["LayMines"] = 2,
    ["GasGrenadeThrower"] = 1,
    ["ClusterGrenadeThrower"] = 1,
    ["PulseGrenadeThrower"] = 1,
	["ScanGrenadeThrower"] = 1,
	["Submachinegun"] = 0,
}

function GetMaterialIndexPerWeapon( wepClass )
    assert(wepClass)
    assert(kBmacMaterialViewIndices[wepClass])
    return kBmacMaterialViewIndices[wepClass]
end

function GetViewOverrideMaterial( variant )
    assert(variant)
    local type = GetRoboticType(variant)
    if type == kBigMacVariantType then
        return kBigMacViewMaterials[variant]
    else
        return kMilitaryViewMaterials[variant]
    end
end

end --End-client-only

-- precache models fror all variants
MarineVariantMixin.kModelNames = { male = { }, female = { }, bigmac = {} }

local function MakeModelPath( marineType, suffix )
    return "models/marine/" .. marineType .. "/" .. marineType .. suffix .. ".model"
end

for variant, data in pairs(kMarineVariantsData) do
    if data.isRobot then
        MarineVariantMixin.kModelNames.bigmac[variant] = PrecacheAssetSafe( MakeModelPath("bigmac", data.modelFilePart), MakeModelPath("bigmac", kDefaultMacVariantData.modelFilePart) )
    else
        MarineVariantMixin.kModelNames.male[variant] = PrecacheAssetSafe( MakeModelPath("male", data.modelFilePart), MakeModelPath("male", kDefaultVariantData.modelFilePart) )
        MarineVariantMixin.kModelNames.female[variant] = PrecacheAssetSafe( MakeModelPath("female", data.modelFilePart), MakeModelPath("female", kDefaultVariantData.modelFilePart) )
    end
end

MarineVariantMixin.kDefaultModelName = MarineVariantMixin.kModelNames.male[kDefaultMarineVariant]

MarineVariantMixin.kMarineAnimationGraph = PrecacheAsset("models/marine/male/male.animation_graph") --shared across all models

MarineVariantMixin.kMilMacAngerVentsCinematic = PrecacheAsset("cinematics/marine/bigmac/bmac_05_steam.cinematic")
MarineVariantMixin.kBackAttachPoint = "JetPack"

MarineVariantMixin.networkVars =
{
    shoulderPadIndex = string.format("integer (0 to %d)",  #kShoulderPad2ItemId),
    marineType = "enum kMarineVariantsBaseType",
    variant = "enum kMarineVariants"
}

function MarineVariantMixin:__initmixin()
    
    self.variant = kDefaultMarineVariant
    self.shoulderPadIndex = 0
    self.marineType = kMarineVariantsBaseType.male

    if Client then
        self.clientVariant = nil

        self.clientShoulderPatchIndex = nil

        --special vfx for limited marine variants
        self.clientBackCinematic = nil

        --init as TRUE, to force skin-mats to update when entities are created
        self.initViewModelEvent = true

        --flag to trigger when Player model is changed, thus forcing ViewModel to update
        self.forceSkinsUpdate = false

        -- flag to trigger an update of the view model. There is some delay until the active weapon matches the view model weapon.
        self.viewModelDirty = false
    end

end

function MarineVariantMixin:GetMarineTypeString()
    return GetMarineTypeLabel( self.marineType )
end

function MarineVariantMixin:GetMarineType()
    return self.marineType
end

function MarineVariantMixin:GetVariant()
    return self.variant
end

function MarineVariantMixin:GetIsRoboticVariant()
    return table.icontains( kRoboticMarineVariantIds, self.variant )
end

function MarineVariantMixin:GetEffectParams(tableParams)
    tableParams[kEffectFilterSex] = self:GetMarineTypeString()
    tableParams[kEffectFilterAlternateType] = table.icontains( kMilitaryMacVariantIds , self.variant )
end

function MarineVariantMixin:GetVariantModel()
    return MarineVariantMixin.kModelNames[ self:GetMarineTypeString() ][ self.variant ]
end

if Server then

    function MarineVariantMixin:CopyPlayerDataFrom(player)
    --Handle copy to JetPack and/or Exos
        if player.variant then
            self.variant = player.variant
        end
    end

    -- Usually because the client connected or changed their options.
    function MarineVariantMixin:OnClientUpdated(client, isPickup)

        if not Shared.GetIsRunningPrediction() then
            Player.OnClientUpdated(self, client, isPickup)

            local data = client.variantData
            if data == nil then
                return
            end

            if table.icontains( kRoboticMarineVariantIds, data.marineVariant ) then
                self.marineType = kMarineVariantsBaseType.bigmac
            else
                self.marineType = data.isMale and kMarineVariantsBaseType.male or kMarineVariantsBaseType.female
            end

            self.shoulderPadIndex = 0

            local selectedIndex = client.variantData.shoulderPadIndex

            if GetHasShoulderPad(selectedIndex, client) then
                self.shoulderPadIndex = selectedIndex
            end

            -- Some entities using MarineVariantMixin don't care about model changes.
            if self.GetIgnoreVariantModels and self:GetIgnoreVariantModels() then
                return
            end

            if GetHasVariant(kMarineVariantsData, data.marineVariant, client) or client:GetIsVirtual() then
                assert(self.variant > 0)
                self.variant = data.marineVariant
                local modelName = self:GetVariantModel()
                assert(modelName ~= "")
                self:SetModel(modelName, MarineVariantMixin.kMarineAnimationGraph)
            else
                Print("ERROR: Client tried to request marine variant they do not have yet")
            end
            
            -- Trigger a weapon skin update, to update the view model
            self:UpdateWeaponSkin(client)
        end

    end

end

if Client then

    function MarineVariantMixin:OnMarineSkinChanged()
        if self.clientVariant == self.variant and not self.forceSkinsUpdate then
            return
        end

        local varChanged = self.clientVariant ~= self.variant
        self.clientVariant = self.variant

        local player = Client.GetLocalPlayer()
        if player and player == self and (varChanged or self.forceSkinsUpdate) then
            self:OnUpdateViewModelEvent()
        end

        self:OnShoulderPatchChanged()
        
        if self.forceSkinsUpdate then
            self.forceSkinsUpdate = false
        end
    end

    function MarineVariantMixin:OnModelChanged(hasModel)
        if hasModel then
            self.forceSkinsUpdate = true
            self:OnMarineSkinChanged()
        end
    end

    function MarineVariantMixin:OnUpdatePlayer(deltaTime)

        if not Shared.GetIsRunningPrediction() then
            local player = Client.GetLocalPlayer()
            
            if player == self and ( self.initViewModelEvent or self.clientVariant ~= self.variant ) then
            --Always run at least once to allow local client to have model-data in scope
                self:OnMarineSkinChanged()
                self.initViewModelEvent = false --ensure this only runs once
            end

            if not self:isa("JetpackMarine") and player ~= self and not self:isa("Exo") and not self:isa("Spectator") then
                if self.variant == kMarineVariants.militarymac05 and self.clientBackCinematic == nil then
                    self.clientBackCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
                    self.clientBackCinematic:SetCinematic(MarineVariantMixin.kMilMacAngerVentsCinematic)
                    self.clientBackCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
                    self.clientBackCinematic:SetParent(self)
                    self.clientBackCinematic:SetCoords(Coords.GetIdentity())
                    self.clientBackCinematic:SetAttachPoint(self:GetAttachPointIndex(MarineVariantMixin.kBackAttachPoint))
                    self.clientBackCinematic:SetIsActive(true)
                elseif self.clientBackCinematic ~= nil and self.variant ~= kMarineVariants.militarymac05 then
                    Client.DestroyCinematic( self.clientBackCinematic )
                    self.clientBackCinematic = nil
                end
            end

            if (self:isa("Exo") or self.variant ~= kMarineVariants.militarymac05) and self.clientBackCinematic ~= nil or (self ~= player) then
                Client.DestroyCinematic( self.clientBackCinematic )
                self.clientBackCinematic = nil
            end
        end
        
    end

    function MarineVariantMixin:OnDestroy()
        if self.clientBackCinematic then
            Client.DestroyCinematic( self.clientBackCinematic )
            self.clientBackCinematic = nil
        end
    end

    function MarineVariantMixin:OnUpdateViewModelEvent()
        PROFILE("MarineVariantMixin:OnUpdateViewModelEvent")
        self.viewModelDirty = true
    end

    function MarineVariantMixin:OnUpdateRender()

        if self.viewModelDirty then

            if self:GetIsAlive() and self:isa("Marine") then

                local viewModel = self:GetViewModelEntity()

                local updateViewMaterials =
                        viewModel and
                        viewModel.weaponId ~= Entity.invalidId and
                        self:GetActiveWeaponId() == viewModel.weaponId

                if updateViewMaterials then

                    local viewRenderModel = viewModel:GetRenderModel()
                    if viewRenderModel and viewRenderModel:GetReadyForOverrideMaterials() then

                        --[[
                            Clear all override materials, this way we get a clean state and
                            we can be sure that left-over override materials are cleared for
                            when we switch between bmac/human view models.

                            (Due to different material indexes)
                        --]]
                        viewRenderModel:ClearOverrideMaterials()

                        if table.icontains( kRoboticMarineVariantIds, self.clientVariant ) then

                            --Handle BMAC hands mat-swap
                            if self.clientVariant ~= kMarineVariants.bigmac then

                                local matIdx = GetMaterialIndexPerWeapon( viewModel:GetWeapon():GetClassName() )
                                local viewMat = GetViewOverrideMaterial( self.clientVariant )
                                assert(matIdx)
                                assert(viewMat)
                                viewRenderModel:SetOverrideMaterial( matIdx, viewMat )

                            end
                        end

                        viewModel:SetHighlightNeedsUpdate()

                        local viewModelWeapon = viewModel:GetWeapon()
                        if viewModelWeapon then
                            if viewModelWeapon.SetSkinStateDirty then
                                viewModelWeapon:SetSkinStateDirty()
                            end
                        else
                            Log("ERROR: Could not flag weapon skin dirty. Weapon does not exist!")
                        end

                        -- Done!
                        self.viewModelDirty = false

                    else
                        -- Render model for the view model does not yet exist. Delay a frame.
                        return false
                    end

                else

                    -- If we are in the ready room, the we wont have a weapon id for the view model.
                    -- In this case just stop checking.
                    if viewModel and viewModel.weaponId == Entity.invalidId then
                        self.viewModelDirty = false
                        return false
                    end

                    -- The active weapon ID and view model weapon ID don't match up yet. Delay a frame.
                    -- Active weapon can get set after the view model weapon id.
                    return false
                end
            else
                -- Not alive or not marine. In this case we don't care anymore.
                self.viewModelDirty = false
            end

        end

    end

    Event.Hook("Console_dumpvariants", function()
        local p = Client.GetLocalPlayer()
        if p and p:isa("Marine") then
            Log("CLIENT | Marine Variants Data----------------------")
            Log("    variant:           %s", p.variant)
            Log("    clientVariant:     %s", p.clientVariant)
            Log("\tInventory:")

            for i = 0, p:GetNumChildren() - 1 do
    
                local child = p:GetChildAtIndex(i)
                if child:isa("Weapon") then
                    local class = child:GetClassName()
                    if class == "Axe" then
                        Log("\t\taxeVariant:                 %s", child.axeVariant)
                    elseif class == "Pistol" then
                        Log("\t\tpistolVariant:              %s", child.pistolVariant)
                    elseif class == "Rifle" then
                        Log("\t\trifleVariant:               %s", child.rifleVariant)
                    elseif class == "Builder" then
                        Log("\t\twelderVariant:              %s", child.welderVariant)
                    elseif class == "Welder" then
                        Log("\t\twelderVariant:              %s", child.welderVariant)
                    elseif class == "Shotgun" then
                        Log("\t\tshotgunVariant:             %s", child.shotgunVariant)
                    elseif class == "Flamethrower" then
                        Log("\t\tflamethrowerVariant:        %s", child.flamethrowerVariant)
                    elseif class == "GrenadeLauncher" then
                        Log("\t\tgrenadeLauncherVariant:     %s", child.grenadeLauncherVariant)
                    elseif class == "HeavyMachineGun" then
                        Log("\t\thmgVariant:                 %s", child.hmgVariant)
                    end
                end
                
            end

        end
    end)

    function MarineVariantMixin:OnShoulderPatchChanged()
        if self:GetRenderModel() ~= nil then
            self:GetRenderModel():SetMaterialParameter("patchIndex", self.shoulderPadIndex - 2)
            self.clientShoulderPatchIndex = self.shoulderPadIndex
        end
    end

end
