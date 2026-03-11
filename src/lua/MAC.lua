-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\MAC.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- AI controllable flying robot marine commander can control. Used to build structures
-- and has other special abilities.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

--[[

Katz notes:
* Rework hold to be a toggled "short leash" mod
* Due to order limitations, it is possible to assign multiple macs on a target if using chaining orders (edge case)
* Very minor limitation: Chaining x2+ orders after a follow will only take the last order, and discard intermediate between follow and tail order.
*   --> If x2+ chained order are given after the follow, the mac will go straight to last point.
*   --> This is due to orders limitation with looping orders (current behavior I did still allows to chain one order, which is better than none)

Test routine:
* Give all orders once (move / construct+weld (powernode (unprimed + dead) + blueprint) / weld players)
*  -> MAc should ONLY be doing that unless there is a "use" request on the field
*  -> The "use" request should not put the mac beyond its leash (short or long)
* Sidequests (put mac near low RT, it will weld RT, but will prioritise nearby players first if any)
* Chained order (same kind or diff)
* Chained order with a looping type order (test both follow and patrol)
* Patrol mac should check for side quests on each of its patrol points (depending on leash (short or long))
* Hold action should trigger a "hold" automatic order as a tail order (visual QoL)
* Test upgrading a unit the MAC has an order on (obs -> adv obs, armory -> adv armory, unmaned exo -> player enters exo (or leave))
* Check multiple macs cannot weld same target or themselves
* Check that MACs when following/welding keep a distance from target (not inside it)

Next work TBD:
* Players using the "weld me" voice request could trigger a mac order.
* Optimization if needed (call frequencies and moving calls lower into, so it's not called each time each)

New/fixed stuff:
* Patrol
* Chained orders now works (of diff kind), can even queue a fallback pos after a follow order if target dies
* Players can press "Use" on a mac to hijack it and ask for an immediate weld (it will resume current order once done)
    --> Good when mac is busy building an RT or welding side stuff
* Hold is a toggle for short/long leash (will show a QoL hold visual)
* Macs will go directely to follow target (not on target pos, and THEN follow (two step))

--]]

Script.Load("lua/CommAbilities/Marine/EMPBlast.lua")

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/DoorMixin.lua")
Script.Load("lua/BuildingMixin.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/UpgradableMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/AchievementGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/MobileTargetMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/RepositioningMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/SleeperMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CorrodeMixin.lua")
Script.Load("lua/SupplyUserMixin.lua")
Script.Load("lua/SoftTargetMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/WebableMixin.lua")
Script.Load("lua/ParasiteMixin.lua")
Script.Load("lua/BlightMixin.lua")
Script.Load("lua/BlowtorchTargetMixin.lua")
Script.Load("lua/RolloutMixin.lua")
Script.Load("lua/MACVariantMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")
Script.Load("lua/CargoGateUserMixin.lua")

class 'MAC' (ScriptActor)

MAC.kMapName = "mac"

MAC.kModelName = PrecacheAsset("models/marine/mac/mac.model")
local kAnimationGraph = PrecacheAsset("models/marine/mac/mac.animation_graph")

local kConfirmSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/confirm")
local kConfirm2DSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/confirm_2d")
local kStartConstructionSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/constructing")
local kStartConstruction2DSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/constructing_2d")
local kStartWeldSound = PrecacheAsset("sound/NS2.fev/marine/structures/mac/weld_start")
local kHelpingSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/help_build")
local kPassbyMACSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/passby_mac")
local kPassbyDrifterSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/passby_driffter")

local kUsedSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/mac/use")

local kJetsCinematic = PrecacheAsset("cinematics/marine/mac/jet.cinematic")
local kJetsSound = PrecacheAsset("sound/NS2.fev/marine/structures/mac/thrusters")

local kRightJetNode = "fxnode_jet1"
local kLeftJetNode = "fxnode_jet2"
MAC.kLightNode = "fxnode_light"
MAC.kWelderNode = "fxnode_welder"

-------------------
-- Main balance ---

MAC.kHealth = kMACHealth
MAC.kArmor = kMACArmor

MAC.kConstructRate = 0.4
MAC.kWeldRate = 0.5
MAC.kMoveSpeed = 7
MAC.kSpeedUpgradePercent = (1 + kMACSpeedAmount)
MAC.CanMultipleWeldPlayers = false
MAC.CanMultipleWeldPvE = true

MAC.kRolloutSpeed = 5 -- how fast the MAC rolls out of the ARC factory. Standard speed is just too fast.
MAC.kTurnSpeed = 3 * math.pi -- a mac is nimble

MAC.kRepairHealthPerSecond = 30 -- (used by WeldableMixin, when welding hp of arcs for instance)

----------------------
-- Leash and ranges --

 -- Range at which the MAC is looking for entities to interact with (limited by leash range if shorter)
MAC.kSearchRangeLongLeash = 10.0  --12.0
MAC.kSearchRangeShortLeash = 3.0 -- 2.5

-- Distances at which the MAC can operate from its anchor point (needs to be longer than kSearchRange(long/short)Leash)
MAC.kDefaultLeashRadius = 14.0 -- Direct distance check for leash
MAC.kDefaultLeashPathLength = 20.0 -- Secondary pathing mesh check (so we do travel half the map for an entity behind a wall)

-- Distances at which the MAC has to be from it's followed target
MAC.kFollowLeashDistance = 4.0
MAC.kFollowLeashWorkingDistance = 6.0

-- Weld and build distances
MAC.kWeldDistance = 2
MAC.kBuildDistance = 2     -- Distance at which bot can start building a structure.

------------------------
-- Extents and sizes ---

MAC.kCapsuleHeight = 0.2
MAC.kCapsuleRadius = 0.5
MAC.kModelScale = 0.75

-------------
-- Others ---

-- MAC.kStartDistance = 3 -- Unused
MAC.kHoverHeight = 0.5

-- how often we check to see if we are in a marines face when welding
-- Note: Need to be fairly long to allow it to weld marines with backs towards walls - the AI will
-- stop moving after a < 1 sec long interval, and the welding will be done in the time before it tries
-- to move behind their backs again
MAC.kWeldPositionCheckInterval = 1 

----------------
-- Greetings ---

MAC.kGreetingUpdateInterval = 1
MAC.kGreetingInterval = 10
MAC.kGreetingDistance = 5
MAC.kUseTime = 2.0
MAC.kMaxUseableRange = 3.0
 
----------------
----------------

local networkVars =
{
    welding = "boolean",
    constructing = "boolean",
    moving = "boolean",
    shortLeash = "boolean",
    orderScanRadius = "float (0 to 31 by 0.01)",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(UpgradableMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(CorrodeMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(WebableMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)
AddMixinNetworkVars(BlightMixin, networkVars)
AddMixinNetworkVars(MACVariantMixin, networkVars)
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)
AddMixinNetworkVars(CargoGateUserMixin, networkVars)

--------------

function MAC:GetLeashLenght()
    return self.leashLenght
end

function MAC:SetLongLeash()
    self.shortLeash = false
    self.leashLenght = MAC.kDefaultLeashRadius
end
function MAC:SetShortLeash()
    self.shortLeash = true
    self.leashLenght = MAC.kSearchRangeShortLeash
end
function MAC:IsUsingShortLeash()
    return self.shortLeash --self:GetLeashLenght() == MAC.kSearchRangeShortLeash
end

function MAC:SetLeashPos(newPosition)
    --Log("MAC -- New leash point set")
    self.leashedPosition = newPosition or self:GetOrigin() -- nil pos resets leash to current pos
    --CreateEntity(EMPBlast.kMapName, self.leashedPosition, self:GetTeamNumber()) -- For direct visual on where/when the leash is set
end

function MAC:GetLeashPos()
    return self.leashedPosition -- Weld everything around the static leashPos, not himself
end

function MAC:IsBeyondLeash()
    return (self:GetOrigin() - self:GetLeashPos()):GetLength() > self:GetLeashLenght()
end

function MAC:GetOrderScanRadius() -- Automatically accounts for leash restrictions
    local range = self:GetLeashLenght() or 0

    --local currentOrder = self:GetCurrentOrder()
    --if currentOrder and currentOrder:GetType() == kTechId.FollowAndWeld then
    --    range = MAC.kFollowLeashWorkingDistance
    --end

    range = math.min(range, MAC.kSearchRangeLongLeash) -- Limit the max range (optimization)
    range = math.max(range, MAC.kSearchRangeShortLeash) -- At least this distance, or the MAC will not do anything
    return range
end
function MAC:UpdateOrderScanRadius()
    self.orderScanRadius = self:GetOrderScanRadius()
end

function MAC:GetHasWeldingOrder()
    local hasWeldingOrder = false
    local currentOrder = mac:GetCurrentOrder()

    if (currentOrder) then
        hasWeldingOrder = (isWeldingOrder or currentOrder:GetType() == kTechId.FollowAndWeld)
        hasWeldingOrder = (isWeldingOrder or currentOrder:GetType() == kTechId.Weld)
        hasWeldingOrder = (isWeldingOrder or currentOrder:GetType() == kTechId.AutoWeld)
    end
    return hasWeldingOrder
end


-- Rval: (isWeldedByOther, isItDirectOrder)
function MAC:GetIsWeldedByOtherMAC(target)

    if target then
        local targetId = target:GetId()
        for _, mac in ipairs(GetEntitiesForTeam("MAC", self:GetTeamNumber())) do
            if self ~= mac then
                local macOrder = mac:GetCurrentOrder()
                local macTarget = (macOrder and macOrder:GetParam() ~= nil) and Shared.GetEntity(macOrder:GetParam()) or nil
                
                if macTarget == target then
                    return true, true -- Target has already mac with a direct order on it
                end

                if mac.targetId == targetId then
                    return true, false -- Target is already welded by a side quest mac
                end
            end
        end
    end
    return false, false
end

--------------

function MAC:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin, { kTriggeringEnabledDefault = true })
    InitMixin(self, ClientModelMixin)
    InitMixin(self, DoorMixin)
    InitMixin(self, BuildingMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, UpgradableMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin, { kPlayFlinchAnimations = true })
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, AchievementGiverMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, PathingMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, SoftTargetMixin)
    InitMixin(self, WebableMixin)
    InitMixin(self, ParasiteMixin)
	InitMixin(self, BlightMixin)
    InitMixin(self, RolloutMixin)
	InitMixin(self, ResearchMixin)
	InitMixin(self, RecycleMixin)
    InitMixin(self, CargoGateUserMixin)
    
    self.timeOfLastFindNothingToDo = 0    
    if Server then
        InitMixin(self, RepositioningMixin)
        self:SetLongLeash()
        self:UpdateOrderScanRadius()
    elseif Client then
        InitMixin(self, CommanderGlowMixin)
		InitMixin(self, BlowtorchTargetMixin)
        self.orderScanRadiusClient = self:GetOrderScanRadius()
    end
    
    self:SetUpdates(true, kRealTimeUpdateRate)
    self:SetLagCompensated(true)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.SmallStructuresGroup)
    
