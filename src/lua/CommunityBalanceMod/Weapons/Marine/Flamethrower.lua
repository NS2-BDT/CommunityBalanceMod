-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Flamethrower.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Weapon.lua")
Script.Load("lua/Weapons/Marine/Flame.lua")
Script.Load("lua/PickupableWeaponMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/AchievementGiverMixin.lua")
Script.Load("lua/FlamethrowerVariantMixin.lua")
Script.Load("lua/FilteredCinematicMixin.lua")

class 'Flamethrower' (ClipWeapon)

if Client then
    Script.Load("lua/Weapons/Marine/Flamethrower_Client.lua")
end

Flamethrower.kMapName = "flamethrower"

Flamethrower.kModelName = PrecacheAsset("models/marine/flamethrower/flamethrower.model")
local kViewModels = GenerateMarineViewModelPaths("flamethrower")
local kAnimationGraph = PrecacheAsset("models/marine/flamethrower/flamethrower_view.animation_graph")

local kFireLoopingSound = PrecacheAsset("sound/NS2.fev/marine/flamethrower/attack_loop")

local kRange = kFlamethrowerRange

Flamethrower.kConeWidth = kFlamethrowerConeWidth
Flamethrower.kDamageRadius = kFlamethrowerDamageRadius

local networkVars =
{
    createParticleEffects = "boolean",
    animationDoneTime = "float",
    loopingSoundEntId = "entityid",
    range = "integer (0 to 11)"
}

AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(FlamethrowerVariantMixin, networkVars)

function Flamethrower:OnCreate()

    ClipWeapon.OnCreate(self)

    self.loopingSoundEntId = Entity.invalidId

    if Server then

        self.createParticleEffects = false
        self.animationDoneTime = 0

        self.loopingFireSound = Server.CreateEntity(SoundEffect.kMapName)
        self.loopingFireSound:SetAsset(kFireLoopingSound)
        self.loopingFireSound:SetParent(self)
        self.loopingSoundEntId = self.loopingFireSound:GetId()

    elseif Client then

        InitMixin(self, FilteredCinematicMixin)

        self:SetUpdates(true, kDefaultUpdateRate)
        self.lastAttackEffectTime = 0.0

    end

    InitMixin(self, PickupableWeaponMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, AchievementGiverMixin)
    InitMixin(self, FlamethrowerVariantMixin)

end

function Flamethrower:OnDestroy()

    ClipWeapon.OnDestroy(self)

    -- The loopingFireSound was already destroyed at this point, clear the reference.
    if Server then
        self.loopingFireSound = nil
    elseif Client then

        if self.trailCinematic then
            Client.DestroyTrailCinematic(self.trailCinematic)
            self.trailCinematic = nil
        end

        if self.pilotCinematic then
            Client.DestroyCinematic(self.pilotCinematic)
            self.pilotCinematic = nil
        end

    end

end

function Flamethrower:GetAnimationGraphName()
    return kAnimationGraph
end

-- extracted via model analyzer tool, this is the bounding box origin of the model.
function Flamethrower:GetPickupOrigin()
    return self:GetCoords():TransformPoint(Vector(0.3868434429168701, -0.010511890053749084, -0.060572415590286255))
end

function Flamethrower:GetWeight()
    return kFlamethrowerWeight
end

function Flamethrower:OnHolster(player)

    ClipWeapon.OnHolster(self, player)

    self.createParticleEffects = false

end

function Flamethrower:OnDraw(player, previousWeaponMapName)

    ClipWeapon.OnDraw(self, player, previousWeaponMapName)

    self.createParticleEffects = false
    self.animationDoneTime = Shared.GetTime()

end

function Flamethrower:GetClipSize()
    return kFlamethrowerClipSize
end

function Flamethrower:CreatePrimaryAttackEffect(player)

    -- Remember this so we can update gun_loop pose param
    self.timeOfLastPrimaryAttack = Shared.GetTime()

end

function Flamethrower:GetRange()
    return kRange
end

function Flamethrower:GetViewModelName(sex, variant)
    return kViewModels[sex][variant]
end

