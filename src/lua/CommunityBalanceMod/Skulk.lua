-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\Skulk.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--                  Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Utility.lua")
Script.Load("lua/Weapons/Alien/BiteLeap.lua")
Script.Load("lua/Weapons/Alien/Parasite.lua")
Script.Load("lua/Weapons/Alien/XenocideLeap.lua")
Script.Load("lua/Weapons/Alien/ReadyRoomLeap.lua")
Script.Load("lua/Alien.lua")
Script.Load("lua/Mixins/BaseMoveMixin.lua")
Script.Load("lua/Mixins/GroundMoveMixin.lua")
Script.Load("lua/Mixins/CrouchMoveMixin.lua")
Script.Load("lua/Mixins/JumpMoveMixin.lua")
Script.Load("lua/CelerityMixin.lua")
Script.Load("lua/Mixins/CameraHolderMixin.lua")
Script.Load("lua/WallMovementMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/BabblerClingMixin.lua")
Script.Load("lua/TunnelUserMixin.lua")
Script.Load("lua/RailgunTargetMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/SkulkVariantMixin.lua")

class 'Skulk' (Alien)

Skulk.kMapName = "skulk"

Skulk.kModelName = PrecacheAsset("models/alien/skulk/skulk.model")
local kViewModelName = PrecacheAsset("models/alien/skulk/skulk_view.model")
local kSkulkAnimationGraph = PrecacheAsset("models/alien/skulk/skulk.animation_graph")

-- Balance, movement, animation
Skulk.kViewOffsetHeight = .55

Skulk.kHealth = kSkulkHealth
Skulk.kArmor = kSkulkArmor

local kDashSound = PrecacheAsset("sound/NS2.fev/alien/skulk/full_speed")

local kLeapVerticalForce = 10.8
local kLeapTime = 0.2
local kLeapForce = 7.6

Skulk.kMaxSpeed = 7.25
Skulk.kSneakSpeedModifier = 0.5931035

local kMass = 45 -- ~100 pounds
-- How big the spheres are that are casted out to find walls, "feelers".
-- The size is calculated so the "balls" touch each other at the end of their range
local kNormalWallWalkFeelerSize = 0.25
local kNormalWallWalkRange = 0.3

-- jump is valid when you are close to a wall but not attached yet at this range
local kJumpWallRange = 0.4
local kJumpWallFeelerSize = 0.1

Skulk.kXExtents = .45
Skulk.kYExtents = .45
Skulk.kZExtents = .45

Skulk.kMaxSneakOffset = 0 --0.55

Skulk.kWallJumpInterval = 0.4
Skulk.kWallJumpForce = 6.4 -- scales down the faster you are
Skulk.kMinWallJumpForce = 0.1
Skulk.kVerticalWallJumpForce = 4.3

Skulk.kMinBunnyHopForce = 0.05
Skulk.kBunnyHopForce = 7
Skulk.kVerticalBunnyHopForce = 2.15
Skulk.kBunnyHopMaxSpeed = 8.5
Skulk.kBunnyHopMaxSpeedCelerityBonus = 0.6
Skulk.kBunnyHopMaxGroundTouchDuration = 0.5

Skulk.kWallJumpMaxSpeed = 11
Skulk.kWallJumpMaxSpeedCelerityBonus = 1.2

Skulk.kAdrenalineEnergyRecuperationRate = kSkulkAdrenalineEnergyRate

Skulk.kMaxJumpComboLifetime = 1.5 -- seconds before the next jump is considered a "first" jump.

if Server then
    Script.Load("lua/Skulk_Server.lua", true)
elseif Client then
    Script.Load("lua/Skulk_Client.lua", true)
end

local networkVars =
{
    wallWalking = "compensated boolean",
    timeLastWallWalkCheck = "private compensated time",
    leaping = "compensated boolean",
    timeOfLeap = "private compensated time",
    timeOfLastJumpLand = "private compensated time",
    timeLastWallJump = "private compensated time",
    jumpLandSpeed = "private compensated float",
    dashing = "compensated boolean",    
    timeOfLastPhase = "private time",
    -- sneaking (movement modifier) skulks starts to trail their body behind them
    sneakOffset = "compensated interpolated float (0 to 1 by 0.04)",

    -- true if upgrades have been set at respawn
    autopickedUpgrades = "boolean"
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
AddMixinNetworkVars(SkulkVariantMixin, networkVars)

function Skulk:OnCreate()

    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, JumpMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, CelerityMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kSkulkFov })
    InitMixin(self, WallMovementMixin)
    InitMixin(self, SkulkVariantMixin)
    
    Alien.OnCreate(self)

    InitMixin(self, DissolveMixin)
    InitMixin(self, BabblerClingMixin)
    InitMixin(self, TunnelUserMixin)
    
    if Client then
        InitMixin(self, RailgunTargetMixin)
        self.timeDashChanged = 0
    end
    
    self.wallWalking = false
    self.wallWalkingNormalGoal = Vector.yAxis
    self.leaping = false
    self.timeLastWallJump = 0
     
    self.sneakOffset = 0
    self.autopickedUpgrades = false
    