end

function MAC:OnInitialized()
    
    ScriptActor.OnInitialized(self)

    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)

    if Server then
    
        self:UpdateIncludeRelevancyMask()
        
        InitMixin(self, SleeperMixin)
        InitMixin(self, MobileTargetMixin)
        InitMixin(self, SupplyUserMixin)
        InitMixin(self, InfestationTrackerMixin)
        
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        self.jetsSound = Server.CreateEntity(SoundEffect.kMapName)
        self.jetsSound:SetAsset(kJetsSound)
        self.jetsSound:SetParent(self)

        self:SetLeashPos(nil)
        self:SetLongLeash()
        --self.autoReturning = false
        --self.searchFollowTarget = false

    elseif Client then
    
        InitMixin(self, UnitStatusMixin)     
        InitMixin(self, HiveVisionMixin) 

        -- Setup movement effects
        self.jetsCinematics = {}
        for index,attachPoint in ipairs({ kLeftJetNode, kRightJetNode }) do
            self.jetsCinematics[index] = Client.CreateCinematic(RenderScene.Zone_Default)
            self.jetsCinematics[index]:SetCinematic(kJetsCinematic)
            self.jetsCinematics[index]:SetRepeatStyle(Cinematic.Repeat_Endless)
            self.jetsCinematics[index]:SetParent(self)
            self.jetsCinematics[index]:SetCoords(Coords.GetIdentity())
            self.jetsCinematics[index]:SetAttachPoint(self:GetAttachPointIndex(attachPoint))
            self.jetsCinematics[index]:SetIsActive(false)
        end

    end
    
    self.timeOfLastGreeting = 0
    self.timeOfLastGreetingCheck = 0
    self.timeOfLastChatterSound = 0
    self.timeOfLastWeld = 0
    self.timeOfLastConstruct = 0
    self.moving = false
    
    self:SetModel(MAC.kModelName, kAnimationGraph)
    
    InitMixin(self, IdleMixin)

    if not Predict then
        InitMixin(self, MACVariantMixin)
        self:ForceSkinUpdate()
    end
    
end

local function GetObstacleSize(target)
    local obstacleSize = 0.1
    if target and HasMixin(target, "Extents") then
        obstacleSize = target:GetExtents():GetLengthXZ()
    end
    return obstacleSize
end

function MAC:FindFollowAndWeldTarget()
    local newTarget = nil
    local weldables = GetEntitiesWithMixinForTeamWithinXZRange("Weldable", self:GetTeamNumber(), self:GetOrigin(), self:GetOrderScanRadius())
    Shared.SortEntitiesByDistance(self:GetOrigin(), weldables)
    for w = 1, #weldables do
    
        local weldable = weldables[w]
        -- Don't auto follow another MAC which I can't weld (need to exclude self in the future if that changes)
        -- Don't follow any costructable targets to prevent freezing, only follow mobile weldable targets
        if not HasMixin(weldable, "Construct") and weldable:GetIsAlive() and not weldable:isa("MAC") then 
            
            newTarget = weldable
            break

        end
        
    end
    
    return newTarget
