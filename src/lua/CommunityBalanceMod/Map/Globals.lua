-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Globals.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Utility.lua")
Script.Load("lua/GUIAssets.lua")
Script.Load("lua/ItemUtils.lua")
Script.Load("lua/IterableDict.lua")

-- How often should Entity.OnUpdate be run
kRealTimeUpdateRate = 0
kDefaultUpdateRate = 0.1 --1/10.0
if Server then
    kDefaultUpdateRate = 0.25 -- 1/4
end

kBotAccWeaponGroup = enum(
{
    "Bullets",
    "ExoMinigun",
    "ExoRailgun",
    "Melee",
    "BiteLeap",
    "LerkSpikes",
    "LerkBite",
    "Parasite",
    "Spit",
    "Swipe"
})

kBotDebugSection = enum(
{
    "ActionWeight",
    "BotAccuracy",
    "BotAim",
})

kMaxPlayerSkill = 3000
kMaxPlayerLevel = 300

kSuicideDelay = 6

kDecalMaxLifetime = 60

-- All the layouts are based around this screen height.
kBaseScreenHeight = 1080

kDefaultRenderMask = 0x01
kHiveVisionRenderMask = 0x02
kEquipmentOutlineRenderMask = 0x04
kCustomizeSceneRenderMask = 0x08

-- Team types - corresponds with teamNumber in editor_setup.xml
kNeutralTeamType = 0
kMarineTeamType = 1
kAlienTeamType = 2
kRandomTeamType = 3

-- only allow reseting the game in the first 3 minutes
-- after 7 minutes players are allowed to give up a round
-- was 5 minutes prior to Feb 07, 2013 (bumped to 10 for an unknown reason)
-- was 10 minutes prior to Nov 08, 2014 (decreased to 7 because many games are over by the time fades come out and were using the resetgame vote to get around this)
kMaxTimeBeforeReset = 3 * 60
kMinTimeBeforeConcede = 3 * 60
kPercentNeededForVoteConcede = 0.75

-- Team colors
kMarineFontName = Fonts.kAgencyFB_Large
kMarineFontColor = Color(0.756, 0.952, 0.988, 1)

kAlienFontName = Fonts.kAgencyFB_Large
kAlienFontColor = Color(0.901, 0.623, 0.215, 1)

kNeutralFontName = Fonts.kAgencyFB_Large
kNeutralFontColor = Color(0.7, 0.7, 0.7, 1)

kSteamFriendColor = Color(1, 1, 1, 1)

-- Move hit effect slightly off surface we hit so particles don't penetrate. In meters.
kHitEffectOffset = 0.13
-- max distance of blood from impact point to nearby geometry
kBloodDistance = 3.5

kMaxTracerLifetime = 2.0

kCommanderPingDuration = 15

kCommanderColor = 0xFFFF00
kCommanderColorFloat = Color(1,1,0,1)
kMarineTeamColor = 0x4DB1FF
kMarineTeamColorFloat = Color(0.302, 0.859, 1)
kAlienTeamColor = 0xFFCA3A
kAlienTeamColorFloat = Color(1, 0.792, 0.227)
kNeutralTeamColor = 0xEEEEEE
kChatPrefixTextColor = 0xFFFFFF
kChatTextColor = { [kNeutralTeamType] = kNeutralFontColor,
    [kMarineTeamType] = kMarineFontColor,
    [kAlienTeamType] = kAlienFontColor }
kNewPlayerColor = 0x00DC00
kNewPlayerColorFloat = Color(0, 0.862, 0, 1)
kChatTypeTextColor = 0xDD4444
kFriendlyColor = 0xFFFFFF
kNeutralColor = 0xAAAAFF
kEnemyColor = 0xFF0000
kParasitedTextColor = 0xFFEB7F

kParasiteColor = Color(1, 1, 0, 1)
kPoisonedColor = Color(0, 1, 0, 1)

kCountDownLength = 6
kTunnelLength = 27

-- Team numbers and indices
kTeamInvalid = -1
kTeamReadyRoom = 0
kTeam1Index = 1
kTeam2Index = 2
kSpectatorIndex = 3
kTeamIndexMax = kSpectatorIndex

-- Marines vs. Aliens
kTeam1Type = kMarineTeamType
kTeam2Type = kAlienTeamType

-- Used for playing team and scoreboard
kTeam1Name = "Frontiersmen"
kTeam2Name = "Kharaa"
kSpectatorTeamName = "Ready room"
kDefaultPlayerName = "NSPlayer"

kDefaultWaypointGroup = "GroundWaypoints"
kAirWaypointsGroup = "AirWaypoints"

kMaxResources = 200

kWorldMessageLifeTime = 1.0
kCommanderErrorMessageLifeTime = 2.0
kWorldMessageResourceOffset = Vector(0, 2.5, 0)
kResourceMessageRange = 35
kWorldDamageNumberAnimationSpeed = 800
-- Updating messages with new numbers shouldn't reset animation - keep it big and faded-in intead of growing
kWorldDamageRepeatAnimationScalar = .1

-- Max player name
kMaxNameLength = 20
kMaxScore = 9999
kMaxKills = 254
kMaxDeaths = 254
kMaxPing = 999

kMaxChatLength = 120

kMaxHotkeyGroups = 9

kBotGuardMaxAFKTime = 10 -- Max time for Bots to "guard" a human player


--Command Structure in danger music params
kDangerMusicCheckEndDistance = 35
kDangerMusicCheckStartDistance = 25
kDangerMusicHealthEndAmount = 0.6
kDangerMusicHealthStartAmount = 0.5
kDangerMusicMinDelayTime = 3.25


-- Surface list. Add more materials here to precache ricochets, bashes, footsteps, etc
-- Used with PrecacheMultipleAssets
kSurfaceList = { "door", "electronic", "metal", "organic", "rock", "thin_metal", "membrane", "armor", "flesh", "flame", "infestation", "glass" }
kSurfaces = enum(kSurfaceList)

