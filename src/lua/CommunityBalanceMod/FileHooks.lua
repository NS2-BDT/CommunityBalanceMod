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

-- General NS2 Files
ModLoader.SetupFileHook("lua/NetworkMessages.lua", "lua/CommunityBalanceMod/NetworkMessages.lua", "replace")
ModLoader.SetupFileHook("lua/NS2ConsoleCommands_Server.lua", "lua/CommunityBalanceMod/NS2ConsoleCommands_Server.lua", "replace")
ModLoader.SetupFileHook("lua/NS2Utility.lua", "lua/CommunityBalanceMod/NS2Utility.lua", "replace")
ModLoader.SetupFileHook("lua/NS2Utility_Server.lua", "lua/CommunityBalanceMod/NS2Utility_Server.lua", "replace")
ModLoader.SetupFileHook("lua/Shared.lua", "lua/CommunityBalanceMod/Shared.lua", "replace")
ModLoader.SetupFileHook("lua/Server.lua", "lua/CommunityBalanceMod/Server.lua", "replace")
ModLoader.SetupFileHook("lua/MarineWeaponEffects.lua", "lua/CommunityBalanceMod/MarineWeaponEffects.lua", "replace")
ModLoader.SetupFileHook("lua/MarineStructureEffects.lua", "lua/CommunityBalanceMod/MarineStructureEffects.lua", "replace")
ModLoader.SetupFileHook("lua/Globals.lua", "lua/CommunityBalanceMod/Globals.lua", "replace")
ModLoader.SetupFileHook("lua/DamageTypes.lua", "lua/CommunityBalanceMod/DamageTypes.lua", "replace")
ModLoader.SetupFileHook("lua/Player.lua", "lua/CommunityBalanceMod/Player.lua", "replace")
ModLoader.SetupFileHook("lua/Player_Client.lua", "lua/CommunityBalanceMod/Player_Client.lua", "replace")
ModLoader.SetupFileHook("lua/PlayerInfoEntity.lua", "lua/CommunityBalanceMod/PlayerInfoEntity.lua", "replace")
ModLoader.SetupFileHook("lua/Commander_Buttons.lua", "lua/CommunityBalanceMod/Commander_Buttons.lua", "replace")
ModLoader.SetupFileHook("lua/Commander_GhostStructure.lua", "lua/CommunityBalanceMod/Commander_GhostStructure.lua", "replace")
ModLoader.SetupFileHook("lua/HitSounds.lua", "lua/CommunityBalanceMod/HitSounds.lua", "replace")
ModLoader.SetupFileHook("lua/MapBlip.lua", "lua/CommunityBalanceMod/MapBlip.lua", "replace")
ModLoader.SetupFileHook("lua/Render.lua", "lua/CommunityBalanceMod/Render.lua", "replace")
ModLoader.SetupFileHook("lua/ServerStats.lua", "lua/CommunityBalanceMod/ServerStats.lua", "replace")
ModLoader.SetupFileHook("lua/TeamInfo.lua", "lua/CommunityBalanceMod/TeamInfo.lua", "replace")
ModLoader.SetupFileHook("lua/TechData.lua", "lua/CommunityBalanceMod/TechData.lua", "replace")
ModLoader.SetupFileHook("lua/TechTree.lua", "lua/CommunityBalanceMod/TechTree.lua", "replace")
ModLoader.SetupFileHook("lua/TechTreeButtons.lua", "lua/CommunityBalanceMod/TechTreeButtons.lua", "replace")
ModLoader.SetupFileHook("lua/TechTreeConstants.lua", "lua/CommunityBalanceMod/TechTreeConstants.lua", "replace")
ModLoader.SetupFileHook("lua/Utility.lua", "lua/CommunityBalanceMod/Utility.lua", "post")
ModLoader.SetupFileHook("lua/PlayingTeam.lua", "lua/CommunityBalanceMod/PlayingTeam.lua", "replace")
ModLoader.SetupFileHook("lua/Commander_Client.lua", "lua/CommunityBalanceMod/Commander_Client.lua", "replace")
ModLoader.SetupFileHook("lua/AmmoPack.lua", "lua/CommunityBalanceMod/AmmoPack.lua", "replace")
ModLoader.SetupFileHook("lua/DamageEffects.lua", "lua/CommunityBalanceMod/DamageEffects.lua", "replace")
ModLoader.SetupFileHook("lua/EquipmentOutline.lua", "lua/CommunityBalanceMod/EquipmentOutline.lua", "replace")
ModLoader.SetupFileHook("lua/BuildUtility.lua", "lua/CommunityBalanceMod/BuildUtility.lua", "replace")

