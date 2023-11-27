
local oldCommandStructureOnEntityChange= CommandStructure.OnEntityChange
function CommandStation:OnEntityChange(oldEntityId, _)
    oldCommandStructureOnEntityChange(self, oldEntityId, _)

    if HasMixin(self, "MapBlip") then 
         self:MarkBlipDirty()
    end

end