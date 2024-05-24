
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



if GetGamemode() ~= "ns2" then 
    Log("CommunityBalanceMod: Custom Gamemode detected. Dont apply balance changes.")
    return
end


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

-- == Passive ability for upgrades ==
folder = "UpgradesPassiveAbilities"
Loader_SetupFilehook("lua/Spur.lua", "post", folder)
Loader_SetupFilehook("lua/Veil.lua", "post", folder)
Loader_SetupFilehook("lua/Shell.lua", "post", folder)

-- == Gorge energy reduction ==
folder = "GorgeEnergyReduction"
Loader_SetupFilehook("lua/Weapons/Alien/BabblerEggAbility.lua", "post", folder)
Loader_SetupFilehook("lua/Weapons/Alien/HydraAbility.lua", "post", folder)
Loader_SetupFilehook("lua/Balance.lua", "post", folder)

-- == Stomp knock down and visual change ==
folder = "StompKnockDown"
Loader_SetupFilehook("lua/Weapons/Alien/Shockwave.lua", "post", folder)
Loader_SetupFilehook("lua/Balance.lua", "post", folder)
--Loader_SetupFilehook("lua/AlienWeaponEffects.lua", "post", folder)
--shockwave_segment.cinematic
--stomp_trimmed.cinematic


-- == Bugfix for Structure Reposition ==
folder = "RepositionFix"
Loader_SetupFilehook("lua/AlienStructureMoveMixin.lua",  "post", folder)

-- == MDS Marines ==
folder = "MDSmarines"
Loader_SetupFilehook("lua/Weapons/Alien/HealSprayMixin.lua", "replace", folder)
Loader_SetupFilehook("lua/FireMixin.lua", "post", folder)
Loader_SetupFilehook("lua/DamageTypes.lua",  "post", folder)
Loader_SetupFilehook("lua/BalanceHealth.lua", "post", folder)
Loader_SetupFilehook("lua/Balance.lua", "post", folder)
Loader_SetupFilehook( "lua/BalanceMisc.lua", "post", folder )
Loader_SetupFilehook("lua/Locale.lua", "post", folder) 

-- == Advanced Support Name Change ==
folder = "RenamedAdvancedSupport"
Loader_SetupFilehook("lua/Locale.lua", "post", folder) 
Loader_SetupFilehook("lua/TechData.lua", "post", folder)

-- == TechTree GUI fixes ==
folder = "TechTreeGUI"
Loader_SetupFilehook("lua/TechData.lua", "post", folder)
Loader_SetupFilehook("lua/GUITechMap.lua", "post", folder) -- fixes advanced protolab GUI issue
Loader_SetupFilehook("lua/AlienTechMap.lua", "post", folder) 
Loader_SetupFilehook( "lua/TechTreeButtons.lua", "post", folder )
Loader_SetupFilehook("lua/MarineTechMap.lua", "replace", folder)

-- == Pulse Grenade Buff ==
-- == Mine, Welder drop reduction ==
-- == Shift Energy Nerf ==
folder = "BalanceValueChanges"
Loader_SetupFilehook("lua/Balance.lua", "post", folder)
Loader_SetupFilehook( "lua/BalanceMisc.lua", "post", folder )

-- == Destroy Clogs faster == 
folder = "DigestClogs"
Loader_SetupFilehook("lua/Clog.lua", "post", folder)

-- == Faster MACs with better LOS == 
folder = "MacBuffs"
Loader_SetupFilehook("lua/MAC.lua", "post", folder)


-- == Reduced switching cost ==
folder = "ReducedSwitchingCost"
Loader_SetupFilehook("lua/GUIAlienBuyMenu.lua", "post", folder) -- possible conflict with Devnull quick buy
Loader_SetupFilehook("lua/AlienUpgradeManager.lua", "post", folder)
Loader_SetupFilehook("lua/Balance.lua", "post", folder) -- assumes resilience
Loader_SetupFilehook("lua/TechData.lua", "post", folder)

-- == Dynamic Minimap Icons == 
folder = "Minimap"
Loader_SetupFilehook("lua/MapBlipMixin.lua", "post", folder)
Loader_SetupFilehook("lua/Globals.lua", "post", folder)
Loader_SetupFilehook("lua/GUIMinimap.lua", "post", folder)
Loader_SetupFilehook("lua/MapBlip.lua", "post", folder)
Loader_SetupFilehook("lua/NS2Utility.lua", "post", folder)
Loader_SetupFilehook("lua/Armory_Server.lua", "post", folder)
Loader_SetupFilehook("lua/ARC", "post", folder)
Loader_SetupFilehook("lua/ARC_Server.lua", "post", folder)
Loader_SetupFilehook("lua/Hive_Server.lua", "post", folder)
Loader_SetupFilehook("lua/Hive.lua", "post", folder)
Loader_SetupFilehook("lua/DrifterEgg.lua", "post", folder)
Loader_SetupFilehook("lua/CommandStation_Server.lua", "post", folder)
Loader_SetupFilehook("lua/Whip.lua", "post", folder)
Loader_SetupFilehook("lua/Whip_Server.lua", "post", folder)
Loader_SetupFilehook("lua/Armory.lua", "post", folder)
-- minimap_blip.dds
-- marine_minimap_blip.dds

