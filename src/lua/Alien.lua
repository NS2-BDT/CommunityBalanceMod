-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\Alien.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Player.lua")
Script.Load("lua/CloakableMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/DouseMixin.lua")
Script.Load("lua/CatalystMixin.lua")
Script.Load("lua/ScoringMixin.lua")
Script.Load("lua/Alien_Upgrade.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/EnergizeMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/AlienActionFinderMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/StormCloudMixin.lua")
Script.Load("lua/MucousableMixin.lua")
Script.Load("lua/ShieldableMixin.lua")
Script.Load("lua/BiomassHealthMixin.lua")
Script.Load("lua/Hud/GUINotificationMixin.lua")
Script.Load("lua/PlayerStatusMixin.lua")

local alienBloodSurfaceShader = PrecacheAsset("cinematics/vfx_materials/decals/alien_blood.surface_shader")

if Client then
    Script.Load("lua/TeamMessageMixin.lua")
end

class 'Alien' (Player)

Alien.kMapName = "alien"

if Server then
    Script.Load("lua/Alien_Server.lua")
elseif Client then
    Script.Load("lua/Alien_Client.lua")
end

local alienSurfaceShader = PrecacheAsset("models/alien/alien.surface_shader")

local AlienkNotEnoughResourcesSound = PrecacheAsset("sound/NS2.fev/alien/voiceovers/more")

local AlienkChatSound = PrecacheAsset("sound/NS2.fev/alien/common/chat")
local AlienkSpendResourcesSoundName = PrecacheAsset("sound/NS2.fev/alien/commander/spend_nanites")

-- Representative portrait of selected units in the middle of the build button cluster
Alien.kPortraitIconsTexture = "ui/alien_portraiticons.dds"

-- Multiple selection icons at bottom middle of screen
Alien.kFocusIconsTexture = "ui/alien_focusicons.dds"

-- Small mono-color icons representing 1-4 upgrades that the creature or structure has
Alien.kUpgradeIconsTexture = "ui/alien_upgradeicons.dds"

Alien.kAnimOverlayAttack = "attack"

Alien.kWalkBackwardSpeedScalar = 1

Alien.kEnergyRecuperationRate = kAlienAdrenalineEnergyRate

-- How long our "need healing" text gets displayed under our blip
Alien.kCustomBlipDuration = 10

local inf1 = PrecacheAsset("materials/infestation/infestation.dds")
local inf2 = PrecacheAsset("materials/infestation/infestation_normal.dds")
local inf3 = PrecacheAsset("models/alien/infestation/infestation2.model")
local inf4 = PrecacheAsset("cinematics/vfx_materials/vfx_neuron_03.dds")

local kDefaultAttackSpeed = 1

local networkVars =
{
    -- The alien energy used for all alien weapons and abilities (instead of ammo) are calculated
    -- from when it last changed with a constant regen added
    timeAbilityEnergyChanged = "compensated time",
    abilityEnergyOnChange = "compensated float (0 to " .. math.ceil(kAbilityMaxEnergy) .. " by 0.05 [] )",

    movementModiferState = "compensated boolean",

    oneHive = "private boolean",
    twoHives = "private boolean",
    threeHives = "private boolean",

    hasAdrenalineUpgrade = "boolean",

    enzymed = "boolean",

    silenceLevel = "integer (0 to 3)",

    electrified = "boolean",

    hatched = "private boolean",

    darkVisionSpectatorOn = "private boolean",

    isHallucination = "boolean",
    hallucinatedClientIndex = "integer",

    creationTime = "time",
    
	resilienceTimeEnd = "time",
    stormed = "boolean",
}

AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(DouseMixin, networkVars)
AddMixinNetworkVars(CatalystMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(EnergizeMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)
AddMixinNetworkVars(StormCloudMixin, networkVars)
AddMixinNetworkVars(ScoringMixin, networkVars)
AddMixinNetworkVars(MucousableMixin, networkVars)
AddMixinNetworkVars(ShieldableMixin, networkVars)
AddMixinNetworkVars(GUINotificationMixin, networkVars)
AddMixinNetworkVars(PlayerStatusMixin, networkVars)

function Alien:OnCreate()

    Player.OnCreate(self)

    InitMixin(self, FireMixin)
    InitMixin(self, UmbraMixin)
	InitMixin(self, DouseMixin)
    InitMixin(self, CatalystMixin)
    InitMixin(self, EnergizeMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, AlienActionFinderMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, StormCloudMixin)
    InitMixin(self, MucousableMixin)
    InitMixin(self, ShieldableMixin)
    InitMixin(self, BiomassHealthMixin)
    InitMixin(self, GUINotificationMixin)
    InitMixin(self, ScoringMixin, { kMaxScore = kMaxScore })
    InitMixin(self, PlayerStatusMixin)
    
    self.timeLastMomentumEffect = 0

    self.timeAbilityEnergyChanged = Shared.GetTime()
    self.abilityEnergyOnChange = self:GetMaxEnergy()
    self.lastEnergyRate = self:GetRecuperationRate()

    self.darkVisionOn = false

    self.lastDarkVisionState = false
    self.darkVisionLastFrame = false
    self.darkVisionTime = 0
    self.darkVisionEndTime = 0
	
	self.resilienceTimeEnd = Shared.GetTime()

    self.oneHive = false
    self.twoHives = false
    self.threeHives = false
    self.enzymed = false
	self.stormed = false

    if Server then

        self.timeWhenEnzymeExpires = 0
        self.timeLastCombatAction = 0
        self.silenceLevel = 0

        self.electrified = false
        self.timeElectrifyEnds = 0
		self.timeWhenStormExpires = 0

    elseif Client then
        InitMixin(self, TeamMessageMixin, { kGUIScriptName = "GUIAlienTeamMessage" })
    end

end

function Alien:OnJoinTeam()

    Player.OnJoinTeam( self )

    if self:GetTeamNumber() ~= kNeutralTeamType then
        self.oneHive = false
        self.twoHives = false
        self.threeHives = false
    end

end

function Alien:OnInitialized()

    Player.OnInitialized(self)

    InitMixin(self, CloakableMixin)

    local teamNumber = self:GetTeamNumber()
    local onAlienTeam = teamNumber == kAlienTeamType -- Avoid defaulting AV on if on ReadyRoom team for example.

    if Server then

        self.armor = self:GetArmorAmount()
        self.maxArmor = self.armor

        InitMixin(self, InfestationTrackerMixin)
        UpdateAbilityAvailability(self, self:GetTierOneTechId(), self:GetTierTwoTechId(), self:GetTierThreeTechId())

        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end

        self.darkVisionSpectatorOn = GetAlienVisionInitialStateForPlayer(self) and onAlienTeam

    elseif Client then

        InitMixin(self, HiveVisionMixin)

        if self:GetIsLocalPlayer() and self.hatched then
            self:TriggerHatchEffects()
        end

        self.darkVisionOn = GetAdvancedOption("avstate") and onAlienTeam

    end

    if Client and Client.GetLocalPlayer() == self then
        Client.SetPitch(0.0)
    end

    if self.isHallucination then
        InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kPlayerMoveOrderCompleteDistance })
    end

end

function Alien:GetHasOutterController()
    return not self.isHallucination and Player.GetHasOutterController(self)
end

function Alien:SetHatched()
    self.hatched = true
end

function Alien:GetCanRepairOverride(target)
    return false
end


-- player for local player
function Alien:TriggerHatchEffects()
    self.clientTimeTunnelUsed = Shared.GetTime()
end

function Alien:GetArmorAmount()

    if GetHasCarapaceUpgrade(self) then
        return self:GetArmorFullyUpgradedAmount()
    end

    return self:GetBaseArmor()

end

function Alien:GetBaseCarapaceArmorBuff()
    assert(false, "GetBaseCarapaceArmorBuff must be overridden!")
end

function Alien:GetCarapaceBonusPerBiomass()
    assert(false, "GetCarapaceBonusPerBiomass must be overridden!")
end

-- Called from AlienTeam:Update
function Alien:UpdateArmorAmount(carapaceLevel, biomassLevel)

    biomassLevel = biomassLevel or 0
    carapaceLevel = GetHasCarapaceUpgrade(self) and carapaceLevel or 0
    local carapaceBaseArmorBonus = carapaceLevel > 0 and self:GetBaseCarapaceArmorBuff() or 0
    local carapaceBiomassArmorBonus = (carapaceLevel > 0 and self:GetCarapaceBonusPerBiomass() or 0) * biomassLevel

    local newMaxArmor = self:GetBaseArmor()
    if carapaceLevel > 0 then
        newMaxArmor = self:GetBaseArmor() + (carapaceBaseArmorBonus + carapaceBiomassArmorBonus) * (carapaceLevel / 3)
    end

    if newMaxArmor ~= self.maxArmor then -- Shell level changed, or purchases carapace upgrade

        local oldArmorPercent = self.maxArmor > 0 and self.armor/self.maxArmor or 0
        self.maxArmor = newMaxArmor
        self:SetArmor(self.maxArmor * oldArmorPercent, true)

    end

