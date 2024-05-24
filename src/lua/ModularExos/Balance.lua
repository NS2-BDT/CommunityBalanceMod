--- Module pricing
kExoWelderCost = 15
kRailgunCost = 20
kPlasmaLauncherCost = 20
kMinigunCost = 25

--kExoFlamerCost = 30
kExoShieldCost = 15
kClawCost = 5
--kPhaseModuleCost = 15
kThrustersCost = 10
kArmorModuleCost = 10
kNanoModuleCost = 10
kExoNanoShieldCost = 10
kExoCatPackCost = 10

kMinigunMovementSlowdown = 1
kRailgunMovementSlowdown = 1

kNanoShieldPlayerDuration = 6

--- Exo
Exo.kExosuitArmor = kExosuitArmor
Exo.kExosuitArmorPerUpgradeLevel = kExosuitArmorPerUpgradeLevel
Exo.kVertThrust = 0
Exo.kHorizThrust = 250
Exo.kMaxSpeed = 6
Exo.kThrustersCooldownTime = 0.5
Exo.kThrusterDuration = 1

--- FUEL USAGE
--- rate could be effective seconds it takes to recharge/use 1 fuel
kExoFuelRechargeRate = 5
--- Exo-Jetpack
kExoThrusterMinFuel = 0.0 -- Energy Min
kExoThrusterFuelUsageRate = 3 --Energy Cost/s
--kExoThrusterLateralAccel = 50
--kExoThrusterVerticleAccel = 8

--- Exo-Nanoshield
kExoNanoShieldMinFuel = 0.99 -- Energy Min
kExoNanoShieldFuelUsageRate = 4 -- Energy Cost/s

--- Exo-Nanorepair
kExoRepairMinFuel = 0.01 -- Energy Min
kExoRepairPerSecond = 15
kExoRepairFuelUsageRate = 5 --Energy Cost/s
kExoRepairInterval = 0.5

--- Exo-Catpack
kExoCatPackMinFuel = 0.99 -- Energy Min
kExoCatPackFuelUsageRate = 4 --Energy Cost/s

--Tech Research

Exo.ExoShieldTech = kTechId.ExosuitTech
--Exo.ExoFlamerTech = kTechId.ExosuitTech
--Exo.ExoWelderTech = kTechId.ExosuitTech
Exo.RailgunTech = kTechId.ExosuitTech
Exo.PlasmaLauncherTech = kTechId.ExosuitTech
Exo.MinigunTech = kTechId.ExosuitTech
Exo.ArmorModuleTech = kTechId.ExosuitTech
--Exo.PhaseModuleTech = kTechId.ExosuitTech
Exo.ThrusterModuleTech = kTechId.ExosuitTech

--Weapons

--RAILGUN --
kRailgunWeight = 0.1      -- default 0.045
kRailgunDamage = 45 	  -- default 10
kRailgunChargeDamage = 15 -- default 140

-- CLAW
kClawWeight = 0.0 -- default 0.01
kClawDamage = 50 -- default 50

-- MINIGUN --
kMinigunDamage = 6 -- default 6
kMinigunDamageType = kDamageType.Heavy --original heavy
kMinigunWeight = 0.2 -- default 0.06
Minigun.kHeatUpRate = 0.3 -- default 0.3
Minigun.kCoolDownRate = 0.4 -- default 0.4

-- PLASMALAUNCHER --
kPlasmaT1LifeTime = 10
kPlasmaT2LifeTime = 10
kPlasmaT3LifeTime = 10

kPlasmaMinDirectDamage = 50
kPlasmaMaxDirectDamage = 70

kPlasmaSpeedMin = 20
kPlasmaSpeedMedian = 35
kPlasmaSpeedMax = 50

kPlasmaHitBoxRadiusMax = 0.495 -- Hitbox radius from center of projectile...
kPlasmaHitBoxRadiusMedian = 0.33
kPlasmaHitBoxRadiusMin = 0.165

