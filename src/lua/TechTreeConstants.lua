-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\TechTreeConstants.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

---@class kTechId
kTechId = enum {

    'None', 'PingLocation',

    'VoteConcedeRound',

    'SpawnMarine', 'SpawnAlien', 'CollectResources', 'TransformResources', 'Research',

    -- General orders and actions ("Default" is right-click)
    'Default', 'Move', 'Patrol', 'Attack', 'Build', 'Construct', 'AutoConstruct', 'Grow', 'Cancel', 'Recycle', 'Consume', 'Weld', 'AutoWeld', 'Stop', 'SetRally', 'SetTarget', 'Follow', 'HoldPosition', 'FollowAlien',
    -- special mac order (follows the target, welds the target as priority and others in range)
    'FollowAndWeld',

    -- Alien specific orders
    'AlienMove', 'AlienAttack', 'AlienConstruct', 'Heal', 'AutoHeal',

    -- Commander menus for selected units
    'RootMenu', 'BuildMenu', 'AdvancedMenu', 'AssistMenu', 'MarkersMenu', 'UpgradesMenu', 'WeaponsMenu',

    -- Robotics factory menus
    'RoboticsFactoryARCUpgradesMenu', 'RoboticsFactoryMACUpgradesMenu', 'UpgradeRoboticsFactory',

    'ReadyRoomPlayer', 'ReadyRoomEmbryo', 'ReadyRoomExo',

    -- Doors
    'Door', 'DoorOpen', 'DoorClose', 'DoorLock', 'DoorUnlock',

    -- Misc
    'ResourcePoint', 'TechPoint', 'SocketPowerNode', 'Mine',

    ------------/
    -- Marines --
    ------------/

    -- Marine classes + spectators
    'Marine', 'Exo', 'MarineCommander', 'JetpackMarine', 'Spectator', 'AlienSpectator',

    -- Marine alerts (specified alert sound and text in techdata if any)
    'MarineAlertAcknowledge', 'MarineAlertNeedMedpack', 'MarineAlertNeedAmmo', 'MarineAlertNeedOrder', 'MarineAlertNeedStructure', 'MarineAlertHostiles', 'MarineCommanderEjected', 'MACAlertConstructionComplete',
    'MarineAlertSentryFiring', 'MarineAlertCommandStationUnderAttack',  'MarineAlertSoldierLost', 'MarineAlertCommandStationComplete',

    'MarineAlertInfantryPortalUnderAttack', 'MarineAlertSentryUnderAttack', 'MarineAlertStructureUnderAttack', 'MarineAlertExtractorUnderAttack', 'MarineAlertSoldierUnderAttack',

    'MarineAlertResearchComplete', 'MarineAlertManufactureComplete', 'MarineAlertUpgradeComplete', 'MarineAlertOrderComplete', 'MarineAlertWeldingBlocked', 'MarineAlertMACBlocked', 'MarineAlertNotEnoughResources', 'MarineAlertObjectiveCompleted', 'MarineAlertConstructionComplete',

    -- Marine orders
    'Defend',

    -- Special tech
    'TwoCommandStations', 'ThreeCommandStations',

    -- Marine tech
    'CommandStation', 'MAC', 'Armory', 'InfantryPortal', 'Extractor', 'ExtractorArmor', 'Sentry', 'ARC', 'SubmachinegunTech', 
    'PowerPoint', 'AdvancedArmoryUpgrade', 'Observatory', 'Detector', 'DistressBeacon', 'PhaseGate', 'RoboticsFactory', 'ARCRoboticsFactory', 'ArmsLab',
    'SentryBattery', 'PrototypeLab', 'AdvancedArmory', 'UpgradeToExoPrototypeLab', 'ExoPrototypeLab', 'ExosuitTech', 'UpgradeToInfantryPrototypeLab', 'InfantryPrototypeLab',

    -- Weapon tech
	'Submachinegun', 'DropSubmachinegun', 
    'AdvancedWeaponry', 'ShotgunTech', 'HeavyRifleTech', 'HeavyMachineGunTech', 'DetonationTimeTech', 'GrenadeLauncherTech', 'FlamethrowerTech', 'FlamethrowerAltTech', 'WelderTech', 'MinesTech',
    'GrenadeTech', 'ClusterGrenade', 'ClusterGrenadeProjectile', 'ClusterGrenadeProjectileFragment', 'GasGrenade', 'GasGrenadeProjectile', 'PulseGrenade', 'PulseGrenadeProjectile', 'ScanGrenade', 'ScanGrenadeProjectile',
    'DropWelder', 'DropMines', 'DropShotgun', 'DropHeavyMachineGun', 'DropGrenadeLauncher', 'DropFlamethrower',

    -- Marine buys
    'FlamethrowerAlt',

    -- Research
    'PhaseTech', 'MACSpeedTech', 'MACEMPTech', 'ARCArmorTech', 'ARCSplashTech', 'JetpackTech',
    'DualMinigunTech', 'DualMinigunExosuit', 'UpgradeToDualMinigun',
    'ClawRailgunTech', 'ClawRailgunExosuit',
    'DualRailgunTech', 'DualRailgunExosuit', 'UpgradeToDualRailgun',
	'CoresExosuitTech',
    'DropJetpack', 'DropExosuit',

    -- MAC (build bot) abilities
    'MACEMP', 'Welding',

    -- Weapons
    'Rifle', 'Pistol', 'Shotgun', 'HeavyMachineGun', 'Claw', 'Minigun', 'Railgun', 'GrenadeLauncher', 'Flamethrower', 'Axe', 'LayMines', 'Welder',

    -- Armor
    'Jetpack', 'JetpackFuelTech', 'JetpackArmorTech', 'Exosuit', 'ExosuitLockdownTech', 'ExosuitUpgradeTech',

    -- Activations
    'ARCDeploy', 'ARCUndeploy',

    -- Marine Commander abilities
    'NanoShield', 'PowerSurge', 'Scan', 'AmmoPack', 'MedPack', 'CatPack', 'SelectObservatory', 'ReversePhaseGate',

    ------------
    -- Aliens --
    ------------

    -- bio mass levels
    'Biomass', 'BioMassOne', 'BioMassTwo', 'BioMassThree', 'BioMassFour', 'BioMassFive', 'BioMassSix', 'BioMassSeven', 'BioMassEight', 'BioMassNine', 'BioMassTen', 'BioMassEleven', 'BioMassTwelve',
    -- those are available at the hive
    'ResearchBioMassOne', 'ResearchBioMassTwo', 'ResearchBioMassThree', 'ResearchBioMassFour',

    'DrifterEgg', 'Drifter',

    -- Alien lifeforms
    'Skulk', 'Gorge', 'Lerk', 'Fade', 'Onos', "AlienCommander", "AllAliens", "Hallucination", "DestroyHallucination",

    -- Special tech
    'TwoHives', 'ThreeHives', 'UpgradeToCragHive', 'UpgradeToShadeHive', 'UpgradeToShiftHive',

    'HydraSpike',

    'LifeFormMenu', 'SkulkMenu', 'GorgeMenu', 'LerkMenu', 'FadeMenu', 'OnosMenu',

    -- Alien structures
    'Hive', 'HiveHeal', 'CragHive', 'ShadeHive', 'ShiftHive','Harvester', 'Egg', 'Embryo', 'Hydra', 'Cyst', 'Clog', 'GorgeTunnel', 'EvolutionChamber',
    'GorgeEgg', 'LerkEgg', 'FadeEgg', 'OnosEgg',

    -- Infestation upgrades
    'MucousMembrane',

    -- personal upgrade levels
    'Shell', 'TwoShells', 'ThreeShells', 'SecondShell', 'ThirdShell', 'FullShell',
    'Veil', 'TwoVeils', 'ThreeVeils', 'SecondVeil', 'ThirdVeil', 'FullVeil',
    'Spur', 'TwoSpurs', 'ThreeSpurs', 'SecondSpur', 'ThirdSpur', 'FullSpur',

    -- Upgrade buildings and abilities (structure, upgraded structure, passive, triggered, targeted)
    'Crag', 'TwoCrags', 'CragHeal',
    'Whip', 'TwoWhips', 'EvolveBombard', 'WhipBombard', 'WhipBombardCancel', 'WhipBomb', 'Slap',
    'Shift', 'TwoShifts', 'SelectShift', 'EvolveEcho', 'ShiftHatch', 'ShiftEcho', 'ShiftEnergize',
    'Shade', 'TwoShades', 'EvolveHallucinations', 'ShadeDisorient', 'ShadeCloak', 'ShadePhantomMenu', 'ShadePhantomStructuresMenu',

    'DrifterCamouflage', 'DrifterCelerity', 'DrifterRegeneration',

    'CystCamouflage', 'CystCelerity', 'CystCarapace',

    'Return',

    'DefensivePosture', 'OffensivePosture', 'AlienMuscles', 'AlienBrain',

    'UpgradeSkulk', 'UpgradeGorge', 'UpgradeLerk', 'UpgradeFade', 'UpgradeOnos',

    'ContaminationTech', 'RuptureTech', 'BoneWallTech',

    -- Tunnnel Tech
    -- Warning: Don't change order or otherwise the tunnelmanager won't work properly
    'Tunnel', 'TunnelExit', 'TunnelRelocate', 'TunnelCollapse', 'InfestedTunnel', 'UpgradeToInfestedTunnel', 'TunnelTube',

    'BuildTunnelMenu',
    
    "BuildTunnelEntryOne", "BuildTunnelEntryTwo", "BuildTunnelEntryThree", "BuildTunnelEntryFour",
    "BuildTunnelExitOne", "BuildTunnelExitTwo", "BuildTunnelExitThree", "BuildTunnelExitFour",

    "SelectTunnelEntryOne", "SelectTunnelEntryTwo", "SelectTunnelEntryThree", "SelectTunnelEntryFour",
    "SelectTunnelExitOne", "SelectTunnelExitTwo", "SelectTunnelExitThree", "SelectTunnelExitFour",

    -- Skulk abilities
    'Bite', 'Sneak', 'Parasite', 'Leap', 'Xenocide',

    -- gorge abilities
    'Spit', 'Spray', 'BellySlide', 'BabblerTech', 'BuildAbility', 'BabblerAbility', 'Babbler', 'BabblerEgg', 'GorgeTunnelTech', 'BileBomb',  'WebTech', 'Web', 'HydraTech',

    -- lerk abilities
    'LerkBite', 'Cling', 'Spikes', 'Umbra', 'Spores',

    -- fade abilities
    'Swipe', 'Blink', 'ShadowStep', 'Vortex', 'Stab', 'MetabolizeEnergy', 'MetabolizeHealth',

    -- onos abilities
    'Gore', 'Smash', 'Charge', 'BoneShield', 'Stomp', 'Shockwave',

    -- echo menu
    'TeleportHydra', 'TeleportWhip', 'TeleportTunnel', 'TeleportCrag', 'TeleportShade', 'TeleportShift', 'TeleportVeil', 'TeleportSpur', 'TeleportShell', 'TeleportHive', 'TeleportEgg', 'TeleportHarvester',

    -- Whip movement
    'WhipRoot', 'WhipUnroot',

    ---- Alien abilities and upgrades

    --CragHive
    'Vampirism',
    'Carapace',
    'Regeneration',

    --ShadeHive
    'Aura',
    'Focus',
    'Camouflage',

    --ShiftHive
    'Crush',
    'Celerity',
    'Adrenaline',

    -- Alien alerts
    'AlienAlertNeedHarvester', 'AlienAlertNeedMist', 'AlienAlertNeedDrifter', 'AlienAlertNeedHealing', 'AlienAlertStructureUnderAttack', 'AlienAlertHiveUnderAttack', 'AlienAlertHiveDying', 'AlienAlertHarvesterUnderAttack',
    'AlienAlertLifeformUnderAttack', 'AlienAlertGorgeBuiltHarvester', 'AlienCommanderEjected',
    'AlienAlertOrderComplete',
    'AlienAlertNotEnoughResources', 'AlienAlertResearchComplete', 'AlienAlertManufactureComplete', 'AlienAlertUpgradeComplete', 'AlienAlertHiveComplete', 'AlienAlertNeedStructure',

    -- Pheromones
    'ThreatMarker', 'LargeThreatMarker', 'NeedHealingMarker', 'WeakMarker', 'ExpandingMarker',

    -- Infestation
    'Infestation',

    -- Commander abilities
    'NutrientMist', 'Rupture', 'BoneWall', 'Contamination', 'SelectDrifter', 'HealWave', 'CragUmbra', 'ShadeInk', 'EnzymeCloud', 'Hallucinate', 'SelectHallucinations', 'Storm',

    -- Alien Commander hallucinations
    'HallucinateDrifter', 'HallucinateSkulk', 'HallucinateGorge', 'HallucinateLerk', 'HallucinateFade', 'HallucinateOnos',
    'HallucinateHive', 'HallucinateWhip', 'HallucinateShade', 'HallucinateCrag', 'HallucinateShift', 'HallucinateHarvester', 'HallucinateHydra',

    -- Voting commands
    'VoteDownCommander1', 'VoteDownCommander2', 'VoteDownCommander3',

    'GameStarted',

    'DeathTrigger',
	
	-- CBM Techs
	'Resilience',

    'WhipAbility',

    'UpgradeToFortressCrag',
    'FortressCrag',
    'FortressCragAbility',

    
    'UpgradeToFortressShift',
    'FortressShift',
    'FortressShiftAbility',

    
    'UpgradeToFortressShade',
    'FortressShade',
    'ShadeHallucination',
	'ShadeSonar',

    
    'UpgradeToFortressWhip',
    'FortressWhip',
    'FortressWhipAbility',
	'FortressWhipCragPassive',
	'FortressWhipShiftPassive',
	'FortressWhipShadePassive',

	'ShellPassive',
	'SpurPassive',
	'VeilPassive',

    'HallucinateShell',
    'HallucinateSpur',
    'HallucinateVeil',
    'HallucinateEgg',
    'HallucinateCloning',
    'HallucinateRandom',

    --'ExoWelder',
    'ExoFlamer',
    'ExoShield',
    
    --'WeaponCache',
    --'MarineStructureAbility',
	
	'BabblerBombAbility',
    'BabblerBomb',

	'ShieldBatteryUpgrade',
	'ShieldBattery',
	'PuriProtocol',
	
	'DIS',
	
	'BattleMAC', 'BattleMACNanoShield', 'BattleMACCatPack', 'BattleMACHealingWave', 'BattleMACSpeedBoost',
	
	'UpgradeObservatory', 'AdvancedObservatory', 'CargoTech', 'CargoGate',
	
	'SyncTechOne', 'SyncTechTwo', 'SyncTechThree', 'SyncTechFour', 'SyncTechFive', 'SyncTechSix', 'SyncTechSeven', 'SyncTechEight', 'SyncTechNine', 'SyncTechTen', 'SyncTechEleven', 
	'SyncTechTwelve', 'SyncTechThirteen', 'SyncTechFourteen', 'SyncTechFifteen', 'SyncTechSixteen', 'SyncTechSeventeen', 'SyncTechEighteen', 'SyncTechNineteen', 'SyncTechTwenty', 'SyncTechTwentyone',

    -- Marine upgrades
    'Weapons1', 'Weapons2', 'Weapons3', 'AdvancedMarineSupport',
    'Armor1', 'Armor2', 'Armor3', 'NanoArmor',
	
	'Max', -- Unused, for legacy reasons, do NOT use!
}

