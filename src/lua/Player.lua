--[[
    ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======

    lua\Player.lua

    Created by:   Charlie Cleveland (charlie@unknownworlds.com)

    Player coordinates - z is forward, x is to the left, y is up.
    The origin of the player is at their feet.

    ========= For more information, visit us at http://www.unknownworlds.com =====================
]]

Script.Load("lua/Globals.lua")
Script.Load("lua/TechData.lua")
Script.Load("lua/Utility.lua")
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/PhysicsGroups.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/WeaponOwnerMixin.lua")
Script.Load("lua/DoorMixin.lua")
Script.Load("lua/Mixins/ControllerMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/AchievementReceiverMixin.lua")
Script.Load("lua/AchievementGiverMixin.lua")
Script.Load("lua/UpgradableMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/MobileTargetMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/AFKMixin.lua")
Script.Load("lua/SmoothedRelevancyMixin.lua")
Script.Load("lua/ClientLOSMixin.lua")
Script.Load("lua/menu2/PlayerScreen/CallingCards/GUIMenuCallingCardData.lua") -- kCallingCards enum
Script.Load("lua/PlayerBotMixin.lua")

if Client then
    Script.Load("lua/HelpMixin.lua")
end

--@Abstract
class 'Player' (ScriptActor)

Player.kTooltipSound = PrecacheAsset("sound/NS2.fev/common/tooltip")
Player.kToolTipInterval = 18
Player.kHintInterval = 18
Player.kPushDuration = 0.5
Player.kAllFreeCheat = false

-- min/max distance for physics culling
Player.kPhysicsCullMin = 3
Player.kPhysicsCullMax = 50

if Server then
    Script.Load("lua/Player_Server.lua")
end

if Client then
    Script.Load("lua/Player_Client.lua")
    Script.Load("lua/Chat.lua")
end

if Predict then

    function Player:OnUpdatePlayer(deltaTime)
        -- do nothing
    end

    function Player:UpdateMisc(input)
        -- do nothing
    end

end

------------
-- STATIC --
------------

-- Private
local kTapInterval = 0.27

local TAP_NONE = 0
local TAP_LEFT = 1
local TAP_RIGHT = 2
local TAP_FORWARD = 3
local TAP_BACKWARD = 4

local tapVector =
{
    TAP_NONE     = Vector(0, 0, 0),
    TAP_LEFT     = Vector(1, 0, 0),
    TAP_RIGHT    = Vector(-1, 0, 0),
    TAP_FORWARD  = Vector(0, 0, 1),
    TAP_BACKWARD = Vector(0, 0, -1)
}
local tapString =
{
    TAP_NONE     = "TAP_NONE",
    TAP_LEFT     = "TAP_LEFT",
    TAP_RIGHT    = "TAP_RIGHT",
    TAP_FORWARD  = "TAP_FORWARD",
    TAP_BACKWARD = "TAP_BACKWARD"
}

--Public
Player.kMapName = "player"

Player.kModelName                   = PrecacheAsset("models/marine/male/male.model")
local kSpecialModelName            = PrecacheAsset("models/marine/male/male_special.model")
local kClientConnectSoundName      = PrecacheAsset("sound/NS2.fev/common/connect")
local kNotEnoughResourcesSound     = PrecacheAsset("sound/NS2.fev/marine/voiceovers/commander/more")
local kInvalidSound                = PrecacheAsset("sound/NS2.fev/common/invalid")
local kChatSound                   = PrecacheAsset("sound/NS2.fev/common/chat")

-- used Player_Rumble.lua
Player.kRumbleSoundEffect           = PrecacheAsset("sound/NS2.fev/alien/onos/rumble")
Player.kFallingDirtEffect           = PrecacheAsset("cinematics/alien/onos/dirt_fall.cinematic")

Player.kRunIdleSpeed = 1

Player.kLoginBreakingDistance = 150
local kDownwardUseRange = 2.2
Player.kUseHolsterTime = 0.5
Player.kDefaultBuildTime = .2
local kUseBoxSize = Vector(0.5, 0.5, 0.5)

Player.kCountDownLength = kCountDownLength

Player.kGravity = -21.5
Player.kMass = 90.7 -- ~200 pounds (incl. armor, weapons)
Player.kWalkBackwardSpeedScalar = 0.4
-- Weapon weight scalars (from NS1)
Player.kStowedWeaponWeightScalar = 0.7
Player.kJumpHeight =  1.25
Player.kOnGroundDistance = 0.1

-- The physics shapes used for player collision have a "skin" that makes them appear to float, this makes the shape
-- smaller so they don't appear to float anymore
Player.kSkinCompensation = 0.9
Player.kXZExtents = 0.35
Player.kYExtents = 0.95
-- Eyes a bit below the top of the head. NS1 marine was 64" tall.
local kViewOffsetHeight = Player.kYExtents * 2 - 0.2

-- Slow down players when crouching
Player.kCrouchSpeedScalar = 0.5
-- Percentage change in height when full crouched
local kCrouchShrinkAmount = 0.7
local kExtentsCrouchShrinkAmount = 0.5
-- How long does it take to crouch or uncrouch

Player.kMinVelocityForGravity = .5
Player.kThinkInterval = .2
Player.kMinimumPlayerVelocity = .05    -- Minimum player velocity for network performance and ease of debugging

-- Player speeds
Player.kWalkMaxSpeed = 5                -- Four miles an hour = 6,437 meters/hour = 1.8 meters/second (increase for FPS tastes)

Player.kAcceleration = 40
Player.kRunAcceleration = 100

Player.kTauntMovementScalar = .05           -- Players can only move a little while taunting

Player.kDamageIndicatorDrawTime = 1

-- The slowest scalar of our max speed we can go to because of jumping
Player.kMinSlowSpeedScalar = .3

Player.kUnstickDistance = .1
Player.kUnstickOffsets =
{
    Vector(0, Player.kUnstickDistance, 0),
    Vector(Player.kUnstickDistance, 0, 0),
    Vector(-Player.kUnstickDistance, 0, 0),
    Vector(0, 0, Player.kUnstickDistance),
    Vector(0, 0, -Player.kUnstickDistance)
}

Player.stepTotalTime    = 0.1 --Total amount of time to interpolate up a step


-- This is how far the player can turn with their feet standing on the same ground before
-- they start to rotate in the direction they are looking.
local kBodyYawTurnThreshold = Math.Radians(85)

-- The 3rd person model angle is lagged behind the first person view angle a bit.
-- This is how fast it turns to catch up. Radians per second.
local kTurnDelaySpeed = 8
local kTurnRunDelaySpeed = 2.5
-- Controls how fast the body_yaw pose parameter used for turning while standing
-- still blends back to default when the player starts moving.
local kTurnMoveYawBlendToMovingSpeed = 5

-- This is used to push players away from each other.
local kPlayerRepelForce = 7

-- Max amount of step allowed
Player.kMaxStepAmount = 2

-------------
-- NETWORK --
-------------

--[[ When changing these, make sure to update Player:CopyPlayerDataFrom. Any data which
    needs to survive between player class changes needs to go in here.
    Compensated variables are things that you want reverted when processing commands
    so basically things that are important for defining whether or not something can be shot
    for the player this is anything that can affect the hit boxes, like the animation that's playing,
    the current animation time, pose parameters, etc (not for the player firing but for the
    player being shot).
 ]]
local networkVars =
{
    -- the player need to track its own origin at full precision in order for its
    -- own movement and actions to be fluid and predictable
    fullPrecisionOrigin = "private compensated vector",

    clientIndex = "entityid",

    viewModelId = "private entityid",

    resources = "private float (0 to " .. kMaxPersonalResources .." by 0.01)",
    teamResources = "private float (0 to " .. kMaxTeamResources .." by 0.01)", -- Todo: Remove and use TeamInfoEntity field

    frozen = "private boolean",

    timeOfLastUse = "private compensated time",
    timeLastSeasonThrow = "private compensated time",

    --bodyYaw must be compensated as it feeds into the animation as a pose parameter
    bodyYaw = "compensated interpolated float (-3.14159265 to 3.14159265 by 0.003)",
    standingBodyYaw = "compensated interpolated float (0 to 6.2831853 by 0.003)",

    bodyYawRun = "compensated interpolated float (-3.14159265 to 3.14159265 by 0.003)",
    runningBodyYaw = "compensated interpolated float (0 to 6.2831853 by 0.003)",
    timeLastMenu = "private time",
    darwinMode = "private boolean",

    moveButtonPressed = "compensated boolean",

    --[[
        Player-specific mode. When set to kPlayerMode.Default, player moves and acts normally, otherwise
        he doesn't take player input. Change mode and set modeTime to the game time that the mode
        ends. ProcessEndMode() will be called when the mode ends. Return true from that to process
        that mode change, otherwise it will go back to kPlayerMode.Default. Used for things like taunting,
        building structures and other player actions that take time while the player is stationary.
     ]]
    mode = "private compensated enum kPlayerMode",

    -- Time when mode will end. Set to -1 to have it never end.
    modeTime = "private compensated float",

    primaryAttackLastFrame = "compensated boolean",
    secondaryAttackLastFrame = "compensated boolean",
    tertiaryAttackLastFrame = "compensated boolean",

    isUsing = "boolean",

    -- Reduce max player velocity in some cases (marine jumping)
    slowAmount = "compensated float (0 to 1 by 0.01)",

    giveDamageTime = "private time",

    pushImpulse = "private vector",
    pushTime = "private time",

    isMoveBlocked = "private boolean",

    communicationStatus = "enum kPlayerCommunicationStatus",

}

