-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Hive.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CloakableMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/CommandStructure.lua")
Script.Load("lua/InfestationMixin.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/CatalystMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/DouseMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/MaturityMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/TeleportMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/BiomassMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/AlienStructureVariantMixin.lua")
Script.Load("lua/RailgunTargetMixin.lua")
Script.Load("lua/BlowtorchTargetMixin.lua")

class 'Hive' (CommandStructure)

local networkVars =
{
    extendAmount = "float (0 to 1 by 0.01)",
    bioMassLevel = "integer (0 to 6)",
    evochamberid = "entityid",
	electrified = "boolean",
}

AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(CatalystMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(DouseMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(MaturityMixin, networkVars)
AddMixinNetworkVars(TeleportMixin, networkVars)
AddMixinNetworkVars(HiveVisionMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(AlienStructureVariantMixin, networkVars)

kResearchToHiveType =
{
    [kTechId.UpgradeToCragHive] = kTechId.CragHive,
    [kTechId.UpgradeToShadeHive] = kTechId.ShadeHive,
    [kTechId.UpgradeToShiftHive] = kTechId.ShiftHive,
}

Hive.kMapName = "hive"

local precached = PrecacheAsset("cinematics/vfx_materials/hive_frag.surface_shader")

Hive.kModelName = PrecacheAsset("models/alien/hive/hive.model")
local kAnimationGraph = PrecacheAsset("models/alien/hive/hive.animation_graph")


local kWoundSound = PrecacheAsset("sound/NS2.fev/alien/structures/hive_wound")
-- Play special sound for players on team to make it sound more dramatic or horrible
local kWoundAlienSound = PrecacheAsset("sound/NS2.fev/alien/structures/hive_wound_alien")

-- used by Hive_Client
Hive.kIdleMistEffect = PrecacheAsset("cinematics/alien/hive/idle_mist.cinematic")
local kL2IdleMistEffect = PrecacheAsset("cinematics/alien/hive/idle_mist_lev2.cinematic")
local kL3IdleMistEffect = PrecacheAsset("cinematics/alien/hive/idle_mist_lev3.cinematic")
--Hive.kGlowEffect = PrecacheAsset("cinematics/alien/hive/glow.cinematic")

-- used by Hive_Client
Hive.kSpecksEffect = PrecacheAsset("cinematics/alien/hive/specks.cinematic")
local kSpecksEffectAbyss = PrecacheAsset("cinematics/alien/hive/specks_abyss.cinematic")
local kSpecksEffectKodiak = PrecacheAsset("cinematics/alien/hive/specks_kodiak.cinematic")
local kSpecksEffectReaper = PrecacheAsset("cinematics/alien/hive/specks_reaper.cinematic")
local kSpecksEffectNocturne = PrecacheAsset("cinematics/alien/hive/specks_nocturne.cinematic")
local kSpecksEffectUnearthed = PrecacheAsset("cinematics/alien/hive/specks_unearthed.cinematic")
local kSpecksEffectToxin = PrecacheAsset("cinematics/alien/hive/specks_catpack.cinematic")
local kSpecksEffectShadow = PrecacheAsset("cinematics/alien/hive/specks_shadow.cinematic")
local kSpecksEffectAuric = PrecacheAsset("cinematics/alien/hive/specks_auric.cinematic")

local kCompleteSound = PrecacheAsset("sound/NS2.fev/alien/voiceovers/hive_complete")
local kUnderAttackSound = PrecacheAsset("sound/NS2.fev/alien/voiceovers/hive_under_attack")
local kDyingSound = PrecacheAsset("sound/NS2.fev/alien/voiceovers/hive_dying")

Hive.kHealRadius = 12.7     -- From NS1
Hive.kHealthPercentage = .08
Hive.kHealthUpdateTime = 1

if Server then
    Script.Load("lua/Hive_Server.lua")
elseif Client then
    Script.Load("lua/Hive_Client.lua")
end

function Hive:OnCreate()

    CommandStructure.OnCreate(self)
    
    InitMixin(self, CloakableMixin)
    InitMixin(self, FireMixin)
    InitMixin(self, CatalystMixin)
    InitMixin(self, UmbraMixin)
	InitMixin(self, DouseMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, MaturityMixin)
    InitMixin(self, TeleportMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, BiomassMixin)
    
    self.extendAmount = 0

    if Server then

        self.biomassResearchFraction = 0

        self.cystChildren = { }

        self.lastImpulseFireTime = Shared.GetTime()

        self.timeOfLastEgg = Shared.GetTime()

        -- when constructed first level is added automatically
        self.bioMassLevel = 0

        -- init this to -1, otherwise it defaults to 0 between OnCreate() and OnInitialized()
        self.evochamberid = -1

        self.timeLastReceivedARCDamage = 0

        self:UpdateIncludeRelevancyMask()
		
		self.electrified = false
		self.timeElectrifyEnds = 0

    elseif Client then
        -- For mist creation
        self:SetUpdates(true, kDefaultUpdateRate)
		InitMixin(self, RailgunTargetMixin)
		InitMixin(self, BlowtorchTargetMixin)
    end
    
end

function Hive:OnInitialized()

    InitMixin(self, InfestationMixin)
    
    CommandStructure.OnInitialized(self)

    -- Pre-compute list of egg spawn points.
    if Server then
        
        self:SetModel(Hive.kModelName, kAnimationGraph)
        
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)

        local evochamber = CreateEntity( "evolutionchamber", self:GetOrigin(), self:GetTeamNumber())
        self.evochamberid = evochamber:GetId()
        evochamber:SetOwner( self )
        
    elseif Client then
        
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
        self.glowIntensity = ConditionalValue(self:GetIsBuilt(), 1, 0)
        
    end
    
    InitMixin(self, IdleMixin)
    
    --Must be init'd last
    if not Predict then
        self.setupStructureEffects = false
        self.startSpecsTime = Shared.GetTime() + 5 --delay so network data can propagate
        InitMixin(self, AlienStructureVariantMixin)
    end

end

local kSpecksSkinMap = 
{
    [kAlienStructureVariants.Default] = Hive.kSpecksEffect,
    [kAlienStructureVariants.Abyss] = kSpecksEffectAbyss,
    [kAlienStructureVariants.Reaper] = kSpecksEffectReaper,
    [kAlienStructureVariants.Kodiak] = kSpecksEffectKodiak,
    [kAlienStructureVariants.Toxin] = kSpecksEffectToxin,
    [kAlienStructureVariants.Nocturne] = kSpecksEffectNocturne,
    [kAlienStructureVariants.Shadow] = kSpecksEffectShadow,
    [kAlienStructureVariants.Unearthed] = kSpecksEffectUnearthed,
    [kAlienStructureVariants.Auric] = kSpecksEffectAuric,
}
function Hive:UpdateStructureEffects()

    if Client and not self.setupStructureEffects and Shared.GetTime() > self.startSpecsTime then
    -- Create glowy "plankton" swimming around hive, along with mist and glow
        local coords = self:GetCoords()
        local specksFile = kSpecksSkinMap[self.structureVariant]

        self:AttachEffect(specksFile, coords)
        --self:AttachEffect(Hive.kGlowEffect, coords, Cinematic.Repeat_Loop)
        self.setupStructureEffects = true
    end

end

local kHelpArrowsCinematicName = PrecacheAsset("cinematics/alien/commander_arrow.cinematic")
local precached = PrecacheAsset("models/misc/commander_arrow_aliens.model")

if Client then

    function Hive:GetHelpArrowsCinematicName()
        return kHelpArrowsCinematicName
    end
    
end

function Hive:GetEvolutionChamber()
    return Shared.GetEntity( self.evochamberid )
end

function Hive:SetIncludeRelevancyMask(includeMask)
    
    includeMask = bit.bor(includeMask, kRelevantToTeam2Commander)
    CommandStructure.SetIncludeRelevancyMask(self, includeMask)
    
    -- make evolution chamber relevant whenever hive is relevant.
    local evoChamber = self:GetEvolutionChamber()
    if evoChamber then
        evoChamber:SetIncludeRelevancyMask(includeMask)
    end
    
end

function Hive:GetMaturityRate()
    return kHiveMaturationTime
end

function Hive:GetMatureMaxHealth()
    return kMatureHiveHealth + kHiveHealthPerBioMass*(self.bioMassLevel - 1)
end 

function Hive:GetMatureMaxArmor()
    return kMatureHiveArmor + kHiveArmorPerBioMass*(self.bioMassLevel - 1)
end

function Hive:GetInfestationMaxRadius()
    return kHiveInfestationRadius
end

function Hive:GetMatureMaxEnergy()
    return kMatureHiveMaxEnergy
end

function Hive:OnCollision(entity)

    -- We may hook this up later.
    --[[
    -- if entity:isa("Player") and GetEnemyTeamNumber(self:GetTeamNumber()) == entity:GetTeamNumber() then
    --  self.lastTimeEnemyTouchedHive = Shared.GetTime()
    -- end
     ]]
end

function GetIsHiveTypeResearch(techId)
    return techId == kTechId.UpgradeToCragHive or techId == kTechId.UpgradeToShadeHive or techId == kTechId.UpgradeToShiftHive
end

function GetHiveTypeResearchAllowed(self, techId)
    
    local hiveTypeTechId = kResearchToHiveType[techId]
    return not GetHasTech(self, hiveTypeTechId) and not GetIsTechResearching(self, techId)

end

function Hive:GetInfestationRadius()
    return kHiveInfestationRadius
end

function Hive:GetCystParentRange()
    return kHiveCystParentRange
end

function Hive:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = CommandStructure.GetTechAllowed(self, techId, techNode, player)

    if techId == kTechId.ResearchBioMassTwo then
        allowed = allowed and self.bioMassLevel == 2
    elseif techId == kTechId.ResearchBioMassThree then
        allowed = allowed and self.bioMassLevel == 3
    elseif techId == kTechId.ResearchBioMassFour then
        allowed = allowed and self.bioMassLevel == 4
    end
    
    return allowed, canAfford
    
end

function Hive:GetBioMassLevel()
    return self.bioMassLevel * kHiveBiomass
end

function Hive:GetCanResearchOverride(techId)

    local allowed = true

    if GetIsHiveTypeResearch(techId) then
        allowed = GetHiveTypeResearchAllowed(self, techId)
    end
    
    return allowed and GetIsUnitActive(self)

end

function Hive:GetTechButtons()

    local techButtons = { kTechId.ShiftHatch, kTechId.None, kTechId.None, kTechId.LifeFormMenu,
                          kTechId.None, kTechId.None, kTechId.None, kTechId.None }

    local techId = self:GetTechId()
    if techId == kTechId.Hive then
        techButtons[5] = ConditionalValue(GetHiveTypeResearchAllowed(self, kTechId.UpgradeToCragHive), kTechId.UpgradeToCragHive, kTechId.None)
        techButtons[6] = ConditionalValue(GetHiveTypeResearchAllowed(self, kTechId.UpgradeToShadeHive), kTechId.UpgradeToShadeHive, kTechId.None)
        techButtons[7] = ConditionalValue(GetHiveTypeResearchAllowed(self, kTechId.UpgradeToShiftHive), kTechId.UpgradeToShiftHive, kTechId.None)
    elseif techId == kTechId.CragHive then
        techButtons[5] = kTechId.DrifterRegeneration
        techButtons[6] = kTechId.CystCarapace
    elseif techId == kTechId.ShiftHive then
        techButtons[5] = kTechId.DrifterCelerity
        techButtons[6] = kTechId.CystCelerity
    elseif techId == kTechId.ShadeHive then
        techButtons[5] = kTechId.DrifterCamouflage
        techButtons[6] = kTechId.CystCamouflage
    end
    
    if self.bioMassLevel <= 1 then
        techButtons[2] = kTechId.ResearchBioMassOne
    elseif self.bioMassLevel <= 2 then
        techButtons[2] = kTechId.ResearchBioMassTwo
    elseif self.bioMassLevel <= 3 then
        techButtons[2] = kTechId.ResearchBioMassThree
    elseif self.bioMassLevel <= 4 then
        techButtons[2] = kTechId.ResearchBioMassFour
    end
    
    return techButtons
    
end

function Hive:OnSighted(sighted)

    if sighted then
        local techPoint = self:GetAttached()
        if techPoint then
            techPoint:SetSmashScouted()
        end    
    end
    
    CommandStructure.OnSighted(self, sighted)

end

function Hive:GetHealthbarOffset()
    return 0.8
end 

-- Don't show objective after we become cloaked
function Hive:OnCloak()

    local attached = self:GetAttached()
    if attached then
        attached.showObjective = false
    end
    
end

function Hive:OverrideVisionRadius()
    return 20
end

function Hive:OnUpdatePoseParameters()
    self:SetPoseParam("extend", self.extendAmount)
end

--[[
 * Return true if a connected cyst parent is availble at the given origin normal. 
]]
function GetTechPointInfested(techId, origin)

    local attachEntity = GetNearestFreeAttachEntity(techId, origin, kStructureSnapRadius)
    
    return attachEntity and attachEntity:GetGameEffectMask(kGameEffect.OnInfestation)
    
end

-- return a good spot from which a player could have entered the hive
-- used for initial entry point for the commander
function Hive:GetDefaultEntryOrigin()
    return self:GetOrigin() + Vector(2,0,2)
end

function Hive:GetInfestationBlobMultiplier()
    return 5
end

function Hive:SetElectrified(time)

    if self.timeElectrifyEnds - Shared.GetTime() < time then

        self.timeElectrifyEnds = Shared.GetTime() + time
        self.electrified = true

    end

end

function Hive:GetElectrified()
    return self.electrified
end

Shared.LinkClassToMap("Hive", Hive.kMapName, networkVars)

class 'CragHive' (Hive)
CragHive.kMapName = "crag_hive"
Shared.LinkClassToMap("CragHive", CragHive.kMapName, { })

class 'ShadeHive' (Hive)
ShadeHive.kMapName = "shade_hive"
Shared.LinkClassToMap("ShadeHive", ShadeHive.kMapName, { })

class 'ShiftHive' (Hive)
ShiftHive.kMapName = "shift_hive"
Shared.LinkClassToMap("ShiftHive", ShiftHive.kMapName, { })