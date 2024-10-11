-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Alien\Gore.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com) and
--                  Urwalek Andreas (andi@unknownworlds.com)
--
-- Basic goring attack. Can also be used to smash down locked or welded doors.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/StompMixin.lua")

class 'Gore' (Ability)

Gore.kMapName = "gore"

local kAnimationGraph = PrecacheAsset("models/alien/onos/onos_view.animation_graph")
local kAttackDurationGore = Shared.GetAnimationLength("models/alien/onos/onos_view.model", "gore_attack") / 1.2
local kAttackDurationSmash = Shared.GetAnimationLength("models/alien/onos/onos_view.model", "smash")

Gore.kAttackType = enum({ "Gore", "Smash", "None" })
-- when hitting marine his aim is interrupted
Gore.kAimInterruptDuration = 0.7

local networkVars =
{
    attackType = "enum Gore.kAttackType",
    attackButtonPressed = "boolean"
}

AddMixinNetworkVars(StompMixin, networkVars)

local kAttackRange = 1.7
local kFloorAttackRage = 0.9

local kGoreSmashKnockbackForce = 590 -- mass of a marine: 90
local kGoreSmashMinimumUpwardsVelocity = 9

local function PrioritizeEnemyPlayers(weapon, player, newTarget, oldTarget)
    return not oldTarget or (GetAreEnemies(player, newTarget) and newTarget:isa("Player") and not oldTarget:isa("Player") )
end

local function GetGoreAttackRange(viewCoords)
    return kAttackRange + math.max(0, -viewCoords.zAxis.y) * kFloorAttackRage
end

-- checks in front of the onos in a radius for potential targets and returns the attack mode (randomized if no targets found)
local function GetAttackType(self, player)

    PROFILE("GetAttackType")
    
    local attackType = Gore.kAttackType.Gore
    local range = GetGoreAttackRange(player:GetViewCoords())
    local didHit, target, direction = CheckMeleeCapsule(self, player, 0, range, nil, nil, nil, PrioritizeEnemyPlayers)

    if didHit then
    
        if target and HasMixin(target, "Live") then
        
            if ( target.GetReceivesStructuralDamage and target:GetReceivesStructuralDamage() ) and GetAreEnemies(player, target) then
                attackType = Gore.kAttackType.Smash         
            end
            
        end
    
    end

    if Server then
        self.lastAttackType = attackType
    end
    
    return attackType

end

local kOnDrawStompActivateDelay = 0.125

function Gore:OnCreate()

    Ability.OnCreate(self)
    
    InitMixin(self, StompMixin)
    
    self.attackType = Gore.kAttackType.None
    if Server then
        self.lastAttackType = Gore.kAttackType.None
    end
    
    --tiny delay, to allow clean swap-state when changing abilities
    self.onDrawTime = 0

    self.activityString = self.activityString or "none"
    
end

function Gore:GetDeathIconIndex()
    return kDeathMessageIcon.Gore
end

function Gore:GetVampiricLeechScalar()
    return kGoreVampirismScalar
end

function Gore:GetAnimationGraphName()
    return kAnimationGraph
end

function Gore:GetEnergyCost()
    return kGoreEnergyCost
end

function Gore:GetHUDSlot()
    return 1
end

function Gore:GetAttackType()
    return self.attackType
end

function Gore:OnHolster(player)

    Ability.OnHolster(self, player)
    
    self:OnAttackEnd()
    
end

function Gore:GetMeleeBase()
    -- Width of box, height of box
    return 1, 1.4
end

function Gore:GetIsAffectedByFocus()
    return true
end

function Gore:Attack(player)
    
    local now = Shared.GetTime()
    local didHit = false
    local impactPoint
    local target
    
    local range = GetGoreAttackRange(player:GetViewCoords())
    didHit, target, impactPoint = AttackMeleeCapsule(self, player, kGoreDamage, range)

    self:OnAttack(player)
    
    return didHit, impactPoint, target
    
end

function Gore:OnTag(tagName)

    PROFILE("Gore:OnTag")

    if tagName == "hit" then
    
        local player = self:GetParent()
        
        local didHit, impactPoint, target = self:Attack(player)
        
        -- play sound effects
        self:TriggerEffects("gore_attack")
        
        -- play particle effects for smash
        if didHit and self:GetAttackType() == Gore.kAttackType.Smash and ( not target or (target.GetReceivesStructuralDamage and target:GetReceivesStructuralDamage()) ) then
        
            local effectCoords = player:GetViewCoords()
            effectCoords.origin = impactPoint
            self:TriggerEffects("smash_attack_hit", {effecthostcoords = effectCoords} )
            
        end
        
        if self.attackButtonPressed then
            self.attackType = GetAttackType(self, player)
        else
            self:OnAttackEnd()
        end
        
        if player:GetEnergy() >= self:GetEnergyCost(player) or not self.attackButtonPressed then
            self:OnAttackEnd()
        end
        
    elseif tagName == "end" and not self.attackButtonPressed then
        self:OnAttackEnd()
    end    

end

function Gore:OnPrimaryAttack(player)
    
    local nextAttackType = self.attackType
    if nextAttackType == Gore.kAttackType.None then
        nextAttackType = GetAttackType(self, player)
    end

    if player:GetEnergy() >= self:GetEnergyCost(player) then
        self.attackType = nextAttackType
        self.attackButtonPressed = true
    else
        self:OnAttackEnd()
    end 

end

function Gore:OnPrimaryAttackEnd(player)
    
    Ability.OnPrimaryAttackEnd(self, player)
    self:OnAttackEnd()
    
end

function Gore:OnAttackEnd()
    self.attackType = Gore.kAttackType.None
    self.attackButtonPressed = false
end

function Gore:OnUpdateAnimationInput(modelMixin)
    local now = Shared.GetTime()
    if self.onDrawTime + kOnDrawStompActivateDelay > now then
        return
    end
    local cooledDown = (not self.nextAttackTime) or (now >= self.nextAttackTime)
    if not self.nextAttackUpdate or now > self.nextAttackUpdate then
        if self.attackButtonPressed and cooledDown then
            if self.attackType == Gore.kAttackType.Gore then
                self.activityString = "primary"
                self.nextAttackUpdate = now + 0.1
            elseif self.attackType == Gore.kAttackType.Smash then
                self.activityString = "smash"
                self.nextAttackUpdate = now + 0.1
            end
        else
            self.activityString = "none"
        end
    end
    
    modelMixin:SetAnimationInput("ability", "gore")
    modelMixin:SetAnimationInput("activity", self.activityString)
    
end

function Gore:GetAttackAnimationDuration()
    local attackType = self.attackType

    if Server then
        attackType = self.lastAttackType
    end

    if attackType == Gore.kAttackType.Smash then
        return kAttackDurationSmash
    else
        return kAttackDurationGore
    end
end

function Gore:OnDraw(player, previousWeaponMapName)
    Ability.OnDraw(self, player, previousWeaponMapName)
    self.secondaryAttacking = false
    self.primaryAttacking = false
    self.onDrawTime = Shared.GetTime()
end

Shared.LinkClassToMap("Gore", Gore.kMapName, networkVars)