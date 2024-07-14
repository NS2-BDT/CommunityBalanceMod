Script.Load("lua/GUIMarineBuyMenu.lua")

--[[ (Z = lightning bolt icon, R = res icon)
                  0%|                                    80%-padding| |80%             |100% (Width)
    ╔═════════════╤═════════════════════════════════════════════════════════════════════╗ ─0%
    ║             │ ┌───────────────────────────────────────────────┐ ┌───────────────┐ ║ 
    ║ Jetpack     │ │ POWER MODULE                                  │ │     HEAVY     │ ║
    ║             │ │ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐  │ │               │ ║ 
    ╟─────────────┤ │ │ +20P │ │ +20P │ │ +20P │ │ +20P │ │ +20P │  │ │     20Z/      │ ║ 
    ║             │ │ │ -40R │ │ -40R │ │ -40R │ │ -40R │ │ -40R │  │ │       /40Z    │ ║ 
    ║  │Exo│      │ │ └──────┘ └──────┘ └──────┘ └──────┘ └──────┘  │ │               │ ║
    ║             │ └───────────────────────────────────────────────┘ └───────────────┘ ║ ─15%
    ╟─────────────┤ ┌───────────────┐                                 ┌───────────────┐ ║
    ║             │ │ RIGHT ARM     │                                 │ LEFT ARM      │ ║
    ║             │ │┌─────────────┐│                                 │┌─────────────┐│ ║
    ║             │ ││ CLAW        ││                                 ││ CLAW        ││ ║
    ║             │ ││ 10Z    (PIC)││                                 ││ 10Z    (PIC)││ ║
    ║             │ │└─────────────┘│                                 │└─────────────┘│ ║
    ║             │ │┌─────────────┐│                                 │┌─────────────┐│ ║
    ║             │ ││ WELDER      ││                                 ││ WELDER      ││ ║
    ║             │ ││ 10Z    (PIC)││                                 ││ 10Z    (PIC)││ ║
    ║             │ │└─────────────┘│             ( PIC )             │└─────────────┘│ ║
    ║             │ │┌─────────────┐│                                 │┌─────────────┐│ ║
    ║             │ ││ SHIELD      ││                                 ││ SHIELD      ││ ║
    ║             │ ││ 10Z    (PIC)││                                 ││ 10Z    (PIC)││ ║
    ║             │ │└─────────────┘│                                 │└─────────────┘│ ║
    ║             │ │┌─────────────┐│                                 │┌─────────────┐│ ║
    ║             │ ││ MINIGUN     ││                                 ││ MINIGUN     ││ ║
    ║             │ ││ 10Z    (PIC)││                                 ││ 10Z    (PIC)││ ║
    ║             │ │└─────────────┘│                                 │└─────────────┘│ ║
    ║             │ │┌─────────────┐│                                 │┌─────────────┐│ ║
    ║             │ ││ RAILGUN     ││                                 ││ RAILGUN     ││ ║
    ║             │ ││ 10Z    (PIC)││                                 ││ 10Z    (PIC)││ ║
    ║             │ │└─────────────┘│                                 │└─────────────┘│ ║
    ║             │ │┌─────────────┐│                                 │┌─────────────┐│ ║
    ║             │ ││ FLAMER      ││                                 ││ FLAMER      ││ ║
    ║             │ ││ 10Z    (PIC)││                                 ││ 10Z    (PIC)││ ║
    ║             │ │└─────────────┘│                                 │└─────────────┘│ ║
    ║             │ └───────────────┘                                 └───────────────┘ ║ ─15%+right/left arm panel height
    ║             │ ┌─────────────────────────────┐  ┌────────────────────────────────┐ ║ ─85%
    ║             │ │ ARMOR MODULE                │  │ UTILITY MODULE                 │ ║
    ║             │ │ ┌──────┐ ┌──────┐ ┌──────┐  │  │ ┌──────┐ ┌───────┐ ┌─────────┐ │ ║
    ║             │ │ │ +100 │ │ +100 │ │ +100 │  │  │ │ None │ │Scanner│ │Thrusters│ │ ║
    ║             │ │ │  10Z │ │  10Z │ │  10Z │  │  │ │      │ │  10Z  │ │  10Z    │ │ ║
    ║             │ │ └──────┘ └──────┘ └──────┘  │  │ └──────┘ └───────┘ └─────────┘ │ ║
    ║             │ └─────────────────────────────┘  └────────────────────────────────┘ ║ ─100% (Height-UpgradeButtonSize)
    ║             │                                                         ┌─────────┐ ║ 
    ║             │                                                    40R ─┤ UPGRADE │ ║
    ║             │                                                         └─────────┘ ║ ─
    ╚═════════════╧═════════════════════════════════════════════════════════════════════╝
                  0%|         0%+armor panel width|  |100%-utiltiy panel width         |100%
]]

