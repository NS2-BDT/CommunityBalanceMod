local kBabblerSearchTime = 8
local kBabblerOffMapInterval = 1
local kUpdateMoveInterval = 0.3

function Babbler:GetSpeedScalar()
    if self.clinged then
        local parent = self:GetParent()
        if parent and parent.GetSpeedScalar then
            return parent:GetSpeedScalar()
        end
    end
    
    if Client and self.clientVelocity then
        return self.clientVelocity:GetLength() / self:GetMaxSpeed()
    end
    
    return self:GetVelocity():GetLength() / self:GetMaxSpeed()
end

function Babbler:OnDamageDone(doer, target)
    self.timeLastDamageDealt = Shared.GetTime()
end

if Server then
	function Babbler:MoveRandom()
		PROFILE("Babbler:MoveRandom")

		if self.moveType == kBabblerMoveType.None and self:GetIsOnGround() and not self.babblerOffMap then
			-- check for targets to attack
			local target = self.targetSelector:AcquireTarget() or self:GetTarget()
			local owner = self:GetOwner()
			local alive = owner and HasMixin(owner, "Live") and owner:GetIsAlive()
			local ownerOrigin = owner and (not owner:isa("Commander") and owner:GetOrigin() or owner.lastGroundOrigin)

			if target then
				-- All babblers get that attack order too (all the group focus on the same target)
				for _, babbler in ipairs(GetEntitiesForTeamWithinRange("Babbler", self:GetTeamNumber(), self:GetOrigin(), 30)) do
					if babbler:GetOwner() == owner and babbler:GetTarget() ~= target then
						babbler:SetMoveType(kBabblerMoveType.Attack, target, target:GetOrigin())
					end
				end
			elseif owner and alive and HasMixin(owner, "BabblerCling") and self.lastDetachTime < (Shared.GetTime() - kBabblerSearchTime) then
				if owner:GetCanAttachBabbler() then
					self:SetMoveType(kBabblerMoveType.Cling, owner, ownerOrigin)
				elseif ownerOrigin then
					if (ownerOrigin - self:GetOrigin()):GetLength() <= 6 then
						self:SetMoveType(kBabblerMoveType.Wag, owner, ownerOrigin)
					else
						self:SetMoveType(kBabblerMoveType.Move, nil, ownerOrigin)
					end
				end
			else
				-- nothing to do, find something "interesting" (maybe glowing)
				local targetPos = self:FindSomethingInteresting()

				if targetPos then
					self:SetMoveType(kBabblerMoveType.Move, nil, targetPos)
				end
			end

			-- jump randomly
			if math.random() < 0.6 then
				self:JumpRandom()
			end
		end

		return not self.clinged and self:GetIsAlive()
	end

	local function RandomNegate(value)
		return math.random() > 0.5 and -value or value
	end

	function Babbler:Detach(force)
		if not self.clinged then
			return
		end

		local parent = self:GetParent()

		if parent and not force then
			-- Do not detach from the alien if he is out of the map (inside a tunnel)
			local maxDistance = 1000
			local origin = parent:GetOrigin()
			if origin:GetLengthSquared() > maxDistance * maxDistance then
				return
			end
		end

		if parent and HasMixin(parent, "BabblerCling") then
			parent:DetachBabbler(self)
		end

		self.lastDetachTime = Shared.GetTime()
		self.clinged = false

		self:CreateHitBox()

		local kDetachOffset = Vector(RandomNegate(math.random(15, 70) / 100), 0.25, RandomNegate(math.random(15, 70) / 100))
		-- Check so babbler scatter is not thru walls etc.
		if GetWallBetween(self:GetOrigin(), self:GetOrigin() + kDetachOffset, parent) then
			kDetachOffset = Vector(0, 0.25, 0)
		end
		self:SetOrigin(self:GetOrigin() + kDetachOffset)
		self:UpdateJumpPhysicsBody()
		self:SetMoveType(kBabblerMoveType.None)
		-- self:JumpRandom() should not be needed

		self:AddTimedCallback(Babbler.BabblerOffMap, kBabblerOffMapInterval)
		self:AddTimedCallback(Babbler.MoveRandom, kUpdateMoveInterval + math.random() / 5)
		self:AddTimedCallback(Babbler.UpdateWag, 0.4)
	end
end