-- == AlienCommMines ==
folder = "AlienCommMines"
Loader_SetupFilehook("lua/Mine.lua", "post", folder) -- Alien comm sees parasited mines. 

-- == Selfharm ==
folder = "Selfharm"
Loader_SetupFilehook("lua/NS2Utility.lua", "post", folder) -- Removed selfharm of Arcs 
Loader_SetupFilehook("lua/DamageTypes.lua", "post", folder) -- selfharm counts as ff


-- == WeaponDecay ==
folder = "WeaponDecay"
Loader_SetupFilehook("lua/Weapons/Weapon_Server.lua", "post", folder) -- Tie Weapon HP to decay

-- == AutopickupWelder ==
folder = "AutopickupWelder"
Loader_SetupFilehook("lua/Marine.lua", "post", folder) -- reduced autopickup delay for welders to 1 sec


folder = "CombinedProtoFortress"
--[[ == 
Advanced Prototypelab,
FortressPvE
==]]
Loader_SetupFilehook("lua/TeamInfo.lua", "post", folder)
Loader_SetupFilehook("lua/TechTreeConstants.lua", "post", folder)
Loader_SetupFilehook("lua/TechTree.lua", "post", folder)



-- == Advanced Prototypelab ==
folder = "AdvancedPrototypelab"
Loader_SetupFilehook("lua/PrototypeLab.lua", "post", folder)
Loader_SetupFilehook("lua/PrototypeLab_Server.lua", "post", folder)
Loader_SetupFilehook("lua/NS2Utility.lua", "post", folder)
Loader_SetupFilehook("lua/MarineTeam.lua", "post", folder)
Loader_SetupFilehook("lua/Globals.lua", "post", folder)
Loader_SetupFilehook("lua/TechTreeButtons.lua", "post", folder)
-- TechTreeConstants.lua 
-- TechTree.lua 
-- TeamInfo.lua
Loader_SetupFilehook("lua/Balance.lua", "post", folder)
Loader_SetupFilehook("lua/TechData.lua", "post", folder)
Loader_SetupFilehook("lua/ServerStats.lua", "post", folder)
-- exo_holo_finished.cinematic
-- exo_holo_research.cinematic
-- exosuit_holo_alpha.dds
-- exosuit_holo_illumn.dds
-- exosuit_holo.dds
-- exosuit_holo.material
-- exosuit_holo.model
-- holo_cone.model
-- minigun_holo_material


-- == Always Show Status Icons ==
folder = "StatusIcons"
Loader_SetupFilehook( "lua/Hud/GUIPlayerStatus.lua", "post", folder ) 
Loader_SetupFilehook( "lua/AdvancedOptions.lua", "post", folder )

-- == FortressPvE ==
folder = "FortressPvE"
Loader_SetupFilehook("lua/AlienCommander.lua", "post", folder)
Loader_SetupFilehook("lua/Crag.lua", "post", folder)
Loader_SetupFilehook("lua/Shift.lua", "post", folder)
Loader_SetupFilehook("lua/Shade.lua", "post", folder)
Loader_SetupFilehook("lua/Whip.lua", "post", folder)
Loader_SetupFilehook("lua/Whip_Server.lua", "post", folder)
Loader_SetupFilehook("lua/BalanceHealth.lua", "post", folder)
Loader_SetupFilehook("lua/Balance.lua", "post", folder)
Loader_SetupFilehook("lua/Locale.lua", "post", folder) 
Loader_SetupFilehook( "lua/BalanceMisc.lua", "post", folder )
Loader_SetupFilehook( "lua/Hallucination.lua", "replace", folder )
-- TechTreeConstants.lua 
-- TechTree.lua
-- TeamInfo.lua
Loader_SetupFilehook("lua/TechData.lua", "post", folder)
Loader_SetupFilehook( "lua/TechTreeButtons.lua", "post", folder )
Loader_SetupFilehook("lua/AlienTeam.lua", "post", folder) -- must be the first loaded AlienTeam.lua
Loader_SetupFilehook("lua/ServerStats.lua", "post", folder)
Loader_SetupFilehook("lua/AlienTechMap.lua", "post", folder)
-- model folders: crag/shift/shade/whip
-- buildmenu.dds
-- whip_enzyme.material
-- whip_enzyme.surface_shade
-- ShadeHallucination.lua

