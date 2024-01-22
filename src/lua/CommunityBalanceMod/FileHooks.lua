-- ========= Community Balance Mod ===============================
--
-- 
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


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


local function Loader_SetupFilehook(filename, replace_type, folder, mainfolder)
    local newFilename 
    for i = string.len(filename), 3, -1 do 

        if mainfolder ~= nil and mainfolder ~= "" then 
            if filename:sub(i,i) == '/' then 
                newFilename = string.format("lua/CommunityBalanceMod/%s/%s%s", mainfolder, folder, filename:sub(i, string.len(filename) ))
                break
            end
            
        else
            if filename:sub(i,i) == '/' then 
                newFilename = string.format("lua/CommunityBalanceMod/%s%s", folder, filename:sub(i, string.len(filename) ))
                break
            end

        end
    end
    ModLoader.SetupFileHook(filename,  newFilename, replace_type)
end
local folder = ""
local mainfolder = ""


if GetGamemode() ~= "ns2" then 
    Log("CommunityBalanceMod: Custom Gamemode detected. Dont apply balance changes.")
    return
end

Script.Load("lua/CommunityBalanceMod/Others/Scripts/EnumUtils.lua")

-- == FortressPvE ==
folder = "FortressPvE/Minimap"
Loader_SetupFilehook("lua/Globals.lua", "post", folder)
Loader_SetupFilehook("lua/GUIMinimap.lua", "post", folder)
Loader_SetupFilehook("lua/MapBlipMixin.lua", "post", folder)
Loader_SetupFilehook("lua/NS2Utility.lua", "post", folder)
-- minimap_blip.dds

folder = "FortressPvE/Stormcloud"
Loader_SetupFilehook( "lua/Alien_Client.lua", "post", folder )
Loader_SetupFilehook( "lua/Alien_Server.lua", "post", folder )
Loader_SetupFilehook( "lua/Alien.lua", "post", folder )
Loader_SetupFilehook( "lua/Fade.lua", "post", folder )
Loader_SetupFilehook( "lua/GUIAlienHUD.lua", "post", folder )
Loader_SetupFilehook( "lua/Hud/GUIPlayerStatus.lua", "post", folder )
Loader_SetupFilehook( "lua/NS2ConsoleCommands_Server.lua", "post", folder )
Loader_SetupFilehook( "lua/Player_Client.lua", "post", folder )
Loader_SetupFilehook( "lua/Skulk.lua", "post", folder )
Loader_SetupFilehook( "lua/CommAbilities/Alien/StormCloud.lua", "post", folder )
Loader_SetupFilehook( "lua/StormCloudMixin.lua", "post", folder )
-- storm_view.material
-- storm_view.surface_shader
-- storm.material
-- storm.surface_shader
-- ember.dds

folder = "FortressPvE/Structures"
Loader_SetupFilehook("lua/Crag.lua", "post", folder)
Loader_SetupFilehook("lua/Shade.lua", "post", folder)
Loader_SetupFilehook("lua/Shift.lua", "post", folder)
Loader_SetupFilehook("lua/Whip_Server.lua", "post", folder)
Loader_SetupFilehook("lua/Whip.lua", "post", folder)
-- Loader_SetupFilehook("lua/WhipBomb.lua", "post", folder ) TODO remove

folder = "FortressPvE"
Loader_SetupFilehook("lua/AlienCommander.lua", "post", folder)
Loader_SetupFilehook("lua/AlienTeam.lua", "post", folder)
Loader_SetupFilehook("lua/AlienTechMap.lua", "post", folder)
Loader_SetupFilehook("lua/Balance.lua", "post", folder)
Loader_SetupFilehook("lua/BalanceHealth.lua", "post", folder)
Loader_SetupFilehook("lua/BalanceMisc.lua", "post", folder )
Loader_SetupFilehook("lua/Hallucination.lua", "post", folder )
Loader_SetupFilehook("lua/Locale.lua", "post", folder) 
Loader_SetupFilehook("lua/ServerStats.lua", "post", folder)
-- ShadeHallucination.lua
Loader_SetupFilehook("lua/TeamInfo.lua", "post", folder )
Loader_SetupFilehook("lua/TechData.lua", "post", folder)
Loader_SetupFilehook("lua/TechTree.lua", "post", folder)
Loader_SetupFilehook("lua/TechTreeButtons.lua", "post", folder )
Loader_SetupFilehook("lua/TechTreeConstants.lua", "post", folder)
Loader_SetupFilehook("lua/Utility.lua", "post", folder)
-- model folders: crag/shift/shade/whip
-- buildmenu.dds
-- whip_enzyme.material
-- whip_enzyme.surface_shade

