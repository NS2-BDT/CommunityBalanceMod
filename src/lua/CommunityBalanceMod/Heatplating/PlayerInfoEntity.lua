--Insight upgrades bitmask table
local techUpgradesTable =
{
    kTechId.Jetpack,
    kTechId.Welder,
    kTechId.ClusterGrenade,
    kTechId.PulseGrenade,
    kTechId.GasGrenade,
    kTechId.Mine,

    kTechId.Vampirism,
    kTechId.Carapace,
    kTechId.Heatplating,
    kTechId.Regeneration,

    kTechId.Aura,
    kTechId.Focus,
    kTechId.Camouflage,

    kTechId.Celerity,
    kTechId.Adrenaline,
    kTechId.Crush,

    kTechId.Parasite,

    -- for compatibility with devnulls interesting postgame screen
    kTechId.DualMinigunExosuit, 
    kTechId.DualRailgunExosuit
}

local techUpgradesBitmask = CreateBitMask(techUpgradesTable)


-- for compatibility with devnulls enhanced scoreboard
local oldPlayerInfoEntityUpdateScore = debug.getupvaluex(PlayerInfoEntity.UpdateScore, "oldPlayerInfoEntityUpdateScore")
if oldPlayerInfoEntityUpdateScore then 
    debug.setupvaluex(oldPlayerInfoEntityUpdateScore, "techUpgradesBitmask", techUpgradesBitmask)
 end


debug.setupvaluex(GetTechIdsFromBitMask, "techUpgradesTable", techUpgradesTable)
debug.setupvaluex(PlayerInfoEntity.UpdateScore, "techUpgradesBitmask", techUpgradesBitmask)
debug.setupvaluex(GetTechIdsFromBitMask, "techUpgradesBitmask", techUpgradesBitmask)
