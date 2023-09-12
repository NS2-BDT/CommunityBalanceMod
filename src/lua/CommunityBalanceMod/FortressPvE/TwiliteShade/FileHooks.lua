
-- unused, CommunityBalanceMod Filehook loads the file it wants to use.

local function ModLoader_SetupFileHook(file, replace_type)
    local alienfortress_files = string.gsub(file, "lua/", "lua/alienfortress/", 1)

    ModLoader.SetupFileHook(file,  alienfortress_files, replace_type)
end

ModLoader_SetupFileHook( "lua/Balance.lua", "post" )
ModLoader_SetupFileHook( "lua/BalanceMisc.lua", "post" )
ModLoader_SetupFileHook( "lua/Hallucination.lua", "replace" )
ModLoader_SetupFileHook( "lua/TechTreeConstants.lua", "post" )
ModLoader_SetupFileHook( "lua/TechTreeButtons.lua", "post" )
ModLoader_SetupFileHook( "lua/TechData.lua", "post" )
ModLoader_SetupFileHook( "lua/AlienTeam.lua", "post" )
ModLoader_SetupFileHook( "lua/Shade.lua", "post" )