GUIMarineBuyMenu.kWeightLabelData = {
    { min = 0.00, label = "LIGHT", col = Color(0, 1, 0, 1), },
    { min = 0.15, label = "MEDIUM", col = Color(1, 1, 0, 1), },
    { min = 0.30, label = "HEAVY", col = Color(1, 0, 0, 1), },
}

--local GetBigIconPixelCoords = GetLocal(GUIMarineBuyMenu._InitializeContent, "GetBigIconPixelCoords")
--local GetSmallIconPixelCoordinates = GetLocal(GUIMarineBuyMenu._InitializeEquipped, "GetSmallIconPixelCoordinates")

local gBigIconIndex, bigIconWidth, bigIconHeight = nil, 400, 300
local function GetBigIconPixelCoords(techId, researched)
    if not gBigIconIndex then
        gBigIconIndex = {}
        gBigIconIndex[kTechId.Axe] = 0
        gBigIconIndex[kTechId.Pistol] = 1
        gBigIconIndex[kTechId.Rifle] = 2
        gBigIconIndex[kTechId.Shotgun] = 3
        gBigIconIndex[kTechId.GrenadeLauncher] = 4
        gBigIconIndex[kTechId.Flamethrower] = 5
        gBigIconIndex[kTechId.Jetpack] = 6
        gBigIconIndex[kTechId.Exosuit] = 7
        gBigIconIndex[kTechId.Welder] = 8
        gBigIconIndex[kTechId.LayMines] = 9
        gBigIconIndex[kTechId.DualMinigunExosuit] = 10
        gBigIconIndex[kTechId.UpgradeToDualMinigun] = 10
        gBigIconIndex[kTechId.ClawRailgunExosuit] = 11
        gBigIconIndex[kTechId.DualRailgunExosuit] = 11
        gBigIconIndex[kTechId.UpgradeToDualRailgun] = 11
        
        gBigIconIndex[kTechId.ClusterGrenade] = 12
        gBigIconIndex[kTechId.GasGrenade] = 13
        gBigIconIndex[kTechId.PulseGrenade] = 14
    end
    local index = gBigIconIndex[techId] or 0
    local x1 = 0
    local x2 = bigIconWidth
    if not researched then
        x1 = bigIconWidth
        x2 = bigIconWidth * 2
    end
    local y1 = index * bigIconHeight
    local y2 = (index + 1) * bigIconHeight
    return x1, y1, x2, y2
end

local smallIconHeight = 64
local smallIconWidth = 128
local gSmallIconIndex = nil
local function GetSmallIconPixelCoordinates(itemTechId)
    if not gSmallIconIndex then
        gSmallIconIndex = {}
        
        gSmallIconIndex[kTechId.Claw] = 25
        
        gSmallIconIndex[kTechId.Axe] = 4
        gSmallIconIndex[kTechId.Pistol] = 3
        gSmallIconIndex[kTechId.Rifle] = 1
        gSmallIconIndex[kTechId.Shotgun] = 5
        gSmallIconIndex[kTechId.GrenadeLauncher] = 8
        gSmallIconIndex[kTechId.Flamethrower] = 6
        gSmallIconIndex[kTechId.Jetpack] = 24
        gSmallIconIndex[kTechId.Exosuit] = 26
        gSmallIconIndex[kTechId.Welder] = 10
        gSmallIconIndex[kTechId.LayMines] = 21
        gSmallIconIndex[kTechId.DualMinigunExosuit] = 26
        gSmallIconIndex[kTechId.UpgradeToDualMinigun] = 26
        gSmallIconIndex[kTechId.ClawRailgunExosuit] = 38
        gSmallIconIndex[kTechId.DualRailgunExosuit] = 38
        gSmallIconIndex[kTechId.UpgradeToDualRailgun] = 38
        
        gSmallIconIndex[kTechId.ClusterGrenade] = 42
        gSmallIconIndex[kTechId.GasGrenade] = 43
        gSmallIconIndex[kTechId.PulseGrenade] = 44
    
    end
    local index = gSmallIconIndex[itemTechId]
    if not index then
        index = 0
    end
    local y1 = index * smallIconHeight
    local y2 = (index + 1) * smallIconHeight
    return 0, y1, smallIconWidth, y2
end

local function GetBuildIconPixelCoords(techId)
    local iconX, iconY = GetMaterialXYOffset(techId)
    return iconX * 80, iconY * 80, iconX * 80 + 80, iconY * 80 + 80
end

