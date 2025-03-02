-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Alien_Client.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/MaterialUtility.lua")

Alien.kEnzymedViewMaterialName = "cinematics/vfx_materials/enzyme_view.material"
Alien.kEnzymedThirdpersonMaterialName = "cinematics/vfx_materials/enzyme.material"
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/enzyme_view.surface_shader")
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/enzyme.surface_shader")

local AlienkCelerityViewCinematic = PrecacheAsset("cinematics/alien/high_speed_1p.cinematic")
-- used in Weapons/Alien/Metabolize.lua
kRegenerationViewCinematic = PrecacheAsset("cinematics/alien/regeneration_1p.cinematic")
local AlienkFirstPersonDeathEffect = PrecacheAsset("cinematics/alien/death_1p_alien.cinematic")

Alien.kElectrifiedViewMaterialName = "cinematics/vfx_materials/pulse_gre_elec.material"
Alien.kElectrifiedThirdpersonMaterialName = "cinematics/vfx_materials/pulse_gre_elec.material"
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/pulse_gre_elec.surface_shader")
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/pulse_gre_elec.surface_shader")

Alien.kMucousViewMaterialName = "cinematics/vfx_materials/mucousshield_view.material"
Alien.kMucousThirdpersonMaterialName = "cinematics/vfx_materials/mucousshield.material"
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/mucousshield.surface_shader")
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/mucousshield_view.surface_shader")

Alien.kBoneshieldThirdPersonMaterialName = "cinematics/vfx_materials/boneshield.material"
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/boneshield.surface_shader")

Alien.kStormedViewMaterialName = "cinematics/vfx_materials/storm_view.material"
Alien.kStormedThirdpersonMaterialName = "cinematics/vfx_materials/storm.material"
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/storm_view.surface_shader")
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/storm.surface_shader")

local kAlienFirstPersonHitEffectName = PrecacheAsset("cinematics/alien/hit_1p.cinematic")

local kEnzymeEffectInterval = 0.2
local kMucousEffectInterval = 1
local cinematicCeleDuration = 3.2

function PlayerUI_GetNumHives()

    for _, ent in ientitylist(Shared.GetEntitiesWithClassname("AlienTeamInfo")) do
        return ent:GetNumHives()
    end

    return 0

end

function AlienUI_GetHasMovementSpecial()

    local hasMovementSpecial = false

    local player = Client.GetLocalPlayer()
    if player and player.GetHasMovementSpecial then
        hasMovementSpecial = player:GetHasMovementSpecial()
    end

    return hasMovementSpecial

end

function AlienUI_GetMovementSpecialTechId()

    local techId = false

    local player = Client.GetLocalPlayer()
    if player and player.GetMovementSpecialTechId then
        techId = player:GetMovementSpecialTechId()
    end

    return techId

end

function AlienUI_GetMovementSpecialEnergyCost()

    local cost = 0

    local player = Client.GetLocalPlayer()
    if player and player.GetMovementSpecialEnergyCost then
        cost = player:GetMovementSpecialEnergyCost()
    end

    return cost

end

function AlienUI_GetMovementSpecialCooldown()

    local fraction = 0

    local player = Client.GetLocalPlayer()
    if player and player.GetMovementSpecialCooldown then
        fraction = player:GetMovementSpecialCooldown()
    end

    return fraction

end

-- array of totalPower, minPower, xoff, yoff, visibility (boolean), hud slot
function GetActiveAbilityData(secondary)

    local data = { }

    local player = Client.GetLocalPlayer()

    if player ~= nil then

        local ability = player:GetActiveWeapon()

        if ability ~= nil and ability:isa("Ability") then

            if not secondary or secondary and ability:GetHasSecondary(player) then
                data = ability:GetInterfaceData(secondary, false)
            end

        end

    end

    return data

end

function AlienUI_GetHasAdrenaline()

    local player = Client.GetLocalPlayer()
    local hasAdrenaline = false

    if player then
        hasAdrenaline = player.hasAdrenalineUpgrade
    end

    return hasAdrenaline == true

end

function AlienUI_GetInUmbra()

    local player = Client.GetLocalPlayer()
    if player ~= nil and HasMixin(player, "Umbra") then
        return player:GetHasUmbra()
    end

    return false

