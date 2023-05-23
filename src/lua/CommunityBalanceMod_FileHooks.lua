g_communityBalanceModRevision = 1

-- Classes
-- Classes/Player
ModLoader.SetupFileHook("lua/Player_Client.lua", "lua/CommunityBalanceMod/Classes/Player/Player_Client.lua", "post")

-- CommAbilities
-- CommAbilities/Alien
ModLoader.SetupFileHook("lua/CommAbilities/Alien/CragUmbra.lua", "lua/CommunityBalanceMod/CommAbilities/Alien/CragUmbra.lua", "post")
ModLoader.SetupFileHook("lua/CommAbilities/Alien/EnzymeCloud.lua", "lua/CommunityBalanceMod/CommAbilities/Alien/EnzymeCloud.lua", "post")

-- Entities
-- Entities/Player
ModLoader.SetupFileHook("lua/PlayerInfoEntity.lua", "lua/CommunityBalanceMod/Entities/Player/PlayerInfoEntity.lua", "post")

-- Globals
ModLoader.SetupFileHook("lua/Balance.lua", "lua/CommunityBalanceMod/Globals/Balance.lua", "post")
ModLoader.SetupFileHook("lua/Globals.lua", "lua/CommunityBalanceMod/Globals/Globals.lua", "post")
ModLoader.SetupFileHook("lua/Render.lua", "lua/CommunityBalanceMod/Globals/Render.lua", "post")

-- GUI
ModLoader.SetupFileHook("lua/GUIUpgradeChamberDisplay.lua", "lua/CommunityBalanceMod/GUI/GUIUpgradeChamberDisplay.lua", "post")
ModLoader.SetupFileHook("lua/Alien_Client.lua", "lua/CommunityBalanceMod/GUI/Alien_Client.lua", "post")

-- Locale
ModLoader.SetupFileHook("lua/Locale.lua", "lua/CommunityBalanceMod/Locale/Locale.lua", "post")

-- Mixins
ModLoader.SetupFileHook("lua/FireMixin.lua", "lua/CommunityBalanceMod/Mixins/FireMixin.lua", "post")
ModLoader.SetupFileHook("lua/MucousableMixin.lua", "lua/CommunityBalanceMod/Mixins/MucousableMixin.lua", "post")
ModLoader.SetupFileHook("lua/UmbraMixin.lua", "lua/CommunityBalanceMod/Mixins/UmbraMixin.lua", "post")

-- NS2Utility
ModLoader.SetupFileHook("lua/Alien_Upgrade.lua", "lua/CommunityBalanceMod/NS2Utility/Alien_Upgrade.lua", "post")

-- Team
ModLoader.SetupFileHook("lua/AlienTeam.lua", "lua/CommunityBalanceMod/Teams/AlienTeam.lua", "post")

-- Tech
ModLoader.SetupFileHook("lua/AlienTechMap.lua", "lua/CommunityBalanceMod/Tech/AlienTechMap.lua", "post")
ModLoader.SetupFileHook("lua/TechData.lua", "lua/CommunityBalanceMod/Tech/TechData.lua", "post")
ModLoader.SetupFileHook("lua/TechTreeButtons.lua", "lua/CommunityBalanceMod/Tech/TechTreeButtons.lua", "post")
ModLoader.SetupFileHook("lua/TechTreeConstants.lua", "lua/CommunityBalanceMod/Tech/TechTreeConstants.lua", "post")

-- Weapons
-- Weapons/Alien
ModLoader.SetupFileHook("lua/AlienWeaponEffects.lua", "lua/CommunityBalanceMod/Weapons/Alien/AlienWeaponEffects.lua", "post")
ModLoader.SetupFileHook("lua/Weapons/Alien/Shockwave.lua", "lua/CommunityBalanceMod/Weapons/Alien/Shockwave.lua", "post")

-- Weapons/Marine
ModLoader.SetupFileHook("lua/Weapons/Marine/GasGrenade.lua", "lua/CommunityBalanceMod/Weapons/Marine/GasGrenade.lua", "post")
ModLoader.SetupFileHook("lua/Weapons/Marine/PulseGrenade.lua", "lua/CommunityBalanceMod/Weapons/Marine/PulseGrenade.lua", "post")
ModLoader.SetupFileHook("lua/Weapons/Marine/Railgun.lua", "lua/CommunityBalanceMod/Weapons/Marine/Railgun.lua", "post")
ModLoader.SetupFileHook("lua/Weapons/Marine/ClipWeapon.lua", "lua/CommunityBalanceMod/Weapons/Marine/ClipWeapon.lua", "post")
