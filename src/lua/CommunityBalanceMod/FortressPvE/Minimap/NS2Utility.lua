

local oldBuildClassToGrid = BuildClassToGrid
function BuildClassToGrid()
    local ClassToGrid = oldBuildClassToGrid()

    ClassToGrid["FortressWhipMature"] = { 4, 9 }
    ClassToGrid["FortressCrag"] = { 1, 9 }
    ClassToGrid["FortressWhip"] = { 3, 9 }
    ClassToGrid["FortressShade"] = { 5, 9 }
    ClassToGrid["FortressShift"] = { 6, 9 }

    return ClassToGrid
end