-- == MDS Marines ==
folder = "MDSmarines"
Loader_SetupFilehook("lua/Balance.lua", "post", folder)
Loader_SetupFilehook("lua/BalanceHealth.lua", "post", folder)
Loader_SetupFilehook("lua/BalanceMisc.lua", "post", folder )
Loader_SetupFilehook("lua/DamageTypes.lua",  "post", folder)
Loader_SetupFilehook("lua/FireMixin.lua", "post", folder)
Loader_SetupFilehook("lua/Weapons/Alien/HealSprayMixin.lua", "post", folder)
-- TODO Hitsounds isnt loaded?
Loader_SetupFilehook("lua/Locale.lua", "post", folder) 

-- == Resilience / Heat Plating ==
folder = "Resilience"
Loader_SetupFilehook("lua/Alien_Client.lua", "post", folder)
Loader_SetupFilehook("lua/Alien_Upgrade.lua",  "post", folder)
Loader_SetupFilehook("lua/AlienTeam.lua", "post", folder)
Loader_SetupFilehook("lua/AlienTechMap.lua", "post", folder)
Loader_SetupFilehook("lua/Balance.lua", "post", folder)
Loader_SetupFilehook("lua/DamageTypes.lua",  "post", folder)
Loader_SetupFilehook("lua/FireMixin.lua", "post", folder)
Loader_SetupFilehook("lua/GUIUpgradeChamberDisplay.lua", "post", folder)
Loader_SetupFilehook("lua/Locale.lua", "post", folder) 
Loader_SetupFilehook("lua/Mine.lua", "post", folder)
Loader_SetupFilehook("lua/PlayerInfoEntity.lua", "post", folder)
Loader_SetupFilehook("lua/TechData.lua", "post", folder)
Loader_SetupFilehook("lua/TechTreeButtons.lua", "post", folder )
Loader_SetupFilehook("lua/TechTreeConstants.lua", "post", folder)

mainfolder = "Others"

-- == Build Version Overlay ==
folder = "BuildVersionOverlay"
Loader_SetupFilehook("lua/GUIFeedback.lua", "post", folder, mainfolder)

-- == Github Changelog ==
folder = "GithubChangelog"
Loader_SetupFilehook("lua/Player_Client.lua", "post", folder, mainfolder)

-- == Ingame Changelog ==
folder = "IngameChangelog"
Loader_SetupFilehook("lua/menu2/GUIMainMenu.lua", "post", folder, mainfolder)
-- GUIBetaBalanceChangelogData.lua TODO move from scripts to own folder
-- GUIBetaBalanceChangelog.lua
-- GUIMenuBetaBalanceChangelogButton.lua
-- balance_icon_hover.dds
-- balance_icon.dds

mainfolder = "MinorBalance"

-- == Advanced Prototypelab ==
folder = "AdvancedPrototypelab"
Loader_SetupFilehook("lua/Balance.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/Globals.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/bots/MarineCommanderBrain_Senses.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/bots/MarineCommanerBrain_TechPath.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/MarineTeam.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/NS2Utility.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/PrototypeLab_Server.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/PrototypeLab.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/ServerStats.lua", "post", folder, mainfolder)
Loader_SetupFilehook( "lua/TeamInfo.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/TechData.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/TechTree.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/TechTreeButtons.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/TechTreeConstants.lua", "post", folder, mainfolder)
-- exo_holo_finished.cinematic
-- exo_holo_research.cinematic
-- exosuit_holo_alpha.dds
-- exosuit_holo_illumn.dds
-- exosuit_holo.dds
-- exosuit_holo.material
-- exosuit_holo.model
-- holo_cone.model
-- minigun_holo_material

-- == Pulse Grenade Buff ==
-- == Mine, Welder drop reduction ==
-- == Shift Energy Nerf ==
folder = "BalanceValueChanges"
Loader_SetupFilehook("lua/Balance.lua", "post", folder, mainfolder)
Loader_SetupFilehook( "lua/BalanceMisc.lua", "post", folder, mainfolder)

-- == Catpack affects welding ==
folder = "CatpackBuffs"
Loader_SetupFilehook( "lua/Exosuit.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/Locale.lua", "post", folder, mainfolder)
Loader_SetupFilehook( "lua/Player.lua", "post", folder, mainfolder)
Loader_SetupFilehook( "lua/Weapons/Marine/Welder.lua", "post", folder, mainfolder)

folder = "CloakingHaze"
--Loader_SetupFilehook("lua/AlienTeam.lua", "post" , folder, mainfolder)
--Loader_SetupFilehook("lua/Balance.lua", "post" , folder, mainfolder) 
--Loader_SetupFilehook("lua/CloakableMixin.lua", "post" , folder, mainfolder)
-- TODO does cloaking haze gets loaded?
--Loader_SetupFilehook("lua/Drifter.lua", "post" , folder, mainfolder) 
--Loader_SetupFilehook("lua/Locale.lua", "post", folder, mainfolder)
--Loader_SetupFilehook("lua/TechData.lua", "post" , folder, mainfolder)
--Loader_SetupFilehook("lua/TechTreeButtons.lua", "post" , folder, mainfolder) 
--Loader_SetupFilehook("lua/TechTreeConstants.lua", "post" , folder, mainfolder)

