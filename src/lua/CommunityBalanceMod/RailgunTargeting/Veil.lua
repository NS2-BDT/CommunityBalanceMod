Script.Load("lua/RailgunTargetMixin.lua")

local OldVeilOnCreate = Veil.OnCreate
function Veil:OnCreate()
    OldVeilOnCreate(self)

    if Client then
        InitMixin(self, RailgunTargetMixin)
    end
end