function Flamethrower:BurnSporesAndUmbra(startPoint, endPoint)

    local toTarget = endPoint - startPoint
    local length = toTarget:GetLength()
    toTarget:Normalize()

    local stepLength = 2
    for i = 1, 5 do

        -- stop when target has reached, any spores would be behind
        if length < i * stepLength then
            break
        end

        local checkAtPoint = startPoint + toTarget * i * stepLength
        local spores = GetEntitiesWithinRange("SporeCloud", checkAtPoint, kSporesDustCloudRadius)

        local clouds = GetEntitiesWithinRange("CragUmbra", checkAtPoint, CragUmbra.kRadius)
        table.copy(GetEntitiesWithinRange("StormCloud", checkAtPoint, StormCloud.kRadius), clouds, true)
        table.copy(GetEntitiesWithinRange("MucousMembrane", checkAtPoint, MucousMembrane.kRadius), clouds, true)
        table.copy(GetEntitiesWithinRange("EnzymeCloud", checkAtPoint, EnzymeCloud.kRadius), clouds, true)

        local bombs = GetEntitiesWithinRange("Bomb", checkAtPoint, 1.6)
        table.copy(GetEntitiesWithinRange("WhipBomb", checkAtPoint, 1.6), bombs, true)

        local burnSpent = false

        for i = 1, #bombs do
            local bomb = bombs[i]
            bomb:TriggerEffects("burn_bomb", { effecthostcoords = Coords.GetTranslation(bomb:GetOrigin()) } )
            DestroyEntity(bomb)
            burnSpent = true
        end

        for i = 1, #spores do
            local spore = spores[i]
            self:TriggerEffects("burn_spore", { effecthostcoords = Coords.GetTranslation(spore:GetOrigin()) } )
            DestroyEntity(spore)
            burnSpent = true
        end

        for i = 1, #clouds do
            local cloud = clouds[i]
            self:TriggerEffects("burn_umbra", { effecthostcoords = Coords.GetTranslation(cloud:GetOrigin()) } )
            DestroyEntity(cloud)
            burnSpent = true
        end

        if burnSpent then
            break
        end


    end

end

