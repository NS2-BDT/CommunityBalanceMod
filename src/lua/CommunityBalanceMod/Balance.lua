-- ====**** CommunityBalanceModRefactor\Balance.lua ****====
-- ====**** Resilience\Balance.lua ****====
-- Resilience
kResilienceCost = 0
kResilienceScalarBuffs = 0.3334
kResilienceScalarDebuffs = 0.3334
kAlienResilienceDamageReductionPercentByLevel = 10

-- ====**** FortressPvE\Balance.lua ****====


-- FortressPvE
kFortressUpgradeCost = 24
kFortressResearchTime = 25
kFortressAbilityCooldown = 10
kFortressAbilityCost = 0
kCragCost = 8
kShiftCost = 8
kShadeCost = 8
kWhipCost = 8


kCragUmbra = 5

kMaxHallucinations = 6
kHallucinationLifeTime = 0.1 -- ignored, last indefinitely

kStormCloudDuration = 5

kWhipAbilityCost = 2
kWhipAbilityCooldown = 10

kHallucinateCloningCost = 0
kHallucinateCloningCooldown = 1.5
kHallucinateRandomCost = 0
kHallucinateRandomCooldown = 1.5

-- ====**** AdvancedPrototypelab\Balance.lua ****====

-- Advanced Protolab
kAdvancedPrototypeLabResearchTime = kExosuitTechResearchTime -- 90
kAdvancedPrototypeLabUpgradeCost = kExosuitTechResearchCost -- 20
kAdvancedPrototypeLabHealth = kPrototypeLabHealth  -- 3000
kAdvancedPrototypeLabArmor = kPrototypeLabArmor -- 500   
kAdvancedPrototypeLabPointValue = kPrototypeLabPointValue -- 20


-- ====**** MDSmarines\Balance.lua ****====

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


-- ====**** GorgeEnergyReduction\Balance.lua ****====

-- Gorge energy reduction
kDropHydraEnergyCost = 28 -- vanilla 40
kDropBabblerEggEnergyCost = 10 -- vanilla 15


-- ====**** BalanceValueChanges\Balance.lua ****====


-- Buffs
kPulseGrenadeDamage = 50 -- vanilla: 50
kPulseGrenadeEnergyDamageRadius = 6 -- 4
kDropMineCost = 5 --7
kWelderDropCost = 2 -- 7
kStabEnergyCost = 25 --30
kStabResearchCost = 20 -- 25

kAdvancedMarineSupportResearchCost = 15 -- 20
kNanoShieldCost = 2 --3

kMucousMembraneAbilityRadius = 6.5 -- 5

-- Nerfs
kClusterGrenadeDamageRadius = 8 --10
kClusterFragmentDamageRadius = 5 -- 6





-- ====**** ReducedSwitchingCost\Balance.lua ****====

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

-- ====**** StompKnockDown\Balance.lua ****====

kStompDamage = 50 -- vanilla: 40


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
kMinigunFuelUsageScalar = 1 -- Usage commented out in Exo.lua
kRailgunFuelUsageScalar = 1 -- Usage commented out in Exo.lua

kNanoShieldPlayerDuration = 6

--- Exo
kExosuitHorizontalThrusterAddSpeed = 2 -- 10
kExosuitThrusterHorizontalAcceleration = 200
kExosuitThrusterUpwardsAcceleration = 0
kExosuitMinTimeBetweenThrusterActivations = 0.5
kExosuitMaxSpeed = 7
kExosuitSpeedCap = 7.25
kExosuitDeployDuration = 1.4

--- FUEL USAGE
--- rate could be effective seconds it takes to recharge/use 1 fuel
kExoFuelRechargeRate = 5
--- Exo-Jetpack
kExoThrusterMinFuel = 0.25 -- Energy Min
kExoThrusterFuelUsageRate = 4 --Energy Cost/s
--kExoThrusterLateralAccel = 50
--kExoThrusterVerticleAccel = 8

--- Exo-Nanoshield
kExoNanoShieldMinFuel = 0.99 -- Energy Min
kExoNanoShieldFuelUsageRate = 4 -- Energy Cost/s

--- Exo-Nanorepair
kExoRepairMinFuel = 0.50 -- Energy Min
kExoRepairPerSecond = 15
kExoRepairFuelUsageRate = 5 --Energy Cost/s
kExoRepairInterval = 0.5

--- Exo-Catpack
kExoCatPackMinFuel = 0.99 -- Energy Min
kExoCatPackFuelUsageRate = 4 --Energy Cost/s

--Tech Research

kExoShieldTech = kTechId.ExosuitTech
--kExoFlamerTech = kTechId.ExosuitTech
--kExoWelderTech = kTechId.ExosuitTech
kRailgunTech = kTechId.ExosuitTech
kPlasmaLauncherTech = kTechId.ExosuitTech
kMinigunTech = kTechId.ExosuitTech
kArmorModuleTech = kTechId.ExosuitTech
--kExoPhaseModuleTech = kTechId.ExosuitTech
kExoThrusterModuleTech = kTechId.ExosuitTech

--Weapons
kDualExosuitCost = 25 -- For ToolTip

--RAILGUN --
kRailgunWeight = 0.1      -- default 0.045
kRailgunDamage = 30 	  -- default 10
kRailgunChargeDamage = 30 -- default 140

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
kPlasmaBombDamage = 35 -- 20
kPlasmaBombDamageRadius = 6 -- 4 is the pulse damage radius (matches pulse cinematic)
kPlasmaBombEnergyCost = 0.60

kPlasmaBombDOTDamage = 15 -- DOT applied after direct damage
kPlasmaDOTDuration = 5.5
kPlasmaDOTInterval = 0.5

kPlasmaHitBoxRadiusT3 = 0.495 -- Hitbox radius from center of projectile...
kPlasmaHitBoxRadiusT2 = 0.33
kPlasmaHitBoxRadiusT1 = 0.10

kPlasmaLauncherEnergyUpRate = 0.2
kPlasmaDamageType = kDamageType.Normal 

kPlasmaLauncherWeight = 0.125

---- FLAMETHROWER --
--kExoFlamerWeight = 0.15
--kExoFlamerConeWidth = 0.30
--kExoFlamerCoolDownRate = 0.15
--kExoFlamerDualGunHeatUpRate = 0.10
--kExoFlamerHeatUpRate = 0.10
--kExoFlamerFireRate = 1 / 3
--kExoFlamerTrailLength = 10.5
--kExoFlamerExoFlamerDamage = 20
--kExoFlamerRange = 10
--kExoFlamerDamageRadius = 1.8
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
--

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
kPlasmaLauncherArmor = 50
kThrustersArmor = 0
kArmorModuleArmor = 100
kCatPackArmor = 0
kNanoRepairArmor = 0

kHallucinationCloudAbilityCooldown = 10

--Babbler Bomb

kTimeBetweenBabblerBombShots = 2.5 --- starting point 2.5

kBabblerBombEnergyCost = 35 --Starting point 35
kBabblerBombVelocity = 11 --Starting point 11
kBabblerBombVelocity = 15 --Starting point 15

kMaxNumBomblers = 6 --Starting point 6
kBomblerLifeTime = 5 --Starting point 5


kBabblerBombResearchTime = kBileBombResearchTime
kBabblerBombResearchCost = 15
