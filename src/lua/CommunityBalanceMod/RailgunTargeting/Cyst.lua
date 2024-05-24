Script.Load("lua/RailgunTargetMixin.lua")

local OldCystOnCreate = Cyst.OnCreate
function Cyst:OnCreate()
    OldCystOnCreate(self)

    if Client then
        InitMixin(self, RailgunTargetMixin)
    end
end