end

function MAC:OnEntityChange(oldId, newId)

    local currentOrder = self:GetCurrentOrder()

    if currentOrder and currentOrder:GetType() == kTechId.FollowAndWeld then
        
        if oldId == currentOrder:GetParam() then
            --DebugPrint("MAC follow Target changed "..ToString(currentOrder:GetParam()))
            local newTarget = newId and Shared.GetEntity(newId)
            
            -- continue follow the new entity which we were following
            if newTarget and HasMixin(newTarget, "Weldable") then
                -- Only case where we self-issue an order (ex: moving in/out of exo, buying JPs)
                self:GiveOrder(kTechId.FollowAndWeld, newId, newTarget:GetOrigin(), nil, false, false)
                --DebugPrint("MAC following new target")
            end
        end
    end
    
end

function MAC:GetTurnSpeedOverride()
    return MAC.kTurnSpeed
end

function MAC:GetCanSleep()
    return self:GetCurrentOrder() == nil
end

function MAC:GetMinimumAwakeTime()
    return 5
end

function MAC:GetExtentsOverride()
    return Vector(MAC.kCapsuleRadius, MAC.kCapsuleHeight / 2, MAC.kCapsuleRadius)
end

function MAC:GetFov()
    return self.moving and 120 or 360
end

function MAC:GetIsFlying()
    return true
end

function MAC:GetReceivesStructuralDamage()
    return true
end

function MAC:OnUse(player, elapsedTime, useSuccessTable)

    -- Play flavor sounds when using MAC.
    if Server then
    

        local time = Shared.GetTime()
        
        if self.timeOfLastUse == nil or (time > (self.timeOfLastUse + MAC.kUseTime)) then
            
            if player:isa("Marine") and player.variant and table.icontains( kRoboticMarineVariantIds, player.variant) then
            --MACs either don't like or don't recognize their larger kin...picky little buggers, aren't they.
                Server.PlayPrivateSound(player, kPassbyDrifterSoundName, self, 1.0, Vector(0, 0, 0))
            else
                Server.PlayPrivateSound(player, kUsedSoundName, self, 1.0, Vector(0, 0, 0))
            end

            -- Limitations: Looping orders like follow/patrol don't work well when they are interrupted
            -- So, we disable the "use" for those cases, the mac will weld nearby entities anyway when it is available
            -- Also, those forces macs to weld the commander targeted entity FIRST (other players or arcs), which is not a bad thing
            -- It is still possible to press "use" for when it is building or welding regular buildings
            -- (MAC will still make a sound to acknowledge the request though)
            if player:GetWeldPercentage() < 1 and not self:GetIsWeldedByOtherMAC(player) and not self:GetIsLoopingOrders() then
                self:GiveOrder(kTechId.AutoWeld, player:GetId(), player:GetOrigin(), nil, false, true)
                --self.secondaryOrderType = kTechId.AutoWeld
                --self.secondaryTargetId = player:GetId()
            end
            
            self.timeOfLastUse = time
            
            
        end
        
    end
    
end

-- avoid the MAC hovering inside (as that shows the MAC through the factory top)
function MAC:GetHoverHeight()
    if self.rolloutSourceFactory then
        -- keep it low until it leaves the factory, then go back to normal hover height
        local remainingDist = self.cursor and self.cursor:GetRemainingDistance() or 0
        local h = MAC.kHoverHeight * (1.1 - remainingDist) / 1.1
        return math.max(0, h)
    end
    return MAC.kHoverHeight
end

function MAC:OnOverrideOrder(order)

    local orderTarget
    if (order:GetParam() ~= nil) then
        orderTarget = Shared.GetEntity(order:GetParam())
    end
    
    local isSelfOrder = orderTarget == self

    -- Default orders to unbuilt friendly structures should be construct orders
    if order:GetType() == kTechId.Default and GetOrderTargetIsConstructTarget(order, self:GetTeamNumber()) then
    
        order:SetType(kTechId.Construct)

    elseif order:GetType() == kTechId.Default and orderTarget and orderTarget:isa("PowerPoint") and orderTarget:GetIsDisabled() then
    
        order:SetType(kTechId.Weld)
        
    elseif order:GetType() == kTechId.Default and GetOrderTargetIsWeldTarget(order, self:GetTeamNumber()) and not isSelfOrder --[[and not self:GetIsWeldedByOtherMAC(orderTarget)--]] then
    -- allow multiple MACs to follow the same target
        -- only moving targets need to be followed
        if HasMixin(orderTarget, "Orders") and not orderTarget:isa("CargoGate") then
            order:SetType(kTechId.FollowAndWeld)
        elseif orderTarget:GetWeldPercentage() < 1 and not self:GetIsWeldedByOtherMAC(orderTarget) then
            order:SetType(kTechId.Weld)
        else
            order:SetType(kTechId.Move)
        end
        
    elseif (order:GetType() == kTechId.Default or order:GetType() == kTechId.Move) then
        
        -- Convert default order (right-click) to move order
        order:SetType(kTechId.Move)

    end
    
    if GetAreEnemies(self, orderTarget) then
        order.orderParam = -1
    end
    
end

function MAC:GetIsOrderHelpingOtherMAC(order)

    if order:GetType() == kTechId.Construct then
    
        -- Look for friendly nearby MACs
        local macs = GetEntitiesForTeamWithinXZRange("MAC", self:GetTeamNumber(), self:GetOrigin(), 3)
        for index, mac in ipairs(macs) do
        
            if mac ~= self then
            
                local otherMacOrder = mac:GetCurrentOrder()
                if otherMacOrder ~= nil and otherMacOrder:GetType() == order:GetType() and otherMacOrder:GetParam() == order:GetParam() then
                    return true
                end
                
            end
            
        end
        
    end
    
    return false
    
end

function MAC:OnOrderChanged()

    local order = self:GetCurrentOrder()    
    
    if order then
            
        local owner = self:GetOwner()
        
        if not owner then
            local commanders = GetEntitiesForTeam("Commander", self:GetTeamNumber())
            if commanders and commanders[1] then
                owner = commanders[1]
            end    
        end
        
        local currentComm = commanders and commanders[1] or nil

        -- Look for nearby MAC doing the same thing
        if self:GetIsOrderHelpingOtherMAC(order) then
            self:PlayChatSound(kHelpingSoundName)
            self.lastOrderLocation = order:GetLocation()
        elseif order:GetType() == kTechId.Construct then
        
            self:PlayChatSound(kStartConstructionSoundName)
            
            if currentComm then
                Server.PlayPrivateSound(currentComm, kStartConstruction2DSoundName, currentComm, 1.0, Vector(0, 0, 0))
            end
            self.lastOrderLocation = order:GetLocation()
            
        elseif order:GetType() == kTechId.Weld or order:GetType() == kTechId.AutoWeld then 
            
            if order:GetLocation() ~= self.lastOrderLocation or self.lastOrderLocation == nil then

                self:PlayChatSound(kStartWeldSound)

                if currentComm then
                    Server.PlayPrivateSound(currentComm, kStartWeldSound, currentComm, 1.0, Vector(0, 0, 0))
                end
                
                self.lastOrderLocation = order:GetLocation()
                
            end
            
        elseif order:GetType() == kTechId.FollowAndWeld then
        
            self:SetLeashPos(nil)
            
        else
        
            self:PlayChatSound(kConfirmSoundName)
            
            if currentComm then
                Server.PlayPrivateSound(currentComm, kConfirm2DSoundName, currentComm, 1.0, Vector(0, 0, 0))
            end
            
            self.lastOrderLocation = order:GetLocation()
            
        end

    end

