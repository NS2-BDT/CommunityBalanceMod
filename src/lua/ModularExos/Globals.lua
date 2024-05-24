--local oldGetPrecachedCosmeticMaterial = GetPrecachedCosmeticMaterial
--function GetPrecachedCosmeticMaterial(className, variantId, viewOnly)
--    if className == "Claw" then
--        className = "Minigun"
--    --elseif (className == "ExoWelder") or (className == "ExoFlamer") or (className == "ExoShield") or (className == "MarineStructureAbility") then
--    --    className = "Railgun"
--    end
--
--    return oldGetPrecachedCosmeticMaterial(className, variantId, viewOnly)
--end

--debug.appendtoenum(kMinimapBlipType, "WeaponCache")


--- Patch exo-claw skins into kExoVariantsData
--- Claw Minigun
kExoVariantsData[kExoVariants.kodiak].worldMaterials["ClawMinigun"] = {
    { idx = 0, mat = "models/marine/exosuit/exosuit_kodiak.material" },
    { idx = 1, mat = "models/marine/exosuit/claw_kodiak.material" },
    { idx = 2, mat = "models/marine/exosuit/minigun_kodiak.material" },
}
kExoVariantsData[kExoVariants.kodiak].viewMaterials["ClawMinigun"] = {
    "models/marine/exosuit/claw_view_kodiak.material",
    "models/marine/exosuit/minigun_view_kodiak.material",
    "models/marine/exosuit/forearm_kodiak.material",
}

kExoVariantsData[kExoVariants.tundra].worldMaterials["ClawMinigun"] = {
    { idx = 0, mat = "models/marine/exosuit/exosuit_tundra.material" },
    { idx = 1, mat = "models/marine/exosuit/claw_tundra.material" },
    { idx = 2, mat = "models/marine/exosuit/minigun_tundra.material" },
}
kExoVariantsData[kExoVariants.tundra].viewMaterials["ClawMinigun"] = {
    "models/marine/exosuit/claw_view_tundra.material",
    "models/marine/exosuit/minigun_view_tundra.material",
    "models/marine/exosuit/forearm_tundra.material",
}

kExoVariantsData[kExoVariants.forge].worldMaterials["ClawMinigun"] = {
    { idx = 0, mat = "models/marine/exosuit/exosuit_forge.material" },
    { idx = 1, mat = "models/marine/exosuit/claw.material" },
    { idx = 2, mat = "models/marine/exosuit/minigun_forge.material" },
}
kExoVariantsData[kExoVariants.forge].viewMaterials["ClawMinigun"] = {
    "models/marine/exosuit/claw_view.material",
    "models/marine/exosuit/minigun_view_forge.material",
    "models/marine/exosuit/forearm_forge.material",
}

kExoVariantsData[kExoVariants.sandstorm].worldMaterials["ClawMinigun"] = {
    { idx = 0, mat = "models/marine/exosuit/exosuit_sandstorm.material" },
    { idx = 1, mat = "models/marine/exosuit/claw.material" },
    { idx = 2, mat = "models/marine/exosuit/minigun_sandstorm.material" },
}
kExoVariantsData[kExoVariants.sandstorm].viewMaterials["ClawMinigun"] = {
    "models/marine/exosuit/claw_view.material",
    "models/marine/exosuit/minigun_view_sandstorm.material",
    "models/marine/exosuit/forearm_sandstorm.material",
}

kExoVariantsData[kExoVariants.chroma].worldMaterials["ClawMinigun"] = {
    { idx = 0, mat = "models/marine/exosuit/exosuit_chroma.material" },
    { idx = 1, mat = "models/marine/exosuit/claw.material" },
    { idx = 2, mat = "models/marine/exosuit/minigun_chroma.material" },
}
kExoVariantsData[kExoVariants.chroma].viewMaterials["ClawMinigun"] = {
    "models/marine/exosuit/claw_view.material",
    "models/marine/exosuit/minigun_view_chroma.material",
    "models/marine/exosuit/forearm_chroma.material",
}

