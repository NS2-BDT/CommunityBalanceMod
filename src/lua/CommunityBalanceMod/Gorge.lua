-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Gorge.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Utility.lua")
Script.Load("lua/Alien.lua")
Script.Load("lua/Weapons/Alien/SpitSpray.lua")
Script.Load("lua/Weapons/Alien/InfestationAbility.lua")
Script.Load("lua/Weapons/Alien/DropStructureAbility.lua")
Script.Load("lua/Weapons/Alien/BabblerAbility.lua")
Script.Load("lua/Weapons/Alien/BileBomb.lua")
Script.Load("lua/Mixins/BaseMoveMixin.lua")
Script.Load("lua/Mixins/GroundMoveMixin.lua")
Script.Load("lua/Mixins/JumpMoveMixin.lua")
Script.Load("lua/Mixins/CrouchMoveMixin.lua")
Script.Load("lua/CelerityMixin.lua")
Script.Load("lua/Mixins/CameraHolderMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/BabblerClingMixin.lua")
Script.Load("lua/RailgunTargetMixin.lua")
Script.Load("lua/CommunityBalanceMod/BlowtorchTargetMixin.lua")
Script.Load("lua/TunnelUserMixin.lua")
Script.Load("lua/Weapons/PredictedProjectile.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/GorgeVariantMixin.lua")
Script.Load("lua/BabblerOwnerMixin.lua")
Script.Load("lua/CommunityBalanceMod/Weapons/Alien/BabblerBomb.lua")
Script.Load("lua/CommunityBalanceMod/Weapons/Alien/BabblerBombAbility.lua")

class 'Gorge' (Alien)

if Server then    
    Script.Load("lua/Gorge_Server.lua")
end

local networkVars =
{
    bellyYaw = "private compensated float",
    timeSlideEnd = "private time",
    startedSliding = "private boolean",
    sliding = "compensated boolean",
    hasBellySlide = "private compensated boolean",    
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
AddMixinNetworkVars(BabblerOwnerMixin, networkVars)
AddMixinNetworkVars(TunnelUserMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(GorgeVariantMixin, networkVars)

Gorge.kMapName = "gorge"

Gorge.kModelName = PrecacheAsset("models/alien/gorge/gorge.model")
local precached = PrecacheAsset("models/alien/gorge/gorge_view.model")
local kGorgeAnimationGraph = PrecacheAsset("models/alien/gorge/gorge.animation_graph")

-- used by Gorge_Server.lua
Gorge.kSlideLoopSound = PrecacheAsset("sound/NS2.fev/alien/gorge/slide_loop")
Gorge.kBuildSoundInterval = .5

local GorgekBuildSoundName = PrecacheAsset("sound/NS2.fev/alien/gorge/build")

Gorge.kXZExtents = 0.5
Gorge.kYExtents = 0.475

Gorge.kAirControl = 9
Gorge.kMaxAirFriction = 0.14
Gorge.kMinAirFriction = 0.18

Gorge.kMass = 80
Gorge.kJumpHeight = 1.23
Gorge.kLeanSpeed = 2
Gorge.kMaxBackwardSpeedScalar = 0.7
Gorge.kStartSlideSpeed = 9.6
Gorge.kViewOffsetHeight = 0.6
Gorge.kMaxGroundSpeed = 6
Gorge.kMaxSlidingSpeed = 14
Gorge.kSlidingMoveInputScalar = 0.1
Gorge.kBuildingModeMovementScalar = 0.001
Gorge.kSlideCoolDown = 0.5
Gorge.kBellySlideControl = 25

Gorge.kAirZMoveWeight = 2.5
Gorge.kAirStrafeWeight = 2.5
Gorge.kAirBrakeWeight = 0.1

local kGorgeBellyYaw = "belly_yaw"

Gorge.kBellyFriction = 0.1
Gorge.kBellyFrictionOnInfestation = 0.039

Gorge.kAdrenalineEnergyRecuperationRate = kGorgeAdrenalineEnergyRate

function Gorge:OnCreate()

    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, JumpMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, CelerityMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kGorgeFov })
    InitMixin(self, GorgeVariantMixin)
    
    Alien.OnCreate(self)
    
    InitMixin(self, DissolveMixin)
    InitMixin(self, BabblerClingMixin)
    InitMixin(self, BabblerOwnerMixin)
    InitMixin(self, TunnelUserMixin)
    
    InitMixin(self, PredictedProjectileShooterMixin)

    if Client then
        InitMixin(self, RailgunTargetMixin)
		InitMixin(self, BlowtorchTargetMixin)
    end
    
    self.bellyYaw = 0
    self.timeSlideEnd = 0
    self.startedSliding = false
    self.sliding = false
    self.verticalVelocity = 0

