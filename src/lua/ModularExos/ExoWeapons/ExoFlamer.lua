Script.Load("lua/Weapons/Marine/Flame.lua")
Script.Load("lua/Weapons/Weapon.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponHolder.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponSlotMixin.lua")
Script.Load("lua/TechMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/EffectsMixin.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")
Script.Load("lua/Weapons/BulletsMixin.lua")

class 'ExoFlamer'(Entity)

ExoFlamer.kMapName = "exoflamer"

if Client then
    Script.Load("lua/ModularExos/ExoWeapons/ExoFlamer_Client.lua")
end

ExoFlamer.kMapName = "exoflamer"

ExoFlamer.kModelName = PrecacheAsset("models/marine/flamethrower/flamethrower.model")
local kAnimationGraph = PrecacheAsset("models/marine/flamethrower/flamethrower_view.animation_graph")
local kFireLoopingSound = PrecacheAsset("sound/NS2.fev/marine/flamethrower/attack_loop")
local kRange = kExoFlamerRange

local kHeatUISoundName = PrecacheAsset("sound/NS2.fev/marine/heavy/heat_UI")
local kOverheatedSoundName = PrecacheAsset("sound/NS2.fev/marine/heavy/overheated")

local networkVars = {
    createParticleEffects = "boolean",
    animationDoneTime     = "float",
    range                 = "integer (0 to 11)",
    isShooting            = "boolean",
    loopingSoundEntId     = "entityid",
    heatAmount            = "float (0 to 1 by 0.01)",
    overheated            = "private boolean",
    heatUISoundId         = "private entityid"
    
}