------------
-- MIXINS --
------------

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(ControllerMixin, networkVars)
AddMixinNetworkVars(WeaponOwnerMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(AchievementReceiverMixin, networkVars)
AddMixinNetworkVars(UpgradableMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(ClientLOSMixin, networkVars)
AddMixinNetworkVars(PlayerBotMixin, networkVars)

local function GetTabDirectionVector(buttonReleased)

    if buttonReleased > 0 and buttonReleased < 5 then
        return tapVector[buttonReleased]
    end

    return tapVector[TAP_NONE]

end

function Player:OnCreate()

    ScriptActor.OnCreate(self)

    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, ControllerMixin)
    InitMixin(self, WeaponOwnerMixin, { kStowedWeaponWeightScalar = Player.kStowedWeaponWeightScalar })
    InitMixin(self, DoorMixin)
    -- TODO: move LiveMixin to child classes (some day)
    InitMixin(self, LiveMixin)
    InitMixin(self, AchievementReceiverMixin)
    InitMixin(self, AchievementGiverMixin)
    InitMixin(self, UpgradableMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin, { kPlayFlinchAnimations = false }) --Disable flinch animations due to hitreg desync issue on animation blending between Client/Server
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, SmoothedRelevancyMixin)
    InitMixin(self, PlayerBotMixin)

    if Client then
        InitMixin(self, HelpMixin)
        InitMixin(self, ClientLOSMixin)
        self:AddFieldWatcher("locationId", Player.OnLocationIdChange)
    end

    self:SetLagCompensated(true)

    self:SetUpdates(true, kRealTimeUpdateRate)

    if Server then

        InitMixin(self, AFKMixin)

        self.name = ""
        self.giveDamageTime = 0
        self.sendTechTreeBase = false
        self.waitingForAutoTeamBalance = false

    elseif Client then

        self.giveDamageTimeClientCheck = 0

    end

    self.viewOffset = Vector(0, 0, 0)

    self.bodyYaw = 0
    self.standingBodyYaw = 0

    self.bodyYawRun = 0
    self.runningBodyYaw = 0

    self.clientIndex = -1

    self.timeLastMenu = 0
    self.darwinMode = false

    self.leftFoot = true
    self.mode = kPlayerMode.Default
    self.modeTime = -1
    self.primaryAttackLastFrame = false
    self.secondaryAttackLastFrame = false
    self.tertiaryAttackLastFrame = false

    self.requestsScores = false
    self.viewModelId = Entity.invalidId

    self.usingStructure = nil
    self.timeOfLastUse = 0
    self.timeLastSeasonThrow = 0

    self.timeOfDeath = nil

    self.resources = 0

    self.isMoveBlocked = false
    self.isRookie = false

    self.moveButtonPressed = false

    -- Make the player kinematic so that bullets and other things collide with it.
    self:SetPhysicsGroup(PhysicsGroup.PlayerGroup)

    self.isUsing = false
    self.slowAmount = 0

    self.lastButtonReleased = TAP_NONE
    self.timeLastButtonReleased = 0
    self.previousMove = Vector(0, 0, 0)

    self.pushImpulse = Vector(0, 0, 0)
    self.pushTime = 0

    self.concedeSettingsIndex = 1
    self.callingCard = kDefaultPlayerCallingCard

end

local function InitViewModel(self)

    assert(Server)
    assert(self.viewModelId == Entity.invalidId)

    local viewModel = CreateEntity(ViewModel.mapName)
    viewModel:SetOrigin(self:GetOrigin())
    viewModel:SetParent(self)
    self.viewModelId = viewModel:GetId()

end

function Player:OnInitialized()

    ScriptActor.OnInitialized(self)

    if Server then

        InitViewModel(self)
        -- Only give weapons when playing.
        if self:GetTeamNumber() ~= kNeutralTeamType and not self.preventWeapons then
            self:InitWeapons()
        elseif self:GetTeamNumber() == kNeutralTeamType then
            self:InitWeaponsForReadyRoom()
        end

        self:SetNextThink(Player.kThinkInterval)

        InitMixin(self, MobileTargetMixin)

    end

    self:SetViewOffsetHeight(self:GetMaxViewOffsetHeight())
    self:UpdateControllerFromEntity()

    if Client then

        self.cameraShakeAmount = 0
        self.cameraShakeSpeed = 0
        self.cameraShakeTime = 0
        self.cameraShakeLastTime = 0

        self.lightShakeAmount = 0
        self.lightShakeEndTime = 0
        self.lightShakeScalar = 1

        self.giveDamageTimeClient = self.giveDamageTime

        if not self:GetIsLocalPlayer() and not self:isa("Commander") and not self:isa("Spectator") then
            InitMixin(self, UnitStatusMixin)
        end

        local serverBlood = GetAdvancedOption("serverblood")
        local message =
        {
            serverBlood = serverBlood
        }
        Client.SendNetworkMessage("ServerConfirmedHitEffects", message, true)

        self.serverBlood = serverBlood

        Player.kTracersEnabled = GetAdvancedOption("tracers")

        Client.SendNetworkMessage("SetAlienWeaponUseHUDSlot",
        {
            slotMode = GetAdvancedOption("alien_weaponslots")
        }, true)

        Client.SendNetworkMessage("InitAVState",
        {
            startsOn = GetAdvancedOption("avstate")
        }, true)
    end

    -- TODO: MOVE TO ONCREATE
    self.communicationStatus = kPlayerCommunicationStatus.None

end

function Player:GetIsSteamFriend()

    if self.isSteamFriend == nil and self.clientIndex > 0 then

        local steamId = GetSteamIdForClientIndex(self.clientIndex)
        if steamId then
            self.isSteamFriend = Client.GetIsSteamFriend(steamId)
        end

    end

    return self.isSteamFriend
end

--[[
    Called when the player entity is destroyed.
]]
function Player:OnDestroy()

    ScriptActor.OnDestroy(self)

    if Client then

        if self.viewModel ~= nil then

            Client.DestroyRenderViewModel(self.viewModel)
            self.viewModel = nil

        end

        self:UpdateCloakSoundLoop(false)
        self:UpdateDisorientSoundLoop(false)

        self:CloseMenu()

        if self.unitStatusDisplay then

            GetGUIManager():DestroyGUIScriptSingle("GUIUnitStatus")
            self.unitStatusDisplay = nil

        end

    elseif Server then
        self:RemoveSpectators(nil)

        if self.playerInfo then

            DestroyEntity(self.playerInfo)
            self.playerInfo = nil

        end

        if self:GetIsVirtual() then
            local bot = self:GetControllingBot()
            if bot then
                bot:OnDestroy()
            end
        end

    end

end

function Player:OnEntityChange(oldEntityId, newEntityId)

    if Client then

        if self:GetId() == oldEntityId then
            -- If this player is changing is any way, just assume the
            -- buy/evolve menu needs to close.
            self:CloseMenu()
        end

        -- If this is a player changing classes that we're already following, update the id
        local player = Client.GetLocalPlayer()
        if player.followId == oldEntityId then
            Client.SendNetworkMessage("SpectatePlayer", {entityId = newEntityId}, true)
            player.followId = newEntityId
        end

    end

end

--[[
    Camera will zoom to third person and not attach to the ragdolls head when set to false.
    Child classes can overwrite this.
]]
function Player:GetAnimateDeathCamera()
    return true
end

function Player:GetReceivesBiologicalDamage()
    return true
end

function Player:GetReceivesVaporousDamage()
    return true
end

-- Special unique client-identifier
function Player:GetClientIndex()
    return self.clientIndex
end

function Player:AddPushImpulse(vector)
    self.pushImpulse = Vector(vector)
    self.pushTime = Shared.GetTime()
end

function Player:OverrideInput(input)

    ClampInputPitch(input)

    if self.timeClosedMenu and (Shared.GetTime() < self.timeClosedMenu + .25) then

        -- Don't allow weapon firing
        local removePrimaryAttackMask = bit.bxor(0xFFFFFFFF, Move.PrimaryAttack)
        input.commands = bit.band(input.commands, removePrimaryAttackMask)

    end

    if self.shortcircuitInput then
        input.commands = 0x00000000
        input.move = Vector(0,0,0)
    end

    self.shortcircuitInput = MainMenu_GetIsOpened()

    return input

end

function Player:GetIsFirstPerson()
    return (Client and (Client.GetLocalPlayer() == self) and not self:GetIsThirdPerson())
end

function Player:GetViewOffset()
    return self.viewOffset
end


--[[
    Stores the player's current view offset. Calculated from GetMaxViewOffset() and crouch state.
]]
function Player:SetViewOffsetHeight(newViewOffsetHeight)
    self.viewOffset.y = newViewOffsetHeight
end

function Player:GetMaxViewOffsetHeight()
    return kViewOffsetHeight
end

-- worldX => -map y
-- worldZ => +map x
function Player:GetMapXY(worldX, worldZ)

    local success = false
    local mapX = 0
    local mapY = 0

    local heightmap = GetHeightmap()

    if heightmap then
        mapX = heightmap:GetMapX(worldZ)
        mapY = heightmap:GetMapY(worldX)
    else
        Print("Player:GetMapXY(): heightmap is nil")
        return false, 0, 0
    end

    if mapX >= 0 and mapX <= 1 and mapY >= 0 and mapY <= 1 then
        success = true
    end

    return success, mapX, mapY

