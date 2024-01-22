-- ========= Community Balance Mod ===============================
--
-- "lua\BalanceHealth.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================





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
        
kFortressWhipHealth = 650 * 3 + 175 * 3
kFortressWhipArmor = 175 * 1.5
kFortressMatureWhipHealth = 720 * 3  + 240 * 3
kFortressMatureWhipArmor = 240 * 1.5

kFortressShiftHealth = 600 * 3 + 60 * 3
kFortressShiftArmor = 60 * 1.5
kFortressMatureShiftHealth = 880 * 3 + 120 * 3
kFortressMatureShiftArmor = 120 * 1.5

kFortressShadeHealth = 600 * 3
kFortressShadeArmor = 0
kFortressMatureShadeHealth = 1200 * 3
kFortressMatureShadeArmor = 0

kBalanceOffInfestationHurtPercentPerSecondFortress = 0.02 / 3

