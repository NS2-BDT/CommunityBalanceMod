-- ========= Community Balance Mod ===============================
--
-- "lua\TechTreeButtons.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================

local kTechIdToMaterialOffset = debug.getupvaluex(GetMaterialXYOffset, "kTechIdToMaterialOffset")

local toAdd = {

    {kTechId.FortressCrag, 192}, 
    {kTechId.UpgradeToFortressCrag, 192}, 
    {kTechId.FortressCragAbility, 75}, --umbra
    {kTechId.FortressShift, 194}, 
    {kTechId.UpgradeToFortressShift, 194},
    {kTechId.FortressShiftAbility, 64},
    {kTechId.FortressShade, 195}, 
    {kTechId.UpgradeToFortressShade, 195},
  --{kTechId.FortressShadeAbility, 195}, 
    {kTechId.FortressWhip, 193}, 
    {kTechId.UpgradeToFortressWhip, 193}, 
    {kTechId.FortressWhipAbility, 50}, 
    {kTechId.WhipAbility, 68}, 

    {kTechId.ShadeHallucination, 126}, 



    {kTechId.HallucinateShell, 22}, 
    {kTechId.HallucinateSpur, 11}, 
    {kTechId.HallucinateVeil, 23}, 
    {kTechId.HallucinateEgg, 34}, 
    {kTechId.HallucinateCloning, 123}, 
    {kTechId.HallucinateRandom, 120}, 
    
}

local toChange = {

    {kTechId.ShadePhantomMenu, 126}, -- for fake structures
    {kTechId.Hallucination, 126}, -- for fake structures

}

local toRemove = {}


-- Process changes first
for _,v in ipairs(toChange) do
    if kTechIdToMaterialOffset[v[1]] then
        kTechIdToMaterialOffset[v[1]] = v[2]
    end
end

-- Process removals next
for _,v in ipairs(toRemove) do
    if kTechIdToMaterialOffset[i] then
        table.remove(kTechIdToMaterialOffset, v)
    end
end

-- Process additions last
for _,v in ipairs(toAdd) do
    if not kTechIdToMaterialOffset[v[1]] then
        kTechIdToMaterialOffset[v[1]] = v[2]
    end
end