end

function Gorge:OnInitialized()

    Alien.OnInitialized(self)
    
    self:SetModel(Gorge.kModelName, kGorgeAnimationGraph)
    
    if Server then
    
        self.slideLoopSound = Server.CreateEntity(SoundEffect.kMapName)
        self.slideLoopSound:SetAsset(Gorge.kSlideLoopSound)
        self.slideLoopSound:SetParent(self)
        
    elseif Client then
    
        self:AddHelpWidget("GUIGorgeHealHelp", 2)
        self:AddHelpWidget("GUIGorgeBellySlideHelp", 2)
        self:AddHelpWidget("GUITunnelEntranceHelp", 1)
        
    end
    
    InitMixin(self, IdleMixin)
    
end

function Gorge:GetAirControl()
    return Gorge.kAirControl
end

function Gorge:GetCarapaceSpeedReduction()
    return kGorgeCarapaceSpeedReduction
end

function Gorge:GetMovementSpecialCooldown()
    local cooldown = 0
    local timeElapsed = (Shared.GetTime() - self.timeSlideEnd)

    local slideDelay = Gorge.kSlideCoolDown

    if timeElapsed < slideDelay then
        cooldown = 1 - Clamp(timeElapsed / slideDelay, 0, 1)
    end

    return cooldown
end

function Gorge:GetMovementSpecialEnergyCost()
    return kBellySlideCost
end

if Client then

    function Gorge:GetHealthbarOffset()
        return 1
    end  

    function Gorge:OverrideInput(input)

        -- Always let the DropStructureAbility override input, since it handles client-side-only build menu

        local buildAbility = self:GetWeapon(DropStructureAbility.kMapName)

        if buildAbility then
            input = buildAbility:OverrideInput(input)
        end
        
        return Player.OverrideInput(self, input)
        
    end
    
end

function Gorge:GetBaseArmor()
    return kGorgeArmor
end

function Gorge:GetBaseHealth()
    return kGorgeHealth
end

function Gorge:GetHealthPerBioMass()
    return kGorgeHealthPerBioMass
end

function Gorge:GetAdrenalineEnergyRechargeRate()
    return Gorge.kAdrenalineEnergyRecuperationRate
end

function Gorge:GetBabblerShieldPercentage()
    return kGorgeBabblerShieldPercent
end

function Gorge:GetMaxViewOffsetHeight()
    return self.kViewOffsetHeight
end

function Gorge:GetCrouchShrinkAmount()
    return 0
end

function Gorge:GetExtentsCrouchShrinkAmount()
    return 0
end

function Gorge:GetViewModelName()
    return self:GetVariantViewModel(self:GetVariant())
end

function Gorge:GetBaseCarapaceArmorBuff()
    return kGorgeBaseCarapaceUpgradeAmount
end

function Gorge:GetCarapaceBonusPerBiomass()
    return kGorgeCarapaceArmorPerBiomass
end

function Gorge:GetJumpHeight()
    return self.kJumpHeight
end

function Gorge:GetIsBellySliding()
    return self.sliding
end
--[[
function Gorge:GetCanJump()
    return not self:GetIsBellySliding()
end
--]]
function Gorge:GetIsSlidingDesired(input)

    if bit.band(input.commands, Move.MovementModifier) == 0 then
        return false
    end
    
    if self.crouching then
        return false
    end
    
    if not self:GetHasMovementSpecial() then
        return false
    end
    
    if self:GetVelocity():GetLengthXZ() < 3 or self:GetIsJumping() then
    
        if self:GetIsBellySliding() then    
            return false
        end 
           
    else
        
        local zAxis = self:GetViewCoords().zAxis
        zAxis.y = 0
        zAxis:Normalize()
        
        if GetNormalizedVectorXZ(self:GetVelocity()):DotProduct( zAxis ) < 0.2 then
            return false
        end
    
    end
    
    return true

end