-- a longer surface list, for hiteffects only (used by hiteffects network message, don't remove any values)
kHitEffectSurface = enum( { "metal", "door", "electronic", "organic", "rock", "thin_metal", "membrane", "armor", "flesh", "flame", "infestation", "glass", "ethereal", "flame", "hallucination", "umbra", "nanoshield", "robot" } )
kHitEffectRelevancyDistance = 40
kHitEffectMaxPosition = 1638 -- used for precision in hiteffect message
kTracerSpeed = 115
kMaxHitEffectsPerSecond = 25

kPlayerStatus = enum( { "Hidden", "Dead", "Evolving", "Embryo", "Commander", "Exo", "GrenadeLauncher", "Rifle", "HeavyMachineGun", "Shotgun", "Flamethrower", "Void", "Spectator", "Skulk", "Gorge", "Fade", "Lerk", "Onos", "SkulkEgg", "GorgeEgg", "FadeEgg", "LerkEgg", "OnosEgg" } )
kPlayerCommunicationStatus = enum( {'None', 'Voice', 'Typing', 'Menu'} )
kSpectatorMode = enum( { 'FreeLook', 'Overhead', 'Following', 'FirstPerson', 'KillCam' } )

kMaxAlienAbilities = 3

kDefaultSensitivity = 2.5

kNoWeaponSlot = 0
-- Weapon slots (marine only). Alien weapons use just regular numbers.
kPrimaryWeaponSlot = 1
kSecondaryWeaponSlot = 2
kTertiaryWeaponSlot = 3

-- How long to display weapon picker after selecting weapons
kDisplayWeaponTime = 1.5

-- Death message indices
kDeathMessageIcon = enum( { 'None',
    'Rifle', 'RifleButt', 'Pistol', 'Axe', 'Shotgun',
    'Flamethrower', 'ARC', 'Grenade', 'Sentry', 'Welder',
    'Bite', 'HydraSpike', 'Spray', 'Spikes', 'Parasite',
    'SporeCloud', 'Swipe', 'BuildAbility', 'Whip', 'BileBomb',
    'Mine', 'Gore', 'Spit', 'Jetpack', 'Claw',
    'Minigun', 'Vortex', 'LerkBite', 'Umbra',
    'Xenocide', 'Blink', 'Leap', 'Stomp',
    'Consumed', 'GL', 'Recycled', 'Babbler', 'Railgun', 'BabblerAbility', 'GorgeTunnel', 'BoneShield',
    'ClusterGrenade', 'GasGrenade', 'PulseGrenade', 'Stab', 'WhipBomb', 'Metabolize', 'Crush', 'EMPBlast', 'HeavyMachineGun'
} )

kMinimapBlipType = enum( { 'Undefined', 'TechPoint', 'ResourcePoint', 'Scan', 'EtherealGate', 'HighlightWorld',
    'Sentry', 'CommandStation',
    'Extractor', 'InfantryPortal', 'Armory', 'AdvancedArmory', 'PhaseGate', 'Observatory',
    'RoboticsFactory', 'ArmsLab', 'PrototypeLab',
    'Hive', 'Harvester', 'Hydra', 'Egg', 'Embryo', 'Crag', 'Whip', 'Shade', 'Shift', 'Shell', 'Veil', 'Spur', 'TunnelEntrance', 'BoneWall',
    'Marine', 'JetpackMarine', 'Exo', 'Skulk', 'Lerk', 'Onos', 'Fade', 'Gorge',
    'Door', 'PowerPoint', 'DestroyedPowerPoint', 'UnsocketedPowerPoint',
    'BlueprintPowerPoint', 'ARC', 'Drifter', 'MAC', 'Infestation', 'InfestationDying', 'MoveOrder', 'AttackOrder', 'BuildOrder', 'SensorBlip', 'SentryBattery' } )

-- Friendly IDs
-- 0 = friendly
-- 1 = enemy
-- 2 = neutral
-- for spectators is used Marine and Alien
kMinimapBlipTeam = enum( {'Friendly', 'Enemy', 'Neutral', 'Alien', 'Marine', 'FriendAlien', 'FriendMarine', 'InactiveAlien', 'InactiveMarine' } )

-- How long commander alerts should last (from NS1)
kAlertExpireTime = 20

-- Bit mask table for non-stackable game effects. OnInfestation is set if we're on ANY infestation (regardless of team).
-- Always keep "Max" as last element.
kGameEffects = {"InUmbra", "Fury", "Cloaked", "Parasite", "NearDeath", "OnFire", "OnInfestation", "Beacon", "Energize" }
kGameEffect = CreateBitMask( kGameEffects )
kGameEffectMax = bit.lshift( 1, #kGameEffects )

-- Stackable game effects (more than one can be active, server-side only)
kFuryGameEffect = "fury"
kMaxStackLevel = 10

kMaxEntityStringLength = 32
kMaxAnimationStringLength = 32

kHasTechResult = enum({ 'None', 'NotStarted', 'InProgressOrUnbuilt', 'HasTech' })

-- Contention state for a Location entity
---@class kLocationState
---@field Neutral
---@field Marine
---@field Alien
---@field Contested
kLocationState = enum({'Neutral', 'Marine', 'Alien', 'Contested'})

-- Player modes. When outside the default player mode, input isn't processed from the player
kPlayerMode = enum( {'Default', 'Taunt', 'Knockback', 'StandUp'} )

-- Team alert types
kAlertType = enum( {'Attack', 'Info', 'Request'} )

-- Dynamic light modes for power grid
kLightMode = enum( {'Normal', 'NoPower', 'LowPower', 'Damaged'} )

-- Game state
-- Everthing less than PreGame means the game has not started
kGameState = enum( {'NotStarted', 'WarmUp', 'PreGame', 'Countdown', 'Started', 'Team1Won', 'Team2Won', 'Draw'} )

-- Don't allow commander to build structures this close to attach points or other structures
kBlockAttachStructuresRadius = 3

-- Marquee while active, to ensure we get mouse release event even if on top of other component
kHighestPriorityZ = 3

-- How often to send kills, deaths, nick name changes, etc. for scoreboard
kScoreboardUpdateInterval = 1

-- How often to send ping updates to individual players
kUpdatePingsIndividual = 3

-- How often to send ping updates to all players.
kUpdatePingsAll = 10

kStructureSnapRadius = 4

-- Only send friendly blips down within this range
kHiveSightMaxRange = 50
kHiveSightMinRange = 3
kHiveSightDamageTime = 8

-- Bit masks for relevancy checking
kRelevantToTeam1Unit        = 1
kRelevantToTeam2Unit        = 2
kRelevantToTeam1Commander   = 4
kRelevantToTeam2Commander   = 8
kRelevantToTeam1            = bit.bor(kRelevantToTeam1Unit, kRelevantToTeam1Commander)
kRelevantToTeam2            = bit.bor(kRelevantToTeam2Unit, kRelevantToTeam2Commander)
kRelevantToReadyRoom        = 16

-- Hive sight constants
kBlipType = enum( {'Undefined', 'Friendly', 'FriendlyUnderAttack', 'Sighted', 'TechPointStructure', 'NeedHealing', 'FollowMe', 'Chuckle', 'Pheromone', 'Parasited' } )

kFeedbackURL = "http://getsatisfaction.com/unknownworlds/feedback/topics/new?product=unknownworlds_natural_selection_2&display=layer&style=idea&custom_css=http://www.unknownworlds.com/game_scripts/ns2/styles.css"

-- Used for menu on top of class (marine or alien buy menus or out of game menu)
kMenuFlashIndex = 2

-- Fade to black time (then to spectator mode)
kFadeToBlackTime = 2

-- Constant to prevent z-fighting
kZFightingConstant = 0.1

-- Any geometry or props with this name won't be drawn or affect commanders
kCommanderInvisibleGroupName = "CommanderInvisible"
kCommanderInvisibleVentsGroupName = "CommanderInvisibleVents"
kCommanderInvisibleNonCollisionGroupName = "CommanderInvisibleNonCollision"
-- Any geometry or props with this name will not support being built on top of
kCommanderNoBuildGroupName = "CommanderNoBuild"
kCommanderBuildGroupName = "CommanderBuild"

kSeasonalFallGroupName = "SeasonalFall"
kSeasonalFallExcludeGroupName = "SeasonalFallExclude"
kSeasonalFallCommanderInvisibleGroupName = "SeasonalFallCommanderInvisible"
kSeasonalFallNonCollisionGeometryGroupName = "SeasonalFallNonCollisionGeometry"

kSeasonalWinterGroupName = "SeasonalWinter"
kSeasonalWinterExcludeGroupName = "SeasonalWinterExclude"
kSeasonalWinterCommanderInvisibleGroupName = "SeasonalWinterCommanderInvisible"
kSeasonalWinterNonCollisionGeometryGroupName = "SeasonalWinterNonCollisionGeometry"

-- invisible and blocks all movement
kMovementCollisionGroupName = "MovementCollisionGeometry"
-- same as 'MovementCollisionGeometry'
kCollisionGeometryGroupName = "CollisionGeometry"
-- invisible, blocks anything default geometry would block
kInvisibleCollisionGroupName = "InvisibleGeometry"
-- visible and won't block anything
kNonCollisionGeometryGroupName = "NonCollisionGeometry"

kPathingLayerName = "Pathing"

-- Max players allowed in game
kMaxPlayers = 32

kMaxIdleWorkers = 127
kMaxPlayerAlerts = 127

-- Max distance to propagate entities with
kMaxRelevancyDistance = 40

kEpsilon = 0.0001

-- Weapon spawn height (for Commander dropping weapons)
kCommanderDropSpawnHeight = 0.08
kCommanderEquipmentDropSpawnHeight = 0.5

kInventoryIconsTexture = Textures.kInventoryIcons
kInventoryIconTextureWidth = 128
kInventoryIconTextureHeight = 64

-- Options keys
kNicknameOptionsKey = "nickname4"
kNicknameOverrideKey = "ns2distinctPersona"
kVisualDetailOptionsKey = "visualDetail"
kSoundInputDeviceOptionsKey = "sound/input-device"
kSoundOutputDeviceOptionsKey = "sound/output-device"
kSoundMuteWhenMinized = "sound/minimized-mute"
kSoundVolumeOptionsKey = "soundVolume"
kMusicVolumeOptionsKey = "musicVolume"
kVoiceVolumeOptionsKey = "voiceVolume"
kDisplayOptionsKey = "graphics/display/display"
kWindowModeOptionsKey = "graphics/display/window-mode"
kDisplayQualityOptionsKey = "graphics/display/quality"
kInvertedMouseOptionsKey = "input/mouse/invert"
kLastServerConnected = "lastConnectedServer"
kLastServerPassword  = "lastServerPassword"
kLastServerMapName  = "lastServerMapName"

kPhysicsGpuAccelerationKey = "physics/gpu-acceleration"
kGraphicsXResolutionOptionsKey = "graphics/display/x-resolution"
kGraphicsYResolutionOptionsKey = "graphics/display/y-resolution"
kAntiAliasingOptionsKey = "graphics/display/anti-aliasing-type"
kAmbientOcclusionOptionsKey = "graphics/display/ambient-occlusion3" -- '3' so it is a new setting, so it can default to the new ao.
kAtmosphericsOptionsKey = "graphics/display/atmospherics"
kShadowsOptionsKey = "graphics/display/shadows"
kShadowFadingOptionsKey = "graphics/display/shadow-fading"
kBloomOptionsKey = "graphics/display/bloom_new"
kAnisotropicFilteringOptionsKey = "graphics/display/anisotropic-filtering"
kColorBlindOptionsKey = "graphics/display/colorblind_mode"

kMouseSensitivityScalar         = 50

-- Player use range
kPlayerUseRange = 2
kMaxPitch = (math.pi / 2) - math.rad(3)

-- Pathing flags
kPathingFlags = enum ({'UnBuildable', 'UnPathable', 'Blockable'})

-- How far from the order location must units be to complete it.
kAIMoveOrderCompleteDistance = 0.01
kPlayerMoveOrderCompleteDistance = 1.5

-- Statistics
kStatisticsURL = "http://sponitor2.herokuapp.com/api/send"

kResourceType = enum( {'Team', 'Personal', 'Energy', 'Ammo'} )

kNameTagFontColors = { [kMarineTeamType] = kMarineFontColor,
    [kAlienTeamType] = kAlienFontColor,
    [kNeutralTeamType] = kNeutralFontColor }

kNameTagFontNames = { [kMarineTeamType] = kMarineFontName,
    [kAlienTeamType] = kAlienFontName,
    [kNeutralTeamType] = kNeutralFontName }

kHealthBarColors = { [kMarineTeamType] = Color(0.725, 0.921, 0.949, 1),
    [kAlienTeamType] = Color(0.776, 0.364, 0.031, 1),
    [kNeutralTeamType] = Color(1, 1, 1, 1) }
kHealthBarEnemyPlayerColor = Color(0.987, 0.067, 0.267, 1)

kHealthBarBgColors = { [kMarineTeamType] = Color(0.725 * 0.5, 0.921 * 0.5, 0.949 * 0.5, 1),
    [kAlienTeamType] = Color(0.776 * 0.5, 0.364 * 0.5, 0.031 * 0.5, 1),
    [kNeutralTeamType] = Color(1 * 0.5, 1 * 0.5, 1 * 0.5, 1) }
kHealthBarBgEnemyPlayerColor = Color(0.910 * 0.25, 0.067 * 0.25, 0.267 * 0.25, 1)

kRegenBarFriendlyColor = Color(0, 1.0, 0.129, 1)
kRegenBarEnemyColor = Color(1.0, 0.930, 0, 1 )

kArmorBarColors = { [kMarineTeamType] = Color(0.078, 0.878, 0.984, 1),
    [kAlienTeamType] = Color(0.576, 0.194, 0.011, 1),
    [kNeutralTeamType] = Color(0.5, 0.5, 0.5, 1) }
kArmorBarEnemyPlayerColor = Color(0.800, 0.627 , 0.0, 1)

kArmorBarBgColors = { [kMarineTeamType] = Color(0.078 * 0.5, 0.878 * 0.5, 0.984 * 0.5, 1),
    [kAlienTeamType] = Color(0.576 * 0.5, 0.194 * 0.5, 0.011 * 0.5, 1),
    [kNeutralTeamType] = Color(0.5 * 0.5, 0.5 * 0.5, 0.5 * 0.5, 1) }
--kArmorBarBgEnemyPlayerColor =  Color(0.408 * 0.25, 0.078 * 0.25, 0.157 * 0.25, 1)
kArmorBarBgEnemyPlayerColor =  Color(0.800 * 0.25, 0.627 * 0.25, 0.0 * 0.25, 1)

kAbilityBarColors = { [kMarineTeamType] = Color(0,1,1,1),
    [kAlienTeamType] = Color(1,1,0,1),
    [kNeutralTeamType] = Color(1, 1, 1, 1) }

kAbilityBarBgColors = { [kMarineTeamType] = Color(0, 0.5, 0.5, 1),
    [kAlienTeamType] = Color(0.5, 0.5, 0, 1),
    [kNeutralTeamType] = Color(0.5, 0.5, 0.5, 1) }

-- used for specific effects
kUseInterval = 0.1
kSeasonalThrowInterval = 0.2

kPlayerLOSDistance = 20
kStructureLOSDistance = 1.75

kGestateCameraDistance = 1.75

-- Rookie mode
kRookieOnlyLevel = 5 -- level with which players should only play on bootcamp servers
kRookieMaxSkillTier = 1 -- max skill tier players can have to play at a bottcamp server
kRookieLevel = 10 -- level with which players can play on bootcamp servers

kMinFOVAdjustmentDegrees = 0
kMaxFOVAdjustmentDegrees = 20

kDamageEffectType = enum({ 'Blood', 'AlienBlood', 'Sparks', 'Oil' })

kIconColors =
{
    [kMarineTeamType] = Color(0.8, 0.96, 1, 1),
    [kAlienTeamType] = Color(1, 0.9, 0.4, 1),
    [kNeutralTeamType] = Color(1, 1, 1, 1),
}

--Marine Flashlight Defaults
kDefaultMarineFlashlightColor = Color(0.78, 0.78, 0.67)
kDefaultMarineFlashlightAtmoDensity = 0.025

kDefaultLightsAtmoDensity = 0.15

------------------------------------------
--  DLC stuff
------------------------------------------
-- checks if client has the DLC, if a table is passed, the function returns true when the client owns at least one of the productIds
function GetHasDLC(productId, client)
    if productId == nil or productId == 0 then
        return true
    end

    local checkIds = {}
    if type(productId) == "table" then
        checkIds = productId
    else
        checkIds = { productId }
    end

    for i = 1, #checkIds do
        if Client then
            --assert(client ~= nil)
            return Client.GetIsDlcAuthorized(checkIds[i])
        elseif Server and client then
            assert(client ~= nil)
            local serverDlcAuth = Server.GetIsDlcAuthorized(client, checkIds[i])
            return serverDlcAuth
        end
    end

    return false
end

--Team Cosmetics Slots IDs
--These denote which cosmetic slot is set for what skin, of a given team. See GameInfo
kTeamCosmeticSlot1 = 1
kTeamCosmeticSlot2 = 2
kTeamCosmeticSlot3 = 3
kTeamCosmeticSlot4 = 4
kTeamCosmeticSlot5 = 5
kTeamCosmeticSlot6 = 6


kDlcStorePageBaseUrl = "https://store.steampowered.com/app/"
kBmacStorePageUrl = "https://store.steampowered.com/app/1183100/"
kPlusBmacBundleStorePageUrl = "https://store.steampowered.com/bundle/12582/"
kEliteBmacBundleStorePageUrl = "https://store.steampowered.com/bundle/12583/"

kSpecialEditionProductId        = 4930
kDeluxeEditionProductId         = 4932
kShadowProductId                = 250893

kUnpackTundraBundleItemId       = 10
kUnpackNocturneBundleItemId     = 11
kUnpackForgeBundleItemId        = 12
kUnpackBigMacBundleItemId       = 13
kUnpackBigMacBundle2ItemId      = 14
kUnpackBigMacBundle3ItemId      = 15
kUnpackKodiakBundleItemId       = 20
kUnpackReaperBundleItemId       = 30
kUnpackShadowBundleItemId       = 40
kUnpackAbyssBundleItemId        = 60
kUnpackCatalystBundleItemId     = 70

kBlackArmorItemId               = 9001

kTundraBundleItemId             = 100
kTundraArmorItemId              = 101
kTundraAxeItemId                = 106
kTundraWelderItemId             = 107
kTundraExosuitItemId            = 102
kTundraPistolItemId             = 112
kTundraRifleItemId              = 103
kTundraShotgunItemId            = 104
kTundraFlamethrowerItemId       = 108
kTundraGrenadeLauncherItemId    = 109
kTundraHMGItemId                = 110
kTundraShoulderPatchItemId      = 105
kTundraStructuresItemId         = 111

kKodiakBundleItemId             = 200
kKodiakArmorItemId              = 201
kKodiakExosuitItemId            = 202
kKodiakPistolItemId             = 218
kKodiakRifleItemId              = 203
kKodiakShotgunItemId            = 217
kKodiakShoulderPatchItemId      = 204
kKodiakAxeItemId                = 206
kKodiakWelderItemId             = 207
kKodiakFlamethrowerItemId       = 208
kKodiakGrenadeLauncherItemId    = 209
kKodiakHMGItemId                = 210
kKodiakMarineStructuresItemId   = 211

kKodiakSkulkItemId              = 205
kKodiakGorgeItemId              = 212
kKodiakLerkItemId               = 213
kKodiakFadeItemId               = 214
kKodiakOnosItemId               = 215
kKodiakTunnelItemId             = 216
kKodiakAlienStructuresItemId    = 216

kReaperBundleItemId             = 300
kReaperShoulderPatchItemId      = 301
kReaperSkulkItemId              = 302
kReaperGorgeItemId              = 303
kReaperLerkItemId               = 304
kReaperFadeItemId               = 305
kReaperOnosItemId               = 306
kReaperTunnelItemId             = 307
kReaperStructuresItemId         = 307

kEliteAssaultArmorItemId        = 401

kShadowBundleItemId             = 400
kShadowShoulderPatchItemId      = 402
kShadowSkulkItemId              = 403
kShadowGorgeItemId              = 404
kShadowLerkItemId               = 405
kShadowFadeItemId               = 406
kShadowOnosItemIds              = {407, 408}
--Note: these cannot be changed, otherwise original owner's of Shadow content won't get them
kShadowTunnelItemId             = 409
kShadowStructuresItemId         = 409

kDeluxeArmorItemId              = 501
kAssaultArmorItemId             = 502

kRedRifleItemId                 = 801
kDragonRifleItemId              = 10101
kGoldRifleItemId                = 10102
kViperPistolItemId              = 10104
kGoldPistolItemId               = 10105

kWoodAxeItemId                  = 10201 --
kWoodPistolItemId               = 10202 --
kWoodRifleItemId                = 10203 --

kDamascusAxeItemId              = 10301 --
kDamascusPistolItemId           = 10302 --
kDamascusRifleItemId            = 10303 --

kDamascusGreenAxeItemId         = 10401 --
kDamascusGreenPistolItemId      = 10402 --
kDamascusGreenRifleItemId       = 10403 --

kDamascusPurpleAxeItemId        = 10501 --
kDamascusPurplePistolItemId     = 10502 --
kDamascusPurpleRifleItemId      = 10503 --



-- ShoulderPatches
kReinforcedShoulderPatchItemId      = 503
kNS2WC14GlobeShoulderPatchItemId    = 901
kGodarShoulderPatchItemId           = 902
kSaunamenShoulderPatchItemId        = 903
kSnailsShoulderPatchItemId          = 904
kTitusGamingShoulderPatchItemId     = 905
kRookieShoulderPatchItemId          = 906
kHalloween16ShoulderPatchItemId     = 907
kSNLeviathanPatchItemId             = 908
kSNPeeperPatchItemId                = 909
kSummerGorgePatchItemId             = 910
kHauntedBabblerPatchItemId          = 911
kBattleGorgeShoulderPatchItemId     = 912   --

--Hours-Played TD Badges (Time Played)
kTDTier1BadgeItemId                 = 12201 --
kTDTier2BadgeItemId                 = 12202 --
kTDTier3BadgeItemId                 = 12203 --
kTDTier4BadgeItemId                 = 12204 --
kTDTier5BadgeItemId                 = 12205 --
kTDTier6BadgeItemId                 = 12206 --
kTDTier7BadgeItemId                 = 12207 --
kTDTier8BadgeItemId                 = 12208 --

--Victories TD Calling Cards (Field Players)
kSkulkHugCardItemId                 = 13001 --
kDoNotBlinkCardItemId               = 13002--
kBabyMarineCardItemId               = 13003--
kLockedLoadedCardItemId             = 13004--
kNedRageCardItemId                  = 13005--
kUrpaBootyCardItemId                = 13006--
kSadbabblerCardItemId               = 13007--
kJobWeldDoneCardItemId              = 13008--
kBalanceGorgeCardItemId             = 13009--
kLorkCardItemId                     = 13010--
kLazyGorgeCardItemId                = 13011--
kUrpaCardItemId                     = 13012--
kSlipperSkulkCardItemId             = 13013--
kShadowFadeCardItemId               = 13014--
kBurnoutFadeCardItemId              = 13015--
kOverNineCardItemId                 = 13016--
kLerkedCardItemId                   = 13017--
kTableFlipGorgeCardItemId           = 13018--
kAngryOnosCardItemId                = 13019--
kOhNoesCardItemId                   = 13020--

--Victories TD Calling Cards (Commander Players)
kForScienceCardItemId               = 13021--
kTurboDrifterCardItemId             = 13022--
kBattleGorgeCardItemId              = 13023--


-- Abyss
kAbyssBundleItemId                  = 600
kAbyssSkulkItemId                   = 601
kAbyssGorgeItemId                   = 602
kAbyssLerkItemId                    = 603
kAbyssFadeItemId                    = 604
kAbyssOnosItemId                    = 605
kAbyssTunnelItemId                  = 606
kAbyssStructuresItemId              = 606

--Nocturne
kNocturneAlienPackItemId           = 1100
kNocturneSkulkItemId               = 1101
kNocturneGorgeItemId               = 1102
kNocturneLerkItemId                = 1103
kNocturneFadeItemId                = 1104
kNocturneOnosItemId                = 1105
kNocturneTunnelItemId              = 1114
kNocturneStructuresItemId          = 1114

--Forge
kForgeMarinePackItemId          = 1106
kForgeArmorItemId               = 1107
kForgeRifleItemId               = 1108
kForgePistolItemId              = 1109
kForgeShotgunItemId             = 1112
kForgeFlamethrowerItemId        = 1113
kForgeGrenadeLauncherItemId     = 1115
kForgeHMGItemId                 = 1116
kForgeAxeItemId                 = 1110
kForgeWelderItemId              = 1117
kForgeExosuitItemId             = 1111
kForgeStructuresItemId          = 1118

-- Chroma
kChromaArmorItemId              = 14001--
kChromaBigmacItemId             = 14002--
kChromaMilitaryBmacItemId       = 14003--
kChromaAxeItemId                = 14004--
kChromaPistolItemId             = 10106 --single-item-purchase
kChromaRifleItemId              = 10103 --single-item-purchase
kChromaShotgunItemId            = 14005--
kChromaFlamethrowerItemId       = 14006--
kChromaGrenadeLauncherItemId    = 14007--
kChromaHMGItemId                = 14008--
kChromaWelderItemId             = 14009--
kChromaCommandStationItemId     = 14010--
kChromaExtractorItemId          = 14011--
kChromaExoItemId                = 14012--
kChromaArcItemId                = 14013--
kChromaMacItemId                = 14014--

kCatalystBundleId = 7000


--Sandstorm
kSandstormArmorItemId           = 7001
kSandstormRifleItemId           = 7002
kSandstormPistolItemId          = 7003
kSandstormShotgunItemId         = 7004
kSandstormFlamethrowerItemId    = 7005
kSandstormGrenadeLauncherItemId = 7006
kSandstormExosuitItemId         = 7007
kSandstormWelderItemId          = 7008
kSandstormAxeItemId             = 7009
kSandstormHMGItemId             = kSandstormRifleItemId     --FIXME This needs to be its own item, junking up the DLC descrp text
kSandstormStructuresId          = kSandstormArmorItemId


--Toxin
kToxinSkulkItemId           = 7010
kToxinGorgeItemId           = 7011
kToxinLerkItemId            = 7012
kToxinFadeItemId            = 7013
kToxinOnosItemId            = 7014
kToxinStructuresItemId      = kToxinSkulkItemId     --FIXME This needs to be its own item, junking up the DLC descrp text
kToxinTunnelItemId          = kToxinStructuresItemId

kUnearthedStructuresItemId  = 10001
kUnearthedTunnelItemId      = kUnearthedStructuresItemId


--Auric
kAuricCystItemId            = 15001--
kAuricDrifterItemId         = 15002--
kAuricHiveItemId            = 15003--
kAuricHarvesterItemId       = 15004--
kAuricEggItemId             = 15005--
kAuricSkulkItemId           = 15006--
kAuricLerkItemId            = 15007--
kAuricFadeItemId            = 15008--
kAuricOnosItemId            = 15009--
kAuricGorgeItemId           = 15010--
kAuricGorgeClogItemId       = 15011--
kAuricGorgeHydraItemId      = 15012--
kAuricGorgeBabblerItemId    = 15013--
kAuricGorgeBabblerEggItemId = 15014--
kAuricTunnelItemId          = 15015--

--"Special" Skulks
kWidowSkulkItemId           = 12101--
kTanithSkulkItemId          = 12102--

--Playtester Skin
kSleuthSkulkItemId          = 12103--


--BMAC
kBigMacBundleItemId         = 8000
kBigMacBundle2ItemId        = 8100
kBigMacBundle3ItemId        = 8200

kBigMacVanillaId            = 8001
kMilitaryMacVanillaId       = 8002

kBigMacVariantOneId             = 8101
kBigMacVariantTwoId             = 8102
kBigMacVariantThreeId           = 8103
kMilitaryBigMacVariantOneId     = 8104
kMilitaryBigMacVariantTwoId     = 8105
kMilitaryBigMacVariantThreeId   = 8106

kBigMacEliteId                  = 8201
kMilitaryBigMacEliteId          = 8202

--No longer used, left for backwards compatibility
kCollectableItemIds = { 701, 702, 703, 704, 705, 706, 707, 708, 709, 710, 711, 712, 713, 714, 715 }


--Imported Old-Hive Badge Items
kBadges_DeveloperItemId             = 25001
kBadges_DeveloperRetiredItemId      = 25002
kBadges_MaptesterItemId             = 25003
kBadges_PlaytesterItemId            = 25004
kBadges_Ns1PlaytesterItemId         = 25005
kBadges_ConstellationItemId         = 25006
kBadges_HughnicornItemId            = 25007
kBadges_Squad5BlueItemId            = 25008
kBadges_Squad5SilverItemId          = 25009
kBadges_Squad5GoldItemId            = 25010
kBadges_CommanderItemId             = 25011 --Note: this used to be granted by Hive; now, it won't
kBadges_CommunityDevItemId          = 25012
kBadges_ReinforcedBlueItemId        = 25013
kBadges_ReinforcedSilverItemId      = 25014
kBadges_ReinforcedGoldItemId        = 25015
kBadges_ReinforcedDiamondItemId     = 25016
kBadges_ReinforcedShadowItemId      = 25017
kBadges_ReinforcedOnosItemId        = 25018
kBadges_ReinforcedInsiderItemId     = 25019
kBadges_ReinforcedDirectorItemId    = 25020
kBadges_Wc2013SupportItemId         = 25021
kBadges_Wc2013SilverItemId          = 25022
kBadges_Wc2013GoldItemId            = 25023
kBadges_Wc2013ShadowItemId          = 25024


--Reference table that is all BMAC ItemIDs (used for purchasable checks)
kBmacItemIds = 
{
    kBigMacVanillaId,
    kMilitaryMacVanillaId,
    kBigMacVariantOneId,
    kBigMacVariantTwoId,
    kBigMacVariantThreeId,
    kBigMacEliteId,
    kMilitaryBigMacEliteId
}

kDlcOnlyPurchasableItems =
{
    kDeluxeArmorItemId,

    kBigMacVanillaId,
    kMilitaryMacVanillaId,
    kBigMacVariantOneId,
    kBigMacVariantTwoId,
    kBigMacVariantThreeId,
    kMilitaryBigMacVariantOneId,
    kMilitaryBigMacVariantTwoId,
    kMilitaryBigMacVariantThreeId,
    kBigMacEliteId,
    kMilitaryBigMacEliteId,

    kToxinSkulkItemId,
    kToxinGorgeItemId,
    kToxinLerkItemId,
    kToxinFadeItemId,
    kToxinOnosItemId,
    kToxinStructuresItemId,
    kToxinTunnelItemId,

    kSandstormArmorItemId,
    kSandstormRifleItemId,
    kSandstormPistolItemId,
    kSandstormShotgunItemId,
    kSandstormFlamethrowerItemId,
    kSandstormGrenadelauncherItemId,
    kSandstormExosuitItemId,
    kSandstormWelderItemId,
    kSandstormAxeItemId,
    kSandstormHMGItemId,
    kSandstormStructuresId,

}

kDlcKodiakId = 296360
kDlcShadowFadeId = 471240
kDlcSkullFireId = 494080
kDlcShadowOnosId = 870920
kDlcReaperId = 310100
kDlcCatalystId = 926020
--Commented out DLCs content is available via direct item purchase(s)
kDlcBmacPackId = 1183100        --tier1
kDlcBmacSupportPackId = 1183102 --tier2
kDlcBmacElitePackId = 1183101   --tier3

kBMAC_DlcBundleList = { kDlcBmacPackId, kDlcBmacSupportPackId, kDlcBmacElitePackId }


kItemDlcData = IterableDict()

kItemDlcData[kDeluxeEditionProductId] = 
{
    items = 
    {
        kDeluxeArmorItemId
    },
    displayName = "Deluxe Edition"
}

kItemDlcData[kDlcCatalystId] = 
{
    items = 
    {
        kSandstormArmorItemId,
        kSandstormRifleItemId,
        kSandstormPistolItemId,
        kSandstormShotgunItemId,
        kSandstormFlamethrowerItemId,
        kSandstormGrenadeLauncherItemId,
        kSandstormExosuitItemId,
        kSandstormWelderItemId,
        kSandstormAxeItemId,
        kSandstormHMGItemId,
        kSandstormStructuresId,

        kToxinSkulkItemId,
        kToxinGorgeItemId,
        kToxinLerkItemId,
        kToxinFadeItemId,
        kToxinOnosItemId,
        kToxinTunnelItemId,
        kToxinStructuresItemId,
    },
    displayName = "Catalyst"
}

kItemDlcData[kDlcBmacPackId] = 
{
    items = 
    {
        kBigMacVanillaId,
        kMilitaryMacVanillaId,
        kBigMacVariantOneId,
        kMilitaryBigMacVariantOneId
    },
    displayName = "B.M.A.C. Supporters Pack"
}

kItemDlcData[kDlcBmacSupportPackId] = 
{
    items = 
    {
        --kBigMacVariantOneId,
        --kMilitaryBigMacVariantOneId,
        kBigMacVariantTwoId,
        kMilitaryBigMacVariantTwoId,
        kBigMacVariantThreeId,
        kMilitaryBigMacVariantThreeId
    },
    displayName = "B.M.A.C. Supporters Pack Plus"
}

kItemDlcData[kDlcBmacElitePackId] = 
{
    items = 
    {
        --kBigMacVariantOneId,
        --kMilitaryBigMacVariantOneId,
        --kBigMacVariantTwoId,
        --kMilitaryBigMacVariantTwoId,
        --kBigMacVariantThreeId,
        --kMilitaryBigMacVariantThreeId,
        kBigMacEliteId,
        kMilitaryBigMacEliteId
    },
    displayName = "B.M.A.C. Elite Supporters Pack"
}




kSkulkVariants = enum({ "normal", "kodiak", "abyss", "shadow", "reaper", "nocturne", "toxin", "auric", "widow", "sleuth", "tanith" })
kSkulkVariantsData =
{
    [kSkulkVariants.normal] = { displayName = "Normal", modelFilePart = "", viewModelFilePart = "" },
    [kSkulkVariants.shadow] = 
    { 
        itemId = kShadowSkulkItemId, 
        displayName = "Shadow", 
        modelFilePart = "_shadow", 
        viewModelFilePart = "",
        --Skulks are a bit weird, as some variants use default material + an overridden material
        viewMaterials = 
        {
            "",
            "models/alien/skulk/skulk_v2.material",
        }
    },
    [kSkulkVariants.kodiak] = 
    { 
        itemId = kKodiakSkulkItemId, 
        displayName = "Kodiak", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterial = "models/alien/skulk/skulk_kodiak.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "",
            "models/alien/skulk/skulk_kodiak.material",
        }
    },
    [kSkulkVariants.reaper] = 
    { 
        itemId = kReaperSkulkItemId, 
        displayName = "Reaper", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterial = "models/alien/skulk/skulk_albino.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "models/alien/skulk/skulk_albino_view.material",
            "models/alien/skulk/skulk_albino.material",
        }
    },
    [kSkulkVariants.abyss] = 
    { 
        itemId = kAbyssSkulkItemId,  
        displayName = "Abyss",  
        modelFilePart = "",  
        viewModelFilePart = "",
        worldMaterial = "models/alien/skulk/skulk_abyss.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "models/alien/skulk/skulk_abyss_view.material",
            "models/alien/skulk/skulk_abyss.material",
        }
    },
    [kSkulkVariants.nocturne] = 
    { 
        itemId = kNocturneSkulkItemId,  
        displayName = "Nocturne",  
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterial = "models/alien/skulk/skulk_nocturne.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "models/alien/skulk/skulk_nocturne_view.material",
            "models/alien/skulk/skulk_nocturne.material",
        }
    },
    [kSkulkVariants.toxin] = 
    { 
        itemId = kToxinSkulkItemId, 
        displayName = "Toxin", 
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/alien/skulk/skulk_toxin.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "models/alien/skulk/skulk_toxin_view.material",
            "models/alien/skulk/skulk_toxin.material",
        }
    },
    [kSkulkVariants.auric] = 
    { 
        itemId = kAuricSkulkItemId, 
        displayName = "Auric", 
        modelFilePart = "_shadow",
        viewModelFilePart = "_shadow",
        worldMaterial = "models/alien/skulk/skulk_auric.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "models/alien/skulk/skulk_view_auric.material",
            "models/alien/skulk/skulk_auric.material",
        }
    },
    [kSkulkVariants.widow] = 
    { 
        itemId = kWidowSkulkItemId, 
        displayName = "Widow", 
        modelFilePart = "_shadow",
        viewModelFilePart = "_shadow",
        worldMaterial = "models/alien/skulk/skulk_widow.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "models/alien/skulk/skulk_view_widow.material",
            "models/alien/skulk/skulk_widow.material",
        }
    },
    [kSkulkVariants.sleuth] = 
    { 
        itemId = kSleuthSkulkItemId, 
        displayName = "Sleuth", 
        modelFilePart = "_shadow",
        viewModelFilePart = "_shadow",
        worldMaterial = "models/alien/skulk/skulk_sleuth.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "models/alien/skulk/skulk_view_sleuth.material",
            "models/alien/skulk/skulk_sleuth.material",
        }
    },
    [kSkulkVariants.tanith] = 
    { 
        itemId = kTanithSkulkItemId, 
        displayName = "Tanith", 
        modelFilePart = "_shadow",
        viewModelFilePart = "_shadow",
        worldMaterial = "models/alien/skulk/skulk_tanith.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "models/alien/skulk/skulk_view_tanith.material",
            "models/alien/skulk/skulk_tanith.material",
        }
    },
}
kDefaultSkulkVariant = kSkulkVariants.normal

