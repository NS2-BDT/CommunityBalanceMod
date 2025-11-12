-- Resilience
kResilienceCost = 0
kResilienceScalarBuffs = 0.3334
kResilienceScalarDebuffs = 0.3334
kAlienResilienceDamageReductionPercentByLevel = 10

-- FortressPvE
kFortressUpgradeCost = 20
kFortressResearchTime = 25
kFortressAbilityCooldown = 10
kFortressHallucinationCooldown = 60
kFortressAbilityCost = 0
kCragCost = 8
kShiftCost = 8
kShadeCost = 8
kWhipCost = 8

kCragUmbra = 5

kDouseShotgunModifier = 0.95
kDouseBulletModifier = 0.95
kDouseMinigunModifier = 0.95
kDouseRailgunModifier = 0.95
kDouseGrenadeModifier = 0.95

kMaxHallucinations = 6
kHallucinationLifeTime = 0.1 -- ignored, last indefinitely

kStormCloudDuration = 5

kWhipAbilityCost = 0
kWhipAbilityCooldown = 10
kWhipWebbedDuration = 3.0
kWhipSiphonHealthAmount = 75

kHallucinateCloningCost = 0
kHallucinateCloningCooldown = 1.5
kHallucinateRandomCost = 0
kHallucinateRandomCooldown = 1.5

-- ExoProtolab
kExoPrototypeLabResearchTime = 90
kExoPrototypeLabUpgradeCost = kExosuitTechResearchCost -- 20
kExoPrototypeLabHealth = kPrototypeLabHealth  -- 3000
kExoPrototypeLabArmor = kPrototypeLabArmor -- 500   
kExoPrototypeLabPointValue = kPrototypeLabPointValue -- 20

-- InfantryProtolab
kInfantryPrototypeLabResearchTime = kExosuitTechResearchTime -- 90
kInfantryPrototypeLabUpgradeCost = kExosuitTechResearchCost -- 20
kInfantryPrototypeLabHealth = kPrototypeLabHealth  -- 3000
kInfantryPrototypeLabArmor = kPrototypeLabArmor -- 500   
kInfantryPrototypeLabPointValue = kPrototypeLabPointValue -- 20
kJetpackCost = 15

-- Advanced Observatory
kUpgradeAdvancedObservatoryCost = 10
kUpgradeObservatoryTime = 60
kAdvancedObservatoryHealth = 1000
kAdvancedObservatoryArmor = 500
kAdvancedObservatoryPointValue = 15

-- Cargo Gate
kCargoGateSupply = 0
kCargoGateCost = 15
kCargoGateBuildTime = 20
kCargoGateHealth = 1500
kCargoGateArmor = 1000
kCargoGateEngagementDistance = 2
kCargoGatePointValue = 15
kCargoPhaseTechResearchCost = 10
kCargoPhaseTechResearchTime = 30
kCargoGateLimit = 2

-- MDS Marines only
kARCDamage = 610 -- vanilla 530 (Also in Arc Files now when enabled)
kFlamethrowerDamage = 9 --vanilla 9.918
kGrenadeLauncherGrenadeDamage = 65 --vanilla 74.381

-- GL and FT for their playerdamage change have to be removed at damagetypes.lua from their special damage table "upgradedDamageScalars"
local kDamagePerUpgradeScalarStructure = 0.1 * 2
kWeapons1DamageScalarStructure = 1 + kDamagePerUpgradeScalarStructure
kWeapons2DamageScalarStructure = 1 + kDamagePerUpgradeScalarStructure * 2
kWeapons3DamageScalarStructure = 1 + kDamagePerUpgradeScalarStructure * 3

local kShotgunDamagePerUpgradeScalarStructure = 0.0784 * 2
kShotgunWeapons1DamageScalarStructure = 1 + kShotgunDamagePerUpgradeScalarStructure
kShotgunWeapons2DamageScalarStructure = 1 + kShotgunDamagePerUpgradeScalarStructure * 2
kShotgunWeapons3DamageScalarStructure = 1 + kShotgunDamagePerUpgradeScalarStructure * 3

-- Weapon costs
kShotgunCost = 20
kShotgunTechResearchTime = 30
kFlamethrowerCost = 20
kGrenadeLauncherCost = 20
kHeavyMachineGunCost = 20

-- Gorge energy reduction
kDropHydraEnergyCost = 28 -- vanilla 40
kDropBabblerEggEnergyCost = 10 -- vanilla 15

-- DIS / ARC
kDISCost = 10
kDISDamage = 5
kDISDamageType = kDamageType.Splash
kDISRange = 28
kDISMinRange = 7
kMaxDISs = 1
kDISBuildTime = 10
kARCBuildTime = 12.5 -- vanilla: 10
kUpgradeRoboticsFactoryTime = 30

