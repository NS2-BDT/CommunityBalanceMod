-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======        
--        
-- lua\BalanceHealth.lua        
--        
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)            
--        
-- ========= For more information, visit us at http://www.unknownworlds.com =====================        

--Time interval allowed for healing to be clamped
kHealingClampInterval = 1
kHealingClampMaxHPAmount = 0.12
kHealingClampReductionScalar = 0.34

-- HEALTH AND ARMOR        
kMarineHealth = 100    kMarineArmor = 30    kMarinePointValue = 5
kJetpackHealth = 100    kJetpackArmor = 30    kJetpackPointValue = 10
kExosuitHealth = 100    kExosuitArmor = 320    kExosuitPointValue = 20

--Medpack
kMedpackHeal = 25
kMedpackPickupDelay = 0.45
kMarineRegenerationHeal = 25 --Amount of hp per second

kLayMinesPointValue = 2
kGrenadeLauncherPointValue = 10
kShotgunPointValue = 10
kHeavyMachineGunPointValue = 15
kFlamethrowerPointValue = 7

kMinigunPointValue = 10
kRailgunPointValue = 10
        
kSkulkHealth = 75    kSkulkArmor = 10    kSkulkPointValue = 5    kSkulkHealthPerBioMass = 3
kGorgeHealth = 160   kGorgeArmor = 50    kGorgePointValue = 7    kGorgeHealthPerBioMass = 2
kLerkHealth = 180    kLerkArmor = 30     kLerkPointValue = 15    kLerkHealthPerBioMass = 2
kFadeHealth = 250    kFadeArmor = 80     kFadePointValue = 20    kFadeHealthPerBioMass = 5
kOnosHealth = 700    kOnosArmor = 450    kOnosPointValue = 30    kOnosHealtPerBioMass = 50

kMarineWeaponHealth = 400
        
kEggHealth = 350    kEggArmor = 0    kEggPointValue = 1

kBabblerHealth = 12    kBabblerArmor = 0    kBabblerPointValue = 0

kBabblerEggHealth = 225    kBabblerEggArmor = 0    kBabblerEggPointValue = 0
kMatureBabblerEggHealth = 350 kMatureBabblerEggArmor = 0

        
kArmorPerUpgradeLevel = 20
kExosuitArmorPerUpgradeLevel = 40
kArmorHealScalar = 1 -- 0.75

kParasitePlayerPointValue = 1
kBuildPointValue = 5
kRecyclePaybackScalar = 0.75

kCarapaceHealReductionPerLevel = 0.0

kSkulkArmorFullyUpgradedAmount = 25
kGorgeArmorFullyUpgradedAmount = 75
kLerkArmorFullyUpgradedAmount = 50
kFadeArmorFullyUpgradedAmount = 120
kOnosArmorFullyUpgradedAmount = 650

kBalanceOffInfestationHurtPercentPerSecond = 0.02
kMinOffInfestationHurtPerSecond = 20

-- used for structures
kStartHealthScalar = 0.3

kArmoryHealth = 1500    kArmoryArmor = 200    kArmoryPointValue = 5
kAdvancedArmoryHealth = 3000    kAdvancedArmoryArmor = 500    kAdvancedArmoryPointValue = 10
kCommandStationHealth = 3000    kCommandStationArmor = 1500    kCommandStationPointValue = 20
kObservatoryHealth = 700    kObservatoryArmor = 500    kObservatoryPointValue = 10
kPhaseGateHealth = 1500    kPhaseGateArmor = 800    kPhaseGatePointValue = 10
kRoboticsFactoryHealth = 2500    kRoboticsFactoryArmor = 400    kRoboticsFactoryPointValue = 5
kARCRoboticsFactoryHealth = 2800    kARCRoboticsFactoryArmor = 600    kARCRoboticsFactoryPointValue = 7
kPrototypeLabHealth = 3000    kPrototypeLabArmor = 500    kPrototypeLabPointValue = 20
kInfantryPortalHealth = 1525    kInfantryPortalArmor = 500    kInfantryPortalPointValue = 10
kArmsLabHealth = 1650    kArmsLabArmor = 500    kArmsLabPointValue = 15
kSentryBatteryHealth = 500    kSentryBatteryArmor = 250    kSentryBatteryPointValue = 5

-- 5000/1000 is good average (is like 7,000 health from NS1)
kHiveHealth = 4300    kHiveArmor = 800    kHivePointValue = 30
kBioMassUpgradePointValue = 10 kUgradedHivePointValue = 5
kMatureHiveHealth = 6450 kMatureHiveArmor = 1500
kHiveHealthPerBioMass = 150 kHiveArmorPerBioMass = 25
        
kDrifterHealth = 300    kDrifterArmor = 20    kDrifterPointValue = 5
kMACHealth = 300    kMACArmor = 50    kMACPointValue = 2
kMineHealth = 30    kMineArmor = 9    kMinePointValue = 5
        
kExtractorHealth = 2400 kExtractorArmor = 1050 kExtractorPointValue = 15
kExtractorArmorAddAmount = 700 -- not used

-- (2500 = NS1)
kHarvesterHealth = 2300 kHarvesterArmor = 225 kHarvesterPointValue = 15
kMatureHarvesterHealth = 2600 kMatureHarvesterArmor = 375

kSentryHealth = 500    kSentryArmor = 100    kSentryPointValue = 2
kARCHealth = 2600    kARCArmor = 400    kARCPointValue = 5
kARCDeployedHealth = 2600    kARCDeployedArmor = 0
        
