-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\Weapons\Alien\Ability.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Weapon.lua")

class 'Ability' (Weapon)

local networkVars = 
{
    lastPrimaryAttackTime = "time (by 0.1)"
}

Ability.kMapName = "alienability"

local kDefaultEnergyCost = 20

function Ability:OnInitialized()
    Weapon.OnInitialized(self)
    
    self.lastPrimaryAttackTime = 0
end

-- Return 0-100 energy cost (where 100 is full energy bar)
function Ability:GetEnergyCost()
    return kDefaultEnergyCost
end

function Ability:GetSecondaryTechId()
    return kTechId.None
end

function Ability:GetSecondaryEnergyCost()
    return self:GetEnergyCost()
end

function Ability:GetResetViewModelOnDraw()
    return false
end

-- return array of player energy (0-1), ability energy cost (0-1), techId, visibility and hud slot
function Ability:GetInterfaceData(secondary, inactive)

    local parent = self:GetParent()
    -- It is possible there will be a time when there isn't a parent due to how Entities are destroyed and unparented.
    if parent then
    
        local vis = (inactive and parent:GetInactiveVisible()) or (not inactive)
        local hudSlot = 0
        if self.GetHUDSlot then
            hudSlot = self:GetHUDSlot()
        end
        
        -- Handle secondary here
        local techId = self:GetTechId()
        if secondary then
            techId = self:GetSecondaryTechId()
        end
        
        -- Inactive abilities return only hud slot, techId
        if inactive then
            return {hudSlot, techId}
        elseif parent.GetEnergy then
        
            if secondary then
                return {parent:GetEnergy() / parent:GetMaxEnergy(), self:GetSecondaryEnergyCost() / parent:GetMaxEnergy(), techId, vis, hudSlot }
            else
                local cooldown = self.GetCooldownFraction and self:GetCooldownFraction()
                return {parent:GetEnergy() / parent:GetMaxEnergy(), self:GetEnergyCost() / parent:GetMaxEnergy(), techId, vis, hudSlot, cooldown }
            end
        
        end
        
    end
    
    return { }
    
end

-- Abilities don't have world models, they are part of the creature
function Ability:GetWorldModelName()
    return ""
end

-- All alien abilities use the view model designated by the alien
function Ability:GetViewModelName()

    local viewModel = ""
    local parent = self:GetParent()
    
    if parent ~= nil and parent:isa("Alien") then
        viewModel = parent:GetViewModelName()
    end
    
    return viewModel
    
end

function Ability:PerformPrimaryAttack(player)
    return false
end

function Ability:PerformSecondaryAttack(player)
    return false
end

function Ability:GetAttackAnimationDuration()
    return 1
end

function Ability:GetFocusCooldownDuration(player)
    return 0
end

-- Child class should override if preventing the primary attack is needed.
function Ability:GetPrimaryAttackAllowed()
    return true
end

-- Child class can override
function Ability:OnPrimaryAttack(player)

    if self:GetPrimaryAttackAllowed() and (not self:GetPrimaryAttackRequiresPress() or not player:GetPrimaryAttackLastFrame()) then
    
        local energyCost = self:GetEnergyCost(player)
        
        if player:GetEnergy() >= energyCost then
        
            if self:PerformPrimaryAttack(player) then

                self:OnAttack(player, energyCost)
                self.lastPrimaryAttackTime = Shared.GetTime()
                Weapon.OnPrimaryAttack(self, player)
                
            end
            
        end
        
    end
    
end

function Ability:OnSecondaryAttack(player)

    if not self:GetSecondaryAttackRequiresPress() or not player:GetSecondaryAttackLastFrame() then
    
        local energyCost = self:GetSecondaryEnergyCost()
        
        if player:GetEnergy() >= energyCost then

            if self:PerformSecondaryAttack(player) then

                self:OnAttack(player, energyCost)
                Weapon.OnSecondaryAttack(self, player)
                
            end

        end

    end

end

function Ability:OnDraw(player, previousWeaponMapName)
    Weapon.OnDraw(self, player, previousWeaponMapName)
end

function Ability:GetEffectParams(tableParams)

    local player = self:GetParent()
    if player then
        local silenceLevel = player.silenceLevel or 0
        tableParams[kEffectFilterSilenceUpgrade] = silenceLevel == 3
        tableParams[kEffectParamVolume] = 1 - Clamp(silenceLevel / 3, 0, 1)
    end
    
end

function Ability:GetIsAffectedByFocus()
    return false
end

function Ability:GetIsAffectedByCrush()
    return true
end

function Ability:GetFocusAttackCooldown()
    return kFocusAttackSlowAtMax
end

function Ability:GetMaxFocusBonusDamage()
    return kFocusDamageBonusAtMax
end

function Ability:OnAttack(player, energyCost)
    energyCost = energyCost or self:GetEnergyCost()

    if self:GetIsAffectedByFocus() then
        local focusCooldown = self:DoAbilityFocusCooldown(player)
        energyCost = energyCost * ( 1 + focusCooldown )
	end

    player:DeductAbilityEnergy(energyCost)
end

-- returns focus cooldown scalar
function Ability:DoAbilityFocusCooldown(player)

    if player:GetHasUpgrade( kTechId.Focus ) then
        local veilLevel = player:GetVeilLevel()
        local focusCooldown = veilLevel > 0 and self:GetFocusAttackCooldown() or 0

        local animationDuration = self:GetAttackAnimationDuration()
        local cooldown = animationDuration * (1 + focusCooldown)
        
        -- factor in effects like enzyme and pulse grenade hits
        local attackPeriodFactor = 1.0

        -- general attack speed modifications by self
        if player.ModifyAttackSpeed then
            local attackSpeedTable = { attackSpeed = attackPeriodFactor }
            player:ModifyAttackSpeed(attackSpeedTable)
            attackPeriodFactor = attackSpeedTable.attackSpeed
        end
        
        -- pulse grenades/overcharge
        if player.electrified then
            attackPeriodFactor = attackPeriodFactor * kElectrifiedAttackSpeed
        end
        
        -- enzyme
        if player:GetIsEnzymed() then
            attackPeriodFactor = attackPeriodFactor * kEnzymeAttackSpeed
        end
        
        self.nextAttackTime = Shared.GetTime() + (cooldown / attackPeriodFactor)

        return focusCooldown
    end

    return 0
end

Shared.LinkClassToMap("Ability", "alienability", networkVars)