end

function AlienUI_GetAvailableUpgrades()

    local techTree = GetTechTree()

    local upgrades = {}
    local localPlayer = Client.GetLocalPlayer()

    if techTree and localPlayer then

        for _, upgradeId in ipairs(techTree:GetAddOnsForTechId(kTechId.AllAliens)) do

            local upgradeNode = techTree:GetTechNode(upgradeId)
            local hiveType = GetHiveTypeForUpgrade(upgradeId)

            if upgradeNode:GetAvailable() and not localPlayer:GetHasUpgrade(upgradeId) then

                if not upgrades[hiveType] then
                    upgrades[hiveType] = {}
                end

                table.insert(upgrades[hiveType], upgradeNode:GetTechId())
            end

        end

    end

    return upgrades

end

function AlienUI_HasSameTypeUpgrade(selectedIds, techId)

    local desiredHiveType = GetHiveTypeForUpgrade(techId)
    for _, selectedId in ipairs(selectedIds) do

        if GetHiveTypeForUpgrade(selectedId) == desiredHiveType then
            return true
        end

    end

    return false

end

function AlienUI_GetEggCount()

    local eggCount = 0

    local teamInfo = GetTeamInfoEntity(kTeam2Index)
    if teamInfo then
        eggCount = teamInfo:GetEggCount()
    end

    return eggCount

end

--
-- For current ability, return an array of
-- totalPower, minimumPower, tex x offset, tex y offset,
-- visibility (boolean), command name
--
function PlayerUI_GetAbilityData()

    local data = {}
    local player = Client.GetLocalPlayer()
    if player ~= nil then

        table.addtable(GetActiveAbilityData(false), data)

    end

    return data

end

--
-- For secondary ability, return an array of
-- totalPower, minimumPower, tex x offset, tex y offset,
-- visibility (boolean)
--
function PlayerUI_GetSecondaryAbilityData()

    local data = {}
    local player = Client.GetLocalPlayer()
    if player ~= nil then

        table.addtable(GetActiveAbilityData(true), data)

    end

    return data

end

--
-- Return boolean value indicating if inactive powers should be visible
--
function PlayerUI_GetInactiveVisible()
    local player = Client.GetLocalPlayer()
    return player:isa("Alien") and player:GetInactiveVisible()
end

-- Loop through child weapons that aren't active and add all their data into one array
function PlayerUI_GetInactiveAbilities()

    local data = {}

    local player = Client.GetLocalPlayer()

    if player and player:isa("Alien") then

        local inactiveAbilities = player:GetHUDOrderedWeaponList()

        -- Don't show selector if we only have one ability
        if table.icount(inactiveAbilities) > 1 then

            for _, ability in ipairs(inactiveAbilities) do

                if ability:isa("Ability") then
                    local abilityData = ability:GetInterfaceData(false, true)
                    if table.icount(abilityData) > 0 then
                        table.addtable(abilityData, data)
                    end
                end

            end

        end

    end

    return data

end

function PlayerUI_GetPlayerEnergy()

    local player = Client.GetLocalPlayer()
    if player and player.GetEnergy then
        return player:GetEnergy()
    end
    return 0

end

function PlayerUI_GetPlayerMaxEnergy()

    local player = Client.GetLocalPlayer()
    if player and player.GetMaxEnergy then
        return player:GetMaxEnergy()
    end
    return kAbilityMaxEnergy

end

function PlayerUI_GetHasMucousShield()
    local result = false

    local player = Client.GetLocalPlayer()
    if player then
        if player.GetHasMucousShield then
            result = player:GetHasMucousShield()
        end

        if player.GetHasBabblerShield then
            result = result or player:GetHasBabblerShield()
        end

        if HasMixin(player, "Shieldable") then
            result = result or player:GetHasOverShield()
        end
    end

    return result

end

