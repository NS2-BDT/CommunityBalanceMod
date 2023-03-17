local DestroyShockwave = debug.getupvaluex(Shockwave.Detonate, "DestroyShockwave")

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
        if Shared.GetTestsEnabled() then
			DebugBox(groundTrace.endPoint, groundTrace.endPoint, Vector(2.2,0.8,2.2), 5, 0, 0, 1, 1 )
		end
        
		self:SetOrigin(groundTrace.endPoint + (Vector.yAxis * .5) )
		
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
    else
		DestroyShockwave(self)
	end
    
    return true
end
