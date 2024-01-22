-- ========= Community Balance Mod ===============================
--
-- "lua\DrifterEgg.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


Script.Load("lua/MapBlipMixin.lua")

local oldDrifterEggOnInitialized = DrifterEgg.OnInitialized
function DrifterEgg:OnInitialized()

    oldDrifterEggOnInitialized(self)

    if Server then  
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
    end

end