function PlayerUI_GetMucousShieldHP()
    local player = Client.GetLocalPlayer()
    if not player then return 0, 0 end

    local health = 0
    local maxHealth = 0

    if player.GetMuscousShieldAmount then
        health = math.ceil(player:GetMuscousShieldAmount())
        if health > 0 then
            maxHealth = player:GetMaxShieldAmount()
        end
    end

    if player.GetBabblerShieldAmount then
        local shield = math.ceil(player:GetBabblerShieldAmount())
        if shield > 0 then
            health = health + shield
            maxHealth = maxHealth + player:GetMaxBabblerShieldAmount()
        end
    end

    if HasMixin(player, "Shieldable") then
        local shield = math.ceil(player:GetOverShieldAmount())
        if shield > 0 then
            health = health + shield
            maxHealth = maxHealth + player:GetMaxOverShieldAmount()
        end
    end

    return health, maxHealth
end

function PlayerUI_GetMucousShieldFraction()
    local health, maxHealth = PlayerUI_GetMucousShieldHP()

    if maxHealth == 0 or health == 0 then return 0 end

    return Clamp(health / maxHealth, 0, 1)
end

function PlayerUI_GetMucousShieldTimeRemaining()

    local player = Client.GetLocalPlayer()
    local fraction = 0

    if player then
        if player.GetShieldTimeRemaining then
            fraction = math.max(player:GetShieldTimeRemaining(), fraction)
        end

        if HasMixin(player, "Shieldable") then
            fraction = math.max(player:GetOverShieldTimeRemaining(), fraction)
        end
    end

    return fraction

end

function PlayerUI_GetPlayerMucousShieldState()

    local playerMucousShieldState = 1
    if PlayerUI_GetHasMucousShield() then
        playerMucousShieldState = 2
    end

    return playerMucousShieldState

end

function PlayerUI_GetIsOnFire()

    local player = Client.GetLocalPlayer()
    if player and player.GetIsOnFire then
        return player:GetIsOnFire()
    end

    return false

end

function PlayerUI_GetIsElectrified()

    local player = Client.GetLocalPlayer()
    if player and player.GetElectrified then
        return player:GetElectrified()
    end

    return false

end

function PlayerUI_GetIsWallWalking()

    local player = Client.GetLocalPlayer()
    if player and player:isa("Skulk") then
        return player:GetIsWallWalking()
    end

    return false

end

function Alien:UpdateEnzymeEffect(isLocal)

    if self.enzymedClient ~= self.enzymed then

        if isLocal then

            local viewModel
            if self:GetViewModelEntity() then
                viewModel = self:GetViewModelEntity():GetRenderModel()
            end

            if viewModel then

                if self.enzymed then
                    self.enzymedViewMaterial = AddMaterial(viewModel, Alien.kEnzymedViewMaterialName)
                else

                    if RemoveMaterial(viewModel, self.enzymedViewMaterial) then
                        self.enzymedViewMaterial = nil
                    end

                end

            end

        end

        local thirdpersonModel = self:GetRenderModel()
        if thirdpersonModel then

            if self.enzymed then
                self.enzymedMaterial = AddMaterial(thirdpersonModel, Alien.kEnzymedThirdpersonMaterialName)
            else

                if RemoveMaterial(thirdpersonModel, self.enzymedMaterial) then
                    self.enzymedMaterial = nil
                end

            end

        end

        self.enzymedClient = self.enzymed

    end

    -- update cinemtics
    if self.enzymed then

        if not self.lastEnzymedEffect or self.lastEnzymedEffect + kEnzymeEffectInterval < Shared.GetTime() then

            self:TriggerEffects("enzymed")
            self.lastEnzymedEffect = Shared.GetTime()

        end

    end

end

function Alien:UpdateBoneshieldEffects(isLocal)

    local isBoneshieldActive = self.GetIsBoneShieldActive and self:GetIsBoneShieldActive()
    if self.wasBoneshieldActive ~= isBoneshieldActive then

        local thirdpersonModel = self:GetRenderModel()
        if thirdpersonModel then

            if isBoneshieldActive then
                self.boneshieldMaterial = AddMaterial(thirdpersonModel, Alien.kBoneshieldThirdPersonMaterialName)
            else
                if RemoveMaterial(thirdpersonModel, self.boneshieldMaterial) then
                    self.boneshieldMaterial = nil
                end
            end

        end

        self.wasBoneshieldActive = self.GetIsBoneShieldActive and self:GetIsBoneShieldActive()

    end

end

