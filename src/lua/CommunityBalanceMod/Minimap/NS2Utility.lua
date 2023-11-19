

local oldBuildClassToGrid = BuildClassToGrid
function BuildClassToGrid()
    local ClassToGrid = oldBuildClassToGrid()

    ClassToGrid["CommandStationOccupied"] = { 2, 4 }
    ClassToGrid["WhipMature"] = { 4, 7 }
    ClassToGrid["JetpackMarine"] = { 3, 2 }
    ClassToGrid["DrifterEgg"] = { 7, 3 }
    ClassToGrid["HiveFresh"] = { 1, 6 }
    ClassToGrid["Hive"] = { 2, 6 }
    ClassToGrid["HiveMature"] = { 3, 6 }
    ClassToGrid["HiveFreshOccupied"] = { 5, 2 }
    ClassToGrid["HiveOccupied"] = { 6, 2 }
    ClassToGrid["HiveMatureOccupied"] = { 7, 2 }

    return ClassToGrid
end


