-- ========= Community Balance Mod ===============================
--
--  "lua\Cyst_Server.lua"
--
--    Created by:   Twiliteblue, Drey (@drey3982)
--
-- ===============================================================

function Cyst:ScanForNearbyEnemy()

    --self.lastDetectedTime = self.lastDetectedTime or 0
    --if self.lastDetectedTime + kDetectInterval < Shared.GetTime() then

        local done = false

        -- Check shades in range, and stop if a shade is in range and is cloaked.
        if not done then
            for _, shade in ipairs(GetEntitiesForTeamWithinRange("Shade", self:GetTeamNumber(), self:GetOrigin(), Shade.kCloakRadius)) do
                if shade:GetIsCloaked() then
                    done = true
                    break
                end
            end
        end

        -- Finally check if the cysts have players in range.
        if not done and #GetEntitiesForTeamWithinRange("Player", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kCystDetectRange) > 0 then
            self:TriggerUncloak(true, 1.8) -- uncloak for 1.8 seconds
            done = true
        end

        --self.lastDetectedTime = Shared.GetTime()
    --end

    return self:GetIsAlive()
end
