-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Whip_Server.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local kWhipFrenzyAttackSpeed = 2.0
local kWhipEnervateDuration = 1.4
local kWhipFrenzyDuration = 7.5
local kWhipMaxInfestationCharge = 10

local kBileShowerDuration = 2.9
local kBileShowerDamage = 66.67 --  about 400 damage max, 26.668 x 5 ticks x 3 hits
local kBileShowerSplashRadius = 7
local kBileShowerDotInterval = 0.4 -- actually about 0.52s
local kBileShowerInterval = 0.6
local kBileShowerParasiteDuration = 5

-- reset attack if we don't get an end-tag from the animation inside this time
local kWhipAttackScanInterval = 0.33
local kSlapAfterBombardTimeout = Shared.GetAnimationLength(Whip.kModelName, "attack")
local kBombardAfterBombardTimeout = Shared.GetAnimationLength(Whip.kModelName, "bombard")

-- Delay between the animation start and the "hit" tagName. Values here are hardcoded and
-- will be replaced with the more accurate, real one at the first whip "hit" tag recorded.
local kAnimationHitTagAtSet       = { slap = false, bombard = false }
local kSlapAnimationHitTagAt      = kSlapAfterBombardTimeout / 3.75 --2.5
local kBombardAnimationHitTagAt   = kBombardAfterBombardTimeout / 17.25 --11.5

local kFrenzySlapAfterBombardTimeout = kSlapAfterBombardTimeout --/ kWhipFrenzyAttackSpeed
local kFrenzyBombardAfterBombardTimeout = kBombardAfterBombardTimeout --/ kWhipFrenzyAttackSpeed

local kFrenzySlapAnimationHitTagAt = kSlapAnimationHitTagAt --/ kWhipFrenzyAttackSpeed
local kFrenzyBombardAnimationHitTagAt = kBombardAnimationHitTagAt --/ kWhipFrenzyAttackSpeed

local kWhipBombardRange = 20
local kWhipBombSpeed = 20

local kRangeSquared        = Whip.kRange^2
local kBombardRangeSquared = kWhipBombardRange^2

local kWhipUnrootSound = PrecacheAsset("sound/NS2.fev/alien/structures/whip/unroot")
local kWhipRootedSound = PrecacheAsset("sound/NS2.fev/alien/structures/whip/root")

Script.Load("lua/Ballistics.lua")

function Whip:IsEntBlockingLos(ent, target)
    local entOrigin = ent:GetOrigin()
    local targetOrigin = target:GetOrigin()
    local eyePos = self:GetOrigin()
    local angle = math.rad(285/2)

    local toEntity = Vector(0, 0, 0)

    -- Reuse vector
    toEntity.x = entOrigin.x - eyePos.x
    toEntity.y = entOrigin.y - eyePos.y
    toEntity.z = entOrigin.z - eyePos.z

    -- Normalize vector
    local toEntityLength = math.sqrt(toEntity.x * toEntity.x + toEntity.y * toEntity.y + toEntity.z * toEntity.z)
    if toEntityLength > kEpsilon then
        toEntity.x = toEntity.x / toEntityLength
        toEntity.y = toEntity.y / toEntityLength
        toEntity.z = toEntity.z / toEntityLength
    end

    local normViewVec = (eyePos - targetOrigin):GetUnit()
    local dotProduct = Math.DotProduct(toEntity, normViewVec)

    local s = math.acos(dotProduct)

    -- Log("S = " .. tostring(s) .. " angle = " .. tostring(angle) .. " blocking ent: " .. EntityToString(ent))
    local isVisible = (s > angle)
    return (isVisible)
end


-- ValidateTarget() checks if we can attack and hit the target via a traceray between
-- our eyePos and the target:GetEngagementPoint().
-- Todo Fix:
--      Due to that Whips ignore any target with an engagement point behind an obstacle
--      like a railing even if the rest of the target is clearly visible.
function Whip:GetCanAttackTarget(selector, target, range)
    return selector:ValidateTarget(target)
end

function Whip:UpdateOrders(deltaTime)

    if GetIsUnitActive(self) then

        self:UpdateAttack(deltaTime)

    end

end

function Whip:SetBlockTime(interval)

    assert(type(interval) == "number")
    assert(interval > 0)

    self.unblockTime = Shared.GetTime() + interval

end

function Whip:OnTeleport()

    if self.rooted then
        self:Unroot()
    end

