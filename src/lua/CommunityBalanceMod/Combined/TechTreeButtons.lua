local kTechIdToMaterialOffset = debug.getupvaluex(GetMaterialXYOffset, "kTechIdToMaterialOffset")

local toAdd = {
    {kTechId.Resilience, 167}, --61 is carapace/resilience
    {kTechId.UpgradeToAdvancedPrototypeLab, 25},
    {kTechId.AdvancedPrototypeLab, 15},

    {kTechId.FortressCrag, 192}, 
    {kTechId.UpgradeToFortressCrag, 192}, 
    {kTechId.FortressCragAbility, 75}, --umbra
    {kTechId.FortressShift, 194}, 
    {kTechId.UpgradeToFortressShift, 194},
    {kTechId.FortressShiftAbility, 194},
    {kTechId.FortressShade, 195}, 
    {kTechId.UpgradeToFortressShade, 195},
  --{kTechId.FortressShadeAbility, 195}, 
    {kTechId.FortressWhip, 193}, 
    {kTechId.UpgradeToFortressWhip, 193}, 
    {kTechId.FortressWhipAbility, 193}, 
}

local toChange = {

    {kTechId.AdvancedArmory, 99}, -- was 1 for Armory before
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
