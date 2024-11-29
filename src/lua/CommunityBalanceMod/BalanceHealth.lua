-- ====**** MDSmarines\BalanceHealth.lua ****====

--MDS marines

kBabblerEggHealth = 230
kMatureBabblerEggHealth = 360

-- all structures health incresed by roughly 15%

-- hives are buffed by 15% but with increased maturity HP
-- kHiveHealth = 4000    kHiveArmor = 750    kHivePointValue = 30
kHiveHealth = 4600    kHiveArmor = 860

-- 20% instead of 15%
-- kMatureHiveHealth = 6000 kMatureHiveArmor = 1400
kMatureHiveHealth = 7000 kMatureHiveArmor = 1750

        
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
kBoneWallHealth = 115 kBoneWallArmor = 0    kBoneWallHealthPerBioMass = 115
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


kCragHealth = 440
kCragArmor = 140
kMatureCragHealth = 510
kMatureCragArmor = 250

kWhipHealth = 600
kWhipArmor = 160
kMatureWhipHealth = 660
kMatureWhipArmor = 220

kShiftHealth = 550
kShiftArmor = 60
kMatureShiftHealth = 810
kMatureShiftArmor = 110

kShadeHealth = 550
kShadeArmor = 0
kMatureShadeHealth = 1100
kMatureShadeArmor = 0

-- ====**** Arcs\BalanceHealth.lua ****====
--kARCHealth = 2600 -- 2600 vanilla
--kARCArmor = 650   -- 400 vanilla 
--kARCPointValue = 5
-- ====**** FortressPvE\BalanceHealth.lua ****====




--[[
kCragHealth = 480    
kCragArmor = 160
kMatureCragHealth = 560    
kMatureCragArmor = 272

kWhipHealth = 650    
kWhipArmor = 175
kMatureWhipHealth = 720    
kMatureWhipArmor = 240

kShadeHealth = 600    
kShadeArmor = 0
kMatureShadeHealth = 1200
kMatureShadeArmor = 0

kShiftHealth = 600    
kShiftArmor = 60
kMatureShiftHealth = 880    
kMatureShiftArmor = 120
]]

-- we cant use the constants, since MDS changes them

kFortressCragHealth = 480 * 3 + 160 * 3
kFortressCragArmor = 160 * 1.5
kFortressMatureCragHealth = 560 * 3 + 272 * 3
kFortressMatureCragArmor = 272 * 1.5
kFortressCragHealthPerBioMass = 200        

kFortressWhipHealth = 650 * 3 + 175 * 3
kFortressWhipArmor = 175 * 1.5
kFortressMatureWhipHealth = 720 * 3  + 240 * 3
kFortressMatureWhipArmor = 240 * 1.5
kFortressWhipHealthPerBioMass = 200

kFortressShiftHealth = 600 * 3 + 60 * 3
kFortressShiftArmor = 60 * 1.5
kFortressMatureShiftHealth = 880 * 3 + 120 * 3
kFortressMatureShiftArmor = 120 * 1.5
kFortressShiftHealthPerBioMass = 200

kFortressShadeHealth = 600 * 3
kFortressShadeArmor = 0
kFortressMatureShadeHealth = 1200 * 3
kFortressMatureShadeArmor = 0
kFortressShadeHealthPerBioMass = 200

kBalanceOffInfestationHurtPercentPerSecondFortress = 0.02 / 3


