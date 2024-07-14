Script.Load("lua/RailgunTargetMixin.lua")

local OldHarvesterOnCreate = Harvester.OnCreate
function Harvester:OnCreate()
    OldHarvesterOnCreate(self)

    if Client then
        InitMixin(self, RailgunTargetMixin)
    end
end
