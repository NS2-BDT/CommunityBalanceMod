-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\GUIMarineBuyMenu.lua
--
-- Created by: Andreas Urwalek (andi@unknownworlds.com)
--
-- Manages the marine buy/purchase menu.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIAnimatedScript.lua")

class 'GUIMarineBuyMenu' (GUIAnimatedScript)

GUIMarineBuyMenu.kMockupSize = Vector(2880, 1620, 0)

local kArmoryBackgroundTexture         = PrecacheAsset("ui/buymenu_marine/armory_background.dds")
local kPrototypeLabBackgroundTexture   = PrecacheAsset("ui/buymenu_marine/prototypelab_background.dds")

local kButtonGroupFrame_Unlabeled_x2   = PrecacheAsset("ui/buymenu_marine/button_group_frame_unlabeled_x2.dds")
local kButtonGroupFrame_Labeled_x3     = PrecacheAsset("ui/buymenu_marine/button_group_frame_labeled_x3.dds")
local kButtonGroupFrame_Labeled_x4     = PrecacheAsset("ui/buymenu_marine/button_group_frame_labeled_x4.dds")
local kButtonGroupFrame_Labeled_x5     = PrecacheAsset("ui/buymenu_marine/button_group_frame_labeled_x5.dds")

local kButtonsTexture                  = PrecacheAsset("ui/buymenu_marine/buttons.dds")
local kButtonErrorFrame                = PrecacheAsset("ui/buymenu_marine/button_errorframe.dds")
local kButtonHighlightTexture          = PrecacheAsset("ui/buymenu_marine/button_highlight.dds")

local kResourceIcon_Lit                = PrecacheAsset("ui/buymenu_marine/resource_icon_lit.dds")
local kResourceIcon_Unlit              = PrecacheAsset("ui/buymenu_marine/resource_icon_unlit.dds")

local kWeaponButtonResIconTexture_Lit  = PrecacheAsset("ui/buymenu_marine/resource_lit.dds")
local kWeaponButtonTeamIconTexture     = PrecacheAsset("ui/buymenu_marine/team_icon.dds")

-- Right side "details" section textures.
local kResourceBigTexture_Unlit        = PrecacheAsset("ui/buymenu_marine/resourcebig_unlit.dds")
local kResourceBigTexture_Lit          = PrecacheAsset("ui/buymenu_marine/resourcebig_lit.dds")
local kArmoryBigPicturesTexture        = PrecacheAsset("ui/buymenu_marine/armory_bigicons.dds")
local kPrototypeLabBigPicturesTexture  = PrecacheAsset("ui/buymenu_marine/prototypelab_bigicons.dds")
local kSpecialsTexture                 = PrecacheAsset("ui/buymenu_marine/special_frames.dds")
local kVSBarTexture                    = PrecacheAsset("ui/buymenu_marine/stat_bar.dds")

GUIMarineBuyMenu.kCostTextColor_Free             = Color(97/255,  97/255, 97/255)
GUIMarineBuyMenu.kCostTextColor_HasEnoughMoney   = Color(1,       1,      1)
GUIMarineBuyMenu.kCostTextColor_NotEnoughMoney   = Color(174/255, 51/255, 51/255)

GUIMarineBuyMenu.kTeamTextColor_None             = Color(97/255,  97/255,  97/255)
GUIMarineBuyMenu.kTeamTextColor_HasPlayers       = Color(109/255, 158/255, 167/255)
GUIMarineBuyMenu.kSpecialTextContentColor        = Color(162/255, 195/255, 200/255)
GUIMarineBuyMenu.kSpecialTextContentColor_Debuff = Color(239/255, 94/255,  80/255)

GUIMarineBuyMenu.kErrorFrameTextPadding          = 10 -- X, both sides

local kButtonShowState = enum({
    'Uninitialized',
    'NotHosted',
    'Occupied',
    'Equipped',
    'Unresearched',
    'InsufficientFunds',
    'Available',
    'Disabled', -- Tutorial should block 'Axe' purchasing, for example. Override 'GUIMarineBuyMenu:GetTechIDDisabled(techID)' for this.
})

local kButtonShowStateDefinitions =
{
    [kButtonShowState.Disabled] = {
        ShowError = true,
        Text = "BUYMENU_ERROR_DISABLED",
        TextColor = Color(239/255, 94/255, 80/255)
    },

    [kButtonShowState.NotHosted] = {
        ShowError = true,
        Text = "BUYMENU_ERROR_UNAVAILABLE",
        TextColor = Color(94/255, 116/255, 128/255)
    },

    [kButtonShowState.Occupied] = {
        ShowError = true,
        Text = "BUYMENU_ERROR_OCCUPIED",
        TextColor = Color(94/255, 116/255, 128/255)
    },

    [kButtonShowState.Equipped] = {
        ShowError = true,
        Text = "BUYMENU_ERROR_EQUIPPED",
        TextColor = Color(2/255, 230/255, 255/255)
    },

    [kButtonShowState.Unresearched] = {
        ShowError = true,
        Text = "BUYMENU_ERROR_NOTRESEARCHED",
        TextColor = Color(94/255, 116/255, 128/255)
    },

    [kButtonShowState.InsufficientFunds] = {
        ShowError = true,
        Text = "BUYMENU_ERROR_INSUFFICIENTFUNDS",
        TextColor = Color(239/255, 94/255, 80/255)
    },

    [kButtonShowState.Available] = {
        ShowError = false,
    },
}

-- Table of unscaled button positions, for each of the weapon group frames.
local kWeaponGroupButtonPositions =
{

    [kButtonGroupFrame_Unlabeled_x2] =
    {
        Vector(4, 4, 0),
        Vector(4, 122, 0),
    },

    [kButtonGroupFrame_Labeled_x3] =
    {
        Vector(4, 20, 0),
        Vector(4, 140, 0),
        Vector(4, 258, 0),
    },

    [kButtonGroupFrame_Labeled_x4] =
    {
        Vector(4, 25, 0),
        Vector(4, 143, 0),
        Vector(4, 262, 0),
        Vector(4, 380, 0),
    },
	
	[kButtonGroupFrame_Labeled_x5] =
    {
        Vector(4, 25, 0),
        Vector(4, 143, 0),
        Vector(4, 262, 0),
        Vector(4, 380, 0),
		Vector(4, 498, 0),
    },

}

local kSpecial = enum(
{
    'Massive',
    'Electrify',
    'Burn'
})

local kSpecialDefinitions =
{
    [kSpecial.Massive] =
    {
        TextureCoordinates = { 0, 0, 717, 184 },
        Title = "BUYMENU_MASSIVE_TITLE",
        Specials =
        {
            "BUYMENU_MASSIVE_SPECIAL1",
            "BUYMENU_MASSIVE_SPECIAL2",
            "BUYMENU_MASSIVE_SPECIAL3",
            "BUYMENU_MASSIVE_SPECIAL4",
            "BUYMENU_MASSIVE_SPECIAL5",
        },
        SpecialsDebuffs = set
        {
            4, 5
        }
    },

    [kSpecial.Electrify] =
    {
        TextureCoordinates = { 0, 185, 717, 279 },
        Title = "BUYMENU_ELECTRIFY_TITLE",
        Specials =
        {
            "BUYMENU_ELECTRIFY_SPECIAL1",
        }
    },

    [kSpecial.Burn] =
    {
        TextureCoordinates = { 0, 370, 717, 464 },
        Title = "BUYMENU_BURN_TITLE",
        Specials =
        {
            "BUYMENU_BURN_SPECIAL1",
            "BUYMENU_BURN_SPECIAL2",
        }
    }
}

local kTechIdStats =
{
    [kTechId.Axe] =
    {
        LifeFormDamage = 0.1,
        StructureDamage = 0.7,
        Range = 0.1,
    },

    [kTechId.Welder] =
    {
        LifeFormDamage = 0.1,
        StructureDamage = 0.2,
        Range = 0.1,
    },

    [kTechId.Pistol] =
    {
        LifeFormDamage = 0.8,
        StructureDamage = 0.5,
        Range = 1,
    },

    [kTechId.Rifle] =
    {
        LifeFormDamage = 0.8,
        StructureDamage = 0.8,
        Range = 0.8,
    },

    [kTechId.Shotgun] =
    {
        LifeFormDamage = 1,
        StructureDamage = 0.8,
        Range = 0.4,
    },

    [kTechId.GrenadeLauncher] =
    {
        LifeFormDamage = 0.3,
        StructureDamage = 1,
        Range = 0.9,
    },

    [kTechId.HeavyMachineGun] =
    {
        LifeFormDamage = 1,
        StructureDamage = 0.6,
        Range = 0.7,
    },

    [kTechId.Flamethrower] =
    {
        LifeFormDamage = 0.6,
        StructureDamage = 1,
        Range = 0.4,
    },

    [kTechId.GasGrenade] =
    {
        LifeFormDamage = 0.4,
        StructureDamage = 0.6,
        Range = 0.7,
        RangeLabelOverride = "BUYMENU_GRENADES_RANGE_OVERRIDE",
    },

    [kTechId.ClusterGrenade] =
    {
        LifeFormDamage = 0.2,
        StructureDamage = 0.8,
        Range = 0.6,
        RangeLabelOverride = "BUYMENU_GRENADES_RANGE_OVERRIDE",
    },

    [kTechId.PulseGrenade] =
    {
        LifeFormDamage = 0.5,
        StructureDamage = 0.1,
        Range = 0.4,
        RangeLabelOverride = "BUYMENU_GRENADES_RANGE_OVERRIDE",
    },

    [kTechId.DualMinigunExosuit] =
    {
        LifeFormDamage = 0.9,
        StructureDamage = 0.8,
        Range = 0.7,
    },

    -- Prototype Lab "big" pictures are a seperate texture file.
    [kTechId.DualRailgunExosuit] =
    {
        LifeFormDamage = 1,
        StructureDamage = 0.6,
        Range = 1,
    },
	
    [kTechId.Submachinegun] =
    {
        LifeFormDamage = 0.7,
        StructureDamage = 0.5,
        Range = 0.7,
    },	
}

local function GetStatsForTechId(techId)


    local stats = kTechIdStats[techId]
    if stats then
        return stats
    end

    return nil

end