folder = "CloakRework"
-- Loader_SetupFilehook( "lua/Alien.lua", "post", folder, mainfolder) -- allows cloak in combat
-- Loader_SetupFilehook( "lua/Babbler.lua", "post", folder, mainfolder) -- cloak moving babblers
-- Loader_SetupFilehook( "lua/CloakableMixin.lua", "post", folder, mainfolder)
-- Loader_SetupFilehook( "lua/Cyst_Server.lua", "post" , folder, mainfolder) -- Removed unnecessary Cyst nearby enemy check
-- Loader_SetupFilehook( "lua/DetectableMixin.lua", "post", folder, mainfolder) -- detection updates faster
-- Loader_SetupFilehook( "lua/DetectorMixin.lua", "post", folder, mainfolder) -- ink blocks out passive obs detection
-- Loader_SetupFilehook( "lua/DisorientableMixin.lua", "post", folder, mainfolder) -- updates faster
-- Loader_SetupFilehook( "lua/DrifterEgg.lua", "post", folder, mainfolder) -- cloaks driftereggs
-- Loader_SetupFilehook( "lua/Hydra.lua", "post", folder, mainfolder) -- cloak hydras?
-- Loader_SetupFilehook( "lua/Lerk.lua", "post", folder, mainfolder) -- allows lerks to move cloaked
-- Loader_SetupFilehook( "lua/LOSMixin.lua", "post", folder, mainfolder) -- update map when non player cloak vs non player
-- Loader_SetupFilehook( "lua/Player_Client.lua", "post", folder, mainfolder) -- show cloak icon only when fully cloaked
-- Loader_SetupFilehook( "lua/CommAbilities/Alien/ShadeInk.lua", "post", folder, mainfolder) -- less visual distortion for marines, cloaks players
-- Loader_SetupFilehook( "lua/UmbraMixin.lua", "post", folder, mainfolder) -- umbra doesnt show for cloaked aliens
-- Loader_SetupFilehook( "lua/Whip.lua", "post", folder, mainfolder) -- cloaks whips?
-- babbler_ball.surface_shader

-- focus delay changed from 57% to 33%
folder = "GoreFocus"
Loader_SetupFilehook( "lua/Weapons/Alien/Gore.lua", "post", folder, mainfolder) 

-- == Gorge energy reduction ==
folder = "GorgeEnergyReduction"
Loader_SetupFilehook("lua/Weapons/Alien/BabblerEggAbility.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/Balance.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/Weapons/Alien/HydraAbility.lua", "post", folder, mainfolder)

-- == Faster MACs with better LOS == 
folder = "MacBuffs"
Loader_SetupFilehook("lua/MAC.lua", "post", folder, mainfolder)

-- == Camo Onos Sneaking == 
folder = "OnosWalkingSound"
Loader_SetupFilehook( "lua/Onos_Client.lua", "post", folder, mainfolder)
Loader_SetupFilehook( "lua/Onos.lua", "post", folder, mainfolder)

-- == Railgun dropoff ==
folder = "RailgunDropoff"
Loader_SetupFilehook("lua/Weapons/Marine/Railgun.lua", "post", folder, mainfolder)

-- == Reduced switching cost ==
folder = "ReducedSwitchingCost"
Loader_SetupFilehook("lua/AlienUpgradeManager.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/Balance.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/GUIAlienBuyMenu.lua", "post", folder, mainfolder) -- possible conflict with Devnull quick buy
Loader_SetupFilehook("lua/TechData.lua", "post", folder, mainfolder)

-- == Selfharm ==
folder = "Selfharm"
Loader_SetupFilehook("lua/DamageTypes.lua", "post", folder, mainfolder) -- selfharm counts as ff
Loader_SetupFilehook("lua/NS2Utility.lua", "post", folder, mainfolder) -- Removed selfharm of Arcs 

-- focus applies to stab
folder = "StabFocus"
Loader_SetupFilehook( "lua/Weapons/Alien/StabBlink.lua", "post", folder, mainfolder) 

-- == Stomp knock down and visual change ==
folder = "StompKnockDown"
Loader_SetupFilehook("lua/Balance.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/Weapons/Alien/Shockwave.lua", "post", folder, mainfolder)

-- == Passive ability for upgrades ==
folder = "UpgradesPassiveAbilities"
Loader_SetupFilehook("lua/Shell.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/Spur.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/Veil.lua", "post", folder, mainfolder)