kGorgeVariants = enum({ "normal", "kodiak", "abyss", "shadow", "reaper", "nocturne", "toxin", "auric" })
kGorgeVariantsData =
{
    [kGorgeVariants.normal] = { displayName = "Normal", modelFilePart = "", viewModelFilePart = "" },
    [kGorgeVariants.shadow] = 
    { 
        itemId = kShadowGorgeItemId, 
        displayName = "Shadow", 
        modelFilePart = "_shadow", 
        viewModelFilePart = "" 
    },
    [kGorgeVariants.reaper] = 
    { 
        itemId = kReaperGorgeItemId, 
        displayName = "Reaper", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterial = "models/alien/gorge/gorge_albino.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/alien/gorge/gorge_albino_view.material",
    },
    [kGorgeVariants.nocturne] =  
    { 
        itemId = kNocturneGorgeItemId, 
        displayName = "Nocturne", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterial = "models/alien/gorge/gorge_anniv.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/alien/gorge/gorge_anniv_view.material",
    },
    [kGorgeVariants.toxin] = 
    { 
        itemId = kToxinGorgeItemId, 
        displayName = "Toxin", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterial = "models/alien/gorge/gorge_toxin.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/alien/gorge/gorge_toxin_view.material",
    },
    [kGorgeVariants.abyss] = 
    { 
        itemId = kAbyssGorgeItemId, 
        displayName = "Abyss", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterial = "models/alien/gorge/gorge_abyss.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/alien/gorge/gorge_abyss_view.material",
    },
    [kGorgeVariants.kodiak] = 
    { 
        itemId = kKodiakGorgeItemId, 
        displayName = "Kodiak", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterial = "models/alien/gorge/gorge_kodiak.material",
        worldMaterialIndex = 0,
    },
    [kGorgeVariants.auric] = 
    { 
        itemId = kAuricGorgeItemId, 
        displayName = "Auric", 
        modelFilePart = "_shadow",
        viewModelFilePart = "_shadow",
        worldMaterial = "models/alien/gorge/gorge_auric.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/alien/gorge/gorge_view_auric.material",
    },
}
kDefaultGorgeVariant = kGorgeVariants.normal

kClogVariants = enum({ "normal", "Kodiak", "Abyss", "Shadow", "Reaper", "Nocturne", "Toxin", "Auric" })
kClogVariantsData = 
{
    [kClogVariants.normal] = { displayName = "Normal" },
    [kClogVariants.Shadow] = 
    { 
        itemId = kShadowGorgeItemId, 
        displayName = "Shadow", 
        modelFilePart = "_shadow", 
    },
    [kClogVariants.Reaper] = 
    { 
        itemId = kReaperGorgeItemId, 
        displayName = "Reaper", 
        modelFilePart = "_reaper", 
    },
    [kClogVariants.Nocturne] =  
    { 
        itemId = kNocturneGorgeItemId, 
        displayName = "Nocturne", 
        modelFilePart = "_nocturne", 
    },
    [kClogVariants.Toxin] = 
    { 
        itemId = kToxinGorgeItemId, 
        displayName = "Toxin", 
        modelFilePart = "_toxin", 
    },
    [kClogVariants.Abyss] = 
    { 
        itemId = kAbyssGorgeItemId, 
        displayName = "Abyss", 
        modelFilePart = "_abyss", 
    },
    [kClogVariants.Kodiak] = 
    { 
        itemId = kKodiakGorgeItemId, 
        displayName = "Kodiak", 
        modelFilePart = "_kodiak", 
    },
    [kClogVariants.Auric] = 
    { 
        itemId = kAuricGorgeClogItemId, 
        displayName = "Auric", 
        modelFilePart = "_auric", 
    },
}
kDefaultClogVariant = kClogVariants.normal

