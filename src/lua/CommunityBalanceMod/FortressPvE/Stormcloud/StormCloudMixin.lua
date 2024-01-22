-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


function StormCloudMixin:ModifyMaxSpeed(maxSpeedTable)

    if self.stormed then 
        maxSpeedTable.maxSpeed = maxSpeedTable.maxSpeed * 1.2
    end
end