end

function Skulk:OnInitialized()

    Alien.OnInitialized(self)
    
    -- Note: This needs to be initialized BEFORE calling SetModel() below
    -- as SetModel() will call GetHeadAngles() through SetPlayerPoseParameters()
    -- which will cause a script error if the Skulk is wall walking BEFORE
    -- the Skulk is initialized on the client.
    self.currentWallWalkingAngles = Angles(0.0, 0.0, 0.0)
    
    self:SetModel(self:GetVariantModel(), kSkulkAnimationGraph)
    
    if Client then
    
        self.currentCameraRoll = 0
        
        self:AddHelpWidget("GUIEvolveHelp", 2)
        self:AddHelpWidget("GUISkulkParasiteHelp", 1)
        self:AddHelpWidget("GUISkulkLeapHelp", 2)
        self:AddHelpWidget("GUIMapHelp", 1)
        self:AddHelpWidget("GUITunnelEntranceHelp", 1)
        
    end

    InitMixin(self, IdleMixin)
    
end

function Skulk:GetCarapaceSpeedReduction()
    return kSkulkCarapaceSpeedReduction
end

function Skulk:OnDestroy()

    Alien.OnDestroy(self)

    if Client then
    
        if self.playingDashSound then
        
            Shared.StopSound(self, kDashSound)
            self.playingDashSound = false
        
        end
    
    end

end

function Skulk:GetBaseArmor()
    return Skulk.kArmor
end

function Skulk:GetCrouchSpeedScalar()
    return 0
end

function Skulk:GetBaseHealth()
    return Skulk.kHealth
end

function Skulk:GetHealthPerBioMass()
    return kSkulkHealthPerBioMass
end

function Skulk:GetAdrenalineEnergyRechargeRate()
    return Skulk.kAdrenalineEnergyRecuperationRate
end

function Skulk:GetBabblerShieldPercentage()
    return kSkulkBabblerShieldPercent
end

function Skulk:GetMaxViewOffsetHeight()
    return Skulk.kViewOffsetHeight
end

function Skulk:GetCrouchShrinkAmount()
    return 0
end

function Skulk:GetExtentsCrouchShrinkAmount()
    return 0
end

function Skulk:OnLeap()

    local velocity = self:GetVelocity() * 0.5
    local forwardVec = self:GetViewAngles():GetCoords().zAxis
    local newVelocity = velocity + GetNormalizedVectorXZ(forwardVec) * kLeapForce
    
    -- Add in vertical component.
    newVelocity.y = kLeapVerticalForce * forwardVec.y + kLeapVerticalForce * 0.5 + ConditionalValue(velocity.y < 0, velocity.y, 0)
    
    self:SetVelocity(newVelocity)
    
    self.leaping = true
    self.wallWalking = false
    self.jumping = true
    self:DisableGroundMove(0.2)
    
    self.timeOfLeap = Shared.GetTime()
    
end

function Skulk:GetRecentlyWallJumped()
    return self.timeLastWallJump + Skulk.kWallJumpInterval > Shared.GetTime()
end

function Skulk:GetCanWallJump()

    local wallWalkNormal = self:GetAverageWallWalkingNormal(kJumpWallRange, kJumpWallFeelerSize)
    if wallWalkNormal then
        return wallWalkNormal.y < 0.5
    end
    
    return false

end

function Skulk:GetViewModelName()
    return self:GetVariantViewModel(self:GetVariant())
end

function Skulk:GetCanJump()
    local canWallJump = self:GetCanWallJump()
    return self:GetIsOnGround() or canWallJump
end

function Skulk:GetIsWallWalking()
    return self.wallWalking
end

function Skulk:GetIsLeaping()
    return self.leaping
end

function Skulk:GetIsWallWalkingPossible() 
    return not self:GetRecentlyJumped() and not self:GetCrouching()
end