end

function MAC:GetMoveSpeed()

    local maxSpeedTable = { maxSpeed = MAC.kMoveSpeed }
    if self.rolloutSourceFactory then
        maxSpeedTable.maxSpeed = MAC.kRolloutSpeed
    end
    self:ModifyMaxSpeed(maxSpeedTable)

    return maxSpeedTable.maxSpeed
    
end

function MAC:GetBackPosition(target)

    if not target:isa("Player") then
        return None
    end
    
    local coords = target:GetViewAngles():GetCoords()
    local targetViewAxis = coords.zAxis
    targetViewAxis.y = 0 -- keep it 2D
    targetViewAxis:Normalize()
    local fromTarget = self:GetOrigin() - target:GetOrigin()
    local targetDist = fromTarget:GetLengthXZ()
    fromTarget.y = 0
    fromTarget:Normalize()

    local weldPos = None    
    local dot = targetViewAxis:DotProduct(fromTarget)    
    -- if we are in front or not sufficiently away from the target, we calculate a new weldPos
    if dot > 0.866 or targetDist < MAC.kWeldDistance - 0.5 then
        -- we are in front, find out back positon
        local obstacleSize = GetObstacleSize(target)

        -- we do not want to go straight through the player, instead we move behind and to the
        -- left or right
        local targetPos = target:GetOrigin()
        local toMidPos = targetViewAxis * (obstacleSize + MAC.kWeldDistance - 0.1)
        local midWeldPos = targetPos - targetViewAxis * (obstacleSize + MAC.kWeldDistance - 0.4)
        local leftV = Vector(-targetViewAxis.z, targetViewAxis.y, targetViewAxis.x)
        local rightV = Vector(targetViewAxis.z, targetViewAxis.y, -targetViewAxis.x)
        local leftWeldPos = midWeldPos + leftV * 2
        local rightWeldPos = midWeldPos + rightV * 2
        --[[
        DebugBox(leftWeldPos+Vector(0,1,0),leftWeldPos+Vector(0,1,0),Vector(0.1,0.1,0.1), 5, 1, 0, 0, 1)
        DebugBox(rightWeldPos+Vector(0,1,0),rightWeldPos+Vector(0,1,0),Vector(0.1,0.1,0.1), 5, 1, 1, 0, 1)
        DebugBox(midWeldPos+Vector(0,1,0),midWeldPos+Vector(0,1,0),Vector(0.1,0.1,0.1), 5, 1, 1, 1, 1)       
        --]]
        -- take the shortest route
        local origin = self:GetOrigin()
        if (origin - leftWeldPos):GetLengthSquared() < (origin - rightWeldPos):GetLengthSquared() then
            weldPos = leftWeldPos
        else
            weldPos = rightWeldPos
        end
    end
    
    return weldPos
        
end

function MAC:CheckBehindBackPosition(orderTarget)
    
    local targetWelding = orderTarget.GetActiveWeapon and orderTarget:GetActiveWeapon() and orderTarget:GetActiveWeapon():GetMapName() == Welder.kMapName
    -- Don't circle behind player if they're welding
    if targetWelding then
        return None
    end
    
    if not self.timeOfLastBackPositionCheck or Shared.GetTime() > self.timeOfLastBackPositionCheck + MAC.kWeldPositionCheckInterval then
 
        self.timeOfLastBackPositionCheck = Shared.GetTime()
        self.backPosition = self:GetBackPosition(orderTarget)

    end

    return self.backPosition    
end

function MAC:ProcessWeldOrder(deltaTime, orderTarget, orderLocation, autoWeld)

    local time = Shared.GetTime()
    local canBeWeldedNow = false
    local orderStatus = kOrderStatus.InProgress

    -- It is possible for the target to not be weldable at this point.
    -- This can happen if a damaged Marine becomes Commander for example.
    -- The Commander is not Weldable but the Order correctly updated to the
    -- new entity Id of the Commander. In this case, the order will simply be completed.
  
    -- TODO: optimize this
    if orderTarget and HasMixin(orderTarget, "Weldable") then

        local toTarget = (orderLocation - self:GetOrigin())
        local distanceToTarget = toTarget:GetLength()
        canBeWeldedNow = orderTarget:GetCanBeWelded(self) and orderTarget:GetWeldPercentage() < 1

        local obstacleSize = GetObstacleSize(orderTarget)

        local leashToTargetXZDistance = self:GetLeashPos() and Vector(self:GetLeashPos() - orderTarget:GetOrigin()):GetLengthXZ() or 0
        local tooFarFromLeash = self:GetLeashPos() and (
                                leashToTargetXZDistance > obstacleSize + MAC.kDefaultLeashRadius or
                                distanceToTarget > obstacleSize + MAC.kDefaultLeashRadius )
                                or false

        if autoWeld and self:IsBeyondLeash() then --(tooFarFromLeash or distanceToTarget > self:GetOrderScanRadius()) then
            orderStatus = kOrderStatus.Cancelled
            --Log("MAC -- Autoweld target went out of leash, resuming former order")
        elseif not canBeWeldedNow then
            orderStatus = kOrderStatus.Completed
        else
            local forceMove = false
            local targetPosition = orderTarget:GetOrigin()

            local closeEnoughToWeld = distanceToTarget - obstacleSize < MAC.kWeldDistance + 0.5
            local shouldMoveCloser = distanceToTarget - obstacleSize > MAC.kWeldDistance
            
            -- don't circle behind if target player is urgent, or target is near leash limit
            if closeEnoughToWeld and leashToTargetXZDistance <= self:GetOrderScanRadius() and not self:IsUsingShortLeash() then
            
                local backPosition = self:CheckBehindBackPosition(orderTarget)
                if backPosition then
                    forceMove = true
                    targetPosition = backPosition
                end
            end

            if shouldMoveCloser or forceMove then
                -- otherwise move towards it
                local hoverAdjustedLocation = GetHoverAt(self, targetPosition)
                local doneMoving = self:MoveToTarget(PhysicsMask.AIMovement, hoverAdjustedLocation, self:GetMoveSpeed(), deltaTime)
                self.moving = not doneMoving
            else
                self.moving = false
            end

            -- DISABLED - Not allowed to weld after taking damage recently.
            --[[if Shared.GetTime() - self:GetTimeLastDamageTaken() <= 1.0 then
                return kOrderStatus.InProgress
            end--]]

            -- Weld target if we're close enough to weld and enough time has passed since last weld
            if closeEnoughToWeld and (time >= self.timeOfLastWeld + MAC.kWeldRate) then
                orderTarget:OnWeld(self, MAC.kWeldRate)
                self.timeOfLastWeld = time
            end

        end

    else
        orderStatus = kOrderStatus.Cancelled
    end
    
    -- Continuously turn towards the target. But don't mess with path finding movement if it was done.
    if orderLocation and not self.moving then
    
        local toOrder = (orderLocation - self:GetOrigin())
        self:SmoothTurn(deltaTime, GetNormalizedVector(toOrder), 0)
        
    end
    
    return orderStatus
    
