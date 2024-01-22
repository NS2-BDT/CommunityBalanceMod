-- ========= Community Balance Mod ===============================
--
-- "lua\TechTreeConstants.lua"
--
--    Created by:   Twiliteblue, Drey (@drey3982)
--
-- ===============================================================

local newTechIds = {
   
    'CloakingHaze'
}

local removeTechIds = {
}

for _,v in ipairs(removeTechIds) do
    EnumUtils.RemoveFromEnum(kTechId, v)
end

for _,v in ipairs(newTechIds) do
    EnumUtils.AppendToEnum(kTechId, v)
end
