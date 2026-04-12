-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Balance.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/BalanceHealth.lua")
Script.Load("lua/BalanceMisc.lua")

kCBMaddon = true -- Enables Plasma Exo, AMAC, SPARC, SMG, Adv Obs, Adv Gate, Bio 5, and Fortress Structures

kTransformResourcesTime = 15
kTransformResourcesCost = 15
kTransformResourcesRate = 1

kDetectInterval = 0.5     -- Drifter and cyst cloaking update interval.
kCystDetectRange = 8      -- Shade Hive passive upgrade cyst detect range
kDrifterDetectRange = 3   -- Shade Hive passive upgrade drifter detect range

-- commander has  to stay in command structure for the first kCommanderMinTime seconds of each round
kCommanderMinTime = 30

kAutoBuildRate = 0.5

-- setting to true will prevent any placement and construction of marine structures on infested areas
kPreventMarineStructuresOnInfestation = false
kCorrodeMarineStructureArmorOnInfestation = true

kInfestationCorrodeDamagePerSecond = 30

kMaxSupply = 200
kSupplyPerTechpoint = 100

-- used as fallback
kDefaultBuildTime = 8

-- MARINE COSTS
kCommandStationCost = 15

kExtractorCost = 10

kExtractorArmorCost = 5
kExtractorArmorResearchTime = 20

kInfantryPortalCost = 20

kArmoryCost = 10
kArmsLabCost = 20

kAdvancedArmoryUpgradeCost = 25
kPrototypeLabCost = 25

kSentryCost = 7
kPowerNodeCost = 0

kMACCost = 3
kMineCost = 5
kDropMineCost = 5
kMineResearchCost  = 10
kTechEMPResearchCost = 0
kTechMACSpeedResearchCost = 10

kPowerPointBuildTime = 12

kWelderTechResearchTime = 15

kGrenadeTechResearchCost = 10
kGrenadeTechResearchTime = 45

kShotgunCost = 20
kShotgunDropCost = 20
kShotgunTechResearchCost = 20
kHeavyRifleTechResearchCost = 30
kHeavyMachineGunDropCost = 20
kHeavyMachineGunTechResearchCost = 20

kClusterGrenadeCost = 2
kGasGrenadeCost = 2
kPulseGrenadeCost = 2

kGrenadeLauncherCost = 20
kGrenadeLauncherDropCost = 20
kGrenadeLauncherTechResearchCost = 15
kDetonationTimeTechResearchCost = 15

kAdvancedWeaponryResearchCost = 10

kFlamethrowerCost = 20
kFlamethrowerDropCost = 20
kFlamethrowerTechResearchCost = 20

kRoboticsFactoryCost = 5
kUpgradeRoboticsFactoryCost = 10
kUpgradeRoboticsFactoryTime = 30
kARCCost = 15
kARCSplashTechResearchCost = 15
kARCArmorTechResearchCost = 15
kWelderTechResearchCost = 0
kWelderCost = 2
kWelderDropCost = 2

kPulseGrenadeDamageRadius = 4
kPulseGrenadeEnergyDamageRadius = 6
kPulseGrenadeDamage = 10
kPulseGrenadeEnergyDamage = 0
kPulseGrenadeDamageType = kDamageType.Normal
kPulseDOTDamage = 5 -- DOT applied after direct damage (20 total) - DISABLED
kPulseDOTDuration = 4.5
kPulseDOTInterval = 1

kClusterGrenadeDamageRadius = 8
kClusterGrenadeDamage = 72
kClusterGrenadeDamageType = kDamageType.ClusterFlame

kClusterFragmentDamageRadius = 5
kClusterFragmentDamage = 20
kClusterGrenadeFragmentDamageType = kDamageType.ClusterFlameFragment

kNerveGasDamagePerSecond = 50
kNerveGasDamageType = kDamageType.NerveGas
kNerveGasCloudRadius = 7

kJetpackCost = 15
kJetpackDropCost = 15
kJetpackTechResearchCost = 25
kJetpackFuelTechResearchCost = 15
kJetpackArmorTechResearchCost = 15

kExosuitTechResearchCost = 20
kExosuitLockdownTechResearchCost = 20

kExosuitCost = 40
kExosuitDropCost = 50
kClawRailgunExosuitCost = 40
kDualExosuitCost = 25
kDualRailgunExosuitCost = 55

kUpgradeToDualMinigunCost = 20
kUpgradeToDualRailgunCost = 20

kDualMinigunTechResearchCost = 25
kClawRailgunTechResearchCost = 30
kDualRailgunTechResearchCost = 30

kCatPackTechResearchCost = 15
kWeapons1ResearchCost = 20
kWeapons2ResearchCost = 30
kWeapons3ResearchCost = 40

kArmor1ResearchCost = 20
kArmor2ResearchCost = 30
kArmor3ResearchCost = 40
kNanoArmorResearchCost = 20

kRifleUpgradeTechResearchCost = 10

kObservatoryCost = 10
kPhaseGateCost = 15
kPhaseTechResearchCost = 10
kReversePGCooldown = 5

kResearchBioMassOneCost = 15
kBioMassOneTime = 25
kResearchBioMassTwoCost = 20
kBioMassTwoTime = 40
kResearchBioMassThreeCost = 40
kBioMassThreeTime = 60
kResearchBioMassFourCost = 190
kBioMassFourTime = 600