end


function MAC:ProcessMove(deltaTime, target, targetPosition, closeEnough)

    local hoverAdjustedLocation = GetHoverAt(self, targetPosition)
    local distance = (targetPosition - self:GetOrigin()):GetLengthXZ()
    local doneMoving = distance <= closeEnough

    if (not doneMoving) then
        doneMoving = self:MoveToTarget(PhysicsMask.AIMovement, hoverAdjustedLocation, self:GetMoveSpeed(), deltaTime)
    end

    if (doneMoving) then
        if (self.moving == true) then
            self.moving = false
            return kOrderStatus.Completed -- We just finished
        else
            return kOrderStatus.None -- nothing done
        end
    else
        self.moving = true
        return kOrderStatus.InProgress -- Moving toward point
    end
    
end

function MAC:PlayChatSound(soundName)   --FIXME This can be heard by Alien Comm without LOS ...switch to Team sound?

    -- Balance Mod, added 8 seconds
    if self.timeOfLastChatterSound == 0 or (Shared.GetTime() > self.timeOfLastChatterSound + 10) and self:GetIsAlive() then

        local team = self:GetTeam()
        team:PlayPrivateTeamSound(soundName, self:GetOrigin(), false, nil, false, nil)  --FIXME This seems to make it 2D Only (not positional)
        
        local enemyTeamNumber = GetEnemyTeamNumber(team:GetTeamNumber())
        local enemyTeam = GetGamerules():GetTeam(enemyTeamNumber)
        if enemyTeam ~= nil then  --SeenByTeam? ...not sure that exists
            team:PlayPrivateTeamSound(soundName, self:GetOrigin(), false, nil, false, nil)
        end
        --self:PlaySound(soundName)
        self.timeOfLastChatterSound = Shared.GetTime()
    end
    
end

-- Look for other MACs and Drifters to greet as we fly by
function MAC:UpdateGreetings()

    local time = Shared.GetTime()
    if self.timeOfLastGreetingCheck == 0 or (time > (self.timeOfLastGreetingCheck + MAC.kGreetingUpdateInterval)) then
    
        if self.timeOfLastGreeting == 0 or (time > (self.timeOfLastGreeting + MAC.kGreetingInterval)) then
        
            local ents = GetEntitiesMatchAnyTypes({"MAC", "Drifter"})
            for index, ent in ipairs(ents) do
            
                if (ent ~= self) and (self:GetOrigin() - ent:GetOrigin()):GetLength() < MAC.kGreetingDistance then
                
                    if GetCanSeeEntity(self, ent) then
                        if ent:isa("MAC") then
                            self:PlayChatSound(kPassbyMACSoundName)
                        elseif ent:isa("Drifter") then
                            self:PlayChatSound(kPassbyDrifterSoundName)
                        end
                        
                        self.timeOfLastGreeting = time
                        break
                        
                    end
                    
                end                    
                    
            end                
                            
        end
        
        self.timeOfLastGreetingCheck = time
        
    end

end

function MAC:GetCanBeWeldedOverride()
    return true
end

function MAC:GetEngagementPointOverride()
    return self:GetOrigin() + Vector(0, self:GetHoverHeight(), 0)
end

local function GetCanConstructTarget(self, target)
    return target ~= nil and HasMixin(target, "Construct") and GetAreFriends(self, target)
end

function MAC:ProcessConstruct(deltaTime, orderTarget, orderLocation)

    local time = Shared.GetTime()
    
    local toTarget = (orderLocation - self:GetOrigin())
    local distToTarget = toTarget:GetLengthXZ()
    local orderStatus = kOrderStatus.InProgress
    local canConstructTarget = GetCanConstructTarget(self, orderTarget)

    if canConstructTarget then
        if self.timeOfLastConstruct == 0 or (time > (self.timeOfLastConstruct + MAC.kConstructRate)) then
            local engagementDist = GetEngagementDistance(orderTarget:GetId()) 
            if distToTarget < engagementDist then
        
                if orderTarget:GetIsBuilt() then   
                    orderStatus = kOrderStatus.Completed
                else
            
                    -- Otherwise, add build time to structure
                    orderTarget:Construct(MAC.kConstructRate * kMACConstructEfficacy, self)
                    self.timeOfLastConstruct = time
                
                end
                
            else
            
                local hoverAdjustedLocation = GetHoverAt(self, orderLocation)
                local doneMoving = self:MoveToTarget(PhysicsMask.AIMovement, hoverAdjustedLocation, self:GetMoveSpeed(), deltaTime)
                self.moving = not doneMoving
                
                -- Not sure if this is the best method, but MAC sometimes stops when construct target is built before it can be reached
                if orderTarget:GetIsBuilt() then   
                    orderStatus = kOrderStatus.Completed
                end
            end    
        end

    end
    
    -- Continuously turn towards the target. But don't mess with path finding movement if it was done.
    if not self.moving and toTarget then
        self:SmoothTurn(deltaTime, GetNormalizedVector(toTarget), 0)
    end
    
    return orderStatus
    
end

function MAC:OnValidateOrder(newOrder)
    -- No multi welding on marines (only multi welding restriction)
    -- Multi welding is also checked for side-quests
    local target = (newOrder and newOrder:GetParam() ~= nil) and Shared.GetEntity(newOrder:GetParam()) or nil

    local isAlreadyBeingWelded, isDirectWeldOrder = self:GetIsWeldedByOtherMAC(target)
    -- Only restrain multiple direct order, sidequests macs will stop once they see the other took the job
    if target and HasMixin(target, "Live") and target:GetIsAlive() and (isAlreadyBeingWelded and isDirectWeldOrder) then
        if target:isa("Player") and not MAC.CanMultipleWeldPlayers then
            --Log("MAC -- Player already welded by other MAC, invalidating order")
            return false
        end
        if (HasMixin(target, "Weldable") or HasMixin(target, "Construct")) and not MAC.CanMultipleWeldPvE then
            --Log("MAC -- PvE already welded by other MAC, invalidating order")
            return false
        end
    end
    return true
end

function MAC:OnOrderGiven(newOrder)


    --Log("MAC: Setting new leash location (new order given)")
    self:SetLeashPos(newOrder:GetLocation()) -- Leash is position of last order given (not GetCurrentOrderTarget())

    if (newOrder:GetType() == kTechId.FollowAndWeld and self:GetCurrentOrder():GetType() == kTechId.Move) then
        -- QoL: If we have move orders, just discard them and go straight for the target
        -- (because ns2 is autochaining a move and THEN a follow order, which is not a nice detour)
        self:ClearCurrentOrder()
        --Log("MAC -- Clearing current move order and moving straight to target")
    end

    -- Clear the QoL hold order whenever a new different order is given (it will be reissued once done)
    if (newOrder:GetType() ~= kTechId.HoldPosition and self:GetCurrentOrder():GetType() == kTechId.HoldPosition) then
        self:ClearCurrentOrder()
    end
    