local kTechIdInfo =
{
    [kTechId.Pistol] =
    {
        ButtonTextureIndex = 0,
        BigPictureIndex = 0,
        Description = "PISTOL_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.Pistol)
    },

    [kTechId.Rifle] =
    {
        ButtonTextureIndex = 1,
        BigPictureIndex = 1,
        Description = "RIFLE_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.Rifle)
    },

    [kTechId.Shotgun] =
    {
        ButtonTextureIndex = 2,
        BigPictureIndex = 2,
        Description = "SHOTGUN_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.Shotgun)
    },

    [kTechId.GrenadeLauncher] =
    {
        ButtonTextureIndex = 3,
        BigPictureIndex = 3,
        Description = "GRENADELAUNCHER_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.GrenadeLauncher)
    },

    [kTechId.Flamethrower] =
    {
        ButtonTextureIndex = 4,
        BigPictureIndex = 4,
        Description = "FLAMETHROWER_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.Flamethrower),
        Special = kSpecial.Burn
    },

    [kTechId.HeavyMachineGun] =
    {
        ButtonTextureIndex = 5,
        BigPictureIndex = 5,
        Description = "HMG_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.HeavyMachineGun)
    },

    [kTechId.Axe] =
    {
        ButtonTextureIndex = 6,
        BigPictureIndex = 6,
        Description = "AXE_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.Axe)
    },

    [kTechId.Welder] =
    {
        ButtonTextureIndex = 7,
        BigPictureIndex = 7,
        Description = "WELDER_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.Welder)
    },

    [kTechId.GasGrenade] =
    {
        ButtonTextureIndex = 8,
        BigPictureIndex = 8,
        Description = "GASGRENADE_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.GasGrenade)
    },

    [kTechId.ClusterGrenade] =
    {
        ButtonTextureIndex = 9,
        BigPictureIndex = 9,
        Description = "CLUSTERGRENADE_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.ClusterGrenade)
    },

    [kTechId.PulseGrenade] =
    {
        ButtonTextureIndex = 10,
        BigPictureIndex = 10,
        Description = "PULSEGRENADE_BUYDESCRIPTION",
        Special = kSpecial.Electrify,
        Stats = GetStatsForTechId(kTechId.PulseGrenade)
    },

    [kTechId.LayMines] =
    {
        ButtonTextureIndex = 11,
        BigPictureIndex = 11,
        Description = "MINES_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.LayMines)
    },

    [kTechId.Submachinegun] =
    {
        ButtonTextureIndex = 17,
        BigPictureIndex = 14,
        Description = "SMG_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.Submachinegun)
    },

    -- Prototype Lab "big" pictures are a seperate texture file.
    [kTechId.Jetpack] =
    {
        ButtonTextureIndex = 12,
        BigPictureIndex = 2,
        Description = "JETPACK_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.Jetpack)
    },

    [kTechId.DualRailgunExosuit] =
    {
        ButtonTextureIndex = 13,
        BigPictureIndex = 1,
        Description = "DUALRAILGUN_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.DualRailgunExosuit),
        Special = kSpecial.Massive
    },

    [kTechId.DualMinigunExosuit] =
    {
        ButtonTextureIndex = 14,
        BigPictureIndex = 0,
        Description = "DUALMINIGUN_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.DualMinigunExosuit),
        Special = kSpecial.Massive
    },
}

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
        gBigIconIndex[kTechId.Submachinegun] = 17
		
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
        gSmallIconIndex[kTechId.Flamethrower] = 10 -- 6
        gSmallIconIndex[kTechId.Jetpack] = 24
        gSmallIconIndex[kTechId.Exosuit] = 26
        gSmallIconIndex[kTechId.Welder] = 10
        gSmallIconIndex[kTechId.LayMines] = 21
        gSmallIconIndex[kTechId.DualMinigunExosuit] = 26
        gSmallIconIndex[kTechId.UpgradeToDualMinigun] = 26
        gSmallIconIndex[kTechId.ClawRailgunExosuit] = 38
        gSmallIconIndex[kTechId.DualRailgunExosuit] = 38
        gSmallIconIndex[kTechId.UpgradeToDualRailgun] = 38
		gSmallIconIndex[kTechId.Submachinegun] = 17
        
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
    [kExoModuleTypes.Flamethrower] = {
        label          = "Blowtorch", tooltip = "EXO_WEAPON_FLAMETHROWER_TOOLTIP",
        image          = kInventoryIconsTexture,
        imageTexCoords = { GetSmallIconPixelCoordinates(kTechId.Flamethrower) },
    },
    
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

function GUIMarineBuyMenu:_GetPigPicturePixelCoordinatesForTechID(techId)

    -- NOTE(Salads): The texture file for purchase buttons have a column for "not hovered", and another for "hovered"

    local pictureWidth = 651 -- armory dimensions
    local pictureHeight = 319
    if self.hostStructure:isa("PrototypeLab") then
        pictureWidth = 403
        pictureHeight = 424
    end

    local index = kTechIdInfo[techId].BigPictureIndex
    assert(index, "Could not find index for techid")

    local x1 = 0
    local x2 = x1 + pictureWidth

    local y1 = pictureHeight * index
    local y2 = y1 + pictureHeight

    return { x1, y1, x2, y2 }

end

function GUIMarineBuyMenu:_GetButtonPixelCoordinatesForTechID(techId, isHover)

    -- NOTE(Salads): The texture file for purchase buttons have a column for "not hovered", and another for "hovered"

    local buttonIconWidth = 441
    local buttonIconHeight = 114
    local hoverAdd = isHover and buttonIconWidth or 0
    local index = kTechIdInfo[techId].ButtonTextureIndex
    assert(index, "Could not find index for techid")

    local x1 = hoverAdd
    local x2 = x1 + buttonIconWidth

    local y1 = buttonIconHeight * index
    local y2 = y1 + buttonIconHeight

    return { x1, y1, x2, y2 }

end

local function Desaturate(color, desaturateBy)

    local hue, sat, val = RGBToHSV(color)
    sat = sat - desaturateBy
    local result = HSVToRGB(hue, sat, val)

    return result
end

function GUIMarineBuyMenu:_UpdateSpecialSection(specialDefinition)

    local specialTextureCoords = specialDefinition.TextureCoordinates
    local specialTitle = specialDefinition.Title
    self.specialFrame:SetTexturePixelCoordinates(GUIUnpackCoords(specialTextureCoords))
    self.specialFrame:SetSize(GUIGetSizeFromCoords(specialTextureCoords))
    self.specialTitle:SetText(string.format("%s%s", Locale.ResolveString("BUYMENU_TITLE_PREFIX"), Locale.ResolveString(specialTitle)))

    local specialTextPadding = 30
    local startPos = self.specialTitle:GetPosition()
    local xPos = startPos.x
    local yPos = startPos.y + 35

    local specials = specialDefinition.Specials
    local numSpecials = #specials
    for i, specialText in ipairs(self.specialTexts) do

        if i <= numSpecials then
            specialText:SetText(Locale.ResolveString(specials[i]))

            local debuffIndicies = specialDefinition.SpecialsDebuffs
            if debuffIndicies and debuffIndicies[i] then
                specialText:SetColor(self.kSpecialTextContentColor_Debuff)
            else
                specialText:SetColor(self.kSpecialTextContentColor)
            end

        else
            specialText:SetText("")
        end

        specialText:SetPosition(Vector(xPos, yPos, 0))
        yPos = yPos + specialTextPadding

    end

end

function GUIMarineBuyMenu:_UpdateStatBar(barItem, stat)

    local statFullWidth = self.rangeBar:GetTextureWidth()
    local statFullHeight = self.rangeBar:GetTextureHeight()
    local statWidth = stat * statFullWidth
    local desaturateBy = 0.35
    local statColor
    if stat <= 0.5 then

        statColor = LerpColor(Desaturate(Color(1,0,0), desaturateBy), Desaturate(Color(1,1,0), desaturateBy), stat / 0.5)
    else
        statColor = LerpColor(Desaturate(Color(1,1,0), desaturateBy), Desaturate(Color(0,1,0), desaturateBy), (stat - 0.5) / 0.5)
    end

    barItem:SetSize(Vector(statWidth, statFullHeight, 0))
    barItem:SetTexturePixelCoordinates(0, 0, statWidth, statFullHeight)
    barItem:SetColor(statColor)

end

function GUIMarineBuyMenu:GetTechIDDisabled(techID)
    return false
end

function GUIMarineBuyMenu:_CreateButton(parent, buttonPosition, buttonTechId)

    local iconpaddingX = 18
    local iconPaddingY = 2
    local iconOffsetY = 3
    local buttonPixelCoordinates = self:_GetButtonPixelCoordinatesForTechID(buttonTechId, false)

    local buyButton = self:CreateAnimatedGraphicItem()
    buyButton:SetIsScaling(false)
    buyButton:AddAsChildTo(parent)
    buyButton:SetPosition(buttonPosition)
    buyButton:SetTexture(kButtonsTexture)
    buyButton:SetTexturePixelCoordinates(GUIUnpackCoords(buttonPixelCoordinates))
    buyButton:SetSize(GUIGetSizeFromCoords(buttonPixelCoordinates))
    buyButton:SetOptionFlag(GUIItem.CorrectScaling)

    local techCost = LookupTechData(buttonTechId, kTechDataCostKey, nil)
    local costHasPrice = false
    local costString
    if techCost then
        costString = string.format("%d", techCost)
        costHasPrice = techCost > 0
    else
        costString = "error"
    end

    local costIconGlowSize = 18 -- Space in the actual texture that's just glow
    local costIconSize = 30 + costIconGlowSize

    local costIcon = self:CreateAnimatedGraphicItem()
    costIcon:SetIsScaling(false)
    costIcon:AddAsChildTo(buyButton)
    costIcon:SetAnchor(GUIItem.Left, GUIItem.Center)
    costIcon:SetTexture(kResourceIcon_Lit)
    costIcon:SetSize(Vector(costIconSize, costIconSize, 0))
    costIcon:SetPosition(Vector(iconpaddingX - 9, -costIcon:GetSize().y - iconPaddingY - iconOffsetY + 9, 0))
    costIcon:SetOptionFlag(GUIItem.CorrectScaling)

    local kButtonNumberFontSize = 30

    local costText = self:CreateAnimatedTextItem()
    costText:SetIsScaling(false)
    costText:AddAsChildTo(costIcon)
    costText:SetPosition(Vector(-4, 0, 0))
    costText:SetAnchor(GUIItem.Right, GUIItem.Center)
    costText:SetTextAlignmentX(GUIItem.Align_Min)
    costText:SetTextAlignmentY(GUIItem.Align_Center)
    costText:SetText(costString)
    costText:SetOptionFlag(GUIItem.CorrectScaling)
    GUIMakeFontScale(costText, "kAgencyFB", kButtonNumberFontSize)

    local teamIcon = self:CreateAnimatedGraphicItem()
    teamIcon:SetIsScaling(false)
    teamIcon:AddAsChildTo(buyButton)
    teamIcon:SetAnchor(GUIItem.Left, GUIItem.Center)
    teamIcon:SetTexture(kWeaponButtonTeamIconTexture)
    teamIcon:SetSizeFromTexture()
    teamIcon:SetPosition(Vector(iconpaddingX, iconPaddingY - iconOffsetY, 0))
    teamIcon:SetOptionFlag(GUIItem.CorrectScaling)

    local teamText = self:CreateAnimatedTextItem()
    teamText:SetIsScaling(false)
    teamText:AddAsChildTo(teamIcon)
    teamText:SetPosition(Vector(teamIcon:GetSize().x + 4, 2, 0))
    teamText:SetAnchor(GUIItem.Left, GUIItem.Center)
    teamText:SetTextAlignmentX(GUIItem.Align_Min)
    teamText:SetTextAlignmentY(GUIItem.Align_Center)
    teamText:SetFontName(Fonts.kAgencyFB_Tiny)
    teamText:SetOptionFlag(GUIItem.CorrectScaling)
    GUIMakeFontScale(teamText, "kAgencyFB", kButtonNumberFontSize)

    -- y = 7, x: 0
    local errorFrame = self:CreateAnimatedGraphicItem()
    errorFrame:SetIsScaling(false)
    errorFrame:AddAsChildTo(buyButton)
    errorFrame:SetOptionFlag(GUIItem.CorrectScaling)
    errorFrame:SetPosition(Vector(0, 7, 0))
    errorFrame:SetTexture(kButtonErrorFrame)
    errorFrame:SetSizeFromTexture()

    local errorText = self:CreateAnimatedTextItem()
    errorText:SetIsScaling(false)
    errorText:AddAsChildTo(errorFrame)
    errorText:SetPosition(Vector(self.kErrorFrameTextPadding, 0, 0))
    errorText:SetAnchor(GUIItem.Left, GUIItem.Center)
    errorText:SetTextAlignmentX(GUIItem.Align_Min)
    errorText:SetTextAlignmentY(GUIItem.Align_Center)
    errorText:SetFontName(Fonts.kAgencyFB_Tiny)
    errorText:SetOptionFlag(GUIItem.CorrectScaling)
    GUIMakeFontScale(errorText, "kAgencyFBBold", 33)

    return
    {
        TechID = buttonTechId,
        Button = buyButton,
        ErrorFrame = errorFrame,
        ErrorTextItem = errorText,
        Hosted = false,
        WeaponGroup = parent,
        TeamText = teamText,
        CostText = costText,
        Initialized = false,
        LastShowState = kButtonShowState.Uninitialized,
        Disabled = self:GetTechIDDisabled(buttonTechId)
    }

