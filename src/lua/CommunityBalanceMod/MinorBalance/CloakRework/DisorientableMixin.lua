-- ========= Community Balance Mod ===============================
--
--  "lua\DisorientableMixin.lua"
--
--    Created by:   Twiliteblue, Drey (@drey3982)
--
-- ===============================================================


local kUpdateInterval = 0.25 -- 0.5
debug.setupvaluex(DisorientableMixin.__initmixin, kUpdateInterval)

local UpdateDisorient = debug.getupvaluex(DisorientableMixin.__initmixin, "UpdateDisorient")
local kDisorientIntensity = 1.2 -- 4
debug.setupvaluex(UpdateDisorient, kDisorientIntensity)
debug.setupvaluex(DisorientableMixin.__initmixin, UpdateDisorient)
