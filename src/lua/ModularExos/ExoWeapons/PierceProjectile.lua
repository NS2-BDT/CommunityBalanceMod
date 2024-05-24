-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\PierceProjectile.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

PierceProjectileShooterMixin = CreateMixin(PierceProjectileShooterMixin)
PierceProjectileShooterMixin.type = "PierceProjectile"

local minSpeedSquared = 0.001 * 0.001
local function UpdateRenderCoords(self)

    if not self.renderCoords then
        self.renderCoords = Coords.GetIdentity()
    end

    if not self.lastOrigin and self.velocity then
        self.lastOrigin = self:GetOrigin() - self.velocity
    end

    if self.lastOrigin and self.lastOrigin ~= self:GetOrigin() then

        local direction = self:GetOrigin() - self.lastOrigin
        if direction:GetLengthSquared() > minSpeedSquared then
            direction:Normalize()
            self.renderCoords.zAxis = direction
            self.renderCoords.xAxis = self.renderCoords.yAxis:CrossProduct(self.renderCoords.zAxis)
            self.renderCoords.xAxis:Normalize()
            self.renderCoords.yAxis = self.renderCoords.zAxis:CrossProduct(self.renderCoords.xAxis)
            self.renderCoords.yAxis:Normalize()

        end
    end

    self.renderCoords.origin = self:GetOrigin()
    self.lastOrigin = self:GetOrigin()

end

local kMaxNumProjectiles = 200

function PierceProjectileShooterMixin:__initmixin()
    self.nextProjectileId = 1
    self.PierceProjectiles = {}
    self.PierceProjectilesList = unique_set()
end

function PierceProjectileShooterMixin:CreatePierceProjectile(className, startPoint, velocity, bounce, friction, gravity, physicsMaskOverride, shotDamage, shotDOTDamage, shotHitBoxSize, shotDamageRadius, ChargePercent, player)

    if Predict or (not Server and _G[className].kUseServerPosition) then
        return nil
    end

    local clearOnImpact = _G[className].kClearOnImpact
    local detonateWithTeam = _G[className].kClearOnEnemyImpact and GetEnemyTeamNumber(self:GetTeamNumber()) or -1
    local detonateRadius = _G[className].kDetonateRadius
    local minLifeTime = _G[className].kMinLifeTime

    local projectile
    local projectileController = PierceProjectileController()
    projectileController:Initialize(startPoint, velocity, shotHitBoxSize, self, bounce, friction, gravity, detonateWithTeam, clearOnImpact, minLifeTime, detonateRadius, shotDamage, shotDOTDamage, shotDamageRadius, ChargePercent, player)
    projectileController.projectileId = self.nextProjectileId
	
	cinematicName = _G[className].kProjectileCinematic	
	projectileController.modelName = _G[className].kModelName

    if physicsMaskOverride then
        projectileController:SetControllerPhysicsMask(physicsMaskOverride)
    end

    local projectileEntId = Entity.invalidId

    if Server then

        projectile = CreateEntity(_G[className].kMapName, startPoint, self:GetTeamNumber())
        projectile.projectileId = self.nextProjectileId
        projectileEntId = projectile:GetId()
			
        projectile:SetOwner(self)

		projectile.LastEntityHit = projectile:GetId()

        projectile:SetPierceProjectileController(projectileController, self.isHallucination == true)

    end

    local projectileModel
    local projectileCinematic
	
    if Client then

        local coords = Coords.GetLookIn(startPoint, GetNormalizedVector(velocity))

        if projectileController.modelName then

            local modelIndex = Shared.GetModelIndex(projectileController.modelName)
            if modelIndex then

                projectileModel = Client.CreateRenderModel(RenderScene.Zone_Default)
                projectileModel:SetModel(modelIndex)
				projectileModel:SetCoords(coords)

            end

        end

        if cinematicName then

            projectileCinematic = Client.CreateCinematic(RenderScene.Zone_Default, false, true)
            projectileCinematic:SetCinematic(cinematicName)
            projectileCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
            projectileCinematic:SetIsVisible(true)
            projectileCinematic:SetCoords(coords)

        end

    end

    self.PierceProjectiles[self.nextProjectileId] = { Controller = projectileController, Model = projectileModel, EntityId = projectileEntId, CreationTime = Shared.GetTime(), Cinematic = projectileCinematic}
    self.PierceProjectilesList:Insert(self.nextProjectileId)

    if not _G[className].kUseServerPosition then

        self.nextProjectileId = self.nextProjectileId + 1
        if self.nextProjectileId > kMaxNumProjectiles then
            self.nextProjectileId = 1
        end

    end

    return projectile

end

