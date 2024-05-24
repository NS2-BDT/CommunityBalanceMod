local oldBuildClassToGrid = BuildClassToGrid
function BuildClassToGrid()
    
    local ClassToGrid = oldBuildClassToGrid()
    
    ClassToGrid["WeaponCache"] = { 2, 5 }
    
    return ClassToGrid

end