kTechIdMax = kTechId.Max -- For legacy reasons, do NOT use!

kTechToBiomassLevel =
{
    [kTechId.BioMassOne]    = 1,
    [kTechId.BioMassTwo]    = 2,
    [kTechId.BioMassThree]  = 3,
    [kTechId.BioMassFour]   = 4,
    [kTechId.BioMassFive]   = 5,
    [kTechId.BioMassSix]    = 6,
    [kTechId.BioMassSeven]  = 7,
    [kTechId.BioMassEight]  = 8,
    [kTechId.BioMassNine]   = 9,
    [kTechId.BioMassTen]    = 10,
    [kTechId.BioMassEleven] = 11,
    [kTechId.BioMassTwelve] = 12,

    -- and inverse...
    [1]  = kTechId.BioMassOne,
    [2]  = kTechId.BioMassTwo,
    [3]  = kTechId.BioMassThree,
    [4]  = kTechId.BioMassFour,
    [5]  = kTechId.BioMassFive,
    [6]  = kTechId.BioMassSix,
    [7]  = kTechId.BioMassSeven,
    [8]  = kTechId.BioMassEight,
    [9]  = kTechId.BioMassNine,
    [10] = kTechId.BioMassTen,
    [11] = kTechId.BioMassEleven,
    [12] = kTechId.BioMassTwelve,
}