end

function Whip:UpdateRootState()

    local infested = self:GetGameEffectMask(kGameEffect.OnInfestation)
    local moveOrdered = self:GetCurrentOrder() and self:GetCurrentOrder():GetType() == kTechId.Move

    -- unroot if we have a move order or infestation recedes
    if self.rooted and (moveOrdered or (not infested  and not self:GetIsMature()  )) then --Balance Mod: No infestation requirement for matured whips to root
        self:Unroot()
    end

    -- root if on infestation and not moving/teleporting
    if not self.rooted and (infested or self:GetIsMature() )  and not (moveOrdered or self:GetIsTeleporting()) then --Balance Mod: No infestation requirement for matured whips to root
        self:Root()
    end

end

function Whip:Root()

    StartSoundEffectOnEntity(kWhipRootedSound, self)

    self:AttackerMoved() -- reset target sel

    self.rooted = true

    if self.frenzy then 
        self:SetBlockTime(0.2) 
    else
         self:SetBlockTime(0.5)
    end

    self:EndAttack()
    self.targetId = Entity.invalidId

    return true

end

function Whip:Unroot()

    StartSoundEffectOnEntity(kWhipUnrootSound, self)

    self.rooted = false
    if self.frenzy then 
        self:SetBlockTime(0.2) 
    else
         self:SetBlockTime(0.5)
    end
    self:EndAttack()

    return true

end

-- handle the targetId
function Whip:OnEntityChange(oldId, newId)

    -- Check if an entity was destroyed.
    if oldId ~= nil and newId == nil then

        if oldId == self.targetId then
            self.targetId = Entity.invalidId
        end

    end

end

function Whip:OnMaturityComplete()
    if HasMixin(self, "MapBlip") then 
        self:MarkBlipDirty()
    end
    self:GiveUpgrade(kTechId.WhipBombard)
end


function Whip:OnTeleportEnd()

    self:AttackerMoved() -- reset target sel
    self:ResetPathing()

end

function Whip:PerformAction(techNode, position)

    local success = false

    if techNode:GetTechId() == kTechId.Cancel or techNode:GetTechId() == kTechId.Stop then

        self:ClearOrders()
        success = true

    end

    return success

end


--
-- --- Attack block
--
function Whip:UpdateAttack(deltaTime)
    local now = Shared.GetTime()

    -- leaving tracking target for later... the other stuff works
    -- local target = Shared.GetEntity(self.targetId)
    -- if target then
    --     self:TrackTarget(target, deltaTime)
    -- end

    if not self.nextAttackScanTime or now > self.nextAttackScanTime then
        self:UpdateAttacks()
    end

end

function Whip:UpdateAttacks()

    if self:GetCanStartSlapAttack() then
        local newTarget = self:TryAttack(self.slapTargetSelector, true, kRangeSquared)
        self.nextAttackScanTime = Shared.GetTime() + kWhipAttackScanInterval
        if newTarget then
            self:FaceTarget(newTarget)
            self.targetId = newTarget:GetId()
            self.slapping = true
            self.bombarding = false
        end
    end

    if not self.slapping and self:GetCanStartBombardAttack() then
        local newTarget = self:TryAttack(self.bombardTargetSelector, false, kBombardRangeSquared)
        self.nextAttackScanTime = Shared.GetTime() + kWhipAttackScanInterval
        if newTarget then
            self:FaceTarget(newTarget)
            self.targetId = newTarget:GetId()
            self.bombarding = true
            self.slapping = false;
        end
    end
end


function Whip:GetCanStartSlapAttack()
    if not self.rooted or self:GetIsOnFire() or self.enervating or self.electrified then
        return false
    end
    return Shared.GetTime() > self.nextSlapStartTime
end

function Whip:GetCanStartBombardAttack()

    if not self:GetIsMature() then
        return false
    end

    if not self.rooted or self:GetIsOnFire() or self.enervating or self.electrified then
        return false
    end
    return Shared.GetTime() > self.nextBombardStartTime
end