end

function GUIMarineBuyMenu:_InitializeWeaponGroup(groupItem, buttonPositions, purchasableTechIds)

    assert(groupItem)
    assert(type(buttonPositions) == "table")
    assert(type(purchasableTechIds) == "table")
    assert(#buttonPositions >= #purchasableTechIds, "Not enough button positions for purchasable tech ids!")

    for i = 1, #purchasableTechIds do

        local techId = purchasableTechIds[i]
        local buttonPos = buttonPositions[i]

        local buttonTable = self:_CreateButton(groupItem, buttonPos, techId)
        table.insert(self.buyButtons, buttonTable)

    end

end

function GUIMarineBuyMenu:SetHostStructure(hostStructure)

    assert(hostStructure)

    self.hostStructure = hostStructure

    if self.hostStructure:isa("Armory") then
        self:CreateArmoryUI()
    elseif self.hostStructure:isa("PrototypeLab") then
        self:CreatePrototypeLabUI()
    else
        Log(string.format("ERROR: No generator found for class: %s", self.hostStructure:GetClassName()))
    end
	
    if hostStructure:isa("PrototypeLab") then
        self:_InitializeExoModularButtons()
        self:_RefreshExoModularButtons()
    end	
end

function GUIMarineBuyMenu:CreatePrototypeLabUI()
    
    self.defaultTechId = kTechId.Jetpack
    
    self.background = self:CreateAnimatedGraphicItem()
    self.background:SetTexture(kPrototypeLabBackgroundTexture)
    self.background:SetSizeFromTexture()
    self.background:SetIsScaling(false)
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.background:SetHotSpot(Vector(0.5, 0.5, 0))
    self.background:SetScale(self.customScaleVector)
    self.background:SetOptionFlag(GUIItem.CorrectScaling)
    self.background:SetLayer(kGUILayerMarineBuyMenu)
    
    local buttonGroupX = 97
    local buttonGroupY = 149
    
    local buttonPositions = kWeaponGroupButtonPositions[kButtonGroupFrame_Unlabeled_x2]
    
    local buttonGroup = self:CreateAnimatedGraphicItem()
    buttonGroup:AddAsChildTo(self.background)
    buttonGroup:SetIsScaling(false)
    buttonGroup:SetPosition(Vector(buttonGroupX, buttonGroupY, 0))
    buttonGroup:SetTexture(kButtonGroupFrame_Unlabeled_x2)
    buttonGroup:SetSizeFromTexture()
    buttonGroup:SetOptionFlag(GUIItem.CorrectScaling)
    
    self:_InitializeWeaponGroup(buttonGroup, buttonPositions,
                                {
                                    kTechId.Jetpack,
                                    kTechId.DualMinigunExosuit,
                                })

    local rightSideStartPos = Vector(580, 38, 0)
    self:_CreateRightSide(rightSideStartPos)

end

function GUIMarineBuyMenu:CreateArmoryUI()

    local paddingX = 105 -- Start of content from left side of background.
    local paddingY = 36
    -- 449
    local paddingXWeaponGroups = 29
    -- 449
    local paddingYWeaponGroups = 6
    local paddingXWeaponGroupsToRightSide = 36 -- 724 after this till end. (not including end cap)

    self.defaultTechId = kTechId.Rifle

    self.background = self:CreateAnimatedGraphicItem()
    self.background:SetTexture(kArmoryBackgroundTexture)
    self.background:SetSizeFromTexture()
    self.background:SetIsScaling(false)
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.background:SetHotSpot(Vector(0.5, 0.5, 0))
    self.background:SetScale(self.customScaleVector)
    self.background:SetOptionFlag(GUIItem.CorrectScaling)
    self.background:SetLayer(kGUILayerMarineBuyMenu)

    local x2ButtonPositions = kWeaponGroupButtonPositions[kButtonGroupFrame_Unlabeled_x2]
    local x4ButtonPositions = kWeaponGroupButtonPositions[kButtonGroupFrame_Labeled_x4]
	local x5ButtonPositions = kWeaponGroupButtonPositions[kButtonGroupFrame_Labeled_x5]

    local weaponGroupTopLeft = self:CreateAnimatedGraphicItem()
    weaponGroupTopLeft:SetIsScaling(false)
    weaponGroupTopLeft:SetPosition(Vector(paddingX, paddingY, 0))
    weaponGroupTopLeft:SetTexture(kButtonGroupFrame_Unlabeled_x2)
    weaponGroupTopLeft:SetSizeFromTexture()
    weaponGroupTopLeft:SetOptionFlag(GUIItem.CorrectScaling)
    self.background:AddChild(weaponGroupTopLeft)
    self:_InitializeWeaponGroup(weaponGroupTopLeft, x2ButtonPositions,
    {
        kTechId.Pistol,
        kTechId.Rifle,
    })

    local weaponGroupBottomLeft = self:CreateAnimatedGraphicItem()
    weaponGroupBottomLeft:SetIsScaling(false)
    weaponGroupBottomLeft:SetPosition(Vector(paddingX, weaponGroupTopLeft:GetPosition().y + weaponGroupTopLeft:GetSize().y + paddingYWeaponGroups, 0))
    weaponGroupBottomLeft:SetTexture(kButtonGroupFrame_Labeled_x5)
    weaponGroupBottomLeft:SetSizeFromTexture()
    weaponGroupBottomLeft:SetOptionFlag(GUIItem.CorrectScaling)
    self.background:AddChild(weaponGroupBottomLeft)
    self:_InitializeWeaponGroup(weaponGroupBottomLeft, x5ButtonPositions,
    {
        kTechId.Shotgun,
		kTechId.Submachinegun,
        kTechId.GrenadeLauncher,
        kTechId.Flamethrower,
        kTechId.HeavyMachineGun
    })

    local x4LabelStartX = 335

    local labelItemBottomLeft = self:CreateAnimatedTextItem()
    labelItemBottomLeft:SetIsScaling(false)
    labelItemBottomLeft:AddAsChildTo(weaponGroupBottomLeft)
    labelItemBottomLeft:SetPosition(Vector(x4LabelStartX, 0, 0))
    labelItemBottomLeft:SetAnchor(GUIItem.Left, GUIItem.Top)
    labelItemBottomLeft:SetTextAlignmentX(GUIItem.Align_Min)
    labelItemBottomLeft:SetTextAlignmentY(GUIItem.Align_Min)
    labelItemBottomLeft:SetFontName(Fonts.kAgencyFB_Tiny)
    labelItemBottomLeft:SetText(Locale.ResolveString("BUYMENU_GROUPLABEL_WEAPONS"))
    labelItemBottomLeft:SetOptionFlag(GUIItem.CorrectScaling)
    GUIMakeFontScale(labelItemBottomLeft, "kAgencyFB", 24)

    local weaponGroupTopRight = self:CreateAnimatedGraphicItem()
    weaponGroupTopRight:SetIsScaling(false)
    weaponGroupTopRight:AddAsChildTo(self.background)
    weaponGroupTopRight:SetPosition(Vector(weaponGroupTopLeft:GetPosition().x + weaponGroupTopLeft:GetSize().x + paddingXWeaponGroups, paddingY, 0))
    weaponGroupTopRight:SetTexture(kButtonGroupFrame_Unlabeled_x2)
    weaponGroupTopRight:SetSizeFromTexture()
    weaponGroupTopRight:SetOptionFlag(GUIItem.CorrectScaling)
    self:_InitializeWeaponGroup(weaponGroupTopRight, x2ButtonPositions,
    {
        kTechId.Axe,
        kTechId.Welder
    })

    local weaponGroupBottomRight = self:CreateAnimatedGraphicItem()
    weaponGroupBottomRight:SetIsScaling(false)
    weaponGroupBottomRight:AddAsChildTo(self.background)
    weaponGroupBottomRight:SetPosition(Vector(weaponGroupTopRight:GetPosition().x, weaponGroupTopRight:GetPosition().y + weaponGroupTopRight:GetSize().y + paddingYWeaponGroups, 0))
    weaponGroupBottomRight:SetTexture(kButtonGroupFrame_Labeled_x4)
    weaponGroupBottomRight:SetSizeFromTexture()
    weaponGroupBottomRight:SetOptionFlag(GUIItem.CorrectScaling)
    self:_InitializeWeaponGroup(weaponGroupBottomRight, x4ButtonPositions,
    {
        kTechId.GasGrenade,
        kTechId.ClusterGrenade,
        kTechId.PulseGrenade,
        kTechId.LayMines
    })

    local labelItemBottomRight = self:CreateAnimatedTextItem()
    labelItemBottomRight:SetIsScaling(false)
    labelItemBottomRight:AddAsChildTo(weaponGroupBottomRight)
    labelItemBottomRight:SetPosition(Vector(x4LabelStartX, 0, 0))
    labelItemBottomRight:SetAnchor(GUIItem.Left, GUIItem.Top)
    labelItemBottomRight:SetTextAlignmentX(GUIItem.Align_Min)
    labelItemBottomRight:SetTextAlignmentY(GUIItem.Align_Min)
    labelItemBottomRight:SetFontName(Fonts.kAgencyFB_Tiny)
    labelItemBottomRight:SetText(Locale.ResolveString("BUYMENU_GROUPLABEL_UTILITY"))
    labelItemBottomRight:SetOptionFlag(GUIItem.CorrectScaling)
    GUIMakeFontScale(labelItemBottomRight, "kAgencyFB", 24)

    local rightSideStartPos = weaponGroupTopRight:GetPosition()
    rightSideStartPos.x = rightSideStartPos.x + weaponGroupTopRight:GetSize().x
    rightSideStartPos.x = rightSideStartPos.x + paddingXWeaponGroupsToRightSide
    self:_CreateRightSide(rightSideStartPos)

end

function GUIMarineBuyMenu:_CreateRightSide(startPos)

    -- This is created here to eliminate common code
    self.buyButtonHighlight = self:CreateAnimatedGraphicItem()
    self.buyButtonHighlight:SetIsScaling(false)
    self.buyButtonHighlight:AddAsChildTo(self.background)
    self.buyButtonHighlight:SetTexture(kButtonHighlightTexture)
    self.buyButtonHighlight:SetSizeFromTexture()
    self.buyButtonHighlight:SetIsVisible(false)
    self.buyButtonHighlight:SetOptionFlag(GUIItem.CorrectScaling)

    self.purchaseText = self:CreateAnimatedTextItem()
    self.purchaseText:SetIsScaling(false)
    self.purchaseText:AddAsChildTo(self.buyButtonHighlight)
    self.purchaseText:SetPosition(Vector(18, 89, 0))
    self.purchaseText:SetOptionFlag(GUIItem.CorrectScaling)
    self.purchaseText:SetText(Locale.ResolveString("BUYMENU_CLICKTOPURCHASE"))
    GUIMakeFontScale(self.purchaseText, "kAgencyFBBold", 21)

    self.rightSideRoot = self:CreateAnimatedGraphicItem()
    self.rightSideRoot:AddAsChildTo(self.background)
    self.rightSideRoot:SetIsScaling(false)
    self.rightSideRoot:SetPosition(startPos)
    self.rightSideRoot:SetColor(Color(0,0,0,0))
    self.rightSideRoot:SetOptionFlag(GUIItem.CorrectScaling)

    local y = 0
    self.itemTitle = self:CreateAnimatedTextItem()
    self.itemTitle:AddAsChildTo(self.rightSideRoot)
    self.itemTitle:SetIsScaling(false)
    self.itemTitle:SetPosition(Vector(0, y, 0))
    self.itemTitle:SetFontIsBold(true)
    self.itemTitle:SetColor(Color(1,1,1,1))
    self.itemTitle:SetFontName(Fonts.kAgencyFB_Large_Bold)
    self.itemTitle:SetOptionFlag(GUIItem.CorrectScaling)
    GUIMakeFontScale(self.itemTitle, "kAgencyFBBold", 55)

    y = y + self.itemTitle:GetTextHeight(self.itemTitle:GetText()) + 18

    self.costText = self:CreateAnimatedTextItem()
    self.costText:AddAsChildTo(self.rightSideRoot)
    self.costText:SetIsScaling(false)
    self.costText:SetPosition(Vector(0, y, 0))
    self.costText:SetColor(Color(164/255, 196/255, 201/255, 1))
    self.costText:SetFontName(Fonts.kAgencyFB_Large_Bold)
    self.costText:SetOptionFlag(GUIItem.CorrectScaling)
    GUIMakeFontScale(self.costText, "kAgencyFBBold", 60)

    self.costTextIcon = self:CreateAnimatedGraphicItem()
    self.costTextIcon:AddAsChildTo(self.costText)
    self.costTextIcon:SetIsScaling(false)
    self.costTextIcon:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.costTextIcon:SetTexture(kResourceIcon_Unlit)
    self.costTextIcon:SetSizeFromTexture()
    self.costTextIcon:SetScale(Vector(1,1,1) * 1.5)
    self.costTextIcon:SetHotSpot(Vector(0, 0.5, 0))
    self.costTextIcon:SetOptionFlag(GUIItem.CorrectScaling)
    self.costTextIcon:SetPosition(Vector(-9, 0, 0))

    self.currentMoneyText = self:CreateAnimatedTextItem()
    self.currentMoneyText:AddAsChildTo(self.rightSideRoot)
    self.currentMoneyText:SetIsScaling(false)
    self.currentMoneyText:SetPosition(Vector(354, y, 0))
    self.currentMoneyText:SetFontIsBold(true)
    self.currentMoneyText:SetColor(Color(2/255, 230/255, 255/255, 1))
    self.currentMoneyText:SetFontName(Fonts.kAgencyFB_Large_Bold)
    self.currentMoneyText:SetText(Locale.ResolveString("BUYMENU_CURRENTMONEY_PREFIX"))
    self.currentMoneyText:SetOptionFlag(GUIItem.CorrectScaling)
    GUIMakeFontScale(self.currentMoneyText, "kAgencyFBBold", 60)

    self.currentMoneyTextIcon = self:CreateAnimatedGraphicItem()
    self.currentMoneyTextIcon:AddAsChildTo(self.currentMoneyText)
    self.currentMoneyTextIcon:SetIsScaling(false)
    self.currentMoneyTextIcon:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.currentMoneyTextIcon:SetTexture(kResourceIcon_Lit)
    self.currentMoneyTextIcon:SetSizeFromTexture()
    self.currentMoneyTextIcon:SetScale(Vector(1,1,1) * 1.5)
    self.currentMoneyTextIcon:SetHotSpot(Vector(0, 0.5, 0))
    self.currentMoneyTextIcon:SetOptionFlag(GUIItem.CorrectScaling)
    self.currentMoneyTextIcon:SetPosition(Vector(-9, 0, 0))

    y = y + 80

    local vsXPos = 145
    local vsTextPadding = 32
    local vsBarXOffset = 30
    local vsTextFontSize = 33

    self.statBarsStartPosY = y

    self.rangeText = self:CreateAnimatedTextItem()
    self.rangeText:AddAsChildTo(self.rightSideRoot)
    self.rangeText:SetIsScaling(false)
    self.rangeText:SetPosition(Vector(vsXPos, y, 0))
    self.rangeText:SetColor(Color(1, 1, 1))
    self.rangeText:SetTextAlignmentX(GUIItem.Align_Max)
    self.rangeText:SetText(Locale.ResolveString("BUYMENU_RANGE"))
    self.rangeText:SetOptionFlag(GUIItem.CorrectScaling)
    GUIMakeFontScale(self.rangeText, "kAgencyFB", vsTextFontSize)

    self.rangeBar = self:CreateAnimatedGraphicItem()
    self.rangeBar:AddAsChildTo(self.rightSideRoot)
    self.rangeBar:SetIsScaling(false)
    self.rangeBar:SetPosition(self.rangeText:GetPosition() + Vector(vsBarXOffset, 0, 0))
    self.rangeBar:SetTexture(kVSBarTexture)
    self.rangeBar:SetSizeFromTexture()
    self.rangeBar:SetOptionFlag(GUIItem.CorrectScaling)

    local rangeTextHeight = self.rangeText:GetTextHeight(self.rangeText:GetText())
    local rangeBarHeight = self.rangeBar:GetSize().y
    self.rangeBar:SetPosition(self.rangeBar:GetPosition() + Vector(0, (rangeTextHeight - rangeBarHeight) / 2, 0))

    y = y + vsTextPadding

    self.vsLifeformsText = self:CreateAnimatedTextItem()
    self.vsLifeformsText:AddAsChildTo(self.rightSideRoot)
    self.vsLifeformsText:SetIsScaling(false)
    self.vsLifeformsText:SetPosition(Vector(vsXPos, y, 0))
    self.vsLifeformsText:SetColor(Color(1, 1, 1))
    self.vsLifeformsText:SetTextAlignmentX(GUIItem.Align_Max)
    self.vsLifeformsText:SetText(Locale.ResolveString("BUYMENU_VSLIFEFORMS"))
    self.vsLifeformsText:SetOptionFlag(GUIItem.CorrectScaling)
    GUIMakeFontScale(self.vsLifeformsText, "kAgencyFB", vsTextFontSize)

    self.vsLifeformBar = self:CreateAnimatedGraphicItem()
    self.vsLifeformBar:AddAsChildTo(self.rightSideRoot)
    self.vsLifeformBar:SetIsScaling(false)
    self.vsLifeformBar:SetPosition(self.vsLifeformsText:GetPosition() + Vector(vsBarXOffset, 0, 0))
    self.vsLifeformBar:SetTexture(kVSBarTexture)
    self.vsLifeformBar:SetSizeFromTexture()
    self.vsLifeformBar:SetOptionFlag(GUIItem.CorrectScaling)

    local lifeformTextHeight = self.vsLifeformsText:GetTextHeight(self.vsLifeformsText:GetText())
    local lifeformBarHeight = self.vsLifeformBar:GetSize().y
    self.vsLifeformBar:SetPosition(self.vsLifeformBar:GetPosition() + Vector(0, (lifeformTextHeight - lifeformBarHeight) / 2, 0))

    y = y + vsTextPadding

    self.vsStructuresText = self:CreateAnimatedTextItem()
    self.vsStructuresText:AddAsChildTo(self.rightSideRoot)
    self.vsStructuresText:SetIsScaling(false)
    self.vsStructuresText:SetPosition(Vector(vsXPos, y, 0))
    self.vsStructuresText:SetColor(Color(1, 1, 1))
    self.vsStructuresText:SetTextAlignmentX(GUIItem.Align_Max)
    self.vsStructuresText:SetText(Locale.ResolveString("BUYMENU_VSSTRUCTURES"))
    self.vsStructuresText:SetOptionFlag(GUIItem.CorrectScaling)
    GUIMakeFontScale(self.vsStructuresText, "kAgencyFB", vsTextFontSize)

    self.vsStructuresBar = self:CreateAnimatedGraphicItem()
    self.vsStructuresBar:AddAsChildTo(self.rightSideRoot)
    self.vsStructuresBar:SetIsScaling(false)
    self.vsStructuresBar:SetPosition(self.vsStructuresText:GetPosition() + Vector(vsBarXOffset, 0, 0))
    self.vsStructuresBar:SetTexture(kVSBarTexture)
    self.vsStructuresBar:SetSizeFromTexture()
    self.vsStructuresBar:SetOptionFlag(GUIItem.CorrectScaling)

    local structuresTextHeight = self.vsStructuresText:GetTextHeight(self.vsStructuresText:GetText())
    local structuresBarHeight = self.vsStructuresBar:GetSize().y
    self.vsStructuresBar:SetPosition(self.vsStructuresBar:GetPosition() + Vector(0, (structuresTextHeight - structuresBarHeight) / 2, 0))

    y = y + 50

    self.itemDescriptionPositionY = y
    self.itemDescription = self:CreateAnimatedTextItem()
    self.itemDescription:AddAsChildTo(self.rightSideRoot)
    self.itemDescription:SetIsScaling(false)
    self.itemDescription:SetTextClipped(true, 687, -1)
    self.itemDescription:SetPosition(Vector(0, self.itemDescriptionPositionY, 0))
    self.itemDescription:SetColor(Color(164/255, 196/255, 201/255))
    self.itemDescription:SetOptionFlag(GUIItem.CorrectScaling)
    GUIMakeFontScale(self.itemDescription, "kAgencyFB", vsTextFontSize)

    y = y + 75

    local bigPicturesTexture = kArmoryBigPicturesTexture
    if self.hostStructure:isa("PrototypeLab") then
        bigPicturesTexture = kPrototypeLabBigPicturesTexture
    end

    self.bigPicturePositionY = y
    self.bigPicturePositionYDiff = 75

    self.bigPicture = self:CreateAnimatedGraphicItem()
    self.bigPicture:AddAsChildTo(self.rightSideRoot)
    self.bigPicture:SetIsScaling(false)
    self.bigPicture:SetPosition(Vector(0, y, 0))
    self.bigPicture:SetTexture(bigPicturesTexture)
    local bigPictureCoords = self:_GetPigPicturePixelCoordinatesForTechID(kTechId.Pistol)
    self.bigPicture:SetSize(GUIGetSizeFromCoords(bigPictureCoords))
    self.bigPicture:SetTexturePixelCoordinates(GUIUnpackCoords(bigPictureCoords))
    self.bigPicture:SetOptionFlag(GUIItem.CorrectScaling)

    y = y + self.bigPicture:GetSize().y

    self.specialFrame = self:CreateAnimatedGraphicItem()
    self.specialFrame:SetIsScaling(false)
    self.specialFrame:SetTexture(kSpecialsTexture)
    self.specialFrame:SetSize(GUIGetSizeFromCoords(kSpecialDefinitions[kSpecial.Electrify].TextureCoordinates))
    self.specialFrame:SetTexturePixelCoordinates(GUIUnpackCoords(bigPictureCoords))
    self.specialFrame:SetOptionFlag(GUIItem.CorrectScaling)

    local buttonGroupX = 97
    local buttonGroupY = 149 + 373 + 20
    if self.hostStructure:isa("PrototypeLab") then

        self.specialFrame:AddAsChildTo(self.background)
        self.specialFrame:SetPosition(Vector(buttonGroupX, buttonGroupY, 0))

    elseif self.hostStructure:isa("Armory") then

        self.specialFrame:AddAsChildTo(self.rightSideRoot)
        self.specialFrame:SetPosition(Vector(0, y, 0))

    end

    self.specialTitle = self:CreateAnimatedTextItem()
    self.specialTitle:AddAsChildTo(self.specialFrame)
    self.specialTitle:SetIsScaling(false)
    self.specialTitle:SetPosition(Vector(90, 0, 0))
    self.specialTitle:SetOptionFlag(GUIItem.CorrectScaling)
    GUIMakeFontScale(self.specialTitle, "kAgencyFBBold", 32)

    self.specialTexts = {}

    local maxSpecials = 0
    if self.hostStructure:isa("Armory") then
        maxSpecials = 2
    elseif self.hostStructure:isa("PrototypeLab") then
        maxSpecials = 5
    end

    for _ = 1, maxSpecials do

        local specialText = self:CreateAnimatedTextItem()
        specialText:AddAsChildTo(self.specialFrame)
        specialText:SetIsScaling(false)
        specialText:SetOptionFlag(GUIItem.CorrectScaling)
        GUIMakeFontScale(specialText, "kAgencyFB", 25)

        table.insert(self.specialTexts, specialText)
    end

    if self.hostStructure:isa("PrototypeLab") then
        local buttonGroupX = 97
        local buttonGroupY = (149 + 373 + 20) + 150
        self.specialFrame:SetPosition(Vector(buttonGroupX, buttonGroupY, 0))
    end
end

function GUIMarineBuyMenu:OnClose()

    -- Check if GUIMarineBuyMenu is what is causing itself to close.
    if not self.closingMenu then
        -- Play the close sound since we didn't trigger the close.
        MarineBuy_OnClose()
    end

end

function GUIMarineBuyMenu:OnResolutionChanged(oldX, oldY, newX, newY)
    self:Uninitialize()
    self:Initialize()
    
    MarineBuy_OnClose()
end

function GUIMarineBuyMenu:Initialize()

    GUIAnimatedScript.Initialize(self)

    -- NOTE(Salads): UI is created when SetHostStructure is called.

    -- Art file is not based on 1920x1080, so we do our own scaling.
    self.customScale = (Client.GetScreenHeight() / self.kMockupSize.y)
    self.customScaleVector = Vector(1,1,1) * self.customScale

    self.mouseOverStates = { }
    self.buyButtons = { } -- stores all of the button guiItems that purchase things.
    self.specialTexts = { }

    self.hoveredBuyButton = nil

    self.initialized = false -- Don't want to start with the details section empty.
    self.defaultTechId = kTechId.None

    -- note: items buttons get initialized through SetHostStructure()
    MarineBuy_OnOpen()
    
    MouseTracker_SetIsVisible(true, "ui/Cursor_MenuDefault.dds", true)
    
end

--
-- Checks if the mouse is over the passed in GUIItem and plays a sound if it has just moved over.
--
local function GetIsMouseOver(self, overItem)

    local mouseX, mouseY = Client.GetCursorPosScreen()
    local mouseOver = GUIItemContainsPoint(overItem, mouseX, mouseY, true)
    if mouseOver and not self.mouseOverStates[overItem] then
        MarineBuy_OnMouseOver()
    end

    local changed = self.mouseOverStates[overItem] ~= mouseOver
    self.mouseOverStates[overItem] = mouseOver
    return mouseOver, changed
    
end

function GUIMarineBuyMenu:_SetDetailsSectionTechId(techId, techCost)

    self.initialized = true

    local displayName = LookupTechData(techId, kTechDataDisplayName, nil)
    self.itemTitle:SetText(string.upper(Locale.ResolveString(displayName or "NO NAME")))

    self.costText:SetText(string.format("%s: %d", Locale.ResolveString("BUYMENU_COST"), techCost))

    local description = kTechIdInfo[techId].Description
    self.itemDescription:SetText(Locale.ResolveString(description))

    local bigPictureCoords = self:_GetPigPicturePixelCoordinatesForTechID(techId)
    self.bigPicture:SetTexturePixelCoordinates(GUIUnpackCoords(bigPictureCoords))

    local stats = kTechIdInfo[techId].Stats

    if stats then

        self.rangeBar:SetIsVisible(true)
        self.vsStructuresBar:SetIsVisible(true)
        self.vsLifeformBar:SetIsVisible(true)

        self.rangeText:SetIsVisible(true)
        self.vsStructuresText:SetIsVisible(true)
        self.vsLifeformsText:SetIsVisible(true)

        -- Grenades override the "range" label to instead say "AOE Range"
        self.rangeText:SetText(stats.RangeLabelOverride and Locale.ResolveString("BUYMENU_GRENADES_RANGE_OVERRIDE") or Locale.ResolveString("BUYMENU_RANGE"))

        self:_UpdateStatBar(self.rangeBar, stats.Range)
        self:_UpdateStatBar(self.vsLifeformBar, stats.LifeFormDamage)
        self:_UpdateStatBar(self.vsStructuresBar, stats.StructureDamage)
        self.itemDescription:SetPosition(Vector(0, self.itemDescriptionPositionY, 0))
        self.bigPicture:SetPosition(Vector(0, self.bigPicturePositionY, 0))

    else

        self.rangeBar:SetIsVisible(false)
        self.vsStructuresBar:SetIsVisible(false)
        self.vsLifeformBar:SetIsVisible(false)

        self.rangeText:SetIsVisible(false)
        self.vsStructuresText:SetIsVisible(false)
        self.vsLifeformsText:SetIsVisible(false)

        self.itemDescription:SetPosition(Vector(0, self.statBarsStartPosY, 0))
        self.bigPicture:SetPosition(Vector(0, self.bigPicturePositionY - self.bigPicturePositionYDiff, 0))

    end


    -- Update the "special" stuff.
    local techSpecial = kTechIdInfo[techId].Special
    if techSpecial then

        local specialDefinition = kSpecialDefinitions[techSpecial]
        self:_UpdateSpecialSection(specialDefinition)

        self.specialFrame:SetIsVisible(true)
    else
        self.specialFrame:SetIsVisible(false)
    end
	
	if techId == kTechId.DualMinigunExosuit then
        self.itemTitle:SetIsVisible(false)
        self.costText:SetIsVisible(false)
        self.itemDescription:SetIsVisible(false)
        self.bigPicture:SetPosition(Vector(285, 100, 0))
        self.bigPicture:SetAnchor(GUIItem.Top, GUIItem.Left)
        
        self.currentMoneyText:SetIsVisible(false)
        self.currentMoneyTextIcon:SetIsVisible(false)
        self.rangeBar:SetIsVisible(false)
        self.vsStructuresBar:SetIsVisible(false)
        self.vsLifeformBar:SetIsVisible(false)
        
        self.rangeText:SetIsVisible(false)
        self.vsStructuresText:SetIsVisible(false)
        self.vsLifeformsText:SetIsVisible(false)
    else
        self.itemTitle:SetIsVisible(true)
        self.costText:SetIsVisible(true)
        self.itemDescription:SetIsVisible(true)
        self.bigPicture:SetIsVisible(true)
        self.currentMoneyText:SetIsVisible(true)
        self.currentMoneyTextIcon:SetIsVisible(true)
    
    end
end

function GUIMarineBuyMenu:_UpdateRealTimeElements(buttonTable, techId, techAvailable, currentMoney, techCost)

    self.currentMoneyText:SetText(string.format("%s %s", Locale.ResolveString("BUYMENU_CURRENTMONEY_PREFIX"), ToString(currentMoney)))

    -- Update button availability state
    local costText = buttonTable.CostText
    local teamText = buttonTable.TeamText
    local buttonItem = buttonTable.Button
    if techAvailable then

        buttonItem:SetColor(Color(1,1,1))

        local costTextColor = self.kCostTextColor_HasEnoughMoney
        if techCost <= 0 then
            costTextColor = self.kCostTextColor_Free
        elseif techCost > currentMoney then
            costTextColor = self.kCostTextColor_NotEnoughMoney
        end

        costText:SetColor(costTextColor)

    else

        buttonItem:SetColor(Color(0,0,0))
        costText:SetColor(self.kCostTextColor_Free) -- This is grey, but yeah the naming is weird.

    end

    local teamInfo = GetTeamInfoEntity(kTeam1Index)
    local techMapName = self:_GetMapNameForNetvar(techId)
    assert(techMapName)

    if teamInfo and techMapName then
        local netVarName = TeamInfo_GetUserTrackerNetvarName(techMapName)
        local numUsers = teamInfo[netVarName]
        assert(numUsers, string.format("Netvar %s does not exist in MarineTeamInfo!", netVarName))
        teamText:SetText(string.format("%d", numUsers))
        teamText:SetColor(ConditionalValue(numUsers > 0, self.kTeamTextColor_HasPlayers, self.kTeamTextColor_None))
    end


end

function GUIMarineBuyMenu:_UpdateBuyButtonAvailability(buttonTable, hoverStateChanged, useHoverTexture, buttonState)

    assert(buttonState ~= kButtonShowState.Uninitialized)

    local buttonItem = buttonTable.Button
    local techId = buttonTable.TechID
    local lastShowState = buttonTable.LastShowState
    local buttonShowStateDef = kButtonShowStateDefinitions[buttonState]

    if lastShowState ~= buttonState then

        local showError = buttonShowStateDef.ShowError
        buttonTable.ErrorFrame:SetIsVisible(showError)
        if showError then
            buttonTable.ErrorTextItem:SetText(Locale.ResolveString(buttonShowStateDef.Text))
            buttonTable.ErrorTextItem:SetColor(buttonShowStateDef.TextColor)

            -- Resize the error text frame to the size of the text, plus some padding
            local textScale = buttonTable.ErrorTextItem:GetScale().x
            local textWidth = buttonTable.ErrorTextItem:GetTextWidth(buttonTable.ErrorTextItem:GetText()) * textScale
            local newFrameWidth = textWidth + (self.kErrorFrameTextPadding * 2)
            buttonTable.ErrorFrame:SetSize(Vector(newFrameWidth, buttonTable.ErrorFrame:GetSize().y, 0))
        end

        buttonTable.LastShowState = buttonState

    end

    if hoverStateChanged then
        local coords = self:_GetButtonPixelCoordinatesForTechID(techId, useHoverTexture)
        buttonItem:SetTexturePixelCoordinates(GUIUnpackCoords(coords))
    end

end

function GUIMarineBuyMenu:Update(deltaTime)

    -- Update all of the buy buttons.
    self.hoveredBuyButton = nil
    local hoveredTechAvailable = false
    local hoveredCanAfford = false

    for i = 1, #self.buyButtons do

        local buttonTable = self.buyButtons[i]
        local buttonItem = buttonTable.Button
        local techId = buttonTable.TechID
        assert(buttonItem)

        local hovering, changed = GetIsMouseOver(self, buttonItem)
        local techResearched = self:_GetResearchInfo(techId)
        local hasTable = MarineBuy_GetHas(techId)
        local techAlreadyEquipped = hasTable.Has
        local techOccupied = hasTable.Occupied

        local hostTechId = self.hostStructure:GetTechId()
        if self.lastHostTechId ~= hostTechId or not buttonTable.Initialized then

            local isHosted = false

            for _, supportedTechId in ipairs(self.hostStructure:GetItemList()) do
                if supportedTechId == techId then
                    isHosted = true
                    break
                end
            end

            self.lastHostTechId = hostTechId
            buttonTable.Hosted = isHosted

        end

        local initEvent = ((techId == self.defaultTechId) and not self.initialized)
        local techAvailable = techResearched and not (techAlreadyEquipped or techOccupied) and buttonTable.Hosted and not buttonTable.Disabled
        local currentMoney = math.floor(PlayerUI_GetPersonalResources() * 10) / 10
        local useHoverTexture = hovering and techAvailable

        -- Update details section.
        local techCost = LookupTechData(techId, kTechDataCostKey, -1)
        if (hovering and changed) or initEvent then
            self:_SetDetailsSectionTechId(techId, techCost)
        end

        -- Get the button's new state, then update it.
        local buttonState = kButtonShowState.Available

        if buttonTable.Disabled then
            buttonState = kButtonShowState.Disabled
        elseif not buttonTable.Hosted then
            buttonState = kButtonShowState.NotHosted
        elseif techOccupied then
            buttonState = kButtonShowState.Occupied
        elseif techAlreadyEquipped then
            buttonState = kButtonShowState.Equipped
        elseif not techResearched then
            buttonState = kButtonShowState.Unresearched
        elseif techCost > currentMoney then
            buttonState = kButtonShowState.InsufficientFunds
        end

        self:_UpdateBuyButtonAvailability(buttonTable, changed, useHoverTexture, buttonState)
        self:_UpdateRealTimeElements(buttonTable, techId, techAvailable, currentMoney, techCost)

        if hovering then
            self.hoveredBuyButton = buttonTable
            hoveredTechAvailable = techAvailable
            hoveredCanAfford = currentMoney >= techCost
        end

    end

    -- Update hover item.
    if self.hoveredBuyButton then
        self.buyButtonHighlight:SetPosition(self.hoveredBuyButton.WeaponGroup:GetPosition() + self.hoveredBuyButton.Button:GetPosition() + Vector(-5, -5, 0))
        self.buyButtonHighlight:SetIsVisible(true)
        self.purchaseText:SetIsVisible(hoveredTechAvailable and hoveredCanAfford)
    else
        self.buyButtonHighlight:SetIsVisible(false)
    end

	self:_UpdateExoModularButtons()
	
	if self.hoveredBuyButton and self.hoveredBuyButton.TechID == kTechId.DualMinigunExosuit or (self.hoveredBuyButton == nil and self.hoveringExo) then
        self.hoveringExo = true
        self.modularExoConfigActive = true
        for elementI, element in ipairs(self.modularExoGraphicItemsToDestroyList) do
            element:SetIsVisible(true)
        end
        
        return
    end
    if self.modularExoGraphicItemsToDestroyList then
        self.hoveringExo = false
        self.modularExoConfigActive = false
        for elementI, element in ipairs(self.modularExoGraphicItemsToDestroyList) do
            element:SetIsVisible(false)
        end
    end
end

function GUIMarineBuyMenu:_GetMapNameForNetvar(techId)

    local rawMapName = LookupTechData(techId, kTechDataMapName, nil)
    if rawMapName ~= Exo.kMapName then
        return rawMapName, false
    end

    -- Exos all have the same player class "exo", which have a weapon called "ExoWeaponHolder", which then holds two weapons. (Railgun/Minigun)
    -- At the moment we only have dual-wield of the same weapon.
    local overriddenMapName = rawMapName
    if techId == kTechId.DualRailgunExosuit then
        overriddenMapName = string.format("%s+%s", Railgun.kMapName, Railgun.kMapName)
    elseif techId == kTechId.DualMinigunExosuit then
        overriddenMapName = string.format("%s+%s", Minigun.kMapName, Minigun.kMapName)
    else
        assert(false, "Invalid exo techId for user tracker!")
    end

    return overriddenMapName

end

function GUIMarineBuyMenu:Uninitialize()
    
    GUIAnimatedScript.Uninitialize(self)

    if self.background then
        self.background:Destroy()
    end
    
    MouseTracker_SetIsVisible(false)
    
end

function GUIMarineBuyMenu:_GetResearchInfo(techId)

    local researched = MarineBuy_IsResearched(techId)
    local researchProgress = 0
    local researching = false

    if not researched then
        researchProgress = MarineBuy_GetResearchProgress(techId)
    end

    if not (researchProgress == 0) then
        researching = true
    end

    return researched, researchProgress, researching

end

local function HandleItemClicked(self)
    
    if self.hoveredBuyButton then
        
        local item = self.hoveredBuyButton
		        
        local researched = self:_GetResearchInfo(item.TechID)
        local itemCost = MarineBuy_GetCosts(item.TechID)
        local canAfford = PlayerUI_GetPlayerResources() >= itemCost
        local hasItem = PlayerUI_GetHasItem(item.TechID)
	
        if not item.Disabled and researched and canAfford and not hasItem and item.TechID ~= kTechId.DualMinigunExosuit then
            
            MarineBuy_PurchaseItem(item.TechID)
            MarineBuy_OnClose()
            
            return true, true
        
        end
    
    end
	
    if self.hoveringExo then
        local researched = self:_GetResearchInfo(kTechId.DualMinigunExosuit)
        if GetIsMouseOver(self, self.modularExoBuyButton) and researched then
            Client.SendNetworkMessage("ExoModularBuy", ModularExo_ConvertConfigToNetMessage(self.exoConfig))
            MarineBuy_OnClose()
            return true, true
        end
        for buttonI, buttonData in ipairs(self.modularExoModuleButtonList) do
            if GetIsMouseOver(self, buttonData.buttonGraphic) then
                if buttonData.state == "enabled" then
                    self.exoConfig[buttonData.slotType] = buttonData.moduleType
                    if buttonData.forceToDefaultConfig then
                        self.exoConfig[kExoModuleSlots.RightArm] = kExoModuleTypes.Minigun
                        self.exoConfig[kExoModuleSlots.LeftArm] = kExoModuleTypes.Claw
                        self.exoConfig[kExoModuleSlots.Utility] = kExoModuleTypes.None
                        self.exoConfig[kExoModuleSlots.Ability] = kExoModuleTypes.None
                    end
                    if buttonData.forceLeftToClaw then
                        self.exoConfig[kExoModuleSlots.LeftArm] = kExoModuleTypes.Claw
                    end
                    self:_RefreshExoModularButtons()
                end
            end
        end
    end
    return false, false

end

function GUIMarineBuyMenu:SendKeyEvent(key, down)

    local closeMenu = false
    local inputHandled = false

    if key == InputKey.MouseButton0 and self.mousePressed ~= down then

        self.mousePressed = down

        if down then
            inputHandled, closeMenu = HandleItemClicked(self)
        end

    end

    -- No matter what, this menu consumes MouseButton0/1.
    if key == InputKey.MouseButton0 or key == InputKey.MouseButton1 then
        inputHandled = true
    end

    if InputKey.Escape == key and not down then

        closeMenu = true
        inputHandled = true
        MarineBuy_OnClose()

    end

    if closeMenu then
        MarineBuy_Close()
    end

    return inputHandled
    
end

-- %%% New CBM Functions %%% --
local kResourceIconTexture = "ui/pres_icon_big.dds"
local kButtonTexture = "ui/marine_buymenu_button.dds"
local kMenuSelectionTexture = "ui/buymenu_marine/button_highlight.dds"
local kResourceIconWidth = (32)
local kResourceIconHeight = (32)

local kFont = Fonts.kAgencyFB_Small

local kCloseButtonColorHover = Color(1, 1, 1, 1)
local kCloseButtonColor = Color(0.82, 0.98, 1, 1)
local kTextColor = Color(kMarineFontColor)

local kDisabledColor = Color(0.82, 0.98, 1, 0.5)
local kCannotBuyColor = Color(0.98, 0.24, 0.17, 1)
local kEnabledColor = Color(1, 1, 1, 1)

local kConfigAreaWidth = 1000
local kConfigAreaHeight = 900

local kSlotPanelBackgroundColor = Color(0, 0, 0, 0.6)
local kModuleButtonSize = Vector(220, 84, 0)
local kWeaponImageSize = Vector(80, 40, 0)
local kUtilityImageSize = Vector(59, 59, 0)

GUIMarineBuyMenu.kExoSlotData = {
    [kExoModuleSlots.RightArm] = {
        label      = "Secondary Weapon", --label = "EXO_MODULESLOT_RIGHT_ARM",
        xp         = 0.0,
        yp         = 0.16,
        anchorX    = GUIItem.Left,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeModuleButton(moduleType, moduleTypeData, offsetX, offsetY, kExoModuleSlots.RightArm, false)
        end,
    },
    [kExoModuleSlots.LeftArm]  = {
        label      = "Primary Weapon", --label = "EXO_MODULESLOT_LEFT_ARM",
        xp         = 1.00,
        yp         = 0.16,
        anchorX    = GUIItem.Right,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeModuleButton(moduleType, moduleTypeData, offsetX, offsetY, kExoModuleSlots.LeftArm, false)
        end,
    },
    
    [kExoModuleSlots.Utility]  = {
        label      = "Core Module", --label = "EXO_MODULESLOT_UTILITY",
        xp         = 0.0,
        yp         = 0.65,
        anchorX    = GUIItem.Left,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeModuleButton(moduleType, moduleTypeData, offsetX, offsetY, kExoModuleSlots.Utility, true)
        end,
    },
    -- [kExoModuleSlots.Ability]  = {
    --     label      = "Squad Support", --label = "EXO_MODULESLOT_ABILITY",
    --     xp         = 0.0,
    --     yp         = 0.85,
    --     anchorX    = GUIItem.Left,
    --     makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
    --         return self:MakeModuleButton(moduleType, moduleTypeData, offsetX, offsetY, kExoModuleSlots.Ability, true)
    --     end,
    -- },
}

function GUIMarineBuyMenu:_InitializeExoModularButtons()
    --local canHaveDualArm = self.hostStructure:GetTechId() == kTechId.AdvancedPrototypeLab

    self.activeExoConfig = nil
    local player = Client.GetLocalPlayer()
    if player and player:isa("Exo") then
        self.activeExoConfig = ModularExo_ConvertNetMessageToConfig(player)
        -- isValid, badReason, resourceCost
        local _, _, resourceCost = ModularExo_GetIsConfigValid(self.activeExoConfig)
        self.activeExoConfigResCost = resourceCost
        self.exoConfig = self.activeExoConfig
    else
        self.activeExoConfig = {}
        self.activeExoConfigResCost = 0
        self.exoConfig = {
            [kExoModuleSlots.RightArm] = kExoModuleTypes.Minigun,
            [kExoModuleSlots.LeftArm]  = kExoModuleTypes.Claw,
            [kExoModuleSlots.Utility]  = kExoModuleTypes.None,
            [kExoModuleSlots.Ability]  = kExoModuleTypes.None,
        }
    end

    self.modularExoConfigActive = false
    self.modularExoGraphicItemsToDestroyList = {}
    self.modularExoModuleButtonList = {}
    
    local kFontSize = 40
    -------UPGRADE/BUY Button ---
    local kButtonWidth = 220
    local bPadding = 0
    self.modularExoBuyButtonBackground = self:CreateAnimatedGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, self.modularExoBuyButtonBackground)
    self.modularExoBuyButtonBackground:SetIsScaling(false)
    
    self.modularExoBuyButtonBackground:SetSize(Vector(kModuleButtonSize.x + bPadding * 2, kModuleButtonSize.y + bPadding * 2, 0))
    self.modularExoBuyButtonBackground:SetPosition(Vector(kConfigAreaWidth - kButtonWidth, 0.86 * kConfigAreaHeight, 0))
    self.modularExoBuyButtonBackground:SetTexture(kButtonTexture)
    self.modularExoBuyButtonBackground:SetColor(kSlotPanelBackgroundColor)
    self.modularExoBuyButtonBackground:SetOptionFlag(GUIItem.CorrectScaling)
    self.rightSideRoot:AddChild(self.modularExoBuyButtonBackground)
    
    self.modularExoBuyButton = self:CreateAnimatedGraphicItem()
    self.modularExoBuyButton:SetIsScaling(false)
    self.modularExoBuyButton:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.modularExoBuyButton:SetSize(kModuleButtonSize)
    self.modularExoBuyButton:SetPosition(Vector(bPadding, bPadding, 0))
    self.modularExoBuyButton:SetTexture(kMenuSelectionTexture)
    self.modularExoBuyButton:SetLayer(kGUILayerMarineBuyMenu)
    self.modularExoBuyButton:SetOptionFlag(GUIItem.CorrectScaling)
    self.modularExoBuyButtonBackground:AddChild(self.modularExoBuyButton)
    
    self.modularExoBuyButtonText = self:CreateAnimatedTextItem()
    self.modularExoBuyButtonText:SetIsScaling(false)
    self.modularExoBuyButtonText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.modularExoBuyButtonText:SetPosition(Vector(0, 0, 0))
    self.modularExoBuyButtonText:SetFontName(kFont)
    self.modularExoBuyButtonText:SetTextAlignmentX(GUIItem.Align_Center)
    self.modularExoBuyButtonText:SetTextAlignmentY(GUIItem.Align_Center)
    self.modularExoBuyButtonText:SetText(Locale.ResolveString("BUY"))
    self.modularExoBuyButtonText:SetFontIsBold(true)
    self.modularExoBuyButtonText:SetColor(kCloseButtonColor)
    self.modularExoBuyButtonText:SetOptionFlag(GUIItem.CorrectScaling)
    GUIMakeFontScale(self.modularExoBuyButtonText, "kAgencyFB", kFontSize + 3)
    self.modularExoBuyButton:AddChild(self.modularExoBuyButtonText)
    
    self.modularExoCostText = self:CreateAnimatedTextItem()
    self.modularExoCostText:SetIsScaling(false)
    self.modularExoCostText:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.modularExoCostText:SetPosition(Vector(kResourceIconWidth + 10, 0, 0))
    self.modularExoCostText:SetFontName(kFont)
    self.modularExoCostText:SetTextAlignmentX(GUIItem.Align_Min)
    self.modularExoCostText:SetTextAlignmentY(GUIItem.Align_Center)
    self.modularExoCostText:SetText("0")
    self.modularExoCostText:SetFontIsBold(true)
    self.modularExoCostText:SetColor(kTextColor)
    self.modularExoCostText:SetOptionFlag(GUIItem.CorrectScaling)
    GUIMakeFontScale(self.modularExoCostText, "kAgencyFB", kFontSize)
    self.modularExoBuyButton:AddChild(self.modularExoCostText)
    
    self.modularExoCostIcon = self:CreateAnimatedGraphicItem()
    self.modularExoCostIcon:SetIsScaling(false)
    self.modularExoCostIcon:SetSize(Vector(kResourceIconWidth * 0.7, kResourceIconHeight * 0.7, 0))
    self.modularExoCostIcon:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.modularExoCostIcon:SetPosition(Vector(10, -kResourceIconHeight * 0.4, 0))
    self.modularExoCostIcon:SetTexture(kResourceIconTexture)
    self.modularExoCostIcon:SetColor(kTextColor)
    self.modularExoCostIcon:SetOptionFlag(GUIItem.CorrectScaling)
    self.modularExoBuyButton:AddChild(self.modularExoCostIcon)
    
    
    --BUY/UPGRADE BUTTON ENDS HERE
    --[[local slotData
    if canHaveDualArm then
        slotData = GUIMarineBuyMenu.kExoSlotData
    else
        slotData = {
            [kExoModuleSlots.RightArm] = GUIMarineBuyMenu.kExoSlotData[kExoModuleSlots.RightArm],
            [kExoModuleSlots.LeftArm] = GUIMarineBuyMenu.kExoSlotData[kExoModuleSlots.LeftArm],
			}
    end]]
    
    for slotType, slotGUIDetails in pairs(GUIMarineBuyMenu.kExoSlotData) do
        local panelBackground = self:CreateAnimatedGraphicItem()
        table.insert(self.modularExoGraphicItemsToDestroyList, panelBackground)
        panelBackground:SetIsScaling(false)
        panelBackground:SetTexture(kButtonTexture)
        panelBackground:SetColor(kSlotPanelBackgroundColor)
        panelBackground:SetOptionFlag(GUIItem.CorrectScaling)
        local panelSize
        
        local slotTypeData = kExoModuleSlotsData[slotType]
        
        local panelTitle = self:CreateAnimatedTextItem()
        panelTitle:SetIsScaling(false)
        panelTitle:SetFontName(kFont)
        panelTitle:SetFontIsBold(true)
        panelTitle:SetPosition(Vector(-1, -50, 0))
        panelTitle:SetAnchor(GUIItem.Left, GUIItem.Top)
        panelTitle:SetTextAlignmentX(GUIItem.Align_Min)
        panelTitle:SetTextAlignmentY(GUIItem.Align_Min)
        panelTitle:SetColor(kTextColor)
        panelTitle:SetOptionFlag(GUIItem.CorrectScaling)
        panelTitle:SetText(slotGUIDetails.label)--(Locale.ResolveString("BUY"))
        GUIMakeFontScale(panelTitle, "kAgencyFB", kFontSize)
        panelBackground:AddChild(panelTitle)
        local padding = 5
        local startOffsetX = padding
        local startOffsetY = padding
        local offsetX, offsetY = startOffsetX, startOffsetY
        -- moduleType, moduleTypeName
        for moduleType, _ in ipairs(kExoModuleTypes) do
            local moduleTypeData = kExoModuleTypesData[moduleType]
            local isSameType = (moduleTypeData and moduleTypeData.category == slotTypeData.category)
            if moduleType == kExoModuleTypes.None and not slotTypeData.required then
                isSameType = true
                moduleTypeData = {}
            end
            -- excludes claw on secondary weapon (right) slot
            if isSameType and slotTypeData.category == kExoModuleCategories.Weapon and moduleTypeData.leftArmOnly and kExoModuleSlots.RightArm == slotType then
                isSameType = false
            end
            if isSameType then
                --[[if (slotType == kExoModuleSlots.LeftArm and (moduleTypeData.advancedOnly and not canHaveDualArm)) then
                    break
                end]]
                local buttonGraphic, newOffsetX, newOffsetY = slotGUIDetails.makeButton(self, moduleType, moduleTypeData, offsetX, offsetY)
                offsetX, offsetY = newOffsetX, newOffsetY
                panelBackground:AddChild(buttonGraphic)
            end
        end
        if offsetX == startOffsetX then
            offsetX = offsetX + kModuleButtonSize.x
        end
        
        if offsetY == startOffsetY then
            offsetY = offsetY + kModuleButtonSize.y
        end
        panelSize = Vector(offsetX + padding, offsetY + padding, 0)
        
        panelBackground:SetSize(panelSize)
        local panelX = slotGUIDetails.xp * kConfigAreaWidth
        local panelY = slotGUIDetails.yp * kConfigAreaHeight
        if slotGUIDetails.anchorX == GUIItem.Right then
            panelX = panelX - panelSize.x
        end
        
        panelBackground:SetPosition(Vector(panelX, panelY, 0))
        self.rightSideRoot:AddChild(panelBackground)
    end