function Skulk:GetUpgradeLevel(upgradeIndexName)
    local playerLevel, teamLevel = Alien.GetUpgradeLevel(self, upgradeIndexName)

    -- delay the upgrade levels slightly after respawn
    if teamLevel > 0 and self.autopickedUpgrades then
        local now = Shared:GetTime()
        for i = teamLevel, 0, -1 do
            playerLevel = i

            if self.creationTime + i * kUpgradeLevelDelayAtAlienRepawn < now then
                if i == teamLevel then
                    self.autopickedUpgrades = false -- delay timed out, so no reason to adjust the level any longer
                end

                break
            end
        end
    end

    return playerLevel, teamLevel
end

function Skulk:GetPlayFootsteps()
    return self:GetVelocityLength() > .75 and self:GetIsOnGround() and self:GetIsAlive() and not self.movementModiferState
end

function Skulk:GetTriggerLandEffect()
    local xzSpeed = self:GetVelocity():GetLengthXZ()
    return Alien.GetTriggerLandEffect(self) and (not self.movementModiferState or xzSpeed > 7)
end

-- Update wall-walking from current origin
function Skulk:PreUpdateMove(input, runningPrediction)

    PROFILE("Skulk:PreUpdateMove")
    --[[
    local dashDesired = bit.band(input.commands, Move.MovementModifier) ~= 0 and self:GetVelocity():GetLength() > 4
    if not self.dashing and dashDesired and self:GetEnergy() > 15 then
        self.dashing = true    
    elseif self.dashing and not dashDesired then
        self.dashing = false
    end
    
    if self.dashing then    
        self:DeductAbilityEnergy(input.time * 30)    
    end
    
    if self:GetEnergy() == 0 then
        self.dashing = false
    end
    --]]
    if self:GetCrouching() then
        self.wallWalking = false
    end

    if self.wallWalking then

        -- Most of the time, it returns a fraction of 0, which means
        -- trace started outside the world (and no normal is returned)
        local goal = self:GetAverageWallWalkingNormal(kNormalWallWalkRange, kNormalWallWalkFeelerSize, PhysicsMask.AllButPCsAndWebs)
        if goal ~= nil then
        
            self.wallWalkingNormalGoal = goal
            self.wallWalking = true

        else
            self.wallWalking = false
        end
    
    end
    
    if not self:GetIsWallWalking() then
        -- When not wall walking, the goal is always directly up (running on ground).
        self.wallWalkingNormalGoal = Vector.yAxis
    end

    if self.leaping and Shared.GetTime() > self.timeOfLeap + kLeapTime then
        self.leaping = false
    end
        
    self.currentWallWalkingAngles = self:GetAnglesFromWallNormal(self.wallWalkingNormalGoal or Vector.yAxis) or self.currentWallWalkingAngles

    -- adjust the sneakOffset so sneaking skulks can look around corners without having to expose themselves too much
    local delta = input.time * math.min(1, self:GetVelocityLength())
    if self.movementModiferState then
        if self.sneakOffset < Skulk.kMaxSneakOffset then
            self.sneakOffset = math.min(Skulk.kMaxSneakOffset, self.sneakOffset + delta)
        end
    else
        if self.sneakOffset > 0 then
            self.sneakOffset = math.max(0, self.sneakOffset - delta)
        end
    end
    
end

function Skulk:DisableRollPitchSmoothing()
    --do not change roll or pitch briefly after jumping to prevent twitchy wall movement
    return self.timeOfLastJump ~= nil and self.timeOfLastJump + .13 > Shared.GetTime()
end

function Skulk:GetRollSmoothRate()
    if self:DisableRollPitchSmoothing() then
        return 0
    end
    return 5
end

function Skulk:GetPitchSmoothRate()
    if self:DisableRollPitchSmoothing() then
        return 0
    end
    return 3
end

function Skulk:GetSlerpSmoothRate()
    return 5
end

function Skulk:GetAngleSmoothRate()
    return 6
end

function Skulk:GetCollisionSlowdownFraction()
    return 0.15
end

function Skulk:GetDesiredAngles(deltaTime)
    return self.currentWallWalkingAngles
end 

function Skulk:GetHeadAngles()

    if self:GetIsWallWalking() then
        -- When wallwalking, the angle of the body and the angle of the head is very different
        return self:GetViewAngles()
    else
        return self:GetViewAngles()
    end

end

function Skulk:GetAngleSmoothingMode()

    if self:GetIsWallWalking() then
        return "quatlerp"
    else
        return "euler"
    end

end

function Skulk:GetIsUsingBodyYaw()
    return not self:GetIsWallWalking()
end