kBiomassResearchTechIds = set
{
    kTechId.ResearchBioMassOne,
    kTechId.ResearchBioMassTwo,
    kTechId.ResearchBioMassThree
}

kBioMassTechIdsSet = set
{
    kTechId.BioMassOne,
    kTechId.BioMassTwo,
    kTechId.BioMassThree,
    kTechId.BioMassFour,
    kTechId.BioMassFive,
    kTechId.BioMassSix,
    kTechId.BioMassSeven,
    kTechId.BioMassEight,
    kTechId.BioMassNine,
    kTechId.BioMassTen,
    kTechId.BioMassEleven,
    kTechId.BioMassTwelve
}

kTechToSyncLevel =
{
    [kTechId.SyncTechOne]       = 1,
    [kTechId.SyncTechTwo]       = 2,
    [kTechId.SyncTechThree]     = 3,
    [kTechId.SyncTechFour]      = 4,
    [kTechId.SyncTechFive]      = 5,
    [kTechId.SyncTechSix]       = 6,
    [kTechId.SyncTechSeven]     = 7,
    [kTechId.SyncTechEight]     = 8,
    [kTechId.SyncTechNine]      = 9,
    [kTechId.SyncTechTen]       = 10,
    [kTechId.SyncTechEleven]    = 11,
	[kTechId.SyncTechTwelve]    = 12,
	[kTechId.SyncTechThirteen]  = 13,
	[kTechId.SyncTechFourteen]  = 14,
	[kTechId.SyncTechFifteen]   = 15,
	[kTechId.SyncTechSixteen]   = 16,
	[kTechId.SyncTechSeventeen] = 17,
	[kTechId.SyncTechEighteen]  = 18,
	[kTechId.SyncTechNineteen]  = 19,
	[kTechId.SyncTechTwenty]    = 20,
	[kTechId.SyncTechTwentyone] = 21,

    -- and inverse...
    [1]  = kTechId.SyncTechOne,
    [2]  = kTechId.SyncTechTwo,
    [3]  = kTechId.SyncTechThree,
    [4]  = kTechId.SyncTechFour,
    [5]  = kTechId.SyncTechFive,
    [6]  = kTechId.SyncTechSix,
    [7]  = kTechId.SyncTechSeven,
    [8]  = kTechId.SyncTechEight,
    [9]  = kTechId.SyncTechNine,
    [10] = kTechId.SyncTechTen,
    [11] = kTechId.SyncTechEleven,
    [12] = kTechId.SyncTechTwelve,
    [13] = kTechId.SyncTechThirteen,
	[14] = kTechId.SyncTechFourteen,
	[15] = kTechId.SyncTechFifteen,
	[16] = kTechId.SyncTechSixteen,
	[17] = kTechId.SyncTechSeventeen,
	[18] = kTechId.SyncTechEighteen,
	[19] = kTechId.SyncTechNineteen,
	[20] = kTechId.SyncTechTwenty,
	[21] = kTechId.SyncTechTwentyone,
}