end

-- for marquee selection
function MAC:GetIsMoveable()
    return true
end

function MAC:UpdateCurrentOrder(deltaTime, currentOrder)
    local orderStatus = kOrderStatus.None        
    local orderTarget = Shared.GetEntity(currentOrder:GetParam())
    local orderLocation = self:GetCurrentOrderTarget()
    local orderType = currentOrder:GetType()

    local hasWeldOrder = orderType and (orderType == kTechId.Weld or orderType == kTechId.AutoWeld)
    local hasMoveOrder = orderType and (orderType == kTechId.Move)
    local hasPatrolOrder = orderType and (orderType == kTechId.Patrol)
    local hasFollowOrder = orderType and (orderType == kTechId.FollowAndWeld)
    local hasConstructOrder = orderType and (orderType == kTechId.Build or orderType == kTechId.Construct)
    -- ------- Process current order (follow, weld, move, hold, build)

    if hasFollowOrder then
       --Log("MAC -- Follow and weld order")
        orderStatus = self:ProcessWeldOrder(deltaTime, orderTarget, orderLocation, orderType == kTechId.AutoWeld)
        if (orderTarget and orderTarget:GetIsAlive()) then -- and orderStatus == kOrderStatus.InProgress) then
            self:SetLeashPos(orderTarget:GetOrigin())
            --Log("MAC -- Follow and weld order -- leash update (in progress status)")
        end
    elseif hasMoveOrder or hasPatrolOrder then
        local closeEnough = self:GetHoverHeight() + kAIMoveOrderCompleteDistance
        local currentTargetNeedsWelding = false

        if (orderTarget) then
            closeEnough = closeEnough + math.max(GetObstacleSize(orderTarget), MAC.kWeldDistance)
            currentTargetNeedsWelding = orderTarget:GetWeldPercentage() < 1
        end

        --Log("MAC -- Updating patrol or move order")
        if (currentTargetNeedsWelding) then
            orderStatus = self:ProcessWeldOrder(deltaTime, orderTarget, orderLocation, false)
        else
            orderStatus = self:ProcessMove(deltaTime, orderTarget, orderLocation, closeEnough)
        end
        self:UpdateGreetings()
    --elseif orderType == kTechId.HoldPosition then
    --    --
        
    elseif hasWeldOrder then -- autoweld means we cancel if we leave leash range
        orderStatus = self:ProcessWeldOrder(deltaTime, orderTarget, orderLocation, orderType == kTechId.AutoWeld)
    elseif hasConstructOrder then
        orderStatus = self:ProcessConstruct(deltaTime, orderTarget, orderLocation)
    else
        orderStatus = kOrderStatus.None
    end
    
    -- ------- Check for if the order is done (completed or cancelled)

    if orderStatus == kOrderStatus.Cancelled then

        if (orderType == kTechId.FollowAndWeld) then
            -- Follow order never complete on their own (infinite), they only get cancelled because target died (so we check for end-of-order here)
            self:CompletedCurrentOrder() -- Complete first, then clear it (it's a looping kind, it won't auto clear itself on complete)
        end

        self:ClearCurrentOrder()
    elseif orderStatus == kOrderStatus.Completed or orderStatus == kOrderStatus.None then
        self:CompletedCurrentOrder()
        --Log("MAC -- Order completed")
    end

    return orderStatus
end

local function _GetNearestWeldablePlayer(self, nearbySortedWeldable)
    for _, w in ipairs(nearbySortedWeldable) do
        -- Max x1 mac per weld target
        if w:isa("Player") then
            local isWeldable = w:GetIsAlive() and w:GetWeldPercentage() < 1
            local isAllowedToWeld = MAC.CanMultipleWeldPlayers or not self:GetIsWeldedByOtherMAC(w)
            if isWeldable and isAllowedToWeld then
                return w
            end
        end
    end
    return nil
end

local function _GetNearestWeldablePvE(self, nearbySortedWeldable)
    for _, w in ipairs(nearbySortedWeldable) do
        if not w:isa("Player") then
            local isWeldable = w:GetIsAlive() and w:GetWeldPercentage() < 1
            local isConstructable = w:GetIsAlive() and (HasMixin(w, "Construct") and w:GetCanConstruct(self))
            local isAllowedToWeld = MAC.CanMultipleWeldPvE or not self:GetIsWeldedByOtherMAC(w)
            -- local isAlreadyBeingWelded = self:GetIsWeldedByOtherMAC(w)
            if (isWeldable and not isConstructable) and (not w:isa("MAC")) and isAllowedToWeld then
                return w
            end
        end
    end
    return nil
end

local function _GetNearestConstructablePvE(self, nearbySortedWeldable)
    for _, w in ipairs(nearbySortedWeldable) do
        if not w:isa("Player") then
            local isConstructable = w:GetIsAlive() and (HasMixin(w, "Construct") and w:GetCanConstruct(self))
            local isAllowedToBuild = MAC.CanMultipleWeldPvE or not self:GetIsWeldedByOtherMAC(w)
            if isConstructable and isAllowedToBuild then --  and not self:GetIsWeldedByOtherMAC(w) -- Constructable CAN be build with multiple macs, only welding is restricted
                return w
            end
        end
    end
    return nil
end

