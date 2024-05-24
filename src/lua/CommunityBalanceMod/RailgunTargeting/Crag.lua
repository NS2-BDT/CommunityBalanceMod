Script.Load("lua/RailgunTargetMixin.lua")

local OldCragOnCreate = Crag.OnCreate
function Crag:OnCreate()
    OldCragOnCreate(self)

    if Client then
        InitMixin(self, RailgunTargetMixin)
    end
end