kSyncTechIdsSet = set
{
    kTechId.SyncTechOne,
    kTechId.SyncTechTwo,
    kTechId.SyncTechThree,
    kTechId.SyncTechFour,
    kTechId.SyncTechFive,
    kTechId.SyncTechSix,
    kTechId.SyncTechSeven,
    kTechId.SyncTechEight,
    kTechId.SyncTechNine,
    kTechId.SyncTechTen,
    kTechId.SyncTechEleven,
	kTechId.SyncTechTwelve,
	kTechId.SyncTechThirteen,
	kTechId.SyncTechFourteen,
	kTechId.SyncTechFifteen,
	kTechId.SyncTechSixteen,
	kTechId.SyncTechSeventeen,
	kTechId.SyncTechEighteen,
	kTechId.SyncTechNineteen,
	kTechId.SyncTechTwenty,
	kTechId.SyncTechTwentyone
}

function StringToTechId(string)
    return kTechId[string] or kTechId.None
end

-- Tech types
kTechType = enum({ 'Invalid', 'Order', 'Research', 'Upgrade', 'Action', 'Buy', 'Build', 'EnergyBuild', 'Manufacture', 'Activation', 'Menu', 'EnergyManufacture', 'PlasmaManufacture', 'Special', 'Passive' })

-- Button indices
kRecycleCancelButtonIndex   = 12
kMarineUpgradeButtonIndex   = 5
kAlienBackButtonIndex       = 8

kCommanderDefaultMenu = kTechId.BuildMenu