function Whip:TryAttack(selector, keepTarget, maxRangeSquared)
    local target

    if keepTarget and self.targetId ~= Entity.invalidId then
        target = Shared.GetEntity(self.targetId)
        local isPlayer  = target and target:isa("Player")
        local canAttack = target and self:GetCanAttackTarget(selector, target, maxRangeSquared)
        local whipOrig  = Vector(self:GetOrigin().x, 0, self:GetOrigin().z)
        local targetOrig = target and Vector(target:GetOrigin().x, 0, target:GetOrigin().z)
        local isInRange = target and (whipOrig - targetOrig):GetLengthSquared() < maxRangeSquared

        -- Only remember player targets, otherwise we could be locked attacking a building and not switch
        -- to a player we could hit (but keep hitting the same player, priority target)
        if not isPlayer or not canAttack or not isInRange then
            target = nil
            self.targetId = Entity.invalidId
        end
    end

    if not target then
        target = selector:AcquireTarget()
        if target and not self:GetCanAttackTarget(selector, target, maxRangeSquared) then
            target = nil
        end
    end

    return target

end


local function AvoidSector(yaw, low, high)
    local mid = low + (high - low) / 2
    local result = 0
    if yaw > low and yaw < mid then
        result = low - yaw
    end
    if yaw >= mid and yaw < high then
        result = high - yaw
    end
    return result
end

--
-- figure out the best combo of attack yaw and view yaw to use aginst the given target.
-- returns viewYaw,attackYaw
--
function Whip:CalcTargetYaws(target)

    local point = target:GetEngagementPoint()

    -- Note: The whip animation is screwed up
    -- attack animation: valid for 270-90 degrees.
    -- attack_back : valid for 135-225 using poseParams 225-315
    -- bombard : valid for 270-90 degrees
    -- bombard_back : covers the 135-225 degree area using poseParams 225-315
    -- No valid attack animation covers the 90-135 and 225-270 angles - they are "dead"
    -- To avoid the dead angles, we lerp the view angle at half the attack yaw rate

    -- the attack_yaw we calculate here is the actual angle to be attacked. The pose_params
    -- attack_yaw will be transformed to cover it correctly. OnUpdateAnimationInput handles
    -- switching animations by use_back

    -- Update our attackYaw to aim at our current target
    local attackDir = GetNormalizedVector(point - self:GetModelOrigin())

    -- the animation rotates the wrong way, mathemathically speaking
    local attackYawRadians = -math.atan2(attackDir.x, attackDir.z)

    -- Factor in the orientation of the whip.
    attackYawRadians = attackYawRadians + self:GetAngles().yaw

    --[[
        local angles2 = self:GetAngles()
        local p1 = self:GetModelOrigin()
        local c = angles2:GetCoords()
        DebugLine(p1, p1 + c.zAxis * 2, 5, 0, 1, 0, 1)
        angles2.yaw = self:GetAngles().yaw - attackYawRadians
        c = angles2:GetCoords()
        DebugLine(p1, p1 + c.zAxis * 2, 5, 1, 0, 0, 1)
    --]]

    local attackYawDegrees = DegreesTo360(math.deg(attackYawRadians), true)
    --Log("%s: attackYawDegrees %s, view angle deg %s", self, attackYawDegrees, DegreesTo360(math.deg(self:GetAngles().yaw)))

    -- now figure out any adjustments needed in viewYaw to keep out of the bad animation zones
    local viewYawAdjust = AvoidSector(attackYawDegrees, 85,140)
    if viewYawAdjust == 0 then
        viewYawAdjust = AvoidSector(attackYawDegrees, 220, 275)
    end

    attackYawDegrees = attackYawDegrees - viewYawAdjust
    viewYawAdjust = math.rad(viewYawAdjust)


    return  viewYawAdjust, attackYawDegrees

end

-- Note: Non-functional; intended to adjust the angle of the model to keep
-- facing the target, but not important enough to spend time on for 267
function Whip:TrackTarget(target, deltaTime)

    local point = target:GetEngagementPoint()

    -- we can't adjust attack yaw after the attack has started, as that will change what animation is run and thus screw
    -- the generation of hit tags. Instead, we rotate the whole whip so the attack will be towards the target

    local dir2Target = GetNormalizedVector(point - self:GetModelOrigin())

    local yaw2Target = -math.atan2(dir2Target.x, dir2Target.z)

    local attackYaw = math.rad(self.attackYaw)
    local desiredYaw = yaw2Target - attackYaw

    local angles = self:GetAngles()
    angles.yaw = desiredYaw
    -- think about slerping later
    Log("%s: Tracking to %s", self, desiredYaw)
    -- self:SetAngles(angles)

end


