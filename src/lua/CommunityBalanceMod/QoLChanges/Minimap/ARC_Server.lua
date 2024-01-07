
function ARC:OnEntityChange(oldId)

    if HasMixin(self, "MapBlip") then 
        self:MarkBlipDirty()
   end

    if self.targetedEntity == oldId then
        self.targetedEntity = Entity.invalidId
    end    

end
