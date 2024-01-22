-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================



local kResetDetectionInterval = 0.5 -- 1.5
local DisableDetected = debug.getupvaluex(DetectableMixin.__initmixin, "DisableDetected")
debug.setupvaluex(DisableDetected, "kResetDetectionInterval", kResetDetectionInterval)
debug.setupvaluex(DetectableMixin.__initmixin, "kResetDetectionInterval", kResetDetectionInterval)
debug.setupvaluex(DetectableMixin.__initmixin, "DisableDetected", DisableDetected)

local kDetectEffectInterval = 0.5 -- 3
debug.setupvaluex(DetectableMixin.OnUpdateRender, "kDetectEffectInterval", kDetectEffectInterval)
