-- ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ============
--
-- lua\DamageMixin.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

DamageMixin = CreateMixin(DamageMixin)
DamageMixin.type = "Damage"

-- These may be optionally implemented.
DamageMixin.optionalCallbacks =
{
    PostDoDamage = "Call for when damage has been applied and the function is about to return."
}

function DamageMixin:__initmixin()
    PROFILE("DamageMixin:__initmixin")
end

-- damage type, doer and attacker don't need to be passed. that info is going to be fetched here. pass optional surface name
-- pass surface "none" for not hit/flinch effect
function DamageMixin:DoDamage(damage, target, point, direction, surface, altMode, showtracer)

    -- No prediction if the Client is spectating another player.
    if Client and not Client.GetIsControllingPlayer() then
        return false
    end
    
    local killedFromDamage = false
    local doer = self

    -- attacker is always a player, doer is 'self'
    local attacker, weapon
    local currentComm
    
    if target and target:isa("Ragdoll") then
        return false
    end
    
    if target and not (target.GetCanTakeDamage and target:GetCanTakeDamage()) then
        return false
    end
        
    if self:isa("Player") then
        attacker = self
    else

        if self:GetParent() and self:GetParent():isa("Player") then
            attacker = self:GetParent()
            
            if attacker:isa("Alien") and (self.secondaryAttacking or self.shootingSpikes) then
                weapon = attacker:GetActiveWeapon():GetSecondaryTechId()
            else
                weapon = self:GetTechId()
            end
            
        elseif HasMixin(self, "Owner") and self:GetOwner() and self:GetOwner():isa("Player") then
            
            attacker = self:GetOwner()
            -- If it's one of these doing damage, send the damage message to the current commander instead
            -- The original owner remains the same
            if self:isa("Whip") or self:isa("WhipBomb") or self:isa("ARC") or self:isa("Sentry") or self:isa("MAC") or self:isa("Drifter") then
                local commanders = GetEntitiesForTeam("Commander", self:GetTeamNumber())
                if commanders and commanders[1] then
                    currentComm = commanders[1]
                end
            end
            
            if self.GetWeaponTechId then
                weapon = self:GetWeaponTechId()
            elseif self.GetTechId then
                weapon = self:GetTechId()
            end
        end

    end

    if not attacker then
        attacker = doer
    end

	if point ~= point then
		Log('DamageMixin - Target Point was NAN!')
		Log('Attacker: %s',attacker)
		Log('Weapon: %s',weapon)
		return false
	end

    if attacker then
    
        -- Get damage type from source
        local damageType = kDamageType.Normal
        if self.GetDamageType then
            damageType = self:GetDamageType()
        elseif HasMixin(self, "Tech") then
            damageType = LookupTechData(self:GetTechId(), kTechDataDamageType, kDamageType.Normal)
        end
        
        local armorUsed = 0
        local healthUsed = 0
        local damageDone = 0
        local overshieldDamage = 0
        local rawDamage = damage
        
        if target and HasMixin(target, "Live") and damage > 0 then  

            damage, armorUsed, healthUsed, overshieldDamage = GetDamageByType(target, attacker, doer, damage, damageType, point, weapon)

            overshieldDamage = overshieldDamage or 0 -- Just in case mods alter damage rules in a way that this becomes nil
            rawDamage = damage + overshieldDamage

            -- check once the damage
            if not direction then
                direction = Vector(0, 0, 1)
            end

            -- Get the target entity id before takedamage so we can add the killing shot damage to our damage total.
            local targetEntityId = target:GetId()
            killedFromDamage, damageDone = target:TakeDamage(damage + overshieldDamage, attacker, doer, point, direction, armorUsed, healthUsed, damageType, nil)

            if rawDamage > 0 then
                                
                -- Many types of damage events are server-only, such as grenades.
                -- Send the player a message so they get feedback about what damage they've done.
                -- We use messages to handle multiple-hits per frame, such as splash damage from grenades.
                if Server and attacker:isa("Player") then
                
                    if GetAreEnemies( attacker, target ) then
                    
                        local amount = (target:GetCanTakeDamage() or killedFromDamage) and (damageDone + overshieldDamage) or 0 -- actual damage done
                        local overkill = healthUsed + armorUsed * 2 -- the full amount of potential damage, including overkill
                        
                        if HitSound_IsEnabledForWeapon( weapon ) then
                            -- Damage message will be sent at the end of OnProcessMove by the HitSound system
                            HitSound_RecordHit( attacker, target, amount, point, overkill, weapon )
                        else
                            SendDamageMessage( currentComm or attacker, targetEntityId, amount, point, overkill, weapon )
                        end
                        
                        SendMarkEnemyMessage( attacker, target, amount, weapon )
                    
                    end
                    
                    -- This makes the cross hair turn red. Show it when hitting enemies only
                    if (not doer.GetShowHitIndicator or doer:GetShowHitIndicator()) and GetAreEnemies(attacker, target) then
                        attacker.giveDamageTime = Shared.GetTime()
                    end
                    
                end
                
                if self.OnDamageDone then
                    self:OnDamageDone(doer, target)
                end

                if attacker and attacker.OnDamageDone then
                    attacker:OnDamageDone(doer, target)
                end
                
            end

        end
        
        -- trigger damage effects (damage, deflect) with correct surface
        if surface ~= "none" then
            local armorMultiplier = ConditionalValue(damageType == kDamageType.Light, 4, 2)
            armorMultiplier = ConditionalValue(damageType == kDamageType.Heavy, 1, armorMultiplier)
        
            -- local playArmorEffect = armorUsed * armorMultiplier > healthUsed
                
            if HasMixin(target, "NanoShieldAble") and target:GetIsNanoShielded() then    
                surface = "nanoshield"
                
            elseif HasMixin(target, "Fire") and target:GetIsOnFire() then
                surface = "flame"

            elseif not target then
            
                if GetIsPointOnInfestation(point) then
                    surface = "infestation"
                end
                
                if not surface or surface == "" then
                    surface = "metal"
                end
            
            elseif target:isa("Marine") and target.variant and table.icontains( kRoboticMarineVariantIds, target.variant) then
                surface = "robot"

            elseif not surface or surface == "" then
            
                surface = GetIsAlienUnit(target) and "organic" or "metal"

                -- define metal_thin, rock, or other
                if target.GetSurfaceOverride then
                    
                    surface = target:GetSurfaceOverride(damageDone) or surface
                    
                elseif GetAreEnemies(self, target) then

                    if target:isa("Alien") then
                        surface = "organic"
                    elseif target:isa("Exo") then
                        surface = "robot"
                    elseif target:isa("Marine") then
                        surface = "flesh"
                    else
                    
                        if HasMixin(target, "Team") then
                        
                            if target:GetTeamType() == kAlienTeamType then
                                surface = "organic"
                            else
                                surface = "metal"
                            end
                            
                        end
                    
                    end

                end

            end

            -- send to all players in range, except to attacking player, he will predict the hit effect
            if Server then
            
                if GetShouldSendHitEffect() then
                    local directionVectorIndex = 1
                    if direction then
                        directionVectorIndex = GetIndexFromVector(direction)
                    end

                    local message = BuildHitEffectMessage(point, doer, surface, target, showtracer, altMode, rawDamage, directionVectorIndex)

                    --[[
                        NOTE(Salads)

                        We use the origin of the attacker to determine entities that are in range to tell them to show a tracer,
                        but you can still do damage to players out of relevancy. Might want to think about not allowing damage
                        to be done if we're out of relevancy in the future.
                    --]]
                    local toPlayers = GetEntitiesWithinRange("Player", attacker:GetOrigin(), kHitEffectRelevancyDistance)
                    for _, spectator in ientitylist(Shared.GetEntitiesWithClassname("Spectator")) do
                    
                        if table.icontains(toPlayers, Server.GetOwner(spectator):GetSpectatingPlayer()) then
                            table.insertunique(toPlayers, spectator)
                        end
                        
                    end
                    
                    -- No need to send to the attacker if this is a child of the attacker.
                    -- Children such as weapons are simulated on the Client as well so they will
                    -- already see the hit effect.
                    if attacker and self:GetParent() == attacker and not attacker.serverBlood then
                        table.removevalue(toPlayers, attacker)
                    end
                    
                    for _, player in ipairs(toPlayers) do
                        Server.SendNetworkMessage(player, "HitEffect", message, false) 
                    end
                
                end

            elseif Client then

                local player = Client.GetLocalPlayer()

                if not player.serverBlood then
                    HandleHitEffect(point, doer, surface, target, showtracer, altMode, rawDamage, direction)
                end
                
                -- If we are far away from our target, trigger a private sound so we can hear we hit something
                if target then
                    
                    if attacker.MarkEnemyFromClient then
                        attacker:MarkEnemyFromClient( target, weapon )
                    end
                    
                    if (point - attacker:GetOrigin()):GetLength() > 5 then
                        attacker:TriggerEffects("hit_effect_local")
                    end
                    
                end
                
            end
            
        end
        
    end

    if self.PostDoDamage then
        self:PostDoDamage(target, damage)
    end
    
    return killedFromDamage
    
end