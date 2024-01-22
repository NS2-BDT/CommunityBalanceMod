-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================

local newTechIds = {
    "UpgradeToAdvancedPrototypeLab",
    "AdvancedPrototypeLab",
    'ExosuitTech',
}

local removeTechIds = {
    'ExosuitTech',
}

for _,v in ipairs(removeTechIds) do
    EnumUtils.RemoveFromEnum(kTechId, v)
end

for _,v in ipairs(newTechIds) do
    EnumUtils.AppendToEnum(kTechId, v)
end
