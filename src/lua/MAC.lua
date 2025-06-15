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

-- Balance
MAC.kConstructRate = 0.4
MAC.kWeldRate = 0.5
MAC.kOrderScanRadius = 10.0  --12.0
MAC.kDefaultLeashRadius = 14.0 -- needs to be longer than kOrderScanRadius + kWeldDistance
MAC.kHoldPositionOrderRadius = 3.0 -- 2.5
MAC.kFollowLeashDistance = 4.0
MAC.kFollowLeashWorkingDistance = 6.0
MAC.kRepairHealthPerSecond = 30
MAC.kHealth = kMACHealth
MAC.kArmor = kMACArmor
MAC.kMoveSpeed = 7
MAC.kHoverHeight = 0.5
MAC.kStartDistance = 3
MAC.kWeldDistance = 2
MAC.kBuildDistance = 2     -- Distance at which bot can start building a structure.
MAC.kSpeedUpgradePercent = (1 + kMACSpeedAmount)
-- how often we check to see if we are in a marines face when welding
-- Note: Need to be fairly long to allow it to weld marines with backs towards walls - the AI will
-- stop moving after a < 1 sec long interval, and the welding will be done in the time before it tries
-- to move behind their backs again
MAC.kWeldPositionCheckInterval = 1 

-- how fast the MAC rolls out of the ARC factory. Standard speed is just too fast.
MAC.kRolloutSpeed = 5
MAC.kModelScale = 0.75

MAC.kCapsuleHeight = 0.2
MAC.kCapsuleRadius = 0.5

-- Greetings
MAC.kGreetingUpdateInterval = 1
MAC.kGreetingInterval = 10
MAC.kGreetingDistance = 5
MAC.kUseTime = 2.0
MAC.kMaxUseableRange = 3.0
MAC.kSearthIdleMACRange = 15.0
 