function Whip:FaceTarget(target)

    local viewYawAdjust, attackYaw = self:CalcTargetYaws(target)
    local angles = self:GetAngles()

    angles.yaw = angles.yaw + viewYawAdjust
    self:SetAngles(angles)

    self.attackYaw = attackYaw

end


function Whip:AttackerMoved()

    self.slapTargetSelector:AttackerMoved()
    self.bombardTargetSelector:AttackerMoved()

end

--
-- Slap attack
--
function Whip:SlapTarget(target)
    self:FaceTarget(target)
    -- where we hit
    local now = Shared.GetTime()
    local targetPoint = target:GetEngagementPoint()
    local attackOrigin = self:GetEyePos()
    local hitDirection = targetPoint - attackOrigin
    hitDirection:Normalize()
    -- fudge a bit - put the point of attack 0.5m short of the target
    local hitPosition = targetPoint - hitDirection * 0.5

    self:DoDamage(kWhipSlapDamage, target, hitPosition, hitDirection, nil, true)
	
	if GetHasTech(self, kTechId.CragHive) and self:GetTechId() == kTechId.FortressWhip and target:isa("Player") then
		self:AddHealth(kWhipSiphonHealthAmount)
	end
	
	if GetHasTech(self, kTechId.ShadeHive) and self:GetTechId() == kTechId.FortressWhip then
		target:SetParasited(nil, kBileShowerParasiteDuration)
	end
	
	if GetHasTech(self, kTechId.ShiftHive) and self:GetTechId() == kTechId.FortressWhip then
		target:SetWebbed(kWhipWebbedDuration, true)
	end
	
    self:TriggerEffects("whip_attack")

    local delay = self.frenzy and kFrenzySlapAfterBombardTimeout - kFrenzySlapAnimationHitTagAt
                  or kSlapAfterBombardTimeout - kSlapAnimationHitTagAt
    local nextSlapStartTime    = now + delay
    local nextBombardStartTime = now + delay

    self.nextSlapStartTime    = math.max(nextSlapStartTime,    self.nextSlapStartTime)
    self.nextBombardStartTime = math.max(nextBombardStartTime, self.nextBombardStartTime)
end

--
-- Bombard attack
--
function Whip:BombardTarget(target)
    self:FaceTarget(target)
    -- This seems to fail completly; we get really weird values from the Whip_Ball point,
    local now = Shared.GetTime()
    local bombStart,success = self:GetAttachPointOrigin("Whip_Ball")
    if not success then
        Log("%s: no Whip_Ball point?", self)
        bombStart = self:GetOrigin() + Vector(0,1,0);
    end

    local targetPos = target:GetEngagementPoint()

    local direction = Ballistics.GetAimDirection(bombStart, targetPos, kWhipBombSpeed)
    if direction then
        self:FlingBomb(bombStart, targetPos, direction, kWhipBombSpeed)
    end

    local timingOffset = self.frenzy and kFrenzyBombardAnimationHitTagAt or kBombardAnimationHitTagAt
    local nextSlapStartTime    = now + (( self.frenzy and kFrenzySlapAfterBombardTimeout or kSlapAfterBombardTimeout )      - timingOffset)
    local nextBombardStartTime = now + (( self.frenzy and kFrenzyBombardAfterBombardTimeout or kBombardAfterBombardTimeout) - timingOffset)

    self.nextSlapStartTime    = math.max(nextSlapStartTime,    self.nextSlapStartTime)
    self.nextBombardStartTime = math.max(nextBombardStartTime, self.nextBombardStartTime)
end

function Whip:FlingBomb(bombStart, targetPos, direction, speed)

    local bomb = CreateEntity(WhipBomb.kMapName, bombStart, self:GetTeamNumber())

    -- For callback purposes so we can adjust our aim
    bomb.intendedTargetPosition = targetPos
    bomb.shooter = self
    bomb.shooterEntId = self:GetId()

    SetAnglesFromVector(bomb, direction)

    local startVelocity = direction * speed
    bomb:Setup( self:GetOwner(), startVelocity, true, nil, self)

    -- we set the lifetime so that if the bomb does not hit something, it still explodes in the general area. Good for hunting jetpackers.
    bomb:SetLifetime(self:CalcLifetime(bombStart, targetPos, startVelocity))

end