kHiveCost = 40

kHarvesterCost = 8

kShellCost = 15
kCragCost = 8

kSpurCost = 15
kShiftCost = 8

kVeilCost = 15
kShadeCost = 8

kWhipCost = 10
kEvolveBombardCost = 5

kGorgeCost = 10
kGorgeEggCost = 20
kLerkCost = 21
kLerkEggCost = 40
kFadeCost = 35
kFadeEggCost = 80
kOnosCost = 55
kOnosEggCost = 100

kSkulkUpgradeCost = 0
kGorgeUpgradeCost = 1
kLerkUpgradeCost = 3
kFadeUpgradeCost = 5
kOnosUpgradeCost = 8

kAlienAdrenalineEnergyRate = 10
kSkulkAdrenalineEnergyRate = 27
kGorgeAdrenalineEnergyRate = 13
kLerkAdrenalineEnergyRate = 13
kFadeAdrenalineEnergyRate = 15
kOnosAdrenalineEnergyRate = 15

kHydraCost = 0
kClogCost = 0
kGorgeTunnelCost = 3
kGorgeTunnelBuildTime = 18.5

kEnzymeCloudDuration = 3

kCrushCost = 0
kCarapaceCost = 0
kRegenerationCost = 0
kResilienceCost = 0

kCamouflageCost = 0
kAuraCost = 0
kFocusCost = 0

kSilenceCost = 0
kAdrenalineCost = 0
kCelerityCost = 0

kPlayingTeamInitialTeamRes = 60
kMaxTeamResources = 200

kMarineInitialIndivRes = 20
kAlienInitialIndivRes = 15
kCommanderInitialIndivRes = 0
kMaxPersonalResources = 100

kResourceTowerResourceInterval = 6
kTeamResourcePerTick = 1

kPlayerResPerInterval = 0.1

kKillTeamReward = 0
kPersonalResPerKill = 0

-- MARINE DAMAGE
kRifleDamage = 10
kRifleDamageType = kDamageType.Normal
kRifleClipSize = 50

kHeavyRifleCost = 30

kHeavyRifleDamage = 10
kHeavyRifleDamageType = kDamageType.Puncture
kHeavyRifleClipSize = 75

kHeavyMachineGunCost = 20

kHeavyMachineGunDamage = 7
kHeavyMachineGunDamageType = kDamageType.MachineGun
kHeavyMachineGunClipSize = 100
kHeavyMachineGunClipNum = 4
kHeavyMachineGunRange = 100
kHeavyMachineGunSecondaryRange = 1.1
kHeavyMachineGunSpread = Math.Radians(3.2)

kRifleMeleeDamage = 10
kRifleMeleeDamageType = kDamageType.Normal

-- 10 bullets per second
kPistolRateOfFire = 0.1
kPistolDamage = 20
kPistolDamageType = kDamageType.Normal
kPistolClipSize = 10
-- not used yet
kPistolMinFireDelay = 0.1

kPistolAltDamage = 40


kWelderDamagePerSecond = 30
kWelderDamageType = kDamageType.Flame
kWelderFireDelay = 0.2

kSelfWeldAmount = 5
kPlayerArmorWeldRate = 20

kAxeDamage = 27.5
kAxeDamageType = kDamageType.Structural


kGrenadeLauncherGrenadeDamage = 65
kGrenadeLauncherGrenadeDamageType = kDamageType.GrenadeLauncher
kGrenadeLauncherClipSize = 4
kGrenadeLauncherGrenadeDamageRadius = 4.8
kGrenadeLifetime = 2.0
kGrenadeUpgradedLifetime = 1.5

kShotgunFireRate = 0.88
kShotgunDamage = 11.33
kShotgunDamageType = kDamageType.Normal
kShotgunClipSize = 6
kShotgunBulletsPerShot = 13
kShotgunSpreadDistance = 10 --Gets used as z-axis value for spread vectors before normalization

kNadeLauncherClipSize = 4

kFlameRadius = 1.8

kFlamethrowerDamage = 9
kFlamethrowerDamageRadius = kFlameRadius
kFlamethrowerConeWidth = 0.3
kFlameThrowerEnergyDamage = 1
kFlamethrowerDamageType = kDamageType.Flame
kFlamethrowerClipSize = 50
kFlamethrowerRange = 9

kBurnDamagePerSecond = 8
kFlamethrowerBurnDuration = 2.1
kFlamethrowerMaxBurnDuration = 6


-- affects dual minigun and dual railgun damage output
kExoDualMinigunModifier = 1
kExoDualRailgunModifier = 1

kMinigunDamage = 6
kMinigunDamageType = kDamageType.Heavy

kClawDamage = 50
kClawDamageType = kDamageType.Structural

kRailgunDamage = 35
kRailgunChargeDamage = 35
kRailgunDamageType = kDamageType.Structural

kMACAttackDamage = 5
kMACAttackDamageType = kDamageType.Normal
kMACAttackFireDelay = 0.6

kMineDamage = 130
kMineDamageType = kDamageType.Normal

