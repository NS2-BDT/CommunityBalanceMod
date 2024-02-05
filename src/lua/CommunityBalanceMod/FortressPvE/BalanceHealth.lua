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

kBalanceOffInfestationHurtPercentPerSecondFortress = kBalanceOffInfestationHurtPercentPerSecond / 3
gFortressModHPnerf = 0.20
gFortressPvEModLoaded = true
Loh(" PvE Mod loaded")

-- armor has to be at 2nd and 4th position
local alienSupportStructures = {
    {
        "kCragHealth",
        "kCragArmor",
        "kMatureCragHealth",
        "kMatureCragArmor"
    },{
        "kWhipHealth",
        "kWhipArmor",
        "kMatureWhipHealth",
        "kMatureWhipArmor"
    },{
        "kShiftHealth",
        "kShiftArmor", 
        "kMatureShiftHealth",
        "kMatureShiftArmor"
    },{
        "kShadeHealth",
        "kShadeArmor", 
        "kMatureShadeHealth", 
        "kMatureShadeArmor"
    } 
}


-- also used in MDS to apply the 15% buff
-- armor has to be at 2nd and 4th position
gAlienFortressStructures = {
    {
        "kFortressCragHealth",
        "kFortressCragArmor",
        "kFortressMatureCragHealth",
        "kFortressMatureCragArmor"
    },{
        "kFortressWhipHealth",
        "kFortressWhipArmor",
        "kFortressMatureWhipHealth",
        "kFortressMatureWhipArmor"
    },{

        "kFortressShiftHealth",
        "kFortressShiftArmor", 
        "kFortressMatureShiftHealth",
        "kFortressMatureShiftArmor"
    },{
        "kFortressShadeHealth",
        "kFortressShadeArmor", 
        "kFortressMatureShadeHealth", 
        "kFortressMatureShadeArmor"
    }
}








-- if this file gets loaded after MDS, revert the HP buff
if gMDSModLoaded == true and gMDSModHPbuff then 

    --revert to base
    for k, v in pairs(alienSupportStructures) do
        for _, w in ipairs(v) do 
            _G[w] =  _G[w] / (1 + gMDSModHPbuff)
        end
    end

    -- apply difference in % to base HP
    for k, v in pairs(alienSupportStructures) do
        for _, w in ipairs(v) do 
            _G[w] = _G[w] + _G[w] * ( gMDSModHPbuff - gFortressModHPnerf )
        end
    end

-- MDS wasnt loaded before, apply 20% nerf.
elseif gMDSModLoaded ~= true then 

    for k, v in pairs(alienSupportStructures) do
        for _, w in ipairs(v) do 
            _G[w] = _G[w] - _G[w] * gFortressModHPnerf
        end
    end
end


-- triple eHP of fortress structures.
-- custom HP/Armor split, 1/2 of armor gets converted to +HP*2
for k, v in pairs(gAlienFortressStructures) do

    -- get non fortress name
    local nonFortressString
    nonFortressString = string.gsub(v[1], "Fortress", "")
    local baseHP = _G[nonFortressString]
    nonFortressString = string.gsub(v[2], "Fortress", "")
    local baseArmor = _G[nonFortressString]
    nonFortressString = string.gsub(v[3], "Fortress", "")
    local baseMatureHP = _G[nonFortressString]
    nonFortressString = string.gsub(v[4], "Fortress", "")
    local baseMatureArmor = _G[nonFortressString]

    _G[v[1]] = baseHP * 3 + baseArmor * 1.5 * 2
    _G[v[2]] = baseArmor * 1.5
    _G[v[3]] = baseMatureHP * 3 + baseArmor * 1.5 * 2
    _G[v[4]] = baseMatureArmor * 1.5
end