-- Handle transitions between starting-sliding, sliding, and ending-sliding
function Gorge:UpdateGorgeSliding(input)

    PROFILE("Gorge:UpdateGorgeSliding")

    local slidingDesired = self:GetIsSlidingDesired(input)
    if slidingDesired and not self.sliding and self.timeSlideEnd + Gorge.kSlideCoolDown < Shared.GetTime()
            and self:GetIsOnGround() and self:GetEnergy() >= kBellySlideCost then

        self.sliding = true
        self.startedSliding = true

        if Server then
            if (GetHasSilenceUpgrade(self) and self:GetVeilLevel() == 0) or not GetHasSilenceUpgrade(self) then
                self.slideLoopSound:Start()
            end
        end

        self:DeductAbilityEnergy(kBellySlideCost)
        self:PrimaryAttackEnd()
        self:SecondaryAttackEnd()

    end

    if not slidingDesired and self.sliding then

        self.sliding = false

        if Server then
            self.slideLoopSound:Stop()
        end

        self.timeSlideEnd = Shared.GetTime()

    end

    -- Have Gorge lean into turns depending on input. He leans more at higher rates of speed.
    if self:GetIsBellySliding() then

        local desiredBellyYaw = 2 * (-input.move.x / self.kSlidingMoveInputScalar) * (self:GetVelocity():GetLength() / self:GetMaxSpeed())
        self.bellyYaw = Slerp(self.bellyYaw, desiredBellyYaw, input.time * Gorge.kLeanSpeed)

    end

end

-- Increase air friction the faster the gorge moves to avoid that ppl can maintain more than 10 m/s via bellyslide and jumping
function Gorge:GetAirFriction()
    local speedScalar = self:GetSpeedScalar()
    return math.max(self.kMaxAirFriction * speedScalar, self.kMinAirFriction)
end

function Gorge:GetCanRepairOverride()
    return true
end

function Gorge:HandleButtons(input)

    PROFILE("Gorge:HandleButtons")
    
    Alien.HandleButtons(self, input)
    
    self:UpdateGorgeSliding(input)
    
end

function Gorge:OnUpdatePoseParameters(viewModel)

    PROFILE("Gorge:OnUpdatePoseParameters")
    
    Alien.OnUpdatePoseParameters(self, viewModel)
    
    self:SetPoseParam(kGorgeBellyYaw, self.bellyYaw * 45)
    
end

function Gorge:SetCrouchState(newCrouchState)
    self.crouching = newCrouchState
end

function Gorge:GetMaxSpeed()
    return self.kMaxGroundSpeed
end

function Gorge:GetMaxBackwardSpeedScalar()
    return Gorge.kMaxBackwardSpeedScalar
end

function Gorge:GetAcceleration()
    return self:GetIsBellySliding() and 0 or 8
end

function Gorge:GetGroundFriction()
    
    if self:GetIsBellySliding() then
        return self:GetGameEffectMask(kGameEffect.OnInfestation) and Gorge.kBellyFrictionOnInfestation or Gorge.kBellyFriction
    end

    return 7
    
end

function Gorge:GetMass()
    return self.kMass
end

function Gorge:OnUpdateAnimationInput(modelMixin)

    PROFILE("Gorge:OnUpdateAnimationInput")
    
    Alien.OnUpdateAnimationInput(self, modelMixin)
    
    if self:GetIsBellySliding() then
        modelMixin:SetAnimationInput("move", "belly")
    end
    
end

function Gorge:GetMovementSpecialTechId()
    return kTechId.BellySlide
end

function Gorge:GetHasMovementSpecial()
    return true -- self.hasBellySlide or self:GetTeamNumber() == kTeamReadyRoom
end

function Gorge:ModifyVelocity(input, velocity, deltaTime)

    -- Give a little push forward to make sliding useful
    if self.startedSliding then

        if self:GetIsOnGround() then

            local pushDirection = GetNormalizedVectorXZ(self:GetViewCoords().zAxis)

            local currentSpeed = math.max(0, pushDirection:DotProduct(velocity))

            local maxSpeedTable = { maxSpeed = self.kStartSlideSpeed }
            self:ModifyMaxSpeed(maxSpeedTable, input)

            local addSpeed = math.max(0, maxSpeedTable.maxSpeed - currentSpeed)
            local impulse = pushDirection * addSpeed

            velocity:Add(impulse)

        end

        self.startedSliding = false

    end

    if self:GetIsBellySliding() then

        local currentSpeed = velocity:GetLengthXZ()
        local prevY = velocity.y
        velocity.y = 0

        local addVelocity = self:GetViewCoords():TransformVector(input.move)
        addVelocity.y = 0
        addVelocity:Normalize()
        addVelocity:Scale(deltaTime * self.kBellySlideControl)

        velocity:Add(addVelocity)
        velocity:Normalize()
        velocity:Scale(currentSpeed)
        velocity.y = prevY

    end

