

oldBuildClassToGrid = BuildClassToGrid
function BuildClassToGrid()
    local ClassToGrid = oldBuildClassToGrid()
    ClassToGrid["AdvancedPrototypeLab"] = { 4, 5 }
    return ClassToGrid
end


