-- ========= Community Balance Mod ===============================
--
-- "lua\BalanceHealth.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


local structureHPbuff = 0.15 -- 15%
local structureHPbuffHives = 0.20

local alienStructureHealthMDS = {
    "kBabblerEggHealth",
    "kMatureBabblerEggHealth",
    "kHiveHealth",
    "kHiveArmor",
    "kHarvesterHealth",
    "kHarvesterArmor",
    "kMatureHarvesterHealth",
    "kMatureHarvesterArmor",
    "kShellHealth",
    "kShellArmor",
    "kMatureShellHealth",
    "kMatureShellArmor",
    "kSpurHealth",
    "kSpurArmor",
    "kMatureSpurHealth",
    "kMatureSpurArmor",
    "kVeilHealth",
    "kVeilArmor",
    "kMatureVeilHealth",
    "kMatureVeilArmor",
    "kHydraHealth",
    "kHydraArmor",
    "kMatureHydraHealth",
    "kMatureHydraArmor",
    "kHydraHealthPerBioMass",
    "kClogHealth",
    "kClogArmor",
    "kClogHealthPerBioMass",
    "kWebHealth",
    "kCystHealth",
    "kCystArmor",
    "kMatureCystHealth",
    "kMatureCystArmor",
    "kMinMatureCystHealth",
    "kBoneWallHealth",
    "kBoneWallArmor",
    "kBoneWallHealthPerBioMass",
    "kContaminationHealth",
    "kContaminationArmor",
    "kTunnelEntranceHealth",
    "kTunnelEntranceArmor",
    "kMatureTunnelEntranceHealth",
    "kMatureTunnelEntranceArmor",
    "kInfestedTunnelEntranceHealth",
    "kInfestedTunnelEntranceArmor",
    "kMatureInfestedTunnelEntranceHealth",
    "kMatureInfestedTunnelEntranceArmor",
}


-- buff all structures by about 15% HP and Armor
-- rounds by 10 HP
for k, v in pairs(alienStructureHealthMDS) do
    _G[v] = _G[v] + math.floor( (_G[v] * structureHPbuff / 10) + 0.5 ) * 10
end


-- hives HP is 20% higher
kMatureHiveHealth = kMatureHiveHealth + math.floor( ( kMatureHiveHealth * structureHPbuffHives / 10) + 0.5 ) * 10
kMatureHiveArmor = kMatureHiveArmor + math.floor( ( kMatureHiveArmor * structureHPbuffHives / 10) + 0.5 ) * 10


-- deduct the 15% of crag, veil, shade, shift
if gAppliedBasicStructureNerf ~= true then
    gAppliedBasicStructureNerf = true
end

if gAppliedMDSBuff ~= true then
    gAppliedMDSBuff = true

    
    
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

end



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
