-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\Weapons\Marine\Claw.lua
--
--    Created by:   Brian Cronin (brianc@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/DamageMixin.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponSlotMixin.lua")
Script.Load("lua/TechMixin.lua")
Script.Load("lua/TeamMixin.lua")

class 'Claw' (Entity)

Claw.kMapName = "claw"

local networkVars =
{
    clawAttacking = "private boolean"
}

local kClawRange = 2.6

AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(ExoWeaponSlotMixin, networkVars)

function Claw:OnCreate()

    Entity.OnCreate(self)
    
    InitMixin(self, TechMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, ExoWeaponSlotMixin)
    
    self.clawAttacking = false
    
end

function Claw:GetMeleeBase()
    return 1, 0.8
end

function Claw:GetMeleeOffset()
    return 0.0
end

function Claw:OnPrimaryAttack(_)
    self.clawAttacking = true
end

function Claw:OnPrimaryAttackEnd(_)
    self.clawAttacking = false
end

function Claw:GetDeathIconIndex()
    return kDeathMessageIcon.Claw
end

function Claw:ProcessMoveOnWeapon(player, input)
end

function Claw:GetWeight()
    return kClawWeight
end

function Claw:OnTag(tagName)

    PROFILE("Claw:OnTag")

    local player = self:GetParent()
    if player then
    
        if tagName == "hit" then
            AttackMeleeCapsuleAll(self, player, kClawDamage, kClawRange)
        elseif tagName == "claw_attack_start" then
            player:TriggerEffects("claw_attack")
        end
        
    end
    
end

function AttackMeleeCapsuleAll(weapon, player, damage, range, optionalCoords, altMode, filter)

    local targets = {}
    local didHit, target, endPoint, direction, surface, startPoint, trace

    if not filter then
        filter = EntityFilterTwo(player, weapon)
    end

    -- loop upto 20 times just to go through any soft targets.
    -- Stops as soon as nothing is hit or a non-soft target is hit
    for i = 1, 20 do

        local traceFilter = function(test)
            return EntityFilterList(targets)(test) or filter(test)
        end

        -- Enable tracing on this capsule check, last argument.
        didHit, target, endPoint, direction, surface, startPoint, trace = CheckMeleeCapsule(weapon, player, damage, range, optionalCoords, true, 1, nil, traceFilter)
        local alreadyHitTarget = target ~= nil and table.icontains(targets, target)

        if didHit and not alreadyHitTarget then
            weapon:DoDamage(damage, target, endPoint, direction, surface, altMode)
        end

        if target and not alreadyHitTarget then
            table.insert(targets, target)
        end

        if not target then
            break
        end

    end

    HandleHitregAnalysis(player, startPoint, endPoint, trace)

    local lastTarget = targets[#targets]

    -- Handle Stats
    if Server then

        local parent = weapon and weapon.GetParent and weapon:GetParent()
        if parent and weapon.GetTechId then

            -- Drifters, buildings and teammates don't count towards accuracy as hits or misses
            if (lastTarget and lastTarget:isa("Player") and GetAreEnemies(parent, lastTarget)) or lastTarget == nil then

                local steamId = parent:GetSteamId()
                if steamId then
                    StatsUI_AddAccuracyStat(steamId, weapon:GetTechId(), lastTarget ~= nil, lastTarget and lastTarget:isa("Onos"), weapon:GetParent():GetTeamNumber())
                end
            end
            GetBotAccuracyTracker():AddAccuracyStat(parent:GetClient(), lastTarget ~= nil, kBotAccWeaponGroup.Melee)
        end
    end

    return didHit, lastTarget, endPoint, surface

end

function Claw:OnUpdateAnimationInput(modelMixin)
    modelMixin:SetAnimationInput("activity_" .. self:GetExoWeaponSlotName(), self.clawAttacking)
end

Shared.LinkClassToMap("Claw", Claw.kMapName, networkVars)