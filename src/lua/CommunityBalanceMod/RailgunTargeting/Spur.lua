Script.Load("lua/RailgunTargetMixin.lua")

local OldSpurOnCreate = Spur.OnCreate
function Spur:OnCreate()
    OldSpurOnCreate(self)

    if Client then
        InitMixin(self, RailgunTargetMixin)
    end
end
