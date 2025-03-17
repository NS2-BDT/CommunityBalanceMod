
class 'Bombler' (Babbler)

Bombler.kMapName = "bombler"

Bombler.kRadius = 0.25

local kAnimationGraph = PrecacheAsset("models/alien/babbler/babbler.animation_graph")

local kTargetMaxFollowRange = 30
local kBabblerOffMapInterval = 1
local kUpdateMoveInterval = 0.3
local kMinJumpDistance = 5

local oldOnInit = Bombler.OnInitialized
function Bombler:OnInitialized()

	oldOnInit(self)

	if Server then
		self:AddTimedCallback(Bombler.MoveRandom, kUpdateMoveInterval)
	end

end
    

function Bombler:TimedKill()

	self:TriggerEffects("death", {effecthostcoords = Coords.GetTranslation(self:GetOrigin()) })
	DestroyEntity(self)

end


function Bombler:GetIsClinged()
    return false
end							   




local oldUpdateBabbler = Bombler.UpdateBabbler
function Bombler:UpdateBabbler(deltaTime)

	-- Kill babblers after a certain period
	if Server then
		if self.creationTime + kBomblerLifeTime  < Shared.GetTime() then
			self:TimedKill()
		end
	end
	
	oldUpdateBabbler(self, deltaTime)
  
end


if Server then

    local kEyeOffset = Vector(0, 0.2, 0)
    function Bombler:GetEyePos()
        return self:GetOrigin() + kEyeOffset
    end



    local function KillCallback(this)
        this:Kill()
        return -- remove callback
    end

    function Bombler:OnOwnerChanged(oldOwner, newOwner)
        if not newOwner then
            -- Destroy Babblers without Owner
            -- Use callback to avoid server crashs due to calls to destroyed unit by mixins
            self:AddTimedCallback(KillCallback, 1)
        end
    end

    function Bombler:OnEntityChange(oldId, newId)
		if self.moveType == kBabblerMoveType.Cling then
			self:SetMoveType(kBabblerMoveType.Move, nil, self:GetOrigin(), true)
		end
    end

    function Bombler:GetBabblerBall()
		return false
    end


 	function Bombler:MoveRandom()
		PROFILE("Babbler:MoveRandom")

		if self.moveType == kBabblerMoveType.None and self:GetIsOnGround() and not self.babblerOffMap then
			-- check for targets to attack
			local target = self.targetSelector:AcquireTarget() or self:GetTarget()
			local owner = self:GetOwner()
			local alive = owner and HasMixin(owner, "Live") and owner:GetIsAlive()
			local ownerOrigin = owner and (not owner:isa("Commander") and owner:GetOrigin() or owner.lastGroundOrigin)

			if target then
				-- All babblers get that attack order too (all the group focus on the same target)
				for _, babbler in ipairs(GetEntitiesForTeamWithinRange("Bombler", self:GetTeamNumber(), self:GetOrigin(), 30)) do
					if babbler:GetOwner() == owner and babbler:GetTarget() ~= target then
						babbler:SetMoveType(kBabblerMoveType.Attack, target, target:GetOrigin())
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



    local function GetCanReachTarget(self, target)

        local obstacleNormal = Vector(0, 1, 0)

        local targetOrig = target:GetOrigin()
        local targetTraceOrigin = HasMixin(target, "Target") and target:GetEngagementPoint() or target:GetOrigin()
        local trace = Shared.TraceRay(self:GetOrigin() + kEyeOffset, targetTraceOrigin, CollisionRep.LOS, PhysicsMask.All, EntityFilterAll())

        local canReach = trace.fraction >= 0.9 or self:IsTargetReached(targetOrig, 1)
        if canReach then
            return true, nil
        else
            obstacleNormal = trace.normal
        end

        return false, obstacleNormal

    end

    function Bombler:UpdateCling(deltaTime)
      --[[  if not self:Attach(deltaTime) then
            self:Detach()
            return false
        end

        return true]]--
    end

    local kDetachOffset = Vector(0, 0.3, 0)

    function Bombler:Attach(deltaTime)
    end

    function Bombler:Detach(force)

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

        self:SetOrigin(self:GetOrigin() + kDetachOffset)
        self:UpdateJumpPhysicsBody()
        self:SetMoveType(kBabblerMoveType.None)
        self:JumpRandom()

        self:AddTimedCallback(Babbler.BabblerOffMap, kBabblerOffMapInterval)
        self:AddTimedCallback(Babbler.MoveRandom, kUpdateMoveInterval + math.random() / 5)
        self:AddTimedCallback(Babbler.UpdateWag, 0.4)
    end



    local function NoObstacleInWay(self, targetPosition)

        local trace = Shared.TraceRay(self:GetOrigin() + kEyeOffset, targetPosition, CollisionRep.LOS, PhysicsMask.All, EntityFilterAll())
        return trace.fraction == 1

    end

    function Bombler:UpdateMove(deltaTime)

        PROFILE("Bombler:UpdateMove")

        local success

        if self.moveType == kBabblerMoveType.Move  then
            if self:GetIsOnGround() then

                if self.timeLastJump + 0.5 < Shared.GetTime() then

                    local target = self:GetTarget()
                    local targetPosition = self.targetPosition or (target and target:GetOrigin())
                    local distToTarget = targetPosition and targetPosition:GetDistanceTo(self:GetOrigin())
                    local isFriend = target and target.GetTeamNumber and target:GetTeamNumber() == self:GetTeamNumber()

                    if distToTarget < kMinJumpDistance then
                        self.targetReached = true
                    end

                    local followTarget = target and (isFriend or not self.targetReached or distToTarget <= kTargetMaxFollowRange)

                    if targetPosition and (not target or followTarget) then

                        local distance = math.max(0, ((self:GetOrigin() - targetPosition):GetLength() - kMinJumpDistance))
                        local shouldJump = math.random()
                        local jumpProbablity = 0

                        if 0 < distance and distance < kMinJumpDistance then
                            jumpProbablity = distance / 5
                        end

                        local done = false
                        if self.jumpAttempts < 3 and jumpProbablity >= shouldJump and NoObstacleInWay(self, targetPosition) then
                            done = self:Jump(self:GetMoveVelocity(targetPosition))
                            self.jumpAttempts = self.jumpAttempts + 1
                        else
                            done = self:Move(targetPosition, deltaTime)
                        end

                        if done or (self:GetOrigin() - targetPosition):GetLengthXZ() < 0.5 then
                            if self.physicsBody then
                                self.physicsBody:SetCoords(self:GetCoords())
                            end
                            self:SetMoveType(target and kBabblerMoveType.Attack or kBabblerMoveType.None,
                                    target, targetPosition)
                            if self:GetTarget() then
                                -- Call it here once to prevent babblers to stare at the marine
                                -- for a few seconds before attacking after reaching it
                                self:UpdateAttack(true)
                            end
                        end

                        success = true

                    end

                    if not success then
                        -- Log("Not success, setting none move type")
                        self:SetMoveType(kBabblerMoveType.None)
                    end
                end


            end

        end

        self.jumping = not self:GetIsOnGround()

    end

end

function Bombler:GetShowSensorBlip()
    return true --not self.clinged
end


Shared.LinkClassToMap("Bombler", Bombler.kMapName, networkVars, true)
