-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Lerk.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
--    Modified by: James Gu (twiliteblue) on 5 Aug 2011
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Utility.lua")
Script.Load("lua/Alien.lua")
Script.Load("lua/Weapons/Alien/LerkBite.lua")
Script.Load("lua/Weapons/Alien/LerkUmbra.lua")
Script.Load("lua/Weapons/Alien/Spores.lua")
Script.Load("lua/Mixins/BaseMoveMixin.lua")
Script.Load("lua/Mixins/GroundMoveMixin.lua")
Script.Load("lua/CelerityMixin.lua")
Script.Load("lua/Mixins/CameraHolderMixin.lua")
Script.Load("lua/WallMovementMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/Mixins/CrouchMoveMixin.lua")
Script.Load("lua/TunnelUserMixin.lua")
Script.Load("lua/BabblerClingMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/LerkVariantMixin.lua")
Script.Load("lua/RailgunTargetMixin.lua")
Script.Load("lua/BlowtorchTargetMixin.lua")

class 'Lerk' (Alien)

Lerk.kMapName = "lerk"

if Client then
    Script.Load("lua/Lerk_Client.lua")
elseif Server then
    Script.Load("lua/Lerk_Server.lua")
end

Lerk.kModelName = PrecacheAsset("models/alien/lerk/lerk.model")
local kViewModelName = PrecacheAsset("models/alien/lerk/lerk_view.model")
local kAnimationGraph = PrecacheAsset("models/alien/lerk/lerk.animation_graph")

precached = PrecacheAsset("models/alien/lerk/lerk.surface_shader")

local networkVars =
{
    gliding = "private compensated boolean",   
    glideAllowed = "private compensated boolean",  
    lastTimeFlapped = "compensated time",
    -- Wall grip. time == 0 no grip, > 0 when grip started.
    wallGripTime = "private compensated time",
    -- the normal that the model will use. Calculated the same way as the skulk
    wallGripNormalGoal = "private compensated vector",
    wallGripAllowed = "private compensated boolean",
    flapPressed = "private compensated boolean",
    timeOfLastPhase = "private time",
    flySoundId = "entityid"
}