function Skulk:OnJump( modifiedVelocity )

    self.wallWalking = false

    local material = self:GetMaterialBelowPlayer()    
    
    local currentSpeed = modifiedVelocity:GetLengthXZ()
    local maxWallJumpSpeed = self:GetMaxWallJumpSpeed()
            
    if currentSpeed > maxWallJumpSpeed * 0.95 then
        self:TriggerEffects("jump_best", {surface = material})          
    elseif currentSpeed > maxWallJumpSpeed * 0.75 then
        self:TriggerEffects("jump_good", {surface = material})       
    end
    
    self:TriggerEffects("jump", {surface = material})

    
end

function Skulk:OnWorldCollision(normal, impactForce, newVelocity)

    PROFILE("Skulk:OnWorldCollision")

    self.wallWalking = self:GetIsWallWalkingPossible() and normal.y < 0.5
    
end

function Skulk:GetMaxSpeed(possible)

    if possible then
        return Skulk.kMaxSpeed
    end
    
    local maxspeed = Skulk.kMaxSpeed
    
    if self.movementModiferState then
        maxspeed = maxspeed * Skulk.kSneakSpeedModifier
    end
    
    return maxspeed
    
end

function Skulk:ModifyCelerityBonus(celerityBonus)
    
    if self.movementModiferState then
        celerityBonus = celerityBonus * Skulk.kSneakSpeedModifier
    end
    
    return celerityBonus
    
end

function Skulk:GetCelerityBonus()
    
end

function Skulk:GetMass()
    return kMass
end

function Skulk:OverrideUpdateOnGround(onGround)
    return onGround or self:GetIsWallWalking()
end

function Skulk:ModifyGravityForce(gravityTable)

    if self:GetIsWallWalking() and not self:GetCrouching() then
        gravityTable.gravity = 0

    elseif self:GetIsOnGround() then
        gravityTable.gravity = 0
        
    end

end

function Skulk:GetJumpHeight()
    return Skulk.kJumpHeight
end

function Skulk:GetPerformsVerticalMove()
    return self:GetIsWallWalking()
end

function Skulk:GetMaxWallJumpSpeed()
    if self.stormed and GetHasCelerityUpgrade(self) then 
        return Skulk.kWallJumpMaxSpeed + Skulk.kWallJumpMaxSpeedCelerityBonus*(1 + 0.5*self:GetSpurLevel()/3.0)
	elseif self.stormed then
		return Skulk.kWallJumpMaxSpeed + Skulk.kWallJumpMaxSpeedCelerityBonus
	else
		return Skulk.kWallJumpMaxSpeed
    end
end

function Skulk:GetMaxBunnyHopSpeed()
    if self.stormed and GetHasCelerityUpgrade(self) then 
		return Skulk.kBunnyHopMaxSpeed + Skulk.kBunnyHopMaxSpeedCelerityBonus*(1 + 0.5*self:GetSpurLevel()/3.0)
	elseif self.stormed then
		return Skulk.kBunnyHopMaxSpeed + Skulk.kBunnyHopMaxSpeedCelerityBonus
	else
		return Skulk.kBunnyHopMaxSpeed
    end
end


function Skulk:ModifyJump(input, velocity, jumpVelocity)
    -- we add the bonus in the direction the move is going
    local viewCoords = self:GetViewAngles():GetCoords()

    if self:GetCanWallJump() then

        jumpVelocity.y = 3 + math.min(1, 1 + viewCoords.zAxis.y) * 2

        if not self:GetRecentlyWallJumped() then

            local minimumForce = Skulk.kMinWallJumpForce
            local scalableForce = Skulk.kWallJumpForce
            local verticalForce = Skulk.kVerticalWallJumpForce
            local maxSpeed = self:GetMaxWallJumpSpeed()

            local fraction = 1 - Clamp( velocity:GetLengthXZ() / maxSpeed , 0, 1)

            local force = math.max(minimumForce, scalableForce * fraction)

            -- The first jump should be 50% boost.
            if self.timeOfLastJump + Skulk.kMaxJumpComboLifetime < Shared.GetTime() then
                force = force * 0.5
            end

            local direction = input.move.z == -1 and -1 or 1
            local bonusVec = viewCoords.zAxis * direction
            bonusVec.y = 0
            bonusVec:Normalize()

            bonusVec:Scale(force)

            bonusVec.y = viewCoords.zAxis.y * verticalForce
            jumpVelocity:Add(bonusVec)
        end

        self.timeLastWallJump = Shared.GetTime()

    elseif not self:GetRecentlyJumped() and self:GetTimeGroundTouched() + Skulk.kBunnyHopMaxGroundTouchDuration < Shared.GetTime() then

        local minimumForce = Skulk.kMinBunnyHopForce
        local scalableForce = Skulk.kBunnyHopForce
        local verticalForce = Skulk.kVerticalBunnyHopForce
        local maxSpeed = self:GetMaxBunnyHopSpeed()

        local fraction = 1 - Clamp( velocity:GetLengthXZ() / maxSpeed, 0, 1)
        local force = math.max(minimumForce, scalableForce * fraction)

        -- The first jump should be 50% boost.
        if self.timeOfLastJump + Skulk.kMaxJumpComboLifetime < Shared.GetTime() then
            force = force * 0.5
        end

        local bonusVec = viewCoords:TransformVector(input.move)
        bonusVec.y = 0
        bonusVec:Normalize()

        bonusVec:Scale(force)

        bonusVec.y = viewCoords.zAxis.y * verticalForce
        jumpVelocity:Add(bonusVec)
    end

