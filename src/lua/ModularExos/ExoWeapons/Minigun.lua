function Minigun:GetIsAffectedByWeaponUpgrades()
    return true
end

local Shoot = debug.getupvaluex(Minigun.OnTag, "Shoot")
local kMinigunSpread = Math.Radians(5)
debug.setupvaluex(Shoot, "kMinigunSpread", kMinigunSpread)

-- minigun overheat old technology
local oldUpdateOverheated = debug.getupvaluex(Minigun.ProcessMoveOnWeapon, "UpdateOverheated")
local function UpdateOverheated(self, player)
    oldUpdateOverheated(self, player)
    if self.overheated and self.heatAmount == 0 then
        self.overheated = false
    end
end
debug.setupvaluex(Minigun.ProcessMoveOnWeapon, "UpdateOverheated", UpdateOverheated)
