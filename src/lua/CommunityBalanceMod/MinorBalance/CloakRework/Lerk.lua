-- ========= Community Balance Mod ===============================
--
--  "lua\Lerk.lua"
--
--    Created by:   Twiliteblue, Drey (@drey3982)
--
-- ===============================================================

local cloakMaxSpeed = 0.7 * kLerkMaxSpeed -- 9
function Lerk:GetSpeedScalar()
    return self:GetVelocity():GetLength() / cloakMaxSpeed
end