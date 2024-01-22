-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


function Whip:OnMaturityComplete()

    if HasMixin(self, "MapBlip") then 
        self:MarkBlipDirty()
   end
    self:GiveUpgrade(kTechId.WhipBombard)

end