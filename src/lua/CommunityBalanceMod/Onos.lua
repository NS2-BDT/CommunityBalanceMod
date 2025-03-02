-- Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Onos.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- Gore attack should send players flying (doesn't have to be ragdoll). Stomp will stun
-- marines in range and blow up mines.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Utility.lua")
Script.Load("lua/Weapons/Alien/Gore.lua")
Script.Load("lua/Weapons/Alien/BoneShield.lua")
Script.Load("lua/Alien.lua")
Script.Load("lua/Mixins/BaseMoveMixin.lua")
Script.Load("lua/Mixins/GroundMoveMixin.lua")
Script.Load("lua/Mixins/JumpMoveMixin.lua")
Script.Load("lua/Mixins/CrouchMoveMixin.lua")
Script.Load("lua/CelerityMixin.lua")
Script.Load("lua/Mixins/CameraHolderMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/BabblerClingMixin.lua")
Script.Load("lua/TunnelUserMixin.lua")
Script.Load("lua/RailgunTargetMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/OnosVariantMixin.lua")

class 'Onos' (Alien)

Onos.kMapName = "onos"
Onos.kModelName = PrecacheAsset("models/alien/onos/onos.model")
local kViewModelName = PrecacheAsset("models/alien/onos/onos_view.model")

local kOnosAnimationGraph = PrecacheAsset("models/alien/onos/onos.animation_graph")

local kChargeStart = PrecacheAsset("sound/NS2.fev/alien/onos/wound_serious")
local kRumbleSound = PrecacheAsset("sound/NS2.fev/alien/onos/rumble")

Onos.kStampedeDefaultSettings =
{
    kChargeImpactForce = 1.2,
    kChargeDiffForce = 10,
    kChargeUpForce = 6.5,
    kDisableDuration = 0.2,
}

-- Mods can add their own overrides for other classes.
Onos.kStampedeOverrideSettings = Onos.kStampedeOverrideSettings or {}
Onos.kStampedeOverrideSettings["Exo"] = 
{
    kChargeImpactForce = 0.6,
    kChargeDiffForce = 5,
    kChargeUpForce = 1,
    kDisableDuration = 0.05,
}

Onos.kJumpForce = 20
Onos.kJumpVerticalVelocity = 8

Onos.kJumpRepeatTime = .25
Onos.kViewOffsetHeight = 2.5
Onos.XExtents = .7
Onos.YExtents = 1.2
Onos.ZExtents = .4
Onos.kMass = 453 -- Half a ton
Onos.kJumpHeight = 1.15

-- triggered when the momentum value has changed by this amount (negative because we trigger the effect when the onos stops, not accelerates)
Onos.kMomentumEffectTriggerDiff = 3

Onos.kGroundFrictionForce = 3

-- used for animations and sound effects
Onos.kMaxSpeed = 6.6
Onos.kChargeSpeed = 12.5

Onos.kHealth = kOnosHealth
Onos.kArmor = kOnosArmor
Onos.kChargeEnergyCost = kChargeEnergyCost

Onos.kChargeUpDuration = 0.5
Onos.kChargeDelay = 0.5

-- mouse sensitivity scalar during charging
Onos.kChargingSensScalar = 0

Onos.kStoopingCheckInterval = 0.3
Onos.kStoopingAnimationSpeed = 2
Onos.kYHeadExtents = 0.7
Onos.kYHeadExtentsLowered = 0.0

Onos.kAutoCrouchCheckInterval = 0.4
Onos.kChargeExtents = Vector(1, 1.2, 1.2)
Onos.kStampedeCheckRadius = Onos.kChargeExtents:GetLength() + 1.5
Onos.kStampedePerMarineCooldown = 0.7

Onos.kAdrenalineEnergyRecuperationRate = kOnosAdrenalineEnergyRate
Onos.kBoneShieldActiveHitpointsRegenFactor = kBoneShieldActiveHitpointsRegenFactor

if Server then
    Script.Load("lua/Onos_Server.lua")
elseif Client then
    Script.Load("lua/Onos_Client.lua")
end

local networkVars =
{
    directionMomentum = "private float",
    stooping = "boolean",
    stoopIntensity = "compensated interpolated float",
    charging = "private compensated boolean",
    rumbleSoundId = "entityid",
    timeOfLastPhase = "private time",
}

AddMixinNetworkVars(BaseMoveMixin, networkVars)
AddMixinNetworkVars(GroundMoveMixin, networkVars)
AddMixinNetworkVars(JumpMoveMixin, networkVars)
AddMixinNetworkVars(CrouchMoveMixin, networkVars)
AddMixinNetworkVars(CelerityMixin, networkVars)
AddMixinNetworkVars(CameraHolderMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(BabblerClingMixin, networkVars)
AddMixinNetworkVars(TunnelUserMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(OnosVariantMixin, networkVars)

function Onos:OnCreate()

    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, JumpMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, CelerityMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kOnosFov })
    
    Alien.OnCreate(self)
    
    InitMixin(self, DissolveMixin)
    InitMixin(self, BabblerClingMixin)
    InitMixin(self, TunnelUserMixin)
    InitMixin(self, OnosVariantMixin)
    
    if Client then
    
        InitMixin(self, RailgunTargetMixin)
        self.boneShieldCrouchAmount = 0
        
    end
    
    self.directionMomentum = 0
    
    self.altAttack = false
    self.stooping = false
    self.charging = false
    self.stoopIntensity = 0
    self.timeLastCharge = 0
    self.timeLastChargeEnd = 0
    self.chargeSpeed = 0
    
    if Client then
        self:SetUpdates(true, kDefaultUpdateRate)
    elseif Server then
    
        self.rumbleSound = Server.CreateEntity(SoundEffect.kMapName)
        self.rumbleSound:SetAsset(kRumbleSound)
        self.rumbleSound:SetParent(self)
        self.rumbleSound:Start()
        self.rumbleSoundId = self.rumbleSound:GetId()
        
    end
    
end

function Onos:OnInitialized()

    Alien.OnInitialized(self)
    
    self:SetModel(Onos.kModelName, kOnosAnimationGraph)
    
    self:AddTimedCallback(Onos.UpdateStooping, Onos.kStoopingCheckInterval)
    
    if Client then
        self:AddHelpWidget("GUITunnelEntranceHelp", 1)
    end
    
    InitMixin(self, IdleMixin)

end

function Onos:GetControllerPhysicsGroup()

    if self.isHallucination then
        return PhysicsGroup.SmallStructuresGroup
    end

    return PhysicsGroup.BigPlayerControllersGroup
    
end

function Onos:GetAcceleration()
    return 6.5
end

function Onos:GetAirControl()
    return 4
end

function Onos:GetGroundFriction()
    return 6
end

function Onos:GetCarapaceSpeedReduction()
    return kOnosCarapaceSpeedReduction
end

function Onos:GetCrouchShrinkAmount()
    return 0.4
end

function Onos:GetExtentsCrouchShrinkAmount()
    return 0.4
end

function Onos:GetIsCharging()
    return self.charging
end

function Onos:GetCanJump()

    local weapon = self:GetActiveWeapon()
    local stomping = weapon and HasMixin(weapon, "Stomp") and weapon:GetIsStomping()

    return Alien.GetCanJump(self) and not stomping and not self:GetIsBoneShieldActive()
    
end

function Onos:OnKill()
    if self.rumbleSound ~= nil then
        self.rumbleSound:Stop()
    end

    Player.OnKill(self)
end

function Onos:GetPlayFootsteps()

    if GetHasCamouflageUpgrade(self) and self:GetCrouching() then
       return false
    end

    return self:GetVelocityLength() > .75 and self:GetIsOnGround() and self:GetIsAlive()
end

function Onos:GetCanCrouch()
    return Alien.GetCanCrouch(self) and not self.charging and not self:GetIsBoneShieldActive()
end

function Onos:GetChargeFraction()
    return ConditionalValue(self.charging, math.min(1, (Shared.GetTime() - self.timeLastCharge) / Onos.kChargeUpDuration ), 0)
end

function Onos:GetMovementSpecialCooldown()
    local cooldown = 0
    local timeLeft = (Shared.GetTime() - self.timeLastChargeEnd)

    local chargeDelay = self.kChargeDelay
    if timeLeft < chargeDelay then
        cooldown = 1-Clamp(timeLeft / chargeDelay, 0, 1)
    end

    return cooldown
end

function Onos:GetMovementSpecialEnergyCost()
    return self.kChargeEnergyCost
end

local function TriggerMomentumChangeEffects(entity, surface, direction, normal, extraEffectParams)

    if Client and math.abs(direction:GetLengthSquared() - 1) < 0.001 then
    
        local tableParams = { }
        
        tableParams[kEffectFilterDoerName] = entity:GetClassName()
        tableParams[kEffectSurface] = ConditionalValue(type(surface) == "string" and surface ~= "", surface, "metal")
        
        local coords = Coords.GetIdentity()
        coords.origin = entity:GetOrigin()
        coords.zAxis = direction
        coords.yAxis = normal
        coords.xAxis = coords.yAxis:CrossProduct(coords.zAxis)
        
        tableParams[kEffectHostCoords] = coords
        
        -- Add in extraEffectParams if specified
        if extraEffectParams then
        
            for key, element in pairs(extraEffectParams) do
                tableParams[key] = element
            end
            
        end
        
        GetEffectManager():TriggerEffects("momentum_change", tableParams)
        
    end
    
end

function Onos:EndCharge()

    local surface, normal = GetSurfaceAndNormalUnderEntity(self)

    -- align zAxis to player movement
    local moveDirection = self:GetVelocity()
    moveDirection:Normalize()
    
    TriggerMomentumChangeEffects(self, surface, moveDirection, normal)
    
    self.charging = false
    self.chargeSpeed = 0
    self.timeLastChargeEnd = Shared.GetTime()

end

function Onos:CanBeStampeded(ent)
    
    if ent.nextStampede and Shared.GetTime() < ent.nextStampede then
        return false
    end
    
    if not GetAreEnemies(self, ent) then
        return false
    end
    
    return true
end

function Onos:GetNearbyStampedeables(origin)
    local marines = GetEntitiesWithinRange("Marine", origin, Onos.kStampedeCheckRadius)
    local exos = GetEntitiesWithinRange("Exo", origin, Onos.kStampedeCheckRadius)
    local both = {}

    for i = 1, #marines do
        if self:CanBeStampeded(marines[i]) then
            table.insert(both, marines[i])
        end
    end

    for i = 1, #exos do
        if self:CanBeStampeded(exos[i]) then
            table.insert(both, exos[i])
        end
    end

    return both
end

function Onos:GetCanStampede()
    return self:GetWeapon(Gore.kMapName) and self:GetVelocity():GetLengthXZ() > 9
end

function Onos:Stampede()
    if not self:GetCanStampede() then return end

    local axis = self:GetViewAngles():GetCoords().zAxis
    local hitAxis = (axis * Vector(1, 0, 1)):GetUnit()
    local chargeExtends = Onos.kChargeExtents

    local hitOrigin = self:GetOrigin() + Vector(0, 1, 0) + (hitAxis * chargeExtends.z)
    local stampedables = self:GetNearbyStampedeables(hitOrigin)

    if #stampedables < 1 then return end 

    local hitboxCoords = Coords.GetLookIn(hitOrigin, hitAxis, Vector(0, 1, 0))
    local invHitboxCoords = hitboxCoords:GetInverse() -- could possibly optimize with Transpose() instead?
    for i = 1, #stampedables do
        local marine = stampedables[i]
        local localSpacePosition = invHitboxCoords:TransformPoint(marine:GetEngagementPoint())
        local extents = marine:GetExtents()

        -- If entity is touching box, impact it.
        if math.abs(localSpacePosition.x) <= chargeExtends.x + extents.x and
                math.abs(localSpacePosition.y) <= chargeExtends.y + extents.y and
                math.abs(localSpacePosition.z) <= chargeExtends.z + extents.z then

            self:Impact(marine)

        end
    end
end

function Onos:PreUpdateMove(input, runningPrediction)

    -- determines how manuverable the onos is. When not charging, manuverability is 1.
    -- when charging it goes towards zero as the speed increased. At zero, you can't strafe or change
    -- direction.
    -- The math.sqrt makes you drop manuverability quickly at the start and then drop it less and less
    -- the 0.8 cuts manuverability to zero before the max speed is reached
    -- Fiddle until it feels right.
    -- 0.8 allows about a 90 degree turn in atrium, ie you can start charging
    -- at the entrance, and take the first two stairs before you hit the lockdown.
    local manuverability = ConditionalValue(self.charging, math.max(0, 0.8 - math.sqrt(self:GetChargeFraction())), 1)
    
    if self.charging then
    
        -- fiddle here to determine strafing
        input.move.x = input.move.x * math.max(0.3, manuverability)
        input.move.z = 1
        
        self:DeductAbilityEnergy(Onos.kChargeEnergyCost * input.time)
        
        -- stop charging if out of energy, jumping or we have charged for a second and our speed drops below 4.5
        -- - changed from 0.5 to 1s, as otherwise touchin small obstactles orat started stopped you from charging
        if self:GetEnergy() == 0 or
          (self.timeLastCharge + 1 < Shared.GetTime() and self:GetVelocity():GetLengthXZ() < 4.5) then
        
            self:EndCharge()
            
        end
        
    end
    
    if Server then
        self:Stampede()
    end
    
    if self.autoCrouching then
        self.crouching = self.autoCrouching
    end
    
    if Client and self == Client.GetLocalPlayer() then
    
        -- Lower mouse sensitivity when charging, only affects the local player.
        Client.SetMouseSensitivityScalarX(manuverability)
        
    end
    
end

function Onos:GetAngleSmoothRate()
    return 5
end

function Onos:GetVelocitySmoothRate()
    return 8
end

function Onos:PostUpdateMove(input, runningPrediction)

    if self.charging then
    
        local xzSpeed = self:GetVelocity():GetLengthXZ()
        if xzSpeed > self.chargeSpeed then
            self.chargeSpeed = xzSpeed
        end    
    
    end

end

function Onos:GetAirFriction()
    return 0.28
end

function Onos:TriggerCharge(move)

    if not self.charging and self:GetHasMovementSpecial() and self.timeLastChargeEnd + Onos.kChargeDelay < Shared.GetTime() 
    and self:GetIsOnGround() and not self:GetCrouching() and not self:GetIsBoneShieldActive() then

        self.charging = true
        self.timeLastCharge = Shared.GetTime()
        
        if Server and (GetHasSilenceUpgrade(self) and self:GetVeilLevel() == 0) or not GetHasSilenceUpgrade(self) then
            self:TriggerEffects("onos_charge")
        end
        
        self:TriggerUncloak()
    
    end
    
end

function Onos:HandleButtons(input)

    Alien.HandleButtons(self, input)
    
    if self.movementModiferState then    
        self:TriggerCharge(input.move)        
    else
    
        if self.charging then
            self:EndCharge()
        end
    
    end

end

-- Required by ControllerMixin.
function Onos:GetMovePhysicsMask()
    return self:GetVelocity():GetLengthXZ() > 7.5 and PhysicsMask.OnosCharge or PhysicsMask.OnosMovement
end

function Onos:GetBaseArmor()
    return Onos.kArmor
end

function Onos:GetBaseHealth()
    return Onos.kHealth
end

function Onos:GetHealthPerBioMass()
    return kOnosHealtPerBioMass
end

function Onos:GetBaseCarapaceArmorBuff()
    return kOnosBaseCarapaceUpgradeAmount
end

function Onos:GetCarapaceBonusPerBiomass()
    return kOnosCarapaceArmorPerBiomass
end

function Onos:GetAdrenalineEnergyRechargeRate()
    return Onos.kAdrenalineEnergyRecuperationRate
end

function Onos:GetViewModelName()
    return self:GetVariantViewModel(self:GetVariant())
end

function Onos:GetMaxViewOffsetHeight()
    return Onos.kViewOffsetHeight
end 

function Onos:GetMaxSpeed(possible)

    if possible then
        return Onos.kMaxSpeed
    end

    local boneShieldSlowdown = self:GetIsBoneShieldActive() and kBoneShieldMoveFraction or 1
    local chargeExtra = self:GetChargeFraction() * (Onos.kChargeSpeed - Onos.kMaxSpeed)
    
    return ( Onos.kMaxSpeed + chargeExtra ) * boneShieldSlowdown

end

-- Half a ton
function Onos:GetMass()
    return Onos.kMass
end

function Onos:GetJumpHeight()
    return Onos.kJumpHeight
end

function Onos:GetMaxBackwardSpeedScalar()
    return 1
end

local kStoopPos = Vector(0, 2.6, 0)
function Onos:UpdateStooping(deltaTime)

    local topPos = self:GetOrigin() + kStoopPos
    topPos.y = topPos.y + Onos.kYHeadExtents
    
    local xzDirection = self:GetViewCoords().zAxis
    xzDirection.y = 0
    xzDirection:Normalize()
    
    local trace = Shared.TraceRay(topPos, topPos + xzDirection * 4, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(self))
    
    if not self.stooping and not self.crouching then

        if trace.fraction ~= 1 then
        
            local stoopPos = self:GetEyePos()
            stoopPos.y = stoopPos.y + Onos.kYHeadExtentsLowered
            
            local traceStoop = Shared.TraceRay(stoopPos, stoopPos + xzDirection * 4, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(self))
            if traceStoop.fraction == 1 then
                self.stooping = true                
            end
            
        end    

    elseif self.stoopIntensity == 1 and trace.fraction == 1 then
        self.stooping = false
    end

    
    return true

end

--[[ - McG: Removed for now as this is no longer referenced
function Onos:UpdateAutoCrouch(move)
 
    local moveDirection = self:GetCoords():TransformVector(move)
    
    local extents = GetExtents(kTechId.Onos)
    local startPos1 = self:GetOrigin() + Vector(0, extents.y * self:GetCrouchShrinkAmount(), 0)
    
    local frontLeft = -self:GetCoords().xAxis * extents.x - self:GetCoords().zAxis * extents.z
    local backRight = self:GetCoords().xAxis * extents.x - self:GetCoords().zAxis * extents.z
    
    local startPos2 = self:GetOrigin() + frontLeft + Vector(0, extents.y * (1 - self:GetCrouchShrinkAmount()), 0)
    local startPos3 = self:GetOrigin() + backRight + Vector(0, extents.y * (1 - self:GetCrouchShrinkAmount()), 0)

    local trace1 = Shared.TraceRay(startPos1, startPos1 + moveDirection * 3, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(self))
    local trace2 = Shared.TraceRay(startPos2, startPos2 + moveDirection * 3, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(self))
    local trace3 = Shared.TraceRay(startPos3, startPos3 + moveDirection * 3, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(self))
    
    if trace1.fraction == 1 and trace2.fraction == 1 and trace3.fraction == 1 then
        self.crouching = true
        self.autoCrouching = true
    end

end
--]]

function Onos:OnUpdateAnimationInput(modelMixin)

    Alien.OnUpdateAnimationInput(self, modelMixin)
    
    if self:GetIsBoneShieldActive() then
        modelMixin:SetAnimationInput("move", "shield")
    end
    
end

function Onos:GetHasMovementSpecial()
    return self:GetHasOneHive()
end

function Onos:GetMovementSpecialTechId()
    return kTechId.Charge
end

function Onos:UpdateRumbleSound()

    if Client then
    
        local rumbleSound = Shared.GetEntity(self.rumbleSoundId)

        if rumbleSound then

            if GetHasCamouflageUpgrade(self) and self:GetCrouching() then
                rumbleSound:SetParameter("speed", 0, 1)
            else 
                rumbleSound:SetParameter("speed", self:GetSpeedScalar(), 1)
            end
        end
        
    end
    
end

-- Stampede Charge Impact
function Onos:Impact(target)
    
    target.nextStampede = Shared.GetTime() + Onos.kStampedePerMarineCooldown
    
    local mass = target.GetMass and target:GetMass() or Player.kMass
    
    local targetPoint = target:GetEngagementPoint()
    local attackOrigin = self:GetOrigin()

    local hitDirection = targetPoint - attackOrigin
    hitDirection:Normalize()

    local onosVel = self:GetVelocity()
    onosVel:Normalize()

    local classname = target:GetClassName()
    local settings = classname and Onos.kStampedeOverrideSettings[classname] or Onos.kStampedeDefaultSettings

    local disableDur = settings.kDisableDuration
    local chargeUpForce = settings.kChargeUpForce
    local chargeImpactForce = settings.kChargeImpactForce
    local chargeDiffForce = settings.kChargeDiffForce

    local diffVect = hitDirection - onosVel
    diffVect.y = 0

    local gore = self:GetWeapon(Gore.kMapName)
    if not gore then return end -- catch onos without gore scenario

    gore:DoDamage(kChargeDamage, target, attackOrigin, hitDirection)

    if target:isa("Marine") then
        self:TriggerEffects("onos_charge_hit_marine")
    elseif target:isa("Exo") then --or Exosuit if collision added?
        self:TriggerEffects("onos_charge_hit_exo")
    end

    local slapVel = self:GetVelocity() * chargeImpactForce + diffVect * chargeDiffForce + Vector(0, chargeUpForce * (1 - mass/1000), 0)
    if Shared.GetTestsEnabled() then
        local endDebugPoint = targetPoint + slapVel
        DebugLine(attackOrigin, targetPoint, 5, 0, 1, 0, 1)
        DebugLine(targetPoint, endDebugPoint, 5, 1, 0 , 0 , 1)
    end

    target.stampedeVars = {
        disableDur = disableDur,
        velocity = slapVel
    }

    target:AddTimedCallback(function(self)
        if not self.stampedeVars then return end

        self:DisableGroundMove(self.stampedeVars.disableDur)
        self:SetVelocity(self.stampedeVars.velocity)
        self.stampedeVars = nil
    end, 0 )
end

function Onos:OnProcessMove(input)
    
    Alien.OnProcessMove(self, input)    

    if self.stooping then
        self.stoopIntensity = math.min(1, self.stoopIntensity + Onos.kStoopingAnimationSpeed * input.time)
    else
        self.stoopIntensity = math.max(0, self.stoopIntensity - Onos.kStoopingAnimationSpeed * input.time)
    end
    
    self:UpdateRumbleSound()
    
end

function Onos:OnUpdate(dt)

    Alien.OnUpdate(self, dt)
    
    self:UpdateRumbleSound()
    
end

function Onos:UpdateBoneShieldCrouch(deltaTime)

    local direction = self:GetIsBoneShieldActive() and 1 or -1

    self.boneShieldCrouchAmount = Clamp(self.boneShieldCrouchAmount + direction * deltaTime * 3, 0, 1)

end

function Onos:OnProcessIntermediate(input)

    Alien.OnProcessIntermediate(self, input)

    self:UpdateBoneShieldCrouch(input.time)
    
end

function Onos:GetIsEnergizeAllowed()
    return not ( kBoneShieldPreventEnergize and self:GetIsBoneShieldActive() )
end

function Onos:GetRecuperationRate()

    local boneShieldActive = self:GetIsBoneShieldActive()
    if kBoneShieldPreventRecuperation and boneShieldActive then
        return 0
    end

    local alienRegenRate = Alien.GetRecuperationRate(self)
    if boneShieldActive then
        return alienRegenRate * self.kBoneShieldActiveHitpointsRegenFactor
    end

    return alienRegenRate

end

function Onos:OnProcessSpectate(deltaTime)

    Alien.OnProcessSpectate(self, deltaTime)

    self:UpdateBoneShieldCrouch(deltaTime)
    
end

function Onos:GetFlinchIntensityOverride()

    if self:GetIsBoneShieldActive() then
        return 0 --TODO Need to check WHERE damage came from, if outside shielded angle, flinch as normal (via mixin)
    end

    return self.flinchIntensity
end

function Onos:OnUpdatePoseParameters(viewModel)

    PROFILE("Onos:OnUpdatePoseParameters")
    
    Alien.OnUpdatePoseParameters(self, viewModel)

    if self:GetIsBoneShieldActive() then

        local mSpeed = Clamp( 1 - self:GetSpeedScalar(), 0.75, 1 )
        self:SetPoseParam("move_speed", mSpeed)
        self:SetPoseParam("stoop", 0.68)
        self:SetPoseParam("crouch", 0)

    else
        self:SetPoseParam("stoop", self.stoopIntensity)
    end
    
end

local kOnosHeadMoveAmount = 0
-- Give dynamic camera motion to the player
function Onos:PlayerCameraCoordsAdjustment(cameraCoords)

    local camOffsetHeight = 0

    if self:GetIsFirstPerson() then
    
        if not self:GetIsJumping() then

            local movementScalar = Clamp((self:GetVelocity():GetLength() / self:GetMaxSpeed(true)), 0.0, 0.8)
            local bobbing = ( math.cos((Shared.GetTime() - self:GetTimeGroundTouched()) * 7) - 1 )
            cameraCoords.origin.y = cameraCoords.origin.y + kOnosHeadMoveAmount * movementScalar * bobbing
            
        end
        
        cameraCoords.origin.y = cameraCoords.origin.y - self.boneShieldCrouchAmount
        
    end

    return cameraCoords

end

local kOnosEngageOffset = Vector(0, 1.3, 0)
function Onos:GetEngagementPointOverride()
    return self:GetOrigin() + kOnosEngageOffset
end

Onos.kBlockDoers =
set {
    "Minigun",
    "Railgun", -- Hits both boneshield and onos. (double dip is intended)
    "Pistol",
    "Rifle",
    "HeavyMachineGun",
    "Shotgun",
    "Axe",
    "Welder",
    "Sentry",
    "PulseGrenade",
    "ClusterFragment",
    "Mine",
    "Claw",
    "Flamethrower",
    "Grenade", -- Grenade Launcher
    "Mine",
	"PlasmaT1",
	"PlasmaT2",
	"PlasmaT3"
}

function Onos:GetHitsBoneShield(doer, hitPoint)

    if self.kBlockDoers[doer:GetClassName()] then
    
        local viewDirection = GetNormalizedVectorXZ( self:GetViewCoords().zAxis )
        local zPosition = viewDirection:DotProduct( GetNormalizedVector( hitPoint - self:GetOrigin() ) )
        return zPosition >= 0.34 --approx 115 degree cone of Onos facing
    
    end
    
    return false

end

function Onos:GetCombatInnateRegenOverride()
    if self:GetIsBoneShieldActive() then
        return kBoneShieldInnateCombatRegenRate
    end
end

function Onos:GetSurfaceOverride(damage)

    if self:GetIsBoneShieldActive() then
        return "none" --TODO Change based on relative angle of self vs source
    end

end

function Onos:GetCrouchCameraAnimationAllowed(result)
    result.allowed = result.allowed and not self:GetIsBoneShieldActive()
end

function Onos:ModifyCelerityBonus( celerityBonus )

    if self:GetIsBoneShieldActive() then
        return 0
    end

    return celerityBonus

end

function Onos:GetCrouchSpeedScalar()
    if self:GetIsBoneShieldActive() then
        return 0 --no effect on boneshield movement, would be confusing and pointless to do so
    end

    return Player.kCrouchSpeedScalar
end

function Onos:GetCanCrouchOverride()
    return not self:GetIsBoneShieldActive()
end

function Onos:ModifyDamageTakenPostRules(damageTable, attacker, doer, damageType, hitPoint)

    if hitPoint ~= nil and self:GetIsBoneShieldActive() and self:GetHitsBoneShield(doer, hitPoint) then

        -- Update combat state, since regen upgrade will happen if boneshield blocks everything
        -- This should also give the "red flashy" look on minimap
        if HasMixin(self, "Combat") then
            self.lastTakenDamageTime = Shared.GetTime()
            self.lastTakenDamageAmount = 0
        end

        local isRailgun = doer:GetClassName() == "Railgun"
        local boneshieldWeapon = self:GetWeapon(BoneShield.kMapName)
        if boneshieldWeapon then

            local boneshieldDamage = damageTable.damage
            local damageMult = 1
            if damageType == kDamageType.Heavy then
                -- yay one-offs
                damageMult = 2
            end

            boneshieldDamage = boneshieldDamage * damageMult

            if isRailgun then -- Railgun damages both boneshield and onos
                boneshieldWeapon:TakeDamage(boneshieldDamage)
            else
                local leftoverBoneshieldDamage = boneshieldWeapon:TakeDamage(boneshieldDamage)
                damageTable.damage = (leftoverBoneshieldDamage / damageMult) -- leftover damage converted from our multiplied damage
            end

            -- send damage message for specifically boneshield
            if boneshieldDamage > 0 then
                if Server then -- Damage numbers are only sent on server, client never predicts.
                    SendDamageMessage( attacker, self:GetId(), boneshieldDamage, hitPoint, 0, nil, kDamageMessageType.Boneshield ) -- overkill is unused
                end
            end

        end
        --TODO Exclude local player and trigger local-player only effect
        self:TriggerEffects("boneshield_blocked", { effecthostcoords = Coords.GetTranslation(hitPoint) } )

    end

    return damageTable.damage, damageTable.armorFractionUsed, damageTable.healthPerArmor

end

function Onos:ModifyAttackSpeed(attackSpeedTable)

    local activeWeapon = self:GetActiveWeapon()
    if activeWeapon and activeWeapon:isa("Gore") and activeWeapon:GetAttackType() == Gore.kAttackType.Smash then
        attackSpeedTable.attackSpeed = attackSpeedTable.attackSpeed * 1.35
    end

end

function Onos:GetIsBoneShieldActive()

    local activeWeapon = self:GetActiveWeapon()
    if activeWeapon and activeWeapon:isa("BoneShield") and activeWeapon.primaryAttacking then
        return true
    end    
    return false
    
end

Shared.LinkClassToMap("Onos", Onos.kMapName, networkVars)
