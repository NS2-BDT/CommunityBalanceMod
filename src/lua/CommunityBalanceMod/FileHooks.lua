
-- Scipts/GUIBetaBalanceChangelogData.lua contains the ingame changelog.

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


local function Loader_SetupFilehook(filename, replace_type, folder)
    local newFilename 
    for i = string.len(filename), 3, -1 do 
        if filename:sub(i,i) == '/' then 
            newFilename = string.format("lua/CommunityBalanceMod/%s%s", folder, filename:sub(i, string.len(filename) ))
            break
        end
    end
    ModLoader.SetupFileHook(filename,  newFilename, replace_type)
end
local folder = ""


-- == Build Version Overlay ==
folder = "BuildVersionOverlay"
Loader_SetupFilehook("lua/GUIFeedback.lua", "post", folder)

-- == Ingame Changelog ==
folder = "IngameChangelog"
Loader_SetupFilehook("lua/menu2/GUIMainMenu.lua", "post", folder)
-- GUIBetaBalanceChangelogData.lua
-- GUIBetaBalanceChangelog.lua
-- GUIMenuBetaBalanceChangelogButton.lua
-- balance_icon_hover.dds
-- balance_icon.dds

-- == Github Changelog ==
folder = "GithubChangelog"
Loader_SetupFilehook("lua/Player_Client.lua", "post", folder)


-- == Devnull QoL ==
folder = "DevnullQoL"
ModLoader.SetupFileHook("lua/Weapons/Alien/BoneShield.lua", "post", folder)
Loader_SetupFilehook("lua/Babbler.lua", "post", folder)
Loader_SetupFilehook("lua/Weapons/Alien/BabblerPheromone.lua", "post", folder)

-- == Stomp Visual Change ==
folder = "StompVisual"
Loader_SetupFilehook("lua/AlienWeaponEffects.lua", "post", folder)

-- == Forces Particles on Low/High ==
folder = "ParticleSetting"
Loader_SetupFilehook("lua/Render.lua", "post", folder)

-- == Armslab hologram fix ==
folder = "ArmslabHologram"
Loader_SetupFilehook("lua/ResearchMixin.lua", "post", folder)
Loader_SetupFilehook("lua/ArmsLab.lua", "post", folder) 

-- == Score changes for building and hydras ==
folder = "ScoreBuilding"
Loader_SetupFilehook("lua/PointGiverMixin.lua", "post", folder)

-- == Railgun dropoff ==
folder = "RailgunDropoff"
Loader_SetupFilehook("lua/Weapons/Marine/Railgun.lua", "post", folder)

-- == Marine Techtree rerouted ==
folder = "MarineTechtreeRerouted"
Loader_SetupFilehook("lua/MarineTechMap.lua", "replace", folder)

-- == Passive ability for upgrades ==
folder = "UpgradesPassiveAbilities"
Loader_SetupFilehook("lua/Spur.lua", "post", folder)
Loader_SetupFilehook("lua/Veil.lua", "post", folder)
Loader_SetupFilehook("lua/Shell.lua", "post", folder)


folder = "Combined"
--[[ == 
Advanced Prototypelab, 
FortressPvE
==]]
Loader_SetupFilehook("lua/TeamInfo.lua", "post", folder)
Loader_SetupFilehook("lua/TechTreeConstants.lua", "post", folder)
Loader_SetupFilehook("lua/TechTree.lua", "post", folder)
Loader_SetupFilehook("lua/ServerStats.lua", "post", folder)

--[[ = 
MDSmarines,
FortressPvE 
==]]
Loader_SetupFilehook("lua/BalanceHealth.lua", "post", folder)

--[[ = 
Resilience, 
FortressPvE 
==]]
Loader_SetupFilehook("lua/AlienTeam.lua", "post", folder)

--[[ ==
Resilience, 
Advanced Prototypelab, 
Reduced switching cost, 
Advanced Support Name,
FortressPvE
==]]
Loader_SetupFilehook("lua/TechData.lua", "post", folder)

--[[ == 
Resilience, 
Advanced Prototypelab,
FortressPvE
==]]
Loader_SetupFilehook("lua/TechTreeButtons.lua", "post", folder)

--[[ == 
Resilience, 
Advanced Support Name,
FortressPvE
==]]
Loader_SetupFilehook("lua/Locale.lua", "post", folder) 

--[[ == 
Resilience, 
Advanced Prototypelab, 
Reduced switching cost, 
Stomp change, 
Puple Grenade Buff, 
MDSmarines,
Gorge Energy Reduction,
FortressPvE
==]]
Loader_SetupFilehook("lua/Balance.lua", "post", folder)

--[[ ==
Resilience,
MDSmarines
 ==]]
Loader_SetupFilehook("lua/DamageTypes.lua",  "replace", folder) -- TODO use debug. for locals


-- == Gorge energy reduction ==
folder = "GorgeEnergyReduction"
Loader_SetupFilehook("lua/Weapons/Alien/BabblerEggAbility.lua", "post", folder)
Loader_SetupFilehook("lua/Weapons/Alien/HydraAbility.lua", "post", folder)
-- Balance.lua

-- == Advanced Support Name Change ==
-- TechData.lua
-- Locale.lua

-- == Pulse Grenade Buff ==
-- Balance.lua

