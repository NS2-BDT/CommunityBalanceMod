Script.Load("lua/RailgunTargetMixin.lua")

local OldWhipOnCreate = Whip.OnCreate
function Whip:OnCreate()
    OldWhipOnCreate(self)

    if Client then
        InitMixin(self, RailgunTargetMixin)
    end
end