end

-- Return modifier to our max speed (1 is none, 0 is full)
function Player:GetSlowSpeedModifier()

    -- Never drop to 0 speed
    return 1 - (1 - Player.kMinSlowSpeedScalar) * self.slowAmount

end

function Player:GetController()

    return self.controller

end

function Player:WeaponUpdate()

    local weapon = self:GetActiveWeapon()
    if weapon and weapon.OnUpdateWeapon then
        weapon:OnUpdateWeapon(self)
    end

end

function Player:OnPrimaryAttack()
end

function Player:OnSecondaryAttack()
end

function Player:PrimaryAttack()

    local weapon = self:GetActiveWeapon()
    if weapon then
        weapon:OnPrimaryAttack(self)
        self:OnPrimaryAttack()
    end

end

function Player:SecondaryAttack()

    local weapon = self:GetActiveWeapon()
    if weapon and weapon:GetHasSecondary(self) then
        weapon:OnSecondaryAttack(self)
        self:OnSecondaryAttack()
    end

end

function Player:TertiaryAttack()

end

function Player:PrimaryAttackEnd()

    local weapon = self:GetActiveWeapon()
    if weapon then
        weapon:OnPrimaryAttackEnd(self)
    end

end

function Player:SecondaryAttackEnd()

    local weapon = self:GetActiveWeapon()
    if weapon and weapon:GetHasSecondary(self) then
        weapon:OnSecondaryAttackEnd(self)
    end

end

function Player:TertiaryAttackEnd()

end

function Player:SelectNextWeapon()
    self:SelectNextWeaponInDirection(1)
end

function Player:SelectPrevWeapon()
    self:SelectNextWeaponInDirection(-1)
end

function Player:Reload()

    local weapon = self:GetActiveWeapon()
    if weapon ~= nil then
        weapon:OnReload(self)
    end

end

local function GetIsValidUseOfPoint(self, entity, usablePoint, useRange)

    if GetPlayerCanUseEntity(self, entity) then

        local viewCoords = self:GetViewAngles():GetCoords()
        local toUsePoint = usablePoint - self:GetEyePos()

        return toUsePoint:GetLength() < useRange and viewCoords.zAxis:DotProduct(GetNormalizedVector(toUsePoint)) > 0.8

    end

    return false

end

--[[
    Will return true if the passed in entity can be used by self and
    the entity has no attach points to use.
]]
local function GetCanEntityBeUsedWithNoUsablePoint(self, entity)

    if HasMixin(entity, "Usable") then

        -- Ignore usable points if a Structure has not been built.
        local usablePointOverride = HasMixin(entity, "Construct") and not entity:GetIsBuilt()

        local usablePoints = entity:GetUsablePoints()
        if usablePointOverride or (not usablePoints or #usablePoints == 0) and GetPlayerCanUseEntity(self, entity) then
            return true, nil
        end

    end

    return false, nil

end

function Player:PerformUseTrace()

    local startPoint = self:GetEyePos()
    local viewCoords = self:GetViewAngles():GetCoords()

    -- To make building low objects like an infantry portal easier, increase the use range
    -- as we look downwards. This effectively makes use trace in a box shape when looking down.
    local isUsing = self:GetIsUsing()
    local useAngle = -0.5
    local useBoxSize1 = Vector(0.2, 0.2, 0.2)
    local useBoxSize2 = kUseBoxSize
    local maxUseLength = (useBoxSize2 - -useBoxSize2):GetLength()

    local useRange = kPlayerUseRange
    local sinAngle = viewCoords.zAxis:GetLengthXZ()
    if viewCoords.zAxis.y < 0 and sinAngle > 0 then

        useRange = kPlayerUseRange / sinAngle
        if -viewCoords.zAxis.y * useRange > kDownwardUseRange then
            useRange = kDownwardUseRange / -viewCoords.zAxis.y
        end

    end

    -----------------
    -- Artifially increase the range if we are actually building, so we get 2 completly different thresholds
    -- for starting to 'use', and stopping it. Those removing the glitch in/out/in/out effect near edge values.

    -- VAR   = VAR      * (isUsing and FORGIVING_VALUE or DEFAULT_VALUE)
    -- useRange = useRange + (isUsing and 1.00 or 0)

    -- useAngle = useAngle * (isUsing and -0.60 or -0.50)
    -- useBoxSize1 = useBoxSize1 * (isUsing and 2.00 or 1.00)
    -- useBoxSize2 = useBoxSize2 * (isUsing and 2.00 or 1.00)
    -- maxUseLength = maxUseLength + (isUsing and 0.50 or 0)

    -----------------

    -- Get possible useable entities within useRange that have an attach point.
    local ents = GetEntitiesWithMixinWithinRange("Usable", self:GetOrigin(), useRange)
    for e = 1, #ents do

        local entity = ents[e]
        -- Filter away anything on the enemy team. Allow using entities not on any team.
        if not HasMixin(entity, "Team") or self:GetTeamNumber() == entity:GetTeamNumber() then

            local usablePoints = entity:GetUsablePoints()
            if usablePoints then

                for p = 1, #usablePoints do

                    local usablePoint = usablePoints[p]
                    local success = GetIsValidUseOfPoint(self, entity, usablePoint, useRange)
                    if success then
                        return entity, usablePoint
                    end

                end

            end

        end

    end

    -- If failed, do a regular trace with entities that don't have usable points.
    local viewCoords = self:GetViewAngles():GetCoords()
    local endPoint = startPoint + viewCoords.zAxis * kMaxRelevancyDistance

    local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.AllButPCsAndRagdollsAndBabblers, EntityFilterOneAndIsa(self, "Weapon"))

    if isUsing and trace.entity == nil then
        trace = Shared.TraceBox(useBoxSize1, startPoint, endPoint, CollisionRep.Damage, PhysicsMask.AllButPCsAndRagdollsAndBabblers, EntityFilterOneAndIsa(self, "Weapon"))
    end

    if trace.fraction < 1 and trace.entity ~= nil then

        local distToEnt = trace.endPoint:GetDistanceTo(startPoint)
        local maxDistToUse = trace.entity.GetUseMaxRange and trace.entity:GetUseMaxRange() or useRange
        -- Only return this entity if it can be used and it does not have a usable point (which should have been
        -- caught in the above cases).
        if distToEnt <= maxDistToUse and GetCanEntityBeUsedWithNoUsablePoint(self, trace.entity) then
            return trace.entity, trace.endPoint
            -- else
            --     Log("First traceBox error (%s / %s", tostring(distToEnt <= maxDistToUse), trace.entity)
        end
        -- else
        --     Log("No entity or fraction touched a wall: %s / %s", tostring(trace.fraction), trace.entity)
    end


    if isUsing then
        -- Called in case the normal trace fails to allow some tolerance.
        -- Modify the endPoint to account for the size of the box.
        endPoint = startPoint + viewCoords.zAxis * (useRange - maxUseLength / 2)
        local traceBox = Shared.TraceBox(useBoxSize2, startPoint, endPoint, CollisionRep.Move, PhysicsMask.AllButPCsAndRagdollsAndBabblers, EntityFilterOneAndIsa(self, "Weapon"))
        -- Only return this entity if it can be used and it does not have a usable point (which should have been caught in the above cases).
        if traceBox.fraction < 1 and traceBox.entity ~= nil and GetCanEntityBeUsedWithNoUsablePoint(self, traceBox.entity) then

            local direction = startPoint - traceBox.entity:GetOrigin()
            direction:Normalize()

            -- Must be generally facing the entity.
            if viewCoords.zAxis:DotProduct(direction) < useAngle then
                return traceBox.entity, traceBox.endPoint
                -- else
                --     Log("View angle too bad; %s < %s", tostring(viewCoords.zAxis:DotProduct(direction)), tostring(useAngle))
            end

        end
    end

    -- Log("None of the trace matched")

    return nil, Vector(0, 0, 0)

end

function Player:UseTarget(entity, timePassed)

    assert(entity)

    local useSuccessTable = { useSuccess = false }
    if entity.OnUse then

        useSuccessTable.useSuccess = true
        entity:OnUse(self, timePassed, useSuccessTable)

    end

    self:OnUseTarget(entity)

    return useSuccessTable.useSuccess

end

