-- ====**** MDSmarines\BalanceHealth.lua ****====

--MDS marines

kBabblerEggHealth = 230
kMatureBabblerEggHealth = 360

-- all structures health incresed by roughly 15%

-- hives are buffed by 15% but with increased maturity HP
-- kHiveHealth = 4000    kHiveArmor = 750    kHivePointValue = 30
kHiveHealth = 4300    kHiveArmor = 800

-- kMatureHiveHealth = 6000 kMatureHiveArmor = 1400
kMatureHiveHealth = 6450 kMatureHiveArmor = 1505
kHiveHealthPerBioMass = 150
kHiveArmorPerBioMass = 35
        
-- kHarvesterHealth = 2000 kHarvesterArmor = 200 kHarvesterPointValue = 15
-- kMatureHarvesterHealth = 2300 kMatureHarvesterArmor = 320
kHarvesterHealth = 2300 kHarvesterArmor = 230
kMatureHarvesterHealth = 2645 kMatureHarvesterArmor = 368

-- kShellHealth = 600     kShellArmor = 150     kShellPointValue = 12
-- kMatureShellHealth = 700     kMatureShellArmor = 200
kShellHealth = 690    kShellArmor = 173 
kMatureShellHealth = 805     kMatureShellArmor = 230
     
-- kSpurHealth = 800     kSpurArmor = 50     kSpurPointValue = 12
-- kMatureSpurHealth = 900  kMatureSpurArmor = 100  kMatureSpurPointValue = 12
kSpurHealth = 920     kSpurArmor = 58
kMatureSpurHealth = 1035  kMatureSpurArmor = 115

-- kVeilHealth = 900     kVeilArmor = 0     kVeilPointValue = 12
-- kMatureVeilHealth = 1100     kMatureVeilArmor = 0     kVeilPointValue = 12
kVeilHealth = 1035     kVeilArmor = 0     
kMatureVeilHealth = 1265     kMatureVeilArmor = 0

-- kHydraHealth = 125    kHydraArmor = 5  
-- kMatureHydraHealth = 160   kMatureHydraArmor = 20   
-- kHydraHealthPerBioMass = 16
kHydraHealth = 144    kHydraArmor = 6    
kMatureHydraHealth = 184   kMatureHydraArmor = 23
kHydraHealthPerBioMass = 18

kBabblerHealth = 12

-- kClogHealth = 250  kClogArmor = 0 kClogPointValue = 0
-- kClogHealthPerBioMass = 4
kClogHealth = 288  kClogArmor = 0 kClogPointValue = 0
kClogHealthPerBioMass = 5

-- kWebHealth = 10
kWebHealth = 10

-- kCystHealth = 50    kCystArmor = 1
-- kMatureCystHealth = 400    kMatureCystArmor = 1    kCystPointValue = 1
-- kMinMatureCystHealth = 200 kMinCystScalingDistance = 48 kMaxCystScalingDistance = 120
kCystHealth = 58    kCystArmor = 1
kMatureCystHealth = 460    kMatureCystArmor = 1    
kMinMatureCystHealth = 230 

-- kBoneWallHealth = 100 kBoneWallArmor = 0    kBoneWallHealthPerBioMass = 100
-- kContaminationHealth = 1500 kContaminationArmor = 0    kContaminationPointValue = 2
kBoneWallHealth = 115 kBoneWallArmor = 0    kBoneWallHealthPerBioMass = 140
kContaminationHealth = 1725 kContaminationArmor = 0

-- kTunnelEntranceHealth = 1000   kTunnelEntranceArmor = 100    kTunnelEntrancePointValue = 5
-- kMatureTunnelEntranceHealth = 1400    kMatureTunnelEntranceArmor = 250
kTunnelEntranceHealth = 1150   kTunnelEntranceArmor = 115
kMatureTunnelEntranceHealth = 1610    kMatureTunnelEntranceArmor = 288

-- kInfestedTunnelEntranceHealth = 1250    kInfestedTunnelEntranceArmor = 200
-- kMatureInfestedTunnelEntranceHealth = 1400    kMatureInfestedTunnelEntranceArmor = 250
kInfestedTunnelEntranceHealth = 1438    kInfestedTunnelEntranceArmor = 230
kMatureInfestedTunnelEntranceHealth = 1610    kMatureInfestedTunnelEntranceArmor = 288

-- kTunnelStartingHealthScalar = 0.18
kTunnelStartingHealthScalar = 0.18 --Percentage of kTunnelEntranceHealth & kTunnelEntranceArmor newly placed Tunnel has


kCragHealth = 300
kCragArmor = 150
kMatureCragHealth = 550
kMatureCragArmor = 275

kShiftHealth = 450
kShiftArmor = 75
kMatureShiftHealth = 800
kMatureShiftArmor = 150

kShadeHealth = 600
kShadeArmor = 0
kMatureShadeHealth = 1100
kMatureShadeArmor = 0

kWhipHealth = 350
kWhipArmor = 175
kMatureWhipHealth = 550
kMatureWhipArmor = 275

kFortressCragHealth = 800
kFortressCragArmor = 300
kFortressMatureCragHealth = 1280
kFortressMatureCragArmor = 360
kFortressCragHealthPerBioMass = 0        

kFortressShiftHealth = 1100
kFortressShiftArmor = 150
kFortressMatureShiftHealth = 1640
kFortressMatureShiftArmor = 180
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

kDISHealth = 2600    kDISArmor = 400    kDISPointValue = 5
kDISDeployedHealth = 2600    kDISDeployedArmor = 0

kSentryBatteryHealth = 500    
kSentryBatteryArmor = 250 

kShieldedSentryBatteryHealth = 1000
kShieldedSentryBatteryArmor = 250
kShieldedSentryBatteryPointValue = 10