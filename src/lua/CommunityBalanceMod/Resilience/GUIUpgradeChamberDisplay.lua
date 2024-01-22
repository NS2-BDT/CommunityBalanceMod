-- ========= Community Balance Mod ===============================
--
-- "lua\GUIUpgradeChamberDisplay.lua"
--
--    Created by:   4sdfg, Drey (@drey3982)
--
-- ===============================================================

-- Original
--
-- local kIndexToUpgrades =
-- {
--     { kTechId.Spur, kTechId.Crush, kTechId.Celerity, kTechId.Adrenaline },
--     { kTechId.Veil, kTechId.Camouflage, kTechId.Aura, kTechId.Focus },
--     { kTechId.Shell, kTechId.Vampirism, kTechId.Carapace, kTechId.Regeneration },
-- }

local kIndexToUpgrades =
{
    { kTechId.Spur, kTechId.Crush, kTechId.Celerity, kTechId.Adrenaline },
    { kTechId.Veil, kTechId.Camouflage, kTechId.Aura, kTechId.Focus },
    { kTechId.Shell, kTechId.Vampirism, kTechId.Resilience, kTechId.Regeneration },
}

debug.setupvaluex(GUIUpgradeChamberDisplay.Update, "kIndexToUpgrades", kIndexToUpgrades)
