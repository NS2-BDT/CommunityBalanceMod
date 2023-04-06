Shockwave.kRadius = 0.01

local kShockwaveLifeTime = debug.getupvaluex(Shockwave.OnCreate, "kShockwaveLifeTime")
local kShockWaveVelocity = debug.getupvaluex(Shockwave.UpdateShockwave, "kShockWaveVelocity")

local CreateEffect = debug.getupvaluex(Shockwave.OnCreate, "CreateEffect")
local kRotationCoords = debug.getupvaluex(CreateEffect, "kRotationCoords")
local kShockwaveCrackMaterial = debug.getupvaluex(CreateEffect, "kShockwaveCrackMaterial")

local DestroyShockwave = debug.getupvaluex(Shockwave.Detonate, "DestroyShockwave")

local function CreateEffect(self)
    -- local player = Client.GetLocalPlayer()
    -- local enemies = GetAreEnemies(self, player)

    -- -- Hide effect for enemies without LOS
    -- -- Not ideal, but parent sighted will be more up-to-date in most cases
    -- local parent = self:GetParent() -- can be nil
    -- local hideEffect = enemies and parent and not parent:GetIsSighted()
    -- if hideEffect then
    --     return true
    -- end

    local coords = self:GetCoords()
    local groundTrace = Shared.TraceRay(coords.origin, coords.origin - Vector.yAxis * 3, CollisionRep.Move, PhysicsMask.Movement, EntityFilterAllButIsa("Tunnel"))

    if groundTrace.fraction ~= 1 then
        coords.origin = groundTrace.endPoint
        
        coords.zAxis.y = 0
        coords.zAxis:Normalize()
        
        coords.xAxis.y = 0
        coords.xAxis:Normalize()
        
        coords.yAxis = coords.zAxis:CrossProduct(coords.xAxis)

        --self:TriggerEffects("shockwave_trail", { effecthostcoords = coords })
        Client.CreateTimeLimitedDecal(kShockwaveCrackMaterial, coords * kRotationCoords[math.random(1, #kRotationCoords)], 2.7, 6)
    end
    
    return true
end

debug.setupvaluex(Shockwave.OnCreate, "CreateEffect", CreateEffect)

function Shockwave:UpdateShockwave(deltaTime) 
    local bestEndPoint = nil
    local bestFraction = 0

    if not self.endPoint then
        -- if self.tFirst == true then
        --     self.tFirst = false
        --     self:Detonate()
        -- end

        -- for i = 1, 4 do
        for i = 1, 11 do
            local offset = Vector.yAxis * (i-1) * 0.3
            local trace = Shared.TraceRay(self:GetOrigin() + offset, self:GetOrigin() + self:GetCoords().zAxis * kShockWaveVelocity * kShockwaveLifeTime + offset, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAllButIsa("Tunnel"))

            -- if Shared.GetTestsEnabled() then
            --     DebugLine(self:GetOrigin() + offset, trace.endPoint, 2, 1, 1, 1, 1)
            -- end

            if trace.fraction == 1 then
                bestEndPoint = trace.endPoint
                break
            elseif trace.fraction > bestFraction then
                bestEndPoint = trace.endPoint
                bestFraction = trace.fraction 
            end
        end

        self.endPoint = bestEndPoint
        local origin = self:GetOrigin()
        origin.y = self.endPoint.y
        self:SetOrigin(origin)

        --DebugLine(origin, self.endPoint, 2, 1, 0, 0, 1)
    end
    local newPosition = SlerpVector(self:GetOrigin(), self.endPoint, self:GetCoords().zAxis * kShockWaveVelocity * deltaTime)

    if (newPosition - self.endPoint):GetLength() < 0.1 then
        DestroyShockwave(self)
    else
        self:SetOrigin(newPosition)
    end
end

function Shockwave:Detonate()
    local origin = self:GetOrigin()

    local groundTrace = Shared.TraceRay(origin, origin - Vector.yAxis * 3, CollisionRep.Move, PhysicsMask.Movement, EntityFilterAllButIsa("Tunnel"))
    local enemies = GetEntitiesWithMixinWithinRange("Live", groundTrace.endPoint, 2.2)
    
	if Shared.GetTestsEnabled() then
		DebugLine(origin, groundTrace.endPoint, 2, 1, 0, 1, 1)
    end
    
    -- never damage the owner
    local owner = self:GetOwner()
    if owner then
        table.removevalue(enemies, owner)
    end
    
    if groundTrace.fraction < 1 then
        -- if Shared.GetTestsEnabled() then
		-- 	DebugBox(groundTrace.endPoint, groundTrace.endPoint, Vector(2.2,0.8,2.2), 5, 0, 0, 1, 1 )
		-- end
        
		-- self:SetOrigin(groundTrace.endPoint + (Vector.yAxis * .5) )
		
        for _, enemy in ipairs(enemies) do
            local enemyId = enemy:GetId()
            if enemy:GetIsAlive() and not table.contains(self.damagedEntIds, enemyId) and math.abs(enemy:GetOrigin().y - groundTrace.endPoint.y) < 0.8 then
                self:DoDamage(kStompDamage, enemy, enemy:GetOrigin(), GetNormalizedVector(enemy:GetOrigin() - groundTrace.endPoint), "none")
                table.insert(self.damagedEntIds, enemyId)

                local hasGroundMove = HasMixin(enemy, "GroundMove")
                
                if not hasGroundMove or enemy:GetIsOnGround() then
                    self:TriggerEffects("shockwave_hit", { effecthostcoords = enemy:GetCoords() })
                end

                -- CommunityBalanceMod: Don't stun players, web them
                -- 
                -- if HasMixin(enemy, "Stun") then
                --     enemy:SetStun(kDisruptMarineTime)
                -- end

                if HasMixin(enemy, "Webable") then
                    enemy:SetWebbed(kWebbedDuration, true)
                end
            end
        end
    -- else
	-- 	DestroyShockwave(self)
	end
    
    return true
end
