

local oldBuildClassToGrid = BuildClassToGrid
function BuildClassToGrid()
    local ClassToGrid = oldBuildClassToGrid()

    ClassToGrid["CommandStationOccupied"] = { 8, 9 }
    ClassToGrid["WhipMature"] = { 4, 7 }
    ClassToGrid["JetpackMarine"] = { 7, 9 }
    ClassToGrid["DrifterEgg"] = { 7, 10 }
    ClassToGrid["HiveFresh"] = { 1, 10 }
    ClassToGrid["Hive"] = { 2, 10 }
    ClassToGrid["HiveMature"] = { 3, 10 }
    ClassToGrid["HiveFreshOccupied"] = { 4, 10 }
    ClassToGrid["HiveOccupied"] = { 5, 10 }
    ClassToGrid["HiveMatureOccupied"] = { 6, 10 }

    return ClassToGrid
end