kPlasmaDOTDamageMax = 40 -- DOT applied after direct damage
kPlasmaDOTDamageMin = 0
kPlasmaDOTDuration = 1.5
kPlasmaDOTInterval = 0.25

kPlasmaDamageRadius = 4 -- 4 is the pulse damage radius (matches pulse cinematic)

kPlasmaDamageType = kDamageType.Normal -- Damage type of DOT...

kPlasmaLauncherWeight = 0.1

---- FLAMETHROWER --
--kExoFlamerWeight = 0.15
--
--ExoFlamer.kConeWidth = 0.30
--ExoFlamer.kCoolDownRate = 0.15
--ExoFlamer.kDualGunHeatUpRate = 0.10
--ExoFlamer.kHeatUpRate = 0.10
--ExoFlamer.kFireRate = 1 / 3
--ExoFlamer.kTrailLength = 10.5
--ExoFlamer.kExoFlamerDamage = 20
--kExoFlamerRange = 10
--ExoFlamer.kDamageRadius = 1.8
--
---- WELDER --
--kExoWelderWeight = 0.02
--ExoWelder.kWeldRange = 4
--ExoWelder.kWelderEffectRate = 0.45
--ExoWelder.kHealScoreAdded = 2
--ExoWelder.kAmountHealedForPoints = 600
--ExoWelder.kWelderFireDelay = 0.2
--ExoWelder.kWelderDamagePerSecond = 15
--ExoWelder.kSelfWeldAmount = 3
--ExoWelder.kPlayerWeldRate = 30
--ExoWelder.kStructureWeldRate = 60
--
---- SHIELD --
kExoShieldWeight = 0.1
kExoShielMinFuel = 0.1
ExoShield.kHeatPerDamage = 0.0015

ExoShield.kHeatUndeployedDrainRate = 0.2
ExoShield.kHeatActiveDrainRate = 0.1
ExoShield.kHeatOverheatedDrainRate = 0.13
ExoShield.kHeatCombatDrainRate = 0.05
ExoShield.kCombatDuration = 2.5

ExoShield.kIdleBaseHeatMin = 0.0
ExoShield.kIdleBaseHeatMax = 0.2
ExoShield.kIdleBaseHeatMaxDelay = 10--30
ExoShield.kCombatBaseHeatExtra = 0.1
ExoShield.kOverheatCooldownGoal = 0

ExoShield.kCorrodeDamageScalar = 0.5 -- move to ModularExo_Balance.lua!

ExoShield.kContactEnergyDrainRateFixed = 0 -- X energy per second
ExoShield.kContactEnergyDrainRatePercent = 0.1 -- X% of energy per second

ExoShield.kShieldOnDelay = 0.1
ExoShield.kShieldToggleDelay = 0.1 -- prevent spamming (should be longer than kShieldOnDelay)

ExoShield.kShieldDistance = 2.2
--ExoShield.kShieldAnglePitchMin = math.rad(50) -- down
--ExoShield.kShieldAnglePitchMax = math.rad(50) -- up
ExoShield.kShieldHeightMin = 2.1 -- down
ExoShield.kShieldHeightMax = 1

ExoShield.kPhysBodyColCount = 6
ExoShield.kPhysBodyRowCount = 3
ExoShield.kShieldDepth = 0.1
ExoShield.kShieldEffectOnDelay = 1
ExoShield.kShieldEffectOffDelay = 0.6

-- Module weights
kArmorModuleWeight = 0.075
kThrustersWeight = 0.025
--kPhaseModuleWeight = 0.1
kNanoRepairWeight = 0.05
kCatPackWeight = 0.05
kNanoShieldWeight = 0.05
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
kBaseExoArmor = 200
kClawArmor = 0
kMinigunArmor = 100
kRailgunArmor = 25
kPlasmaLauncherArmor = 25
kThrustersArmor = 0
kArmorModuleArmor = 100
kCatPackArmor = 0
kNanoRepairArmor = 0