kSentryAttackDamageType = kDamageType.Light
kSentryAttackBaseROF = .15
kSentryAttackRandROF = 0.0
kSentryAttackBulletsPerSalvo = 1
kConfusedSentryBaseROF = 4
kSentryDamage = 3.5
kSentryAttackBulletsPerSalvo = 2

kARCDamage = 610
kARCDamageType = kDamageType.Splash -- splash damage hits friendly arcs as well
kARCRange = 26
kARCMinRange = 7
kMaxARCs = 5

local kDamagePerUpgradeScalar = 0.1
kWeapons1DamageScalar = 1 + kDamagePerUpgradeScalar
kWeapons2DamageScalar = 1 + kDamagePerUpgradeScalar * 2
kWeapons3DamageScalar = 1 + kDamagePerUpgradeScalar * 3

local kShotgunDamagePerUpgradeScalar = 0.0784
kShotgunWeapons1DamageScalar = 1 + kShotgunDamagePerUpgradeScalar
kShotgunWeapons2DamageScalar = 1 + kShotgunDamagePerUpgradeScalar * 2
kShotgunWeapons3DamageScalar = 1 + kShotgunDamagePerUpgradeScalar * 3

local kGrenadeLauncherDamagePerUpgradeScalar = 0.07
kGrenadeLauncherWeapons1DamageScalar = 1 + kGrenadeLauncherDamagePerUpgradeScalar
kGrenadeLauncherWeapons2DamageScalar = 1 + kGrenadeLauncherDamagePerUpgradeScalar * 2
kGrenadeLauncherWeapons3DamageScalar = 1 + kGrenadeLauncherDamagePerUpgradeScalar * 3

local kFlamethrowerDamagePerUpgradeScalar = 0.07
kFlamethrowerWeapons1DamageScalar = 1 + kFlamethrowerDamagePerUpgradeScalar
kFlamethrowerWeapons2DamageScalar = 1 + kFlamethrowerDamagePerUpgradeScalar * 2
kFlamethrowerWeapons3DamageScalar = 1 + kFlamethrowerDamagePerUpgradeScalar * 3

kNanoShieldDamageReductionDamage = 0.68


-- ALIEN DAMAGE

kAlienFocusUpgradeAttackDelay = 1 --FIXME Does not account for variable attack-rates
--(i.e. different attack rates of various alien abilities: Bite ~= Swipe)


kBiteDamage = 75
kBiteDamageType = kDamageType.Normal
kBiteEnergyCost = 5.85

kLeapEnergyCost = 45

kParasiteDamage = 10
kParasiteDamageType = kDamageType.Normal
kParasiteEnergyCost = 30
kParasiteFireRate = 0.54

kXenocideDamage = 200
kXenocideDamageType = kDamageType.Normal
kXenocideRange = 14
kXenocideEnergyCost = 30

kGorgeArmorTunnelDamagePerSecond = 10

kSpitSpeed = 45
kSpitDamage = 30
kSpitDamageType = kDamageType.Normal
kSpitEnergyCost = 7

kBabblerPheromoneEnergyCost = 7
kBabblerDamage = 8
kBabblerExplosionRange = 4
kBabblerExplosionDamage = 16
kBabblerDamageType = kDamageType.Normal
kBabblerCost = 0

kBabblerEggBuildTime = 4
kNumBabblerEggsPerGorge = 1
kBabblerEggDamage = 125 -- per second
kBabblerEggDamageType = kDamageType.Corrode
kBabblerEggDamageDuration = 3
kBabblerEggDamageRadius = 7
kBabblerEggDotInterval = 0.4

-- Also see kHealsprayHealStructureRate
kHealsprayDamage = 8
kHealsprayDamageType = kDamageType.Biological
kHealsprayFireDelay = 0.8
kHealsprayEnergyCost = 10
kHealsprayRadius = 3.5

kBileBombDamage = 55 -- per second
kBileBombDamageType = kDamageType.Corrode
kBileBombEnergyCost = 20
kBileBombDuration = 5
-- 200 inches in NS1 = 5 meters
kBileBombSplashRadius = 6
kBileBombDotInterval = 0.4

kWebBuildCost = 0
kWebbedDuration = 5
kWebbedParasiteDuration = 10
kWebSlowVelocityScalar = 0.34 --Note: Exos override this
kWebMaxCharges = 3
kWebSecondsPerCharge = 10
kWebHealthPerCharge = 10

kWebZeroVisDistance = 4.0
kWebFullVisDistance = 3.0
kWebDistortionFullVisDistance = kWebFullVisDistance + 0.5
kWebDistortionZeroVisDistance = kWebZeroVisDistance + 1.25
kWebDistortionIntensity = 0.0625
kWebChargeScaleAdditive = 0.47

kLerkBiteDamage = 60
kBitePoisonDamage = 6 -- per second
kPoisonBiteDuration = 6
kLerkBiteEnergyCost = 5
kLerkBiteDamageType = kDamageType.Normal

kUmbraEnergyCost = 27
kUmbraMaxRange = 17
kUmbraDuration = 2.5
kUmbraRadius = 4

kUmbraShotgunModifier = 0.8
kUmbraBulletModifier = 0.8
kUmbraMinigunModifier = 0.8
kUmbraRailgunModifier = 0.8
kUmbraGrenadeModifier = 0.8