function Alien:UpdateMucousEffects(isLocal)

    if self.mucousClient ~= self.mucousShield then

        if isLocal then

            local viewModel
            if self:GetViewModelEntity() then
                viewModel = self:GetViewModelEntity():GetRenderModel()
            end

            if viewModel then

                if self.mucousShield then
                    self.mucousViewMaterial = AddMaterial(viewModel, Alien.kMucousViewMaterialName)
                else

                    if RemoveMaterial(viewModel, self.mucousViewMaterial) then
                        self.mucousViewMaterial = nil
                    end

                end

            end

        end

        local thirdpersonModel = self:GetRenderModel()
        if thirdpersonModel then

            if self.mucousShield then
                self.mucousMaterial = AddMaterial(thirdpersonModel, Alien.kMucousThirdpersonMaterialName)
            else

                if RemoveMaterial(thirdpersonModel, self.mucousMaterial) then
                    self.mucousMaterial = nil
                end

            end

        end

        self.mucousClient = self.mucousShield

    end

    -- update cinemtics
    if self.mucousShield then

        if not self.lastMucousEffect or self.lastMucousEffect + kMucousEffectInterval < Shared.GetTime() then

            self.lastMucousEffect = Shared.GetTime()

        end

    end

end

function Alien:GetDarkVisionEnabled()

    if Client.GetIsControllingPlayer() then
        return self.darkVisionOn
    else
        return self.darkVisionSpectatorOn
    end

end

function Alien:GetShowElectrifyEffect()
    return self.electrified
end

function Alien:UpdateElectrified(isLocal)

    local electrified = self:GetShowElectrifyEffect()

    if self.electrifiedClient ~= electrified then

        if isLocal then

            local viewModel
            if self:GetViewModelEntity() then
                viewModel = self:GetViewModelEntity():GetRenderModel()
            end

            if viewModel then

                if electrified then
                    self.electrifiedViewMaterial = AddMaterial(viewModel, Alien.kElectrifiedViewMaterialName)
                    self.electrifiedViewMaterial:SetParameter("elecAmount",  0.3)
                else

                    if RemoveMaterial(viewModel, self.electrifiedViewMaterial) then
                        self.electrifiedViewMaterial = nil
                    end

                end

            end

        end

        local thirdpersonModel = self:GetRenderModel()
        if thirdpersonModel then

            if electrified then
                self.electrifiedMaterial = AddMaterial(thirdpersonModel, Alien.kElectrifiedThirdpersonMaterialName)
                self.electrifiedMaterial:SetParameter("elecAmount",  1.5)
            else

                if RemoveMaterial(thirdpersonModel, self.electrifiedMaterial) then
                    self.electrifiedMaterial = nil
                end

            end

        end

        self.electrifiedClient = electrified
        
    end
end


local alienVisionEnabled = true
local function ToggleAlienVision(enabled)
    alienVisionEnabled = enabled ~= "false"
end
Event.Hook("Console_alienvision", ToggleAlienVision)

function Alien:UpdateClientEffects(deltaTime, isLocal)

    Player.UpdateClientEffects(self, deltaTime, isLocal)

    -- If we are dead, close the evolve menu.
    if isLocal and not self:GetIsAlive() and self:GetBuyMenuIsDisplaying() then
        self:CloseMenu()
    end

    self:UpdateEnzymeEffect(isLocal)
    self:UpdateElectrified(isLocal)
    self:UpdateMucousEffects(isLocal)
    self:UpdateBoneshieldEffects(isLocal)
	self:UpdateStormEffect(isLocal)

    if isLocal and self:GetIsAlive() then

        local darkVisionFadeAmount = 1
        local darkVisionFadeTime = 0.2
        local darkVisionState = self:GetDarkVisionEnabled()

        if self.lastDarkVisionState ~= darkVisionState then

            if darkVisionState then

                self.darkVisionTime = Shared.GetTime()
                self:TriggerEffects("alien_vision_on")

            else

                self.darkVisionEndTime = Shared.GetTime()
                self:TriggerEffects("alien_vision_off")

            end

            self.lastDarkVisionState = darkVisionState

        end

        if not darkVisionState then
            darkVisionFadeAmount = Clamp(1 - (Shared.GetTime() - self.darkVisionEndTime) / darkVisionFadeTime, 0, 1)
        end

        local useShader = Player.screenEffects.darkVision

        if useShader then

            useShader:SetActive(alienVisionEnabled)
            useShader:SetParameter("startTime", self.darkVisionTime)
            useShader:SetParameter("time", Shared.GetTime())
            useShader:SetParameter("amount", darkVisionFadeAmount)
            if (avType ~= nil) then
                useShader:SetParameter("avType", avType)
            end

        end

        self:UpdateRegenerationEffect()

    end