end

function Alien:SetElectrified(time)

    -- Remove the mucous shield
    if HasMixin(self, "Mucousable") then
        self:ClearShield()
    end

    -- Remove the enzyme effect
    if self.ClearEnzyme then
        self:ClearEnzyme()
    end

    if self.timeElectrifyEnds - Shared.GetTime() < time then

        self.timeElectrifyEnds = Shared.GetTime() + time
        self.electrified = true

    end

end

function Alien:GetElectrified()

    return self.electrified

end

if Server then

    local function Electrify(client)

        if Shared.GetCheatsEnabled() then

            local player = client:GetControllingPlayer()
            if player.SetElectrified then
                player:SetElectrified(5)
            end

        end

    end
    Event.Hook("Console_electrify", Electrify)

end

function Alien:GetCanCatalystOverride()
    return false
end

function Alien:GetCarapaceSpeedReduction()
    return kCarapaceSpeedReduction
end

function Alien:GetCarapaceFraction()

    local maxCarapaceArmor = self:GetMaxArmor() - self:GetBaseArmor()
    local currentCarpaceArmor = math.max(0, self:GetArmor() - self:GetBaseArmor())

    if maxCarapaceArmor == 0 then
        return 0
    end

    return currentCarpaceArmor / maxCarapaceArmor

end

function Alien:GetCarapaceMovementScalar()

    if GetHasCarapaceUpgrade(self) then
        return 1 - self:GetCarapaceFraction() * self:GetCarapaceSpeedReduction()
    end

    return 1

end

function Alien:GetSlowSpeedModifier()
    return Player.GetSlowSpeedModifier(self) * self:GetCarapaceMovementScalar()
end

function Alien:GetHasOneHive()
    return self.oneHive
end

function Alien:GetHasTwoHives()
    return self.twoHives
end

function Alien:GetHasThreeHives()
    return self.threeHives
end

-- Return the player's upgrade level and team's upgrade level
function Alien:GetUpgradeLevel(upgradeIndexName)
    local playerLevel = 0
    local teamLevel = 0

    local teamInfo = GetTeamInfoEntity(self:GetTeamNumber())
    if teamInfo then
        teamLevel = teamInfo[upgradeIndexName] or 0
        playerLevel = teamLevel
    end

    return playerLevel, teamLevel
end

function Alien:GetVeilLevel()
    return self:GetUpgradeLevel( "veilLevel" )
end

function Alien:GetSpurLevel()
    return self:GetUpgradeLevel( "spurLevel" )
end

function Alien:GetShellLevel()
    return self:GetUpgradeLevel( "shellLevel" )
end

-- For special ability, return an array of totalPower, minimumPower, tex x offset, tex y offset,
-- visibility (boolean), command name
function Alien:GetAbilityInterfaceData()
    return { }
end

local function CalcEnergy(self, rate)
    local dt = Shared.GetTime() - self.timeAbilityEnergyChanged
    local result = Clamp(self.abilityEnergyOnChange + dt * rate, 0, self:GetMaxEnergy())
    return result
end

--[[
    NOTE(Salads): About method of alien energy

    If we were to use just a real-time value of energy, for example "45.29 energy" as a netvar,
    it would cause silent bites on client side when at extremely low energy levels, since the client's
    energy value will lag behind the server's... so the client thinks it doesn't have enough energy, when
    the Server it actually does, so no bite animation, but wall decal/sound still plays due to the network message
    sent from Server. Other people watching the biting skulk won't experience this since they only get it as a
    server message anyhow.

    By using "time" values that don't change that often, we're much more caught-up since we calculate the energy instead.
    Also, network bandwidth is reduced. However, when the alien's energy recuperation rate is changed, the client can still
    see a jitter in th energy bar as we receive the new regen rate from the server. (It depends on netvars as well)
--]]
function Alien:GetEnergy()
    local rate = self:GetRecuperationRate()
    if self.lastEnergyRate ~= rate then
        -- we assume we ask for energy enough times that the change in energy rate
        -- will hit on the same tick they occure (or close enough)
        self.abilityEnergyOnChange = CalcEnergy(self, self.lastEnergyRate)
        self.timeAbilityEnergyChanged = Shared.GetTime()
    end
    self.lastEnergyRate = rate
    return CalcEnergy(self, rate)
