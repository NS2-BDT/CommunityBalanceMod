-- ========= Community Balance Mod ===============================
--
-- "lua\CommandStation_Server.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


local oldCommandStructureOnEntityChange= CommandStructure.OnEntityChange
function CommandStation:OnEntityChange(oldEntityId, _)
    oldCommandStructureOnEntityChange(self, oldEntityId, _)

    if HasMixin(self, "MapBlip") then 
         self:MarkBlipDirty()
    end

end