ModLoader.SetupFileHook("lua/Server.lua", "lua/ModularExos/Server.lua", "post")
ModLoader.SetupFileHook("lua/Shared.lua", "lua/ModularExos/Shared.lua", "post")
-- TechTreeConstants and TechData is for ExoWelder ExoFlamer, ExoShield, WeaponCache, MarineStructureAbility
ModLoader.SetupFileHook("lua/TechTreeConstants.lua", "lua/ModularExos/TechTreeConstants.lua", "post")
ModLoader.SetupFileHook("lua/TechData.lua", "lua/ModularExos/TechData.lua", "post")
ModLoader.SetupFileHook("lua/Globals.lua", "lua/ModularExos/Globals.lua", "post")
ModLoader.SetupFileHook("lua/GUIInsight_PlayerHealthbars.lua", "lua/ModularExos/GUIInsight_PlayerHealthbars.lua", "post")
ModLoader.SetupFileHook("lua/Onos.lua", "lua/ModularExos/Onos.lua", "post")
ModLoader.SetupFileHook("lua/GUILeftRailgunDisplay.lua", "lua/ModularExos/GUILeftRailgunDisplay.lua", "post")
ModLoader.SetupFileHook("lua/GUIRightRailgunDisplay.lua", "lua/ModularExos/GUIRightRailgunDisplay.lua", "post")
ModLoader.SetupFileHook("lua/Weapons/Marine/Claw.lua", "lua/ModularExos/ExoWeapons/Claw.lua", "post")
-- realted to weaponcache - not in use
-- ModLoader.SetupFileHook("lua/NS2Utility.lua", "lua/ModularExos/NS2Utility.lua", "post")

ModLoader.SetupFileHook("lua/MarineTeam.lua", "lua/ModularExos/MarineTeam.lua", "post")
ModLoader.SetupFileHook("lua/Marine.lua", "lua/ModularExos/Marine.lua", "post")
-- NetworkMessages is called from Shared.lua
--ModLoader.SetupFileHook( "lua/NetworkMessages.lua", "lua/ModularExos/NetworkMessages.lua", "post" )

-- disable minigun balances
--ModLoader.SetupFileHook("lua/Weapons/Marine/Minigun.lua", "lua/ModularExos/ExoWeapons/Minigun.lua", "post")
ModLoader.SetupFileHook("lua/Weapons/Marine/Railgun.lua", "lua/ModularExos/ExoWeapons/Railgun.lua", "post")
-- ModLoader.SetupFileHook("lua/Sentry.lua", "lua/ModularExos/Sentry.lua", "post")

-- Weapon Overrides Marine and Alien
ModLoader.SetupFileHook("lua/Weapons/Marine/ExoWeaponHolder.lua", "lua/ModularExos/ExoWeapons/ExoWeaponHolder.lua", "post")
ModLoader.SetupFileHook("lua/Weapons/DotMarker.lua", "lua/ModularExos/ExoWeapons/DotMarker.lua", "post")

-- Exosuit relevant
ModLoader.SetupFileHook("lua/ReadyRoomExo.lua", "lua/ModularExos/ReadyRoomExo.lua", "post")
ModLoader.SetupFileHook("lua/Player_Client.lua", "lua/ModularExos/Player_Client.lua", "post")
ModLoader.SetupFileHook("lua/GUIExoThruster.lua", "lua/ModularExos/GUI/GUIExoThruster.lua", "post")
ModLoader.SetupFileHook("lua/ExoVariantMixin.lua", "lua/ModularExos/ExoVariantMixin.lua", "post")

-- MarineWeaponEffects is for welder/flamethrower
-- ModLoader.SetupFileHook("lua/MarineWeaponEffects.lua", "lua/ModularExos/MarineWeaponEffects.lua", "post")
ModLoader.SetupFileHook("lua/NanoShieldMixin.lua", "lua/ModularExos/NanoShieldMixin.lua", "post")
ModLoader.SetupFileHook("lua/CatPackMixin.lua", "lua/ModularExos/CatPackMixin.lua", "post")


-- Structure overrides
ModLoader.SetupFileHook("lua/PrototypeLab.lua", "lua/ModularExos/PrototypeLab.lua", "post")

-- Shield Related 
ModLoader.SetupFileHook("lua/PhysicsGroups.lua", "lua/ModularExos/PhysicsGroups.lua", "post")

--ModLoader.SetupFileHook( "lua/Weapons/Alien/Bomb.lua", "lua/ModularExos/ExoWeapons/Bomb.lua", "post" )
--ModLoader.SetupFileHook( "lua/Weapons/Marine/Grenade.lua", "lua/ModularExos/ExoWeapons/Grenade.lua", "post" )

-- Exos
ModLoader.SetupFileHook("lua/Exosuit.lua", "lua/ModularExos/Exosuit.lua", "post")
ModLoader.SetupFileHook("lua/Exo.lua", "lua/ModularExos/Exo.lua", "post")
ModLoader.SetupFileHook("lua/ModularJetpack/Exo.lua", "lua/ModularExos/Jetpack/Exo.lua", "post")

-- Other
ModLoader.SetupFileHook("lua/LiveMixin.lua", "lua/ModularExos/LiveMixin.lua", "post")

-- BUYMENU HELL
ModLoader.SetupFileHook("lua/GUIMarineBuyMenu.lua", "lua/ModularExos/GUI/GUIMarineBuyMenu.lua", "post")

--ModLoader.SetupFileHook("lua/ServerAdminCommands.lua", "lua/ModularExos/ServerAdminCommands.lua", "post")