function Whip:CalcLifetime(bombStart, targetPos, startVelocity)

    local xzRange = (targetPos - bombStart):GetLengthXZ()
    local xzVelocity = Vector(startVelocity)
    xzVelocity.y = 0
    xzVelocity:Normalize()
    xzVelocity = xzVelocity:DotProduct(startVelocity)

    -- Lifetime is enough to reach target + small random amount.
    local lifetime = xzRange / xzVelocity + math.random() * 0.2

    return lifetime

end


-- --- End BombardAttack

-- --- Attack animation handling

function Whip:OnAttackStart(target)

    if target then
        self:FaceTarget(target)
    end

    -- attack animation has started, so the attack has started
    if HasMixin(self, "Cloakable") then
        self:TriggerUncloak()
    end

    if self.bombarding then
        self:TriggerEffects("whip_bombard")
    end
end

--
-- Check if an other target is reachable in the same attack cone, so we don't 'miss'
-- if someone block the slap or if current target is out of range.
-- Instead, hit the new target in the attack cone
function Whip:OnAttackHitBlockedTarget(target)
    local targets = GetEntitiesForTeamWithinRange("Player",
        GetEnemyTeamNumber(self:GetTeamNumber()),
        self:GetOrigin(), kWhipRange)

    Shared.SortEntitiesByDistance(target:GetOrigin(), targets)
    for _, newTarget in ipairs(targets) do

        if newTarget ~= target then
            self.targetId = newTarget:GetId()
            newTarget = self:TryAttack(self.slapTargetSelector, true, kRangeSquared)

            local isTargetValid = newTarget and newTarget:isa("Player") and HasMixin(newTarget, "Live") and newTarget:GetIsAlive()
            if isTargetValid and self:IsEntBlockingLos(newTarget, target)
            then
                -- Log("New target blocking the way validated, hitting him")
                return true, newTarget
            end
        end

    end

    return false, nil
end

function Whip:OnAttackHit()

    -- Prevent OnAttackHit to be called multiple times in a raw
    if self.attackStarted and (self.slapping or self.bombarding) and not self:GetIsOnFire() then

        local success = false
        local target = Shared.GetEntity(self.targetId)
        local eyePos = GetEntityEyePos(self)
        local selector = (self.slapping and self.slapTargetSelector or self.bombardTargetSelector)

        -- Log("OnAttackHit() : " .. EntityToString(target) .. tostring(self.slapping and " slapping" or " bombard"))

        if target then

            local targetValidated = self.slapping and self:GetCanAttackTarget(selector, target, kRangeSquared) or true

            if not targetValidated then
                -- Log("OnAttackHit() : Target not validated, is anything blocking us ?")
                targetValidated, target = self:OnAttackHitBlockedTarget(target)
                -- Log("OnAttackHit() : New Target validated ? " .. tostring(targetValidated))
            end

            if targetValidated then
                if self.slapping then
                    if self:GetCanAttackTarget(selector, target, kRangeSquared) then
                        self:SlapTarget(target)
                        success = true
                    end
                else
                    self:BombardTarget(target)
                    success = true
                end
            end

        end

        if not success then
            self.targetId = Entity.invalidId
        end
    end

    self.attackStarted = false
    self:EndAttack()
end

function Whip:OnAttackEnd()
    -- Empty placeholder function that can be used for modding
end

function Whip:EndAttack()

    -- unblock the next attack
    -- self.targetId = Entity.invalidId
    if self.slapping or self.bombarding then
        self:OnAttackEnd()

        self.slapping = false
        self.bombarding = false
        self.attackStarted = false
    end
end

function Whip:OnTag(tagName)

    PROFILE("Whip:OnTag")

    if tagName == "hit" and self.attackStarted then

        if not kAnimationHitTagAtSet.slap and self.slapping then
            kAnimationHitTagAtSet.slap    = true
            kSlapAnimationHitTagAt        = (Shared.GetTime() - self.lastAttackStart)
            -- Log("%s : Setting slap hit tag at %s", self, tostring(kBombardAnimationHitTagAt))
        end

        if not kAnimationHitTagAtSet.bombard and self.bombarding then
            kAnimationHitTagAtSet.bombard = true
            kBombardAnimationHitTagAt     = (Shared.GetTime() - self.lastAttackStart)
            -- Log("%s : Setting bombard hit tag at %s", self, tostring(kBombardAnimationHitTagAt))
        end

        self:OnAttackHit()
    end

    -- The 'tagName == "hit"' is not reliable and sometime is not triggered at all (obscure reasons).
    -- To fix that we use a manual callback that is reliable, so each time a whip has an animation,
    -- it is guaranted it will hit if the target is still in range and in sight.
    if (tagName == "slap_start" or tagName == "bombard_start") and not self.attackStarted then
        local animationLength = (tagName == "slap_start" and kSlapAnimationHitTagAt or kBombardAnimationHitTagAt)

        self.attackStarted = true
        self.lastAttackStart = Shared.GetTime()
        self:OnAttackStart()
        self:AddTimedCallback(Whip.OnAttackHit, animationLength)
    end

    if tagName == "slap_end" or tagName == "bombard_end" then
        self:OnAttackEnd()
    end

