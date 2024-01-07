
local networkVars =
{
    advanced         =  "boolean"
}
Shared.LinkClassToMap("Armory", Armory.kMapName, networkVars)


local oldArmoryOnCreate = Armory.OnCreate
function Armory:OnCreate()

    oldArmoryOnCreate(self)
    self.advanced = false
end

function Armory:GetIsAdvanced()
    return self.advanced
end