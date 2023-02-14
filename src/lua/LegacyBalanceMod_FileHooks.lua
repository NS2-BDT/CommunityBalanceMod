g_legacyBalanceModRevision = 1
g_legacyBalanceModBeta = 0

-- Entities
-- Entities/Player
ModLoader.SetupFileHook("lua/PlayerInfoEntity.lua", "lua/LegacyBalanceMod/Entities/Player/PlayerInfoEntity.lua", "post")

-- Globals
ModLoader.SetupFileHook("lua/Balance.lua", "lua/LegacyBalanceMod/Globals/Balance.lua", "post")
ModLoader.SetupFileHook("lua/Globals.lua", "lua/LegacyBalanceMod/Globals/Globals.lua", "post")

-- GUI
ModLoader.SetupFileHook("lua/GUIUpgradeChamberDisplay.lua", "lua/LegacyBalanceMod/GUI/GUIUpgradeChamberDisplay.lua", "post")

-- Locale
ModLoader.SetupFileHook("lua/Locale.lua", "lua/LegacyBalanceMod/Locale/Locale.lua", "post")

-- Mixins
ModLoader.SetupFileHook("lua/FireMixin.lua", "lua/LegacyBalanceMod/Mixins/FireMixin.lua", "post")

-- NS2Utility
ModLoader.SetupFileHook("lua/Alien_Upgrade.lua", "lua/LegacyBalanceMod/NS2Utility/Alien_Upgrade.lua", "post")

-- Team
ModLoader.SetupFileHook("lua/AlienTeam.lua", "lua/LegacyBalanceMod/Teams/AlienTeam.lua", "post")

-- Tech
ModLoader.SetupFileHook("lua/AlienTechMap.lua", "lua/LegacyBalanceMod/Tech/AlienTechMap.lua", "post")
ModLoader.SetupFileHook("lua/TechData.lua", "lua/LegacyBalanceMod/Tech/TechData.lua", "post")
ModLoader.SetupFileHook("lua/TechTreeButtons.lua", "lua/LegacyBalanceMod/Tech/TechTreeButtons.lua", "post")
ModLoader.SetupFileHook("lua/TechTreeConstants.lua", "lua/LegacyBalanceMod/Tech/TechTreeConstants.lua", "post")

-- Weapons
-- Weapons/Alien
ModLoader.SetupFileHook("lua/Weapons/Alien/Shockwave.lua", "lua/LegacyBalanceMod/Weapons/Alien/Shockwave.lua", "post")

-- Weapons/Marine
ModLoader.SetupFileHook("lua/Weapons/Marine/PulseGrenade.lua", "lua/LegacyBalanceMod/Weapons/Marine/PulseGrenade.lua", "post")
ModLoader.SetupFileHook("lua/Weapons/Marine/Railgun.lua", "lua/LegacyBalanceMod/Weapons/Marine/Railgun.lua", "post")
