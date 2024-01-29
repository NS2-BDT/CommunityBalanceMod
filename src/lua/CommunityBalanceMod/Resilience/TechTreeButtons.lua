-- ========= Community Balance Mod ===============================
--
-- "lua\TechTreeButtons.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================

local kTechIdToMaterialOffset = debug.getupvaluex(GetMaterialXYOffset, "kTechIdToMaterialOffset")

local toAdd = {
    {kTechId.Resilience, 167}, --61 is carapace/resilience
    {kTechId.DualMinigunExosuit, 84 },
    {kTechId.DualRailgunExosuit, 116 }
}

local toChange = {
    {kTechId.Carapace, 167},
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
