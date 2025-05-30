ClientLOSMixin = CreateMixin(ClientLOSMixin)

ClientLOSMixin.type = "ClientLOS"

ClientLOSMixin.expectedMixins =
{
    Team = "For making friendly players visible",
    EntityChange = "Needed for the OnEntityChange() callback used below.",
}

ClientLOSMixin.optionalCallbacks =
{
}

local kUnitMaxLOSDistance = kPlayerLOSDistance
local kUnitMinLOSDistance = kStructureLOSDistance

local kMarkStickTime = 2
local kMarkLossTime = 0.25
local kMarkMeleeStickTime = 5
local kMarkMeleeLossTime = 2.5
local kTraceLimitPerFrame = 1
local kCrosshairFlickerFix = 0.3

local kAllowedLOSWeapon = set
{
    kTechId.Rifle,
    kTechId.Pistol,
    kTechId.Shotgun,
    kTechId.Submachinegun,
    kTechId.Flamethrower,
    kTechId.HeavyMachineGun,
    kTechId.Minigun,
    kTechId.Railgun,
    kTechId.Claw,
    kTechId.Axe,
    kTechId.Welder,
    kTechId.Bite,
    kTechId.Parasite,
    kTechId.LerkBite,
    kTechId.Spikes,
    kTechId.Swipe,
    kTechId.Stab,
    kTechId.Gore,
}
local kAllowedOtherWeapon = set
{
    kTechId.Spit,
    kTechId.Spray,
    kTechId.GrenadeLauncher,
    kTechId.BileBomb,
    kTechId.Spores,
    kTechId.Stomp,
    kTechId.ClusterGrenadeProjectile,
    kTechId.GasGrenadeProjectile,
    kTechId.PulseGrenadeProjectile,
}
local kMarkTimeOverrideForWeapon =
{
    [kTechId.Axe] = kMarkMeleeStickTime,
    [kTechId.Bite] = kMarkMeleeStickTime,
    [kTechId.Spikes] = kMarkMeleeStickTime,
    [kTechId.Swipe] = kMarkMeleeStickTime,
    [kTechId.Stab] = kMarkMeleeStickTime,
    [kTechId.Gore] = kMarkMeleeStickTime,
}
local kMarkLossTimeOverrideForWeapon =
{
    [kTechId.Axe] = kMarkMeleeLossTime,
    [kTechId.Bite] = kMarkMeleeLossTime,
    [kTechId.Spikes] = kMarkMeleeLossTime,
    [kTechId.Swipe] = kMarkMeleeLossTime,
    [kTechId.Stab] = kMarkMeleeLossTime,
    [kTechId.Gore] = kMarkMeleeLossTime,
}

ClientLOSMixin.networkVars =
{
}

function ClientLOSMixin:__initmixin()
    PROFILE("ClientLOSMixin:__initmixin")
    if Client then
        self.clientLOSdata =
        {
            damagedAt = {},
            tracedAt = {},
            markUntil = {},
            sightedUntil = {},
            remove = {},
            traceQueue = queue(),
            crosshairTime = 0,
        }
    end
end

if Server then
    function IsAllowedWeaponToMarkEnemy( weapon )
        return kAllowedOtherWeapon[weapon] or kAllowedLOSWeapon[weapon]
    end
elseif Client then
    function IsAllowedWeaponToMarkEnemy( weapon )
        return false
    end
end

local function GetIsObscurred(viewer, target)

    if not target then return false end

    local targetOrigin = HasMixin(target, "Target") and target:GetEngagementPoint() or target:GetOrigin()
    local eyePos = GetEntityEyePos(viewer)

    local trace = Shared.TraceRay(eyePos, targetOrigin, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterTwoAndIsa(viewer, target, "Babbler"))

    if trace.fraction == 1 then
        return false
    end

    return true

end

local function CrosshairTraceForPlayer( self )

    local viewAngles = self:GetViewAngles()
    local viewCoords = viewAngles:GetCoords()
    local startPoint = self:GetEyePos()
    local endPoint = startPoint + viewCoords.zAxis * Player.kRangeFinderDistance

    local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOneAndIsa(self, "Babbler"))
    return trace.entity

end