function MAC:DecisionMakingRoutine_SideQuests(deltaTime, currentOrder, currentOrderType, currentOrderTarget)
    
    -- If we found nothing, we go wait one full second til we recheck (reducing calls)
    if self.timeOfLastFindNothingToDo + 1 > Shared.GetTime() then
        return nil
    end

    local newOrderTarget = nil
    local nearbySortedWeldable = self:IsBeyondLeash() and {} or GetEntitiesWithMixinForTeamWithinXZRange("Weldable", self:GetTeamNumber(), self:GetLeashPos(), self:GetOrderScanRadius())
    Shared.SortEntitiesByDistance(self:GetLeashPos(), nearbySortedWeldable)

    local nearestPlayerNeedingWeld = _GetNearestWeldablePlayer(self, nearbySortedWeldable)
    local nearestPvENeedingWeld = _GetNearestWeldablePvE(self, nearbySortedWeldable)
    local nearestConstructablePvE = _GetNearestConstructablePvE(self, nearbySortedWeldable)

    -- Followed target doesn't need immediate welding (catched in first condition),
    -- so we just update the leash to follow it and do side quests
    local hasFollowOrder = currentOrderType and currentOrderTarget and (currentOrderType == kTechId.FollowAndWeld)
    if (hasFollowOrder) then
        self:SetLeashPos(currentOrderTarget:GetOrigin())
        newOrderTarget = currentOrderTarget -- We are assigned to it, even if we don't actively weld it we are ready
    end

    --Log("MAC -- Beyond leash ? " .. (self:IsBeyondLeash() and "yes" or "no"))

    if (not self:IsBeyondLeash() and nearestPlayerNeedingWeld) then -- THEN weld closest PLAYERs to leash point (so it doesn't get stuck on an infested powernode during a hive push)
        self:ProcessWeldOrder(deltaTime, nearestPlayerNeedingWeld, nearestPlayerNeedingWeld:GetOrigin())
        newOrderTarget = nearestPlayerNeedingWeld -- closestMarine, sorted by distance
        --Log("MAC -- Welding nearby players")
    elseif (not self:IsBeyondLeash() and nearestPvENeedingWeld) then
        self:ProcessWeldOrder(deltaTime, nearestPvENeedingWeld, nearestPvENeedingWeld:GetOrigin())
        newOrderTarget = nearestPvENeedingWeld -- closest PvE to weld/construct, sorted by distance
        --Log("MAC -- Welding nearby PVE")
    elseif (not self:IsBeyondLeash() and nearestConstructablePvE) then
        self:ProcessConstruct(deltaTime, nearestConstructablePvE, nearestConstructablePvE:GetOrigin())
        newOrderTarget = nearestConstructablePvE -- closest PvE to weld/construct, sorted by distance
        --Log("MAC -- Building nearby PVE")
    else
        local status = nil
        if (currentOrderType and currentOrderType == kTechId.Patrol) then
            status = self:UpdateCurrentOrder(deltaTime, currentOrder)
        else
            local closeEnough = hasFollowOrder and MAC.kFollowLeashDistance or kAIMoveOrderCompleteDistance
            status = self:ProcessMove(deltaTime, nil, self:GetLeashPos(), closeEnough)
            if (status ~= kOrderStatus.InProgress) then -- if we found nothing to do, delay next calls to +1s
                self.timeOfLastFindNothingToDo = Shared.GetTime()
            end
        end
    end
    return newOrderTarget
end

function MAC:DecisionMakingRoutine(deltaTime)
    local newOrderTarget = nil

    local currentOrder = self:GetCurrentOrder()
    local currentOrderType = (currentOrder and currentOrder:GetType())
    local currentOrderTarget = (currentOrder and currentOrder:GetParam() ~= nil) and Shared.GetEntity(currentOrder:GetParam()) or nil
    local currentTargetNeedsWelding = (currentOrderTarget and currentOrderTarget:GetWeldPercentage() < 1)

    local hasMoveOrder = currentOrderType and (currentOrderType == kTechId.Move)

    -- Don't follow marines through phase gates to who-knows-where
    -- Instead, move to our last set leashPos (which is the entry gate position, so we are not in the middle of nowhere)
    local targetJustPhased = currentOrderTarget and currentOrderTarget.timeOfLastPhase and Shared.GetTime() < currentOrderTarget.timeOfLastPhase + 0.5
    if (targetJustPhased) then
        --Log("-- MAC Target just phased, discarding follow order (so we don't cross the entire map and die)")
        self:ClearCurrentOrder()
        return nil
    end

    if (currentTargetNeedsWelding or hasMoveOrder) then -- Do what coms say TOP priority (like welding exo or building PvE)
        local orderStatus = self:UpdateCurrentOrder(deltaTime, currentOrder)
        newOrderTarget = currentOrderTarget
        --Log("MAC -- Following current order")
    else -- MAC side/idle quests (off orders, but do not discard current one)
        newOrderTarget = self:DecisionMakingRoutine_SideQuests(deltaTime, currentOrder, currentOrderType, currentOrderTarget)
    end
    return newOrderTarget
end

function MAC:OnUpdate(deltaTime)

    ScriptActor.OnUpdate(self, deltaTime)
    if Server and self:GetIsAlive() then

        -- Main logic
        local orderTarget = self:DecisionMakingRoutine(deltaTime)
        self.targetId = orderTarget and orderTarget:GetId() or nil

        -- Some variable to update so we trigger animations on the client side 
        self.constructing = Shared.GetTime() - self.timeOfLastConstruct < 0.5
        self.welding = Shared.GetTime() - self.timeOfLastWeld < 0.5

        if self.moving and not self.jetsSound:GetIsPlaying() then
            self.jetsSound:Start()
        elseif not self.moving and self.jetsSound:GetIsPlaying() then
            self.jetsSound:Stop()
        end

    -- client side build / weld effects
    elseif Client and self:GetIsAlive() then
    
        self.orderScanRadiusClient = self:GetOrderScanRadius()
        
        if self.constructing then
        
            if not self.timeLastConstructEffect or self.timeLastConstructEffect + MAC.kConstructRate < Shared.GetTime()  then
            
                self:TriggerEffects("mac_construct")
                self.timeLastConstructEffect = Shared.GetTime()
                
            end
            
        end
        
        if self.welding then
        
            if not self.timeLastWeldEffect or self.timeLastWeldEffect + MAC.kWeldRate < Shared.GetTime()  then
            
                self:TriggerEffects("mac_weld")
                self.timeLastWeldEffect = Shared.GetTime()
                
            end
            
        end
        
        if self:GetHasOrder() ~= self.clientHasOrder then
        
            self.clientHasOrder = self:GetHasOrder()
            
            if self.clientHasOrder then
                self:TriggerEffects("mac_set_order")
            end
            
        end

        if self.jetsCinematics then

            for id,cinematic in ipairs(self.jetsCinematics) do
                self.jetsCinematics[id]:SetIsActive(self.moving and self:GetIsVisible())
            end

        end

    end
    
end

-- Rally order to not give a proper order and don't follow classic order function calls, so we have to set leash manually for that case.
function MAC:ProcessRallyOrder(originatingEntity)
    OrdersMixin.ProcessRallyOrder(self, originatingEntity)

    -- Mac has x2 orders, the rollout and the rally order right next
    local tailOrder = self:GetHasOrder() and self:GetLastOrder() or nil
    if (tailOrder) then
        self:SetLeashPos(tailOrder:GetLocation())
        --Log("MAC -- Setting leash manually upon rally order")
    end
end

local function _issueQoLHoldOrder(self)
    -- Looping orders don't do well when interrupted by other orders, only do the QoL for regular orders (when idle or moving)
    local tailOrder = self:GetHasOrder() and self:GetLastOrder() or nil
    if not (tailOrder and tailOrder:GetType() == kTechId.HoldPosition) and not self:GetIsLoopingOrders() then
        local targetId = self:GetId()
        local pos = tailOrder and tailOrder:GetLocation() or self:GetOrigin()
        local currentOrder = self:GetCurrentOrder()
        local currentOrderTarget = (currentOrder and currentOrder:GetParam() ~= nil) and Shared.GetEntity(currentOrder:GetParam()) or nil

        -- In case of looping orders, the anchor is the leash position (which is followed target)
        if (self:GetIsLoopingOrders() and currentOrderTarget) then
            pos = self:GetLeashPos()
            targetId = currentOrderTarget:GetId()
        end

        self:GiveOrder(kTechId.HoldPosition, targetId, pos, nil, false, false)
    end
end

function MAC:OnOrderComplete(currentOrder)
    local tailOrder = self:GetLastOrder()
    --if self.autoReturning and order:GetType() == kTechId.Move then

    --Log("MAC -- OnOrderComplete()")

    -- Orders can be classic, repeating (weld/autoweld), or cycling (patrol).
    -- We only re-adjust leash on cycling ones:
    -- * The other types rely on either a one-shot set when ordered, or a frequent position set (not during the on-complete)
    if currentOrder and tailOrder then
        -- Patrol orders dest change once you reach the position (adjust, so it can do side quests on each loop points)
        if GetIsOrderCyclingType(currentOrder) then
            self:SetLeashPos(self:GetCurrentOrderTarget())
            --Log("MAC -- Looping order done, such as patrol (update leash to new patrol position)")
        end
        -- For repeating (like follow), we have to reset to tail order position (it was overwritten by the followed position)

        if GetIsOrderRepeatingType(currentOrder) and not GetIsOrderLoopingType(tailOrder) then
            self:SetLeashPos(tailOrder:GetLocation())
            --Log("MAC -- Cycling order done (such as follow), use tail order as new leash instead of followed entity")
        end
    end


    -- If last order, then add the hold
    -- This is just a QoL visual to know we are using short leash
    if (self:IsUsingShortLeash()) then
        _issueQoLHoldOrder(self)
    end
end


function MAC:PerformAction(techNode, position)

    if techNode:GetTechId() == kTechId.Stop then
        self:SetLeashPos(nil)
        self:SetLongLeash()
        --self.autoReturning = false
        --self.searchFollowTarget = false
        self.timeOfLastFindSomethingTime = Shared.GetTime() + 0.99 -- pause MAC for 1 second
        return true
        
    elseif techNode:GetTechId() == kTechId.HoldPosition then -- Toggle short/long leash
        
        if (self:GetHasOrder() and self:GetCurrentOrder():GetType() == kTechId.HoldPosition) then
            self:ClearCurrentOrder()
        end

        if (self:IsUsingShortLeash()) then
            self:SetLongLeash()
            --Log("MAC -- Using long leash now")
        else
            _issueQoLHoldOrder(self)
            self:SetShortLeash()
            --Log("MAC -- Using short leash now")
        end
        
        return true
    end

    return false
end

function MAC:PerformActivation(techId, position, normal, commander)

    if techId == kTechId.MACEMP then
    
        local empBlast = CreateEntity(EMPBlast.kMapName, self:GetOrigin(), self:GetTeamNumber())
        return empBlast ~= nil, false
    
    end
    
    return ScriptActor.PerformActivation(self, techId, position, normal, commander)
    
end

function MAC:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player)
    
    if techId == kTechId.Move or (techId == kTechId.HoldPosition and not self:IsUsingShortLeash()) or techId == kTechId.Stop then
        allowed = true
    elseif techId == kTechId.Patrol or techId == kTechId.Recycle then
        allowed = true
    else
        allowed = false
    end
    
    return allowed, canAfford
    