folder = "FortressPvE/Minimap"
Loader_SetupFilehook("lua/Globals.lua", "post", folder)
Loader_SetupFilehook("lua/GUIMinimap.lua", "post", folder)
Loader_SetupFilehook("lua/NS2Utility.lua", "post", folder)
Loader_SetupFilehook("lua/MapBlipMixin.lua", "post", folder)
-- minimap_blip.dds

folder = "FortressPvE/Stormcloud"
Loader_SetupFilehook( "lua/Player_Client.lua", "post", folder )
Loader_SetupFilehook( "lua/Alien_Client.lua", "post", folder )
Loader_SetupFilehook( "lua/Alien_Server.lua", "post", folder )
Loader_SetupFilehook( "lua/Alien.lua", "post", folder )
Loader_SetupFilehook( "lua/NS2ConsoleCommands_Server.lua", "post", folder )
Loader_SetupFilehook( "lua/StormCloudMixin.lua", "post", folder )
Loader_SetupFilehook( "lua/Hud/GUIPlayerStatus.lua", "post", folder )
Loader_SetupFilehook( "lua/GUIAlienHUD.lua", "post", folder )
Loader_SetupFilehook( "lua/CommAbilities/Alien/StormCloud.lua", "replace", folder )
Loader_SetupFilehook( "lua/Skulk.lua", "post", folder )
Loader_SetupFilehook( "lua/Fade.lua", "post", folder )
-- storm_view.material
-- storm_view.surface_shader
-- storm.material
-- storm.surface_shader
-- ember.dds



folder = "Utility"
Loader_SetupFilehook("lua/Utility.lua", "post", folder)

-- == Resilience ==
folder = "Resilience"
Loader_SetupFilehook("lua/Alien.lua", "post", folder)
Loader_SetupFilehook("lua/Alien_Client.lua", "post", folder)
Loader_SetupFilehook("lua/Alien_Server.lua", "post", folder)
Loader_SetupFilehook("lua/AlienTeam.lua", "post", folder)
Loader_SetupFilehook("lua/AlienTechMap.lua", "post", folder)
Loader_SetupFilehook("lua/Balance.lua", "post", folder)
Loader_SetupFilehook("lua/DamageTypes.lua", "post", folder)
Loader_SetupFilehook("lua/Hud/GUIPlayerStatus.lua", "post", folder)
Loader_SetupFilehook("lua/GUIUpgradeChamberDisplay.lua", "post", folder)
Loader_SetupFilehook("lua/Locale.lua", "post", folder)
Loader_SetupFilehook("lua/Player_Client.lua", "post", folder)
Loader_SetupFilehook("lua/PlayerInfoEntity.lua", "post", folder)
Loader_SetupFilehook("lua/TechData.lua", "post", folder)
Loader_SetupFilehook("lua/TechTreeButtons.lua", "post", folder )
Loader_SetupFilehook("lua/TechTreeConstants.lua", "post", folder)


-- == Twilites Bugfixes ==
folder = "TwiliteFix"
Loader_SetupFilehook( "lua/Weapons/Alien/Gore.lua", "post", folder ) -- focus delay changed from 57% to 33%
Loader_SetupFilehook( "lua/Weapons/Alien/StabBlink.lua", "post", folder ) -- focus applies to stab
Loader_SetupFilehook( "lua/Babbler.lua", "post", folder ) -- attached babblers on other aliens dont jiggle
Loader_SetupFilehook( "lua/UmbraMixin.lua", "post", folder ) -- finetunes umbra for cloaked aliens
Loader_SetupFilehook( "lua/Weapons/BoneShield.lua", "post", folder ) -- fixed bone shield triggering cooldown when already on cooldown
Loader_SetupFilehook( "lua/Alien_Client.lua", "post", folder )
-- pulse_gre_elec.surface_shader    increased visibility on model


-- == Catpack affects welding ==
folder = "CatpackBuffs"
Loader_SetupFilehook( "lua/Exosuit.lua", "post", folder )
Loader_SetupFilehook( "lua/Player.lua", "post", folder )
Loader_SetupFilehook( "lua/Weapons/Marine/Welder.lua", "post", folder )
Loader_SetupFilehook("lua/Locale.lua", "post", folder) 

-- == Camo Onos Sneaking == 
folder = "OnosWalkingSound"
Loader_SetupFilehook( "lua/Onos_Client.lua", "post", folder )
Loader_SetupFilehook( "lua/Onos.lua", "post", folder )

-- == Less MAC noises ==
folder = "MacGreeting"
Loader_SetupFilehook( "lua/MAC.lua", "post", folder )

-- == QOL Stuff ==
folder = "QOL"
Loader_SetupFilehook("lua/GUIClassicAmmo.lua", "post", folder)

-- HallucinationCloak Mod
-- babbler_ball.surface_shader