kSpikeSpread = Math.Radians(3.3)
kSpikeSize = 0.045
kSpikeDamage = 5
kSpikeDamageType = kDamageType.Puncture
kSpikeEnergyCost = 1.4
kSpikesAttackDelay = 0.07
kSpikesRange = 50
kSpikesPerShot = 1

kSporesDamageType = kDamageType.Gas
kSporesDustDamagePerSecond = 15
kSporesDustFireDelay = 0.36
kSporesMaxRange = 17
kSporesDustEnergyCost = 27
kSporesDustCloudRadius = 4
kSporesDustCloudLifetime = 4

kSwipeDamageType = kDamageType.Puncture
kSwipeDamage = 37.5
kSwipeEnergyCost = 7
kMetabolizeEnergyCost = 10

kStabDamage = 120
kStabDamageType = kDamageType.Structural
kStabEnergyCost = 25

kStartBlinkEnergyCost = 12
kBlinkEnergyCost = 32
kHealthOnBlink = 0

kGoreDamage = 90
kGoreDamageType = kDamageType.Structural
kGoreEnergyCost = 10

kBoneShieldDamageReduction = 0.2 --80% for frontal, if it's on-screen(default fov) it's reduced
kBoneShieldCooldown = 16
kBoneShieldMinimumEnergyNeeded = 0
kBoneShieldMinimumFuel = 0.15
kBoneShieldMaxDuration = 8
kBoneShieldMoveFraction = 0.682 -- ~4.5 m/s
kBoneShieldInnateCombatRegenRate = 0
kBoneshieldPreventInnateRegen = true
kBoneShieldPreventEnergize = false
kBoneShieldPreventRecuperation = false

kStompEnergyCost = 30
kStompDamageType = kDamageType.Heavy
kStompDamage = 50
kStompRange = 12
kDisruptMarineTime = 2
kDisruptMarineTimeout = 4

kChargeDamage = 12

kDrifterAttackDamage = 5
kDrifterAttackDamageType = kDamageType.Normal
kDrifterAttackFireDelay = 0.6

kMelee1DamageScalar = 1.1
kMelee2DamageScalar = 1.2
kMelee3DamageScalar = 1.3

kWhipSlapDamage = 50
kWhipBombardDamage = 250
kWhipBombardDamageType = kDamageType.Corrode
kWhipBombardRadius = 6
kWhipBombardRange = 10
kWhipBombardROF = 6





-- SPAWN TIMES
kMarineRespawnTime = 9

kAlienSpawnTime = 10
kEggGenerationRate = 13
kAlienEggsPerHive = 2

-- delay of a single upgrade level after alien respawn
kUpgradeLevelDelayAtAlienRepawn = 4

-- BUILD/RESEARCH TIMES
kRecycleTime = 12
kConsumeTime = kRecycleTime
kArmoryBuildTime = 12
kAdvancedArmoryResearchTime = 90
kWeaponsModuleAddonTime = 40
kPrototypeLabBuildTime = 20
kArmsLabBuildTime = 17

kMACBuildTime = 5
kExtractorBuildTime = 11

kInfantryPortalBuildTime = 7

kShotgunTechResearchTime = 30
kHeavyRifleTechResearchTime = 60
kHeavyMachineGunTechResearchTime = 30
kGrenadeLauncherTechResearchTime = 20
kAdvancedWeaponryResearchTime = 35

kCommandStationBuildTime = 15

kSentryBatteryCost = 10
kSentryBatteryBuildTime = 5
kBatteryLimit = 2

kRoboticsFactoryBuildTime = 8
kARCBuildTime = 12.5
kARCSplashTechResearchTime = 30
kARCArmorTechResearchTime = 30

kNanoShieldPlayerDuration = 3
kNanoShieldStructureDuration = 5
kSentryBuildTime = 8
kSentryLimit = 1

kNanoShieldResearchCost = 15
kNanoSnieldResearchTime = 60

kMineResearchTime  = 20
kTechEMPResearchTime = 60
kTechMACSpeedResearchTime = 15

kJetpackTechResearchTime = 90
kJetpackFuelTechResearchTime = 60
kJetpackArmorTechResearchTime = 60
kExosuitTechResearchTime = 90
kExosuitLockdownTechResearchTime = 60
kExosuitUpgradeTechResearchTime = 60

kFlamethrowerTechResearchTime = 60

kDualMinigunTechResearchTime = 90
kClawRailgunTechResearchTime = 60
kDualRailgunTechResearchTime = 60
kCatPackTechResearchTime = 45

kObservatoryBuildTime = 10
kPhaseTechResearchTime = 45
kPhaseGateBuildTime = 12

kWeapons1ResearchTime = 75
kWeapons2ResearchTime = 90
kWeapons3ResearchTime = 120
kArmor1ResearchTime = 75
kArmor2ResearchTime = 90
kArmor3ResearchTime = 120

kNanoArmorResearchTime = 60

kHiveBuildTime = 180

kDrifterBuildTime = 4
kHarvesterBuildTime = 38

kShellBuildTime = 18
kCragBuildTime = 25

kWhipBuildTime = 20
kEvolveBombardResearchTime = 15

kSpurBuildTime = 16
kShiftBuildTime = 18

kVeilBuildTime = 14
kShadeBuildTime = 18
kEvolveHallucinationsResearchTime = 30