end

function Alien:AddEnergy(energy)
    assert(energy >= 0)
    self.abilityEnergyOnChange = Clamp(self:GetEnergy() + energy, 0, self:GetMaxEnergy())
    self.timeAbilityEnergyChanged = Shared.GetTime()
end

function Alien:SetEnergy(energy)
    self.abilityEnergyOnChange = Clamp(energy, 0, self:GetMaxEnergy())
    self.timeAbilityEnergyChanged = Shared.GetTime()
end

function Alien:DeductAbilityEnergy(energyCost)

    if not self:GetDarwinMode() then

        local maxEnergy = self:GetMaxEnergy()

        self.abilityEnergyOnChange = Clamp(self:GetEnergy() - energyCost, 0, maxEnergy)
        self.timeAbilityEnergyChanged = Shared.GetTime()

    end

end

function Alien:GetLifeformEnergyRechargeRate()

    if not self.hasAdrenalineUpgrade then
        return Alien.kEnergyRecuperationRate
    end

    local spurLevelFactor = self:GetSpurLevel() / 3
    local adrenalineRechargeRate = self:GetAdrenalineEnergyRechargeRate()
    local finalRate = adrenalineRechargeRate * spurLevelFactor + Alien.kEnergyRecuperationRate * (1.0 - spurLevelFactor)
    return finalRate

end

function Alien:GetRecuperationRate()

    local scalar = ConditionalValue(self:GetGameEffectMask(kGameEffect.OnFire), kOnFireEnergyRecuperationScalar, 1)
    scalar = scalar * (self.electrified and kElectrifiedEnergyRecuperationScalar or 1)

    local rate = self:GetLifeformEnergyRechargeRate()
    rate = rate * scalar

    return rate

end

function Alien:OnGiveUpgrade(techId)
end

function Alien:GetMaxEnergy()
    return kAbilityMaxEnergy
end

function Alien:GetAdrenalineEnergyRechargeRate()
    return Alien.kEnergyRecuperationRate
end

function Alien:GetMaxBackwardSpeedScalar()
    return Alien.kWalkBackwardSpeedScalar
end

-- for marquee selection
function Alien:GetIsMoveable()
    return false
end

function Alien:SetDarkVision(state)
    self.darkVisionOn = state
    self.darkVisionSpectatorOn = state
end

function Alien:GetControllerPhysicsGroup()

    if self.isHallucination then
        return PhysicsGroup.SmallStructuresGroup
    end

    return Player.GetControllerPhysicsGroup(self)

end

function Alien:GetHallucinatedClientIndex()
    return self.hallucinatedClientIndex
end

function Alien:SetHallucinatedClientIndex(clientIndex)
    self.hallucinatedClientIndex = clientIndex
end

function Alien:HandleButtons(input)

    PROFILE("Alien:HandleButtons")

    Player.HandleButtons(self, input)

    -- Update alien movement ability
    local newMovementState = bit.band(input.commands, Move.MovementModifier) ~= 0
    if newMovementState ~= self.movementModiferState and self.movementModiferState ~= nil then
        self:MovementModifierChanged(newMovementState, input)
    end

    self.movementModiferState = newMovementState

    if self:GetCanControl() and (Client or Server) then

        local darkVisionPressed = bit.band(input.commands, Move.ToggleFlashlight) ~= 0
        if not self.darkVisionLastFrame and darkVisionPressed then
            self:SetDarkVision(not self.darkVisionOn)
        end

        self.darkVisionLastFrame = darkVisionPressed

    end

end

function Alien:GetIsCamouflaged()
    return GetHasCamouflageUpgrade(self) --and not self:GetIsInCombat()
end

function Alien:GetNotEnoughResourcesSound()
    return AlienkNotEnoughResourcesSound
end

-- Returns true when players are selecting new abilities. When true, draw small icons
-- next to your current weapon and force all abilities to draw.
function Alien:GetInactiveVisible()
    return Shared.GetTime() < self:GetTimeOfLastWeaponSwitch() + kDisplayWeaponTime
end

--
-- Must override.
--
function Alien:GetBaseArmor()
    assert(false)
end

function Alien:GetBaseHealth()
    assert(false)
end

function Alien:GetHealthPerBioMass()
    assert(false)
end