-- Buffs
kPulseGrenadeDamage = 20 -- vanilla: 50
kPulseDOTDamage = 4 -- DOT applied after direct damage (20 total)
kPulseDOTDuration = 5.5
kPulseDOTInterval = 1
kPulseDamageType = kDamageType.Normal 
kPulseGrenadeEnergyDamageRadius = 6 -- 4
kDropMineCost = 5 --7
kWelderDropCost = 2 -- 7
kStabEnergyCost = 25 --30
kStabResearchCost = 20 -- 25
kAxeDamage = 30

kScanGrenadeTechResearchCost = 10
kScanGrenadeTechResearchTime = 30
kScanGrenadeCost = 2

kAdvancedMarineSupportResearchCost = 15 -- 20
kNanoShieldCost = 2 --3

kMucousMembraneAbilityRadius = 6.5 -- 5

-- Nerfs
kClusterGrenadeDamageRadius = 8 --10
kClusterFragmentDamageRadius = 5 -- 6

-- Reduced switching cost
kSkulkSwitchUpgradeCost = 0
kGorgeSwitchUpgradeCost = 1
kLerkSwitchUpgradeCost = 2
kFadeSwitchUpgradeCost = 3
kOnosSwitchUpgradeCost = 4

-- Not really the right place for this but it'll be fine
local kUpgradesGroupedByChamber = {
    { kTechId.Crush, kTechId.Celerity, kTechId.Adrenaline },
    { kTechId.Camouflage, kTechId.Aura, kTechId.Focus },
    { kTechId.Vampirism, kTechId.Resilience, kTechId.Regeneration },
--    { kTechId.Vampirism, kTechId.Carapace, kTechId.Regeneration },
}

kTraitsInChamberMap = {}
for _,chamberTraits in ipairs(kUpgradesGroupedByChamber) do
    for i = 1,3 do
        kTraitsInChamberMap[chamberTraits[i]] = chamberTraits
    end
end


-- ====**** Arcs\Balance.lua ****====
-- kARCDamage = 1000 -- 610 vanilla MDS
-- kMaxARCs = 3 -- 5 vanilla
-- kARCCost = 25 -- 15 vanilla

-- kARCBuildTime = 15 -- 10 vanilla

-- Stomp
kStompDamage = 50 -- vanilla: 40


-- Module pricing
kExoWelderCost = 15
kRailgunCost = 25
kPlasmaLauncherCost = 20
kExoFlamerCost = 15
kMinigunCost = 25


kExoShieldCost = 15
kClawCost = 0
--kPhaseModuleCost = 15
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

kNanoShieldPlayerDuration = 6

-- Exo
kExosuitHorizontalThrusterAddSpeed = 2 -- 10
kExosuitThrusterHorizontalAcceleration = 200
kExosuitThrusterUpwardsAcceleration = 0
kExosuitMinTimeBetweenThrusterActivations = 0.5
kExosuitMaxSpeed = 7
kExosuitSpeedCap = 7.25
kExosuitDeployDuration = 1.4

-- FUEL USAGE
--- rate could be effective seconds it takes to recharge/use 1 fuel
kExoFuelRechargeRate = 5
-- Exo-Jetpack
kExoThrusterMinFuel = 0.25 -- Energy Min
kExoThrusterFuelUsageRate = 4 --Energy Cost/s
--kExoThrusterLateralAccel = 50
--kExoThrusterVerticleAccel = 8

-- Exo-Nanoshield
kExoNanoShieldMinFuel = 0.99 -- Energy Min
kExoNanoShieldFuelUsageRate = 4 -- Energy Cost/s

-- Exo-Nanorepair
kExoRepairMinFuel = 0.50 -- Energy Min
kExoRepairPerSecond = 15
kExoRepairFuelUsageRate = 5 --Energy Cost/s
kExoRepairInterval = 0.5

-- Exo-Catpack
kExoCatPackMinFuel = 0.99 -- Energy Min
kExoCatPackFuelUsageRate = 4 --Energy Cost/s

--Tech Research
kExoShieldTech = kTechId.ExosuitTech
kExoFlamerTech = kTechId.ExosuitTech
--kExoWelderTech = kTechId.ExosuitTech
kRailgunTech = kTechId.ExosuitTech
kPlasmaLauncherTech = kTechId.ExosuitTech
kMinigunTech = kTechId.ExosuitTech
kArmorModuleTech = kTechId.ExosuitTech
--kExoPhaseModuleTech = kTechId.ExosuitTech
kExoThrusterModuleTech = kTechId.ExosuitTech
kEjectionSeatModuleTech = kTechId.ExosuitTech

--Exo Tech
kDualExosuitCost = 25
kCoreExosuitTechResearchCost = 25
kCoreExosuitTechResearchTime = 60
kDualMinigunTechResearchCost = 25
kDualMinigunTechResearchTime = 90

--RAILGUN --
kRailgunWeight = 0.1      -- default 0.045
kRailgunDamage = 35 	  -- default 10
kRailgunChargeDamage = 35 -- default 140