kHydraBuildTime = 8
kCystBuildTime = 3.33

kSkulkGestateTime = 3
kGorgeGestateTime = 7
kLerkGestateTime = 15
kFadeGestateTime = 25
kOnosGestateTime = 30

kEggGestateTime = 45

kEvolutionGestateTime = 3

-- alien ability research cost / time

kAlienBrainResearchCost = 35
kAlienBrainResearchTime = 90

kAlienMusclesResearchCost = 35
kAlienMusclesResearchTime = 90

kDefensivePostureResearchCost = 35
kDefensivePostureResearchTime = 90

kOffensivePostureResearchCost = 35
kOffensivePostureResearchTime = 90

kUpgradeSkulkResearchCost = 20
kUpgradeSkulkResearchTime = 90
kUpgradeGorgeResearchCost = 30
kUpgradeGorgeResearchTime = 90
kUpgradeLerkResearchCost = 35
kUpgradeLerkResearchTime = 90
kUpgradeFadeResearchCost = 35
kUpgradeFadeResearchTime = 120
kUpgradeOnosResearchCost = 35
kUpgradeOnosResearchTime = 120


kGorgeTunnelResearchCost = 15
kGorgeTunnelResearchTime = 40
kChargeResearchCost = 15
kChargeResearchTime = 40
kLeapResearchCost = 15
kLeapResearchTime = 40
kBileBombResearchCost = 15
kBileBombResearchTime = 40
kShadowStepResearchCost = 15
kShadowStepResearchTime = 40
kUmbraResearchCost = 30
kUmbraResearchTime = 75
kBoneShieldResearchCost = 25
kBoneShieldResearchTime = 40
kSporesResearchCost = 20
kSporesResearchTime = 60
kStompResearchCost = 35
kStompResearchTime = 90
kStabResearchCost = 20
kStabResearchTime = 60
kMetabolizeEnergyResearchCost = 20
kMetabolizeEnergyResearchTime = 40
kMetabolizeHealthResearchCost = 20
kMetabolizeHealthResearchTime = 45
kXenocideResearchCost = 25
kXenocideResearchTime = 60
kWebResearchCost = 10
kWebResearchTime = 60


kCommandStationInitialEnergy = 100  kCommandStationMaxEnergy = 250
kNanoShieldCost = 2
kNanoShieldCooldown = 10
kEMPCost = 50
kNanoShieldDamageReductionDamage = 0.68

kPowerSurgeResearchCost = 15
kPowerSurgeResearchTime = 45
kPowerSurgeCooldown = 4
kPowerSurgeDuration = 10
kPowerSurgeCost = 2

kPowerSurgeTriggerEMP = false
kPowerSurgeEMPDamage = 25
kPowerSurgeEMPDamageRadius = 6
kPowerSurgeEMPElectrifiedDuration = 6

kArmoryInitialEnergy = 100  kArmoryMaxEnergy = 150

kAdvancedMarineSupportResearchCost = 15
kAdvancedMarineSupportResearchTime = 60

kAmmoPackCost = 1
kMedPackCost = 1
kMedPackCooldown = 0
kCatPackCost = 1
kCatPackMoveAddSpeed = 1.125
kCatPackWeaponSpeed = 1.25
kCatPackDuration = 5
kCatPackPickupDelay = 4

kHiveInitialEnergy = 50  kHiveMaxEnergy = 200
kMatureHiveMaxEnergy = 250
kCystCost = 1
kCystCooldown = 0.0
kCystFlamableDamageMultiplier = 5

kDrifterInitialEnergy = 50
kDrifterMaxEnergy = 200

kEnzymeCloudCost = 2
kHallucinationCloudCost = 2
kMucousMembraneCost = 2
kStormCost = 2

kMucousShieldCooldown = 5
kMucousShieldPercent = 0.2
kMucousShieldDuration = 5

kBabblerShieldPercent = 0.1
kSkulkBabblerShieldPercent = 0.28
kGorgeBabblerShieldPercent = 0.13
kLerkBabblerShieldPercent = 0.14
kFadeBabblerShieldPercent = 0.16
kBabblerShieldMaxAmount = 85

kHallucinationLifeTime = 30 -- ignored, last indefinitely
kMaxHallucinations = 6

-- only allow x% of affected players to create a hallucination
kPlayerHallucinationNumFraction = 0.34
-- cooldown per entity
kHallucinationCloudCooldown = 3
kHallucinationCloudAbilityRadius = 7.5
kDrifterAbilityCooldown = 0
kHallucinationCloudAbilityCooldown = 10
kMucousMembraneAbilityCooldown = 3
kMucousMembraneAbilityRadius = 7.5
kEnzymeCloudAbilityCooldown = 3
kEnzymeCloudAbilityRadius = 7.5

kNutrientMistCost = 2
kNutrientMistCooldown = 2
-- Note: If kNutrientMistDuration changes, there is a tooltip that needs to be updated.
kNutrientMistDuration = 15

kRuptureCost = 3
kRuptureCooldown = 4
kRuptureParasiteTime = 10
kRuptureBurstTime = 1.25 --Time before rupture "pops"
kRuptureEffectTime = 1.5
kRuptureEffectDuration = 3
kRuptureEffectRadius = 8.7

kBoneWallCost = 3
kBoneWallCooldown = 10

