-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Alien\StabBlink.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Blink.lua")

class 'StabBlink' (Blink)
StabBlink.kMapName = "stab"

local networkVars =
{
    stabbing = "compensated boolean"
}

local kRange = 1.9

local kAnimationGraph = PrecacheAsset("models/alien/fade/fade_view.animation_graph")
local kAttackAnimationLength = Shared.GetAnimationLength("models/alien/fade/fade_view.model", "stab")
StabBlink.cooldownInfluence = 0.5 -- 0 = no focus cooldown, 1 = same as kAttackDuration
StabBlink.kAttackDuration = kAttackAnimationLength -- no change for now...

function StabBlink:OnCreate()

    Blink.OnCreate(self)

    self.primaryAttacking = false

end

function StabBlink:GetAnimationGraphName()
    return kAnimationGraph
end

function StabBlink:GetEnergyCost()
    return kStabEnergyCost
end

function StabBlink:GetHUDSlot()
    return 3
end

function StabBlink:GetPrimaryAttackRequiresPress()
    return false
end

function StabBlink:GetMeleeBase()
    -- Width of box, height of box
    return .7, 1.2
end

function StabBlink:GetDeathIconIndex()
    return kDeathMessageIcon.Stab
end

function StabBlink:GetSecondaryTechId()
    return kTechId.Blink
end

function StabBlink:GetBlinkAllowed()
    return true
end

function StabBlink:OnPrimaryAttack(player)
    
    local notBlinking = not self:GetIsBlinking()
    local hasEnergy = player:GetEnergy() >= self:GetEnergyCost()
    local cooledDown = (not self.nextAttackTime) or (Shared.GetTime() >= self.nextAttackTime)
    if notBlinking and hasEnergy and cooledDown then
        self.primaryAttacking = true
    else
        self.primaryAttacking = false
    end
    
end

function StabBlink:OnPrimaryAttackEnd()
    
    Blink.OnPrimaryAttackEnd(self)
    
    self.primaryAttacking = false
    
end

function StabBlink:OnHolster(player)

    Blink.OnHolster(self, player)
    
    self.primaryAttacking = false
    --self.stabbing = false
    -- disabling this b/c it means stab will do swipe damage if stab completes after user switches
    -- weapons to swipe.
    
end

function StabBlink:OnDraw(player,previousWeaponMapName)

    Blink.OnDraw(self, player, previousWeaponMapName)
    
    self.primaryAttacking = false
    -- disabling this b/c it should already be false.  By setting it again here, we created a bug
    -- where if you start stab, switch to swipe, switch back to stab, then the stab animation completes,
    -- no damage occurs b/c stabbing is false.
    --self.stabbing = false
    
end

function StabBlink:GetIsStabbing()
    return self.stabbing == true
end

function StabBlink:GetIsAffectedByFocus()
    return true
end

function StabBlink:GetMaxFocusBonusDamage()
    return kStabFocusDamageBonusAtMax
end

function StabBlink:GetAttackAnimationDuration()
    return StabBlink.kAttackDuration * StabBlink.cooldownInfluence
end

function StabBlink:DoAttack()
    self:TriggerEffects("stab_hit")
    self.stabbing = false

    local player = self:GetParent()
    if player then

        AttackMeleeCapsule(self, player, kStabDamage, kRange, nil, false, EntityFilterOneAndIsa(player, "Babbler"))
        
        self:OnAttack(player)
    end
end

function StabBlink:OnTag(tagName)

    PROFILE("SwipeBlink:OnTag")
    
    if tagName == "stab_start" then
    
        self:TriggerEffects("stab_attack")
        self.stabbing = true
    
    elseif tagName == "hit" and self.stabbing then
        
        self:DoAttack()
        
    end

end

function StabBlink:OnUpdateAnimationInput(modelMixin)

    PROFILE("StabBlink:OnUpdateAnimationInput")

    Blink.OnUpdateAnimationInput(self, modelMixin)
    
    modelMixin:SetAnimationInput("ability", "stab")
    
    local activityString = (self.primaryAttacking and "primary") or "none"
    modelMixin:SetAnimationInput("activity", activityString)
    
end

Shared.LinkClassToMap("StabBlink", StabBlink.kMapName, networkVars)