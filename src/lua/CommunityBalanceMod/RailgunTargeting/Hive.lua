Script.Load("lua/RailgunTargetMixin.lua")

local OldHiveOnCreate = Hive.OnCreate
function Hive:OnCreate()
    OldHiveOnCreate(self)

    if Client then
        InitMixin(self, RailgunTargetMixin)
    end
end