kBabblerVariants = enum({ "normal", "Kodiak", "Abyss", "Shadow", "Reaper", "Nocturne", "Toxin", "Auric" })
kBabblerVariantsData = 
{
    [kBabblerVariants.normal] = { displayName = "Normal" },
    [kBabblerVariants.Shadow] = 
    { 
        itemId = kShadowGorgeItemId, 
        displayName = "Shadow", 
        modelFilePart = "_shadow",
    },
    [kBabblerVariants.Reaper] = 
    { 
        itemId = kReaperGorgeItemId, 
        displayName = "Reaper", 
        worldMaterial = "models/alien/babbler/babbler_reaper.material",
        worldMaterialIndex = 0,
    },
    [kBabblerVariants.Nocturne] =  
    { 
        itemId = kNocturneGorgeItemId, 
        displayName = "Nocturne", 
        worldMaterial = "models/alien/babbler/babbler_nocturne.material",
        worldMaterialIndex = 0,
    },
    [kBabblerVariants.Toxin] = 
    { 
        itemId = kToxinGorgeItemId, 
        displayName = "Toxin", 
        worldMaterial = "models/alien/babbler/babbler_toxin.material",
        worldMaterialIndex = 0,
    },
    [kBabblerVariants.Abyss] = 
    { 
        itemId = kAbyssGorgeItemId, 
        displayName = "Abyss", 
        worldMaterial = "models/alien/babbler/babbler_abyss.material",
        worldMaterialIndex = 0,
    },
    [kBabblerVariants.Kodiak] = 
    { 
        itemId = kKodiakGorgeItemId, 
        displayName = "Kodiak", 
        worldMaterial = "models/alien/babbler/babbler_kodiak.material",
        worldMaterialIndex = 0,
    },
    [kBabblerVariants.Auric] = 
    { 
        itemId = kAuricGorgeBabblerItemId, 
        displayName = "Auric",
        modelFilePart = "_shadow",
        worldMaterial = "models/alien/babbler/babbler_auric.material",
        worldMaterialIndex = 0,
    },
}
kDefaultBabblerVariant = kBabblerVariants.normal

kBabblerEggVariants = enum({ "normal", "Kodiak", "Abyss", "Shadow", "Reaper", "Nocturne", "Toxin", "Auric" })
kBabblerEggVariantsData = 
{
    [kBabblerEggVariants.normal] = { displayName = "Normal" },
    [kBabblerEggVariants.Shadow] = 
    { 
        itemId = kShadowGorgeItemId, 
        displayName = "Shadow", 
        modelFilePart = "_shadow", 
    },
    [kBabblerEggVariants.Reaper] = 
    { 
        itemId = kReaperGorgeItemId, 
        displayName = "Reaper", 
        worldMaterial = "models/alien/babbler/babbler_egg_reaper.material",
        worldMaterialIndex = 0,
    },
    [kBabblerEggVariants.Nocturne] =  
    { 
        itemId = kNocturneGorgeItemId, 
        displayName = "Nocturne", 
        worldMaterial = "models/alien/babbler/babbler_egg_nocturne.material",
        worldMaterialIndex = 0,
    },
    [kBabblerEggVariants.Toxin] = 
    { 
        itemId = kToxinGorgeItemId, 
        displayName = "Toxin", 
        worldMaterial = "models/alien/babbler/babbler_egg_toxin.material",
        worldMaterialIndex = 0,
    },
    [kBabblerEggVariants.Abyss] = 
    { 
        itemId = kAbyssGorgeItemId, 
        displayName = "Abyss", 
        worldMaterial = "models/alien/babbler/babbler_egg_abyss.material",
        worldMaterialIndex = 0,
    },
    [kBabblerEggVariants.Kodiak] = 
    { 
        itemId = kKodiakGorgeItemId, 
        displayName = "Kodiak", 
        worldMaterial = "models/alien/babbler/babbler_egg_kodiak.material",
        worldMaterialIndex = 0,
    },
    [kBabblerEggVariants.Auric] = 
    { 
        itemId = kAuricGorgeBabblerEggItemId, 
        displayName = "Auric",
        modelFilePart = "_shadow",
        worldMaterial = "models/alien/babbler/babbler_egg_auric.material",
        worldMaterialIndex = 0,
    },
}
kDefaultBabblerEggVariant = kBabblerEggVariants.normal

kHydraVariants = enum({ "normal", "Kodiak", "Abyss", "Shadow", "Reaper", "Nocturne", "Toxin", "Auric" })
kHydraVariantsData = 
{
    [kHydraVariants.normal] = { displayName = "Normal" },
    [kHydraVariants.Shadow] = 
    { 
        itemId = kShadowGorgeItemId, 
        displayName = "Shadow", 
        modelFilePart = "_shadow", 
    },
    [kHydraVariants.Reaper] = 
    { 
        itemId = kReaperGorgeItemId, 
        displayName = "Reaper", 
        worldMaterial = "models/alien/hydra/hydra_reaper.material",
        worldMaterialIndex = 0,
    },
    [kHydraVariants.Nocturne] =  
    { 
        itemId = kNocturneGorgeItemId, 
        displayName = "Nocturne", 
        worldMaterial = "models/alien/hydra/hydra_nocturne.material",
        worldMaterialIndex = 0,
    },
    [kHydraVariants.Toxin] = 
    { 
        itemId = kToxinGorgeItemId, 
        displayName = "Toxin", 
        worldMaterial = "models/alien/hydra/hydra_toxin.material",
        worldMaterialIndex = 0,
    },
    [kHydraVariants.Abyss] = 
    { 
        itemId = kAbyssGorgeItemId, 
        displayName = "Abyss", 
        worldMaterial = "models/alien/hydra/hydra_abyss.material",
        worldMaterialIndex = 0,
    },
    [kHydraVariants.Kodiak] = 
    { 
        itemId = kKodiakGorgeItemId, 
        displayName = "Kodiak", 
        worldMaterial = "models/alien/hydra/hydra_kodiak.material",
        worldMaterialIndex = 0,
    },
    [kHydraVariants.Auric] = 
    { 
        itemId = kAuricGorgeHydraItemId, 
        displayName = "Auric", 
        modelFilePart = "_shadow",
        worldMaterial = "models/alien/hydra/hydra_auric.material",
        worldMaterialIndex = 0,
    },
}
kDefaultHydraVariant = kHydraVariants.normal

kLerkVariants = enum({ "normal", "kodiak", "abyss", "shadow", "reaper", "nocturne", "toxin", "auric" })
kLerkVariantsData =
{
    [kLerkVariants.normal] = { displayName = "Normal", modelFilePart = "", viewModelFilePart = "" },
    [kLerkVariants.shadow] = 
    { 
        itemId = kShadowLerkItemId,
        displayName = "Shadow",
        modelFilePart = "_shadow",
        viewModelFilePart = ""
    },
    [kLerkVariants.reaper] = 
    { 
        itemId = kReaperLerkItemId, 
        displayName = "Reaper", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterial = "models/alien/lerk/lerk_albino.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/alien/lerk/lerk_albino_view.material",
    },
    [kLerkVariants.nocturne]  = 
    { 
        itemId = kNocturneLerkItemId, 
        displayName = "Nocturne", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterial = "models/alien/lerk/lerk_nocturne.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/alien/lerk/lerk_nocturne_view.material",
    },
    [kLerkVariants.toxin]  = 
    { 
        itemId = kToxinLerkItemId, 
        displayName = "Toxin", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterial = "models/alien/lerk/lerk_toxin.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/alien/lerk/lerk_toxin_view.material",
    },
    [kLerkVariants.abyss]  = 
    { 
        itemId = kAbyssLerkItemId, 
        displayName = "Abyss", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterial = "models/alien/lerk/lerk_abyss.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/alien/lerk/lerk_abyss_view.material",
    },
    [kLerkVariants.kodiak]  = 
    { 
        itemId = kKodiakLerkItemId, 
        displayName = "Kodiak", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterial = "models/alien/lerk/lerk_kodiak.material",
        worldMaterialIndex = 0,
    },
    [kLerkVariants.auric]  = 
    { 
        itemId = kAuricLerkItemId, 
        displayName = "Auric", 
        modelFilePart = "_shadow",
        viewModelFilePart = "_shadow",
        worldMaterial = "models/alien/lerk/lerk_auric.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/alien/lerk/lerk_view_auric.material",
    },
}
kDefaultLerkVariant = kLerkVariants.normal

kFadeVariants = enum({ "normal", "kodiak", "abyss", "shadow", "reaper", "nocturne", "toxin", "auric" })
kFadeVariantsData =
{
    [kFadeVariants.normal] = { displayName = "Normal", modelFilePart = "", viewModelFilePart = "" },
    [kFadeVariants.reaper] = 
    { 
        itemId = kReaperFadeItemId, 
        displayName = "Reaper", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterial = "models/alien/fade/fade_reaper.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/alien/fade/fade_reaper_view.material"
    },
    [kFadeVariants.shadow] = 
    { 
        itemId = kShadowFadeItemId, 
        displayName = "Shadow", 
        modelFilePart = "_shadow", 
        viewModelFilePart = "_shadow"
    },
    [kFadeVariants.nocturne] = 
    { 
        itemId = kNocturneFadeItemId, 
        displayName = "Nocturne", 
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/alien/fade/fade_nocturne.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/alien/fade/fade_nocturne_view.material"
    },
    [kFadeVariants.toxin] = 
    { 
        itemId = kToxinFadeItemId,
        displayName = "Toxin",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/alien/fade/fade_toxin.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/alien/fade/fade_toxin_view.material"
    },
    [kFadeVariants.kodiak] = 
    { 
        itemId = kKodiakFadeItemId,
        displayName = "Kodiak",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/alien/fade/fade_kodiak.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/alien/fade/fade_kodiak_view.material"
    },
    [kFadeVariants.abyss] = 
    { 
        itemId = kAbyssFadeItemId,
        displayName = "Abyss",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/alien/fade/fade_abyss.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/alien/fade/fade_abyss_view.material"
    },
    [kFadeVariants.auric] = 
    { 
        itemId = kAuricFadeItemId,
        displayName = "Auric",
        modelFilePart = "_shadow",
        viewModelFilePart = "_shadow",
        worldMaterial = "models/alien/fade/fade_auric.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/alien/fade/fade_view_auric.material"
    },
}
kDefaultFadeVariant = kFadeVariants.normal

kOnosVariants = enum({ "normal", "kodiak", "abyss", "shadow", "reaper", "nocturne", "toxin", "auric" })
kOnosVariantsData =
{
    [kOnosVariants.normal] = { displayName = "Normal", modelFilePart = "", viewModelFilePart = "" },
    [kOnosVariants.reaper] = 
    { 
        itemId = kReaperOnosItemId, 
        displayName = "Reaper", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterialIndex = 0,
        worldMaterial = "models/alien/onos/onos_albino.material",
        viewMaterials = 
        {
            "models/alien/onos/onos_albino_view.material",
            "models/alien/onos/onos_albino.material",
        }
    },
    [kOnosVariants.nocturne] = 
    { 
        itemId = kNocturneOnosItemId, 
        displayName = "Nocturne", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterialIndex = 0,
        worldMaterial = "models/alien/onos/onos_anniv.material",
        viewMaterials = 
        {
            "models/alien/onos/onos_anniv_view.material",
            "models/alien/onos/onos_anniv.material",
        }
    },
    [kOnosVariants.shadow] = 
    { 
        itemIds = kShadowOnosItemIds, 
        displayName = "Shadow", 
        modelFilePart = "_shadow", 
        viewModelFilePart = "_shadow"
    },
    [kOnosVariants.toxin] = 
    { 
        itemId = kToxinOnosItemId, 
        displayName = "Toxin", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterialIndex = 0,
        worldMaterial = "models/alien/onos/onos_toxin.material",
        viewMaterials = 
        {
            "models/alien/onos/onos_toxin_view.material",
            "models/alien/onos/onos_toxin.material",
        }
    },
    [kOnosVariants.abyss] = 
    { 
        itemId = kAbyssOnosItemId, 
        displayName = "Abyss", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterialIndex = 0,
        worldMaterial = "models/alien/onos/onos_abyss.material",
        viewMaterials = 
        {
            "models/alien/onos/onos_abyss_view.material",
            "models/alien/onos/onos_abyss.material",
        }
    },
    [kOnosVariants.kodiak] = 
    { 
        itemId = kKodiakOnosItemId, 
        displayName = "Kodiak", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterialIndex = 0,
        worldMaterial = "models/alien/onos/onos_kodiak.material",
        viewMaterials = 
        {
            "models/alien/onos/onos_kodiak_view.material",
            "models/alien/onos/onos_kodiak.material",
        }
    },
    [kOnosVariants.auric] = 
    { 
        itemId = kAuricOnosItemId, 
        displayName = "Auric", 
        modelFilePart = "_shadow",
        viewModelFilePart = "_shadow",
        worldMaterialIndex = 0,
        worldMaterial = "models/alien/onos/onos_auric.material",
        viewMaterials = 
        {
            "models/alien/onos/onos_view_auric.material",
            "models/alien/onos/onos_auric.material",
        }
    },
}
kDefaultOnosVariant = kOnosVariants.normal


kAlienStructureVariants = enum({ "Default", "Kodiak", "Abyss", "Shadow", "Reaper", "Nocturne", "Toxin", "Unearthed", "Auric" })
kAlienStructureVariantsData =
{
    [ kAlienStructureVariants.Default ] = { displayName = "Normal" },

    [ kAlienStructureVariants.Toxin ] = 
    { 
        itemId = kToxinStructuresItemId, 
        displayName = "Toxin",
        worldMaterialIndex = 0,
        worldMaterials = 
        {
            ["Hive"] = "models/alien/hive/hive_toxin.material",
        }
    },
    [ kAlienStructureVariants.Unearthed ] = 
    { 
        itemId = kUnearthedStructuresItemId,
        displayName = "Unearthed",
        worldMaterials = 
        {
            ["Hive"] = "models/alien/hive/hive_unearthed.material",
        },
        worldMaterialIndex = 0
    },
    [ kAlienStructureVariants.Kodiak ] = 
    { 
        itemId = kKodiakAlienStructuresItemId,
        displayName = "Kodiak",
        worldMaterialIndex = 0,
        worldMaterials = 
        {
            ["Hive"] = "models/alien/hive/hive_kodiak.material",
        }
    },
    [ kAlienStructureVariants.Nocturne ] = 
    { 
        itemId = kNocturneStructuresItemId,
        displayName = "Nocturne",
        worldMaterialIndex = 0,
        worldMaterials = 
        {
            ["Hive"] = "models/alien/hive/hive_nocturne.material",
        }
    },
    [ kAlienStructureVariants.Reaper ] = 
    { 
        itemId = kReaperStructuresItemId,
        displayName = "Reaper",
        worldMaterialIndex = 0,
        worldMaterials = 
        {
            ["Hive"] = "models/alien/hive/hive_reaper.material",
        }
    },
    [ kAlienStructureVariants.Abyss ] = 
    { 
        itemId = kAbyssStructuresItemId,
        displayName = "Abyss",
        worldMaterialIndex = 0,
        worldMaterials = 
        {
            ["Hive"] = "models/alien/hive/hive_abyss.material",
        }
    },
    [ kAlienStructureVariants.Shadow ] = 
    { 
        itemId = kShadowStructuresItemId,
        displayName = "Shadow",
        worldMaterialIndex = 0,
        worldMaterials = 
        {
            ["Hive"] = "models/alien/hive/hive_shadow.material",
        }
    },
    [ kAlienStructureVariants.Auric ] = 
    { 
        itemId = kAuricHiveItemId,
        displayName = "Auric",
        worldMaterialIndex = 0,
        worldMaterials = 
        {
            ["Hive"] = "models/alien/hive/hive_auric.material",
        }
    },
}
kDefaultAlienStructureVariant = kAlienStructureVariants.Default