--[[
    Check to see if there's a ScriptActor we can use. Checks any usable points returned from
    GetUsablePoints() and if that fails, does a regular trace ray. Returns true if we processed the action.
]]
local function AttemptToUse(self, timePassed)

    PROFILE("Player:AttemptToUse")

    assert(timePassed >= 0)

    local now = Shared.GetTime()

    -- Cannot use anything unless playing the game (a non-spectating player).
    if now - self.timeOfLastUse < kUseInterval or self:isa("Spectator") then
        return false
    end

    -- Trace to find use entity.
    local entity, usablePoint = self:PerformUseTrace()

    -- Use it.
    if entity then

        -- if the game isn't started yet, check if the entity is usuable in non-started game
        -- (allows players to select commanders before the game has started)
        if not self:GetGameStarted() and not (entity.GetUseAllowedBeforeGameStart and entity:GetUseAllowedBeforeGameStart()) then
            return false
        end

        -- Special check for warmup mode
        if entity.GetCanBeUsedDuringWarmup and GetWarmupActive() and not entity:GetCanBeUsedDuringWarmup() then
            return false
        end

        local elapsedTime = 0
        if self:GetIsUsing() then -- Was using, so we can get dT
            elapsedTime = now - self.timeOfLastUse
        end
        
        -- Use it.
        if self:UseTarget(entity, elapsedTime) then

            if kDebugBuildTimes and HasMixin(entity, "Construct") and not entity:GetIsBuilt() then

                if not self:GetIsUsing() then -- Started using now
                    ClearBuildTimesDebugInfo()
                    kDebugBuildTimesInfo.timeStarted = now
                    kDebugBuildTimesInfo.targetClassName = entity:GetClassName()
                    kDebugBuildTimesUI:InitSession(kDebugBuildTimesInfo.targetClassName, LookupTechData(entity:GetTechId(), kTechDataBuildTime, 0))
                end

                kDebugBuildTimesUI:UpdateInfo(now - kDebugBuildTimesInfo.timeStarted)
                
            end
            
            self:SetIsUsing(true)
            self.timeOfLastUse = now
            return true

        end

    end
    
    return false

end

function Player:Buy()
end

function Player:Holster()

    local success = false
    local weapon = self:GetActiveWeapon()

    if weapon then

        weapon:OnHolster(self)

        success = true

    end

    return success

end

function Player:Draw(previousWeaponName)

    local success = false
    local weapon = self:GetActiveWeapon()

    if weapon ~= nil then

        weapon:OnDraw(self, previousWeaponName)

        success = true

    end

    return success

end

--[[
    Returns true if the player is currently on a team and the game has started.
]]
function Player:GetIsPlaying()
    return self:GetGameStarted() and self:GetIsOnPlayingTeam()
end

function Player:GetIsOnPlayingTeam()
    return self:GetTeamNumber() == kTeam1Index or self:GetTeamNumber() == kTeam2Index
end

function Player:GetTechAllowed(techId, techNode)
    return ScriptActor.GetTechAllowed(self, techId, techNode, self)
end

local function HasTeamAssigned(self)

    local teamNumber = self:GetTeamNumber()
    return (teamNumber == kTeam1Index or teamNumber == kTeam2Index)

end

function Player:GetCanTakeDamageOverride()
    return HasTeamAssigned(self)
end

function Player:GetCanDieOverride()
    return HasTeamAssigned(self)
end

-- Individual resources
function Player:GetResources()

    if Shared.GetCheatsEnabled() and Player.kAllFreeCheat then
        return 100
    else
        return Round(self.resources, 2)
    end

end

-- Returns player mass in kg
function Player:GetMass()
    return Player.kMass
end

function Player:AddTeamResources(amount)
    self.teamResources = math.max(math.min(self.teamResources + amount, kMaxTeamResources), 0)
end

function Player:GetDisplayResources()
    return self:GetResources()
end

function Player:GetPersonalResources()

    if Shared.GetCheatsEnabled() and Player.kAllFreeCheat then
        return 100
    else
        return self:GetResources()
    end

end

function Player:GetDisplayTeamResources()

    local displayTeamResources = self.teamResources
    if(Client and self.resourceDisplay) then
        displayTeamResources = self.animatedTeamResourcesDisplay:GetDisplayValue()
    end
    return displayTeamResources

end

-- Team resources
function Player:GetTeamResources()
    return self.teamResources
end

function Player:GetGroundFriction()
    return 9
end

function Player:GetAirFriction()
    return 0
end

function Player:GetClimbFriction()
    return 5
end

function Player:GetCanClimb()
    return true
end

function Player:GetClampedMaxSpeed()
    return 30
end


function Player:GetPerformsVerticalMove()
    return false
end

function Player:ModifyGravityForce(gravityTable)

    if self:GetIsOnGround() then
        gravityTable.gravity = 0
    end

end

function Player:OnUseTarget(target)
end

function Player:OnUseEnd()
end

function Player:EndUse(deltaTime)

    if not self:GetIsUsing() then
        return
    end

    local callOnUseEnd = false

    -- Pull out weapon again if we haven't built for a bit
    if (Shared.GetTime() - self.timeOfLastUse) > kUseInterval then

        self:SetIsUsing(false)
        callOnUseEnd = true

    elseif self:isa("Alien") then

        self:SetIsUsing(false)
        callOnUseEnd = true

    end

    if callOnUseEnd then
        self:OnUseEnd()
    end

    self.updatedSinceUse = true

end

function Player:GetMinimapFov(targetEntity)

    if targetEntity and targetEntity:isa("Player") then
        return 60
    end

    return 90

end

function Player:GetCrouchSpeedScalar()
    return Player.kCrouchSpeedScalar
end

-- Allow child classes to alter player's move at beginning of frame. Alter amount they
-- can move by scaling input.move, remove key presses, etc.
function Player:AdjustMove(input)

    PROFILE("Player:AdjustMove")

    ConcedeSequence.ModifyPlayerMove(self, input)

    -- Don't allow movement when frozen in place
    --McG: Remove as frozen state can get out of sync depending on when players join a team
    --the desired effect of frozen flag is already dealt with in Player:OnProcessMove() anyways, this is pointless.
    --if self.frozen then
    --    input.move:Scale(0)
    --else

    -- Allow child classes to affect how much input is allowed at any time
    if self.mode == kPlayerMode.Taunt then
        input.move:Scale(Player.kTauntMovementScalar)
    end

    --end

    return input

end

function Player:GetAngleSmoothingMode()
    return "euler"
end

function Player:GetDesiredAngles(deltaTime)

    local desiredAngles = Angles()
    desiredAngles.pitch = 0
    desiredAngles.roll = self.viewRoll
    desiredAngles.yaw = self.viewYaw

    return desiredAngles

end

function Player:GetAngleSmoothRate()
    return 10
end

function Player:GetRollSmoothRate()
    return 6
end

function Player:GetPitchSmoothRate()
    return 6
end

function Player:GetSlerpSmoothRate()
    return 6
end

function Player:GetSmoothRoll()
    return true
end

function Player:GetSmoothPitch()
    return true
end

function Player:GetPredictSmoothing()
    return true
end

-- also predict smoothing on the local client, since no interpolation is happening here and some effects can depent on current players angle (like exo HUD)
function Player:AdjustAngles(deltaTime)

    local angles = self:GetAngles()
    local desiredAngles = self:GetDesiredAngles(deltaTime)
    local smoothMode = self:GetAngleSmoothingMode()

    if desiredAngles == nil then

        -- Just keep the old angles

    elseif smoothMode == "euler" then


        angles.yaw = SlerpRadians(angles.yaw, desiredAngles.yaw, self:GetAngleSmoothRate() * deltaTime )
        angles.roll = SlerpRadians(angles.roll, desiredAngles.roll, self:GetRollSmoothRate() * deltaTime )
        angles.pitch = SlerpRadians(angles.pitch, desiredAngles.pitch, self:GetPitchSmoothRate() * deltaTime )

    elseif smoothMode == "quatlerp" then

        --DebugDrawAngles( angles, self:GetOrigin(), 2.0, 0.5 )
        --Print("pre slerp = %s", ToString(angles))
        angles = Angles.Lerp( angles, desiredAngles, self:GetSlerpSmoothRate()*deltaTime )

    else

        angles.pitch = desiredAngles.pitch
        angles.roll = desiredAngles.roll
        angles.yaw = desiredAngles.yaw

    end

    AnglesTo2PiRange(angles)
    self:SetAngles(angles)

end

function Player:UpdateViewAngles(input)

    PROFILE("Player:UpdateViewAngles")

    if ConcedeSequence.GetIsPlayerObserving(self) then
        return
    end

    -- Update to the current view angles.
    local viewAngles = Angles(input.pitch, input.yaw, 0)
    self:SetViewAngles(viewAngles)

    self:AdjustAngles(input.time)

end

function Player:GetTriggerLandEffect()
    local xzSpeed = self:GetVelocity():GetLengthXZ()
    return not HasMixin(self, "CrouchMove") or not self:GetCrouching() or (xzSpeed / self:GetMaxSpeed()) > 0.9
end

function Player:OnGroundChanged(onGround, impactForce, normal, velocity)

    if onGround and self:GetTriggerLandEffect() and impactForce > 5 then

        local landSurface = GetSurfaceAndNormalUnderEntity(self)
        self:TriggerEffects("land", { surface = landSurface })

    end

    if normal and normal.y > 0.5 and self:GetSlowOnLand() then

        local slowdownScalar = Clamp(math.max(0, impactForce - 4) / 18, 0, 1)
        if self.ModifyJumpLandSlowDown then
            slowdownScalar = self:ModifyJumpLandSlowDown(slowdownScalar)
        end

        self:AddSlowScalar(slowdownScalar)
        velocity:Scale(1 - slowdownScalar)

    end

end

function Player:OnJump()
    self:TriggerEffects("jump", {surface = self:GetMaterialBelowPlayer()})
end

function Player:SlowDown(slowScalar)
    self:AddSlowScalar(slowScalar)
end

local kDoublePI = math.pi * 2
local kHalfPI = math.pi / 2

function Player:GetIsUsingBodyYaw()
    return true
end