-- Bots
ModLoader.SetupFileHook("lua/bots/MarineCommanderBrain_Senses.lua", "lua/CommunityBalanceMod/bots/MarineCommanderBrain_Senses.lua", "replace")
ModLoader.SetupFileHook("lua/bots/MarineCommanerBrain_TechPath.lua", "lua/CommunityBalanceMod/bots/MarineCommanerBrain_TechPath.lua", "replace")

-- Mixins
ModLoader.SetupFileHook("lua/NanoShieldMixin.lua", "lua/CommunityBalanceMod/NanoShieldMixin.lua", "replace")
ModLoader.SetupFileHook("lua/CatPackMixin.lua", "lua/CommunityBalanceMod/CatPackMixin.lua", "replace")
ModLoader.SetupFileHook("lua/CloakableMixin.lua", "lua/CommunityBalanceMod/CloakableMixin.lua", "replace")
ModLoader.SetupFileHook("lua/DetectableMixin.lua", "lua/CommunityBalanceMod/DetectableMixin.lua", "replace")
ModLoader.SetupFileHook("lua/DetectorMixin.lua", "lua/CommunityBalanceMod/DetectorMixin.lua", "replace")
ModLoader.SetupFileHook("lua/DisorientableMixin.lua", "lua/CommunityBalanceMod/DisorientableMixin.lua", "replace")
ModLoader.SetupFileHook("lua/FireMixin.lua", "lua/CommunityBalanceMod/FireMixin.lua", "replace")
ModLoader.SetupFileHook("lua/Weapons/Alien/HealSprayMixin.lua", "lua/CommunityBalanceMod/Weapons/Alien/HealSprayMixin.lua", "replace")
ModLoader.SetupFileHook("lua/LOSMixin.lua", "lua/CommunityBalanceMod/LOSMixin.lua", "replace")
ModLoader.SetupFileHook("lua/MapBlipMixin.lua", "lua/CommunityBalanceMod/MapBlipMixin.lua", "replace")
ModLoader.SetupFileHook("lua/PointGiverMixin.lua", "lua/CommunityBalanceMod/PointGiverMixin.lua", "replace")
ModLoader.SetupFileHook("lua/ResearchMixin.lua", "lua/CommunityBalanceMod/ResearchMixin.lua", "replace")
ModLoader.SetupFileHook("lua/UmbraMixin.lua", "lua/CommunityBalanceMod/UmbraMixin.lua", "replace")
ModLoader.SetupFileHook("lua/StormCloudMixin.lua", "lua/CommunityBalanceMod/StormCloudMixin.lua", "replace")
ModLoader.SetupFileHook("lua/HiveVision.lua", "lua/CommunityBalanceMod/HiveVision.lua", "replace")
ModLoader.SetupFileHook("lua/HiveVisionMixin.lua", "lua/CommunityBalanceMod/HiveVisionMixin.lua", "replace")
ModLoader.SetupFileHook("lua/WebableMixin.lua", "lua/CommunityBalanceMod/WebableMixin.lua", "replace")
ModLoader.SetupFileHook("lua/PowerConsumerMixin.lua", "lua/CommunityBalanceMod/PowerConsumerMixin.lua", "replace")
ModLoader.SetupFileHook("lua/MACVariantMixin.lua", "lua/CommunityBalanceMod/MACVariantMixin.lua", "replace")
ModLoader.SetupFileHook("lua/UnitStatusMixin.lua", "lua/CommunityBalanceMod/UnitStatusMixin.lua", "replace")
ModLoader.SetupFileHook("lua/ClientLOSMixin.lua", "lua/CommunityBalanceMod/ClientLOSMixin.lua", "replace")

