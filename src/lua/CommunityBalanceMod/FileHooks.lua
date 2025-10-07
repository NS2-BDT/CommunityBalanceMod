local defaultConfig = {
    revision = "0.0.0",
    build_tag = "dev"
}

g_communityBalanceModConfig = {}

local filepath = "game://configs/CommunityBalanceMod.json"
if GetFileExists(filepath) then
    local configFile = io.open(filepath)
    g_communityBalanceModConfig = json.decode(configFile:read("*all"))
    io.close(configFile)
else
    g_communityBalanceModConfig = defaultConfig
    print("Warn: Using default config for CommunityBalanceMod")
end

ModLoader.SetupFileHook("lua/Balance.lua", "lua/CommunityBalanceMod/Balance.lua", "post") -- Cleanup/Merge
ModLoader.SetupFileHook("lua/BalanceHealth.lua", "lua/CommunityBalanceMod/BalanceHealth.lua", "post") -- Cleanup/Merge
ModLoader.SetupFileHook("lua/BalanceMisc.lua", "lua/CommunityBalanceMod/BalanceMisc.lua", "post") -- Cleanup/Merge
ModLoader.SetupFileHook("lua/Locale.lua", "lua/CommunityBalanceMod/Locale.lua", "post") -- WHERE IS THIS IN NS2/lua!?!??!?
ModLoader.SetupFileHook( "lua/Scoreboard.lua", "lua/CommunityBalanceMod/Scoreboard.lua", "post" ) -- Posting to avoid issues with scoreboard mods...
ModLoader.SetupFileHook("lua/menu2/NavBar/Screens/Options/Mods/ModsMenuData.lua", "lua/CommunityBalanceMod/menu2/NavBar/Screens/Options/Mods/ModsMenuData.lua", "post") -- Posting to avoid issues with mods...
ModLoader.SetupFileHook("lua/Utility.lua", "lua/CommunityBalanceMod/Utility.lua", "post")
ModLoader.SetupFileHook("lua/Weapons/Marine/ClipWeapon.lua", "lua/CommunityBalanceMod/CBM_ClipWeapon.lua", "post")