function Player:GetBodyYawTurnThreshold()
    return -kBodyYawTurnThreshold, kBodyYawTurnThreshold
end

local function UpdateBodyYaw(self, deltaTime, tempInput)

    if self:GetIsUsingBodyYaw() then

        local yaw = self:GetAngles().yaw

        -- Reset values when moving.
        if self:GetVelocityLength() > 0.1 then
            -- Take a bit of time to reset value so going into the move animation doesn't skip.
            self.standingBodyYaw = SlerpRadians(self.standingBodyYaw, yaw, deltaTime * kTurnMoveYawBlendToMovingSpeed)
            self.standingBodyYaw = Math.Wrap(self.standingBodyYaw, 0, kDoublePI)

            self.runningBodyYaw = SlerpRadians(self.runningBodyYaw, yaw, deltaTime * kTurnRunDelaySpeed)
            self.runningBodyYaw = Math.Wrap(self.runningBodyYaw, 0, kDoublePI)

        else
            self.runningBodyYaw = yaw

            local bodyYawTurnThresholdLeft,bodyYawTurnThresholdRight = self:GetBodyYawTurnThreshold()
            local diff = RadianDiff(self.standingBodyYaw, yaw)

            if diff < bodyYawTurnThresholdLeft or bodyYawTurnThresholdRight < diff then

                diff = Clamp(diff, bodyYawTurnThresholdLeft, bodyYawTurnThresholdRight)
                self.standingBodyYaw = Math.Wrap(diff + yaw, 0, kDoublePI)

            end

        end

        self.bodyYawRun = Clamp(RadianDiff(self.runningBodyYaw, yaw), -kHalfPI, kHalfPI)
        self.runningBodyYaw = Math.Wrap(self.bodyYawRun + yaw, 0, kDoublePI)

        local adjustedBodyYaw = RadianDiff(self.standingBodyYaw, yaw)
        if adjustedBodyYaw >= 0 then
            self.bodyYaw = adjustedBodyYaw % kHalfPI
        else
            self.bodyYaw = -(kHalfPI - adjustedBodyYaw % kHalfPI)
        end

    else

        -- Sometimes, probably due to prediction, these values can go out of range. Wrap them here
        self.standingBodyYaw = Math.Wrap(self.standingBodyYaw, 0, kDoublePI)
        self.runningBodyYaw = Math.Wrap(self.runningBodyYaw, 0, kDoublePI)
        self.bodyYaw = 0
        self.bodyYawRun = 0

    end

end
local function UpdateAnimationInputs(self, input)

    -- From WeaponOwnerMixin.
    -- NOTE: We need to process moves on weapons and view model before adjusting origin + angles below.
    self:ProcessMoveOnWeapons(input)

    local viewModel = self:GetViewModelEntity()
    if viewModel then
        viewModel:ProcessMoveOnModel(input.time)
    end

    if self.ProcessMoveOnModel then
        self:ProcessMoveOnModel(input.time)
    end

end

function Player:ConfigurePhysicsCuller()

    if GetConcedeSequenceActive() then
        return
    end

    local viewCoords = self:GetCameraViewCoords()
    local viewPoint = viewCoords.origin
    local viewAngles = Angles()
    viewAngles:BuildFromCoords(viewCoords)
    local fovDegrees = Math.Degrees(GetScreenAdjustedFov(Client.GetEffectiveFov(self), 4/3))
    local maxDistOrOff = PlayerUI_IsOverhead() and 0 or Player.kPhysicsCullMax

    Client.ConfigurePhysicsCuller(viewPoint, viewAngles, fovDegrees, Player.kPhysicsCullMin, maxDistOrOff)

end

function Player:OnProcessIntermediate(input)

    if self:GetIsAlive() and not self:GetCountdownActive() then
        -- Update to the current view angles so that the mouse feels smooth and responsive.
        self:UpdateViewAngles(input)
    end

    -- This is necessary to update the child entity bones so that the view model
    -- animates smoothly and attached weapons will have the correct coords.
    local numChildren = self:GetNumChildren()
    for i = 1,numChildren do
        local child = self:GetChildAtIndex(i - 1)
        if child.OnProcessIntermediate then
            child:OnProcessIntermediate(input)
        end
    end

    if true then
        PROFILE("Player:OnProcessIntermediate:UpdateClientEffects")
        self:UpdateClientEffects(input.time, true)
    end

    if Client then
        self:ConfigurePhysicsCuller()
    end

end

function Player:GetHasController()

    if (Client or Predict) and self.isHallucination then
        return false
    end

    return HasMixin(self, "Live") and self:GetIsAlive()

end

function Player:GetHasOutterController()

    if (Client or Predict) and self.isHallucination then
        return false
    end

    return HasMixin(self, "Live") and self:GetIsAlive()

end

-- You can't modify a compensated field for another (relevant) entity during OnProcessMove(). The
-- "local" player doesn't undergo lag compensation it's only all of the other players and entities.
-- For example, if health was compensated, you can't modify it when a player was shot -
-- it will just overwrite it with the old value after OnProcessMove() is done. This is because
-- compensated fields are rolled back in time, so it needs to restore them once the processing
-- is done. So it backs up, synchs to the old state, runs the OnProcessMove(), then restores them.
function Player:OnProcessMove(input)
    PROFILE("Player:OnProcessMove")

    -- ensure that a player is always moving itself using full precision
    self:SetOrigin(self.fullPrecisionOrigin)
    -- Log("%s: TrackVel-0-start : vel=%s", self, self.velocity)
    -- Log("%s: TrackYaw-0-input: input.yaw=%s|input.pitch=%s", self, input.yaw, input.pitch)
    -- Log("%s: TrackYaw-1-start : y=%s|yR=%s|standY=%s|runY=", self, self.bodyYaw, self.bodyYawRun, self.standingBodyYaw, self.runningBodyYaw)
    -- local startOrigin = self:GetEyePos()
    -- Log("%s: TrackProcessMove-0-start : eye=%s|vel=%s", self, startOrigin, self:GetVelocity())

    SetMoveForHitregAnalysis(input)

    local commands = input.commands
    if self:GetIsAlive() then

        if self:GetCountdownActive() then

            input.move:Scale(0)
            input.commands = 0

        else

            -- Allow children to alter player's move before processing. To alter the move
            -- before it's sent to the server, use OverrideInput
            input = self:AdjustMove(input)

            -- Update player angles and view angles smoothly from desired angles if set.
            -- But visual effects should only be calculated when not predicting.
            self:UpdateViewAngles(input)

        end

    end
    
    do
        PROFILE("Player:OnProcessMove:OnUpdatePlayer")
        self:OnUpdatePlayer(input.time)
    end

    ScriptActor.OnProcessMove(self, input)

    self:HandleButtons(input)

    UpdateAnimationInputs(self, input)

    if self:GetIsAlive() then

        local runningPrediction = Shared.GetIsRunningPrediction()

        if self.PreUpdateMove then
            self:PreUpdateMove(input, runningPrediction)
        end

        -- Update origin and velocity from input move (main physics behavior).
        self:UpdateMove(input, runningPrediction)

        if self.PostUpdateMove then
            self:PostUpdateMove(input, runningPrediction)
        end

        self:UpdateMaxMoveSpeed(input.time)

        -- Restore the buttons so that things like the scoreboard, etc. work.
        input.commands = commands

        -- Everything else
        self:UpdateMisc(input)
        self:UpdateSharedMisc(input)

        -- Debug if desired
        --self:OutputDebug()

        UpdateBodyYaw(self, input.time, input)

    end

    self:EndUse(input.time)

    if Server then
        HitSound_DispatchHits()
    end

    if Client then
        self:ConfigurePhysicsCuller()
    end

    -- for debugging hitreg; if hitreg scan is enabled, we generate a hitreg scan every move
    -- very spammy and wasteful of network resources
    if self.hitregDebugAlways then
        local viewAxis = self:GetViewAngles():GetCoords().zAxis
        local startPoint = self:GetEyePos()
        local endPoint = startPoint + viewAxis * 100
        local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(self))
        -- Log("%s: TrackHitreg-1 : view=%s|start=%s", self, viewAxis, startPoint)
        HandleHitregAnalysis(self, startPoint, endPoint, trace)
    end

    -- local amount = self:GetCrouchAmount()
    -- local offset = -self:GetCrouchShrinkAmount() * amount
    -- Log("%s: Crouching-2-Camera:offset=%s|amount=%s|time=%s|crouch=%s", self, offset, amount, self.timeOfCrouchChange, self.crouching)

    -- local distMoved = self:GetEyePos() - startOrigin
    -- Log("%s: TrackProcessMove-1-end : eye=%s|vel=%s|moved=%s", self, self:GetEyePos()(), self:GetVelocity(), distMoved)
    -- Log("%s: TrackVel-1-end : vel=%s", self, self.velocity)
    -- Log("%s: TrackY-1-end : startY=%s|y=%s", self, startOrigin.y, self:GetOrigin().y)
end

function Player:OnProcessSpectate(deltaTime)

    ScriptActor.OnProcessSpectate(self, deltaTime)

    local numChildren = self:GetNumChildren()
    for i = 1, numChildren do

        local child = self:GetChildAtIndex(i - 1)
        if child.OnProcessIntermediate then
            child:OnProcessIntermediate()
        end

    end

    local viewModel = self:GetViewModelEntity()
    if viewModel then
        viewModel:ProcessMoveOnModel(deltaTime)
    end

    self:OnUpdatePlayer(deltaTime)

