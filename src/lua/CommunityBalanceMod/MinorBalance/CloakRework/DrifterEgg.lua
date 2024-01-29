-- ========= Community Balance Mod ===============================
--
--  "lua\DrifterEgg.lua"
--
--    Created by:   Twiliteblue, Drey (@drey3982)
--
-- ===============================================================

Script.Load("lua/CloakableMixin.lua")
local networkVars =
{
}
AddMixinNetworkVars(CloakableMixin, networkVars)

local oldOnCreate = DrifterEgg.OnCreate
function DrifterEgg:OnCreate()
    oldOnCreate(self)
    InitMixin(self, CloakableMixin)
end
    
Shared.LinkClassToMap("DrifterEgg", DrifterEgg.kMapName, networkVars)