end

function Alien:GetFirstPersonDeathEffect()
    return AlienkFirstPersonDeathEffect
end

function Alien:UpdateRegenerationEffect()

    local GUIRegenerationFeedback = ClientUI.GetScript("GUIRegenerationFeedback")
    if GUIRegenerationFeedback and GUIRegenerationFeedback:GetIsAnimating() and
            GetHasRegenerationUpgrade(self) and self:GetShellLevel() > 0 then

        if self.lastHealth then

            if self.lastHealth < self:GetHealth() then

                GUIRegenerationFeedback:TriggerRegenEffect()
                local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
                cinematic:SetCinematic(kRegenerationViewCinematic)

            end

        end

        self.lastHealth = self:GetHealth()

    end

end

function Alien:UpdateMisc(input)

    Player.UpdateMisc(self, input)

    if not Shared.GetIsRunningPrediction() then

        -- Close the buy menu if it is visible when the Alien moves.
        if input.move.x ~= 0 or input.move.z ~= 0 then
            self:CloseMenu()
        end

    end

end

-- Bring up evolve menu
function Alien:Buy()

    -- Don't allow display in the ready room, or as phantom
    -- Don't allow buy menu to be opened while help screen is displayed.
    if self:GetIsLocalPlayer() and
            not HelpScreen_GetHelpScreen():GetIsBeingDisplayed() and
            not GetMainMenu():GetVisible() then

        -- The Embryo cannot use the buy menu in any case.
        if self:GetTeamNumber() ~= 0 and not self:isa("Embryo") then

            if not self.buyMenu then

                self.buyMenu = GetGUIManager():CreateGUIScript("GUIAlienBuyMenu")

            else
                self:CloseMenu()
            end

        else
            self:PlayEvolveErrorSound()
        end

    end

end

function Alien:PlayEvolveErrorSound()

    if not self.timeLastEvolveErrorSound then
        self.timeLastEvolveErrorSound = Shared.GetTime()
    end

    if self.timeLastEvolveErrorSound + 0.5 < Shared.GetTime() then

        self:TriggerInvalidSound()
        self.timeLastEvolveErrorSound = Shared.GetTime()

    end

end

function Alien:OnCountDown()

    Player.OnCountDown(self)

    local script = ClientUI.GetScript("GUIAlienHUD")
    if script then
        script:SetIsVisible(false)
    end

end

function Alien:OnCountDownEnd()

    Player.OnCountDownEnd(self)

    local script = ClientUI.GetScript("GUIAlienHUD")
    if script then
        script:SetIsVisible(true)
    end

end

function Alien:GetFirstPersonHitEffectName()
    return kAlienFirstPersonHitEffectName
end

function AlienUI_GetPersonalUpgrades()

    local upgrades = {}

    local techTree = GetTechTree()

    if techTree then

        for _, upgradeId in ipairs(techTree:GetAddOnsForTechId(kTechId.AllAliens)) do
            table.insert(upgrades, {TechId = upgradeId, Category = GetHiveTypeForUpgrade(upgradeId)})
        end

    end

    return upgrades

end

function AlienUI_GetUpgradesForCategory(category)

    local upgrades = {}

    local techTree = GetTechTree()

    if techTree then

        for _, upgradeId in ipairs(techTree:GetAddOnsForTechId(kTechId.AllAliens)) do

            if LookupTechData(upgradeId, kTechDataCategory, kTechId.None) == category then
                table.insert(upgrades, upgradeId)
            end

        end

    end

    -- CommunityBalanceMod: preserve upgrade location for vamp, regen
    if category == kTechId.CragHive and 
        #upgrades == 3 and
        kTechId.Resilience ~= nil and 
        kTechId.Vampirism ~= nil and 
        kTechId.Regeneration ~= nil 
        then 
        upgrades[1] =  kTechId.Vampirism  
        upgrades[2] =  kTechId.Resilience
        upgrades[3] =  kTechId.Regeneration
    end

    
    return upgrades