function Flamethrower:CreateFlame(player, position, normal, direction)

    -- create flame entity, but prevent spamming:
    local nearbyFlames = GetEntitiesForTeamWithinRange("Flame", self:GetTeamNumber(), position, 1.7)

    if (#nearbyFlames == 0) then

        local flame = CreateEntity(Flame.kMapName, position, player:GetTeamNumber())
        flame:SetOwner(player)

        local coords = Coords.GetTranslation(position)
		
		if math.abs(Math.DotProduct(normal, direction)) > 0.9999 then
            direction = normal:GetPerpendicular()
        end
		
        coords.yAxis = normal
        coords.zAxis = direction

        coords.xAxis = coords.yAxis:CrossProduct(coords.zAxis)
        coords.xAxis:Normalize()

        coords.zAxis = coords.xAxis:CrossProduct(coords.yAxis)
        coords.zAxis:Normalize()

        flame:SetCoords(coords)
		
    end

end

function Flamethrower:ApplyConeDamage(player)

    local eyePos = player:GetEyePos()
    local ents = {}

    local fireDirection = player:GetViewCoords().zAxis
    local extents = Vector(self.kConeWidth, self.kConeWidth, self.kConeWidth)
    local range = self:GetRange()

    local startPoint = Vector(eyePos)
    local filterEnts = {self, player}
    local trace = TraceMeleeBox(self, startPoint, fireDirection, extents, range, PhysicsMask.Flame, EntityFilterList(filterEnts))

    local endPoint = trace.endPoint
    local normal = trace.normal

    -- Check for spores in the way.
    if Server then
        self:BurnSporesAndUmbra(startPoint, endPoint)
    end

    if trace.fraction ~= 1 then

        local traceEnt = trace.entity
        if traceEnt and HasMixin(traceEnt, "Live") and traceEnt:GetCanTakeDamage() then
            table.insert(ents, traceEnt)
        end

        local hitEntities = GetEntitiesWithMixinWithinXZRange("Live", endPoint, self.kDamageRadius)
        local damageHeight =  self.kDamageRadius / 2
        for i = 1, #hitEntities do
            local ent = hitEntities[i]
            if ent ~= traceEnt and ent:GetCanTakeDamage() and math.abs(endPoint.y - ent:GetOrigin().y) <= damageHeight then
                table.insert(ents, ent)
            end
        end

        --Create Flame
        if Server then
            --Create flame below target
            if trace.entity then
                local groundTrace = Shared.TraceRay(endPoint, endPoint + Vector(0, -2.6, 0), CollisionRep.Default, PhysicsMask.CystBuild, EntityFilterAllButIsa("TechPoint"))
                if groundTrace.fraction ~= 1 then
                    fireDirection = fireDirection * 0.55 + normal
                    fireDirection:Normalize()

                    self:CreateFlame(player, groundTrace.endPoint, groundTrace.normal, fireDirection)
                end
            else
                fireDirection = fireDirection * 0.55 + normal
                fireDirection:Normalize()

                self:CreateFlame(player, endPoint, normal, fireDirection)
            end

        end

    end

    local attackDamage = kFlamethrowerDamage
    for i = 1, #ents do

        local ent = ents[i]
        local enemyOrigin = ent:GetModelOrigin()

        if ent ~= player and enemyOrigin then

            local toEnemy = GetNormalizedVector(enemyOrigin - eyePos)

            local health = ent:GetHealth()
            self:DoDamage( attackDamage, ent, enemyOrigin, toEnemy )

            -- Only light on fire if we successfully damaged them
            if ent:GetHealth() ~= health and HasMixin(ent, "Fire") and not ent:GetHasDouse() then
                ent:SetOnFire(player, self)
            end

        end

    end

end

function Flamethrower:ShootFlame(player)

    local viewAngles = player:GetViewAngles()
    local viewCoords = viewAngles:GetCoords()

    viewCoords.origin = self:GetBarrelPoint(player) + viewCoords.zAxis * (-0.4) + viewCoords.xAxis * (-0.2)
    local endPoint = self:GetBarrelPoint(player) + viewCoords.xAxis * (-0.2) + viewCoords.yAxis * (-0.3) + viewCoords.zAxis * self:GetRange()

    local trace = Shared.TraceRay(viewCoords.origin, endPoint, CollisionRep.Damage, PhysicsMask.Flame, EntityFilterAll())

    local range = (trace.endPoint - viewCoords.origin):GetLength()
    if range < 0 then
        range = range * (-1)
    end

    if trace.endPoint ~= endPoint and trace.entity == nil then

        local angles = Angles(0,0,0)
        angles.yaw = GetYawFromVector(trace.normal)
        angles.pitch = GetPitchFromVector(trace.normal) + (math.pi/2)

        local normalCoords = angles:GetCoords()
        normalCoords.origin = trace.endPoint
        range = range - 3

    end

    self:ApplyConeDamage(player)

end

function Flamethrower:FirePrimary(player)
    self:ShootFlame(player)
end

function Flamethrower:GetDeathIconIndex()
    return kDeathMessageIcon.Flamethrower
end

function Flamethrower:GetHUDSlot()
    return kPrimaryWeaponSlot
end

function Flamethrower:GetIsAffectedByWeaponUpgrades()
    return true
end

function Flamethrower:OnPrimaryAttack(player)

    if not self:GetIsReloading() then

        ClipWeapon.OnPrimaryAttack(self, player)

        if self:GetIsDeployed() and self:GetClip() > 0 and self:GetPrimaryAttacking() then

            if not self.createParticleEffects then
                self:TriggerEffects("flamethrower_attack_start")
            end

            self.createParticleEffects = true

            if Server and not self.loopingFireSound:GetIsPlaying() then
                self.loopingFireSound:Start()
            end

        end

        if self.createParticleEffects and self:GetClip() == 0 then

            self.createParticleEffects = false

            if Server then
                self.loopingFireSound:Stop()
            end

        end

        -- Fire the cool flame effect periodically
        -- Don't crank the period too low - too many effects slows down the game a lot.
        if Client and self.createParticleEffects and self.lastAttackEffectTime + 0.5 < Shared.GetTime() then

            self:TriggerEffects("flamethrower_attack")
            self.lastAttackEffectTime = Shared.GetTime()

        end

    end

end

function Flamethrower:OnPrimaryAttackEnd(player)

    ClipWeapon.OnPrimaryAttackEnd(self, player)

    self.createParticleEffects = false

    if Server then
        self.loopingFireSound:Stop()
    end

end

function Flamethrower:OnReload(player)

    if self:CanReload() then

        if Server then

            self.createParticleEffects = false
            self.loopingFireSound:Stop()

        end

        self:TriggerEffects("reload")
        self.reloading = true

    end

end

function Flamethrower:GetHasSecondary(player)
    return false
end

function Flamethrower:GetSwingSensitivity()
    return 0.8
end

function Flamethrower:Dropped(prevOwner)

    ClipWeapon.Dropped(self, prevOwner)

    if Server then

        self.createParticleEffects = false
        self.loopingFireSound:Stop()

    end

end

function Flamethrower:GetAmmoPackMapName()
    return FlamethrowerAmmo.kMapName
end

function Flamethrower:GetNotifiyTarget()
    return false
end

function Flamethrower:GetIdleAnimations(index)
    local animations = {"idle", "idle_fingers", "idle_clean"}
    return animations[index]
end

function Flamethrower:ModifyDamageTaken(damageTable, attacker, doer, damageType)
    if damageType ~= kDamageType.Corrode then
        damageTable.damage = 0
    end
end

function Flamethrower:GetCanTakeDamageOverride()
    return self:GetParent() == nil
end

if Server then

    function Flamethrower:GetDestroyOnKill()
        return true
    end

    function Flamethrower:GetSendDeathMessageOverride()
        return false
    end

end

if Client then

    function Flamethrower:GetUIDisplaySettings()
        return { xSize = 128, ySize = 256, script = "lua/GUIFlamethrowerDisplay.lua", variant = self:GetFlamethrowerVariant() }
    end

end

Shared.LinkClassToMap("Flamethrower", Flamethrower.kMapName, networkVars)