kContaminationCost = 5
kContaminationCooldown = 3
kContaminationLifeSpan = 20
kContaminationBileInterval = 2
kContaminationBileSpewCount = 3


-- 100% + X (increases by 66%, which is 10 second reduction over 15 seconds)
kNutrientMistPercentageIncrease = 66
kNutrientMistMaturingIncrease = 66

kObservatoryInitialEnergy = 25  kObservatoryMaxEnergy = 100
kObservatoryScanCost = 3
kObservatoryDistressBeaconCost = 10

kMACInitialEnergy = 50  kMACMaxEnergy = 150
kDrifterCost = 8
kDrifterCooldown = 0
kDrifterHatchTime = 7

kDrifterBuildRate = 1.25

kTunnelEntranceCost = 8
kTunnelExitCost = 8
kTunnelRelocateCost = 6
kTunnelBuildTime = 18.5

kUpgradeInfestedTunnelEntranceCost = 6
kUpgradeInfestedTunnelEntranceResearchTime = 18.5

kCragInitialEnergy = 25  kCragMaxEnergy = 100 
kCragHealWaveCost = 3
kHealWaveCooldown = 6
kMatureCragMaxEnergy = 150

kHydraDamage = 15
kHydraAttackDamageType = kDamageType.Normal

kWhipInitialEnergy = 25  kWhipMaxEnergy = 100
kMatureWhipMaxEnergy = 150

kShiftInitialEnergy = 50  kShiftMaxEnergy = 150
kShiftHatchCost = 5
kShiftHatchRange = 11
kMatureShiftMaxEnergy = 200

kEchoHydraCost = 1
kEchoWhipCost = 2
kEchoTunnelCost = 5
kEchoCragCost = 1
kEchoShadeCost = 1
kEchoShiftCost = 1
kEchoVeilCost = 2
kEchoSpurCost = 2
kEchoShellCost = 2
kEchoHiveCost = 10
kEchoEggCost = 1
kEchoHarvesterCost = 2

kShadeInitialEnergy = 25  kShadeMaxEnergy = 100
kShadeInkCost = 3
kShadeInkCooldown = 15
kShadeInkDuration = 6.3
kMatureShadeMaxEnergy = 150

kEnergyUpdateRate = 0.5

-- This is for CragHive, ShadeHive and ShiftHive
kUpgradeHiveCost = 10
kUpgradeHiveResearchTime = 20

kHiveBiomass = 1

kCragBiomass = 0
kShadeBiomass = 0
kShiftBiomass = 0
kWhipBiomass = 0
kHarvesterBiomass = 0
kShellBiomass = 0
kVeilBiomass = 0
kSpurBiomass = 0

-- CBM Balance:
-- GL and FT for their playerdamage change have to be removed at damagetypes.lua from their special damage table "upgradedDamageScalars"
local kDamagePerUpgradeScalarStructure = 0.1 * 2
kWeapons1DamageScalarStructure = 1 + kDamagePerUpgradeScalarStructure
kWeapons2DamageScalarStructure = 1 + kDamagePerUpgradeScalarStructure * 2
kWeapons3DamageScalarStructure = 1 + kDamagePerUpgradeScalarStructure * 3

local kShotgunDamagePerUpgradeScalarStructure = 0.0784 * 2
kShotgunWeapons1DamageScalarStructure = 1 + kShotgunDamagePerUpgradeScalarStructure
kShotgunWeapons2DamageScalarStructure = 1 + kShotgunDamagePerUpgradeScalarStructure * 2
kShotgunWeapons3DamageScalarStructure = 1 + kShotgunDamagePerUpgradeScalarStructure * 3

-- Gorge energy reduction
kDropHydraEnergyCost = 30
kDropBabblerEggEnergyCost = 10

-- Reduced switching cost
kSkulkSwitchUpgradeCost = 0
kGorgeSwitchUpgradeCost = 1
kLerkSwitchUpgradeCost = 2
kFadeSwitchUpgradeCost = 3
kOnosSwitchUpgradeCost = 4

-- Chamber trait swapping
local kUpgradesGroupedByChamber = {
    { kTechId.Crush, kTechId.Celerity, kTechId.Adrenaline },
    { kTechId.Camouflage, kTechId.Aura, kTechId.Focus },
    { kTechId.Vampirism, kTechId.Resilience, kTechId.Regeneration },
}

kTraitsInChamberMap = {}
for _,chamberTraits in ipairs(kUpgradesGroupedByChamber) do
    for i = 1,3 do
        kTraitsInChamberMap[chamberTraits[i]] = chamberTraits
    end
end

-- CBM Content:
-- Fortress structures
kFortressUpgradeCost = 20
kFortressWhipUpgradeCost = 18
kFortressResearchTime = 25
kFortressAbilityCooldown = 10
kFortressHallucinationCooldown = 60
kFortressAbilityCost = 0

-- Fortress crag ability
kDouseShotgunModifier = 0.95
kDouseBulletModifier = 0.95
kDouseMinigunModifier = 0.95
kDouseRailgunModifier = 0.95
kDouseGrenadeModifier = 0.95

-- Fortress shift ability
kStormCloudDuration = 5