end

function GUIMarineBuyMenu:MakeModuleButton(moduleType, moduleTypeData, offsetX, offsetY, slotType, vertical)
    local moduleTypeGUIDetails = GUIMarineBuyMenu.kExoModuleData[moduleType]
    local kFontSize = 40
    local buttonGraphic = self:CreateAnimatedGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, buttonGraphic)
    buttonGraphic:SetIsScaling(false)
    buttonGraphic:SetSize(kModuleButtonSize)
    buttonGraphic:SetAnchor(GUIItem.Left, GUIItem.Top)
    buttonGraphic:SetPosition(Vector(offsetX, offsetY, 0))
    buttonGraphic:SetTexture(kMenuSelectionTexture)
    buttonGraphic:SetOptionFlag(GUIItem.CorrectScaling)
    
    local contentPaddingX = 15
    local contentPaddingY = 5.5
    local label = self:CreateAnimatedTextItem()
    label:SetIsScaling(false)
    label:SetFontName(kFont)
    label:SetPosition(Vector(contentPaddingX, contentPaddingY, 0))
    label:SetAnchor(GUIItem.Left, GUIItem.Top)
    label:SetTextAlignmentX(GUIItem.Align_Min)
    label:SetTextAlignmentY(GUIItem.Align_Min)
    label:SetColor(kTextColor)
    label:SetText(tostring(moduleTypeGUIDetails.label))
    label:SetOptionFlag(GUIItem.CorrectScaling)
    GUIMakeFontScale(label, "kAgencyFB", kFontSize)
    buttonGraphic:AddChild(label)
    
    local resourceCost = moduleTypeData.resourceCost or 0
    
    local image = self:CreateAnimatedGraphicItem()
    image:SetIsScaling(false)
    if vertical then
        image:SetPosition(Vector(-kUtilityImageSize.x - contentPaddingX, -kUtilityImageSize.y * 0.5, 0))
        image:SetSize(kUtilityImageSize)
    else
        image:SetPosition(Vector(-kWeaponImageSize.x - contentPaddingX, -kWeaponImageSize.y * 0.5, 0))
        image:SetSize(kWeaponImageSize)
    end
    image:SetAnchor(GUIItem.Right, GUIItem.Center)
    image:SetTexture(moduleTypeGUIDetails.image)
    image:SetTexturePixelCoordinates(unpack(moduleTypeGUIDetails.imageTexCoords))
    image:SetColor(Color(1, 1, 1, 1))
    image:SetOptionFlag(GUIItem.CorrectScaling)
    buttonGraphic:AddChild(image)
    
    local icon, cost
    if resourceCost > 0 then
        cost = self:CreateAnimatedTextItem()
        cost:SetIsScaling(false)
        cost:SetPosition(Vector(contentPaddingX + kResourceIconWidth, -contentPaddingY, 0))
        cost:SetFontName(kFont)
        cost:SetAnchor(GUIItem.Left, GUIItem.Bottom)
        cost:SetTextAlignmentX(GUIItem.Align_Min)
        cost:SetTextAlignmentY(GUIItem.Align_Max)
        cost:SetColor(kTextColor)
        cost:SetText(tostring(resourceCost))--(Locale.ResolveString("BUY"))
        cost:SetOptionFlag(GUIItem.CorrectScaling)
        GUIMakeFontScale(cost, "kAgencyFB", kFontSize)
        buttonGraphic:AddChild(cost)
        
        icon = self:CreateAnimatedGraphicItem()
        icon:SetIsScaling(false)
        icon:SetPosition(Vector(kResourceIconWidth * 0.7 - 6, -(kResourceIconHeight * 0.7 + 4 + contentPaddingY), 0))
        icon:SetSize(Vector(kResourceIconWidth * 0.7, kResourceIconHeight * 0.7, 0))
        icon:SetAnchor(GUIItem.Left, GUIItem.Bottom)
        icon:SetTexture(kResourceIconTexture)
        --local iconX, iconY = GetMaterialXYOffset(kTechId.PowerSurge)
        --powerIcon:SetTexturePixelCoordinates(iconX*80, iconY*80, iconX*80+80, iconY*80+80)
        icon:SetColor(kTextColor)
        icon:SetOptionFlag(GUIItem.CorrectScaling)
        buttonGraphic:AddChild(icon)
    end
    
    if vertical then
        offsetX = offsetX + kModuleButtonSize.x
    else
        offsetY = offsetY + kModuleButtonSize.y
    end
    
    table.insert(self.modularExoModuleButtonList, {
        slotType        = slotType,
        moduleType      = moduleType,
        buttonGraphic   = buttonGraphic,
        weaponLabel     = label,
        weaponImage     = image,
        costLabel       = cost,
        costIcon        = icon,
        thingsToRecolor = { label, image, cost, icon },
    })
    return buttonGraphic, offsetX, offsetY
