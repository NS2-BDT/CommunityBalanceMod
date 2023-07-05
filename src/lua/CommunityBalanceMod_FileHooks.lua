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


-- Classes
-- Classes/Marine
ModLoader.SetupFileHook("lua/Marine.lua", "lua/CommunityBalanceMod/Classes/Marine/Marine.lua", "post")
-- Classes/Alien
ModLoader.SetupFileHook("lua/Lerk.lua", "lua/CommunityBalanceMod/Classes/Alien/Lerk.lua", "post")
ModLoader.SetupFileHook("lua/Babbler.lua", "lua/CommunityBalanceMod/Classes/Alien/Babbler.lua", "post")
ModLoader.SetupFileHook("lua/Alien.lua", "lua/CommunityBalanceMod/Classes/Alien/Alien.lua", "post") 

-- Classes/Player
ModLoader.SetupFileHook("lua/Player_Client.lua", "lua/CommunityBalanceMod/Classes/Player/Player_Client.lua", "post")
ModLoader.SetupFileHook("lua/Commander.lua", "lua/CommunityBalanceMod/Classes/Player/Commander.lua", "post") -- TODO share cooldown between clients

-- CommAbilities
-- CommAbilities/Alien
ModLoader.SetupFileHook("lua/CommAbilities/Alien/ShadeInk.lua", "lua/CommunityBalanceMod/CommAbilities/Alien/ShadeInk.lua", "post") 
ModLoader.SetupFileHook("lua/CommAbilities/Alien/HallucinationCloud.lua", "lua/CommunityBalanceMod/CommAbilities/Alien/HallucinationCloud.lua", "replace")

-- Entities
-- Entities/Player
ModLoader.SetupFileHook("lua/PlayerInfoEntity.lua", "lua/CommunityBalanceMod/Entities/Player/PlayerInfoEntity.lua", "post")

-- Globals
ModLoader.SetupFileHook("lua/Balance.lua", "lua/CommunityBalanceMod/Globals/Balance.lua", "post")
ModLoader.SetupFileHook("lua/Globals.lua", "lua/CommunityBalanceMod/Globals/Globals.lua", "post")
ModLoader.SetupFileHook("lua/Render.lua", "lua/CommunityBalanceMod/Globals/Render.lua", "post")

-- GUI
ModLoader.SetupFileHook("lua/GUIUpgradeChamberDisplay.lua", "lua/CommunityBalanceMod/GUI/GUIUpgradeChamberDisplay.lua", "post")
ModLoader.SetupFileHook("lua/GUIAlienBuyMenu.lua", "lua/CommunityBalanceMod/GUI/GUIAlienBuyMenu.lua", "post")
ModLoader.SetupFileHook("lua/GUIFeedback.lua", "lua/CommunityBalanceMod/GUI/GUIFeedback.lua", "post")
ModLoader.SetupFileHook("lua/Alien_Client.lua", "lua/CommunityBalanceMod/GUI/Alien_Client.lua", "post")

-- Locale
ModLoader.SetupFileHook("lua/Locale.lua", "lua/CommunityBalanceMod/Locale/Locale.lua", "post")

-- Mixins
ModLoader.SetupFileHook("lua/FireMixin.lua", "lua/CommunityBalanceMod/Mixins/FireMixin.lua", "post")
ModLoader.SetupFileHook("lua/PointGiverMixin.lua", "lua/CommunityBalanceMod/Mixins/PointGiverMixin.lua", "post")
ModLoader.SetupFileHook("lua/CloakableMixin.lua", "lua/CommunityBalanceMod/Mixins/CloakableMixin.lua", "post") 

-- NS2Utility
ModLoader.SetupFileHook("lua/Alien_Upgrade.lua", "lua/CommunityBalanceMod/NS2Utility/Alien_Upgrade.lua", "post")
ModLoader.SetupFileHook("lua/NS2Utility.lua", "lua/CommunityBalanceMod/NS2Utility/NS2Utility.lua", "post")

-- Team
ModLoader.SetupFileHook("lua/AlienTeam.lua", "lua/CommunityBalanceMod/Teams/AlienTeam.lua", "post")
ModLoader.SetupFileHook("lua/MarineTeam.lua", "lua/CommunityBalanceMod/Teams/MarineTeam.lua", "post")
ModLoader.SetupFileHook("lua/TeamInfo.lua", "lua/CommunityBalanceMod/Teams/TeamInfo.lua", "post")

-- Tech
ModLoader.SetupFileHook("lua/AlienTechMap.lua", "lua/CommunityBalanceMod/Tech/AlienTechMap.lua", "post")
ModLoader.SetupFileHook("lua/MarineTechMap.lua", "lua/CommunityBalanceMod/Tech/MarineTechMap.lua", "replace")
ModLoader.SetupFileHook("lua/GUITechMap.lua", "lua/CommunityBalanceMod/Tech/GUITechMap.lua", "replace") -- TODO use .debug for locals
ModLoader.SetupFileHook("lua/AlienUpgradeManager.lua", "lua/CommunityBalanceMod/Tech/AlienUpgradeManager.lua", "post")
ModLoader.SetupFileHook("lua/TechData.lua", "lua/CommunityBalanceMod/Tech/TechData.lua", "post")
ModLoader.SetupFileHook("lua/TechTreeButtons.lua", "lua/CommunityBalanceMod/Tech/TechTreeButtons.lua", "post")
ModLoader.SetupFileHook("lua/TechTreeConstants.lua", "lua/CommunityBalanceMod/Tech/TechTreeConstants.lua", "post")
ModLoader.SetupFileHook("lua/TechTree.lua", "lua/CommunityBalanceMod/Tech/TechTree.lua", "post")


-- Weapons
-- Weapons/Alien
ModLoader.SetupFileHook("lua/AlienWeaponEffects.lua", "lua/CommunityBalanceMod/Weapons/Alien/AlienWeaponEffects.lua", "post")
ModLoader.SetupFileHook("lua/Weapons/Alien/Shockwave.lua", "lua/CommunityBalanceMod/Weapons/Alien/Shockwave.lua", "post")

-- Weapons/Marine
ModLoader.SetupFileHook("lua/Weapons/Marine/Railgun.lua", "lua/CommunityBalanceMod/Weapons/Marine/Railgun.lua", "post")
ModLoader.SetupFileHook("lua/Mine.lua", "lua/CommunityBalanceMod/Weapons/Marine/Mine.lua", "post")

-- Structures
ModLoader.SetupFileHook("lua/ArmsLab.lua", "lua/CommunityBalanceMod/Structures/ArmsLab.lua", "post") 
ModLoader.SetupFileHook("lua/PrototypeLab.lua", "lua/CommunityBalanceMod/Structures/PrototypeLab.lua", "post")
ModLoader.SetupFileHook("lua/PrototypeLab_Server.lua", "lua/CommunityBalanceMod/Structures/PrototypeLab_Server.lua", "post")

-- Damage
ModLoader.SetupFileHook("lua/DamageTypes.lua", "lua/CommunityBalanceMod/Damage/DamageTypes.lua", "replace") -- TODO use .debug for locals