-- Fortress shade ability
kHallucinateCloningCost = 0
kHallucinateCloningCooldown = 1.5
kHallucinateRandomCost = 0
kHallucinateRandomCooldown = 1.5

-- Fortress whip ability / passives
kWhipAbilityCost = 0
kWhipAbilityCooldown = 10
kWhipWebbedDuration = 3.0
kWhipSiphonHealthAmount = 75

-- Babbler Bomb
kTimeBetweenBabblerBombShots = 1.15
kBabblerBombEnergyCost = 20
kBabblerBombVelocity = 15
kMaxNumBomblers = 6
kBomblerLifeTime = 5
kBabblerBombResearchTime = kBileBombResearchTime
kBabblerBombResearchCost = 15

-- ExoProtolab
kExoPrototypeLabResearchTime = 90
kExoPrototypeLabUpgradeCost = kExosuitTechResearchCost -- 20
kExoPrototypeLabHealth = kPrototypeLabHealth  -- 3000
kExoPrototypeLabArmor = kPrototypeLabArmor -- 500   
kExoPrototypeLabPointValue = kPrototypeLabPointValue -- 20

-- InfantryProtolab (depreciated)
kInfantryPrototypeLabResearchTime = kExosuitTechResearchTime -- 90
kInfantryPrototypeLabUpgradeCost = kExosuitTechResearchCost -- 20
kInfantryPrototypeLabHealth = kPrototypeLabHealth  -- 3000
kInfantryPrototypeLabArmor = kPrototypeLabArmor -- 500   
kInfantryPrototypeLabPointValue = kPrototypeLabPointValue -- 20

-- Modular Exos:
-- Module Pricing
kRailgunCost = 25
kPlasmaLauncherCost = 20
kExoFlamerCost = 15
kMinigunCost = 25
kExoShieldCost = 15
kClawCost = 15

kThrustersCost = 5
kArmorModuleCost = 5
kNanoModuleCost = 5
kExoNanoShieldCost = 5
kExoCatPackCost = 5
kEjectionSeatCost = 5

kMinigunMovementSlowdown = 1
kRailgunMovementSlowdown = 1
kMinigunFuelUsageScalar = 1 -- Usage commented out in Exo.lua
kRailgunFuelUsageScalar = 1 -- Usage commented out in Exo.lua

-- Exo Movement
kExosuitHorizontalThrusterAddSpeed = 2 -- 10
kExosuitThrusterHorizontalAcceleration = 200
kExosuitThrusterUpwardsAcceleration = 0
kExosuitMinTimeBetweenThrusterActivations = 0.5
kExosuitMaxSpeed = 7
kExosuitSpeedCap = 7.25
kExosuitDeployDuration = 1.4
kExoFuelRechargeRate = 5
kExoThrusterMinFuel = 0.25 -- Energy Min
kExoThrusterFuelUsageRate = 4 --Energy Cost/s
kExoThrusterStartFuelUsage = 0.1

-- Exo-Nanoshield (depreciated)
kExoNanoShieldMinFuel = 0.99 -- Energy Min
kExoNanoShieldFuelUsageRate = 4 -- Energy Cost/s

-- Exo-Nanorepair (depreciated)
kExoRepairMinFuel = 0.50 -- Energy Min
kExoRepairPerSecond = 15
kExoRepairFuelUsageRate = 5 --Energy Cost/s
kExoRepairInterval = 0.5

-- Exo-Catpack (depreciated)
kExoCatPackMinFuel = 0.99 -- Energy Min
kExoCatPackFuelUsageRate = 4 --Energy Cost/s

-- Exo Tech Research
kExoShieldTech = kTechId.ExosuitTech -- (depreciated)
kExoFlamerTech = kTechId.ExosuitTech -- (depreciated)
kRailgunTech = kTechId.ExosuitTech
kPlasmaLauncherTech = kTechId.ExosuitTech
kMinigunTech = kTechId.ExosuitTech
kArmorModuleTech = kTechId.ExosuitTech
kExoThrusterModuleTech = kTechId.ExosuitTech
kEjectionSeatModuleTech = kTechId.ExosuitTech
kCoreExosuitTechResearchCost = 25 -- (depreciated)
kCoreExosuitTechResearchTime = 60 -- (depreciated)

-- Plasmalauncher arm
kPlasmaT1LifeTime = 10
kPlasmaT2LifeTime = 10
kPlasmaT3LifeTime = 10

kPlasmaMultiSpeed = 45 -- (depreciated)
kPlasmaMultiDamage = 15
kPlasmaMultiDamageRadius = 2
kPlasmaMultiEnergyCost = 0.30

kPlasmaBombSpeed = 15
kPlasmaBombDamage = 35
kPlasmaBombDamageRadius = 4 -- 4 is the pulse damage radius (matches pulse cinematic)
kPlasmaBombEnergyCost = 0.80

kPlasmaBombDOTDamage = 5 -- DOT applied after direct damage
kPlasmaDOTDuration = 5.5
kPlasmaDOTInterval = 0.5

kPlasmaHitBoxRadiusT3 = 0.495 -- Hitbox radius from center of projectile...
kPlasmaHitBoxRadiusT2 = 0.33
kPlasmaHitBoxRadiusT1 = 0.10

kPlasmaLauncherEnergyUpRate = 0.25
kPlasmaDamageType = kDamageType.Normal 

