-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================

local cloakMaxSpeed = 0.7 * kLerkMaxSpeed -- 9
function Lerk:GetSpeedScalar()
    return self:GetVelocity():GetLength() / cloakMaxSpeed
end