AddMixinNetworkVars(BaseMoveMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(GroundMoveMixin, networkVars)
AddMixinNetworkVars(CelerityMixin, networkVars)
AddMixinNetworkVars(CameraHolderMixin, networkVars)
AddMixinNetworkVars(CrouchMoveMixin, networkVars)
AddMixinNetworkVars(TunnelUserMixin, networkVars)
AddMixinNetworkVars(BabblerClingMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(LerkVariantMixin, networkVars)

-- if the user hits a wall and holds the use key and the resulting speed is < this, grip starts
Lerk.kWallGripMaxSpeed = 4
-- once you press grip, you will slide for this long a time and then stop. This is also the time you
-- have to release your movement keys, after this window of time, pressing movement keys will release the grip.
Lerk.kWallGripSlideTime = 0.7
-- after landing, the y-axis of the model will be adjusted to the wallGripNormal after this time.
Lerk.kWallGripSmoothTime = 0.6

-- how to grab for stuff ... same as the skulk tight-in code
Lerk.kWallGripRange = 0.2
Lerk.kWallGripFeelerSize = 0.25

Lerk.kIdleSoundMinSpeed = 11.5 -- also is max speed that can be temporarily reached by flapping while holding on the brakes
Lerk.kIdleSoundMinPlayLength = 3 -- also is max speed that can be temporarily reached by flapping while holding on the brakes
Lerk.kIdleSoundMinSilenceLength = 5 -- also is max speed that can be temporarily reached by flapping while holding on the brakes


local kViewOffsetHeight = 0.5
Lerk.XZExtents = 0.4
Lerk.YExtents = 0.4
-- ~120 pounds
local kMass = 54
local kJumpHeight = 1.5

-- Lerks walk slowly to encourage flight
local kMaxWalkSpeed = 2.8
local kMaxSpeed = kLerkMaxSpeed
kAirStrafeMaxSpeed = 5.5

--local flying2DSound = PrecacheAsset("sound/NS2.fev/alien/lerk/flying")
local kFlying3DSound = PrecacheAsset("sound/NS2.fev/alien/lerk/flying_3D")

local kGlideAccel = 6
Lerk.kFlapForce = 5
Lerk.kFlapForceForward = 8.3
Lerk.kFlapForceStrafe = 8.3

Lerk.kGlideAccel = 6
Lerk.kMaxGlideRoll = math.rad(10)

Lerk.kGravity = -7
Lerk.kSwoopGravity = Lerk.kGravity * 6

Lerk.kAdrenalineEnergyRecuperationRate = kLerkAdrenalineEnergyRate

function Lerk:OnCreate()

    InitMixin(self, BaseMoveMixin, { kGravity = Lerk.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, CelerityMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kLerkFov })
    InitMixin(self, WallMovementMixin)
    InitMixin(self, LerkVariantMixin)
    
    Alien.OnCreate(self)
    
    InitMixin(self, DissolveMixin)
    InitMixin(self, TunnelUserMixin)
    InitMixin(self, BabblerClingMixin)
    
    self.gliding = false
    self.lastTimeFlapped = 0
    
    self.wallGripTime = 0
    
    self.flySoundId = Entity.invalidId

    if Server then
        self.lastFlySpeed = 0
        self.lastOrigin = nil

        self.flySound = Server.CreateEntity( SoundEffect.kMapName )
        self.flySound:SetAsset( kFlying3DSound )
        self.flySound:SetParent(self)
        self.flySound:Start()
        self.flySoundId = self.flySound:GetId()
        
        self.playIdleStartTime = 0
    end
	
	if Client then
        InitMixin(self, RailgunTargetMixin)
		InitMixin(self, BlowtorchTargetMixin)
    end
end

function Lerk:OnInitialized()

    Alien.OnInitialized(self)
    
    self:SetModel(Lerk.kModelName, kAnimationGraph)
    
    if Client then
    
        self.currentCameraRoll = 0
        self.goalCameraRoll = 0
        self.previousYaw = 0
        
        self:AddHelpWidget("GUILerkFlapHelp", 2)
        self:AddHelpWidget("GUILerkSporesHelp", 2)
        self:AddHelpWidget("GUITunnelEntranceHelp", 1)
        
        if self.flySoundId ~= Entity.invalidId then
            local flySound = Shared.GetEntity(self.flySoundId)
            if flySound then
                flySound:SetParameter("speed", 0, 10)
            end
        end

    end
    
    InitMixin(self, IdleMixin)
    
end

function Lerk:OnDestroy()

    Alien.OnDestroy(self)
    
    if Server and self.flySound ~= nil then
        DestroyEntity( self.flySound )
        self.flySound = nil
        self.flySoundId = Entity.invalidId
    end
    
end 

function Lerk:GetHasFallAccel()
    return false
end    

function Lerk:GetCanStep()
    return self:GetIsOnGround() and not self:GetIsWallGripping()
end

function Lerk:ModifyGravityForce(gravityTable)

    if self.gliding or self:GetIsWallGripping() or self:GetIsOnGround() or self.wasHoldingGlide then
        gravityTable.gravity = 0
        
    elseif self:GetCrouching() then
        gravityTable.gravity = Lerk.kSwoopGravity
        
    end

end

function Lerk:GetAngleSmoothRate()
    return 6
end

function Lerk:GetCollisionSlowdownFraction()
    return 0.1
end

function Lerk:GetRollSmoothRate()
    return 3
end   

function Lerk:GetPitchSmoothRate()
    return 3
end

function Lerk:GetDesiredAngles()

    if self:GetIsWallGripping() then
        return self:GetAnglesFromWallNormal( self.wallGripNormalGoal )
    end

    local desiredAngles = Alien.GetDesiredAngles(self)

    if not self:GetIsOnGround() and not self:GetIsWallGripping() then
        -- There seems to be an issue where sometimes the pitch scales from 1.5pi to 2pi when looking up
        -- Normally angles always seem to be +/- 1/2pi as expected...
        -- If our view pitch is greater than pi, just ignore any clamping here.  We are only looking to keep the lerk model from pitching downwards too much
        --Print(ToString(Server and "Server: " or (Client and "Client: " or "Predict: ")).."viewPitch: "..ToString(self.viewPitch))
        if self.viewPitch < math.pi then
            desiredAngles.pitch = math.min(self.viewPitch, 0.4)
        else
            desiredAngles.pitch = self.viewPitch
        end
        local diff = RadianDiff( self:GetAngles().yaw, self.viewYaw )
        if math.abs(diff) < 0.001 then
            diff = 0
        end
        desiredAngles.roll = Clamp(diff, -Lerk.kMaxGlideRoll, Lerk.kMaxGlideRoll)
    end

    return desiredAngles

end

local kLerkGlideYaw = 90

function Lerk:OverrideGetMoveYaw()

    -- stop the animation from banking the model; the animation was originally intended
    -- to handle left/right banking using move_speed and move_yaw, but this was too cumbersome.
    -- By setting the moveYaw to 90 (straight ahead), the animation-state banking is zeroed out
    -- and the banking can be handled by changing the roll angle instead

    if not self:GetIsOnGround() then
        return kLerkGlideYaw
    end
    return nil

end

function Lerk:OverrideGetMoveSpeed(speed)

    if self:GetIsOnGround() then
        return kMaxWalkSpeed
    end
    -- move_speed determines how often we flap. We fiddle some to
    -- flap more at minimum flying speed
    return Clamp((speed - kMaxWalkSpeed) / kMaxSpeed, 0, 1) 
           
end

function Lerk:GetAngleSmoothingMode()

    if self:GetIsWallGripping() then
        return "quatlerp"
    else
        return "euler"
    end

end

local cloakMaxSpeed = 0.6 * kLerkMaxSpeed -- 7.7
function Lerk:GetSpeedScalar()
    return self:GetVelocity():GetLength() / cloakMaxSpeed
end

function Lerk:GetCarapaceSpeedReduction()
    return kLerkCarapaceSpeedReduction
end

-- air strafe works different for lerk
function Lerk:GetAirControl()
    return 0
end

function Lerk:GetBaseArmor()
    return kLerkArmor
end

function Lerk:GetBaseHealth()
    return kLerkHealth
end

function Lerk:GetHealthPerBioMass()
    return kLerkHealthPerBioMass
end

function Lerk:GetBaseCarapaceArmorBuff()
    return kLerkBaseCarapaceUpgradeAmount
end

function Lerk:GetCarapaceBonusPerBiomass()
    return kLerkCarapaceArmorPerBiomass
end

function Lerk:GetAdrenalineEnergyRechargeRate()
    return Lerk.kAdrenalineEnergyRecuperationRate
end

function Lerk:GetBabblerShieldPercentage()
    return kLerkBabblerShieldPercent
end

function Lerk:GetMaxViewOffsetHeight()
    return kViewOffsetHeight
end

function Lerk:GetAirFriction()
    return 0.08
end

function Lerk:GetCrouchShrinkAmount()
    return 0
end

function Lerk:GetExtentsCrouchShrinkAmount()
    return 0
end

function Lerk:GetViewModelName()
    return self:GetVariantViewModel(self:GetVariant())
end

function Lerk:GetIsWallGripping()
    return self.wallGripTime ~= 0 
end

function Lerk:OnGroundChanged(onGround, impactForce, normal, velocity)

    Alien.OnGroundChanged(self, onGround, impactForce, normal, velocity)

    if onGround then
        self.glideAllowed = false
    end

end

-- but always use walk speed fucks up the move_speed variable; it is set with possible=true.
-- gliding animation goes up to max at 2.8m/s rather than 13m/s...
-- always use walk speed. flying is handled in modify velocity
function Lerk:GetMaxSpeed(possible)

    if possible then
        return kMaxWalkSpeed
    end
    
    if self:GetIsOnGround() then
        return kMaxWalkSpeed
    else
        return kMaxSpeed
    end    
    
end

function Lerk:GetMovementSpecialTechId()
    return kTechId.Cling
end

function Lerk:GetHasMovementSpecial()
    return true
end


function Lerk:GetMass()
    return kMass
end

function Lerk:GetTimeOfLastFlap()
    return self.lastTimeFlapped
end

function Lerk:OverrideUpdateOnGround(onGround)
    return (onGround or self:GetIsWallGripping()) and not self.gliding
end

function Lerk:OnWorldCollision(normal)

    PROFILE("Lerk:OnWorldCollision")
    
    self.wallGripAllowed = normal.y < 0.5 and not self:GetCrouching()
    
end

local function UpdateFlap(self, input, velocity)

    local flapPressed = bit.band(input.commands, Move.Jump) ~= 0

    if flapPressed ~= self.flapPressed then

        self.flapPressed = flapPressed
        --self.glideAllowed = not self:GetIsOnGround()
        self.glideAllowed = true

        if flapPressed and self:GetEnergy() > kLerkFlapEnergyCost and not self.gliding then

            -- take off
            if self:GetIsOnGround() or input.move:GetLength() == 0 then

                local wishDir = self:GetViewCoords():TransformVector(input.move)
                wishDir:Normalize()
                if velocity:GetLengthXZ() < 4.5 then
                    velocity:Add(wishDir * Lerk.kFlapForceForward * 0.5)
                end
                velocity.y = velocity.y * 0.5 + 5

            else

                local flapForce = Lerk.kFlapForce
                local move = Vector(input.move)
                move.x = move.x * 0.75
                -- flap only at 50% speed side wards

                local wishDir = self:GetViewCoords():TransformVector(move)
                wishDir:Normalize()

                -- the speed we already have in the new direction
                local currentSpeed = move:DotProduct(velocity)
                -- prevent exceeding max speed of kMaxSpeed by flapping
                local maxSpeedTable = { maxSpeed = kMaxSpeed }
                self:ModifyMaxSpeed(maxSpeedTable, input)

                local maxSpeed = math.max(currentSpeed, maxSpeedTable.maxSpeed)

                if input.move.z ~= 1 and velocity.y < 0 then
                    -- apply vertical flap
                    velocity.y = velocity.y * 0.5 + 3.8
                elseif input.move.z == 1 and input.move.x == 0 then
                    -- flapping forward
                    flapForce = Lerk.kFlapForceForward
                elseif input.move.z == 0 and input.move.x ~= 0 then
                    -- strafe flapping
                    flapForce = Lerk.kFlapForceStrafe
                    velocity.y = velocity.y + 3.5
                end

                -- directional flap
                velocity:Scale(0.65)
                velocity:Add(wishDir * flapForce)

                if velocity:GetLengthSquared() > maxSpeed * maxSpeed then
                    velocity:Normalize()
                    velocity:Scale(maxSpeed)
                end

            end

            self:DeductAbilityEnergy(kLerkFlapEnergyCost)
            self.lastTimeFlapped = Shared.GetTime()
            self.onGround = false
            self:TriggerEffects("flap")

        end

    end

end

local kSneakyGlideSpeedSlowMaxDuration = kLerkSneakyGlideSpeedSlowDuration
local kMinGlideSpeed = kLerkMinGlideSpeed
local kSneakyGlideSlowRate = (kMaxSpeed - kMinGlideSpeed) / kSneakyGlideSpeedSlowMaxDuration
local function UpdateGlide(self, input, velocity, deltaTime)

    -- more control when moving forward
    local holdingGlide = bit.band(input.commands, Move.Jump) ~= 0 and self.glideAllowed
    if input.move.z == 1 and holdingGlide then

        local useSneakyGlide = bit.band(input.commands, Move.MovementModifier) ~= 0
        if not self.wasHoldingGlide and useSneakyGlide then
            self.sneakGlideStartSpeed = velocity:GetLength()
            self.wasHoldingGlide = true
        elseif not useSneakyGlide then
            self.wasHoldingGlide = false
        end

        local useMove = Vector(input.move)
        useMove.x = useMove.x * 0.5

        local wishDir = GetNormalizedVector(self:GetViewCoords():TransformVector(useMove))
        -- slow down when moving in another XZ direction, accelerate when falling down
        local currentDir = GetNormalizedVector(velocity)
        local glideAccel = -currentDir.y * deltaTime * Lerk.kGlideAccel * (self.wasHoldingGlide and 0 or 1)

        local maxSpeedTable = { maxSpeed = kMaxSpeed }
        self:ModifyMaxSpeed(maxSpeedTable, input)

        local speed = velocity:GetLength() -- velocity:DotProduct(wishDir) * 0.1 + velocity:GetLength() * 0.9
        local useSpeed = math.min(maxSpeedTable.maxSpeed, speed + glideAccel)

        if useSneakyGlide then

            local speedOverSneak = velocity:GetLength() - kMinGlideSpeed
            if speedOverSneak > 0 then
                local speedDecreaseBy = math.min(speedOverSneak, deltaTime * kSneakyGlideSlowRate)
                useSpeed = useSpeed - speedDecreaseBy
            end
        end

        -- when speed falls below 1, set horizontal speed to 1, and vertical speed to zero, but allow dive to regain speed
        if useSpeed < kMinGlideSpeed then
            useSpeed = kMinGlideSpeed
            local newY = math.min(wishDir.y, 0)
            wishDir.y = newY
            wishDir = GetNormalizedVector(wishDir)
        end

        -- when gliding we always have 100% control
        local redirectVelocity = wishDir * useSpeed
        VectorCopy(redirectVelocity, velocity)

        self.gliding = not self:GetIsOnGround()

    else
        self.gliding = false
        self.wasHoldingGlide = false
    end

end

local function UpdateCrouchDive(self, input, velocity, deltaTime)
    if self:GetCrouching() and not self:GetIsOnGround() then

        local vy = velocity.y
        if velocity.y > 0 then
            -- cut upwards momentum quick
            velocity.y = velocity.y - velocity.y * 5 * deltaTime
        else

            ---- add some air friction at high speeds
            local maxSpeedTable = { maxSpeed = kMaxSpeed }
            self:ModifyMaxSpeed(maxSpeedTable, input)

            local maxSpeed = maxSpeedTable.maxSpeed * 1.5
            if velocity.y * velocity.y > maxSpeed * maxSpeed then
                -- add some high speedair friction
                velocity.y = velocity.y - velocity.y * 1.5 * deltaTime
            end

        end

    end
end

-- jetpack and exo do the same, move to utility function
local function UpdateAirStrafe(self, input, velocity, deltaTime)

    if not self:GetIsOnGround() and not self.gliding then

        -- do XZ acceleration
        local wishDir = self:GetViewCoords():TransformVector(input.move)
        wishDir.y = 0
        wishDir:Normalize()

        local maxSpeed = math.max(kAirStrafeMaxSpeed, velocity:GetLengthXZ())
        velocity:Add(wishDir * 18 * deltaTime)

        if velocity:GetLengthXZ() > maxSpeed then

            local yVel = velocity.y
            velocity.y = 0
            velocity:Normalize()
            velocity:Scale(maxSpeed)
            velocity.y = yVel

        end

    end

end

function Lerk:ModifyVelocity(input, velocity, deltaTime)

    UpdateFlap(self, input, velocity)
    UpdateAirStrafe(self, input, velocity, deltaTime)
    UpdateGlide(self, input, velocity, deltaTime)
    UpdateCrouchDive(self, input, velocity, deltaTime)

end

function Lerk:GetIsSmallTarget()
    return true
end

function Lerk:GetAirAcceleration()
    return 0
end

function Lerk:GetGroundTransistionTime()
    return 0.2
end

function Lerk:PreUpdateMove(input, runningPrediction)

    PROFILE("Lerk:PreUpdateMove")

    local wallGripPressed = bit.band(input.commands, Move.MovementModifier) ~= 0 and bit.band(input.commands, Move.Jump) == 0
    
    if not self:GetIsWallGripping() and wallGripPressed and self.wallGripAllowed then

        -- check if we can grab anything around us
        local wallNormal = self:GetAverageWallWalkingNormal(Lerk.kWallGripRange, Lerk.kWallGripFeelerSize)
        
        if wallNormal then
        
            self.wallGripTime = Shared.GetTime()
            self.wallGripNormalGoal = wallNormal
            self:SetVelocity(Vector(0,0,0))
            
        end
    
    else
        
        -- we always abandon wall gripping if we flap (even if we are sliding to a halt)
        local breakWallGrip = bit.band(input.commands, Move.Jump) ~= 0 or input.move:GetLength() > 0 or self:GetCrouching()
        
        if breakWallGrip then
        
            self.wallGripTime = 0
            self.wallGripNormal = nil
            self.wallGripAllowed = false
            
        end
        
    end
    
end

local kLerkEngageOffset = Vector(0, 0.6, 0)
function Lerk:GetEngagementPointOverride()
    return self:GetOrigin() + kLerkEngageOffset
end

function Lerk:CalcWallGripSpeedFraction()

    local dt = (Shared.GetTime() - self.wallGripTime)
    if dt > Lerk.kWallGripSlideTime then
        return 0
    end
    local k = Lerk.kWallGripSlideTime
    return (k - dt) / k
    
end

function Lerk:OnUpdatePoseParameters()
    
    Alien.OnUpdatePoseParameters(self)
    
    local activeAbility = self:GetActiveWeapon()
    local activeAbilityIsSpores = activeAbility ~= nil and activeAbility:isa("Spores")
    self:SetPoseParam("spore", activeAbilityIsSpores and 1 or 0)
    
end

function Lerk:OnUpdateAnimationInput(modelMixin)

    PROFILE("Lerk:OnUpdateAnimationInput")
    
    Alien.OnUpdateAnimationInput(self, modelMixin)
    
    if not self:GetIsWallGripping() and not self:GetIsOnGround() then
        modelMixin:SetAnimationInput("move", "fly")
    end
    
    local flappedRecently = (Shared.GetTime() - self.lastTimeFlapped) <= 0.5
    modelMixin:SetAnimationInput("flapping", flappedRecently)
    
end

Shared.LinkClassToMap("Lerk", Lerk.kMapName, networkVars, true)



gDebugSporesAndUmbra = false
local OnCommandLerkAbilitiesRadiusDebugging = function()
    
    if Shared.GetCheatsEnabled() or Shared.GetTestsEnabled() and not gDebugSporesAndUmbra then
        Log("Displaying Spore and Umbra AOE")
        gDebugSporesAndUmbra = true
    elseif gDebugSporesAndUmbra then
        Log("Hiding Spore and Umbra AOE")
        gDebugSporesAndUmbra = false
    end
    
end

Event.Hook("Console_debuglerkabilities", OnCommandLerkAbilitiesRadiusDebugging)