local function UpdateProjectiles(self, input, predict)

    local cleanUp = {}

    for _, projectileId in ipairs(self.PierceProjectilesList:GetList()) do

        local entry = self.PierceProjectiles[projectileId]
        local projectile = Shared.GetEntity(entry.EntityId)
		
        if not predict then
            entry.Controller:Update(input.time, projectile, predict)
        end

        if not Server then

            UpdateRenderCoords(entry.Controller)

            local renderCoords = entry.Controller.renderCoords

            local isVisible = entry.Controller.stopSimulation ~= true

            if entry.Model then
                entry.Model:SetCoords(renderCoords)
                entry.Model:SetIsVisible(isVisible)

            end

            if entry.Cinematic then
                entry.Cinematic:SetCoords(renderCoords)
                entry.Cinematic:SetIsVisible(isVisible)
            end

        end

        if entry.EntityId == Entity.invalidId and Shared.GetTime() - entry.CreationTime > 5 then
            table.insert(cleanUp, projectileId)
        end

    end

    for i = 1, #cleanUp do
        self:SetProjectileDestroyed(cleanUp[i])
    end

end
if Server then
    function PierceProjectileShooterMixin:OnProcessMove(input)
        UpdateProjectiles(self, input, false)
    end
elseif Client then
    function PierceProjectileShooterMixin:OnProcessIntermediate(input)
        UpdateProjectiles(self, input, false)
    end
end

function PierceProjectileShooterMixin:OnEntityChange(oldId)

    for _, projectileId in ipairs(self.PierceProjectilesList:GetList()) do

        local entry = self.PierceProjectiles[projectileId]
        if entry.EntityId == oldId then

            self:SetProjectileDestroyed(projectileId)
            break

        end

    end

end

local function DestroyProjectiles(self)

    for _, projectileId in ipairs(self.PierceProjectilesList:GetList()) do

        local entry = self.PierceProjectiles[projectileId]
        local projectile = Shared.GetEntity(entry.EntityId)
        if projectile then

            projectile:SetPierceProjectileController(entry.Controller, true)
            if entry.Model then
                Client.DestroyRenderModel(entry.Model)
            end

            if entry.Cinematic then
                Client.DestroyCinematic(entry.Cinematic)
            end

        end

    end

    self.PierceProjectiles = {}
    self.PierceProjectilesList:Clear()

end

if Server then

    function PierceProjectileShooterMixin:OnUpdate()
        PROFILE("PierceProjectileShooterMixin:OnUpdate")
        DestroyProjectiles(self)
    end

end

function PierceProjectileShooterMixin:OnDestroy()
    DestroyProjectiles(self)
end

function PierceProjectileShooterMixin:SetProjectileEntity(projectile)

    local entry = self.PierceProjectiles[projectile.projectileId]
    if entry then
        entry.EntityId = projectile:GetId()
    end

end

function PierceProjectileShooterMixin:SetProjectileDestroyed(projectileId)

    local entry = self.PierceProjectiles[projectileId]

    if entry then

        if entry.Model then
            Client.DestroyRenderModel(entry.Model)
        end

        if entry.Cinematic then
            Client.DestroyCinematic(entry.Cinematic)
        end

        if entry.Controller then

            entry.Controller:Uninitialize()
        end

        self.PierceProjectiles[projectileId] = nil
        self.PierceProjectilesList:Remove(projectileId)

    else
        if Shared.GetTestsEnabled() then
            Log("WARNING: No entry found for projectile")
        end
    end

end

class 'PierceProjectileController'

function PierceProjectileController:Initialize(startPoint, velocity, radius, predictor, bounce, friction, gravity, detonateWithTeam, clearOnImpact, minLifeTime, detonateRadius, shotDamage, shotDOTDamage, shotDamageRadius, ChargePercent, player)

    self.creationTime = Shared.GetTime()

    self.controller = Shared.CreateCollisionObject(predictor)
    self.controller:SetPhysicsType(CollisionObject.Kinematic)
    self.controller:SetGroup(PhysicsGroup.ProjectileGroup)
    self.controller:SetupSphere(radius or 0.1, self.controller:GetCoords(), false)

	self.hitboxRadius = radius or 0.1
    self.velocity = Vector(velocity)
    self.bounce = bounce or 0.5
    self.friction = friction or 0
    self.gravity = gravity or 9.81

    self.controller:SetPosition(startPoint, false)

    self.minLifeTime = minLifeTime or 0
    self.detonateRadius = detonateRadius or nil
    self.detonateWithTeam = detonateWithTeam
    self.clearOnImpact = clearOnImpact
	
	self.shotDamage = shotDamage or 10
	self.shotDOTDamage = shotDOTDamage or 0
	self.shotDamageRadius = shotDamageRadius or 0
	
	self.ChargePercent = ChargePercent or 0
	self.player = player

