Script.Load("lua/RailgunTargetMixin.lua")

local OldShiftOnCreate = Shift.OnCreate
function Shift:OnCreate()
    OldShiftOnCreate(self)

    if Client then
        InitMixin(self, RailgunTargetMixin)
    end
end
