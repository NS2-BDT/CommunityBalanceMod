g_legacyBalanceModRevision = 1
g_legacyBalanceModBeta = 0

-- Globals
ModLoader.SetupFileHook("lua/Balance.lua", "lua/LegacyBalanceMod/Globals/Balance.lua", "post")

-- Weapons
-- Weapons/Marine
ModLoader.SetupFileHook("lua/Weapons/Marine/Railgun.lua", "lua/LegacyBalanceMod/Weapons/Marine/Railgun.lua", "post")
