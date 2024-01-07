local oldOnCreate = BoneShield.OnCreate
function BoneShield:OnCreate()
    oldOnCreate(self)
    --tiny delay, to allow clean swap-state when changing abilities
    self.onDrawTime = 0
    
end

function BoneShield:OnDraw(player, previousWeaponMapName)
    Ability.OnDraw(self, player, previousWeaponMapName)
    --self.secondaryAttacking = false
    self.primaryAttacking = false
    self.onDrawTime = Shared.GetTime()
end

function BoneShield:OnPrimaryAttackEnd()
    if self.primaryAttacking then
        self.lastTimeDeactivated = Shared.GetTime()
        self.primaryAttacking = false
        self:UpdateHitpointsRechargeStartTime()
    end
end

local kOnDrawStompActivateDelay = 0 -- 0.055555

function BoneShield:OnUpdateAnimationInput(modelMixin)

    local now = Shared.GetTime()
    --[[if self.onDrawTime + kOnDrawStompActivateDelay > now then
        return
    end--]]
    
    local activityString = self.primaryAttacking and "primary" or "none"
    local abilityString = "boneshield"
       
    modelMixin:SetAnimationInput("ability", abilityString)
    modelMixin:SetAnimationInput("activity", activityString)

end