end

function Player:OnUpdate(deltaTime)

    ScriptActor.OnUpdate(self, deltaTime)

    if true then
        PROFILE("Player:OnUpdate:OnUpdatePlayer")
        self:OnUpdatePlayer(deltaTime)
    end

end

function Player:GetSlowOnLand()
    return false
end

function Player:UpdateMaxMoveSpeed(deltaTime)

    ASSERT(deltaTime >= 0)

    -- Only recover max speed when on the ground
    if HasMixin(self, "GroundMove") and self:GetIsOnGround() then

        local newSlow = math.max(0, self.slowAmount - deltaTime)
        self.slowAmount = newSlow

    end

end

function Player:OutputDebug()

    local startPoint = Vector(self:GetOrigin())
    startPoint.y = startPoint.y + self:GetExtents().y
    DebugBox(startPoint, startPoint, self:GetExtents(), .05, 1, 1, 0, 1)

end

-- Note: It doesn't look like this is being used anymore.
function Player:GetItem(mapName)

    for i = 0, self:GetNumChildren() - 1 do

        local currentChild = self:GetChildAtIndex(i)
        if currentChild:GetMapName() == mapName then
            return currentChild
        end

    end

    return nil

end

function Player:OverrideVisionRadius()
    return kPlayerLOSDistance
end

function Player:GetTraceCapsule()
    return GetTraceCapsuleFromExtents(self:GetExtents())
end

-- Required by ControllerMixin.
function Player:GetControllerSize()
    return GetTraceCapsuleFromExtents(self:GetExtents())
end

function Player:GetControllerPhysicsGroup()
    return PhysicsGroup.PlayerControllersGroup
end

-- Required by ControllerMixin.
function Player:GetMovePhysicsMask()
    return PhysicsMask.Movement
end

--[[
    Moves the player downwards (by at most a meter).
]]
function Player:DropToFloor()

    PROFILE("Player:DropToFloor")

    if self.controller then
        self:UpdateControllerFromEntity()
        self.controller:Move( Vector(0, -1, 0), CollisionRep.Move, CollisionRep.Move, self:GetMovePhysicsMask())
        self:UpdateOriginFromController()
    end

end

function Player:GetCanStepOver(entity)
    return not entity:isa("Player")
end

function Player:GetCrouchShrinkAmount()
    return kCrouchShrinkAmount
end

function Player:GetExtentsCrouchShrinkAmount()
    return kExtentsCrouchShrinkAmount
end

-- Recalculate self.onGround next time
function Player:SetOrigin(origin)

    Entity.SetOrigin(self, origin)

    self.fullPrecisionOrigin = Vector(origin)

    self:UpdateControllerFromEntity()

end

function Player:GetPlayFootsteps()
    if not Client then
        return false
    end
    return self:GetIsOnGround() and self:GetIsAlive() and self:GetVelocityLength() > .75 and
            not (HasMixin(self, "CrouchMove") and self:GetCrouching()) and
            not (HasMixin(self, "Webable") and self:GetIsWebbed())

end

-- Called by client/server UpdateMisc()
function Player:UpdateSharedMisc(input)

    self:UpdateMode()

end

-- Subclasses can override this.
-- In particular, the Skulk must override this since its view angles do NOT correspond to its head angles.
function Player:GetHeadAngles()
    return self:GetViewAngles()
end

function Player:OnUpdatePoseParameters()

    PROFILE("Player:OnUpdatePoseParameters")

    if not Shared.GetIsRunningPrediction() then

        local viewModel = self:GetViewModelEntity()
        if viewModel ~= nil then

            local activeWeapon = self:GetActiveWeapon()
            if activeWeapon and activeWeapon.UpdateViewModelPoseParameters then
                activeWeapon:UpdateViewModelPoseParameters(viewModel)
            end

        end

        SetPlayerPoseParameters(self, viewModel, self:GetHeadAngles())

    end

end

-- By default the movement speed will not factor in the vertical velocity.
function Player:GetMoveSpeedIs2D()
    return true
end

function Player:UpdateMode()

    if(self.mode ~= kPlayerMode.Default and self.modeTime ~= -1 and Shared.GetTime() > self.modeTime) then

        if(not self:ProcessEndMode()) then

            self.mode = kPlayerMode.Default
            self.modeTime = -1

        end

    end

end

function Player:ProcessEndMode()

    if(self.mode == kPlayerMode.Knockback) then

        -- No anim yet, set modetime manually
        self.modeTime = 1.25
        return true

    end

    return false
end

function Player:GetMaxSpeed(possible)
    return Player.kWalkMaxSpeed
end

function Player:GetAcceleration()
    return 13 * self:GetSlowSpeedModifier()
end

function Player:GetAirControl()
    return 11 * self:GetSlowSpeedModifier()
end

function Player:GetAirAcceleration()
    return 6 * self:GetSlowSpeedModifier()
end

-- Maximum speed a player can move backwards
function Player:GetMaxBackwardSpeedScalar()
    return Player.kWalkBackwardSpeedScalar
end

-- for marquee selection
function Player:GetIsMoveable()
    return true
end

function Player:GetIsIdle()
    return self:GetVelocityLength() < 0.1 and not self.moveButtonPressed
end

function Player:GetPlayIdleSound()
    return self:GetIsAlive() and (self:GetVelocityLength() / self:GetMaxSpeed(true)) > 0.65
end

local function CheckSpaceAboveForJump(self)

    local startPoint = self:GetOrigin() + Vector(0, self:GetExtents().y, 0)
    local endPoint = startPoint + Vector(0, 0.5, 0)
    local trace = Shared.TraceCapsule(startPoint, endPoint, 0.1, self:GetExtents().y, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(self))

    return trace.fraction == 1

end

function Player:GetCanJump()
    return self:GetIsOnGround()
end

function Player:GetJumpHeight()
    return Player.kJumpHeight
end

-- 0-1 scalar which goes away over time (takes 1 seconds to get expire of a scalar of 1)
-- Never more than 1 second of recovery time
-- Also reduce velocity by this amount
function Player:AddSlowScalar(scalar)
    self.slowAmount = Clamp(self.slowAmount + scalar, 0, 1)
end

function Player:GetMaterialBelowPlayer()

    local surfaceIndex = self:GetOnGroundSurface()
    local material = surfaceIndex and EnumToString(kSurfaces, surfaceIndex) or "metal"

    -- Have squishy footsteps on infestation
    if self:GetGameEffectMask(kGameEffect.OnInfestation) then
        material = "organic"
    end

    return material

end

function Player:GetFootstepSpeedScalar()
    return Clamp(self:GetVelocityLength() / self:GetMaxSpeed(), 0, 1)
end

function Player:HandleAttacks(input)

    PROFILE("Player:HandleAttacks")

    if not self:GetCanAttack() then
        input.commands = bit.band(input.commands, bit.bnot(bit.bor(Move.PrimaryAttack, Move.SecondaryAttack, Move.TertiaryAttack)))
    end

    self:WeaponUpdate()


    if (bit.band(input.commands, Move.PrimaryAttack) ~= 0) then

        self:PrimaryAttack()

    else

        if self.primaryAttackLastFrame then

            self:PrimaryAttackEnd()

        end

    end

    if (bit.band(input.commands, Move.SecondaryAttack) ~= 0) then

        self:SecondaryAttack()

    else

        if(self.secondaryAttackLastFrame ~= nil and self.secondaryAttackLastFrame) then

            self:SecondaryAttackEnd()

        end

    end

    if (bit.band(input.commands, Move.TertiaryAttack) ~= 0) then

        self:TertiaryAttack()

    else

        if(self.tertiaryAttackLastFrame ~= nil and self.tertiaryAttackLastFrame) then

            self:TertiaryAttackEnd()

        end

    end

    -- Remember if we attacked so we don't call AttackEnd() until mouse button is released
    self.primaryAttackLastFrame = (bit.band(input.commands, Move.PrimaryAttack) ~= 0)
    self.secondaryAttackLastFrame = (bit.band(input.commands, Move.SecondaryAttack) ~= 0)
    self.tertiaryAttackLastFrame = (bit.band(input.commands, Move.TertiaryAttack) ~= 0)

end

function Player:HandleDoubleTap(input)

    PROFILE("Player:HandleDoubleTap")

    -- check which button has been released and store that one
    if not self.previousMove then
        self.previousMove = Vector(input.move)
        self.lastButtonReleased = TAP_NONE
        self.timeLastButtonReleased = 0
        return
    end

    local buttonReleased = TAP_NONE

    if input.move.x == 0 then
        if self.previousMove.x > 0 then
            buttonReleased = TAP_LEFT
        elseif self.previousMove.x < 0 then
            buttonReleased = TAP_RIGHT
        end
    end

    if input.move.z == 0 then
        if self.previousMove.z < 0 then
            buttonReleased = TAP_BACKWARD
        elseif self.previousMove.z > 0 then
            buttonReleased = TAP_FORWARD
        end
    end

    if buttonReleased ~= TAP_NONE then

        if self.timeLastButtonReleased ~= 0 and self.timeLastButtonReleased + kTapInterval > Shared.GetTime() then

            if self.lastButtonReleased == buttonReleased then

                self.timeLastButtonReleased = 0
                self.lastButtonReleased = TAP_NONE
                self:OnDoubleTap(GetTabDirectionVector(buttonReleased) )

            else

                self.lastButtonReleased = buttonReleased
                self.timeLastButtonReleased = Shared.GetTime()

            end

        else
            self.lastButtonReleased = buttonReleased
            self.timeLastButtonReleased = Shared.GetTime()
        end

    end

    self.previousMove = Vector(input.move)