-- Scary GUI Stuff is Scary
ModLoader.SetupFileHook("lua/GUIAlienBuyMenu.lua", "lua/CommunityBalanceMod/GUIAlienBuyMenu.lua", "replace")
ModLoader.SetupFileHook("lua/GUIAlienHUD.lua", "lua/CommunityBalanceMod/GUIAlienHUD.lua", "replace")
ModLoader.SetupFileHook("lua/GUIClassicAmmo.lua", "lua/CommunityBalanceMod/GUIClassicAmmo.lua", "replace")
ModLoader.SetupFileHook("lua/GUICommanderButtons.lua", "lua/CommunityBalanceMod/GUICommanderButtons.lua", "replace")
ModLoader.SetupFileHook("lua/GUIFeedback.lua", "lua/CommunityBalanceMod/GUIFeedback.lua", "replace")
ModLoader.SetupFileHook("lua/menu2/GUIMainMenu.lua", "lua/CommunityBalanceMod/menu2/GUIMainMenu.lua", "replace")
ModLoader.SetupFileHook("lua/GUIMinimap.lua", "lua/CommunityBalanceMod/GUIMinimap.lua", "replace")
ModLoader.SetupFileHook("lua/Hud/GUIPlayerStatus.lua", "lua/CommunityBalanceMod/Hud/GUIPlayerStatus.lua", "replace")
ModLoader.SetupFileHook("lua/GUITechMap.lua", "lua/CommunityBalanceMod/GUITechMap.lua", "replace")
ModLoader.SetupFileHook("lua/GUIUpgradeChamberDisplay.lua", "lua/CommunityBalanceMod/GUIUpgradeChamberDisplay.lua", "replace")
ModLoader.SetupFileHook("lua/GUIActionIcon.lua", "lua/CommunityBalanceMod/GUIActionIcon.lua", "replace")
--ModLoader.SetupFileHook("lua/Hud/GUIInventory.lua", "lua/CommunityBalanceMod/Hud/GUIInventory.lua", "replace")
ModLoader.SetupFileHook("lua/GUIAuraDisplay.lua", "lua/CommunityBalanceMod/GUIAuraDisplay.lua", "replace")
ModLoader.SetupFileHook("lua/Hud/Marine/GUIMarineHUD.lua", "lua/CommunityBalanceMod/Hud/Marine/GUIMarineHUD.lua", "replace")
ModLoader.SetupFileHook("lua/Hud/Marine/GUIExoHUD.lua", "lua/CommunityBalanceMod/Hud/Marine/GUIExoHUD.lua", "replace")
ModLoader.SetupFileHook("lua/GUIAssets.lua", "lua/CommunityBalanceMod/GUIAssets.lua", "replace")
--ModLoader.SetupFileHook("lua/GUIDeathMessages.lua", "lua/CommunityBalanceMod/GUIDeathMessages.lua", "replace")
ModLoader.SetupFileHook("lua/GUIPickups.lua", "lua/CommunityBalanceMod/GUIPickups.lua", "replace")
ModLoader.SetupFileHook("lua/GUIGameEndStats.lua", "lua/CommunityBalanceMod/GUIGameEndStats.lua", "replace")
ModLoader.SetupFileHook("lua/GUIInsight_OtherHealthbars.lua", "lua/CommunityBalanceMod/GUIInsight_OtherHealthbars.lua", "replace")
ModLoader.SetupFileHook("lua/GUIInsight_PlayerFrames.lua", "lua/CommunityBalanceMod/GUIInsight_PlayerFrames.lua", "replace")
ModLoader.SetupFileHook("lua/GUIUnitStatus.lua", "lua/CommunityBalanceMod/GUIUnitStatus.lua", "replace")

-- Marine Base Files
ModLoader.SetupFileHook("lua/Marine.lua", "lua/CommunityBalanceMod/Marine.lua", "replace")
ModLoader.SetupFileHook("lua/Marine_Server.lua", "lua/CommunityBalanceMod/Marine_Server.lua", "replace")
ModLoader.SetupFileHook("lua/MarineTeam.lua", "lua/CommunityBalanceMod/MarineTeam.lua", "replace")
ModLoader.SetupFileHook("lua/MarineTechMap.lua", "lua/CommunityBalanceMod/MarineTechMap.lua", "replace")
ModLoader.SetupFileHook("lua/MarineBuy_Client.lua", "lua/CommunityBalanceMod/MarineBuy_Client.lua", "replace")
ModLoader.SetupFileHook("lua/MarineVariantMixin.lua", "lua/CommunityBalanceMod/MarineVariantMixin.lua", "replace")
ModLoader.SetupFileHook("lua/MarineTeamInfo.lua", "lua/CommunityBalanceMod/MarineTeamInfo.lua", "replace")
ModLoader.SetupFileHook("lua/MarineCommander.lua", "lua/CommunityBalanceMod/MarineCommander.lua", "replace")
ModLoader.SetupFileHook("lua/MarineCommander_Server.lua", "lua/CommunityBalanceMod/MarineCommander_Server.lua", "replace")