end

function Gorge:GetPitchSmoothRate()
    return 1
end

function Gorge:GetPitchRollRate()
    return 3
end

local kMaxSlideRoll = math.rad(20)

function Gorge:GetDesiredAngles()

    local desiredAngles = Alien.GetDesiredAngles(self)
    
    if self:GetIsBellySliding() then
        desiredAngles.pitch = - self.verticalVelocity / 10 
        desiredAngles.roll = GetNormalizedVectorXZ(self:GetVelocity()):DotProduct(self:GetViewCoords().xAxis) * kMaxSlideRoll
    end
    
    return desiredAngles

end

function Gorge:PreUpdateMove()

    self.prevY = self:GetOrigin().y

end

function Gorge:PostUpdateMove(input)

    if self:GetIsBellySliding() and self:GetIsOnGround() then

        local velocity = self:GetVelocity()

        local yTravel = self:GetOrigin().y - self.prevY
        local xzSpeed = velocity:GetLengthXZ()

        if yTravel > 0 then
            xzSpeed = xzSpeed + yTravel * -3
        else
            xzSpeed = xzSpeed + yTravel * -4
        end

        if xzSpeed < self.kMaxSlidingSpeed or yTravel > 0 then

            local directionXZ = GetNormalizedVectorXZ(velocity)
            directionXZ:Scale(xzSpeed)

            velocity.x = directionXZ.x
            velocity.z = directionXZ.z

            self:SetVelocity(velocity)

        end

        self.verticalVelocity = yTravel / input.time

    end

end

if Client then

    function Gorge:GetShowGhostModel()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("DropStructureAbility") then
            return weapon:GetShowGhostModel()
        end
        
        return false
        
    end
    
    function Gorge:GetGhostModelOverride()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("DropStructureAbility") and weapon.GetGhostModelName then
            return weapon:GetGhostModelName(self)
        end
        
    end
    
    function Gorge:GetGhostModelTechId()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("DropStructureAbility") then
            return weapon:GetGhostModelTechId()
        end
        
    end
    
    function Gorge:GetGhostModelCoords()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("DropStructureAbility") then
            return weapon:GetGhostModelCoords()
        end
        
    end
    
    function Gorge:GetLastClickedPosition()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("DropStructureAbility") then
            return weapon.lastClickedPosition
        end
        
    end

    function Gorge:GetIsPlacementValid()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("DropStructureAbility") then
            return weapon:GetIsPlacementValid()
        end
    
    end

    function Gorge:GetIgnoreGhostHighlight()
    
        local weapon = self:GetActiveWeapon()
        if weapon and weapon:isa("DropStructureAbility") and weapon.GetIgnoreGhostHighlight then
            return weapon:GetIgnoreGhostHighlight()
        end
        
    end  

end

function Gorge:GetCanSeeDamagedIcon(ofEntity)
    return not ofEntity:isa("Cyst")
end

function Gorge:GetEngagementPointOverride()
    return self:GetOrigin() + Vector(0, 0.28, 0)
end

if Server then

    function Gorge:OnProcessMove(input)
    
        Alien.OnProcessMove(self, input)
        
        self.hasBellySlide = GetIsTechAvailable(self:GetTeamNumber(), kTechId.BellySlide) == true or GetGamerules():GetAllTech()
        
        local babblerBomb = self:GetWeapon(BabblerBombAbility.kMapName) 
        if babblerBomb and babblerBomb.RechargeCharges then
            if babblerBomb:GetCurrentCharges() < babblerBomb:GetMaxCharges() then
                babblerBomb:RechargeCharges()
            end
        end
    end
	
	if kCombatVersion then
		function Gorge:GetTierThreeTechId()
			return kTechId.BabblerBombAbility
		end
	else
        function Gorge:GetTierFourTechId()
            return kTechId.BabblerBombAbility
        end
    end

end


Shared.LinkClassToMap("Gorge", Gorge.kMapName, networkVars, true)