if Client then
    function ClientLOSMixin:MarkEnemyFromServer( target, weapon )
        if not Client.GetOptionBoolean( "enemyHealth", true ) then return end

        if target and target:isa("Player") then

            local now = Shared.GetTime()
            local id = target:GetId()

            local data = self.clientLOSdata

            data.damagedAt[id] = now
            data.markUntil[id] = math.max( data.markUntil[id] or 0, now + ( kMarkTimeOverrideForWeapon[weapon] or kMarkStickTime ) )
            data.sightedUntil[id] = math.max( data.sightedUntil[id] or 0, now + ( kMarkLossTimeOverrideForWeapon[weapon] or kMarkLossTime ) )

            local tracedAt = data.tracedAt[id]
            if not tracedAt then
                data.tracedAt[id] = { pass = false, time = 0 } -- never passed a trace, but this info is as "old" as possible
                data.traceQueue:SetFront(id) -- put at start, should be the next trace executed
            end
        end
    end

    function ClientLOSMixin:MarkEnemyFromClient( target, weapon )
        if not Client.GetOptionBoolean( "enemyHealth", true ) then return end

        if target:isa("Player") then

            if not IsAllowedWeaponToMarkEnemy(weapon) then return end

            local now = Shared.GetTime()
            local id = target:GetId()

            local data = self.clientLOSdata

            data.damagedAt[id] = now
            data.markUntil[id] = math.max( data.markUntil[id] or 0, now + ( kMarkTimeOverrideForWeapon[weapon] or kMarkStickTime ) )
            data.sightedUntil[id] = math.max( data.sightedUntil[id] or 0, now + ( kMarkLossTimeOverrideForWeapon[weapon] or kMarkLossTime ) )

            -- if there is no trace record yet, this entity must be added to the queue
            local tracedAt = data.tracedAt[id]
            if not tracedAt then
                -- put on end, last priority
                data.traceQueue:Enqueue(id)
            end

            -- Most weapons can only hit if you can actually see the enemy, so the first
            -- trace is effectively free / assumed to pass at the time damage is dealt
            data.tracedAt[id] = { pass = true, time = now }
        end
    end

    function ClientLOSMixin:RemoveMarkFromTargetId( id )
        local data = self.clientLOSdata
        data.remove[id] = nil
        data.damagedAt[id] = nil
        data.tracedAt[id] = nil
        data.markUntil[id] = nil
        data.sightedUntil[id] = nil
    end

    function ClientLOSMixin:GetHasMarkedTarget( target )
        local id = target:GetId()
        local now = Shared.GetTime()
        local tracePass = self.clientLOSdata.tracedAt[id] and self.clientLOSdata.tracedAt[id].pass
        local markUntilTime = self.clientLOSdata.markUntil[id]
        return tracePass and markUntilTime and now <  markUntilTime
    end

    function ClientLOSMixin:GetCachedCrossHairTarget()
        return self.clientLOSdata.crosshairEnt and Shared.GetEntity( self.clientLOSdata.crosshairEnt ) or nil
    end

    function ClientLOSMixin:UpdateMisc()

        if not self:GetIsLocalPlayer() then
            return
        end

        local data = self.clientLOSdata
        local now = Shared.GetTime()
        local traceCount = 0

        -- Do only one crosshair trace per frame...
        local res = CrosshairTraceForPlayer( self )
        if res then
            data.crosshairEnt = res:GetId()
            data.crosshairTime = now
        elseif data.crosshairTime + kCrosshairFlickerFix < now then
            data.crosshairEnt = nil
        end

        local id
        repeat
            id = data.traceQueue:Dequeue()
            if id then
                if data.remove[id] or data.markUntil[id] < now then
                    -- stop tracing this one, and remove data
                    self:RemoveMarkFromTargetId(id)
                else

                    local obscurred = GetIsObscurred( self, Shared.GetEntity( id ) )

                    -- lose mark faster if LOS is blocked
                    if not obscurred then
                        data.sightedUntil[id] = math.max( data.sightedUntil[id], now + kMarkLossTime )
                    end

                    if data.sightedUntil[id] < now then
                        self:RemoveMarkFromTargetId(id)
                    else
                        data.tracedAt[id] = { pass = not obscurred, time = now }

                        traceCount = traceCount + 1
                        data.traceQueue:SetFront(id)
                    end
                end
            end
        until not id or traceCount >= kTraceLimitPerFrame
    end

    function ClientLOSMixin:OnEntityChange(oldEntityId, newEntityId)
        local data = self.clientLOSdata
        if data.damagedAt[oldEntityId] then
            data.remove[oldEntityId] = true
        end

        if data.crosshairEnt == oldEntityId then
            data.crosshairEnt = Entity.InvalidId
        end
    end

end