end
-- --- End attack animation

-- %%% New CBM Functions %%% --
function Whip:StartFrenzy()
    local now = Shared.GetTime()
    self.timeFrenzyEnd = now + kWhipFrenzyDuration
    self.frenzy = true
    
    -- shorten the delay to the next attack
    local nextSlapStartTime    = self.nextSlapStartTime - kFrenzySlapAfterBombardTimeout
    local nextBombardStartTime = self.nextBombardStartTime - kFrenzyBombardAfterBombardTimeout
    self.nextSlapStartTime    = math.max(nextSlapStartTime,    now)
    self.nextBombardStartTime = math.max(nextBombardStartTime, now)
    
	self.infestationSpeedCharge = kWhipMaxInfestationCharge
end

function Whip:Enervate()
    local now = Shared.GetTime()
    self.timeEnervateEnd = now + kWhipEnervateDuration
    self.enervating = true
    self:AddTimedCallback(self.BileShower, kBileShowerInterval)
end

local function SplashFalloff( distanceFraction )
    -- max damage within 2.5m radius, min damage 62.5% at 4.625m
    local kfallOff = Clamp(distanceFraction - 0.357, 0, 0.375)
    --Print(kfallOff)
    return kfallOff
end

function Whip:BileShower()
    -- heals self and bile bombs 3 times

    local now = Shared.GetTime()
    local isAlive = self:GetIsAlive()
    
    -- modified from Contamination:SpewBile
    local dotMarker = CreateEntity( DotMarker.kMapName, self:GetOrigin(), self:GetTeamNumber() )
    dotMarker:SetDamageType( kBileBombDamageType )
    dotMarker:SetLifeTime( kBileShowerDuration )
    dotMarker:SetDamage( kBileShowerDamage )
    dotMarker:SetRadius( kBileShowerSplashRadius )
    dotMarker:SetDamageIntervall( kBileShowerDotInterval )
    dotMarker:SetDotMarkerType( DotMarker.kType.Static )
    dotMarker:SetTargetEffectName( "bilebomb_onstructure" )
    dotMarker:SetDeathIconIndex( kDeathMessageIcon.BileBomb )
    dotMarker:SetOwner( self:GetOwner() )        
    dotMarker:SetFallOffFunc( SplashFalloff )
    dotMarker:TriggerEffects( "bilebomb_hit" )
    
    --self:AddHealth(kBileShowerHeal, false, false, false, self, true)

	if GetHasTech(self, kTechId.ShiftHive) and self:GetTechId() == kTechId.FortressWhip then
		local enemyTeamNumber = GetEnemyTeamNumber(self:GetTeamNumber())
		local targets = GetEntitiesWithMixinForTeamWithinRange("Webable", enemyTeamNumber, self:GetOrigin(), kBileShowerSplashRadius)
		
		for _, target in ipairs(targets) do
			target:SetWebbed(kWhipWebbedDuration, true)
		end
	end
	
	if GetHasTech(self, kTechId.ShadeHive) and self:GetTechId() == kTechId.FortressWhip then
		local enemyTeamNumber = GetEnemyTeamNumber(self:GetTeamNumber())
		local targets = GetEntitiesWithMixinForTeamWithinRange("ParasiteAble", enemyTeamNumber, self:GetOrigin(), kBileShowerSplashRadius)
		
		for _, target in ipairs(targets) do
			target:SetParasited(nil, kBileShowerParasiteDuration)
		end
	end

    return self.enervating and isAlive
end

local kWhipTurnSpeed = 2 * math.pi
function Whip:GetTurnSpeedOverride()
    return kWhipTurnSpeed
end