MAC.kTurnSpeed = 3 * math.pi -- a mac is nimble
local networkVars =
{
    welding = "boolean",
    constructing = "boolean",
    moving = "boolean",
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

-- TODO: implement this function to return a list of idle MACs nearby
function MAC:GetNearbyIdleMACs(target)

    if target then
    
        local idleList = GetEntitiesForTeamWithinXZRange("MAC", target:GetTeamNumber(), target:GetOrigin(), MAC.kSearthIdleMACRange)
        
        for index, mac in ipairs(idleList) do
        
            local isIdle = false
            
            local currentOrder = mac:GetCurrentOrder()
            local orderTarget
            if currentOrder ~= nil then
                table.remove(idleList, index)
                break
                --isIdle = true
            end
            
            if mac.secondaryOrderType ~= nil then
                table.remove(idleList, index)
                break
                --isIdle = true
            end
            
        end
        
    end
    
    --return idleList
    
end


function MAC:GetIsWeldedByOtherMAC(target)

    if target then
    
        for _, mac in ipairs(GetEntitiesForTeam("MAC", self:GetTeamNumber())) do
        
            if self ~= mac then
            
                if mac.secondaryTargetId ~= nil and Shared.GetEntity(mac.secondaryTargetId) == target then
                    return true
                end
                
                local currentOrder = mac:GetCurrentOrder()
                local orderTarget
                if currentOrder and currentOrder:GetParam() ~= nil then
                    orderTarget = Shared.GetEntity(currentOrder:GetParam())
                end
                
                if currentOrder and orderTarget == target and (currentOrder:GetType() == kTechId.FollowAndWeld or currentOrder:GetType() == kTechId.Weld or currentOrder:GetType() == kTechId.AutoWeld) then
                    return true
                end
                
            end
            
        end
        
    end
    
    return false
    
end

function MAC:GetIsWeldedByAnyMAC(target)
     
    if target then
    
        local allMacs = GetEntitiesForTeam("MAC", target:GetTeamNumber())
        --table.copy(GetEntitiesForTeam("BattleMAC", target:GetTeamNumber()), allMacs, true)
    
        for _, mac in ipairs(allMacs) do
            
            if mac.secondaryTargetId ~= nil and Shared.GetEntity(mac.secondaryTargetId) == target then
                return true
            end
            
            local currentOrder = mac:GetCurrentOrder()
            local orderTarget
            if currentOrder and currentOrder:GetParam() ~= nil then
                orderTarget = Shared.GetEntity(currentOrder:GetParam())
            end
            
            if currentOrder and orderTarget == target and (currentOrder:GetType() == kTechId.FollowAndWeld or currentOrder:GetType() == kTechId.Weld or currentOrder:GetType() == kTechId.AutoWeld) then
                return true
            end
            
            
        end
        
    end
    
    return false
    
end

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
        
    if Server then
        InitMixin(self, RepositioningMixin)
        self.orderScanRadius = MAC.kOrderScanRadius
    elseif Client then
        InitMixin(self, CommanderGlowMixin)
		InitMixin(self, BlowtorchTargetMixin)
        self.orderScanRadiusClient = MAC.kOrderScanRadius
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

        self.leashedPosition = nil
        self.autoReturning = false
        self.searchFollowTarget = false
        
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

function MAC:FindFollowAndWeldTarget()
    local newTarget = nil
    local weldables = GetEntitiesWithMixinForTeamWithinXZRange("Weldable", self:GetTeamNumber(), self:GetOrigin(), self.orderScanRadius)
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
                self:GiveOrder(kTechId.FollowAndWeld, newId, newTarget:GetOrigin(), nil, false, false)
                --DebugPrint("MAC following new target")
            end
        end
    end
    
    
    if oldId == self.secondaryTargetId and self.secondaryTargetId ~= nil then
        --DebugPrint("MAC secondary target change")
        self.secondaryOrderType = nil
        self.secondaryTargetId = nil
    end
    
end

function MAC:GetAutomaticOrder()

    local target
    local orderType

    if self.timeOfLastFindSomethingTime == nil or Shared.GetTime() > self.timeOfLastFindSomethingTime + 0.5 then  -- was 1

        self.timeOfLastFindSomethingTime = Shared.GetTime()
                
        -- MAC lost its old follow target, try to find a new one nearby to follow
        -- do this here instead of ProcessFollowAndWeldOrder to reduce frequency of search
        if self.searchFollowTarget then
            local newTarget = self:FindFollowAndWeldTarget()
            if newTarget then
                --DebugPrint("MAC now following "..newTarget:GetId())
                self.selfGivenAutomaticOrder = false
                self.searchFollowTarget = false
                target = newTarget
                orderType = kTechId.FollowAndWeld
                
                return target, orderType
            end
        end
    
        local currentOrder = self:GetCurrentOrder()
        local primaryTarget
        --[[local orderScanRadius = self.holdingPosition and MAC.kHoldPositionOrderRadius 
                                or MAC.kOrderScanRadius--]]
        self.orderScanRadius = self.holdingPosition and MAC.kHoldPositionOrderRadius 
                                or MAC.kOrderScanRadius
                                
        local orderScanOrigin = self.leashedPosition or self:GetOrigin()
        
        if currentOrder and currentOrder:GetType() == kTechId.FollowAndWeld then
            primaryTarget = Shared.GetEntity(currentOrder:GetParam())
            self.orderScanRadius = MAC.kFollowLeashWorkingDistance
        end

        if primaryTarget and (HasMixin(primaryTarget, "Weldable") and primaryTarget:GetWeldPercentage() < 1) and not primaryTarget:isa("MAC") then
            
            target = primaryTarget
            orderType = kTechId.AutoWeld
                    
        else

            -- If there's a friendly entity nearby that needs constructing, constuct it.
            local constructables = GetEntitiesWithMixinForTeamWithinXZRange("Construct", self:GetTeamNumber(), orderScanOrigin, self.orderScanRadius)
            Shared.SortEntitiesByDistance(self:GetOrigin(), constructables)
            for c = 1, #constructables do
            
                local constructable = constructables[c]
                if constructable:GetCanConstruct(self) then
                
                    target = constructable
                    orderType = kTechId.Construct
                    break
                    
                end
                
            end
            
            if not target then
            
                -- Look for entities to heal with weld.
                local weldables = GetEntitiesWithMixinForTeamWithinXZRange("Weldable", self:GetTeamNumber(), orderScanOrigin, self.orderScanRadius)
                Shared.SortEntitiesByDistance(self:GetOrigin(), weldables)
                for w = 1, #weldables do
                
                    local weldable = weldables[w]
                    -- There are cases where the weldable's weld percentage is very close to
                    -- 100% but not exactly 100%. This second check prevents the MAC from being so pedantic.
                    if weldable:GetCanBeWelded(self) and weldable:GetWeldPercentage() < 1 and not self:GetIsWeldedByOtherMAC(weldable) and not weldable:isa("MAC") then
                    
                        target = weldable
                        orderType = kTechId.AutoWeld
                        break

                    end
                    
                end
            
            end
        
        end


    end
    
    return target, orderType

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

            -- prioritize welding marines who ask for it
            if player:GetWeldPercentage() < 1 and not self:GetIsWeldedByAnyMAC(player) then
                --self:GiveOrder(kTechId.AutoWeld, player:GetId(), player:GetOrigin(), nil, false, true)
                self.secondaryOrderType = kTechId.AutoWeld
                self.secondaryTargetId = player:GetId()
            end
            
            self.timeOfLastUse = time
            
            
        end
        
    end
    
end

-- avoid the MAC hovering inside (as that shows the MAC through the factory top)
function MAC:GetHoverHeight()
    if self.rolloutSourceFactory then
        -- keep it low until it leaves the factory, then go back to normal hover height
        local h = MAC.kHoverHeight * (1.1 - self.cursor:GetRemainingDistance()) / 1.1
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
    if order:GetType() == kTechId.Default and GetOrderTargetIsConstructTarget(order, self:GetTeamNumber()) and not isSelfOrder then
    
        order:SetType(kTechId.Construct)
        
    elseif order:GetType() == kTechId.Default and orderTarget and orderTarget:isa("PowerPoint") and orderTarget:GetIsDisabled() then
        order:SetType(kTechId.Weld)

    elseif order:GetType() == kTechId.Default and GetOrderTargetIsWeldTarget(order, self:GetTeamNumber()) and not isSelfOrder --[[and not self:GetIsWeldedByOtherMAC(orderTarget)--]] then
    -- allow multiple MACs to follow the same target
        order:SetType(kTechId.FollowAndWeld)

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
        
        local currentComm = owner or nil

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
        
            self.leashedPosition = nil
            
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
        local obstacleSize = 0
        if HasMixin(target, "Extents") then
            obstacleSize = target:GetExtents():GetLengthXZ()
        end
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

-- return true if new target exists, false if original target is unchanged
function MAC:ProcessUrgentWeldRequest(orderTarget, orderLocation)
    local isUrgent = false
    if self.secondaryTargetId ~= nil then  -- TODO: check and fix this "use for priority weld" code
        local secondaryTarget = Shared.GetEntity(self.secondaryTargetId)
        
        -- assume the secondary weld requester has been checked to be eligible
        if secondaryTarget then
            orderTarget = secondaryTarget
            orderLocation = orderTarget:GetOrigin()
            isUrgent = true
        end
    end
    
    return isUrgent, orderTarget, orderLocation
end

function MAC:ProcessWeldOrder(deltaTime, orderTarget, orderLocation, autoWeld)

    local time = Shared.GetTime()
    local canBeWeldedNow = false
    local orderStatus = kOrderStatus.InProgress

    -- It is possible for the target to not be weldable at this point.
    -- This can happen if a damaged Marine becomes Commander for example.
    -- The Commander is not Weldable but the Order correctly updated to the
    -- new entity Id of the Commander. In this case, the order will simply be completed.
    
    --[[if self.secondaryTargetId ~= nil then
        local secondaryTarget = Shared.GetEntity(self.secondaryTargetId)
        
        if secondaryTarget then
            orderTarget = secondaryTarget
            orderLocation = orderTarget:GetOrigin()
        end
    end--]]
    
    -- let players (secondary target) request weld to override current auto order
    local isUrgent = false
    isUrgent, orderTarget, orderLocation = self:ProcessUrgentWeldRequest(orderTarget, orderLocation)

    -- TODO: optimize this
    if orderTarget and HasMixin(orderTarget, "Weldable") then

        local toTarget = (orderLocation - self:GetOrigin())
        local distanceToTarget = toTarget:GetLength()
        canBeWeldedNow = orderTarget:GetCanBeWelded(self) and orderTarget:GetWeldPercentage() < 1

        local obstacleSize = 0
        if HasMixin(orderTarget, "Extents") then
            obstacleSize = orderTarget:GetExtents():GetLengthXZ()
        end

        local leashToTargetXZDistance = self.leashedPosition and Vector(self.leashedPosition - orderTarget:GetOrigin()):GetLengthXZ() or 0
        local tooFarFromLeash = self.leashedPosition and leashToTargetXZDistance > obstacleSize + MAC.kDefaultLeashRadius or false

        if (autoWeld or isUrgent) and tooFarFromLeash then --(tooFarFromLeash or distanceToTarget > MAC.kOrderScanRadius) then
            orderStatus = kOrderStatus.Cancelled
        elseif not canBeWeldedNow then
            orderStatus = kOrderStatus.Completed
        else
            local forceMove = false
            local targetPosition = orderTarget:GetOrigin()

            local closeEnoughToWeld = distanceToTarget - obstacleSize < MAC.kWeldDistance + 0.5
            local shouldMoveCloser = distanceToTarget - obstacleSize > MAC.kWeldDistance
            
            -- don't circlr behind if target player is urgent, if MAC is holding position, or target is near leash limit
            if closeEnoughToWeld and not isUrgent and not self.holdingPosition and leashToTargetXZDistance <= self.orderScanRadius  then
            
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
    local orderStatus = kOrderStatus.None
    local distance = (targetPosition - self:GetOrigin()):GetLength()
    local doneMoving = target ~= nil and distance < closeEnough

    if not doneMoving and self:MoveToTarget(PhysicsMask.AIMovement, hoverAdjustedLocation, self:GetMoveSpeed(), deltaTime) then

        orderStatus = kOrderStatus.Completed
        self.moving = false

    else
        orderStatus = kOrderStatus.InProgress
        self.moving = true
    end
    
    return orderStatus
    
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
    
    -- let players (secondary target) request weld to override current auto order
    local isUrgent = false
    isUrgent, orderTarget, orderLocation = self:ProcessUrgentWeldRequest(orderTarget, orderLocation)
    
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

            end    
        end
        
    else
        -- Note: hopefully this new code doesn't cause bugs
        -- Player can hijack MAC to request urgent welding
        if orderTarget and HasMixin(orderTarget, "Weldable") then
            local secondaryOrderStatus = self:ProcessWeldOrder(deltaTime, orderTarget, orderTarget:GetOrigin(), true)
            orderStatus = secondaryOrderStatus
        else
            orderStatus = kOrderStatus.Cancelled
        end

    end
    
    -- Continuously turn towards the target. But don't mess with path finding movement if it was done.
    if not self.moving and toTarget then
        self:SmoothTurn(deltaTime, GetNormalizedVector(toTarget), 0)
    end
    
    return orderStatus
    
end

function MAC:ReturnHome()
    self.autoReturning = true
    self.selfGivenAutomaticOrder = true
    self:GiveOrder(kTechId.Move, nil, self.leashedPosition, nil, true, true)
    --DebugPrint("MAC returning to "..ToString(self.leashedPosition))
end

function MAC:FindSomethingToDo()
    
    local target, orderType = self:GetAutomaticOrder()

    if target and orderType then
        if self.leashedPosition then
            -- allow some leeway to go to if target is very close, but outside of leash range
            local tooFarFromLeash = Vector(self.leashedPosition - target:GetOrigin()):GetLengthXZ() > MAC.kDefaultLeashRadius
            if tooFarFromLeash and not self.autoReturning then
                --DebugPrint("MAC strayed too far!")
                self:ReturnHome()
                --DebugPrint("MAC returning 1")
                return false
            end
        else
            -- Found new task, remember current location as home
            self.leashedPosition = GetHoverAt(self, self:GetOrigin())
            --DebugPrint("MAC return position set "..ToString(self.leashedPosition))
        end
        self.autoReturning = false
        self.selfGivenAutomaticOrder = true
        --DebugPrint("MAC new auto order")
        return self:GiveOrder(orderType, target:GetId(), target:GetOrigin(), nil, true, true) ~= kTechId.None  
    elseif self.leashedPosition and not self.autoReturning then
        self:ReturnHome()
        --DebugPrint("MAC returning 2")
        return false
    end
    
    return false
    
end

-- Finding work for MAC which is holding position or on patrol
function MAC:FindLocalTask()

    local target, orderType = self:GetAutomaticOrder()
    
    if target and orderType then
        local leashLength = self.holdingPosition and 2.5 or self.orderScanRadius
        if self.leashedPosition then
            local tooFarFromLeash = Vector(self.leashedPosition - target:GetOrigin()):GetLengthXZ() > leashLength
            if tooFarFromLeash then
                --DebugPrint("MAC moved too far!")
                self:ReturnHome()
                return false
            end
        else
            self.leashedPosition = GetHoverAt(self, self:GetOrigin())
            --DebugPrint("MAC return position set "..ToString(self.leashedPosition))
        end
        self.autoReturning = false
        self.selfGivenAutomaticOrder = true
        return self:GiveOrder(orderType, target:GetId(), target:GetOrigin(), nil, true, true) ~= kTechId.None
        
    elseif self.leashedPosition and not self.autoReturning and not self.holdingPosition then
        --DebugPrint("MAC returning to "..ToString(self.leashedPosition))
        self:ReturnHome()
        return false
    end
    return false
    
end


function MAC:OnOrderGiven(order)

    -- Clear out secondary order when an order is explicitly given to this MAC.
    self.secondaryOrderType = nil
    self.secondaryTargetId = nil
    
    if order:GetType() == kTechId.HoldPosition then
        self.leashedPosition = GetHoverAt(self, self:GetOrigin())
        self.autoReturning = false
        self.searchFollowTarget = false
    elseif not self.selfGivenAutomaticOrder then
        --DebugPrint("leash reset")
        self.leashedPosition = nil
        self.autoReturning = false
        self.searchFollowTarget = false
        self.holdingPosition = false
    end 
    self.selfGivenAutomaticOrder = false
    
end

-- for marquee selection
function MAC:GetIsMoveable()
    return true
end

-- Currently fixed, but keep an watchful eye
-- new TODO: make MAC not fixated on follow order that it ignores automatic build orders
-- TODO: make MAC not fixated on automatic build orders that it ignores follow order
function MAC:ProcessFollowAndWeldOrder(deltaTime, orderTarget, targetPosition)

    local currentOrder = self:GetCurrentOrder()
    local orderStatus = kOrderStatus.InProgress
    -- Don't follow marines through phase gates to who-knows-where
    local targetJustPhased = orderTarget and orderTarget.timeOfLastPhase and Shared.GetTime() < orderTarget.timeOfLastPhase + 0.5
    
    if orderTarget and orderTarget:GetIsAlive() and not targetJustPhased then
        
        -- MAC already has a target to follow, don't look for another one right now
        self.searchFollowTarget = false
        
        local target, orderType = self:GetAutomaticOrder()
        -- search for second job only if MAC isn't busy

        if target and orderType then
        
            self.secondaryOrderType = orderType
            self.secondaryTargetId = target:GetId()
            
        end
        
        target = target ~= nil and target or ( self.secondaryTargetId ~= nil and Shared.GetEntity(self.secondaryTargetId) )
        orderType = orderType ~= nil and orderType or self.secondaryOrderType
        
        local forceMove = false
        if not orderType then
            -- if we don't have a secondary order, we make sure we move to the back of the player
            local backPosition = self:CheckBehindBackPosition(orderTarget)
            if backPosition then
                forceMove = true
                targetPosition = backPosition
            end
        end

        local distance = (self:GetOrigin() - targetPosition):GetLengthXZ()
        
        -- stop moving to primary if we find something to do and we are not too far from our primary
        if orderType and self.moveToPrimary and distance < MAC.kFollowLeashDistance then
            self.moveToPrimary = false
        end
        
        -- longer leash when working on something else
        local triggerMoveDistance = (self.welding or self.constructing or orderType) and MAC.kFollowLeashWorkingDistance or MAC.kFollowLeashDistance
        
        if distance > triggerMoveDistance or self.moveToPrimary or forceMove then
            
            local closeEnough = forceMove and 0.1 or 2.5
            if self:ProcessMove(deltaTime, target, targetPosition, closeEnough) == kOrderStatus.InProgress then
                self.moveToPrimary = true
                self.secondaryTargetId = nil
                self.secondaryOrderType = nil
            else
                self.moveToPrimary = false
            end
            
        else
            self.moving = false
        end
        
        -- when we attempt to follow the primary target, dont interrupt with auto orders
        if not self.moveToPrimary then
        
            if target and orderType then
            
                local secondaryOrderStatus

                if orderType == kTechId.AutoWeld then            
                    secondaryOrderStatus = self:ProcessWeldOrder(deltaTime, target, target:GetOrigin(), true)        
                elseif orderType == kTechId.Construct then
                    secondaryOrderStatus = self:ProcessConstruct(deltaTime, target, target:GetOrigin())
                end
                
                if secondaryOrderStatus == kOrderStatus.Completed or secondaryOrderStatus == kOrderStatus.Cancelled then
                
                    self.secondaryTargetId = nil
                    self.secondaryOrderType = nil
                    self.moving = false
                    
                end
                
            else
                self.moving = false
            end
        
        end
    
    else
        self.moveToPrimary = false
        self.searchFollowTarget = true
        orderStatus = kOrderStatus.Cancelled
    end
    
    return orderStatus

end

function MAC:UpdateOrders(deltaTime)

    local currentOrder = self:GetCurrentOrder()
    if currentOrder ~= nil then
    
        local orderStatus = kOrderStatus.None        
        local orderTarget = Shared.GetEntity(currentOrder:GetParam())
        local orderLocation = currentOrder:GetLocation()
        local orderType = currentOrder:GetType()
        
        if orderType == kTechId.FollowAndWeld then
            --self.searchFollowTarget = true
            orderStatus = self:ProcessFollowAndWeldOrder(deltaTime, orderTarget, orderLocation)    
        elseif orderType == kTechId.Move then
            local closeEnough = 2
            orderStatus = self:ProcessMove(deltaTime, orderTarget, orderLocation, closeEnough)
            self:UpdateGreetings()
        elseif orderType == kTechId.HoldPosition then
            local target, orderType = self:FindLocalTask()  -- work with really short leash when on hold position
            
        elseif orderType == kTechId.Weld or orderType == kTechId.AutoWeld then
            orderStatus = self:ProcessWeldOrder(deltaTime, orderTarget, orderLocation, orderType == kTechId.AutoWeld)
        elseif orderType == kTechId.Build or orderType == kTechId.Construct then
            orderStatus = self:ProcessConstruct(deltaTime, orderTarget, orderLocation)
        end
        
        if orderStatus == kOrderStatus.Cancelled then
            self:ClearCurrentOrder()
            self.selfGivenAutomaticOrder = false
        elseif orderStatus == kOrderStatus.Completed then
            self:CompletedCurrentOrder()
            self.selfGivenAutomaticOrder = false
        end
        
    end
    
end

function MAC:OnUpdate(deltaTime)

    ScriptActor.OnUpdate(self, deltaTime)
    
    if Server and self:GetIsAlive() then

        -- assume we're not moving initially
        self.moving = false
        --self.onPatrol = self:GetCurrentOrder() and self:GetCurrentOrder():GetType() == kTechId.Patrol
    
        -- new feature: allow MAC to find tasks while autoreturning
        if self.autoReturning and not self.secondaryTargetId then
            self:FindSomethingToDo()
            self:UpdateOrders(deltaTime)
        elseif not self:GetHasOrder() then
            self:FindSomethingToDo()
        else
            self:UpdateOrders(deltaTime)
        end
        
        self.constructing = Shared.GetTime() - self.timeOfLastConstruct < 0.5
        self.welding = Shared.GetTime() - self.timeOfLastWeld < 0.5

        if self.moving and not self.jetsSound:GetIsPlaying() then
            self.jetsSound:Start()
        elseif not self.moving and self.jetsSound:GetIsPlaying() then
            self.jetsSound:Stop()
        end
        
    -- client side build / weld effects
    elseif Client and self:GetIsAlive() then
    
        self.orderScanRadiusClient = self.orderScanRadius
        
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

function MAC:OnOrderComplete(order)
    if self.autoReturning and order:GetType() == kTechId.Move then
        self.leashedPosition = nil
        self.autoReturning = false
        --DebugPrint("MAC arrived home")
    end
    self.selfGivenAutomaticOrder = false
end

function MAC:PerformActivation(techId, position, normal, commander)

    if techId == kTechId.MACEMP then
    
        local empBlast = CreateEntity(EMPBlast.kMapName, self:GetOrigin(), self:GetTeamNumber())
        return empBlast ~= nil, false
    
    end
    
    return ScriptActor.PerformActivation(self, techId, position, normal, commander)
    
end

function MAC:PerformAction(techNode, position)

    if techNode:GetTechId() == kTechId.Stop then
        self.leashedPosition = nil
        self.autoReturning = false
        self.searchFollowTarget = false
        self.holdingPosition = false
        self.timeOfLastFindSomethingTime = Shared.GetTime() + 0.99 -- pause MAC for 1 second
        return true
        
    elseif techNode:GetTechId() == kTechId.HoldPosition then
        
        self:ClearOrders()
        self.selfGivenAutomaticOrder = false
        self.holdingPosition = true
        self:GiveOrder(kTechId.HoldPosition, self:GetId(), self:GetOrigin(), nil, true, true)
        return true
    end

    return false
end

function MAC:GetTechButtons(techId)

    local techButtons = 
            { kTechId.Move, kTechId.Stop, kTechId.HoldPosition, kTechId.Welding,
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
        return MAC.kMoveSpeed *.4
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
                mac.selfGivenAutomaticOrder = false
                mac:GiveOrder(kTechId.FollowAndWeld, player:GetId(), player:GetOrigin(), nil, false, false)
            end
            
        end

    end

    Event.Hook("Console_followandweld", OnCommandFollowAndWeld)

end