AddMixinNetworkVars(ExoWeaponSlotMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(PointGiverMixin, networkVars)

function ExoFlamer:OnCreate()
    Entity.OnCreate(self)
    
    self.lastAttackApplyTime = 0
    
    self.isShooting = false
    InitMixin(self, ExoWeaponSlotMixin)
    InitMixin(self, TechMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, BulletsMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, EffectsMixin)
    
    self.timeWeldStarted = 0
    self.timeLastWeld = 0
    self.loopingSoundEntId = Entity.invalidId
    self.range = 10
    self.heatAmount = 0
    self.overheated = false
    
    if Server then
        self.lastAttackApplyTime = 0
        
        self.createParticleEffects = false
        self.loopingFireSound = Server.CreateEntity(SoundEffect.kMapName)
        self.loopingFireSound:SetAsset(kFireLoopingSound)
        -- SoundEffect will automatically be destroyed when the parent is destroyed (the Welder).
        self.loopingFireSound:SetParent(self)
        self.loopingSoundEntId = self.loopingFireSound:GetId()
        
        self.heatUISound = Server.CreateEntity(SoundEffect.kMapName)
        self.heatUISound:SetAsset(kHeatUISoundName)
        self.heatUISound:SetParent(self)
        self.heatUISound:Start()
        self.heatUISoundId = self.heatUISound:GetId()
    
    elseif Client then
        self:SetUpdates(true)
        self.lastAttackEffectTime = 0.0
        self.lastAttackApplyTime = 0
    end
end

function ExoFlamer:OnInitialized()
    Entity.OnInitialized(self)
end

function ExoFlamer:OnDestroy()
    Entity.OnDestroy(self)
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
        if self.heatDisplayUI then
            
            Client.DestroyGUIView(self.heatDisplayUI)
            self.heatDisplayUI = nil
        end
    end
end

function ExoFlamer:OnUpdateAnimationInput(modelMixin)
    PROFILE("ExoFlamer:OnUpdateAnimationInput")
    local parent = self:GetParent()
    local activity = self.isShooting and "primary" or "none"
    -- modelMixin:SetAnimationInput("activity_" .. self:GetExoWeaponSlotName(), activity)
end

function ExoFlamer:ModifyMaxSpeed(maxSpeedTable)
    if self.isShooting then
        maxSpeedTable.maxSpeed = maxSpeedTable.maxSpeed * kMinigunMovementSlowdown
    end
end

function ExoFlamer:GetIsAffectedByWeaponUpgrades()
    return true
end

function ExoFlamer:CreatePrimaryAttackEffect(player)
    -- Remember this so we can update gun_loop pose param
    self.timeOfLastPrimaryAttack = Shared.GetTime()
end

function ExoFlamer:GetRange()
    return kExoFlamerRange
end

function ExoFlamer:BurnSporesAndUmbra(startPoint, endPoint)
    
    local toTarget = endPoint - startPoint
    local distanceToTarget = toTarget:GetLength()
    toTarget:Normalize()
    
    local stepLength = 2
    
    for i = 1, 5 do
        
        -- stop when target has reached, any spores would be behind
        if distanceToTarget < i * stepLength then
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
            bomb:TriggerEffects("burn_bomb", { effecthostcoords = Coords.GetTranslation(bomb:GetOrigin()) })
            DestroyEntity(bomb)
            burnSpent = true
        end
        
        for i = 1, #spores do
            local spore = spores[i]
            self:TriggerEffects("burn_spore", { effecthostcoords = Coords.GetTranslation(spore:GetOrigin()) })
            DestroyEntity(spore)
            burnSpent = true
        end
        
        for i = 1, #clouds do
            local cloud = clouds[i]
            self:TriggerEffects("burn_umbra", { effecthostcoords = Coords.GetTranslation(cloud:GetOrigin()) })
            DestroyEntity(cloud)
            burnSpent = true
        end
        
        if burnSpent then
            break
        end
    
    end

end

function ExoFlamer:CreateFlame(player, position, normal, direction)
    
    -- create flame entity, but prevent spamming:
    local nearbyFlames = GetEntitiesForTeamWithinRange("Flame", player:GetTeamNumber(), position, 1.5)
    
    if #nearbyFlames == 0 then
        
        local flame = CreateEntity(Flame.kMapName, position, player:GetTeamNumber())
        flame:SetOwner(player)
        
        local coords = Coords.GetTranslation(position)
        coords.yAxis = normal
        coords.zAxis = direction
        
        coords.xAxis = coords.yAxis:CrossProduct(coords.zAxis)
        coords.xAxis:Normalize()
        
        coords.zAxis = coords.xAxis:CrossProduct(coords.yAxis)
        coords.zAxis:Normalize()
        
        flame:SetCoords(coords)
    
    end


end

function ExoFlamer:GetMeleeOffset()
    
    return 0

end

function ExoFlamer:ApplyConeDamage(player)
    
    local eyePos = player:GetEyePos()
    local ents = {}
    
    local fireDirection = player:GetViewCoords().zAxis
    local extents = Vector(ExoFlamer.kConeWidth, ExoFlamer.kConeWidth, ExoFlamer.kConeWidth)
    local range = self:GetRange()
    
    local startPoint = Vector(eyePos)
    local filterEnts = { self, player }
    local trace = TraceMeleeBox(self, startPoint, fireDirection, extents, range, PhysicsMask.Flame, EntityFilterList(filterEnts))
    
    local endPoint = trace.endPoint
    local normal = trace.normal
    
    if Server then
        self:BurnSporesAndUmbra(startPoint, endPoint)
    end
    
    if trace.fraction ~= 1 then
        
        local traceEnt = trace.entity
        if traceEnt and HasMixin(traceEnt, "Live") and traceEnt:GetCanTakeDamage() then
            table.insert(ents, traceEnt)
        end
        
        local hitEntities = GetEntitiesWithMixinWithinXZRange("Live", endPoint, self.kDamageRadius)
        local damageHeight = self.kDamageRadius / 2
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
    
    local attackDamage = ExoFlamer.kExoFlamerDamage
    for i = 1, #ents do
        
        local ent = ents[i]
        local enemyOrigin = ent:GetModelOrigin()
        
        if ent ~= player and enemyOrigin then
            
            local toEnemy = GetNormalizedVector(enemyOrigin - eyePos)
            
            local health = ent:GetHealth()
            self:DoDamage(attackDamage, ent, enemyOrigin, toEnemy)
            
            -- Only light on fire if we successfully damaged them
            if ent:GetHealth() ~= health and HasMixin(ent, "Fire") then
                ent:SetOnFire(player, self)
            end
        
        end
    
    end
end

function ExoFlamer:GetBarrelPoint()
    local player = self:GetParent()
    if player then
        if Client and player:GetIsLocalPlayer() then
            local origin = player:GetEyePos()
            local viewCoords = player:GetViewCoords()
            
            if self:GetIsLeftSlot() then
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * 0.65 + viewCoords.yAxis * -0.19
            else
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * -0.65 + viewCoords.yAxis * -0.19
            end
        else
            local origin = player:GetEyePos()
            local viewCoords = player:GetViewCoords()
            
            if self:GetIsLeftSlot() then
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * 0.35 + viewCoords.yAxis * -0.15
            else
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * -0.35 + viewCoords.yAxis * -0.15
            end
        end
    end
    return self:GetOrigin()
end

function ExoFlamer:ShootFlame(player)
    
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
        local angles = Angles(0, 0, 0)
        angles.yaw = GetYawFromVector(trace.normal)
        angles.pitch = GetPitchFromVector(trace.normal) + (math.pi / 2)
        
        local normalCoords = angles:GetCoords()
        normalCoords.origin = trace.endPoint
        range = range - 3
    end
    
    self:ApplyConeDamage(player)


end

function ExoFlamer:FirePrimary(player)
    self:ShootFlame(player)
end

function ExoFlamer:OnTag(tagName)
    PROFILE("ExoWelder:OnTag")
    if not self:GetIsLeftSlot() then
        if tagName == "deploy_end" then
            self.deployed = true
        end
    end
end

function ExoFlamer:OnPrimaryAttack(player)
    
    PROFILE("ExoFlamer:OnPrimaryAttack")
    if not self.overheated then
        if not self.isShooting then
            if not self.createParticleEffects then
                if self:GetIsLeftSlot() then
                    player:TriggerEffects("leftexoflamer_muzzle")
                elseif self:GetIsRightSlot() then
                    player:TriggerEffects("rightexoflamer_muzzle")
                end
            end
            self.createParticleEffects = true
            if Server and not self.loopingFireSound:GetIsPlaying() then
                self.loopingFireSound:Start()
            end
        end
        
        self.isShooting = true
    end
    
    if Client and self.createParticleEffects and self.lastAttackEffectTime + ExoFlamer.kFireRate < Shared.GetTime() then
        if self:GetIsLeftSlot() then
            player:TriggerEffects("leftexoflamer_muzzle")
        elseif self:GetIsRightSlot() then
            player:TriggerEffects("rightexoflamer_muzzle")
        end
        self.lastAttackEffectTime = Shared.GetTime()
    end
    if not self.overheated and self.lastAttackApplyTime + ExoFlamer.kFireRate < Shared.GetTime() then
        self:ShootFlame(player)
        self.lastAttackApplyTime = Shared.GetTime()
    end
end

local function UpdateOverheated(self, player)
    
    if not self.overheated and self.heatAmount == 1 then
        
        self.overheated = true
        self:OnPrimaryAttackEnd(player)
        
        --[[        if self:GetIsLeftSlot() then
                    player:TriggerEffects("minigun_overheated_left")
                elseif self:GetIsRightSlot() then
                    player:TriggerEffects("minigun_overheated_right")
                end    ]]
        
        StartSoundEffectForPlayer(kOverheatedSoundName, player)
    
    end
    
    if self.overheated and self.heatAmount == 0 then
        self.overheated = false
    end

end

function ExoFlamer:AddHeat(amount)
    self.heatAmount = self.heatAmount + amount

end

function ExoFlamer:GetDeathIconIndex()
    return kDeathMessageIcon.Flamethrower
end

function ExoFlamer:OnPrimaryAttackEnd(player)
    if self.isShooting then
        self.createParticleEffects = false
        if Server then
            self.loopingFireSound:Stop()
        end
    end
    self.isShooting = false

end

function ExoFlamer:OnReload(player)
    if self:CanReload() then
        if Server then
            self.createParticleEffects = false
            self.loopingFireSound:Stop()
        end
        self:TriggerEffects("reload")
        self.reloading = true
    end
end

function ExoFlamer:ProcessMoveOnWeapon(player, input)
    local dt = input.time
    local addAmount = self.isShooting and (dt * ExoFlamer.kHeatUpRate) or -(dt * ExoFlamer.kCoolDownRate)
    self.heatAmount = math.min(1, math.max(0, self.heatAmount + addAmount))
    
    UpdateOverheated(self, player)
    
    if self.isShooting and not self.overheated then
        
        local exoWeaponHolder = player:GetActiveWeapon()
        if exoWeaponHolder then
            
            local otherSlotWeapon = self:GetExoWeaponSlot() == ExoWeaponHolder.kSlotNames.Left and exoWeaponHolder:GetRightSlotWeapon() or exoWeaponHolder:GetLeftSlotWeapon()
            if otherSlotWeapon and otherSlotWeapon:isa("ExoFlamer") then
                otherSlotWeapon:AddHeat(dt * ExoFlamer.kDualGunHeatUpRate)
            end
        
        end
    end
    
    if Client and not Shared.GetIsRunningPrediction() then
        
        if player:GetIsLocalPlayer() then
            
            --local heatUISound = Shared.GetEntity(self.heatUISoundId)
            -- heatUISound:SetParameter("heat", self.heatAmount, 1)
        
        end
    
    end

end

function ExoFlamer:GetNotifiyTarget()
    return false
end

function ExoFlamer:ModifyDamageTaken(damageTable, attacker, doer, damageType)
    if damageType ~= kDamageType.Corrode then
        damageTable.damage = 0
    end
end

function ExoFlamer:GetRange()
    return self.range
end

function ExoFlamer:UpdateViewModelPoseParameters(viewModel)
    viewModel:SetPoseParam("welder", 1)
end

function ExoFlamer:OnUpdatePoseParameters(viewModel)
    PROFILE("ExoFlamer:OnUpdatePoseParameters")
    self:SetPoseParam("welder", 1)
end

Shared.LinkClassToMap("ExoFlamer", ExoFlamer.kMapName, networkVars)