end

function Skulk:GetBaseCarapaceArmorBuff()
    return kSkulkBaseCarapaceUpgradeAmount
end

function Skulk:GetCarapaceBonusPerBiomass()
    return kSkulkCarapaceArmorPerBiomass
end

-- The Skulk movement should factor in the vertical velocity
-- only when wall walking.
function Skulk:GetMoveSpeedIs2D()
    return not self:GetIsWallWalking()
end

function Skulk:GetAcceleration()
    return 13
end

function Skulk:GetAirControl()
    return 27
end

function Skulk:GetGroundTransistionTime()
    return 0.1
end

function Skulk:GetAirAcceleration()
    return 9
end

function Skulk:GetAirFriction()
    return 0.055 - (GetHasCelerityUpgrade(self) and self:GetSpurLevel() or 0) * 0.009
end 

function Skulk:GetGroundFriction()
    return 11
end

function Skulk:GetCanStep()
    return not self:GetIsWallWalking()
end

function Skulk:OnUpdateAnimationInput(modelMixin)

    PROFILE("Skulk:OnUpdateAnimationInput")
    
    Alien.OnUpdateAnimationInput(self, modelMixin)
    
    if self:GetIsLeaping() then
        modelMixin:SetAnimationInput("move", "leap")
    end
    
    modelMixin:SetAnimationInput("onwall", self:GetIsWallWalking() and not self:GetIsJumping())
    
end

local function UpdateDashEffects(self)

    if Client then
    
        local dashing = self:GetVelocity():GetLengthXZ() > 8.7

        if self.clientDashing ~= dashing then
        
            self.timeDashChanged = Shared.GetTime()
            self.clientDashing = dashing
            
        end
        
        local soundAllowed = not GetHasSilenceUpgrade(self) or self.silenceLevel < 3        

        if self:GetIsAlive() and dashing and not self.playingDashSound and (Shared.GetTime() - self.timeDashChanged) > 1 then
        
            local volume = GetHasSilenceUpgrade(self) and 1 - (self.silenceLevel / 3) or 1        
            local localPlayerScalar = Client.GetLocalPlayer() == self and 0.26 or 1        
            volume = volume * localPlayerScalar
        
            Shared.PlaySound(self, kDashSound, volume)
            self.playingDashSound = true
        
        elseif not self:GetIsAlive() or ( not dashing and self.playingDashSound ) then    
        
            Shared.StopSound(self, kDashSound)
            self.playingDashSound = false
        
        end
    
    end

end

function Skulk:OnUpdate(deltaTime)
    
    Alien.OnUpdate(self, deltaTime)
    
    --UpdateDashEffects(self)
    
end

function Skulk:GetMovementSpecialTechId()
    return kTechId.Sneak
end

function Skulk:GetHasMovementSpecial()
    return self.movementModiferState
end

function Skulk:OnProcessMove(input)
    PROFILE("Skulk:OnProcessMove")
    Alien.OnProcessMove(self, input)
    
    --UpdateDashEffects(self)

end

function Skulk:GetIsSmallTarget()
    return true
end

local kSkulkEngageOffset = Vector(0, 0.5, 0)
function Skulk:GetEngagementPointOverride()
    return self:GetOrigin() + kSkulkEngageOffset
end

function Skulk:OnAdjustModelCoords(modelCoords)
    
    -- when sneaking, push the model back along the z-axis so the eyepoint of the model is actually close to the eyes.
    modelCoords.origin = modelCoords.origin - modelCoords.zAxis * self.sneakOffset
    
    return modelCoords
    
end

Shared.LinkClassToMap("Skulk", Skulk.kMapName, networkVars, true)

if Server then
    Event.Hook("Console_skulk_sneak", function(client, dist)
        if Shared.GetTestsEnabled() then
            if dist then
                Skulk.kMaxSneakOffset = tonumber(dist)
            end
            Log("Skulk.kMaxSneakOffset = %s", Skulk.kMaxSneakOffset)
        end
    end)
end -- Server