-- Exosuit Base Files
ModLoader.SetupFileHook("lua/Exo.lua", "lua/CommunityBalanceMod/Exo.lua", "replace")
ModLoader.SetupFileHook("lua/ReadyRoomExo.lua", "lua/CommunityBalanceMod/ReadyRoomExo.lua", "replace")
ModLoader.SetupFileHook("lua/ExoVariantMixin.lua", "lua/CommunityBalanceMod/ExoVariantMixin.lua", "replace")
ModLoader.SetupFileHook("lua/Weapons/Marine/ExoWeaponHolder.lua", "lua/CommunityBalanceMod/Weapons/Marine/ExoWeaponHolder.lua", "replace")

-- Weapon and Ability Base Files
ModLoader.SetupFileHook("lua/Weapons/DotMarker.lua", "lua/CommunityBalanceMod/Weapons/DotMarker.lua", "replace")
ModLoader.SetupFileHook("lua/Weapons/Weapon_Server.lua", "lua/CommunityBalanceMod/Weapons/Weapon_Server.lua", "replace")
ModLoader.SetupFileHook("lua/Weapons/WeaponDisplayManager.lua", "lua/CommunityBalanceMod/Weapons/WeaponDisplayManager.lua", "replace")

-- Marine Weapons
ModLoader.SetupFileHook("lua/Weapons/Marine/Claw.lua", "lua/CommunityBalanceMod/Weapons/Marine/Claw.lua", "replace")
ModLoader.SetupFileHook("lua/Weapons/Marine/Railgun.lua", "lua/CommunityBalanceMod/Weapons/Marine/Railgun.lua", "replace")
ModLoader.SetupFileHook("lua/Exosuit.lua", "lua/CommunityBalanceMod/Exosuit.lua", "replace")
ModLoader.SetupFileHook("lua/Weapons/Marine/Flamethrower.lua", "lua/CommunityBalanceMod/Weapons/Marine/Flamethrower.lua", "replace")
ModLoader.SetupFileHook("lua/Weapons/PredictedProjectile.lua", "lua/CommunityBalanceMod/Weapons/PredictedProjectile.lua", "replace")
ModLoader.SetupFileHook("lua/Mine.lua", "lua/CommunityBalanceMod/Mine.lua", "replace")
ModLoader.SetupFileHook("lua/Weapons/Marine/Welder.lua", "lua/CommunityBalanceMod/Weapons/Marine/Welder.lua", "replace")

-- Marine GUI
ModLoader.SetupFileHook("lua/GUIMarineBuyMenu.lua", "lua/CommunityBalanceMod/GUIMarineBuyMenu.lua", "replace")
ModLoader.SetupFileHook("lua/GUIExoThruster.lua", "lua/CommunityBalanceMod/GUIExoThruster.lua", "replace")
ModLoader.SetupFileHook("lua/GUIInsight_PlayerHealthbars.lua", "lua/CommunityBalanceMod/GUIInsight_PlayerHealthbars.lua", "replace")

-- Marine Structures
ModLoader.SetupFileHook("lua/Armory.lua", "lua/CommunityBalanceMod/Armory.lua", "replace")
ModLoader.SetupFileHook("lua/Armory_Server.lua", "lua/CommunityBalanceMod/Armory_Server.lua", "replace")
ModLoader.SetupFileHook("lua/ArmsLab.lua", "lua/CommunityBalanceMod/ArmsLab.lua", "replace")
ModLoader.SetupFileHook("lua/PrototypeLab.lua", "lua/CommunityBalanceMod/PrototypeLab.lua", "replace")
ModLoader.SetupFileHook("lua/PrototypeLab_Server.lua", "lua/CommunityBalanceMod/PrototypeLab_Server.lua", "replace")
ModLoader.SetupFileHook("lua/RoboticsFactory.lua", "lua/CommunityBalanceMod/RoboticsFactory.lua", "replace")
ModLoader.SetupFileHook("lua/Sentry.lua", "lua/CommunityBalanceMod/Sentry.lua", "replace")
ModLoader.SetupFileHook("lua/SentryBattery.lua", "lua/CommunityBalanceMod/SentryBattery.lua", "replace")
ModLoader.SetupFileHook("lua/PhaseGate.lua", "lua/CommunityBalanceMod/PhaseGate.lua", "replace")
ModLoader.SetupFileHook("lua/CommandStation.lua", "lua/CommunityBalanceMod/CommandStation.lua", "replace")
ModLoader.SetupFileHook("lua/CommandStructure_Server.lua", "lua/CommunityBalanceMod/CommandStructure_Server.lua", "replace")
ModLoader.SetupFileHook("lua/Extractor.lua", "lua/CommunityBalanceMod/Extractor.lua", "replace")
ModLoader.SetupFileHook("lua/InfantryPortal.lua", "lua/CommunityBalanceMod/InfantryPortal.lua", "replace")
ModLoader.SetupFileHook("lua/Observatory.lua", "lua/CommunityBalanceMod/Observatory.lua", "replace")
ModLoader.SetupFileHook("lua/PowerPoint.lua", "lua/CommunityBalanceMod/PowerPoint.lua", "replace")