end

function GUIMarineBuyMenu:_UpdateExoModularButtons(deltaTime)
    if self.hoveringExo then

        self:_RefreshExoModularButtons()
        -- local researched = self:_GetResearchInfo(kTechId.DualMinigunExosuit)
		local researched = self.hostStructure:GetTechId() == kTechId.AdvancedPrototypeLab
        if not researched or PlayerUI_GetPlayerResources() < self.exoConfigResourceCost - self.activeExoConfigResCost then
            self.modularExoBuyButton:SetColor(Color(1, 0, 0, 1))
            self.modularExoBuyButtonText:SetColor(Color(0.5, 0.5, 0.5, 1))
            self.modularExoCostText:SetColor(kCannotBuyColor)
            self.modularExoCostIcon:SetColor(kCannotBuyColor)
        else
            if GetIsMouseOver(self, self.modularExoBuyButton) then
                self.modularExoBuyButton:SetColor(kCloseButtonColorHover)
                self.modularExoCostText:SetColor(kCloseButtonColorHover)
                self.modularExoCostIcon:SetColor(kCloseButtonColorHover)
                self.modularExoBuyButtonText:SetColor(kCloseButtonColorHover)
            else
                self.modularExoBuyButton:SetColor(kCloseButtonColor)
                self.modularExoCostText:SetColor(kCloseButtonColor)
                self.modularExoCostIcon:SetColor(kCloseButtonColor)
                self.modularExoBuyButtonText:SetColor(kCloseButtonColor)
            end
            
            --self.modularExoBuyButtonText:SetColor(kCloseButtonColor)
            --self.modularExoCostText:SetColor(kTextColor)
            --self.modularExoCostIcon:SetColor(kTextColor)
        end
        for buttonI, buttonData in ipairs(self.modularExoModuleButtonList) do
            if GetIsMouseOver(self, buttonData.buttonGraphic) then
                if buttonData.state == "enabled" then
                    buttonData.buttonGraphic:SetColor(Color(0, 0.7, 1, 1))
                end
            else
                buttonData.buttonGraphic:SetColor(buttonData.col)
            end
        end
    end
