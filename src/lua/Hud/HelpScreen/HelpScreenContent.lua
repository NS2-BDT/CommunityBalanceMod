-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/Hud/HelpScreen/HelpScreenContent.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Contains all the content that can be displayed by the help screen.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local contentTable = {}

local function CreateContentCard(params)
    
    if not params.name or not params.title or not params.description or not params.classNames or #params.classNames == 0 then
        return false
    end
    
    local formatVals = {}
    if params.descriptionFormatValues then
        for key, value in pairs(params.descriptionFormatValues) do
            if type(value) == "function" then
                formatVals[key] = value()
            else
                formatVals[key] = value
            end
        end
    end
    
    local newContentTable = 
    {
        name = params.name,
        title = params.title,
        requirementFunction = params.requirementFunction,
        description = params.description,
        descriptionFormatValues = formatVals,
        imagePath = params.imagePath,
        actions = params.actions,
        classNames = params.classNames,
        theme = params.theme,
        skipCards = params.skipCards,
        hideIfLocked = params.hideIfLocked or false,
        locale = params.useLocale or false,
    }
    
    return true, newContentTable
    
end

-- name                     - string        - name to refer to this tile by in code.  Used to store whether or not the
--                                              player has seen this tip-card or not yet. (hint-key will appear/flash
--                                              if there are un-viewed cards).
-- title                    - string        - the large, bold text that appears on the card.
-- requirementFunction      - function      - function that returns a boolean, a string, and a table of format
--                                              arguments.  The boolean says whether or not the ability is unlocked,
--                                              the string is the text to display, and the table contains the arguments
--                                              for the string formatting, if applicable (can be nil).  The text color
--                                              is dependent upon the unlock state.
-- description              - string        - the text that appears in the description box.
-- descriptionFormatValues  - table         - if the description string uses string formatting, you can provide
--                                              the values here, either as literals, variables, or even function
--                                              calls.  Just note that it is assumed these are constants -- the
--                                              values are retrieved when this function is called, not when they
--                                              are displayed.
-- imagePath                - string        - the file path of the icon to use in this box.
-- actions                  - table         - a list of actions associated with the ability.  Each item is a table
--                                              containing actions that activate the ability.  Most of the time, these
--                                              tables will be only 1-element.  Example: for the welder, we display
--                                              both the binding for slot3, and the binding for primary attack.  They
--                                              will display from left to right in the order they are provided,
--                                              separated by a "+" sign.  The entries for primary attack and slot3 lie
--                                              in their own tables, as they each represent a different functionality.  
--                                              Example 2: for exosuit thrusters, we want to display the binding for
--                                              jump and the binding for movement modifier, as these both activate
--                                              thrusters (though with slightly different purposes that we'll group
--                                              together for this card).  Since they serve the same purpose, we'll
--                                              group both of these together within the same table.  The will display 
--                                              separated by a "/" sign.
-- classNames               - index table   - list of classes or child classes (eg weapons) that the player must
--                                              be/have for this card to appear.
-- theme                    - string        - "marine" or "alien"
-- skipCards                - table/nil     - a list of all the card names that, if present, cause this card to not
--                                              appear.  When cards are added, they are evaluated one-by-one, in the
--                                              order they are declared.  For example, advanced metabolize and
--                                              metabolize are technically two separate abilities, but adv. metab.
--                                              overrides metab. once researched.  We declare Adv. metab before metab,
--                                              and make note in metab. that adv. metab overrides it.
-- hideIfLocked             - boolean       - if true, card will not be displayed unless all unlock requirements are
--                                              met.
function HelpScreen_AddContent(params)
    
    if contentTable[params.name] then
        Log("ERROR:  Content named \"%s\" already exists!  To replace/modify existing content, use HelpScreen_ReplaceContent()", params.name)
        return
    end
    
    local result, content = CreateContentCard(params)
    
    if result == false then
        Log("ERROR:  Invalid parameters passed to HelpScreen_AddContent()")
        Log("Required parameters:")
        Log("    name = %s", params.name)
        Log("    title = %s", params.title)
        Log("    description = %s", params.description)
        Log("    classNames = %s", params.classNames)
        Log("Optional parameters:")
        Log("    actions = %s", params.actions)
        Log("    requirementFunction = %s", params.requirementFunction)
        Log("    descriptionFormatValues = %s", params.descriptionFormatValues)
        Log("    imagePath = %s", params.imagePath)
        Log("    theme = %s", params.theme)
        Log("    skipCards = %s", params.skipCards)
        Log("    hideIfLocked = %s", params.hideIfLocked)
        Log("    useLocale = %s", params.useLocale)
        return
    end
    
    assert(content)
    
    contentTable[params.name] = #contentTable + 1
    contentTable[#contentTable + 1] = content
    
end

-- Can be used to modify existing content.
function HelpScreen_ReplaceContent(params)
    
    if not contentTable[params.name] then
        Log("ERROR:  No content named \"%s\" was found!  To add new content, use HelpScreen_AddContent()", params.name)
        return
    end
    
    local result, content = CreateContentCard(params)
    
    if result == false then
        Log("ERROR:  Invalid parameters passed to HelpScreen_ReplaceContent()")
        Log("Required parameters:")
        Log("    name = %s", params.name)
        Log("    title = %s", params.title)
        Log("    description = %s", params.description)
        Log("    classNames = %s", params.classNames)
        Log("Optional parameters:")
        Log("    actions = %s", params.actions)
        Log("    requirementFunction = %s", params.requirementFunction)
        Log("    descriptionFormatValues = %s", params.descriptionFormatValues)
        Log("    imagePath = %s", params.imagePath)
        Log("    theme = %s", params.theme)
        Log("    skipCards = %s", params.skipCards)
        Log("    hideIfLocked = %s", params.hideIfLocked)
        Log("    useLocale = %s", params.useLocale)
        return
    end
    
    assert(content)
    
    contentTable[contentTable[params.name]] = content
    
end

function HelpScreen_GetContentTable()
    
    -- might need to be moved elsewhere if this proves to be too much to process at once.
    if #contentTable == 0 then
        HelpScreen_InitializeContent()
    end
    
    return contentTable
end

local kBioMassLevelToHelpText = 
{
    [1] =   "",
    [2] =   "HELP_SCREEN_BIOMASS_REQUIREMENT_2",
    [3] =   "HELP_SCREEN_BIOMASS_REQUIREMENT_3",
    [4] =   "HELP_SCREEN_BIOMASS_REQUIREMENT_4",
    [5] =   "HELP_SCREEN_BIOMASS_REQUIREMENT_5",
    [6] =   "HELP_SCREEN_BIOMASS_REQUIREMENT_6",
    [7] =   "HELP_SCREEN_BIOMASS_REQUIREMENT_7",
    [8] =   "HELP_SCREEN_BIOMASS_REQUIREMENT_8",
    [9] =   "HELP_SCREEN_BIOMASS_REQUIREMENT_9",
	[10] =  "HELP_SCREEN_BIOMASS_REQUIREMENT_10",
}
-- returns the biomass level required by this ability, or nil if it does not require biomass.
local function GetRequiresBiomass(techId)
    
    local techTree = GetTechTree(Client.GetLocalPlayer():GetTeamNumber())
    if not techTree then
        return nil
    end
    
    local techNode = techTree:GetTechNode(techId)
    if not techNode then
        return nil
    end
    
    local level_1 = techNode:GetPrereq1()
    local level_2 = techNode:GetPrereq2()
    
    if level_1 == kTechId.None then
        level_1 = nil
    else
        level_1 = kTechToBiomassLevel[level_1]
    end
    
    if level_2 == kTechId.None then
        level_2 = nil
    else
        level_2 = kTechToBiomassLevel[level_2]
    end
    
    if level_1 == nil and level_2 == nil then
        return nil
    else
        local level = 0
        if level_1 ~= nil then
            level = level_1
        end
        
        if level_2 ~= nil then
            level = math.max(level, level_2)
        end
        
        return level
    end
    
end

local helpScreenImages = 
{
    rifle               = PrecacheAsset("ui/helpScreen/icons/rifle.dds"),
    rifleButt           = PrecacheAsset("ui/helpScreen/icons/rifle_butt.dds"),
    pistol              = PrecacheAsset("ui/helpScreen/icons/pistol.dds"),
    axe                 = PrecacheAsset("ui/helpScreen/icons/axe.dds"),
    welder              = PrecacheAsset("ui/helpScreen/icons/welder.dds"),
    shotgun             = PrecacheAsset("ui/helpScreen/icons/shotgun.dds"),
    mines               = PrecacheAsset("ui/helpScreen/icons/mine.dds"),
    flamethrower        = PrecacheAsset("ui/helpScreen/icons/flamethrower.dds"),
    grenadeLauncher     = PrecacheAsset("ui/helpScreen/icons/grenade_launcher.dds"),
    machineGun          = PrecacheAsset("ui/helpScreen/icons/machine_gun.dds"),
    clusterGrenade      = PrecacheAsset("ui/helpScreen/icons/grenade_cluster.dds"),
    pulseGrenade        = PrecacheAsset("ui/helpScreen/icons/grenade_pulse.dds"),
    gasGrenade          = PrecacheAsset("ui/helpScreen/icons/grenade_gas.dds"),
    minigun             = PrecacheAsset("ui/helpScreen/icons/mini_gun.dds"),
    railgun             = PrecacheAsset("ui/helpScreen/icons/rail_gun.dds"),
    exoThrusters        = PrecacheAsset("ui/helpScreen/icons/thrusters.dds"),
    exoEject            = PrecacheAsset("ui/helpScreen/icons/exo_eject.dds"),
    eggStomp            = PrecacheAsset("ui/helpScreen/icons/egg_stomp.dds"),
    jetpack             = PrecacheAsset("ui/helpScreen/icons/jetpack.dds"),
    bite                = PrecacheAsset("ui/helpScreen/icons/bite.dds"),
    parasite            = PrecacheAsset("ui/helpScreen/icons/parasite.dds"),
    leap                = PrecacheAsset("ui/helpScreen/icons/leap.dds"),
    xenocide            = PrecacheAsset("ui/helpScreen/icons/xenocide.dds"),
    healSpray           = PrecacheAsset("ui/helpScreen/icons/heal_spray.dds"),
    spit                = PrecacheAsset("ui/helpScreen/icons/spit.dds"),
    gorgeStructures     = PrecacheAsset("ui/helpScreen/icons/gorge_structures.dds"),
    bileBomb            = PrecacheAsset("ui/helpScreen/icons/bile_bomb.dds"),
    baitBall            = PrecacheAsset("ui/helpScreen/icons/bait_ball.dds"),
    lerkBite            = PrecacheAsset("ui/helpScreen/icons/lerk_bite.dds"),
    spikes              = PrecacheAsset("ui/helpScreen/icons/spikes.dds"),
    umbra               = PrecacheAsset("ui/helpScreen/icons/umbra.dds"),
    spores              = PrecacheAsset("ui/helpScreen/icons/spores.dds"),
    swipe               = PrecacheAsset("ui/helpScreen/icons/swipe.dds"),
    blink               = PrecacheAsset("ui/helpScreen/icons/blink.dds"),
    advancedMetabolize  = PrecacheAsset("ui/helpScreen/icons/advanced_metabolize.dds"),
    metabolize          = PrecacheAsset("ui/helpScreen/icons/metabolize.dds"),
    stab                = PrecacheAsset("ui/helpScreen/icons/stab.dds"),
    gore                = PrecacheAsset("ui/helpScreen/icons/gore.dds"),
    charge              = PrecacheAsset("ui/helpScreen/icons/charge.dds"),
    boneShield          = PrecacheAsset("ui/helpScreen/icons/bone_shield.dds"),
    stomp               = PrecacheAsset("ui/helpScreen/icons/stomp.dds"),
}

local function EvaluateTechAvailability(techId, requirementMessage)
    
    local player = Client.GetLocalPlayer()
    if GetIsTechUnlocked(player, techId) then
        return true, ""
    else
        local biomassRequirement = GetRequiresBiomass(techId)
        
        if biomassRequirement == nil then
            return false, requirementMessage
        end
        
        local techId = kTechToBiomassLevel[biomassRequirement]
        local techTree = GetTechTree()
        local techNode = techTree:GetTechNode(techId)
        if techNode:GetHasTech() then
            return false, requirementMessage
        else
            return false, kBioMassLevelToHelpText[biomassRequirement]
        end
    end
    
end

-- Populates the content table with all the build in NS2 content.
-- MODDERS:  Hook into this function to add your own help screen content! :D
function HelpScreen_InitializeContent()
    
    -- MARINE STUFF --
    -- Rifle
    HelpScreen_AddContent({
        name = "Rifle",
        title = "HELP_SCREEN_RIFLE",
        description = "HELP_SCREEN_RIFLE_DESCRIPTION",
        imagePath = helpScreenImages.rifle,
        actions = {
            {"Weapon1",},
            {"PrimaryAttack"},
        },
        classNames = {"Rifle"},
        theme = "marine",
        useLocale = true,
        })
    
    -- Rifle Butt
    HelpScreen_AddContent({
        name = "RifleButt",
        title = "HELP_SCREEN_RIFLE_BUTT",
        description = "HELP_SCREEN_RIFLE_BUTT_DESCRIPTION",
        imagePath = helpScreenImages.rifleButt,
        actions = {
            {"Weapon1",},
            {"SecondaryAttack",},
        },
        classNames = {"Rifle"},
        theme = "marine",
        useLocale = true,
        })
    
    -- Shotgun
    HelpScreen_AddContent({
        name = "Shotgun",
        title = "HELP_SCREEN_SHOTGUN",
        description = "HELP_SCREEN_SHOTGUN_DESCRIPTION",
        imagePath = helpScreenImages.shotgun,
        actions = {
            {"Weapon1",},
            {"PrimaryAttack"},
        },
        classNames = {"Shotgun"},
        theme = "marine",
        useLocale = true,
        })
    
    -- Flamethrower
    HelpScreen_AddContent({
        name = "Flamethrower",
        title = "HELP_SCREEN_FLAMETHROWER",
        description = "HELP_SCREEN_FLAMETHROWER_DESCRIPTION",
        imagePath = helpScreenImages.flamethrower,
        actions = {
            {"Weapon1",},
            {"PrimaryAttack"},
        },
        classNames = {"Flamethrower"},
        theme = "marine",
        useLocale = true,
        })
    
    -- Grenade Launcher
    HelpScreen_AddContent({
        name = "GrenadeLauncher",
        title = "HELP_SCREEN_GRENADE_LAUNCHER",
        description = "HELP_SCREEN_GRENADE_LAUNCHER_DESCRIPTION",
        imagePath = helpScreenImages.grenadeLauncher,
        actions = {
            {"Weapon1",},
            {"PrimaryAttack"},
        },
        classNames = {"GrenadeLauncher"},
        theme = "marine",
        useLocale = true,
        })
    
    -- Machine Gun
    HelpScreen_AddContent({
        name = "MachineGun",
        title = "HELP_SCREEN_MACHINE_GUN",
        description = "HELP_SCREEN_MACHINE_GUN_DESCRIPTION",
        imagePath = helpScreenImages.machineGun,
        actions = {
            {"Weapon1",},
            {"PrimaryAttack"},
        },
        classNames = {"HeavyMachineGun"},
        theme = "marine",
        useLocale = true,
        })
    
    -- Pistol
    HelpScreen_AddContent({
        name = "Pistol",
        title = "HELP_SCREEN_PISTOL",
        description = "HELP_SCREEN_PISTOL_DESCRIPTION",
        imagePath = helpScreenImages.pistol,
        actions = {
            {"Weapon2",},
            {"PrimaryAttack"},
        },
        classNames = {"Pistol"},
        theme = "marine",
        useLocale = true,
        })
    
    -- Axe
    HelpScreen_AddContent({
        name = "Axe",
        title = "HELP_SCREEN_AXE",
        description = "HELP_SCREEN_AXE_DESCRIPTION",
        imagePath = helpScreenImages.axe,
        actions = {
            {"Weapon3",},
            {"PrimaryAttack"},
        },
        classNames = {"Axe"},
        theme = "marine",
        useLocale = true,
        })
    
    -- Welder
    HelpScreen_AddContent({
        name = "Welder",
        title = "HELP_SCREEN_WELDER",
        description = "HELP_SCREEN_WELDER_DESCRIPTION",
        imagePath = helpScreenImages.welder,
        actions = {
            {"Weapon3",},
            {"PrimaryAttack"},
        },
        classNames = {"Welder"},
        theme = "marine",
        useLocale = true,
        })
    
    -- Mines
    HelpScreen_AddContent({
        name = "Mines",
        title = "HELP_SCREEN_MINES",
        description = "HELP_SCREEN_MINES_DESCRIPTION",
        imagePath = helpScreenImages.mines,
        actions = {
            {"Weapon4",},
            {"PrimaryAttack"},
        },
        classNames = {"LayMines"},
        theme = "marine",
        useLocale = true,
        })
    
    -- Cluster Grenade
    HelpScreen_AddContent({
        name = "ClusterGrenade",
        title = "HELP_SCREEN_CLUSTER_GRENADE",
        description = "HELP_SCREEN_CLUSTER_GRENADE_DESCRIPTION",
        imagePath = helpScreenImages.clusterGrenade,
        actions = {
            {"Weapon5",},
            {"PrimaryAttack"},
        },
        classNames = {"ClusterGrenadeThrower"},
        theme = "marine",
        useLocale = true,
        })
    
    -- Pulse Grenade
    HelpScreen_AddContent({
        name = "PulseGrenade",
        title = "HELP_SCREEN_PULSE_GRENADE",
        description = "HELP_SCREEN_PULSE_GRENADE_DESCRIPTION",
        imagePath = helpScreenImages.pulseGrenade,
        actions = {
            {"Weapon5",},
            {"PrimaryAttack"},
        },
        classNames = {"PulseGrenadeThrower"},
        theme = "marine",
        useLocale = true,
        })
    
    -- Nerve Gas Grenade
    HelpScreen_AddContent({
        name = "GasGrenade",
        title = "HELP_SCREEN_GAS_GRENADE",
        description = "HELP_SCREEN_GAS_GRENADE_DESCRIPTION",
        imagePath = helpScreenImages.gasGrenade,
        actions = {
            {"Weapon5",},
            {"PrimaryAttack"},
        },
        classNames = {"GasGrenadeThrower"},
        theme = "marine",
        useLocale = true,
        })
    
    -- Exosuit Minigun
    HelpScreen_AddContent({
        name = "ExoMinigun",
        title = "HELP_SCREEN_EXO_MINIGUN",
        description = "HELP_SCREEN_EXO_MINIGUN_DESCRIPTION",
        imagePath = helpScreenImages.minigun,
        actions = {
            {"PrimaryAttack", "SecondaryAttack"},
        },
        classNames = {"Minigun"},
        theme = "marine",
        useLocale = true,
        })
    
    -- Exosuit Railgun
    HelpScreen_AddContent({
        name = "ExoRailgun",
        title = "HELP_SCREEN_EXO_RAILGUN",
        description = "HELP_SCREEN_EXO_RAILGUN_DESCRIPTION",
        imagePath = helpScreenImages.railgun,
        actions = {
            {"PrimaryAttack", "SecondaryAttack"},
        },
        classNames = {"Railgun"},
        theme = "marine",
        useLocale = true,
        })
        
    -- Exosuit Thrusters
    HelpScreen_AddContent({
        name = "ExoThrusters",
        title = "HELP_SCREEN_EXO_THRUSTERS",
        description = "HELP_SCREEN_EXO_THRUSTERS_DESCRIPTION",
        imagePath = helpScreenImages.exoThrusters,
        actions = {
            { "MovementModifier", "Jump" },
        },
        classNames = {"Exo"},
        theme = "marine",
        useLocale = true,
        })
    
    -- Exosuit Eject
    HelpScreen_AddContent({
        name = "ExoEject",
        title = "HELP_SCREEN_EXO_EJECT",
        description = "HELP_SCREEN_EXO_EJECT_DESCRIPTION",
        descriptionFormatValues = { unlockTime = kItemStayTime },
        imagePath = helpScreenImages.exoEject,
        actions = {
            { "Drop" },
        },
        classNames = {"Exo"},
        theme = "marine",
        useLocale = true,
        })
    
    -- Egg Stomp
    HelpScreen_AddContent({
        name = "ExoEggStomp",
        title = "HELP_SCREEN_EXO_EGG_STOMP",
        description = "HELP_SCREEN_EXO_EGG_STOMP_DESCRIPTION",
        imagePath = helpScreenImages.eggStomp,
        actions = {},
        classNames = {"Exo"},
        theme = "marine",
        useLocale = true,
        })
    
    -- Jetpack
    HelpScreen_AddContent({
        name = "Jetpack",
        title = "HELP_SCREEN_JETPACK",
        description = "HELP_SCREEN_JETPACK_DESCRIPTION",
        imagePath = helpScreenImages.jetpack,
        actions = {
            { "Jump" },
        },
        classNames = {"JetpackMarine"},
        theme = "marine",
        useLocale = true,
        })
    
    
    -- ALIEN STUFF --
    -- Skulk
    -- Bite
    HelpScreen_AddContent({
        name = "SkulkBite",
        title = "HELP_SCREEN_BITE",
        description = "HELP_SCREEN_SKULK_BITE_DESCRIPTION",
        imagePath = helpScreenImages.bite,
        actions = {
            { "Weapon1", },
            { "PrimaryAttack", },
        },
        classNames = {"Skulk"},
        theme = "alien",
        useLocale = true,
        })
    
    -- Parasite
    HelpScreen_AddContent({
        name = "Parasite",
        title = "HELP_SCREEN_PARASITE",
        description = "HELP_SCREEN_PARASITE_DESCRIPTION",
        imagePath = helpScreenImages.parasite,
        actions = {
            { "Weapon2", },
            { "PrimaryAttack", },
        },
        classNames = {"Skulk"},
        theme = "alien",
        useLocale = true,
        })
    
    -- Leap
    HelpScreen_AddContent({
        name = "Leap",
        title = "HELP_SCREEN_LEAP",
        requirementFunction = function()
            local result, msg = EvaluateTechAvailability(kTechId.Leap, "HELP_SCREEN_LEAP_REQUIREMENT")
            return result, msg
        end,
        description = "HELP_SCREEN_LEAP_DESCRIPTION",
        imagePath = helpScreenImages.leap,
        actions = {
            { "SecondaryAttack", },
        },
        classNames = {"Skulk"},
        theme = "alien",
        useLocale = true,
        })
    
    -- Xenocide
    HelpScreen_AddContent({
        name = "Xenocide",
        title = "HELP_SCREEN_XENOCIDE",
        requirementFunction = function()
            local result, msg = EvaluateTechAvailability(kTechId.Xenocide, "HELP_SCREEN_XENOCIDE_REQUIREMENT")
            return result, msg
        end,
        description = "HELP_SCREEN_XENOCIDE_DESCRIPTION",
        imagePath = helpScreenImages.xenocide,
        actions = {
            { "Weapon3", },
            { "PrimaryAttack", },
        },
        classNames = {"Skulk"},
        theme = "alien",
        useLocale = true,
        })
    
    -- Gorge
    -- Heal Spray
    HelpScreen_AddContent({
        name = "HealSpray",
        title = "HELP_SCREEN_HEAL_SPRAY",
        description = "HELP_SCREEN_HEAL_SPRAY_DESCRIPTION",
        imagePath = helpScreenImages.healSpray,
        actions = {
            { "SecondaryAttack", },
        },
        classNames = {"Gorge"},
        theme = "alien",
        useLocale = true,
        })
    
    -- Spit
    HelpScreen_AddContent({
        name = "Spit",
        title = "HELP_SCREEN_SPIT",
        description = "HELP_SCREEN_SPIT_DESCRIPTION",
        imagePath = helpScreenImages.spit,
        actions = {
            { "Weapon1", },
            { "PrimaryAttack", },
        },
        classNames = {"Gorge"},
        theme = "alien",
        useLocale = true,
        })
    
    -- Gorge structures
    HelpScreen_AddContent({
        name = "GorgeStructures",
        title = "HELP_SCREEN_GORGE_STRUCTURES",
        description = "HELP_SCREEN_GORGE_STRUCTURES_DESCRIPTION",
        imagePath = helpScreenImages.gorgeStructures,
        actions = {
            { "Weapon2", },
        },
        classNames = {"Gorge"},
        theme = "alien",
        useLocale = true,
        })
    
    -- Bile Bomb
    HelpScreen_AddContent({
        name = "BileBomb",
        title = "HELP_SCREEN_BILE_BOMB",
        requirementFunction = function()
            local result, msg = EvaluateTechAvailability(kTechId.BileBomb, "HELP_SCREEN_BILE_BOMB_REQUIREMENT")
            return result, msg
        end,
        description = "HELP_SCREEN_BILE_BOMB_DESCRIPTION",
        imagePath = helpScreenImages.bileBomb,
        actions = {
            { "Weapon3", },
            { "PrimaryAttack", },
        },
        classNames = {"Gorge"},
        theme = "alien",
        useLocale = true,
        })
    
    -- Bait Ball
    HelpScreen_AddContent({
        name = "BaitBall",
        title = "HELP_SCREEN_BAIT_BALL",
        description = "HELP_SCREEN_BAIT_BALL_DESCRIPTION",
        imagePath = helpScreenImages.baitBall,
        actions = {
            { "Weapon4", },
            { "PrimaryAttack", },
        },
        classNames = {"Gorge"},
        theme = "alien",
        useLocale = true,
        })
    
    -- Lerk
    -- Lerk Bite
    HelpScreen_AddContent({
        name = "LerkBite",
        title = "HELP_SCREEN_BITE",
        description = "HELP_SCREEN_LERK_BITE_DESCRIPTION",
        imagePath = helpScreenImages.lerkBite,
        actions = {
            { "Weapon1", },
            { "PrimaryAttack", },
        },
        classNames = {"Lerk"},
        theme = "alien",
        useLocale = true,
        })
    
    -- Spikes
    HelpScreen_AddContent({
        name = "Spikes",
        title = "HELP_SCREEN_SPIKES",
        description = "HELP_SCREEN_SPIKES_DESCRIPTION",
        imagePath = helpScreenImages.spikes,
        actions = {
            { "SecondaryAttack", },
        },
        classNames = {"Lerk"},
        theme = "alien",
        useLocale = true,
        })
    
    -- Spores
    HelpScreen_AddContent({
        name = "Spores",
        title = "HELP_SCREEN_SPORES",
        requirementFunction = function()
            local result, msg = EvaluateTechAvailability(kTechId.Spores, "HELP_SCREEN_SPORES_REQUIREMENT")
            return result, msg
        end,
        description = "HELP_SCREEN_SPORES_DESCRIPTION",
        imagePath = helpScreenImages.spores,
        actions = {
            { "Weapon3", },
            { "PrimaryAttack", },
        },
        classNames = {"Lerk"},
        theme = "alien",
        useLocale = true,
        })
    
    -- Umbra
    HelpScreen_AddContent({
        name = "Umbra",
        title = "HELP_SCREEN_UMBRA",
        requirementFunction = function()
            local result, msg = EvaluateTechAvailability(kTechId.Umbra, "HELP_SCREEN_UMBRA_REQUIREMENT")
            return result, msg
        end,
        description = "HELP_SCREEN_UMBRA_DESCRIPTION",
        imagePath = helpScreenImages.umbra,
        actions = {
            { "Weapon2", },
            { "PrimaryAttack", },
        },
        classNames = {"Lerk"},
        theme = "alien",
        useLocale = true,
        })
    
    -- Fade
    -- Swipe
    HelpScreen_AddContent({
        name = "Swipe",
        title = "HELP_SCREEN_SWIPE",
        description = "HELP_SCREEN_SWIPE_DESCRIPTION",
        imagePath = helpScreenImages.swipe,
        actions = {
            { "Weapon1", },
            { "PrimaryAttack", },
        },
        classNames = {"Fade"},
        theme = "alien",
        useLocale = true,
        })
    
    -- Blink
    HelpScreen_AddContent({
        name = "Blink",
        title = "HELP_SCREEN_BLINK",
        description = "HELP_SCREEN_BLINK_DESCRIPTION",
        imagePath = helpScreenImages.blink,
        actions = {
            { "SecondaryAttack", },
        },
        classNames = {"Fade"},
        theme = "alien",
        useLocale = true,
        })
    
    -- Advanced Metabolize
    HelpScreen_AddContent({
        name = "AdvancedMetabolize",
        title = "HELP_SCREEN_METABOLIZE_ADV",
        requirementFunction = function()
            local result, msg = EvaluateTechAvailability(kTechId.MetabolizeHealth, "HELP_SCREEN_METABOLIZE_ADV_REQUIREMENT")
            return result, msg
        end,
        description = "HELP_SCREEN_METABOLIZE_ADV_DESCRIPTION",
        imagePath = helpScreenImages.advancedMetabolize,
        actions = {
            { "MovementModifier", },
        },
        classNames = {"Fade"},
        theme = "alien",
        hideIfLocked = true,
        useLocale = true,
        })
    
    -- Metabolize
    HelpScreen_AddContent({
        name = "Metabolize",
        title = "HELP_SCREEN_METABOLIZE",
        requirementFunction = function()
            local result, msg = EvaluateTechAvailability(kTechId.MetabolizeEnergy, "HELP_SCREEN_METABOLIZE_REQUIREMENT")
            return result, msg
        end,
        description = "HELP_SCREEN_METABOLIZE_DESCRIPTION",
        imagePath = helpScreenImages.metabolize,
        actions = {
            { "MovementModifier", },
        },
        classNames = {"Fade"},
        theme = "alien",
        skipCards = {"AdvancedMetabolize"},
        useLocale = true,
        })
    
    -- Stab
    HelpScreen_AddContent({
        name = "Stab",
        title = "HELP_SCREEN_STAB",
        requirementFunction = function()
            local result, msg = EvaluateTechAvailability(kTechId.Stab, "HELP_SCREEN_STAB_REQUIREMENT")
            return result, msg
        end,
        description = "HELP_SCREEN_STAB_DESCRIPTION",
        imagePath = helpScreenImages.stab,
        actions = {
            { "Weapon3", },
            { "PrimaryAttack", },
        },
        classNames = {"Fade"},
        theme = "alien",
        useLocale = true,
        })
    
    -- Onos
    -- Gore
    HelpScreen_AddContent({
        name = "Gore",
        title = "HELP_SCREEN_GORE",
        description = "HELP_SCREEN_GORE_DESCRIPTION",
        imagePath = helpScreenImages.gore,
        actions = {
            { "Weapon1", },
            { "PrimaryAttack", },
        },
        classNames = {"Onos"},
        theme = "alien",
        useLocale = true,
        })
    
    -- Charge
    HelpScreen_AddContent({
        name = "ChargeStampede", -- change name from "charge" so the new info key appears for stampede.
        --name = "Charge", -- leave old value here, commented out for history's sake.
        title = "HELP_SCREEN_CHARGE",
        requirementFunction = function()
            local result, msg = EvaluateTechAvailability(kTechId.Charge, "HELP_SCREEN_CHARGE_REQUIREMENT")
            return result, msg
        end,
        description = "HELP_SCREEN_CHARGE_DESCRIPTION",
        imagePath = helpScreenImages.charge,
        actions = {
            { "MovementModifier", },
        },
        classNames = {"Onos"},
        theme = "alien",
        useLocale = true,
        })
    
    -- Bone Shield
    HelpScreen_AddContent({
        name = "BoneShield_V2", -- add "_V2" so it pops up for people again.  May need to add a highlight in future...
        title = "HELP_SCREEN_BONE_SHIELD",
        requirementFunction = function()
            local result, msg = EvaluateTechAvailability(kTechId.BoneShield, "HELP_SCREEN_BONE_SHIELD_REQUIREMENT")
            return result, msg
        end,
        description = "HELP_SCREEN_BONE_SHIELD_DESCRIPTION",
        imagePath = helpScreenImages.boneShield,
        actions = {
            { "Weapon2", },
            { "PrimaryAttack", },
        },
        classNames = {"Onos"},
        theme = "alien",
        useLocale = true,
        })
    
    -- Stomp
    HelpScreen_AddContent({
        name = "Stomp",
        title = "HELP_SCREEN_STOMP",
        requirementFunction = function()
            local result, msg = EvaluateTechAvailability(kTechId.Stomp, "HELP_SCREEN_STOMP_REQUIREMENT")
            return result, msg
        end,
        description = "HELP_SCREEN_STOMP_DESCRIPTION",
        imagePath = helpScreenImages.stomp,
        actions = {
            { "SecondaryAttack", },
        },
        classNames = {"Onos"},
        theme = "alien",
        useLocale = true,
        })
    
end


