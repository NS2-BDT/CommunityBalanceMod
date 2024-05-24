function Railgun:GetIsAffectedByWeaponUpgrades()
    return true
end

-- Time required to go from 0% to 100% charged...
local kChargeTime = 0.5

-- The Railgun will automatically shoot if it is charged for too long...
local kChargeForceShootTime = 0.51

-- Cooldown between railgun shots...
local kRailgunChargeTime = 1

local kRailgunRange = 30
local kRailgunSpread = Math.Radians(0)
local kBulletSize = 0.5

debug.setupvaluex(Railgun.GetChargeAmount, "kChargeTime", kChargeTime)
debug.setupvaluex(Railgun.ProcessMoveOnWeapon, "kChargeForceShootTime", kChargeForceShootTime)

if Client then
	    function Railgun:OnProcessMove(input)

        Entity.OnProcessMove(self, input)
        
        local player = self:GetParent()
        
        if player then
    
            -- trace and highlight first target
            local filter = EntityFilterAllButMixin("RailgunTarget")
            local startPoint = player:GetEyePos()
            local endPoint = startPoint + player:GetViewCoords().zAxis * kRailgunRange * 1.11
            local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAllButIsa("Tunnel"))
            local direction = (endPoint - startPoint):GetUnit()
            
            local extents = GetDirectedExtentsForDiameter(direction, kBulletSize)
            
            self.railgunTargetId = nil
            
            if trace.fraction < 1 then
                
                local capsuleTrace = Shared.TraceBox(extents, startPoint, trace.endPoint, CollisionRep.Damage, PhysicsMask.Bullets, filter)
                if capsuleTrace.entity then
                
                    capsuleTrace.entity:SetRailgunTarget()
                    self.railgunTargetId = capsuleTrace.entity:GetId()
                    
                end
            
            end
        
        end
    
    end
	-- debug.setupvaluex(Railgun.OnProcessMove, "kRailgunRange", kRailgunRange)
end

-- Allows railguns to fire simulataneously...
function Railgun:OnPrimaryAttack(player)
    
    local exoWeaponHolder = player:GetActiveWeapon()
    local otherSlotWeapon = self:GetExoWeaponSlot() == ExoWeaponHolder.kSlotNames.Left and exoWeaponHolder:GetRightSlotWeapon() or exoWeaponHolder:GetLeftSlotWeapon()
    if self.timeOfLastShot + kRailgunChargeTime <= Shared.GetTime() then
        
        if not self.railgunAttacking then
            self.timeChargeStarted = Shared.GetTime()
        end
        self.railgunAttacking = true
    
    end

end

-- Allows railgun range and bullet size to be changed...
local function TriggerSteamEffect(self, player)

    if self:GetIsLeftSlot() then
        player:TriggerEffects("railgun_steam_left")
    elseif self:GetIsRightSlot() then
        player:TriggerEffects("railgun_steam_right")
    end
    
end

local function ExecuteShot(self, startPoint, endPoint, player)

    -- Filter ourself out of the trace so that we don't hit ourselves.
    local filter = EntityFilterTwo(player, self)
    local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAllButIsa("Tunnel"))
    local hitPointOffset = trace.normal * 0.3
    local direction = (endPoint - startPoint):GetUnit()
    local damage = kRailgunDamage + math.min(1, (Shared.GetTime() - self.timeChargeStarted) / kChargeTime) * kRailgunChargeDamage
    
    local extents = GetDirectedExtentsForDiameter(direction, kBulletSize)

    local hitEntities = {}
	
	for _ = 1, 20 do

		local capsuleTrace = Shared.TraceBox(extents, startPoint, trace.endPoint, CollisionRep.Damage, PhysicsMask.Bullets, filter)
		if capsuleTrace.entity then

			if not table.find(hitEntities, capsuleTrace.entity) then

				table.insert(hitEntities, capsuleTrace.entity)
				self:DoDamage(damage, capsuleTrace.entity, capsuleTrace.endPoint + hitPointOffset, direction, capsuleTrace.surface, false, false)
			end
		end

		-- Stop looping early if we've reached the end.
		if (capsuleTrace.endPoint - trace.endPoint):GetLength() <= extents.x then
			break
		end
		
		if (Shared.GetTime() - self.timeChargeStarted) / kChargeTime < 1 then
			break
		end

		-- use new start point
		startPoint = Vector(capsuleTrace.endPoint) + direction * extents.x * 3
	end

    local effectFrequency = self:GetTracerEffectFrequency()
    local showTracer = (math.random() < effectFrequency)

    -- Tell other players in relevancy to show the tracer. Does not tell the shooting player.
    self:DoDamage(0, nil, trace.endPoint + hitPointOffset, direction, trace.surface, false, showTracer)

    -- Tell the player who shot to show the tracer.
    if Client and showTracer then
        TriggerFirstPersonTracer(self, trace.endPoint)
    end

end

local function Shoot(self, leftSide)

    local player = self:GetParent()
    
    -- We can get a shoot tag even when the clip is empty if the frame rate is low
    -- and the animation loops before we have time to change the state.
    if player then
    
        player:TriggerEffects("railgun_attack")
        
        local viewAngles = player:GetViewAngles()
        local shootCoords = viewAngles:GetCoords()
        
        local startPoint = player:GetEyePos()
        
        local spreadDirection = CalculateSpread(shootCoords, kRailgunSpread, NetworkRandom)
        
        local endPoint = startPoint + spreadDirection * kRailgunRange
        ExecuteShot(self, startPoint, endPoint, player)
        
        if Client then
            TriggerSteamEffect(self, player)
        end
        
        self:LockGun()
        self.lockCharging = true
        
    end
    
end

function Railgun:OnTag(tagName)

    PROFILE("Railgun:OnTag")
    
    if self:GetIsLeftSlot() then
    
        if tagName == "l_shoot" then
            Shoot(self, true)
        elseif tagName == "l_shoot_end" then
            self.lockCharging = false
        end
        
    elseif not self:GetIsLeftSlot() then
    
        if tagName == "r_shoot" then
            Shoot(self, false)
        elseif tagName == "r_shoot_end" then
            self.lockCharging = false
        end
        
    end
    
end
