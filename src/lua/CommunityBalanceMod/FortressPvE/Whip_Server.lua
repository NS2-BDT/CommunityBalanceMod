Whip.kFrenzyAttackSpeed = 2.0
Whip.kEnervateDuration = 1.4

local kWhipAttackScanInterval = 0.33
local kSlapAfterBombardTimeout = Shared.GetAnimationLength(Whip.kModelName, "attack")
local kBombardAfterBombardTimeout = Shared.GetAnimationLength(Whip.kModelName, "bombard")
--local kEnervateDuration = Shared.GetAnimationLength(Whip.kModelName, "enervate") -- 2.4

local kFrenzySlapAfterBombardTimeout = kSlapAfterBombardTimeout / Whip.kFrenzyAttackSpeed
local kFrenzyBombardAfterBombardTimeout = kBombardAfterBombardTimeout / Whip.kFrenzyAttackSpeed

-- attack animations are faster now
local kSlapAnimationHitTagAt      = kSlapAfterBombardTimeout / 3.75 --2.5
local kBombardAnimationHitTagAt   = kBombardAfterBombardTimeout / 17.25 --11.5

local kFrenzySlapAnimationHitTagAt = kSlapAnimationHitTagAt / Whip.kFrenzyAttackSpeed
local kFrenzyBombardAnimationHitTagAt = kBombardAnimationHitTagAt / Whip.kFrenzyAttackSpeed

local kBileShowerInterval = 0.6
local kBileShowerHeal = 0 -- 50 -- heals 3 times

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


function Whip:GetCanStartSlapAttack()
    if not self.rooted or self:GetIsOnFire() or self.enervating then
        return false
    end
    return Shared.GetTime() > self.nextSlapStartTime
end

function Whip:GetCanStartBombardAttack()

    if not self:GetIsMature() then
        return false
    end

    if not self.rooted or self:GetIsOnFire() or self.enervating then
        return false
    end
    return Shared.GetTime() > self.nextBombardStartTime
end


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

    self:DoDamage(Whip.kDamage, target, hitPosition, hitDirection, nil, true)
    self:TriggerEffects("whip_attack")

    local delay = self.frenzy and kFrenzySlapAfterBombardTimeout - kFrenzySlapAnimationHitTagAt
                  or kSlapAfterBombardTimeout - kSlapAnimationHitTagAt
    local nextSlapStartTime    = now + delay
    local nextBombardStartTime = now + delay

    self.nextSlapStartTime    = math.max(nextSlapStartTime,    self.nextSlapStartTime)
    self.nextBombardStartTime = math.max(nextBombardStartTime, self.nextBombardStartTime)
end

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

    local direction = Ballistics.GetAimDirection(bombStart, targetPos, Whip.kBombSpeed)
    if direction then
        self:FlingBomb(bombStart, targetPos, direction, Whip.kBombSpeed)
    end

    local timingOffset = self.frenzy and kFrenzyBombardAnimationHitTagAt or kBombardAnimationHitTagAt
    local nextSlapStartTime    = now + (( self.frenzy and kFrenzySlapAfterBombardTimeout or kSlapAfterBombardTimeout )      - timingOffset)
    local nextBombardStartTime = now + (( self.frenzy and kFrenzyBombardAfterBombardTimeout or kBombardAfterBombardTimeout) - timingOffset)

    self.nextSlapStartTime    = math.max(nextSlapStartTime,    self.nextSlapStartTime)
    self.nextBombardStartTime = math.max(nextBombardStartTime, self.nextBombardStartTime)
end

function Whip:StartFrenzy()
    local now = Shared.GetTime()
    self.timeFrenzyEnd = now + Whip.kFrenzyDuration
    self.frenzy = true
    
    -- shorten the delay to the next attack
    local nextSlapStartTime    = self.nextSlapStartTime - kFrenzySlapAfterBombardTimeout
    local nextBombardStartTime = self.nextBombardStartTime - kFrenzyBombardAfterBombardTimeout
    self.nextSlapStartTime    = math.max(nextSlapStartTime,    now)
    self.nextBombardStartTime = math.max(nextBombardStartTime, now)
    
end

function Whip:Enervate()
    local now = Shared.GetTime()
    self.timeEnervateEnd = now + Whip.kEnervateDuration
    self.enervating = true
    self:AddTimedCallback(self.BileShower, kBileShowerInterval)
end

local kBileShowerDuration = 3
local kBileShowerDamage = 42.5 --  about 250 damage max
local kBileShowerSplashRadius = 8
local kBileShowerDotInterval = kBileBombDotInterval

function Whip:BileShower()
    -- heals self and bile bombs 3 times

    local now = Shared.GetTime()
    local isAlive = self:GetIsAlive()
    
    -- modified from Contamination:SpewBile
    local dotMarker = CreateEntity( DotMarker.kMapName, self:GetAttachPointOrigin("Whip_Ball") or self:GetOrigin(), self:GetTeamNumber() )
    dotMarker:SetDamageType( kBileBombDamageType )
    dotMarker:SetLifeTime( kBileShowerDuration )
    dotMarker:SetDamage( kBileShowerDamage )
    dotMarker:SetRadius( kBileShowerSplashRadius )
    dotMarker:SetDamageIntervall( kBileShowerDotInterval )
    dotMarker:SetDotMarkerType( DotMarker.kType.Static )
    dotMarker:SetTargetEffectName( "bilebomb_onstructure" )
    dotMarker:SetDeathIconIndex( kDeathMessageIcon.BileBomb )
    dotMarker:SetOwner( self:GetOwner() )
    dotMarker:SetFallOffFunc( SineFalloff )
    dotMarker:TriggerEffects( "bilebomb_hit" )
    
    self:AddHealth(kBileShowerHeal, false, false, false, self, true)

    return self.enervating and isAlive
end


function Whip:OnMaturityComplete()
    if HasMixin(self, "MapBlip") then 
        self:MarkBlipDirty()
    end
    self:GiveUpgrade(kTechId.WhipBombard)
end