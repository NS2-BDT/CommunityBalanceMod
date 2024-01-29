-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
--   MDS increases structure HPs by 15%, fortressPvE reduces crag, shift, shade, whip by 20%
--   The file that gets loaded in first applies both changes to prevent any math errors.
--   
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


if gAppliedBasicStructureNerf ~= true then
    gAppliedBasicStructureNerf = true
end



if gAppliedMDSBuff ~= true then

    -- buff all structures by about 15% HP and Armor
    -- rounds by 10 HP
    for k, v in pairs(alienStructureHealthMDS) do
        v = v + math.floor( (v * structureHPbuff / 10) + 0.5 ) * 10
    end

    gAppliedMDSBuff = true
end


kFortressCragHealth = kCragHealth * 3 + kCragArmor * 3
kFortressCragArmor = kCragArmor * 1.5
kFortressMatureCragHealth = kMatureCragHealth * 3 + kMatureCragArmor * 3
kFortressMatureCragArmor = kMatureCragArmor * 1.5
        
kFortressWhipHealth = kWhipHealth * 3 + kWhipArmor * 3
kFortressWhipArmor = kWhipArmor * 1.5
kFortressMatureWhipHealth = kMatureWhipHealth * 3  + kMatureWhipArmor * 3
kFortressMatureWhipArmor = kMatureWhipArmor * 1.5

kFortressShiftHealth = kShiftHealth * 3 + kShiftArmor * 3
kFortressShiftArmor = kShiftArmor * 1.5
kFortressMatureShiftHealth = kMatureShiftHealth * 3 + kMatureShiftArmor * 3
kFortressMatureShiftArmor = kMatureShiftArmor * 1.5

kFortressShadeHealth = kShadeHealth * 3 + kShadeArmor * 3
kFortressShadeArmor = kShadeArmor
kFortressMatureShadeHealth = kMatureShadeHealth * 3 + kMatureShadeArmor * 3
kFortressMatureShadeArmor = kMatureShadeArmor



kBalanceOffInfestationHurtPercentPerSecondFortress = kBalanceOffInfestationHurtPercentPerSecond / 3