GUIMarineBuyMenu.kExoModuleData = {
    
    -- Weapon modules
    [kExoModuleTypes.Claw]         = {
        label          = "Claw", tooltip = "EXO_WEAPON_CLAW_TOOLTIP",
        image          = kInventoryIconsTexture,
        imageTexCoords = { GetSmallIconPixelCoordinates(kTechId.Claw) },
    },
    --[kExoModuleTypes.Welder]       = {
    --    label          = "Welder", tooltip = "EXO_WEAPON_WELDER_TOOLTIP",
    --    image          = kInventoryIconsTexture,
    --    imageTexCoords = { GetSmallIconPixelCoordinates(kTechId.Welder) },
    --},
    --[kExoModuleTypes.Shield]       = {
    --    label          = "Shield", tooltip = "EXO_WEAPON_SHIELD_TOOLTIP",
    --    image          = kInventoryIconsTexture,
    --    imageTexCoords = { GetSmallIconPixelCoordinates(kTechId.PulseGrenade) },
    --},
    --[kExoModuleTypes.MarineStructureAbility] = {
    --    label = "Builder", tooltip = "EXO_WEAPON_SHIELD_TOOLTIP",
    --    image = kInventoryIconsTexture,
    --    imageTexCoords = {GetSmallIconPixelCoordinates(kTechId.Welder)},
    --},
    [kExoModuleTypes.Railgun]      = {
        label          = "Railgun", tooltip = "EXO_WEAPON_RAILGUN_TOOLTIP",
        image          = kInventoryIconsTexture,
        imageTexCoords = { GetSmallIconPixelCoordinates(kTechId.ClawRailgunExosuit) },
    },
	[kExoModuleTypes.PlasmaLauncher]      = {
        label          = "Plasma Launcher", tooltip = "EXO_WEAPON_RAILGUN_TOOLTIP",
        image          = kInventoryIconsTexture,
        imageTexCoords = { GetSmallIconPixelCoordinates(kTechId.ClawRailgunExosuit) },
    },
    [kExoModuleTypes.Minigun]      = {
        label          = "Minigun", tooltip = "EXO_WEAPON_MMINIGUN_TOOLTIP",
        image          = kInventoryIconsTexture,
        imageTexCoords = { GetSmallIconPixelCoordinates(kTechId.Exosuit) },
    },
    
    --[kExoModuleTypes.Flamethrower] = {
    --    label          = "Flamethrower", tooltip = "EXO_WEAPON_FLAMETHROWER_TOOLTIP",
    --    image          = kInventoryIconsTexture,
    --    imageTexCoords = { GetSmallIconPixelCoordinates(kTechId.Flamethrower) },
    --},
    
    -- Utility modules
    
    [kExoModuleTypes.Armor]        = {
        label          = "Armour", tooltip = "Extra armour at the cost of speed",
        image          = "ui/buildmenu.dds",
        imageTexCoords = { GetBuildIconPixelCoords(kTechId.Armor1) },
    },
    
    [kExoModuleTypes.Thrusters]    = {
        label          = "Thrusters", tooltip = "EXO_UTILITY_SCANNER_TOOLTIP",
        image          = "ui/buildmenu.dds",
        imageTexCoords = { GetBuildIconPixelCoords(kTechId.Jetpack) },
    },
	
    --[kExoModuleTypes.PhaseModule]  = {
    --    label          = "Phase", tooltip = "EXO_UTILITY_SCANNER_TOOLTIP",
    --    image          = "ui/buildmenu.dds",
    --    imageTexCoords = { GetBuildIconPixelCoords(kTechId.PhaseGate) },
    --},
	
    --[kExoModuleTypes.NanoShield]   = {
    --    label          = "Nano Shield", tooltip = "EXO_UTILITY_SCANNER_TOOLTIP",
    --    image          = "ui/buildmenu.dds",
    --    imageTexCoords = { GetBuildIconPixelCoords(kTechId.NanoShield) },
    --},
	
    [kExoModuleTypes.NanoRepair]   = {
        label          = "Nano Repair", tooltip = "EXO_UTILITY_SCANNER_TOOLTIP",
        image          = "ui/buildmenu.dds",
        imageTexCoords = { GetBuildIconPixelCoords(kTechId.Welder) },
    },
	
    --[kExoModuleTypes.CatPack]      = {
    --    label          = "Catpack", tooltip = "EXO_UTILITY_SCANNER_TOOLTIP",
    --    image          = "ui/buildmenu.dds",
    --    imageTexCoords = { GetBuildIconPixelCoords(kTechId.CatPack) },
    --},
    
    [kExoModuleTypes.None]         = {
        label          = "None", tooltip = "It appears to be a lot of nothing.",
        image          = "ui/buildmenu.dds",
        imageTexCoords = { GetBuildIconPixelCoords(kTechId.Stop) },
    },
    
}