-- == WeaponDecay ==
folder = "WeaponDecay"
Loader_SetupFilehook("lua/Weapons/Weapon_Server.lua", "post", folder, mainfolder) -- Tie Weapon HP to decay


mainfolder = "QoLChanges"

-- == AlienCommMines ==
folder = "AlienCommMines"
Loader_SetupFilehook("lua/Mine.lua", "post", folder, mainfolder) -- Alien comm sees parasited mines. 

-- == Armslab hologram fix ==
folder = "ArmslabHologram"
Loader_SetupFilehook("lua/ResearchMixin.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/ArmsLab.lua", "post", folder, mainfolder)

-- == AutopickupWelder ==
folder = "AutopickupWelder"
Loader_SetupFilehook("lua/Marine.lua", "post", folder, mainfolder) -- reduced autopickup delay for welders to 1 sec

-- attached babblers on other aliens dont jiggle anyone
folder = "BabblerJiggle"
Loader_SetupFilehook( "lua/Babbler.lua", "post", folder, mainfolder) 

-- fixed boneshield triggering cooldown when already on cooldown
folder = "BoneshieldCooldown"
Loader_SetupFilehook( "lua/Weapons/BoneShield.lua", "post", folder, mainfolder) 

folder = "CommunityServerFirst"
Loader_SetupFilehook("lua/menu2/NavBar/Screens/PlayList/GUIMenuPlayList.lua", "post", folder, mainfolder)

-- == Devnull QoL ==
folder = "DevnullQoL"
Loader_SetupFilehook("lua/Babbler.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/Weapons/Alien/BabblerPheromone.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/Weapons/Alien/BoneShield.lua", "post", folder, mainfolder)

-- == Destroy Clogs faster == 
folder = "DigestClogs"
Loader_SetupFilehook("lua/Clog.lua", "post", folder, mainfolder)

-- == Drifter doesnt follow echo ==
folder = "DrifterStopAtEcho"
Loader_SetupFilehook( "lua/Drifter.lua", "post", folder, mainfolder)

-- fixes FT errors when JP rushing a hive?
folder = "FlamethrowerCrash"
Loader_SetupFilehook( "lua/Weapons/Marine/Flamethrower.lua", "post", folder, mainfolder) 

-- == Less MAC noises ==
folder = "MacGreeting"
Loader_SetupFilehook( "lua/MAC.lua", "post", folder, mainfolder)

-- == Dynamic Minimap Icons == 
folder = "Minimap"
Loader_SetupFilehook("lua/ARC_Server.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/ARC", "post", folder, mainfolder)
Loader_SetupFilehook("lua/Armory_Server.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/Armory.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/CommandStation_Server.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/DrifterEgg.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/Globals.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/GUIMinimap.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/Hive_Server.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/Hive.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/MapBlip.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/MapBlipMixin.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/NS2Utility.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/Whip_Server.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/Whip.lua", "post", folder, mainfolder)
-- minimap_blip.dds
-- marine_minimap_blip.dds

-- == Forces Particles on Low/High ==
folder = "ParticleSetting"
Loader_SetupFilehook("lua/Render.lua", "post", folder, mainfolder)

-- increased visibility on model
folder = "PulseVisibility"
Loader_SetupFilehook( "lua/Alien_Client.lua", "post", folder, mainfolder) 
-- pulse_gre_elec.surface_shader    

-- == Advanced Support Name Change ==
folder = "RenamedAdvancedSupport"
Loader_SetupFilehook("lua/Locale.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/TechData.lua", "post", folder, mainfolder)

-- == Bugfix for Structure Reposition ==
folder = "RepositionFix"
Loader_SetupFilehook("lua/AlienStructureMoveMixin.lua",  "post", folder, mainfolder)

-- == Score changes for building and hydras ==
folder = "ScoreBuilding"
Loader_SetupFilehook("lua/PointGiverMixin.lua", "post", folder, mainfolder)

-- == Always Show Status Icons ==
folder = "StatusIcons"
Loader_SetupFilehook( "lua/AdvancedOptions.lua", "post", folder, mainfolder)
Loader_SetupFilehook( "lua/Hud/GUIPlayerStatus.lua", "post", folder, mainfolder)

-- == TechTree GUI fixes ==
folder = "TechTreeGUI"
Loader_SetupFilehook("lua/AlienTechMap.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/GUITechMap.lua", "post", folder, mainfolder) -- fixes advanced protolab GUI issue
Loader_SetupFilehook("lua/MarineTechMap.lua", "post", folder, mainfolder)
Loader_SetupFilehook("lua/TechData.lua", "post", folder, mainfolder)
Loader_SetupFilehook( "lua/TechTreeButtons.lua", "post", folder, mainfolder)


