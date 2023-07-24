--Filehooks

local function Loader_SetupFileHook(file, replace_type)
    local HallucinationCloak_file = string.gsub(file, "lua/", "lua/HallucinationCloak/", 1)

    ModLoader.SetupFileHook(file,  HallucinationCloak_file, replace_type)
end

Loader_SetupFileHook( "lua/Balance.lua", "post" )
Loader_SetupFileHook( "lua/CloakableMixin.lua", "post" )
Loader_SetupFileHook( "lua/CommAbilities/Alien/ShadeInk.lua", "post" )
Loader_SetupFileHook( "lua/CommAbilities/Alien/HallucinationCloud.lua", "replace" )
--Loader_SetupFileHook( "lua/Cyst_Server.lua", "post" )
Loader_SetupFileHook( "lua/Player_Client.lua", "post" )
Loader_SetupFileHook( "lua/Lerk.lua", "post" )
Loader_SetupFileHook( "lua/Babbler.lua", "post" )
Loader_SetupFileHook( "lua/Onos.lua", "post" )
--Loader_SetupFileHook( "lua/Onos_Client.lua", "post" )
Loader_SetupFileHook( "lua/Whip.lua", "post" )
Loader_SetupFileHook( "lua/DisorientableMixin.lua", "replace" )
Loader_SetupFileHook( "lua/DetectorMixin.lua", "replace" )
Loader_SetupFileHook( "lua/DetectableMixin.lua", "replace" )
Loader_SetupFileHook( "lua/Alien.lua", "post" )

if Client then
    Script.Load("lua/HallucinationCloak/Locale.lua")
end