
local oldHiveOnInitialized = Hive.OnInitialized
function Hive:OnInitialized()

    oldHiveOnInitialized(self)

    if Server then  
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
    end

end
