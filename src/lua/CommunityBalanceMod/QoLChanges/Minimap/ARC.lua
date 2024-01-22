-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


local oldARCOnInitialized = ARC.OnInitialized
function ARC:OnInitialized()

    oldARCOnInitialized(self)

    if Server then  
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
    end

end