end

function GUIMarineBuyMenu:_RefreshExoModularButtons()
    local _, _, resourceCost, _, _ = ModularExo_GetIsConfigValid(self.exoConfig)
    resourceCost = resourceCost or 0
    self.exoConfigResourceCost = resourceCost
    self.modularExoCostText:SetText(tostring(math.max(0,resourceCost - self.activeExoConfigResCost)))
    
    for buttonI, buttonData in ipairs(self.modularExoModuleButtonList) do
        local current = self.exoConfig[buttonData.slotType]
        local col = nil
        local canAfford = true
        if current == buttonData.moduleType then
            if PlayerUI_GetPlayerResources() < self.exoConfigResourceCost - self.activeExoConfigResCost then
                --buttonData.state = "disabled"
                -- buttonData.buttonGraphic:SetColor(kDisabledColor)
                col = kDisabledColor
                --canAfford = false
            else
                buttonData.state = "selected"
                buttonData.buttonGraphic:SetColor(kEnabledColor)
                col = kEnabledColor
            end
        else
            self.exoConfig[buttonData.slotType] = buttonData.moduleType
            local isValid, badReason, _, _, _ = ModularExo_GetIsConfigValid(self.exoConfig)
            
            if buttonData.slotType == kExoModuleSlots.RightArm and badReason == "bad model left" then
                isValid = true
                buttonData.forceLeftToClaw = true
            else
                buttonData.forceLeftToClaw = false
            end
			
            if isValid then
                buttonData.state = "enabled"
                buttonData.buttonGraphic:SetColor(kDisabledColor)
                col = kDisabledColor
            else
                buttonData.state = "disabled"
                buttonData.buttonGraphic:SetColor(kDisabledColor)
                col = kDisabledColor
                if badReason == "not enough power" then
                    canAfford = false
                end
            end
			
            if not isValid and (badReason == "bad model right" or badReason == "bad model left") then
                col = Color(0.2, 0.2, 0.2, 0.4)
                buttonData.weaponImage:SetColor(Color(0.2, 0.2, 0.2, 0.4))
            elseif buttonData.weaponImage ~= nil then
                buttonData.weaponImage:SetColor(Color(1, 1, 1, 1))
            end
			
            self.exoConfig[buttonData.slotType] = current
        end
        buttonData.col = col
        for thingI, thing in ipairs(buttonData.thingsToRecolor) do
            thing:SetColor(col)
        end
        if not canAfford then
            if buttonData.costLabel then
                buttonData.costLabel:SetColor(kCannotBuyColor)
            end
            if buttonData.costIcon then
                buttonData.costIcon:SetColor(kCannotBuyColor)
            end
        end
    end
end