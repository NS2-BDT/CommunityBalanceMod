Script.Load("lua/RailgunTargetMixin.lua")

local OldLerkOnCreate = Lerk.OnCreate
function Lerk:OnCreate()
    OldLerkOnCreate(self)

    if Client then
        InitMixin(self, RailgunTargetMixin)
    end
end
