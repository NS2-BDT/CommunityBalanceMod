-- ========= Community Balance Mod ===============================
--
-- "lua\Hive_Server.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================



function Hive:OnEntityChange(oldId, newId)

    if HasMixin(self, "MapBlip") then 
         self:MarkBlipDirty()
    end
    CommandStructure.OnEntityChange(self, oldId, newId)

end
