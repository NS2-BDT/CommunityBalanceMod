-- ========= Community Balance Mod ===============================
--
-- "lua\bots\MarineCommanerBrain_TechPath.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


local kMarineCommanderTechPath =
{
    -- Tier 1 (Early Game)
    {
        kTechId.ArmsLab,
        kTechId.Armor1,
        kTechId.Armory,
    },

    -- Tier 2
    {
        -- Phase Tech
        kTechId.Observatory,
        kTechId.PhaseTech,

        kTechId.Weapons1,
        kTechId.PhaseGate,
        kTechId.MinesTech,
        kTechId.Armor2,
    },

    -- Tier 3
    {
        -- Auxillary stuff
        kTechId.ShotgunTech,
        kTechId.Weapons2,
        kTechId.GrenadeTech,
    },

    -- Tier 4
    {
        kTechId.AdvancedArmoryUpgrade, -- Flamethrower, GL, HMG all unlocked by this upgrade
        kTechId.PrototypeLab,
    },

    -- Tier 5
    {
        kTechId.JetpackTech,
        kTechId.UpgradeToAdvancedPrototypeLab, --Balance Mod
        --kTechId.ExosuitTech, --Balance Mod
        kTechId.AdvancedMarineSupport, -- Nanoshield, Powersurge, Catpack
        kTechId.Weapons3,
        kTechId.Armor3,
    },
}


local NewGetTechPath = debug.getupvaluex(GetMarineComNextTechStep, "GetTechPath")
debug.setupvaluex(NewGetTechPath, "kMarineCommanderTechPath", kMarineCommanderTechPath)

debug.setupvaluex(GetMarineComNextTechStep, "GetTechPath", NewGetTechPath)



local kTechTestReroutes =
{
    [kTechId.AdvancedArmoryUpgrade] = kTechId.AdvancedArmory,
    [kTechId.UpgradeToAdvancedPrototypeLab] = kTechId.AdvancedPrototypeLab --Balance Mod
}

local kBuildTechIdToSenseMap =
{
    [kTechId.ArmsLab]            = "mainArmsLab"           ,
    [kTechId.Armory]             = "mainArmory"            ,
    [kTechId.Observatory]        = "mainObservatory"       ,
    [kTechId.PhaseGate]          = "mainPhaseGate"         ,
    [kTechId.AdvancedArmory]     = "mainAdvancedArmory"    ,
    [kTechId.PrototypeLab]       = "mainPrototypeLab"      ,
    [kTechId.AdvancedPrototypeLab]= "mainAdvancedPrototypeLab", --Balance Mod
    --[kTechId.RoboticsFactory]    = "hasRoboticsFactoryInBase"   ,
    --[kTechId.ARCRoboticsFactory] = "hasARCRoboticsFactoryInBase",
}

local NewGetHasTechForMarineTechPath = debug.getupvaluex(GetMarineComNextTechStep, "GetHasTechForMarineTechPath")
debug.setupvaluex(NewGetHasTechForMarineTechPath, "kTechTestReroutes", kTechTestReroutes)
debug.setupvaluex(NewGetHasTechForMarineTechPath, "kBuildTechIdToSenseMap", kBuildTechIdToSenseMap)


debug.setupvaluex(GetMarineComNextTechStep, "GetHasTechForMarineTechPath", NewGetHasTechForMarineTechPath)