-- Marine Units
ModLoader.SetupFileHook("lua/ARC.lua", "lua/CommunityBalanceMod/ARC.lua", "replace")
ModLoader.SetupFileHook("lua/ARC_Server.lua", "lua/CommunityBalanceMod/ARC_Server.lua", "replace")
ModLoader.SetupFileHook("lua/MAC.lua", "lua/CommunityBalanceMod/MAC.lua", "replace")

-- Alien Base Files
ModLoader.SetupFileHook("lua/Alien.lua", "lua/CommunityBalanceMod/Alien.lua", "replace")
ModLoader.SetupFileHook("lua/Alien_Client.lua", "lua/CommunityBalanceMod/Alien_Client.lua", "replace")
ModLoader.SetupFileHook("lua/Alien_Server.lua", "lua/CommunityBalanceMod/Alien_Server.lua", "replace")
ModLoader.SetupFileHook("lua/AlienCommander.lua", "lua/CommunityBalanceMod/AlienCommander.lua", "replace")
ModLoader.SetupFileHook("lua/AlienStructure.lua", "lua/CommunityBalanceMod/AlienStructure.lua", "replace")
ModLoader.SetupFileHook("lua/AlienStructureMoveMixin.lua", "lua/CommunityBalanceMod/AlienStructureMoveMixin.lua", "replace")
ModLoader.SetupFileHook("lua/AlienTeam.lua", "lua/CommunityBalanceMod/AlienTeam.lua", "replace")
ModLoader.SetupFileHook("lua/AlienTechMap.lua", "lua/CommunityBalanceMod/AlienTechMap.lua", "replace")
ModLoader.SetupFileHook("lua/AlienUpgradeManager.lua", "lua/CommunityBalanceMod/AlienUpgradeManager.lua", "replace")
ModLoader.SetupFileHook("lua/AlienWeaponEffects.lua", "lua/CommunityBalanceMod/AlienWeaponEffects.lua", "replace")
ModLoader.SetupFileHook("lua/EvolutionChamber.lua", "lua/CommunityBalanceMod/EvolutionChamber.lua", "replace")

-- Alien Ability and Weapon Files
ModLoader.SetupFileHook("lua/Weapons/Alien/Ability.lua", "lua/CommunityBalanceMod/Weapons/Alien/Ability.lua", "replace")
ModLoader.SetupFileHook("lua/Babbler.lua", "lua/CommunityBalanceMod/Babbler.lua", "replace")
ModLoader.SetupFileHook("lua/BabblerEgg.lua", "lua/CommunityBalanceMod/BabblerEgg.lua", "replace")
ModLoader.SetupFileHook("lua/Weapons/Alien/Web.lua", "lua/CommunityBalanceMod/Weapons/Alien/Web.lua", "replace")
ModLoader.SetupFileHook("lua/Weapons/Alien/BabblerEggAbility.lua", "lua/CommunityBalanceMod/Weapons/Alien/BabblerEggAbility.lua", "replace")
ModLoader.SetupFileHook("lua/Weapons/Alien/BabblerPheromone.lua", "lua/CommunityBalanceMod/Weapons/Alien/BabblerPheromone.lua", "replace")
ModLoader.SetupFileHook("lua/Weapons/Alien/BoneShield.lua", "lua/CommunityBalanceMod/Weapons/Alien/BoneShield.lua", "replace")
ModLoader.SetupFileHook("lua/Weapons/Alien/Gore.lua", "lua/CommunityBalanceMod/Weapons/Alien/Gore.lua", "replace")
ModLoader.SetupFileHook("lua/Hallucination.lua", "lua/CommunityBalanceMod/Hallucination.lua", "replace")
ModLoader.SetupFileHook("lua/Weapons/Alien/HydraAbility.lua", "lua/CommunityBalanceMod/Weapons/Alien/HydraAbility.lua", "replace")
ModLoader.SetupFileHook("lua/Weapons/Alien/Shockwave.lua", "lua/CommunityBalanceMod/Weapons/Alien/Shockwave.lua", "replace")
ModLoader.SetupFileHook("lua/Weapons/Alien/StabBlink.lua", "lua/CommunityBalanceMod/Weapons/Alien/StabBlink.lua", "replace")
ModLoader.SetupFileHook("lua/CommAbilities/Alien/StormCloud.lua", "lua/CommunityBalanceMod/CommAbilities/Alien/StormCloud.lua", "replace")
ModLoader.SetupFileHook("lua/CommAbilities/Alien/HallucinationCloud.lua", "lua/CommunityBalanceMod/CommAbilities/Alien/HallucinationCloud.lua", "replace")
ModLoader.SetupFileHook("lua/CommAbilities/Alien/ShadeInk.lua", "lua/CommunityBalanceMod/CommAbilities/Alien/ShadeInk.lua", "replace")