-- == Stomp knock down change ==
folder = "StompKnockDown"
Loader_SetupFilehook("lua/Weapons/Alien/Shockwave.lua", "post", folder)
-- Balance.lua 

-- == Reduced switching cost ==
folder = "ReducedSwitchingCost"
Loader_SetupFilehook("lua/GUIAlienBuyMenu.lua", "post", folder)
Loader_SetupFilehook("lua/AlienUpgradeManager.lua", "post", folder)
-- Balance.lua
-- TechData.lua

-- == Resilience / Heat Plating ==
folder = "Resilience"
Loader_SetupFilehook("lua/PlayerInfoEntity.lua", "post", folder)
Loader_SetupFilehook("lua/Mine.lua", "post", folder)
Loader_SetupFilehook("lua/GUIUpgradeChamberDisplay.lua", "post", folder)
Loader_SetupFilehook("lua/Alien_Client.lua", "post", folder)
Loader_SetupFilehook("lua/FireMixin.lua", "post", folder)
Loader_SetupFilehook("lua/AlienTechMap.lua", "post", folder) -- Also moves mist to bio 1
Loader_SetupFilehook("lua/Alien_Upgrade.lua",  "post", folder)
-- DamageTypes.lua
-- Balance.lua
-- TechData.lua
-- AlienTeam.lua

-- == Advanced Prototypelab ==
folder = "AdvancedPrototypelab"
Loader_SetupFilehook("lua/PrototypeLab.lua", "post", folder)
Loader_SetupFilehook("lua/PrototypeLab_Server.lua", "post", folder)
Loader_SetupFilehook("lua/NS2Utility.lua", "post", folder)
Loader_SetupFilehook("lua/MarineTeam.lua", "post", folder)
Loader_SetupFilehook("lua/GUITechMap.lua", "replace", folder) -- TODO use debug. for locals, also fixes various other GUI errors
Loader_SetupFilehook("lua/Globals.lua", "post", folder)
-- TechTreeConstants.lua 
-- TechTree.lua 
-- TeamInfo.lua
-- Balance.lua
-- TechData.lua
-- ServerStats.lua
-- exo_holo_finished.cinematic
-- exo_holo_research.cinematic
-- exosuit_holo_alpha.dds
-- exosuit_holo_illumn.dds
-- exosuit_holo.dds
-- exosuit_holo.material
-- exosuit_holo.model
-- holo_cone.model
-- minigun_holo_material


-- == MDS Marines ==
folder = "MDSmarines"
Loader_SetupFilehook("lua/Weapons/Alien/HealSprayMixin.lua", "replace", folder)
Loader_SetupFilehook("lua/FireMixin.lua", "post", folder)
-- Balance.Health.lua
-- Balance.lua
-- DamageTypes.lua


-- == FortressPvE ==
folder = "FortressPvE"
Loader_SetupFilehook("lua/AlienCommander.lua", "post", folder)
Loader_SetupFilehook("lua/Crag.lua", "post", folder)
Loader_SetupFilehook("lua/Shift.lua", "post", folder)
Loader_SetupFilehook("lua/Shade.lua", "post", folder)
Loader_SetupFilehook("lua/Whip.lua", "post", folder)
Loader_SetupFilehook("lua/Whip_Server.lua", "post", folder)
-- BalanceHealth.lua
-- Balance.lua
-- Locale.lua
-- TeamInfo.lua
-- TechData.lua 
-- TechTree.lua
-- TechTreeButtons.lua 
-- TechTreeConstants.lua 
-- AlienTeam.lua
-- ServerStats.lua
-- model folders: crag/shift/shade/whip
-- buildmenu.dds

folder = "FortressPvE/Stormcloud"
Loader_SetupFilehook( "lua/Player_Client.lua", "post", folder )
Loader_SetupFilehook( "lua/Alien_Client.lua", "post", folder )
Loader_SetupFilehook( "lua/Alien_Server.lua", "post", folder )
Loader_SetupFilehook( "lua/Alien.lua", "post", folder )
Loader_SetupFilehook( "lua/NS2ConsoleCommands_Server.lua", "post", folder )
Loader_SetupFilehook( "lua/StormCloudMixin.lua", "post", folder )
Loader_SetupFilehook( "lua/Hud/GUIPlayerStatus.lua", "post", folder )
Loader_SetupFilehook( "lua/GUIAlienHUD.lua", "replace", folder )
-- storm_view.material
-- storm_view.surface_shader
-- storm.material
-- storm.surface_shader




folder = "FortressPvE/TwiliteShade"
Loader_SetupFilehook( "lua/BalanceMisc.lua", "post", folder )
Loader_SetupFilehook( "lua/Hallucination.lua", "replace", folder )
Loader_SetupFilehook( "lua/TechTreeConstants.lua", "post" , folder)
Loader_SetupFilehook( "lua/TechTreeButtons.lua", "post", folder )
Loader_SetupFilehook( "lua/TechData.lua", "post", folder ) -- renamed Tooltip
-- ShadeHallucination.lua

-- Loader_SetupFilehook( "lua/AlienTeam.lua", "post", folder ) not used
-- Loader_SetupFilehook( "lua/Shade.lua", "post", folder ) not used, merged in other Shade.lua 
-- Loader_SetupFilehook( "lua/Balance.lua", "post", folder ) not used, moved to other Balance.lua


folder = "Utility"
Loader_SetupFilehook("lua/Utility.lua", "post", folder)