kEggVariants = enum({ "Default", "Kodiak", "Abyss", "Shadow", "Reaper", "Nocturne", "Toxin", "Unearthed", "Auric" })
kEggVariantsData = 
{
    [ kEggVariants.Default ] = { displayName = "Normal" },

    [ kEggVariants.Toxin ] = 
    { 
        itemId = kToxinStructuresItemId, 
        displayName = "Toxin",
        worldMaterialIndex = 0,
        worldMaterials = 
        {
            ["Egg"] = "models/alien/egg/egg_toxin.material",
            ["Embryo"] = "models/alien/egg/egg_toxin.material",
        }
    },
    [ kEggVariants.Unearthed ] = 
    { 
        itemId = kUnearthedStructuresItemId,
        displayName = "Unearthed",
        worldMaterials = 
        {
            ["Egg"] = "models/alien/egg/egg_unearthed.material",
            ["Embryo"] = "models/alien/egg/egg_unearthed.material",
        },
        worldMaterialIndex = 0
    },
    [ kEggVariants.Kodiak ] = 
    { 
        itemId = kKodiakAlienStructuresItemId,
        displayName = "Kodiak",
        worldMaterialIndex = 0,
        worldMaterials = 
        {
            ["Egg"] = "models/alien/egg/egg_kodiak.material",
            ["Embryo"] = "models/alien/egg/egg_kodiak.material",
        }
    },
    [ kEggVariants.Nocturne ] = 
    { 
        itemId = kNocturneStructuresItemId,
        displayName = "Nocturne",
        worldMaterialIndex = 0,
        worldMaterials = 
        {
            ["Egg"] = "models/alien/egg/egg_nocturne.material",
            ["Embryo"] = "models/alien/egg/egg_nocturne.material",
        }
    },
    [ kEggVariants.Reaper ] = 
    { 
        itemId = kReaperStructuresItemId,
        displayName = "Reaper",
        worldMaterialIndex = 0,
        worldMaterials = 
        {
            ["Egg"] = "models/alien/egg/egg_reaper.material",
            ["Embryo"] = "models/alien/egg/egg_reaper.material",
        }
    },
    [ kEggVariants.Abyss ] = 
    { 
        itemId = kAbyssStructuresItemId,
        displayName = "Abyss",
        worldMaterialIndex = 0,
        worldMaterials = 
        {
            ["Egg"] = "models/alien/egg/egg_abyss.material",
            ["Embryo"] = "models/alien/egg/egg_abyss.material",
        }
    },
    [ kEggVariants.Shadow ] = 
    { 
        itemId = kShadowStructuresItemId,
        displayName = "Shadow",
        worldMaterialIndex = 0,
        worldMaterials = 
        {
            ["Egg"] = "models/alien/egg/egg_shadow.material",
            ["Embryo"] = "models/alien/egg/egg_shadow.material",
        }
    },
    [ kEggVariants.Auric ] = 
    { 
        itemId = kAuricEggItemId,
        displayName = "Auric",
        worldMaterialIndex = 0,
        worldMaterials = 
        {
            ["Egg"] = "models/alien/egg/egg_auric.material",
            ["Embryo"] = "models/alien/egg/egg_auric.material",
        }
    },
}
kDefaultEggVariant = kEggVariants.Default

kHarvesterVariants = enum({ "Default", "Kodiak", "Abyss", "Shadow", "Reaper", "Nocturne", "Toxin", "Unearthed", "Auric" })
kHarvesterVariantsData = 
{
    [ kHarvesterVariants.Default ] = { displayName = "Normal" },
    [ kHarvesterVariants.Toxin ] = 
    { 
        itemId = kToxinStructuresItemId, 
        displayName = "Toxin",
        worldMaterialIndex = 0,
        worldMaterial = "models/alien/harvester/harvester_toxin.material",
    },
    [ kHarvesterVariants.Unearthed ] = 
    { 
        itemId = kUnearthedStructuresItemId,
        displayName = "Unearthed",
        worldMaterial = "models/alien/harvester/harvester_unearthed.material",
        worldMaterialIndex = 0
    },
    [ kHarvesterVariants.Kodiak ] = 
    { 
        itemId = kKodiakAlienStructuresItemId,
        displayName = "Kodiak",
        worldMaterialIndex = 0,
        worldMaterial = "models/alien/harvester/harvester_kodiak.material",
    },
    [ kHarvesterVariants.Nocturne ] = 
    { 
        itemId = kNocturneStructuresItemId,
        displayName = "Nocturne",
        worldMaterialIndex = 0,
        worldMaterial = "models/alien/harvester/harvester_nocturne.material",
    },
    [ kHarvesterVariants.Reaper ] = 
    { 
        itemId = kReaperStructuresItemId,
        displayName = "Reaper",
        worldMaterialIndex = 0,
        worldMaterial = "models/alien/harvester/harvester_reaper.material",
    },
    [ kHarvesterVariants.Abyss ] = 
    { 
        itemId = kAbyssStructuresItemId,
        displayName = "Abyss",
        worldMaterialIndex = 0,
        worldMaterial = "models/alien/harvester/harvester_abyss.material",
    },
    [ kHarvesterVariants.Shadow ] = 
    { 
        itemId = kShadowStructuresItemId,
        displayName = "Shadow",
        worldMaterialIndex = 0,
        worldMaterial = "models/alien/harvester/harvester_shadow.material",
    },
    [ kHarvesterVariants.Auric ] = 
    { 
        itemId = kAuricHarvesterItemId,
        displayName = "Auric",
        worldMaterialIndex = 0,
        worldMaterial = "models/alien/harvester/harvester_auric.material",
    },
}
kDefaultHarvesterVariant = kHarvesterVariants.Default

kAlienCystVariants = enum({ "Default", "Auric" })
kAlienCystVariantsData = 
{
    [kAlienCystVariants.Default] = { displayName = "Normal" },
    [kAlienCystVariants.Auric] = 
    {
        displayName = "Auric",
        itemId = kAuricCystItemId,
        worldMaterialIndex = 0,
        worldMaterial = "models/alien/cyst/cyst_auric.material",
    },
}
kDefaultAlienCystVariant = kAlienCystVariants.Default

kAlienDrifterVariants = enum({ "Default", "Auric" })
kAlienDrifterVariantsData = 
{
    [kAlienDrifterVariants.Default] = { displayName = "Normal" },
    [kAlienDrifterVariants.Auric] = 
    {
        displayName = "Auric",
        itemId = kAuricDrifterItemId,
        worldMaterialIndex = 0,
        worldMaterials = 
        {
            ["Drifter"] = "models/alien/drifter/drifter_auric.material",
            ["DrifterEgg"] = "models/alien/cocoon/cocoon_auric.material",
        }
    },
}
kDefaultAlienDrifterVariant = kAlienDrifterVariants.Default

kAlienTunnelVariants = enum({ "Default", "Kodiak", "Abyss", "Shadow", "Reaper", "Nocturne", "Toxin", "Unearthed", "Auric" })
kAlienTunnelVariantsData =
{
    [ kAlienTunnelVariants.Default ] = { modelFilePart = "", displayName = "Normal" },
    [ kAlienTunnelVariants.Shadow ] = 
    { 
        itemId = kShadowTunnelItemId, 
        displayName = "Shadow",
        modelFilePart = "_shadow",  
    },
    [ kAlienTunnelVariants.Toxin ] = 
    { 
        itemId = kToxinTunnelItemId, 
        displayName = "Toxin",
        modelFilePart = "",
        worldMaterialIndex = 0,
        worldMaterial = "models/alien/tunnel/mouth_toxin.material",
    },
    [ kAlienTunnelVariants.Unearthed ] = 
    { 
        itemId = kUnearthedTunnelItemId, 
        displayName = "Unearthed",
        modelFilePart = "",
        worldMaterialIndex = 0,
        worldMaterial = "models/alien/tunnel/mouth_unearthed.material",
    },
    [ kAlienTunnelVariants.Kodiak ] = 
    { 
        itemId = kKodiakTunnelItemId, 
        displayName = "Kodiak",
        modelFilePart = "",
        worldMaterialIndex = 0,
        worldMaterial = "models/alien/tunnel/mouth_kodiak.material",
    },
    [ kAlienTunnelVariants.Nocturne ] = 
    { 
        itemId = kNocturneTunnelItemId, 
        displayName = "Nocturne",
        modelFilePart = "",
        worldMaterialIndex = 0,
        worldMaterial = "models/alien/tunnel/mouth_nocturne.material",
    },
    [ kAlienTunnelVariants.Reaper ] = 
    { 
        itemId = kReaperTunnelItemId,
        displayName = "Reaper",
        modelFilePart = "",
        worldMaterialIndex = 0,
        worldMaterial = "models/alien/tunnel/mouth_reaper.material",
    },
    [ kAlienTunnelVariants.Abyss ] = 
    { 
        itemId = kAbyssTunnelItemId,
        displayName = "Abyss",
        modelFilePart = "",
        worldMaterialIndex = 0,
        worldMaterial = "models/alien/tunnel/mouth_abyss.material",
    },
    [ kAlienTunnelVariants.Auric ] = 
    { 
        itemId = kAuricTunnelItemId,
        displayName = "Auric",
        modelFilePart = "_shadow",
        worldMaterialIndex = 0,
        worldMaterial = "models/alien/tunnel/mouth_auric.material",
    }
}
kDefaultAlienTunnelVariant = kAlienTunnelVariants.Default



-- TODO we can really just get rid of the enum. use array-of-structures pattern, and use #kMarineVariants to network vars
kMarineVariantsBaseType = enum({ "male", "female", "bigmac" })
kMarineVariantsDefaultType = kMarineVariantsBaseType.male

kMarineVariants = enum({
    "green", 
    "special", 
    "deluxe", 
    "assault", 
    "eliteassault", 
    "kodiak", 
    "tundra", 
    "anniv", 
    "sandstorm", 
    "chroma",

    --BMACs
    "bigmac",
    "bigmac02",
    "bigmac03",
    "bigmac04",
    "bigmac05",
    "bigmac06",
    "chromabmac",
    
    --Combat MACs
    "militarymac",
    "militarymac02",
    "militarymac03",
    "militarymac04",
    "militarymac05",
    "militarymac06",
    "chromamilbmac",
})
kMarineHumanVariants = enum({"green", "special", "deluxe", "assault", "eliteassault", "kodiak", "tundra", "anniv", "sandstorm", "chroma" }) --must match kMarineVariants order & value

kMarineVariantsData =
{
    [kMarineVariants.green] = { displayName = "Normal", modelFilePart = "", viewModelFilePart = "" },
    [kMarineVariants.special] = { itemId = kBlackArmorItemId, displayName = "Black", modelFilePart = "_special", viewModelFilePart = "_special" },
    [kMarineVariants.deluxe] = { itemId = kDeluxeArmorItemId, displayName = "Deluxe", modelFilePart = "_special_v1", viewModelFilePart = "_deluxe" },
    [kMarineVariants.assault] = { itemId = kAssaultArmorItemId, displayName = "Assault", modelFilePart = "_assault", viewModelFilePart = "_assault" },
    [kMarineVariants.eliteassault] = { itemId = kEliteAssaultArmorItemId, displayName = "Elite Assault", modelFilePart = "_eliteassault", viewModelFilePart = "_eliteassault" },
    [kMarineVariants.kodiak] = { itemId = kKodiakArmorItemId, displayName = "Kodiak", modelFilePart = "_kodiak", viewModelFilePart = "_kodiak" },
    [kMarineVariants.tundra] = { itemId = kTundraArmorItemId, displayName = "Tundra", modelFilePart = "_tundra", viewModelFilePart = "_tundra" },
    [kMarineVariants.anniv] = { itemId = kForgeArmorItemId, displayName = "Forge", modelFilePart = "_anniv", viewModelFilePart = "_anniv" },
    [kMarineVariants.sandstorm] = { itemId = kSandstormArmorItemId, displayName = "Sandstorm", modelFilePart = "_sandstorm", viewModelFilePart = "_sandstorm" },
    [kMarineVariants.chroma] = { itemId = kChromaArmorItemId, displayName = "Chroma Elite Assault", modelFilePart = "_chroma", viewModelFilePart = "_chroma", },

    [kMarineVariants.bigmac] = { itemId = kBigMacVanillaId, displayName = "B.M.A.C.", modelFilePart = "", viewModelFilePart = "_bigmac1", isRobot = true },
    [kMarineVariants.bigmac02] = { itemId = kBigMacVariantOneId, displayName = "Green B.M.A.C.", modelFilePart = "02", viewModelFilePart = "_bigmac1", isRobot = true },
    [kMarineVariants.bigmac03] = { itemId = kBigMacVariantTwoId, displayName = "Violet B.M.A.C.", modelFilePart = "03", viewModelFilePart = "_bigmac1", isRobot = true },
    [kMarineVariants.bigmac04] = { itemId = kBigMacVariantThreeId, displayName = "Blue B.M.A.C.", modelFilePart = "04", viewModelFilePart = "_bigmac1", isRobot = true },
    [kMarineVariants.bigmac05] = { itemId = kBigMacEliteId, displayName = "Elite B.M.A.C.", modelFilePart = "05", viewModelFilePart = "_bigmac1", isRobot = true },
    [kMarineVariants.bigmac06] = { itemId = kBigMacEliteId, displayName = "Butler B.M.A.C. ", modelFilePart = "06", viewModelFilePart = "_bigmac1", isRobot = true },
    [kMarineVariants.chromabmac] = { itemId = kChromaBigmacItemId, displayName = "Chroma B.M.A.C.", modelFilePart = "07", viewModelFilePart = "_bigmac1", isRobot = true },

    [kMarineVariants.militarymac] = { itemId = kMilitaryMacVanillaId, displayName = "Military B.M.A.C.", modelFilePart = "_military", viewModelFilePart = "_bigmac1", isRobot = true },
    [kMarineVariants.militarymac02] = { itemId = kMilitaryBigMacVariantOneId, displayName = "White Military B.M.A.C.", modelFilePart = "_military02", viewModelFilePart = "_bigmac1", isRobot = true },
    [kMarineVariants.militarymac03] = { itemId = kMilitaryBigMacVariantTwoId, displayName = "Blue Military B.M.A.C.", modelFilePart = "_military03", viewModelFilePart = "_bigmac1", isRobot = true },
    [kMarineVariants.militarymac04] = { itemId = kMilitaryBigMacVariantThreeId, displayName = "Camouflage Military B.M.A.C.", modelFilePart = "_military04", viewModelFilePart = "_bigmac1", isRobot = true },
    [kMarineVariants.militarymac05] = { itemId = kMilitaryBigMacEliteId, displayName = "Elite Military B.M.A.C.", modelFilePart = "_military05", viewModelFilePart = "_bigmac1", isRobot = true },
    [kMarineVariants.militarymac06] = { itemId = kMilitaryBigMacEliteId, displayName = "Special Military B.M.A.C. ", modelFilePart = "_military06", viewModelFilePart = "_bigmac1", isRobot = true },    
    [kMarineVariants.chromamilbmac] = { itemId = kChromaMilitaryBmacItemId, displayName = "Chroma Military B.M.A.C.", modelFilePart = "_military07", viewModelFilePart = "_bigmac1", isRobot = true },
}

kDefaultMarineVariant = kMarineVariants.green
kDefaultMarineBigmacVariant = kMarineVariants.bigmac
kDefaultMarineMilitaryMacVariant = kMarineVariants.militarymac

kRoboticMarineVariantIds = 
{ 
    kMarineVariants.bigmac, 
    kMarineVariants.bigmac02, 
    kMarineVariants.bigmac03, 
    kMarineVariants.bigmac04, 
    kMarineVariants.bigmac05, 
    kMarineVariants.bigmac06,
    
    kMarineVariants.militarymac,
    kMarineVariants.militarymac02,
    kMarineVariants.militarymac03,
    kMarineVariants.militarymac04,
    kMarineVariants.militarymac05,
    kMarineVariants.militarymac06,

    kMarineVariants.chromabmac,
    kMarineVariants.chromamilbmac,
}
kBigMacVariantIds = { kMarineVariants.bigmac, kMarineVariants.bigmac02, kMarineVariants.bigmac03, kMarineVariants.bigmac04, kMarineVariants.bigmac05, kMarineVariants.bigmac06, kMarineVariants.chromabmac, }
kMilitaryMacVariantIds = { kMarineVariants.militarymac, kMarineVariants.militarymac02, kMarineVariants.militarymac03, kMarineVariants.militarymac04, kMarineVariants.militarymac05, kMarineVariants.militarymac06, kMarineVariants.chromamilbmac }
kBigMacVariantType = 1
kMilitaryMacVariantType = 2

