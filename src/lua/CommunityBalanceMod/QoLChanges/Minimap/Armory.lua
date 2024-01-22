-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


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