-- Alien Structures
ModLoader.SetupFileHook("lua/Clog.lua", "lua/CommunityBalanceMod/Clog.lua", "replace")
ModLoader.SetupFileHook("lua/Crag.lua", "lua/CommunityBalanceMod/Crag.lua", "replace")
ModLoader.SetupFileHook("lua/Cyst.lua", "lua/CommunityBalanceMod/Cyst.lua", "replace")
ModLoader.SetupFileHook("lua/Harvester.lua", "lua/CommunityBalanceMod/Harvester.lua", "replace")
ModLoader.SetupFileHook("lua/Hive.lua", "lua/CommunityBalanceMod/Hive.lua", "replace")
ModLoader.SetupFileHook("lua/Hive_Client.lua", "lua/CommunityBalanceMod/Hive_Client.lua", "replace")
ModLoader.SetupFileHook("lua/Hive_Server.lua", "lua/CommunityBalanceMod/Hive_Server.lua", "replace")
ModLoader.SetupFileHook("lua/Hydra.lua", "lua/CommunityBalanceMod/Hydra.lua", "replace")
ModLoader.SetupFileHook("lua/Hydra_Server.lua", "lua/CommunityBalanceMod/Hydra_Server.lua", "replace")
ModLoader.SetupFileHook("lua/Shade.lua", "lua/CommunityBalanceMod/Shade.lua", "replace")
ModLoader.SetupFileHook("lua/Shell.lua", "lua/CommunityBalanceMod/Shell.lua", "replace")
ModLoader.SetupFileHook("lua/Shift.lua", "lua/CommunityBalanceMod/Shift.lua", "replace")
ModLoader.SetupFileHook("lua/Spur.lua", "lua/CommunityBalanceMod/Spur.lua", "replace")
ModLoader.SetupFileHook("lua/Veil.lua", "lua/CommunityBalanceMod/Veil.lua", "replace")
ModLoader.SetupFileHook("lua/Whip.lua", "lua/CommunityBalanceMod/Whip.lua", "replace")
ModLoader.SetupFileHook("lua/Whip_Server.lua", "lua/CommunityBalanceMod/Whip_Server.lua", "replace")
ModLoader.SetupFileHook("lua/WhipBomb.lua", "lua/CommunityBalanceMod/WhipBomb.lua", "replace")
ModLoader.SetupFileHook("lua/TunnelEntrance.lua", "lua/CommunityBalanceMod/TunnelEntrance.lua", "replace")

-- Alien Units
ModLoader.SetupFileHook("lua/Drifter.lua", "lua/CommunityBalanceMod/Drifter.lua", "replace")
ModLoader.SetupFileHook("lua/DrifterEgg.lua", "lua/CommunityBalanceMod/DrifterEgg.lua", "replace")
ModLoader.SetupFileHook("lua/Egg.lua", "lua/CommunityBalanceMod/Egg.lua", "replace")
ModLoader.SetupFileHook("lua/Fade.lua", "lua/CommunityBalanceMod/Fade.lua", "replace")
ModLoader.SetupFileHook("lua/Lerk.lua", "lua/CommunityBalanceMod/Lerk.lua", "replace")
ModLoader.SetupFileHook("lua/Onos.lua", "lua/CommunityBalanceMod/Onos.lua", "replace")
ModLoader.SetupFileHook("lua/Onos_Client.lua", "lua/CommunityBalanceMod/Onos_Client.lua", "replace")
ModLoader.SetupFileHook("lua/Skulk.lua", "lua/CommunityBalanceMod/Skulk.lua", "replace")
ModLoader.SetupFileHook("lua/Gorge.lua", "lua/CommunityBalanceMod/Gorge.lua", "replace")