kExoVariants = enum({ "normal", "kodiak", "tundra", "forge", "sandstorm", "chroma" })
kExoVariantsData =
{
    [kExoVariants.normal] = { displayName = "Normal", modelFilePart = "", viewModelFilePart = "" },

    [kExoVariants.kodiak] = 
    { 
        itemId = kKodiakExosuitItemId, 
        displayName = "Kodiak", 
        modelFilePart = "", 
        viewModelFilePart = "",
        --Note: Exos are treated like Structures, in terms of skins. When fetched, their weapon class-name is used
        --and not the Entity(parent) class-name. This allows for all weapon loadouts to be defined here.
        worldMaterials = 
        {
            ["Minigun"] =
            {
                { idx = 0, mat = "models/marine/exosuit/exosuit_kodiak.material" },
                { idx = 1, mat = "models/marine/exosuit/minigun_kodiak.material" },
            },
            ["Railgun"] =
            {
                { idx = 0, mat = "models/marine/exosuit/railgun_kodiak.material" },
                { idx = 1, mat = "models/marine/exosuit/exosuit_kodiak.material" },
            },
        },
        viewMaterials = 
        {
            ["Minigun"] = 
            {
                "models/marine/exosuit/minigun_view_kodiak.material",
            },
            ["Railgun"] =
            {
                "models/marine/exosuit/railgun_view_kodiak.material",
                "models/marine/exosuit/forearm_kodiak.material",
            }
        }
    },

    [kExoVariants.tundra] = 
    { 
        itemId = kTundraExosuitItemId, 
        displayName = "Tundra", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterials = 
        {
            ["Minigun"] =
            {
                { idx = 0, mat = "models/marine/exosuit/exosuit_tundra.material" },
                { idx = 1, mat = "models/marine/exosuit/minigun_tundra.material" },
            },
            ["Railgun"] =
            {
                { idx = 0, mat = "models/marine/exosuit/railgun_tundra.material" },
                { idx = 1, mat = "models/marine/exosuit/exosuit_tundra.material" },
            },
        },
        viewMaterials = 
        {
            ["Minigun"] = 
            {
                "models/marine/exosuit/minigun_view_tundra.material",
            },
            ["Railgun"] =
            {
                "models/marine/exosuit/railgun_view_tundra.material",
                "models/marine/exosuit/forearm_tundra.material",
            }
        }
    },

    [kExoVariants.forge] = 
    { 
        itemId = kForgeExosuitItemId, 
        displayName = "Forge", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterials = 
        {
            ["Minigun"] =
            {
                { idx = 0, mat = "models/marine/exosuit/exosuit_forge.material" },
                { idx = 1, mat = "models/marine/exosuit/minigun_forge.material" },
            },
            ["Railgun"] =
            {
                { idx = 0, mat = "models/marine/exosuit/railgun_forge.material" },
                { idx = 1, mat = "models/marine/exosuit/exosuit_forge.material" },
            },
        },
        viewMaterials = 
        {
            ["Minigun"] = 
            {
                "models/marine/exosuit/minigun_view_forge.material",
            },
            ["Railgun"] =
            {
                "models/marine/exosuit/railgun_view_forge.material",
                "models/marine/exosuit/forearm_forge.material",
            }
        }
    },

    [kExoVariants.sandstorm] = 
    { 
        itemId = kSandstormExosuitItemId, 
        displayName = "Sandstorm", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterials = 
        {
            ["Minigun"] =
            {
                { idx = 0, mat = "models/marine/exosuit/exosuit_sandstorm.material" },
                { idx = 1, mat = "models/marine/exosuit/minigun_sandstorm.material" },
            },
            ["Railgun"] =
            {
                { idx = 0, mat = "models/marine/exosuit/railgun_sandstorm.material" },
                { idx = 1, mat = "models/marine/exosuit/exosuit_sandstorm.material" },
            },
        },
        viewMaterials = 
        {
            ["Minigun"] = 
            {
                "models/marine/exosuit/minigun_view_sandstorm.material",
            },
            ["Railgun"] =
            {
                "models/marine/exosuit/railgun_view_sandstorm.material",
                "models/marine/exosuit/forearm_sandstorm.material",
            }
        }
    },

    [kExoVariants.chroma] = 
    { 
        itemId = kChromaExoItemId, 
        displayName = "Chroma", 
        modelFilePart = "", 
        viewModelFilePart = "",
        worldMaterials = 
        {
            ["Minigun"] =
            {
                { idx = 0, mat = "models/marine/exosuit/exosuit_chroma.material" },
                { idx = 1, mat = "models/marine/exosuit/minigun_chroma.material" },
            },
            ["Railgun"] =
            {
                { idx = 0, mat = "models/marine/exosuit/railgun_chroma.material" },
                { idx = 1, mat = "models/marine/exosuit/exosuit_chroma.material" },
            },
        },
        viewMaterials = 
        {
            ["Minigun"] = 
            {
                "models/marine/exosuit/minigun_view_chroma.material",
            },
            ["Railgun"] =
            {
                "models/marine/exosuit/railgun_view_chroma.material",
                "models/marine/exosuit/forearm_chroma.material",
            }
        }
    },
}
kDefaultExoVariant = kExoVariants.normal

kRifleVariants = enum({ "normal", "kodiak", "tundra", "red", "forge", "sandstorm", "dragon", "gold", "chroma", "wood", "damascus", "damasgrn", "damaspurp" })
kRifleVariantsData =
{
    [kRifleVariants.normal] =
    {
        displayName = "Normal",
        modelFilePart = "",
        viewModelFilePart = "",
    },
    
    [kRifleVariants.kodiak] =
    {
        itemId = kKodiakRifleItemId,
        displayName = "Kodiak",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/rifle/rifle_kodiak.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/rifle/rifle_view_kodiak.material",
        viewMaterialIndex = 1
    },
    
    [kRifleVariants.tundra] =
    {
        itemId = kTundraRifleItemId,
        displayName = "Tundra",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/rifle/rifle_tundra.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/rifle/rifle_view_tundra.material",
        viewMaterialIndex = 1
    },
    
    [kRifleVariants.red] =
    {
        itemId = kRedRifleItemId,
        displayName = "Skull 'n' Crossfire",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/rifle/rifle_red.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/rifle/rifle_view_red.material",
        viewMaterialIndex = 1
    },
    
    [kRifleVariants.forge] =
    {
        itemId = kForgeRifleItemId,
        displayName = "Forge",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/rifle/rifle_forge.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/rifle/rifle_view_forge.material",
        viewMaterialIndex = 1
    },
    
    [kRifleVariants.sandstorm] =
    {
        itemId = kSandstormRifleItemId,
        displayName = "Sandstorm",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/rifle/rifle_sandstorm.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/rifle/rifle_view_sandstorm.material",
        viewMaterialIndex = 1
    },

    [kRifleVariants.dragon] =
    {
        itemId = kDragonRifleItemId,
        displayName = "Dragon",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/rifle/rifle_dragon.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/rifle/rifle_view_dragon.material",
        viewMaterialIndex = 1
    },

    [kRifleVariants.gold] =
    {
        itemId = kGoldRifleItemId,
        displayName = "Gold",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/rifle/rifle_gold.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/rifle/rifle_view_gold.material",
        viewMaterialIndex = 1
    },

    [kRifleVariants.chroma] =
    {
        itemId = kChromaRifleItemId,
        displayName = "Chroma",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/rifle/rifle_chroma.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/rifle/rifle_view_chroma.material",
        viewMaterialIndex = 1
    },

    [kRifleVariants.wood] =
    {
        itemId = kWoodRifleItemId,
        displayName = "Wood",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/rifle/rifle_wood.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/rifle/rifle_view_wood.material",
        viewMaterialIndex = 1
    },

    [kRifleVariants.damascus] =
    {
        itemId = kDamascusRifleItemId,
        displayName = "Damascus",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/rifle/rifle_damas.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/rifle/rifle_view_damas.material",
        viewMaterialIndex = 1
    },

    [kRifleVariants.damasgrn] =
    {
        itemId = kDamascusGreenRifleItemId,
        displayName = "Damascus Green",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/rifle/rifle_damas_grn.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/rifle/rifle_view_damas_grn.material",
        viewMaterialIndex = 1
    },

    [kRifleVariants.damaspurp] =
    {
        itemId = kDamascusPurpleRifleItemId,
        displayName = "Damascus Purple",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/rifle/rifle_damas_pur.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/rifle/rifle_view_damas_pur.material",
        viewMaterialIndex = 1
    },
}
kDefaultRifleVariant = kRifleVariants.normal

kShotgunVariants = enum({ "normal", "kodiak", "tundra", "forge", "sandstorm", "chroma" })
kShotgunVariantsData =
{
    [kShotgunVariants.normal] =
    {
        displayName = "Normal",
        modelFilePart = "",
        viewModelFilePart = "",
    },
    
    [kShotgunVariants.tundra] =
    {
        itemId = kTundraShotgunItemId,
        displayName = "Tundra",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/shotgun/shotgun_tundra.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "models/marine/shotgun/shotgun_view_tundra.material",
            "models/marine/shotgun/shotgun_view_lights_tundra.material",
        }
    },
    
    [kShotgunVariants.forge] =
    {
        itemId = kForgeShotgunItemId,
        displayName = "Forge",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/shotgun/shotgun_forge.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "models/marine/shotgun/shotgun_view_forge.material",
            "models/marine/shotgun/shotgun_view_lights_forge.material",
        }
    },
    
    [kShotgunVariants.sandstorm] =
    {
        itemId = kSandstormShotgunItemId,
        displayName = "Sandstorm",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/shotgun/shotgun_sandstorm.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "models/marine/shotgun/shotgun_view_sandstorm.material",
            "models/marine/shotgun/shotgun_view_lights_sandstorm.material",
        }
    },

    [kShotgunVariants.kodiak] =
    {
        itemId = kKodiakShotgunItemId,
        displayName = "Kodiak",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/shotgun/shotgun_kodiak.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "models/marine/shotgun/shotgun_view_kodiak.material",
            "models/marine/shotgun/shotgun_view_lights_kodiak.material",
        }
    },

    [kShotgunVariants.chroma] =
    {
        itemId = kChromaShotgunItemId,
        displayName = "Chroma",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/shotgun/shotgun_chroma.material",
        worldMaterialIndex = 0,
        viewMaterials = 
        {
            "models/marine/shotgun/shotgun_view_chroma.material",
            "models/marine/shotgun/shotgun_view_lights_chroma.material",
        }
    },
}
kDefaultShotgunVariant = kShotgunVariants.normal

kPistolVariants = enum({ "normal", "kodiak", "tundra", "forge", "sandstorm", "viper", "gold", "chroma", "wood", "damascus", "damasgrn", "damaspurp" })
kPistolVariantsData = 
{
    [kPistolVariants.normal] =
    {
        displayName = "Normal",
        modelFilePart = "",
        viewModelFilePart = "",
    },
    
    [kPistolVariants.forge] =
    {
        itemId = kForgePistolItemId,
        displayName = "Forge",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/pistol/pistol_forge.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/pistol/pistol_view_forge.material",
        viewMaterialIndex = 0
    },
    
    [kPistolVariants.sandstorm] =
    {
        itemId = kSandstormPistolItemId,
        displayName = "Sandstorm",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/pistol/pistol_sandstorm.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/pistol/pistol_view_sandstorm.material",
        viewMaterialIndex = 0
    },

    [kPistolVariants.tundra] =
    {
        itemId = kTundraPistolItemId,
        displayName = "Tundra",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/pistol/pistol_tundra.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/pistol/pistol_view_tundra.material",
        viewMaterialIndex = 0
    },

    [kPistolVariants.kodiak] =
    {
        itemId = kKodiakPistolItemId,
        displayName = "Kodiak",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/pistol/pistol_kodiak.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/pistol/pistol_view_kodiak.material",
        viewMaterialIndex = 0
    },

    [kPistolVariants.viper] =
    {
        itemId = kViperPistolItemId,
        displayName = "Viper",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/pistol/pistol_viper.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/pistol/pistol_view_viper.material",
        viewMaterialIndex = 0
    },

    [kPistolVariants.gold] =
    {
        itemId = kGoldPistolItemId,
        displayName = "Gold",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/pistol/pistol_gold.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/pistol/pistol_view_gold.material",
        viewMaterialIndex = 0
    },

    [kPistolVariants.chroma] =
    {
        itemId = kChromaPistolItemId,
        displayName = "Chroma",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/pistol/pistol_chroma.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/pistol/pistol_view_chroma.material",
        viewMaterialIndex = 0
    },

    [kPistolVariants.wood] =
    {
        itemId = kWoodPistolItemId,
        displayName = "Wood",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/pistol/pistol_wood.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/pistol/pistol_view_wood.material",
        viewMaterialIndex = 0
    },

    [kPistolVariants.damascus] =
    {
        itemId = kDamascusPistolItemId,
        displayName = "Damascus",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/pistol/pistol_damas.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/pistol/pistol_view_damas.material",
        viewMaterialIndex = 0
    },

    [kPistolVariants.damasgrn] =
    {
        itemId = kDamascusGreenPistolItemId,
        displayName = "Damascus Green",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/pistol/pistol_damas_grn.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/pistol/pistol_view_damas_grn.material",
        viewMaterialIndex = 0
    },

    [kPistolVariants.damaspurp] =
    {
        itemId = kDamascusPurplePistolItemId,
        displayName = "Damascus Purple",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/pistol/pistol_damas_pur.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/pistol/pistol_view_damas_pur.material",
        viewMaterialIndex = 0
    },
}
kDefaultPistolVariant = kPistolVariants.normal

kAxeVariants = enum({ "normal", "kodiak", "tundra", "forge", "sandstorm", "chroma", "wood", "damascus", "damasgrn", "damaspurp" })
kAxeVariantsData = 
{
    [kAxeVariants.normal] =
    {
        displayName = "Normal",
        modelFilePart = "",
        viewModelFilePart = "",
    },
    
    [kAxeVariants.forge] =
    {
        itemId = kForgeAxeItemId,
        displayName = "Forge",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/axe/axe_forge.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/axe/axe_view_forge.material",
        viewMaterialIndex = 1
    },
    
    [kAxeVariants.sandstorm] =
    {
        itemId = kSandstormAxeItemId,
        displayName = "Sandstorm",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/axe/axe_sandstorm.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/axe/axe_view_sandstorm.material",
        viewMaterialIndex = 1
    },

    [kAxeVariants.tundra] =
    {
        itemId = kTundraAxeItemId,
        displayName = "Tundra",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/axe/axe_tundra.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/axe/axe_view_tundra.material",
        viewMaterialIndex = 1
    },

    [kAxeVariants.kodiak] =
    {
        itemId = kKodiakAxeItemId,
        displayName = "Kodiak",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/axe/axe_kodiak.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/axe/axe_view_kodiak.material",
        viewMaterialIndex = 1
    },

    [kAxeVariants.chroma] =
    {
        itemId = kChromaAxeItemId,
        displayName = "Chroma",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/axe/axe_chroma.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/axe/axe_view_chroma.material",
        viewMaterialIndex = 1
    },

    [kAxeVariants.wood] =
    {
        itemId = kWoodAxeItemId,
        displayName = "Wood",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/axe/axe_wood.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/axe/axe_view_wood.material",
        viewMaterialIndex = 1
    },

    [kAxeVariants.damascus] =
    {
        itemId = kDamascusAxeItemId,
        displayName = "Damascus",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/axe/axe_damascus.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/axe/axe_view_damascus.material",
        viewMaterialIndex = 1
    },

    [kAxeVariants.damasgrn] =
    {
        itemId = kDamascusGreenAxeItemId,
        displayName = "Damascus Green",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/axe/axe_damas_grn.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/axe/axe_view_damas_grn.material",
        viewMaterialIndex = 1
    },

    [kAxeVariants.damaspurp] =
    {
        itemId = kDamascusPurpleAxeItemId,
        displayName = "Damascus Purple",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/axe/axe_damaspurp.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/axe/axe_view_damaspurp.material",
        viewMaterialIndex = 1
    },
}
kDefaultAxeVariant = kAxeVariants.normal