kShellHealth = 700     kShellArmor = 150     kShellPointValue = 12
kMatureShellHealth = 750     kMatureShellArmor = 250

kSpurHealth = 900     kSpurArmor = 50     kSpurPointValue = 12
kMatureSpurHealth = 1000  kMatureSpurArmor = 125     kSpurPointValue = 12

kVeilHealth = 1000     kVeilArmor = 0     kVeilPointValue = 12     
kMatureVeilHealth = 1250     kMatureVeilArmor = 0     kVeilPointValue = 12

kCragHealth = 300    kCragArmor = 150    kCragPointValue = 10
kMatureCragHealth = 550    kMatureCragArmor = 275    kMatureCragPointValue = 10
        
kWhipHealth = 350    kWhipArmor = 175    kWhipPointValue = 10
kMatureWhipHealth = 550    kMatureWhipArmor = 275    kMatureWhipPointValue = 10
        
kShiftHealth = 450    kShiftArmor = 75    kShiftPointValue = 10
kMatureShiftHealth = 800    kMatureShiftArmor = 150    kMatureShiftPointValue = 10

kShadeHealth = 600    kShadeArmor = 0    kShadePointValue = 10
kMatureShadeHealth = 1100    kMatureShadeArmor = 0    kMatureShadePointValue = 10

kHydraHealth = 145    kHydraArmor = 5    kHydraPointValue = 2    
kMatureHydraHealth = 175   kMatureHydraArmor = 25    kMatureHydraPointValue = 2
kHydraHealthPerBioMass = 18

kClogHealth = 275  kClogArmor = 0 kClogPointValue = 0
kClogHealthPerBioMass = 5

kWebHealth = 10

kCystHealth = 50    kCystArmor = 1
kMatureCystHealth = 450    kMatureCystArmor = 1    kCystPointValue = 1    
kMinMatureCystHealth = 225    kMinCystScalingDistance = 48 kMaxCystScalingDistance = 120

kBoneWallHealth = 115 kBoneWallArmor = 0    kBoneWallHealthPerBioMass = 140
kContaminationHealth = 1725 kContaminationArmor = 0    kContaminationPointValue = 2

kPowerPointHealth = 2000    kPowerPointArmor = 1000    kPowerPointPointValue = 10
kDoorHealth = 2000    kDoorArmor = 1000    kDoorPointValue = 0

kTunnelEntranceHealth = 1150   kTunnelEntranceArmor = 125    kTunnelEntrancePointValue = 5
kMatureTunnelEntranceHealth = 1600    kMatureTunnelEntranceArmor = 275

kInfestedTunnelEntranceHealth = 1425    kInfestedTunnelEntranceArmor = 250
kMatureInfestedTunnelEntranceHealth = 1600    kMatureInfestedTunnelEntranceArmor = 275

kTunnelStartingHealthScalar = 0.18 --Percentage of kTunnelEntranceHealth & kTunnelEntranceArmor newly placed Tunnel has

-- Alien Armor
kSkulkBaseCarapaceUpgradeAmount = 5
kGorgeBaseCarapaceUpgradeAmount = 12
kLerkBaseCarapaceUpgradeAmount  = 12
kFadeBaseCarapaceUpgradeAmount  = 20
kOnosBaseCarapaceUpgradeAmount  = 50

kSkulkCarapaceArmorPerBiomass = 1
kGorgeCarapaceArmorPerBiomass = 2
kLerkCarapaceArmorPerBiomass  = 1
kFadeCarapaceArmorPerBiomass  = 2.5
kOnosCarapaceArmorPerBiomass  = 20

-- CBM Content:
-- Fortress structures
kFortressCragHealth = 800
kFortressCragArmor = 300
kFortressMatureCragHealth = 1300
kFortressMatureCragArmor = 350
kFortressCragHealthPerBioMass = 0        

kFortressShiftHealth = 1100
kFortressShiftArmor = 150
kFortressMatureShiftHealth = 1650
kFortressMatureShiftArmor = 175
kFortressShiftHealthPerBioMass = 0

kFortressShadeHealth = 1400
kFortressShadeArmor = 0
kFortressMatureShadeHealth = 2000
kFortressMatureShadeArmor = 0
kFortressShadeHealthPerBioMass = 0

kFortressWhipHealth = 2500
kFortressWhipArmor = 150
kFortressMatureWhipHealth = 3000
kFortressMatureWhipArmor = 200
kFortressWhipHealthPerBioMass = 50

kBalanceOffInfestationHurtPercentPerSecondFortress = 0.02 / 3

-- SPARC
kDISHealth = 2600    kDISArmor = 400    kDISPointValue = 5
kDISDeployedHealth = 2600    kDISDeployedArmor = 0

-- Shielded Sentry Battery (depreciated)
kShieldedSentryBatteryHealth = 1000
kShieldedSentryBatteryArmor = 250
kShieldedSentryBatteryPointValue = 10

-- Cargo Gate (depreciated)
kCargoGateHealth = 1500
kCargoGateArmor = 1000
kCargoGatePointValue = 15

-- Advanced Observatory
kAdvancedObservatoryHealth = 1000
kAdvancedObservatoryArmor = 500

if Shared.GetThunderdomeEnabled() then
    Script.Load("lua/thunderdome/ThunderdomeBalanceHealth.lua")
end