--- Claw Railgun
kExoVariantsData[kExoVariants.kodiak].worldMaterials["ClawRailgun"] = {
    { idx = 0, mat = "models/marine/exosuit/claw_kodiak.material" },
    { idx = 1, mat = "models/marine/exosuit/railgun_kodiak.material" },
    { idx = 2, mat = "models/marine/exosuit/exosuit_kodiak.material" },
}
kExoVariantsData[kExoVariants.kodiak].viewMaterials["ClawRailgun"] = {
    "models/marine/exosuit/railgun_view_kodiak.material",
    "models/marine/exosuit/forearm_kodiak.material",
    "models/marine/exosuit/claw_view_kodiak.material",
}

kExoVariantsData[kExoVariants.tundra].worldMaterials["ClawRailgun"] = {
    { idx = 0, mat = "models/marine/exosuit/claw_tundra.material" },
    { idx = 1, mat = "models/marine/exosuit/railgun_tundra.material" },
    { idx = 2, mat = "models/marine/exosuit/exosuit_tundra.material" },
}
kExoVariantsData[kExoVariants.tundra].viewMaterials["ClawRailgun"] = {
    "models/marine/exosuit/railgun_view_tundra.material",
    "models/marine/exosuit/forearm_tundra.material",
    "models/marine/exosuit/claw_view_tundra.material",
}

kExoVariantsData[kExoVariants.forge].worldMaterials["ClawRailgun"] = {
    { idx = 0, mat = "models/marine/exosuit/claw.material" },
    { idx = 1, mat = "models/marine/exosuit/railgun_forge.material" },
    { idx = 2, mat = "models/marine/exosuit/exosuit_forge.material" },
}
kExoVariantsData[kExoVariants.forge].viewMaterials["ClawRailgun"] = {
    "models/marine/exosuit/railgun_view_forge.material",
    "models/marine/exosuit/forearm_forge.material",
    "models/marine/exosuit/claw_view.material",
}

kExoVariantsData[kExoVariants.sandstorm].worldMaterials["ClawRailgun"] = {
    { idx = 0, mat = "models/marine/exosuit/claw.material" },
    { idx = 1, mat = "models/marine/exosuit/railgun_sandstorm.material" },
    { idx = 2, mat = "models/marine/exosuit/exosuit_sandstorm.material" },
}
kExoVariantsData[kExoVariants.sandstorm].viewMaterials["ClawRailgun"] = {
    "models/marine/exosuit/railgun_view_sandstorm.material",
    "models/marine/exosuit/forearm_sandstorm.material",
    "models/marine/exosuit/claw_view.material",
}

kExoVariantsData[kExoVariants.chroma].worldMaterials["ClawRailgun"] = {
    { idx = 0, mat = "models/marine/exosuit/claw.material" },
    { idx = 1, mat = "models/marine/exosuit/railgun_chroma.material" },
    { idx = 2, mat = "models/marine/exosuit/exosuit_chroma.material" },
}
kExoVariantsData[kExoVariants.chroma].viewMaterials["ClawRailgun"] = {
    "models/marine/exosuit/railgun_view_chroma.material",
    "models/marine/exosuit/forearm_chroma.material",
    "models/marine/exosuit/claw_view.material",
}


--local oldGetCustomizableWorldMaterialData = GetCustomizableWorldMaterialData
--function GetCustomizableWorldMaterialData(label, marineType, options)
--    assert(label and type(label) == "string" and label ~= "")
--    assert(options)
--    Print("GetCustomizableWorldMaterialData(%s)", label)
--    local matType = string.lower(label)
--    local matPath = nil
--    local matIdx = -1
--    if matType == "exo_cm" and options.exoVariant ~= kDefaultExoVariant then
--        matPath = GetPrecachedCosmeticMaterial("ClawMinigun", options.exoVariant)
--        matIdx = false
--        return matPath, matIdx
--        --elseif matType == "exo_cr" and options.exoVariant ~= kDefaultExoVariant then
--        --    matPath = GetPrecachedCosmeticMaterial( "Railgun", options.exoVariant )
--        --    matIdx = false
--
--    end
--    return oldGetCustomizableWorldMaterialData(label, marineType, options)
--end