kFlamethrowerVariants = enum({ "normal", "kodiak", "tundra", "forge", "sandstorm", "chroma" })
kFlamethrowerVariantsData = 
{
    [kFlamethrowerVariants.normal] =
    {
        displayName = "Normal",
        modelFilePart = "",
        viewModelFilePart = "",
    },
    
    [kFlamethrowerVariants.forge] =
    {
        itemId = kForgeFlamethrowerItemId,
        displayName = "Forge",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/flamethrower/flamethrower_forge.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/flamethrower/flamethrower_view_forge.material"
    },
    
    [kFlamethrowerVariants.sandstorm] =
    {
        itemId = kSandstormFlamethrowerItemId,
        displayName = "Sandstorm",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/flamethrower/flamethrower_sandstorm.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/flamethrower/flamethrower_view_sandstorm.material",
    },

    [kFlamethrowerVariants.tundra] =
    {
        itemId = kTundraFlamethrowerItemId,
        displayName = "Tundra",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/flamethrower/flamethrower_tundra.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/flamethrower/flamethrower_view_tundra.material",
    },

    [kFlamethrowerVariants.kodiak] =
    {
        itemId = kKodiakFlamethrowerItemId,
        displayName = "Kodiak",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/flamethrower/flamethrower_kodiak.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/flamethrower/flamethrower_view_kodiak.material",
    },

    [kFlamethrowerVariants.chroma] =
    {
        itemId = kChromaFlamethrowerItemId,
        displayName = "Chroma",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/flamethrower/flamethrower_chroma.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/flamethrower/flamethrower_view_chroma.material",
    },
}
kDefaultFlamethrowerVariant = kFlamethrowerVariants.normal

kGrenadeLauncherVariants = enum({ "normal", "kodiak", "tundra", "forge", "sandstorm", "chroma" })
kGrenadeLauncherVariantsData =
{
    --Note: The VIEW materials do no specify and index because it is different for each
    --veriant of Marine Armors. The implementing mixin handles the view indices.

    [kGrenadeLauncherVariants.normal] =
    {
        displayName = "Normal",
        modelFilePart = "",
        viewModelFilePart = "",
    },

    [kGrenadeLauncherVariants.sandstorm] =
    {
        itemId = kSandstormGrenadeLauncherItemId,
        displayName = "Sandstorm",
        modelFilePart = "",   --Note: denotes _armor_ used, not Axe
        viewModelFilePart = "",
        worldMaterial = "models/marine/grenadelauncher/grenade_launcher_sandstorm.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/grenadelauncher/grenade_launcher_view_sandstorm.material"
    },

    [kGrenadeLauncherVariants.tundra] =
    {
        itemId = kTundraGrenadeLauncherItemId,
        displayName = "Tundra",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/grenadelauncher/grenade_launcher_tundra.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/grenadelauncher/grenade_launcher_view_tundra.material"
    },

    [kGrenadeLauncherVariants.forge] =
    {
        itemId = kForgeGrenadeLauncherItemId,
        displayName = "Forge",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/grenadelauncher/grenade_launcher_forge.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/grenadelauncher/grenade_launcher_view_forge.material"
    },

    [kGrenadeLauncherVariants.kodiak] =
    {
        itemId = kKodiakGrenadeLauncherItemId,
        displayName = "Kodiak",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/grenadelauncher/grenade_launcher_kodiak.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/grenadelauncher/grenade_launcher_view_kodiak.material"
    },

    [kGrenadeLauncherVariants.chroma] =
    {
        itemId = kChromaGrenadeLauncherItemId,
        displayName = "Chroma",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/grenadelauncher/grenade_launcher_chroma.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/grenadelauncher/grenade_launcher_view_chroma.material"
    },
    
}
kDefaultGrenadeLauncherVariant = kGrenadeLauncherVariants.normal

kWelderVariants = enum({ "normal", "kodiak", "tundra", "forge", "sandstorm", "chroma" })
kWelderVariantsData =
{
    [kWelderVariants.normal] =
    {
        displayName = "Normal",
        modelFilePart = "",
        viewModelFilePart = "",
    },
    
    [kWelderVariants.sandstorm] =
    {
        itemId = kSandstormWelderItemId,
        displayName = "Sandstorm",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/welder/welder_sandstorm.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/welder/welder_view_sandstorm.material"
    },

    [kWelderVariants.tundra] =
    {
        itemId = kTundraWelderItemId,
        displayName = "Tundra",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/welder/welder_tundra.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/welder/welder_view_tundra.material"
    },

    [kWelderVariants.forge] =
    {
        itemId = kForgeWelderItemId,
        displayName = "Forge",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/welder/welder_forge.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/welder/welder_view_forge.material"
    },

    [kWelderVariants.kodiak] =
    {
        itemId = kKodiakWelderItemId,
        displayName = "Kodiak",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/welder/welder_kodiak.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/welder/welder_view_kodiak.material"
    },

    [kWelderVariants.chroma] =
    {
        itemId = kChromaWelderItemId,
        displayName = "Chroma",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/welder/welder_chroma.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/welder/welder_view_chroma.material"
    },
}
kDefaultWelderVariant = kWelderVariants.normal

kHMGVariants = enum({ "normal", "kodiak", "tundra", "forge", "sandstorm", "chroma" })
kHMGVariantsData =
{
    [kHMGVariants.normal] =
    {
        displayName = "Normal",
        modelFilePart = "",
        viewModelFilePart = "",
    },
    
    [kHMGVariants.sandstorm] =
    {
        itemId = kSandstormHMGItemId,
        displayName = "Sandstorm",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/hmg/hmg_sandstorm.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/hmg/hmg_view_sandstorm.material"
    },

    [kHMGVariants.tundra] =
    {
        itemId = kTundraHMGItemId,
        displayName = "Tundra",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/hmg/hmg_tundra.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/hmg/hmg_view_tundra.material",
    },

    [kHMGVariants.forge] =
    {
        itemId = kForgeHMGItemId,
        displayName = "Forge",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/hmg/hmg_forge.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/hmg/hmg_view_forge.material",
    },

    [kHMGVariants.kodiak] =
    {
        itemId = kKodiakHMGItemId,
        displayName = "Kodiak",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/hmg/hmg_kodiak.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/hmg/hmg_view_kodiak.material",
    },

    [kHMGVariants.chroma] =
    {
        itemId = kChromaHMGItemId,
        displayName = "Chroma",
        modelFilePart = "",
        viewModelFilePart = "",
        worldMaterial = "models/marine/hmg/hmg_chroma.material",
        worldMaterialIndex = 0,
        viewMaterial = "models/marine/hmg/hmg_view_chroma.material",
    },
}
kDefaultHMGVariant = kHMGVariants.normal


kMarineStructureVariants = enum({ "Default", "Kodiak", "Tundra", "Forge", "Sandstorm", "Chroma" })
kMarineStructureVariantsData = 
{
    [ kMarineStructureVariants.Default ] = { displayName = "Normal" },
    [ kMarineStructureVariants.Sandstorm ] = 
    { 
        itemId = kSandstormStructuresId, 
        displayName = "Sandstorm",
        worldMaterials = 
        {
            ["CommandStation"] = 
            {
                { idx = 0, mat = "models/marine/command_station/command_station_sandstorm.material" },
                { idx = 1, mat = "models/marine/command_station/command_station_sandstorm_display.material" },
            },
        },
        --If worldMaterials [ClassName] is not a table, below index is used; otherwise, table 'idx' value is
        worldMaterialIndex = 0,
    },
    [ kMarineStructureVariants.Tundra ] = 
    { 
        itemId = kTundraStructuresItemId, 
        displayName = "Tundra",
        worldMaterials = 
        {
            ["CommandStation"] = 
            {
                { idx = 0, mat = "models/marine/command_station/command_station_tundra.material" },
                { idx = 1, mat = "models/marine/command_station/command_station_tundra_display.material" },
            },
        },
        worldMaterialIndex = 0,
    },
    [ kMarineStructureVariants.Forge ] = 
    { 
        itemId = kForgeStructuresItemId, 
        displayName = "Forge",
        worldMaterials = 
        {
            ["CommandStation"] = 
            {
                { idx = 0, mat = "models/marine/command_station/command_station_forge.material" },
                { idx = 1, mat = "models/marine/command_station/command_station_forge_display.material" },
            },
        },
        worldMaterialIndex = 0,
    },
    [ kMarineStructureVariants.Kodiak ] = 
    { 
        itemId = kKodiakMarineStructuresItemId,
        displayName = "Kodiak",
        worldMaterials = 
        {
            ["CommandStation"] = 
            {
                { idx = 0, mat = "models/marine/command_station/command_station_kodiak.material" },
                { idx = 1, mat = "models/marine/command_station/command_station_kodiak_display.material" },
            },
        },
        worldMaterialIndex = 0,
    },
    [ kMarineStructureVariants.Chroma ] = 
    { 
        itemId = kChromaCommandStationItemId,
        displayName = "Chroma",
        worldMaterials = 
        {
            ["CommandStation"] = 
            {
                { idx = 0, mat = "models/marine/command_station/command_station_chroma.material" },
                { idx = 1, mat = "models/marine/command_station/command_station_display_chroma.material" },
            },
        },
        worldMaterialIndex = 0,
    }
}
kDefaultMarineStructureVariant = kMarineStructureVariants.Default

kExtractorVariants = enum({ "Default", "Kodiak", "Tundra", "Forge", "Sandstorm", "Chroma" })
kExtractorVariantsData = 
{
    [ kExtractorVariants.Default ] = { displayName = "Normal" },
    [ kExtractorVariants.Sandstorm ] = 
    { 
        itemId = kSandstormStructuresId, 
        displayName = "Sandstorm",
        worldMaterial = "models/marine/extractor/extractor_sandstorm.material",
        worldMaterialIndex = 0,
    },
    [ kExtractorVariants.Tundra ] = 
    { 
        itemId = kTundraStructuresItemId, 
        displayName = "Tundra",
        worldMaterial = "models/marine/extractor/extractor_tundra.material",
        worldMaterialIndex = 0,
    },
    [ kExtractorVariants.Forge ] = 
    { 
        itemId = kForgeStructuresItemId, 
        displayName = "Forge",
        worldMaterial = "models/marine/extractor/extractor_forge.material",
        worldMaterialIndex = 0,
    },
    [ kExtractorVariants.Kodiak ] = 
    { 
        itemId = kKodiakMarineStructuresItemId,
        displayName = "Kodiak",
        worldMaterial = "models/marine/extractor/extractor_kodiak.material",
        worldMaterialIndex = 0,
    },
    [ kExtractorVariants.Chroma ] = 
    { 
        itemId = kChromaExtractorItemId,
        displayName = "Chroma",
        worldMaterial = "models/marine/extractor/extractor_chroma.material",
        worldMaterialIndex = 0,
    }
}
kDefaultExtractorVariant = kExtractorVariants.Default

kMarineMacVariants = enum({ "Default", "Chroma" })
kMarineMacVariantsData = 
{
    [ kMarineMacVariants.Default ] = { displayName = "Normal" },
    [ kMarineMacVariants.Chroma ] = 
    { 
        displayName = "Chroma",
        itemId = kChromaMacItemId,
        worldMaterial = "models/marine/mac/mac_chroma.material",
        worldMaterialIndex = 0
    },
}
kDefaultMarineMacVariant = kMarineMacVariants.Default

kMarineArcVariants = enum({ "Default", "Chroma" })
kMarineArcVariantsData = 
{
    [ kMarineArcVariants.Default ] = { displayName = "Normal" },
    [ kMarineArcVariants.Chroma ] = 
    { 
        displayName = "Chroma",
        itemId = kChromaArcItemId,
        worldMaterial = "models/marine/arc/arc_chroma.material",
        worldMaterialIndex = 0
    },
}
kDefaultMarineArcVariant = kMarineArcVariants.Default



kShoulderPadNames =
{
    "None",
    "Reinforced",
    "Shadow",
    "Globe",
    "Godar",
    "Saunamen",
    "Snails",
    "Titus",
    "Kodiak",
    "Reaper",
    "Tundra",
    "Eat your Greens",
    "Pumpkin Patch",
    "Leviathan",
    "Peeper",
    "Summer Gorge",
    "Haunted Babbler",
    "Mad Axe Gorge",
}

kShoulderPad2ItemId =
{
    0, -- no item required if you're not using a shoulder pad
    kReinforcedShoulderPatchItemId,
    kShadowShoulderPatchItemId,
    kNS2WC14GlobeShoulderPatchItemId,
    kGodarShoulderPatchItemId,
    kSaunamenShoulderPatchItemId,
    kSnailsShoulderPatchItemId,
    kTitusGamingShoulderPatchItemId,
    kKodiakShoulderPatchItemId,
    kReaperShoulderPatchItemId,
    kTundraShoulderPatchItemId,
    kRookieShoulderPatchItemId,
    kHalloween16ShoulderPatchItemId,
    kSNLeviathanPatchItemId,
    kSNPeeperPatchItemId,
    kSummerGorgePatchItemId,
    kHauntedBabblerPatchItemId,
    kBattleGorgeShoulderPatchItemId,
}


function GetHasShoulderPad(index, client)
    local itemId = kShoulderPad2ItemId[index]

    if not itemId then
        return false
    end

    if itemId == 0 then
        return true
    end

    return GetOwnsItem( itemId, client )
end

function GetShoulderPadIndexById(targetId)
    for index, id in ipairs(kShoulderPad2ItemId) do
        if targetId == id then
            return index
        end
    end
    return 1
end

function GetShoulderPadIndexByName(padName)
    for index, name in ipairs(kShoulderPadNames) do
        if name == padName then
            return index
        end
    end
    return 1
end


function GetMarineTypeLabel( type )
    assert(type)
    return kMarineVariantsBaseType[type]
end

function GetRoboticType( variant )
    assert(variant)
    assert(table.icontains(kRoboticMarineVariantIds, variant))
    return table.icontains( kBigMacVariantIds , variant) and kBigMacVariantType or kMilitaryMacVariantType
end

if Client then


--Global cache list of materials used for cosmetics material-swapping
--This only needed in Client context. Stores as "ClassName" -> VariantID -> world/view
--It's up to the consuming/calling objects to handle what material index each is assigned.
local kPrecachedCosmeticMaterials = {}  --IterDict?

Event.Hook("Console_dumpallcachedmaterials", function()
    Log("-----------------------------------------------------------")
    Log("\tPrecached Cosmetics Materials\n")
    for k,v in pairs(kPrecachedCosmeticMaterials) do
        Log("[%s]:", k)
        Log("%s",v)
        Log("")
    end
    Log("-----------------------------------------------------------\n")
end)

