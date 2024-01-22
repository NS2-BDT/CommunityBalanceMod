-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


function ARC:OnEntityChange(oldId)

    if HasMixin(self, "MapBlip") then 
        self:MarkBlipDirty()
   end

    if self.targetedEntity == oldId then
        self.targetedEntity = Entity.invalidId
    end    

end
