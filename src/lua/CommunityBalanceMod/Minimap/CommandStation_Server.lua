

function CommandStation:OnEntityChange(oldId, newId)

    if HasMixin(self, "MapBlip") then 
         self:MarkBlipDirty()
    end
    --CommandStructure.OnEntityChange(self, oldId, newId)

end