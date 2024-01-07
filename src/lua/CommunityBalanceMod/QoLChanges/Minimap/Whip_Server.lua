
function Whip:OnMaturityComplete()

    if HasMixin(self, "MapBlip") then 
        self:MarkBlipDirty()
   end
    self:GiveUpgrade(kTechId.WhipBombard)

end