kPlasmaLauncherWeight = 0.125

-- Blowtorch (depreciated)
kExoFlamerWeight = 0.05
kExoFlamerConeWidth = 2
kExoFlamerCoolDownRate = 0.20
kExoFlamerHeatUpRate = 0.10
kExoFlamerFireRate = 1 / 3
kExoFlamerTrailLength = 5.0
kExoFlamerExoFlamerDamage = 8
kExoFlamerRange = 7

kExoFlamerWelderSelfWeldAmount = 1 -- disabled
kExoFlamerWelderAmountHealedForPoints = 600
kExoFlamerWelderHealScoreAdded = 2
kExoFlamerWelderPlayerWeldRate = 20 -- 20 for welder
kExoFlamerWelderStructureWeldRate = 90 -- 90 for welder

kExoFlamerDamageType = kDamageType.Flame

-- Module weights
kArmorModuleWeight = 0.075 -- (depreciated)
kThrustersWeight = 0.025
kNanoRepairWeight = 0.05 -- (depreciated)
kCatPackWeight = 0.05 -- (depreciated)
kNanoShieldWeight = 0.05 -- (depreciated)
kEjectionSeatWeight = 0.025

-- Armor values
kBaseExoArmor = 170
kClawArmor = 75
kMinigunArmor = 75
kRailgunArmor = 25
kPlasmaLauncherArmor = 50
kExoFlamerWelderArmor = 0
kThrustersArmor = 0
kArmorModuleArmor = 100
kCatPackArmor = 0
kNanoRepairArmor = 0
kEjectionSeatArmor = 0
kExoLowHealthEjectThreshold = 0
kEjectorExosuitUseThreshold = 50
kEjectorExosuitMinArmor = 40 -- set minimum armor to ejector exo suit when auto ejecting

-- Advanced Observatory
kUpgradeAdvancedObservatoryCost = 10
kUpgradeObservatoryTime = 45
kAdvancedObservatoryPointValue = 15

-- Cargo Gate (depreciated)
kCargoGateSupply = 0
kCargoGateCost = 15
kCargoGateBuildTime = 20
kCargoGateEngagementDistance = 2
kCargoPhaseTechResearchCost = 10
kCargoPhaseTechResearchTime = 30
kCargoGateLimit = 2

-- Shielded Sentry Battery (depreciated)
kShieldBatteryUpgradeCost = 5
kShieldBatteryResearchTime = 10
kShieldedSentryBatterySupply = 10

-- Purification (depreciated)
kPurifcationChargeRate = 0.0011 -- 100%/(120s * 5LPBs)
kMinPurificationLPBs = 5
kMaintainPurificationLPBs = 2
kSentryBatteryInitialEnergy = 0
kSentryBatteryMaxEnergy = 100

-- SPARC
kDISCost = 10
kDISDamage = 5
kDISDamageType = kDamageType.Splash
kDISRange = 28
kDISMinRange = 7
kMaxDISs = 1
kDISBuildTime = 10
kDISEngagementDistance = 2
kDISSupply = 20
kDISDeployTime = 3
kDISUndeployTime = 3
kDISElectrifiedDuration = 6

-- Scan Grenade (depreciated)
kScanGrenadeTechResearchCost = 10
kScanGrenadeTechResearchTime = 30
kScanGrenadeCost = 2
kScanMiniRadius = 13
kScanMiniDuration = 4

-- SMG
kSMGDamage = 10.5
kSMGClipSize = 50
kSMGWeight = 0.05
kSubmachinegunCost = 5
kSubmachinegunDamageType = kDamageType.Normal
kSubmachinegunTechResearchCost = 10
kSubmachinegunTechResearchTime = 30
kSubmachinegunPointValue = 1
kSMGClipNum = 5
kSMGMeleeDamage = 30

-- MAC/Battle MAC
kBattleMACMoveSpeed = 8			-- MAC is 6
kBattleMACCombatMoveSpeed = 6
kBattleMACHealth = 400   		-- MAC is 300
kBattleMACArmor = 200    		-- MAC is 50
kBattleMACPointValue = 5		-- MAC is WhoCares
kBattleMACCost = 15				-- MAC is 3
kBattleMACInitialEnergy = 25
kBattleMACMaxEnergy = 100
kBattleMACEnergyRate = 1
kBattleMACBuildTime = 20
kBattleMACConstructEfficacy = .6

kBattleMACkCatPackDuration = 5
kBattleMACkNanoShieldDuration = 3
kBattleMACkHealingWaveDuration = 5
kBattleMACkSpeedBoostDuration = 3 -- (depreciated)

kBattleMACAbilityRadius = 6
kBattleMACHealingWaveAmount = 5 -- Per tick ?

kHealingWaveCost = 1
kCatPackFieldCost = 3 
kNanoShieldFieldCost = 3
kSpeedBoostCost = 0 -- (depreciated)

kNanoShieldFieldCooldown = 10
kCatPackFieldCooldown = 10
kHealingWaveCooldown = 10
kSpeedBoostCooldown = 10 -- (depreciated)

kMaxBattleMACs = 1
kBattleMACSupply = 20

if Shared.GetThunderdomeEnabled() then
    Script.Load("lua/thunderdome/ThunderdomeBalance.lua")
end