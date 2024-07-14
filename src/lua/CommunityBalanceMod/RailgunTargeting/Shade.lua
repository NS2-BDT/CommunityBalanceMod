Script.Load("lua/RailgunTargetMixin.lua")

local OldShadeOnCreate = Shade.OnCreate
function Shade:OnCreate()
    OldShadeOnCreate(self)

    if Client then
        InitMixin(self, RailgunTargetMixin)
    end
end