end

function PierceProjectileController:SetControllerPhysicsMask(mask)
    self.mask = mask
end

function PierceProjectileController:Move(deltaTime, velocity, projectile)

    local hitEntity, normal, impact, endPoint

    for _ = 1, 3 do

        local offset = velocity * deltaTime

        if offset:GetLengthSquared() <= 0.0 then
            break
        end
		
		self.controller:SetupSphere(self.hitboxRadius, self.controller:GetCoords(), false)
		local traceEntity = self.controller:Move(0.5*offset, CollisionRep.Damage, CollisionRep.Damage, self.mask or PhysicsMask.PredictedProjectileGroup)
		
		self.controller:SetupSphere(0.01, self.controller:GetCoords(), false)
        local traceGeo = self.controller:Move(0.5*offset, CollisionRep.Damage, CollisionRep.Damage, self.mask or PhysicsMask.PredictedProjectileGroup)
				
		if traceEntity.fraction < 1 and traceEntity.entity then           

			impact = true

            endPoint = Vector(traceEntity.endPoint)

            deltaTime = deltaTime * (1-traceEntity.fraction)

            normal = Vector(traceEntity.normal)

            hitEntity = traceEntity.entity

            if normal then
                normal:Normalize()

                local newVel = velocity - 2 * velocity:DotProduct(normal) * normal

                local perpendicular = (velocity + newVel) * 0.5

                newVel = newVel - newVel:GetProjection(normal) * (1-self.bounce) - perpendicular * self.friction

                VectorCopy(newVel, velocity)
			end
		elseif traceGeo.fraction < 1 then

            impact = true

            endPoint = Vector(traceGeo.endPoint)

            deltaTime = deltaTime * (1-traceGeo.fraction)

            normal = Vector(traceGeo.normal)
			
			if traceGeo.entity then
                hitEntity = traceGeo.entity
            end
			
            if normal then
                normal:Normalize()

                local newVel = velocity - 2 * velocity:DotProduct(normal) * normal

                local perpendicular = (velocity + newVel) * 0.5

                newVel = newVel - newVel:GetProjection(normal) * (1-self.bounce) - perpendicular * self.friction

                VectorCopy(newVel, velocity)
			end
		else
			break
		end
	end

	return hitEntity, normal, impact, endPoint
end

function PierceProjectileController:Update(deltaTime, projectile, predict)

    if self.controller and not self.stopSimulation then

        local velocity = Vector(self.velocity)

        -- approx some leapfrog integration to get more accuracy
        velocity.y = velocity.y - deltaTime * self.gravity * 0.5

        -- update position (can bounce multiple times!)
        local hitEntity, normal, impact, endPoint = self:Move(deltaTime, velocity, projectile)

        -- second part of leapfrog
        velocity.y = velocity.y - deltaTime * self.gravity * 0.5

        if projectile and projectile.kMinVelocityToMove then --This fixes a grenade spazzing out
            if velocity:GetLength() < projectile.kMinVelocityToMove then
                velocity = Vector(0,0,0)
            end
        end

        local oldEnough = self.minLifeTime + self.creationTime <= Shared.GetTime()
        local hasBounced = self.hasBounced
		
        if impact then

            -- some projectiles may predict impact
            if projectile and oldEnough then --and not hasBounced

                projectile:SetOrigin(endPoint)

                if projectile.ProcessHit and (hitEntity or not projectile.kNeedsHitEntity) then
                    projectile:ProcessHit(hitEntity, nil, normal, endPoint, self.shotDamage, self.shotDOTDamage, self.shotDamageRadius, self.ChargePercent)
                end

            end

            self.stopSimulation = self.clearOnImpact or (not self.hasBounced and hitEntity ~= nil and HasMixin(hitEntity, "Team") and hitEntity:GetTeamNumber() == self.detonateWithTeam )
            self.stopSimulation = self.stopSimulation and oldEnough

            if not Shared.GetIsRunningPrediction() then
                self.hasBounced = true
            end
        else


            if not Shared.GetIsRunningPrediction() and projectile and oldEnough and self.detonateRadius and projectile.ProcessNearMiss and not hasBounced then

                local startPoint = projectile:GetOrigin()
                endPoint = self:GetOrigin()

                -- this uses MOVE and a different filter
                local trace = Shared.TraceCapsule( startPoint, endPoint, self.detonateRadius, 0, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(projectile) )

                if trace.fraction ~= 1 then
                    projectile:SetOrigin( trace.endPoint )
                    if projectile:ProcessNearMiss( trace.entity, nil,  trace.endPoint ) then
                        self.stopSimulation = true
                    end
                end
            end
        end

        if not predict then
            VectorCopy(velocity, self.velocity)
        end
    end
