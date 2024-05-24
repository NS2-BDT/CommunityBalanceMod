Script.Load("lua/RailgunTargetMixin.lua")

local OldEggOnCreate = Egg.OnCreate
function Egg:OnCreate()
    OldEggOnCreate(self)

    if Client then
        InitMixin(self, RailgunTargetMixin)
    end
end
