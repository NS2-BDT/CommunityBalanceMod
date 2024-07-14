Script.Load("lua/RailgunTargetMixin.lua")

local OldShellOnCreate = Shell.OnCreate
function Shell:OnCreate()
    OldShellOnCreate(self)

    if Client then
        InitMixin(self, RailgunTargetMixin)
    end
end