function Alien:GetArmorFullyUpgradedAmount()
    local teamEnt = GetGamerules():GetTeam(kTeam2Index)
    if teamEnt then

        -- TODO(Salads): There really should be a constant global for "12"...
        return self:GetBaseArmor() + self:GetBaseCarapaceArmorBuff() + (self:GetCarapaceBonusPerBiomass() * 12)

    end

    return 0
end

function Alien:GetCanBeHealedOverride()
    return self:GetIsAlive()
end

function Alien:MovementModifierChanged(newMovementModifierState, input)
end

--
-- Aliens cannot climb ladders.
--
function Alien:GetCanClimb()
    return false
end

function Alien:GetChatSound()
    return AlienkChatSound
end

function Alien:GetDeathMapName()
    return AlienSpectator.kMapName
end

-- Returns the name of the player's lifeform
function Alien:GetPlayerStatusDesc()

    local status = kPlayerStatus.Void

    if (self:GetIsAlive() == false) then
        status = kPlayerStatus.Dead
    else
        if (self:isa("Embryo")) then
            if self.gestationTypeTechId == kTechId.Skulk then
                status = kPlayerStatus.SkulkEgg
            elseif self.gestationTypeTechId == kTechId.Gorge then
                status = kPlayerStatus.GorgeEgg
            elseif self.gestationTypeTechId == kTechId.Lerk then
                status = kPlayerStatus.LerkEgg
            elseif self.gestationTypeTechId == kTechId.Fade then
                status = kPlayerStatus.FadeEgg
            elseif self.gestationTypeTechId == kTechId.Onos then
                status = kPlayerStatus.OnosEgg
            else
                status = kPlayerStatus.Embryo
            end
        else
            status = kPlayerStatus[self:GetClassName()]
        end
    end

    return status

end

function Alien:OnCatalyst()
end

function Alien:OnCatalystEnd()
end

function Alien:GetCanTakeDamageOverride()
    return Player.GetCanTakeDamageOverride(self)
end

function Alien:GetEffectParams(tableParams)

    tableParams[kEffectFilterSilenceUpgrade] = self.silenceLevel == 3
    tableParams[kEffectParamVolume] = 1 - Clamp(self.silenceLevel / 3, 0, 1)

end

function Alien:GetIsEnzymed()
    return self.enzymed
end

-- @return true if enzyme was cleared
function Alien:ClearEnzyme()
    local rval = (self.enzymed == true)

    if Server then
        self.timeWhenEnzymeExpires = 0 -- Expire with zero. Shared.GetTime at this point will cause harmonic oscillation under constant electrify effect
    end

    self.enzymed = false

    return rval
end

function Alien:OnUpdateAnimationInput(modelMixin)

    Player.OnUpdateAnimationInput(self, modelMixin)

    local attackSpeed = self:GetIsEnzymed() and kEnzymeAttackSpeed or kDefaultAttackSpeed
    attackSpeed = attackSpeed * ( self.electrified and kElectrifiedAttackSpeed or 1 )
    if self.ModifyAttackSpeed then

        local attackSpeedTable = { attackSpeed = attackSpeed }
        self:ModifyAttackSpeed(attackSpeedTable)
        attackSpeed = attackSpeedTable.attackSpeed

    end

    modelMixin:SetAnimationInput("attack_speed", attackSpeed)

end

function Alien:GetHasMovementSpecial()
    return false
end

function Alien:ModifyHeal(healTable)

    if self.isOnFire then
        healTable.health = healTable.health * kOnFireHealingScalar
    end

end

-- %%% New CBM Functions %%% --
function Alien:GetIsStormed()
    return self.stormed
end

function Alien:GetRecuperationRate()
    local scalar = ConditionalValue(self:GetGameEffectMask(kGameEffect.OnFire), kOnFireEnergyRecuperationScalar, 1)
    scalar = scalar * (self.electrified and kElectrifiedEnergyRecuperationScalar or 1)

    local canHaveResilienceBoost = self:GetHasUpgrade(kTechId.Resilience) and Shared.GetTime() < self.resilienceTimeEnd
    local shellCount = self:GetShellLevel()
    scalar = scalar * ConditionalValue(canHaveResilienceBoost, 1 + ((1.25 / 3) * shellCount), 1)

    local rate = self:GetLifeformEnergyRechargeRate()
    rate = rate * scalar

    return rate
end

Shared.LinkClassToMap("Alien", Alien.kMapName, networkVars, true)
