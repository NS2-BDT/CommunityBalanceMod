-- ========= Community Balance Mod ===============================
--
-- "lua\BalanceHealth.lua"
--
--    Created by:   Drey (@drey3982)
--
--   MDS increases structure HPs by 15%, fortressPvE mod reduces crag, shift, shade, whip by 20%
--   gFortressPvEModLoaded and gMDSModLoaded are used to apply the buff/nerfs correctly no 
--     matter the sequence the files are loaded.
--   e.g. baseHP +15% -20% =>  95% baseHP
--   while using no hard coded HP values
--
-- ===============================================================

local structureHPbuffHives = 0.20
gMDSModHPbuff = 0.15 -- 15%
gMDSModLoaded = true

local alienStructuresMDS = {
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


local alienSupportStructuresMDS = {
    "kCragHealth",
    "kCragArmor",
    "kMatureCragHealth",
    "kMatureCragArmor",

    "kWhipHealth",
    "kWhipArmor",
    "kMatureWhipHealth",
    "kMatureWhipArmor",

    "kShiftHealth",
    "kShiftArmor", 
    "kMatureShiftHealth",
    "kMatureShiftArmor",

    "kShadeHealth",
    "kShadeArmor", 
    "kMatureShadeHealth", 
    "kMatureShadeArmor", 
}



-- if this file gets loaded after FortressPvE, revert the fortressPvE nerf
if gFortressPvEModLoaded == true and gAlienFortressStructureHealth and gFortressModHPnerf then 

    -- revert to base HP
    for k, v in pairs(gAlienFortressStructures) do
        for i = 1, i <= #v, i++ do 
            mathfloor( ( ( _G[v[i]] / (1 - gFortressModHPnerf) ) + 5 ) / 10 ) * 10
        end
    end
    for k, v in pairs(alienSupportStructuresMDS) do
        mathfloor( ( ( _G[v] / (1 - gFortressModHPnerf) ) + 5 ) / 10 ) * 10
    end

    -- apply difference in % to base HP
    for k, v in pairs(gAlienFortressStructures) do
        for i = 1, i <= #v, i++ do 
            _G[v[i]] = _G[v[i]] + math.floor( (_G[v[i]] * ( gMDSModHPbuff - gFortressModHPnerf )  + 5) / 10 ) * 10
        end
    end
    for k, v in pairs(alienSupportStructuresMDS) do
        _G[v] = _G[v] + math.floor( (_G[v] * ( gMDSModHPbuff - gFortressModHPnerf ) + 5) / 10 ) * 10
    end


-- FortressPvE wasnt loaded before, apply 15% buff.
elseif gFortressPvEModLoaded =~ true then 
    for k, v in pairs(alienSupportStructuresMDS) do
        _G[v] = _G[v] + math.floor( (_G[v] * gMDSModHPbuff + 5) / 10 ) * 10
    end
    -- set this flag to let fortressPvE know it has to apply a 15% buff, if its loaded afterwards. 
end


 
-- buff structures by about 15% HP and Armor
-- rounds by 10 HP
for k, v in pairs(alienStructuresMDS) do
    _G[v] = _G[v] + math.floor( (_G[v] * gMDSModHPbuff + 5) / 10 ) * 10
end

-- mature hives HP is 20% higher instead of 15%
kMatureHiveHealth = kMatureHiveHealth + math.floor( ( kMatureHiveHealth * structureHPbuffHives + 5 ) / 10  ) * 10
kMatureHiveArmor = kMatureHiveArmor + math.floor( ( kMatureHiveArmor * structureHPbuffHives + 5 ) / 10 ) * 10