end
-- create some blood on the ground below
local kGroundDistanceBlood = Vector(0, 1, 0)
local kGroundBloodStartOffset = Vector(0, 0.2, 0)
function Alien:OnTakeDamageClient(damage, doer, position)

    if not self.timeLastGroundBloodDecal then
        self.timeLastGroundBloodDecal = 0
    end

    --[[if self.timeLastGroundBloodDecal + 0.38 < Shared.GetTime() and doer then
        self:TriggerEffects("damage_sound_target_local", { doer = doer:GetClassName() })
    end--]]

    if self.timeLastGroundBloodDecal + 0.5 < Shared.GetTime() then

        local trace = Shared.TraceRay(self:GetOrigin() + kGroundBloodStartOffset, self:GetOrigin() - kGroundDistanceBlood, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAll())
        if trace.fraction ~= 1 then

            local coords = Coords.GetIdentity()
            coords.origin = trace.endPoint
            coords.yAxis = trace.normal
            coords.zAxis = coords.yAxis:GetPerpendicular()
            coords.xAxis = coords.yAxis:CrossProduct(coords.zAxis)

            self:TriggerEffects("alien_blood_ground", {effecthostcoords = coords})

        end

        self.timeLastGroundBloodDecal = Shared.GetTime()

    end

end

function Alien:OnUpdateRender()

    Player.OnUpdateRender(self)

    if self.isHallucination then

        local model = self:GetRenderModel()
        local player = Client.GetLocalPlayer()

        if model then

            if not GetAreEnemies(self, player) then

                if not self.hallucinationMaterial then

                    self.hallucinationMaterial = AddMaterial(model, "cinematics/vfx_materials/hallucination.material")
                    self:SetOpacity(0, "hallucination")

                end

            elseif self.hallucinationMaterial then

                self:SetOpacity(1, "hallucination")
                RemoveMaterial(model, self.hallucinationMaterial)
                self.hallucinationMaterial = nil

            end

        end

    end

end

-- %%% New CBM Functions %%% --
function Alien:UpdateStormEffect(isLocal)
    if self.stormedClient ~= self.stormed then

        if isLocal then

            local viewModel
            if self:GetViewModelEntity() then
                viewModel = self:GetViewModelEntity():GetRenderModel()
            end

            if viewModel then
               
                if self.stormed then
                    self.stormedViewMaterial = AddMaterial(viewModel, Alien.kStormedViewMaterialName)
 
                    self.cinematicCele = Client.CreateCinematic(RenderScene.Zone_ViewModel)
                    self.cinematicCele:SetCinematic(FilterCinematicName(self:GetSpeedParticles()))
                      --self.cinematicCele:SetRepeatStyle(Cinematic.Repeat_Loop)
                    self.startedCinematicCele = Shared.GetTime()
                else

                    if self.cinematicCele then 
                        Client.DestroyCinematic(self.cinematicCele)
                        self.cinematicCele  = nil
                    end

                    if RemoveMaterial(viewModel, self.stormedViewMaterial) then
                        self.stormedViewMaterial = nil

                    end
                end
            end
        end

        local thirdpersonModel = self:GetRenderModel()
        if thirdpersonModel then

            if self.stormed then
                self.stormedMaterial = AddMaterial(thirdpersonModel, Alien.kStormedThirdpersonMaterialName)
            else

                if RemoveMaterial(thirdpersonModel, self.stormedMaterial) then
                    self.stormedMaterial = nil
                end
            end
        end
        self.stormedClient = self.stormed

    elseif self.stormed and self.startedCinematicCele and self.cinematicCele 
        and self.startedCinematicCele + cinematicCeleDuration < Shared.GetTime() then
            Client.DestroyCinematic(self.cinematicCele)
            self.cinematicCele = Client.CreateCinematic(RenderScene.Zone_ViewModel)
            self.cinematicCele:SetCinematic(FilterCinematicName(self:GetSpeedParticles()))
        self.startedCinematicCele = Shared.GetTime()
    end
end

function Alien:GetSpeedParticles()
    return AlienkCelerityViewCinematic
end