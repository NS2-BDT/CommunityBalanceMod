

Script.Load("lua/MapBlipMixin.lua")

local oldWhipOnInitialized = Whip.OnInitialized
function Whip:OnInitialized()

    oldWhipOnInitialized(self)

    if Server then  
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
    end

end