-- ========= Community Balance Mod ===============================
--
-- "lua\NS2Utility.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================



local oldBuildClassToGrid = BuildClassToGrid
function BuildClassToGrid()
    local ClassToGrid = oldBuildClassToGrid()
    ClassToGrid["AdvancedPrototypeLab"] = { 4, 5 }
    return ClassToGrid
end