-- CLAW
kClawWeight = 0.0 -- default 0.01
kClawDamage = 50 -- default 50

-- MINIGUN --
kMinigunWeight = 0.2 -- default 0.06

-- PLASMALAUNCHER --
kPlasmaT1LifeTime = 10
kPlasmaT2LifeTime = 10
kPlasmaT3LifeTime = 10

kPlasmaMultiSpeed = 45
kPlasmaMultiDamage = 15 -- 12.5
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

kPlasmaLauncherEnergyUpRate = 0.2
kPlasmaDamageType = kDamageType.Normal 

kPlasmaLauncherWeight = 0.125

---- FLAMETHROWER "BLOW TORCH" --
kExoFlamerWeight = 0.05
kExoFlamerConeWidth = 2
kExoFlamerCoolDownRate = 0.20
--kExoFlamerDualGunHeatUpRate = 0.10
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


--
---- WELDER --
--kExoWelderWeight = 0.02
--kExoWelderWeldRange = 4
--kExoWelderWelderEffectRate = 0.45
--kExoWelderHealScoreAdded = 2
--kExoWelderAmountHealedForPoints = 600
--kExoWelderWelderFireDelay = 0.2
--kExoWelderWelderDamagePerSecond = 15
--kExoWelderSelfWeldAmount = 3
--kExoWelderPlayerWeldRate = 30
--kExoWelderStructureWeldRate = 60

-- Module weights
kArmorModuleWeight = 0.075
kThrustersWeight = 0.025
--kPhaseModuleWeight = 0.1
kNanoRepairWeight = 0.05
kCatPackWeight = 0.05
kNanoShieldWeight = 0.05
kEjectionSeatWeight = 0.025
--kExoBuilderWeight = 0.01

---- Exo Building
--kExoBuilderCost = 15
--kWeaponCacheHealth = 600
--kWeaponCacheArmor = 150
--kWeaponCachePointValue = 100
--kNumArmoriesPerPlayer = 1
--kMarineBuildRadius = 3
--kNumSentriesPerPlayer = 1

--Armor values
kBaseExoArmor = 170
kExosuitArmorPerUpgradeLevel = 40
kClawArmor = 0
kMinigunArmor = 75
kRailgunArmor = 25
kPlasmaLauncherArmor = 50
kExoFlamerWelderArmor = 0
kThrustersArmor = 0
kArmorModuleArmor = 100
kCatPackArmor = 0
kNanoRepairArmor = 0
kEjectionSeatArmor = 0
kExoLowHealthEjectThreshold = 0 --50
kEjectorExosuitUseThreshold = 50 --100
kEjectorExosuitMinArmor = 40 -- set minimum armor to ejector exo suit when auto ejecting

kHallucinationCloudAbilityCooldown = 10

--Babbler Bomb
kTimeBetweenBabblerBombShots = 1.15 --- starting point 2.5

kBabblerBombEnergyCost = 20 --Starting point 35
kBabblerBombVelocity = 15 --Starting point 15

kMaxNumBomblers = 6 --Starting point 6
kBomblerLifeTime = 5 --Starting point 5

kBabblerBombResearchTime = kBileBombResearchTime
kBabblerBombResearchCost = 15

-- Sentry / Battery Stuffz
kSentryCost = 7
kSentryBuildTime = 8
kSentryLimit = 2
kSentryRange = 20
kSentryBuildRange = 25 
kSentryAttackBulletsPerSalvo = 2
kSentryDamage = 2.5
kSentryAttackDamageType = kDamageType.Light

kBatteryLimit = 2
kSentryBatteryCost = 10

-- Rifle Stuffz
kRifleDamageType = kDamageType.Normal

-- SMG Stuffz
kSMGDamage = 10
kSMGClipSize = 50
kSMGWeight = 0.05
kSubmachinegunCost = 5
kSubmachinegunDamageType = kDamageType.Normal
kSubmachinegunTechResearchCost = 10
kSubmachinegunTechResearchTime = 30
kSubmachinegunPointValue = 1
kSMGClipNum = 5
kSMGMeleeDamage = 30

-- MAC/Battle MAC Stuffz
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

kBattleMACkCatPackDuration = 5
kBattleMACkNanoShieldDuration = 3
kBattleMACkHealingWaveDuration = 5
kBattleMACkSpeedBoostDuration = 3

kBattleMACAbilityRadius = 6
kBattleMACHealingWaveAmount = 5 -- Per tick ?

kHealingWaveCost = 1
kCatPackFieldCost = 3 
kNanoShieldFieldCost = 3
kSpeedBoostCost = 0

kNanoShieldFieldCooldown = 10
kCatPackFieldCooldown = 10
kHealingWaveCooldown = 10
kSpeedBoostCooldown = 10

kMaxBattleMACs = 1
kBattleMACSupply = 20

-- Bio 5 Hive
kResearchBioMassFourCost = 120
kBioMassFourTime = 300
