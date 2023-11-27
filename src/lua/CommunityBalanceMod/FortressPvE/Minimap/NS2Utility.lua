

local oldBuildClassToGrid = BuildClassToGrid
function BuildClassToGrid()
    local ClassToGrid = oldBuildClassToGrid()

    ClassToGrid["FortressWhipMature"] = { 4, 1 }
    ClassToGrid["FortressCrag"] = { 2, 7 }
    ClassToGrid["FortressWhip"] = { 4, 8 }
    ClassToGrid["FortressShade"] = { 5, 1 }
    ClassToGrid["FortressShift"] = { 3, 4 }

    return ClassToGrid
end