end

-- Pass view model direction
function Player:OnDoubleTap(direction)
end

function Player:GetPrimaryAttackLastFrame()
    return self.primaryAttackLastFrame
end

function Player:GetSecondaryAttackLastFrame()
    return self.secondaryAttackLastFrame
end

function Player:GetIsAbleToUse()
    return self:GetIsAlive()
end

function Player:HandleButtons(input)

    PROFILE("Player:HandleButtons")

    if not self:GetCanControl() then

        -- The following inputs are disabled when the player cannot control themself.
        input.commands = bit.band(input.commands, bit.bnot(bit.bor(Move.Use, Move.Buy, Move.Jump,
                Move.PrimaryAttack, Move.SecondaryAttack,
                Move.SelectNextWeapon, Move.SelectPrevWeapon, Move.Reload,
                Move.Taunt, Move.Weapon1, Move.Weapon2,
                Move.Weapon3, Move.Weapon4, Move.Weapon5,
                Move.Crouch, Move.Drop, Move.MovementModifier,
                Move.TertiaryAttack, Move.QuickSwitch)))

        input.move.x = 0
        input.move.y = 0
        input.move.z = 0

        self:HandleAttacks(input) -- so that attacks will properly end.

        return

    end

    if self.HandleButtonsMixin then
        self:HandleButtonsMixin(input)
    end

    self.moveButtonPressed = input.move:GetLength() ~= 0

    local ableToUse = self:GetIsAbleToUse()
    local usePressed = ableToUse and bit.band(input.commands, Move.Use) ~= 0
    local attackLastFrame = self.primaryAttackLastFrame or self.secondaryAttackLastFrame or self.tertiaryAttackLastFrame
    local alienSecondaryAttacking = self:isa("Alien") and self.secondaryAttackLastFrame

    -- The only use case so far for the 'use' key to be pressed while using primary/secondary attack is
    -- as a gorge when you heal yourself and want to press 'use' to hatch a babblerEgg, or an alien entering the hive.
    -- Otherwise this is disable to prevent issues when opening any buy menu as a marine and the weapon keep firing/reloading
    -- unless you leave the menu. Which can cause issues if you got a GL. The marine player can just release the key and press use.
    if usePressed then

        local isUsing = false
        if (not attackLastFrame or alienSecondaryAttacking) then
            isUsing = AttemptToUse(self, input.time)
        end
        
        if Server and not isUsing and self:GetCanShootSeasonalObject() then
            FireSeasonalProjectile(self)
        end
        
    end

    if Client and not Shared.GetIsRunningPrediction() then

        self.buyLastFrame = self.buyLastFrame or false
        -- Player is bringing up the buy menu (don't toggle it too quickly)
        local buyButtonPressed = bit.band(input.commands, Move.Buy) ~= 0
        if not self.buyLastFrame and buyButtonPressed and Shared.GetTime() > (self.timeLastMenu + 0.3) then

            self:Buy()
            self.timeLastMenu = Shared.GetTime()

        end

        self.buyLastFrame = buyButtonPressed

    end

    self:HandleAttacks(input)

    -- self:HandleDoubleTap(input)

    if bit.band(input.commands, Move.Reload) ~= 0 then
        self:Reload()
    end

    -- Weapon switch
    if not self:GetIsCommander() and not self:GetIsUsing() then

        if bit.band(input.commands, Move.SelectNextWeapon) ~= 0 then
            self:SelectNextWeapon()
        end

        if bit.band(input.commands, Move.SelectPrevWeapon) ~= 0 then
            self:SelectPrevWeapon()
        end

        if bit.band(input.commands, Move.Weapon1) ~= 0 then
            self:SwitchWeapon(1)
        end

        if bit.band(input.commands, Move.Weapon2) ~= 0 then
            self:SwitchWeapon(2)
        end

        if bit.band(input.commands, Move.Weapon3) ~= 0 then
            self:SwitchWeapon(3)
        end

        if bit.band(input.commands, Move.Weapon4) ~= 0 then
            self:SwitchWeapon(4)
        end

        if bit.band(input.commands, Move.Weapon5) ~= 0 then
            self:SwitchWeapon(5)
        end

        if bit.band(input.commands, Move.QuickSwitch) ~= 0 then
            self:QuickSwitchWeapon()
        end

    end

end

-- Seasonal throwable check
function Player:GetCanShootSeasonalObject()

    if not IsSeasonForThrowing() then
        return false
    end

    -- Don't throw object if already using something or if in commander view
    if self:GetIsUsing() or self:GetIsCommander() then
        return false
    end

    local now = Shared.GetTime()
    if now - self.timeLastSeasonThrow < kSeasonalThrowInterval then
        return false
    end

    -- Only allow in RR and pre-game (not post-game.)
    if self:GetTeamNumber() ~= kTeamReadyRoom then
        local entityList = Shared.GetEntitiesWithClassname("GameInfo")
        if entityList:GetSize() == 0 then
            return false
        end

        local gameInfo = entityList:GetEntityAtIndex(0)
        local state = gameInfo:GetState()
        
        if state >= kGameState.PreGame then
            return false
        end
    end

    -- Don't let object throwing get in the way of actually using stuff
    local ent = self:PerformUseTrace()
    local entIsUsable = ent and ( self:GetGameStarted() or ent.GetUseAllowedBeforeGameStart and ent:GetUseAllowedBeforeGameStart() )
    if entIsUsable and GetPlayerCanUseEntity(self, ent) then
        return false
    end
    
    self.timeLastSeasonThrow = now

    return true
end

function Player:OnWeldOverride(doer, elapsedTime, weldPerSecOverride)

    -- macs weld marines by only 50% of the rate
    local weldMod = ( doer ~= nil and doer:isa("MAC") ) and 0.5 or 1


    --balance mod
    local catpackBonus = 1
    if doer ~= nil and doer:GetParent() ~= nil and doer:GetParent():isa("Marine") and doer:GetParent():GetHasCatPackBoost() then 
        catpackBonus = 1.125
    end

    if self:GetArmor() < self:GetMaxArmor() then

        local addArmor = (weldPerSecOverride or kPlayerArmorWeldRate) * elapsedTime * weldMod * catpackBonus
        self:SetArmor(self:GetArmor() + addArmor)

        if self.OnArmorWelded then
            self:OnArmorWelded(doer)
        end

    end

end

function Player:GetCanCrouch()
    return true
end

function Player:GetNotEnoughResourcesSound()
    return kNotEnoughResourcesSound
end

function Player:GetIsCommander()
    return false
end

function Player:GetIsOverhead()
    return false
end

--[[
    Returns the view model entity.
]]
function Player:GetViewModelEntity()

    local result
    -- viewModelId is a private field
    if not Client or self:GetIsLocalPlayer() then

        result = Shared.GetEntity(self.viewModelId)
        ASSERT(not result or result:isa("ViewModel"), "%s: viewmodel is a %s!", self, result)

    end

    return result

end

--[[
    Sets the model currently displayed on the view model.
]]
function Player:SetViewModel(viewModelName, weapon)

    local viewModel = self:GetViewModelEntity()

    -- Currently there is an edge case where this function is called when
    -- there is no view model entity. This will help us figure out why.
    if not viewModel then
        return
    end

    local animationGraphFileName = weapon and weapon:GetAnimationGraphName()
    viewModel:SetModel(viewModelName, animationGraphFileName)
    viewModel:SetWeapon(weapon)

end

function Player:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false
end

function Player:GetScoreboardChanged()
    return self.scoreboardChanged
end

function Player:SpaceClearForEntity(position, printResults)

    local capsuleHeight, capsuleRadius = self:GetTraceCapsule()
    local center = Vector(0, capsuleHeight * 0.5 + capsuleRadius, 0)

    local traceStart = position + center
    local traceEnd = traceStart + Vector(0, .1, 0)

    if capsuleRadius == 0 and printResults then
        Print("%s:SpaceClearForEntity(): capsule radius is 0, returning true.", self:GetClassName())
        return true
    elseif capsuleRadius < 0 and printResults then
        Print("%s:SpaceClearForEntity(): capsule radius is %.2f.", self:GetClassName(), capsuleRadius)
    end

    local trace = Shared.TraceCapsule(traceStart, traceEnd, capsuleRadius, capsuleHeight, CollisionRep.Move, PhysicsMask.AllButPCs, EntityFilterOne(self))

    if trace.fraction ~= 1 and printResults then
        Print("%s:SpaceClearForEntity: Hit %s", self:GetClassName(), SafeClassName(trace.entity))
    end

    return (trace.fraction == 1)

end

function Player:GetChatSound()
    return kChatSound
end

function Player:GetHotkeyGroups()

    local hotKeyGroups = {}

    for _, entity in ipairs(GetEntitiesWithMixinForTeam("Selectable", self:GetTeamNumber())) do

        local group = entity:GetHotGroupNumber()
        if group ~= 0 then

            if not hotKeyGroups[group] then
                hotKeyGroups[group] = {}
            end

            table.insert(hotKeyGroups[group], entity)

        end

    end

    return hotKeyGroups

end

function Player:GetVisibleWaypoint()

    local currentOrder = self:GetCurrentOrder()
    if currentOrder then

        local location = currentOrder:GetLocation()

        if currentOrder:GetType() == kTechId.Weld or currentOrder:GetType() == kTechId.Heal then

            local orderTargetId = currentOrder:GetParam()
            if orderTargetId ~= Entity.invalidId then
                local orderTarget = Shared.GetEntity(orderTargetId)
                if orderTarget then
                    location =  orderTarget:GetOrigin()
                end
            end

        end

        return location
    end

    return nil

end

-- Overwrite to get player status description
function Player:GetPlayerStatusDesc()
    if (self:GetIsAlive() == false) then
        return kPlayerStatus.Dead
    end
    return kPlayerStatus.Void
end

function Player:GetCanGiveDamageOverride()
    return true
end

-- Overwrite how players interact with doors
function Player:OnOverrideDoorInteraction(inEntity)
    if self:GetVelocityLength() > 8 then
        return true, 10
    else
        return true, 6
    end
end

function Player:SetIsUsing (isUsing)
    self.isUsing = isUsing
end

function Player:GetIsUsing ()
    return self.isUsing
end

function Player:GetDarwinMode()
    return self.darwinMode
end

function Player:OnSighted(sighted)
end

function Player:GetGameStarted()
    local gameInfoEnt = GetGameInfoEntity()
    if not gameInfoEnt then
        return false
    end

    if GetWarmupActive() and not self:isa("Commander") then
        return true
    end

    return gameInfoEnt:GetGameStarted()
end

function Player:GetCountdownActive()
    local gameInfoEnt = GetGameInfoEntity()
    if not gameInfoEnt then
        return false
    end

    return self:GetIsOnPlayingTeam() and gameInfoEnt:GetCountdownActive()
end

function Player:Drop(weapon, ignoreDropTimeLimit)
    return false
end

-- childs should override this
function Player:GetArmorAmount()
    return self:GetMaxArmor()
end

if Client then

    function Player:TriggerFootstep()

        self.leftFoot = not self.leftFoot
        local sprinting = HasMixin(self, "Sprint") and self:GetIsSprinting()
        local viewVec = self:GetViewAngles():GetCoords().zAxis
        local forward = self:GetVelocity():DotProduct(viewVec) > -0.1
        local crouch = HasMixin(self, "CrouchMove") and self:GetCrouching()
        local localPlayer = Client.GetLocalPlayer()
        local enemy = localPlayer and GetAreEnemies(self, localPlayer)
        self:TriggerEffects("footstep", {surface = self:GetMaterialBelowPlayer(), left = self.leftFoot, sprinting = sprinting, forward = forward, crouch = crouch, enemy = enemy})
    end

end

local kStepTagNames = { }
kStepTagNames["step"] = true
kStepTagNames["step_run"] = true
kStepTagNames["step_sprint"] = true
kStepTagNames["step_crouch"] = true
function Player:OnTag(tagName)

    PROFILE("Player:OnTag")
    local crouching = HasMixin(self, "CrouchMove") and self:GetCrouching()

    -- Log("%s: tag %s (%s)", self, tagName, kStepTagNames[tagName])

    -- Filter out crouch steps from playing at inappropriate times.
    if tagName == "step_crouch" and not crouching then
        return
    end

    -- Play footstep when foot hits the ground. Client side only. And only if we
    --- are close enough to the local player...
    if Client and kStepTagNames[tagName] and self:GetPlayFootsteps() then
        self:TriggerFootstep()
    end

end

function Player:OnUpdateAnimationInput(modelMixin)

    PROFILE("Player:OnUpdateAnimationInput")

    local moveState = "idle"
    if not self:GetIsIdle() then
        moveState = "run"
    end
    modelMixin:SetAnimationInput("move", moveState)

    local activeWeapon = "none"
    local weapon = self:GetActiveWeapon()
    if weapon ~= nil then

        if weapon.OverrideWeaponName then
            activeWeapon = weapon:OverrideWeaponName()
        elseif weapon.GetMapName then
            activeWeapon = weapon:GetMapName()
        end

    end

    modelMixin:SetAnimationInput("weapon", activeWeapon)

    local weapon = self:GetActiveWeapon()  -- animation may have changed active weapon
    if weapon ~= nil and weapon.OnUpdateAnimationInput then
        weapon:OnUpdateAnimationInput(modelMixin)
    end

end

function Player:GetSpeedScalar()
    return self:GetVelocity():GetLength() / self:GetMaxSpeed(true)
end

function Player:OnUpdateCamera(deltaTime)
end

function Player:BlockMove()
    self.isMoveBlocked = true
end

function Player:RetrieveMove()
    self.isMoveBlocked = false
end

function Player:GetCanControl()
    return not self.isMoveBlocked and self:GetIsAlive() and ( not HasMixin(self, "Stun") or not self:GetIsStunned() ) and not self:GetCountdownActive() and not ConcedeSequence.GetIsPlayerObserving(self)
end

function Player:GetCanAttack()
    return not self:GetIsUsing() and not ConcedeSequence.GetIsPlayerObserving(self)
end

function Player:TriggerInvalidSound()

    if not self.timeLastInvalidSound or self.timeLastInvalidSound + 1 < Shared.GetTime() then
        StartSoundEffectForPlayer(kInvalidSound, self)
        self.timeLastInvalidSound = Shared.GetTime()
    end

end

function Player:GetIsWallWalkingAllowed(entity)
    return false
end

function Player:GetEngagementPointOverride()
    return self:GetModelOrigin()
end

function Player:OnInitialSpawn(techPointOrigin)

    local viewCoords = Coords.GetLookIn(self:GetEyePos(), GetNormalizedVectorXZ(techPointOrigin - self:GetEyePos()))
    local angles = Angles()
    angles:BuildFromCoords(viewCoords)
    self:SetViewAngles(angles)

    angles.pitch = 0.0
    self:SetAngles(angles)

end

function Player:OnJoinTeam()

    self.sendTechTreeBase = true

end

-- This causes problems when doing a trace ray against CollisionRep.Move.
function Player:OnCreateCollisionModel()

    -- Remove any "move" collision representation from the player's model, since
    -- all of the movement collision will be handled by the controller.
    local collisionModel = self:GetCollisionModel()
    collisionModel:RemoveCollisionRep(CollisionRep.Move)

end


function Player:GetWeaponUpgradeLevel()

    if not self.weaponUpgradeLevel then
        return 0
    end

    return self.weaponUpgradeLevel

end

function Player:GetIsRookie()
    return self.isRookie
end

function Player:ModifyMaxSpeed(maxSpeedTable)

    for i = 0, self:GetNumChildren() - 1 do

        local child = self:GetChildAtIndex(i)
        if child.ModifyMaxSpeed then
            child:ModifyMaxSpeed(maxSpeedTable)
        end

    end

end

function Player:TriggerBeaconEffects()

    self.timeLastBeacon = Shared.GetTime()
    self:TriggerEffects("distress_beacon_spawn")

end

function Player:GetCommunicationStatus()
    return self.communicationStatus
end

function Player:SetCommunicationStatus(status)
    self.communicationStatus = status
end

if Server then

    function Player:SetWaitingForTeamBalance(waiting)

        self.waitingForAutoTeamBalance = waiting
        -- Send a message as a FP spectating player will need to be notified.
        Server.SendNetworkMessage(Server.GetOwner(self), "WaitingForAutoTeamBalance", { waiting = waiting }, true)

    end

    function Player:GetIsWaitingForTeamBalance()
        return self.waitingForAutoTeamBalance
    end

end

function Player:GetPositionForMinimap()

    local tunnels = GetEntitiesWithinRange("Tunnel", self:GetOrigin(), 30)
    local isInTunnel = #tunnels > 0

    if isInTunnel then
        return tunnels[1]:GetRelativePosition(self:GetOrigin())
    else
        return self:GetOrigin()
    end

end

function Player:GetDirectionForMinimap()

    local zAxis = self:GetViewAngles():GetCoords().zAxis
    local direction = math.atan2(zAxis.x, zAxis.z)

    local tunnels = GetEntitiesWithinRange("Tunnel", self:GetOrigin(), 30)
    local isInTunnel = #tunnels > 0

    if isInTunnel then
        direction = direction + tunnels[1]:GetMinimapYawOffset()
    end

    return direction

end

local function DelayedSuicide(self)

    if HasMixin(self, "Live") and self:GetCanDie() then
        self:Kill(nil, nil, self:GetOrigin())
    end

    return false

end

function Player:TriggerSuicide()

    if HasMixin(self, "Live") and self:GetCanDie() and not self.suiciding then
        self:AddTimedCallback(DelayedSuicide, kSuicideDelay)
    end

end

function Player:UpdateArmorAmount(armorLevel)

    -- note: some player may have maxArmor == 0
    local armorPercent = self.maxArmor > 0 and self.armor/self.maxArmor or 0
    local newMaxArmor = self:GetArmorAmount(armorLevel)

    if newMaxArmor ~= self.maxArmor then

        self.maxArmor = newMaxArmor
        self:SetArmor(self.maxArmor * armorPercent, true)

    end

end


Shared.LinkClassToMap("Player", Player.kMapName, networkVars, true)