function PrecacheCosmeticMaterials( className, variantData )
    assert(className and className ~= "")
    assert(variantData)
    assert(type(variantData) == "table")

    if not kPrecachedCosmeticMaterials[className] then
        kPrecachedCosmeticMaterials[className] = {}
    end

    for varKey, varIdx in ipairs(variantData) do

        kPrecachedCosmeticMaterials[className][varKey] = {}

        if variantData[varKey].worldMaterial ~= nil then
            local worldMat = variantData[varKey].worldMaterial
            assert(worldMat)
            --Log("STR |    Precache[%s] for %s", worldMat, className)
            kPrecachedCosmeticMaterials[className][varKey].worldMaterial = PrecacheAsset(worldMat)
        end

        --Note: some variants have multiple class-names in their definition (e.g. Structures)
        if variantData[varKey].worldMaterials ~= nil  then
            local worldMats = variantData[varKey].worldMaterials[className]
            assert(worldMats)

            if type(worldMats) == "table" then

                kPrecachedCosmeticMaterials[className][varKey].worldMaterials = {}

                for i, v in ipairs(worldMats) do
                    assert(v.idx and type(v.idx) == "number")
                    assert(v.mat and type(v.mat) == "string")
                    --Log("TBL |    Precache[%s] for %s", v.mat, className)
                    table.insert( 
                        kPrecachedCosmeticMaterials[className][varKey].worldMaterials,
                        { idx = v.idx, mat = PrecacheAsset(v.mat) }
                    )
                end
            else
            --assumed string for single definitions
                --Log("STR |    Precache[%s] for %s", worldMats, className)
                kPrecachedCosmeticMaterials[className][varKey].worldMaterials = PrecacheAsset(worldMats)
            end
        end

        if variantData[varKey].viewMaterial ~= nil then
            local viewMat = variantData[varKey].viewMaterial
            assert(viewMat)
            --Log("STR |    Precache[%s] for %s", viewMat, className)
            kPrecachedCosmeticMaterials[className][varKey].viewMaterial = PrecacheAsset(viewMat)
        end

        if variantData[varKey].viewMaterials  ~= nil then
            local viewMats = variantData[varKey].viewMaterials
            if type(viewMats) == "table" then
            --View materials have to be handled on entity-by-entity basis (in respective mixins)
            --so just dumb-cache them here
                kPrecachedCosmeticMaterials[className][varKey].viewMaterials = {}

                if viewMats[className] and type(viewMats[className]) == "table" then
                    local classViewMats = viewMats[className]
                    for c,m in ipairs(classViewMats) do
                        assert(m and type(m) == "string")
                        --Log("TBL-View |    Precache[%s] for %s", m, className)
                        kPrecachedCosmeticMaterials[className][varKey].viewMaterials[c] = PrecacheAsset(m)
                    end
                else
                    for i,v in ipairs(viewMats) do
                        assert(v and type(v) == "string")
                        --Log("TBL-View |    Precache[%s] for %s", v, className)
                        if v ~= "" then
                        --allow for blank variants definitions
                            kPrecachedCosmeticMaterials[className][varKey].viewMaterials[i] = PrecacheAsset(v)
                        end
                    end
                end
            else
                Log("Warning: Invalid cosmetic definition, using viewMaterials with no table")
            end
        end

    end

end

function GetPrecachedCosmeticMaterial( className, variantId, viewOnly )
    --Log("GetPrecachedCosmeticMaterial( -- )")
    --Log("\t     className: %s", className)
    --Log("\t     variantId: %s", variantId)
    --Log("\t      viewOnly: %s", viewOnly)
    
    assert(className and className ~= "")
    assert(variantId)
    assert(kPrecachedCosmeticMaterials[className])
    assert(kPrecachedCosmeticMaterials[className][variantId])

    if viewOnly then
    --View Model material

        if kPrecachedCosmeticMaterials[className][variantId].viewMaterial then
            return kPrecachedCosmeticMaterials[className][variantId].viewMaterial
        end

        if kPrecachedCosmeticMaterials[className][variantId].viewMaterials then
            return kPrecachedCosmeticMaterials[className][variantId].viewMaterials
        end

        Log("ERROR: No view materials matched for Class[%s] of Variant[%s]", className, variantId)
        return false

    end

    if kPrecachedCosmeticMaterials[className][variantId].worldMaterial then
        return kPrecachedCosmeticMaterials[className][variantId].worldMaterial
    end

    if kPrecachedCosmeticMaterials[className][variantId].worldMaterials then
        return kPrecachedCosmeticMaterials[className][variantId].worldMaterials
    end

    Log("ERROR: No world materials matched for Class[%s] of Variant[%s]", className, variantId)
    return false
end

--Util to determine if the specific variant for a customizable object requires
--material swapping or if it uses a model (thus, baked materials)
function GetIsVariantMaterialSwapped( label, marineType, options )
    assert(label and type(label) == "string" and label ~= "")
    assert(options)

    local objType = string.lower(label)

    if objType == "tunnel" then
        return (
            options.alienTunnelsVariant ~= kAlienTunnelVariants.Default and
            options.alienTunnelsVariant ~= kAlienTunnelVariants.Shadow
        )
    end

    if objType == "skulk" then
        return (
            options.skulkVariant ~= kDefaultSkulkVariant and
            options.skulkVariant ~= kSkulkVariants.shadow
        )
    end

    if objType == "gorge" then
        return (
            options.gorgeVariant ~= kDefaultGorgeVariant and
            options.gorgeVariant ~= kGorgeVariants.shadow
        )
    end

    if objType == "lerk" then
        return (
            options.lerkVariant ~= kDefaultLerkVariant and
            options.lerkVariant ~= kLerkVariants.shadow
        )
    end

    if objType == "fade" then
        return (
            options.fadeVariant ~= kDefaultFadeVariant and
            options.fadeVariant ~= kFadeVariants.shadow
        )
    end

    if objType == "onos" then
        return (
            options.onosVariant ~= kDefaultOnosVariant and
            options.onosVariant ~= kOnosVariants.shadow
        )
    end

    if objType == "babbler" then
        return (
            options.babblerVariant ~= kDefaultBabblerVariant and
            options.babblerVariant ~= kBabblerVariants.Shadow
        )
    end

    if objType == "babbler_egg" then
        return (
            options.babblerEggVariant ~= kDefaultBabblerEggVariant and
            options.babblerEggVariant ~= kBabblerEggVariants.Shadow
        )
    end

    if objType == "hydra" then
        return (
            options.hydraVariant ~= kDefaultHydraVariant and
            options.hydraVariant ~= kHydraVariants.Shadow
        )
    end

    return false
end

--General Utility to fetch the materials and their associated model-indices for overridding
--Note: when a given model has multiple indices per skin, matIdx return value is always false
--and the matPath variable is a table with keys (zero indexed) as material indices
function GetCustomizableWorldMaterialData( label, marineType, options )
    assert(label and type(label) == "string" and label ~= "")
    assert(options)

    local matType = string.lower(label)
    local matPath = nil
    local matIdx = -1

--Marines------------------------------
    if matType == "axe" and options.axeVariant ~= kDefaultAxeVariant then
        matPath = GetPrecachedCosmeticMaterial( "Axe", options.axeVariant )
        matIdx = GetVariantWorldMaterialIndex( kAxeVariantsData, options.axeVariant )

    elseif matType == "welder" and options.welderVariant ~= kDefaultWelderVariant then
        matPath = GetPrecachedCosmeticMaterial( "Welder", options.welderVariant )
        matIdx = GetVariantWorldMaterialIndex( kWelderVariantsData, options.welderVariant )

    elseif matType == "pistol" and options.pistolVariant ~= kDefaultPistolVariant then
        matPath = GetPrecachedCosmeticMaterial( "Pistol", options.pistolVariant )
        matIdx = GetVariantWorldMaterialIndex( kPistolVariantsData, options.pistolVariant )

    elseif matType == "rifle" and options.rifleVariant ~= kDefaultRifleVariant then
        matPath = GetPrecachedCosmeticMaterial( "Rifle", options.rifleVariant )
        matIdx = GetVariantWorldMaterialIndex( kRifleVariantsData, options.rifleVariant )

    elseif matType == "shotgun" and options.shotgunVariant ~= kDefaultShotgunVariant then
        matPath = GetPrecachedCosmeticMaterial( "Shotgun", options.shotgunVariant )
        matIdx = GetVariantWorldMaterialIndex( kShotgunVariantsData, options.shotgunVariant )
    
    elseif matType == "flamethrower" and options.flamethrowerVariant ~= kDefaultFlamethrowerVariant then
        matPath = GetPrecachedCosmeticMaterial( "Flamethrower", options.flamethrowerVariant )
        matIdx = GetVariantWorldMaterialIndex( kFlamethrowerVariantsData, options.flamethrowerVariant )

    elseif matType == "grenadelauncher" and options.grenadeLauncherVariant ~= kDefaultGrenadeLauncherVariant then
        matPath = GetPrecachedCosmeticMaterial( "GrenadeLauncher", options.grenadeLauncherVariant )
        matIdx = GetVariantWorldMaterialIndex( kGrenadeLauncherVariantsData, options.grenadeLauncherVariant )

    elseif matType == "hmg" and options.hmgVariant ~= kDefaultHMGVariant then
        matPath = GetPrecachedCosmeticMaterial( "HeavyMachineGun", options.hmgVariant )
        matIdx = GetVariantWorldMaterialIndex( kHMGVariantsData, options.hmgVariant )

    elseif matType == "exo_mm" and options.exoVariant ~= kDefaultExoVariant then
        matPath = GetPrecachedCosmeticMaterial( "Minigun", options.exoVariant )
        matIdx = false

    elseif matType == "exo_rr" and options.exoVariant ~= kDefaultExoVariant then
        matPath = GetPrecachedCosmeticMaterial( "Railgun", options.exoVariant )
        matIdx = false

    elseif matType == "command_station" and options.marineStructuresVariant ~= kDefaultMarineStructureVariant then
    --CommandStation has multiple overrides per skin, so return table. It's keys are the material indices
        matPath = GetPrecachedCosmeticMaterial( "CommandStation", options.marineStructuresVariant )
        matIdx = false

    elseif matType == "extractor" and options.extractorVariant ~= kDefaultExtractorVariant then
        matPath = GetPrecachedCosmeticMaterial( "Extractor", options.extractorVariant )
        matIdx = GetVariantWorldMaterialIndex( kExtractorVariantsData, options.extractorVariant  )

    elseif matType == "mac" and options.macVariant ~= kDefaultMarineMacVariant then
        matPath = GetPrecachedCosmeticMaterial( "MAC", options.macVariant )
        matIdx = GetVariantWorldMaterialIndex( kMarineMacVariantsData, options.macVariant  )
        
    elseif matType == "arc" and options.arcVariant ~= kDefaultMarineArcVariant then
        matPath = GetPrecachedCosmeticMaterial( "ARC", options.arcVariant )
        matIdx = GetVariantWorldMaterialIndex( kMarineArcVariantsData, options.arcVariant  )

--Aliens-------------------------------

    elseif matType == "skulk" and options.skulkVariant ~= kDefaultSkulkVariant then
        matPath = GetPrecachedCosmeticMaterial( "Skulk", options.skulkVariant )
        matIdx = GetVariantWorldMaterialIndex( kSkulkVariantsData, options.skulkVariant )

    elseif matType == "gorge" and options.gorgeVariant ~= kDefaultGorgeVariant then
        matPath = GetPrecachedCosmeticMaterial( "Gorge", options.gorgeVariant )
        matIdx = GetVariantWorldMaterialIndex( kGorgeVariantsData, options.gorgeVariant )
    
    elseif matType == "lerk" and options.lerkVariant ~= kDefaultLerkVariant then
        matPath = GetPrecachedCosmeticMaterial( "Lerk", options.lerkVariant )
        matIdx = GetVariantWorldMaterialIndex( kLerkVariantsData, options.lerkVariant )

    elseif matType == "fade" and options.fadeVariant ~= kDefaultFadeVariant then
        matPath = GetPrecachedCosmeticMaterial( "Fade", options.fadeVariant )
        matIdx = GetVariantWorldMaterialIndex( kFadeVariantsData, options.fadeVariant )

    elseif matType == "onos" and options.onosVariant ~= kDefaultOnosVariant then
        matPath = GetPrecachedCosmeticMaterial( "Onos", options.onosVariant )
        matIdx = GetVariantWorldMaterialIndex( kOnosVariantsData, options.onosVariant )

    elseif matType == "hive" and options.alienStructuresVariant ~= kDefaultAlienStructureVariant then
        matPath = GetPrecachedCosmeticMaterial( "Hive", options.alienStructuresVariant )
        matIdx = GetVariantWorldMaterialIndex( kAlienStructureVariantsData, options.alienStructuresVariant  )

    elseif matType == "harvester" and options.harvesterVariant ~= kDefaultHarvesterVariant then
        matPath = GetPrecachedCosmeticMaterial( "Harvester", options.harvesterVariant )
        matIdx = GetVariantWorldMaterialIndex( kHarvesterVariantsData, options.harvesterVariant  )

    elseif matType == "egg" and options.eggVariant ~= kDefaultEggVariant then
        matPath = GetPrecachedCosmeticMaterial( "Egg", options.eggVariant )
        matIdx = GetVariantWorldMaterialIndex( kEggVariantsData, options.eggVariant  )

    elseif matType == "cyst" and options.cystVariant ~= kDefaultAlienCystVariant then
        matPath = GetPrecachedCosmeticMaterial( "Cyst", options.cystVariant )
        matIdx = GetVariantWorldMaterialIndex( kAlienCystVariantsData, options.cystVariant  )

    elseif matType == "drifter" and options.drifterVariant ~= kDefaultAlienDrifterVariant then
        matPath = GetPrecachedCosmeticMaterial( "Drifter", options.drifterVariant )
        matIdx = GetVariantWorldMaterialIndex( kAlienDrifterVariantsData, options.drifterVariant  )

    elseif matType == "drifter_egg" and options.drifterVariant ~= kDefaultAlienDrifterVariant then
        matPath = GetPrecachedCosmeticMaterial( "DrifterEgg", options.drifterVariant )
        matIdx = GetVariantWorldMaterialIndex( kAlienDrifterVariantsData, options.drifterVariant  )

    elseif matType == "tunnel" and options.alienTunnelsVariant ~= kDefaultAlienTunnelVariant then
        matPath = GetPrecachedCosmeticMaterial( "Tunnel", options.alienTunnelsVariant )
        matIdx = GetVariantWorldMaterialIndex( kAlienTunnelVariantsData, options.alienTunnelsVariant  )

    elseif matType == "babbler" and options.babblerVariant ~= kDefaultBabblerVariant then
        matPath = GetPrecachedCosmeticMaterial( "Babbler", options.babblerVariant )
        matIdx = GetVariantWorldMaterialIndex( kBabblerVariantsData, options.babblerVariant  )

    elseif matType == "babbler_egg" and options.babblerEggVariant ~= kDefaultBabblerEggVariant then
        matPath = GetPrecachedCosmeticMaterial( "BabblerEgg", options.babblerEggVariant )
        matIdx = GetVariantWorldMaterialIndex( kBabblerEggVariantsData, options.babblerEggVariant  )

    elseif matType == "hydra" and options.hydraVariant ~= kDefaultHydraVariant then
        matPath = GetPrecachedCosmeticMaterial( "Hydra", options.hydraVariant )
        matIdx = GetVariantWorldMaterialIndex( kHydraVariantsData, options.hydraVariant  )

    end

    return matPath, matIdx
end


end --End-Client



kHUDMode = enum({ "Full", "Low", "Minimal" })


--TODO Devise list (per object-type?) of all PURCHASABLE variants ONLY (merge with owned or check inline?)
---- Use to cycle prev/next, per a curPos in above list


-- standard update intervals for use with TimedCallback
-- The engine spreads out callbacks running at the same update interval to spread out any load. This works best if the number of
-- different intervals used is not too high (a hashmap(updateInterval->list of callbacks) is used).
-- The values are just advisory to keep people from choosing 0.45 and 0.55 instead of 0.5
kUpdateIntervalMinimal = 0.5
kUpdateIntervalLow = 0.1
kUpdateIntervalMedium = 0.05
kUpdateIntervalAnimation = 0.02
kUpdateIntervalFull = 0

kPlayerRankingRequestUrl = "http://hive2.ns2cdt.com/api/get/playerData/"
kHiveWhitelistRequestUrl = "http://hive2.ns2cdt.com/api/get/whitelistedServers/"

kFavoritesFileName = "FavoriteServers.json"
kHistoryFileName = "HistoryServers.json"
kRankedFileName = "RankedServers.json"
kBlockedFileName = "BlockedServers.json"

kMaxServerPasswordLength = 20

kHttpOpTimeoutErrorCode = 28
kHttpOpRefusedErrorCode = 7


--Thunderdome Globals Overrides - Only applicable when Client & Server have TD-mode enabled
--McG: This must _always_ be last in this file!
if Shared.GetThunderdomeEnabled() then
    Script.Load("lua/thunderdome/ThunderdomeGameGlobals.lua")
end