end

function MAC:GetTechButtons(techId)

    local techButtons = 
            { kTechId.Move, kTechId.Stop, kTechId.HoldPosition, kTechId.Patrol,
              kTechId.None, kTechId.None, kTechId.None, kTechId.Recycle }
    
    return techButtons
end

function MAC:OnOverrideDoorInteraction(inEntity)
    -- MACs will not open the door if they are currently
    -- welding it shut
    if self:GetHasOrder() then
        local order = self:GetCurrentOrder()
        local targetId = order:GetParam()
        local target = Shared.GetEntity(targetId)
        if (target ~= nil) then
            if (target == inEntity) then
               return false, 0
            end
        end
    end
    return true, 4
end

function MAC:GetIdleSoundInterval()
    return 25
end

function MAC:UpdateIncludeRelevancyMask()
    SetAlwaysRelevantToCommander(self, true)
end

if Server then
    
    function MAC:GetCanReposition()
        return true
    end
    
    function MAC:OverrideRepositioningSpeed()
        return MAC.kMoveSpeed * 0.7 --MAC.kMoveSpeed *.4
    end    
    
    function MAC:OverrideRepositioningDistance()
        return 0.4
    end    

    function MAC:OverrideGetRepositioningTime()
        return .5
    end

end

local function GetOrderMovesMAC(orderType)

    return orderType == kTechId.Move or
           orderType == kTechId.Build or
           orderType == kTechId.Construct or
           orderType == kTechId.Weld

end

function MAC:OnUpdateAnimationInput(modelMixin)

    PROFILE("MAC:OnUpdateAnimationInput")
    
    local move = "idle"
    local currentOrder = self:GetCurrentOrder()
    if currentOrder then
    
        if GetOrderMovesMAC(currentOrder:GetType()) then
            move = "run"
        end
    
    end
    modelMixin:SetAnimationInput("move",  move)
    
    local currentTime = Shared.GetTime()
    local activity = "none"
    if self.constructing or self.welding then
        activity = "build"
    end
    modelMixin:SetAnimationInput("activity", activity)

end

function MAC:GetShowHitIndicator()
    return false
end

function MAC:GetPlayIdleSound()
    return not self:GetHasOrder() and GetIsUnitActive(self)
end

function MAC:GetHealthbarOffset()
    return 0.7 --1.4
end 

function MAC:OnDestroy()

    Entity.OnDestroy(self)

    if Client then

        for id,cinematic in ipairs(self.jetsCinematics) do

            Client.DestroyCinematic(cinematic)
            self.jetsCinematics[id] = nil

        end

    end
    
end

-- %%% New CBM Functions %%% --
function MAC:OverrideVisionRadius()
    return 10
end

function MAC:GetCanBeUsed(player, useSuccessTable)

    if player:isa("Exo") then
        useSuccessTable.useSuccess = true
    end
    
end

function MAC:GetUseMaxRange()
    return self.kMaxUseableRange
end

function MAC:GetWorkingRadius()
    return self.orderScanRadiusClient
end

function MAC:OnAdjustModelCoords(modelCoords)

	modelCoords.xAxis = modelCoords.xAxis * MAC.kModelScale
	modelCoords.yAxis = modelCoords.yAxis * MAC.kModelScale
	modelCoords.zAxis = modelCoords.zAxis * MAC.kModelScale

    return modelCoords
    
end

Shared.LinkClassToMap("MAC", MAC.kMapName, networkVars, true)

if Server then

    local function OnCommandFollowAndWeld(client)

        if client ~= nil and Shared.GetCheatsEnabled() then
        
            local player = client:GetControllingPlayer()
            for _, mac in ipairs(GetEntitiesForTeamWithinXZRange("MAC", player:GetTeamNumber(), player:GetOrigin(), 10)) do
                --mac.selfGivenAutomaticOrder = false
                mac:GiveOrder(kTechId.FollowAndWeld, player:GetId(), player:GetOrigin(), nil, false, false)
            end
            
        end

    end

    Event.Hook("Console_followandweld", OnCommandFollowAndWeld)

end