end

function PierceProjectileController:GetCoords()

    if self.controller then
        return self.controller:GetCoords()
    end

end

function PierceProjectileController:GetPosition()
    return self.controller:GetPosition()
end

function PierceProjectileController:GetOrigin()
    return self.controller:GetPosition()
end

function PierceProjectileController:Uninitialize()

    if self.controller ~= nil then

        Shared.DestroyCollisionObject(self.controller)
        self.controller = nil

    end

end

class 'PierceProjectile' (Entity)

PierceProjectile.kMapName = "Pierceprojectile"

local networkVars =
{
    ownerId = "entityid",
    projectileId = "integer",
    m_angles = "interpolated angles (by 10 [], by 10 [], by 10 [])",
    m_origin = "compensated interpolated position (by 0.05 [2 3 5], by 0.05 [2 3 5], by 0.05 [2 3 5])",
}

AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)

function PierceProjectile:OnCreate()

    Entity.OnCreate(self)

    InitMixin(self, EffectsMixin)
    InitMixin(self, TechMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)

    if Server then

        InitMixin(self, InvalidOriginMixin)
        InitMixin(self, OwnerMixin)

    end

    self:SetUpdates(true, kRealTimeUpdateRate)
    self:SetRelevancyDistance(kMaxRelevancyDistance)

    self:SetPhysicsCullable(false)

end

function PierceProjectile:OverrideCheckVision()
    return false
end

function PierceProjectile:OnInitialized()

    if Client then

        local owner = Shared.GetEntity(self.ownerId)

        if not self.kUseServerPosition and owner and owner == Client.GetLocalPlayer() and Client.GetIsControllingPlayer() then
            owner:SetProjectileEntity(self)
        else

            if self.kModelName then

                local modelIndex = Shared.GetModelIndex(self.kModelName)
                if modelIndex then
                    self.renderModel = Client.CreateRenderModel(RenderScene.Zone_Default)
                    self.renderModel:SetModel(modelIndex)
                end

            end

            if self.kProjectileCinematic then

                self.projectileCinematic = Client.CreateCinematic(RenderScene.Zone_Default, false, true)
                self.projectileCinematic:SetCinematic(self.kProjectileCinematic)
                self.projectileCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
                self.projectileCinematic:SetIsVisible(true)
                self.projectileCinematic:SetCoords(self:GetCoords())

            end

        end

    end

end

function PierceProjectile:OnDestroy()

    if self.projectileController then

        self.projectileController:Uninitialize()
        self.projectileController = nil

    end

    if self.renderModel then

        Client.DestroyRenderModel(self.renderModel)
        self.renderModel = nil

    end

    if self.projectileCinematic then

        Client.DestroyCinematic(self.projectileCinematic)
        self.projectileCinematic = nil

    end

    if Client then

        local owner = Shared.GetEntity(self.ownerId)

        if owner and owner == Client.GetLocalPlayer() then
            owner:SetProjectileDestroyed(self.projectileId)
        end


    end

end

function PierceProjectile:GetVelocity()

    if self.projectileController then
        return Vector(self.projectileController.velocity)
    end

    return Vector(0,0,0)

end

function PierceProjectile:SetPierceProjectileController(controller, selfUpdate)
    self.projectileController = controller
    self.selfUpdate = selfUpdate
end

function PierceProjectile:SetControllerPhysicsMask(mask)
    if self.projectileController then
        self.projectileController:SetControllerPhysicsMask(mask)
    end
end
if Server then

    function PierceProjectile:OnUpdate(deltaTime)

        if self.projectileController then

            if self.selfUpdate then
                self.projectileController:Update(deltaTime, self)
            end

            if self.projectileController then
                self:SetOrigin(self.projectileController:GetOrigin())
            end

        end

    end

end

if Client then
    function PierceProjectile:OnUpdate(deltaTime)
        Entity.OnUpdate(self, deltaTime)
        UpdateRenderCoords(self)

        if self.renderModel then
            self.renderModel:SetCoords(self.renderCoords)
        end

        if self.projectileCinematic then
            self.projectileCinematic:SetCoords(self.renderCoords)
        end

    end
end

Shared.LinkClassToMap("PierceProjectile", PierceProjectile.kMapName, networkVars, true)



-------------------------------------------------------------------------------
--Debug / Testing utils

if Server then

    local gDebugGrenadeDamageRadius = false
    function SetDebugGrenadeDamageRadius(enabled)
        gDebugGrenadeDamageRadius = enabled
        Log("Grenade debug %s", (gDebugGrenadeDamageRadius and  "ENABLED" or  "DISABLED"))
    end

    function GetDebugGrenadeDamage() 
        return gDebugGrenadeDamageRadius
    end

end