-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Cyst.lua
--
--    Created by:   Mats Olsson (mats.olsson@matsotech.se)
--
-- A cyst controls and spreads infestation
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/SleeperMixin.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/CommunityBalanceMod/DouseMixin.lua")
Script.Load("lua/MaturityMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/AchievementGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/CatalystMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/CloakableMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/SpawnBlockMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/CystVariantMixin.lua")
Script.Load("lua/RailgunTargetMixin.lua")
Script.Load("lua/CommunityBalanceMod/BlowtorchTargetMixin.lua")

Script.Load("lua/CommAbilities/Alien/EnzymeCloud.lua")
Script.Load("lua/CommAbilities/Alien/Rupture.lua")

class 'Cyst' (ScriptActor)

Cyst.kMaxEncodedPathLength = 30
Cyst.kMapName = "cyst"
Cyst.kModelName = PrecacheAsset("models/alien/cyst/cyst.model")

local CystkAnimationGraph = PrecacheAsset("models/alien/cyst/cyst.animation_graph")

Cyst.kEnergyCost = 25
Cyst.kPointValue = 5
-- how fast the impulse moves
Cyst.kImpulseSpeed = 8

Cyst.kThinkInterval = 1 
Cyst.kImpulseColor = Color(1,1,0)
Cyst.kImpulseLightIntensity = 8
local kImpulseLightRadius = 1.5

Cyst.kExtents = Vector(0.2, 0.1, 0.2)

Cyst.kBurstDuration = 3

-- range at which we can be a parent
Cyst.kCystMaxParentRange = kCystMaxParentRange

-- size of infestation patch
Cyst.kInfestationRadius = kInfestationRadius
Cyst.kInfestationGrowthDuration = Cyst.kInfestationRadius / kCystInfestDuration
-- increase the visual redeploy range slightly to avoid network field truncation and other woes accidentally redeploying cysts
Cyst.kRedeployBias = 0.2

-- how many seconds before a fully mature cyst, disconnected, becomes fully immature again.
Cyst.kMaturityLossTime = 15

-- cyst infestation spreads/recedes faster
Cyst.kInfestationRateMultiplier = 3

Cyst.kInfestationGrowRateMultiplier = 6
Cyst.kInfestationRecideRateMultiplier = 3

Cyst.kFlamableDamageMultiplier = kCystFlamableDamageMultiplier

local kEnemyDetectInterval = 0.2

local networkVars =
{

    -- Since cysts don't move, we don't need the fields to be lag compensated
    -- or delta encoded
    m_origin = "position (by 0.05 [], by 0.05 [], by 0.05 [])",
    m_angles = "angles (by 0.1 [], by 10 [], by 0.1 [])",
    
    -- Cysts are never attached to anything, so remove the fields inherited from Entity
    m_attachPoint = "integer (-1 to 0)",
    m_parentId = "integer (-1 to 0)",
    
    -- Track our parentId
    parentId = "entityid",
    hasChild = "boolean",
    
    -- if we are connected. Note: do NOT use on the server side when calculating reconnects/disconnects,
    -- as the random order of entity update means that you can't trust it to reflect the actual connect/disconnects
    -- used on the client side by the ui to determine connection status for potently cyst building locations
    connected = "boolean",

    --Cysts scale their health based on the distance to the clostest hive
    healthScalar = "float (0 to 1 by 0.01)",

    cloakInfestation = "boolean"
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(DouseMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(MaturityMixin, networkVars)
AddMixinNetworkVars(CatalystMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(PointGiverMixin, networkVars)
AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(CystVariantMixin, networkVars)

local cystChainDebug = false
local function CystChainToggleDebug()
    cystChainDebug = not cystChainDebug
    Log("cystChainDebug now " .. tostring(cystChainDebug))
end

local function OnCommandCystBias(distance)
    if not Shared.GetCheatsEnabled() then return end
    Cyst.kRedeployBias = tonumber(distance) or Cyst.kRedeployBias
    Print("Cyst.kRedeployBias: %f", Cyst.kRedeployBias)
end

--
-- To avoid problems with minicysts on walls connection to each other through solid rock,
-- we need to move the start/end points a little bit along the start/end normals
--
local function CreateBetween(trackStart, startNormal, trackEnd, endNormal, startOffset, endOffset)

    trackStart = trackStart + startNormal * 0.01
    trackEnd = trackEnd + endNormal * 0.01
    
    local pathDirection = trackEnd - trackStart
    pathDirection:Normalize()
    
    if startOffset == nil then
        startOffset = 0.1
    end
    
    if endOffset == nil then
        endOffset = 0.1
    end
    
    -- DL: Offset the points a little towards the center point so that we start with a polygon on a nav mesh
    -- that is closest to the start. This is a workaround for edge case where a start polygon is picked on
    -- a tiny island blocked off by an obstacle.
    trackStart = trackStart + pathDirection * startOffset
    trackEnd = trackEnd - pathDirection * endOffset
    
    local points = PointArray()
    local isReachable = Pathing.GetPathPoints(trackStart, trackEnd, points)
    
    if isReachable then
        -- Always include the starting point in this path for convenience
        Pathing.InsertPoint(points, 1, trackStart)
end
    return isReachable, points

end

--
-- Convinience function when creating a path between two entities, submits the y-axis of the entities coords as
-- the normal for use in CreateBetween()
--
function CreateBetweenEntities(srcEntity, endEntity)    
    return CreateBetween(srcEntity:GetOrigin(), srcEntity:GetCoords().yAxis, endEntity:GetOrigin(), endEntity:GetCoords().yAxis)    
end

if Server then
    Script.Load("lua/Cyst_Server.lua")
end

function Cyst:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, TeamMixin)
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, FireMixin)
    InitMixin(self, UmbraMixin)
	InitMixin(self, DouseMixin)
    InitMixin(self, CatalystMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, FlinchMixin, { kPlayFlinchAnimations = true })
    InitMixin(self, SelectableMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, AchievementGiverMixin)
    InitMixin(self, CloakableMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, MaturityMixin)
    InitMixin(self, DetectableMixin)
    
    if Server then
    
        InitMixin(self, SpawnBlockMixin)
        self:UpdateIncludeRelevancyMask()
        self.timeLastCystConstruction = 0
        
    elseif Client then
        InitMixin(self, CommanderGlowMixin)
		InitMixin(self, RailgunTargetMixin)
		InitMixin(self, BlowtorchTargetMixin)
        self.connectedFraction = 0
    end

    self:SetPhysicsCollisionRep(CollisionRep.Move)
    self:SetPhysicsGroup(PhysicsGroup.SmallStructuresGroup)
    
    self:SetLagCompensated(false)
    
    self.parentId = Entity.invalidId
    
end

function Cyst:OnDestroy()

    if Client then
        
        if self.redeployCircleModel then
        
            Client.DestroyRenderModel(self.redeployCircleModel)
            self.redeployCircleModel = nil
            
        end
        
    end
    
    ScriptActor.OnDestroy(self)
    
end

function Cyst:GetShowSensorBlip()
    return false
end

function Cyst:GetSpawnBlockDuration()
    return 1
end

--
-- A Cyst is redeployable if it is within range of the origin but
-- we ignore the Y distance within some tolerance.
--
local function GetCystIsRedeployable(cyst, origin, bias)
    bias = bias or 0

    local immune = cyst.immuneToRedeploymentTime and Shared.GetTime() <= cyst.immuneToRedeploymentTime
    if cyst:GetDistance(origin) <= (kCystRedeployRange + bias) and not immune then
        if math.abs(cyst:GetOrigin().y - origin.y) < 2 then
            return GetPathDistance(cyst:GetOrigin(), origin) <= (kCystRedeployRange + bias)
    end
    end
    
    return false
    
end

local function DestroyNearbyCysts(self)

    local nearbyCysts = GetEntitiesForTeamWithinRange("Cyst", self:GetTeamNumber(), self:GetOrigin(), kCystRedeployRange)
    for c = 1, #nearbyCysts do
    
        local cyst = nearbyCysts[c]
        if cyst ~= self and GetCystIsRedeployable(cyst, self:GetOrigin()) then
            cyst:Kill()
        end
        
    end
    
end

function Cyst:OnInitialized()

    InitMixin(self, InfestationMixin)
    
    ScriptActor.OnInitialized(self)

    if Server then
    
        -- start out as disconnected; wait for impulse to arrive
        self.connected = false
        
        self.nextUpdate = Shared.GetTime()
        self.impulseActive = false
        self.bursted = false
        self.timeBursted = 0
        self.children = unique_set()
        
        InitMixin(self, SleeperMixin)
        InitMixin(self, StaticTargetMixin)
        
        self:SetModel(Cyst.kModelName, CystkAnimationGraph)
        
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end

        self.cloakInfestation = false
        self:AddTimedCallback(self.UpdateInfestationCloaking, 0.2)
        self:AddTimedCallback(self.ScanForNearbyEnemy, kEnemyDetectInterval)
        
    elseif Client then    
    
        InitMixin(self, UnitStatusMixin)
        self:AddTimedCallback(Cyst.OnTimedUpdate, 0)
        -- note that even though a Client side cyst does not do OnUpdate, its mixins (cloakable mixin) requires it for
        -- now. If we can change that, then cysts _may_ be able to skip OnUpdate
         
    end   
    
    if Server then
        DestroyNearbyCysts(self)
    end
    
    InitMixin(self, IdleMixin)

    if not Predict then
        InitMixin(self, CystVariantMixin)
        self:ForceCystSkinsUpdate()
    end
    
end

function Cyst:GetPlayIdleSound()
    return self:GetIsBuilt() and self:GetCurrentInfestationRadiusCached() < 1
end

function Cyst:SetImmuneToRedeploymentTime(forTime)
    self.immuneToRedeploymentTime = Shared.GetTime() + forTime
end

function Cyst:GetInfestationGrowthRate()
    return Cyst.kInfestationGrowthDuration
end

function Cyst:GetHealthbarOffset()
    return 0.5
end 

--
-- Infestation never sights nearby enemy players.
--
function Cyst:OverrideCheckVision()
    return false
end

function Cyst:GetIsFlameAble()
    return true
end

function Cyst:GetIsFlameableMultiplier()
    return self.kFlamableDamageMultiplier
end

function Cyst:GetIsCamouflaged()
    return self:GetIsConnected() and self:GetIsBuilt() and not self:GetIsInCombat() and GetHasTech(self, kTechId.ShadeHive)
end

function Cyst:GetCloakInfestation()
    return self.cloakInfestation
end

function Cyst:GetAutoBuildRateMultiplier()
    if GetHasTech(self, kTechId.ShiftHive) then
        return 1.25
    end

    return 1
end

function Cyst:GetMatureMaxHealth()
    return math.max(kMatureCystHealth * self.healthScalar or 0, kMinMatureCystHealth)
end

function Cyst:GetMatureMaxArmor()
    if GetHasTech(self, kTechId.CragHive) then
        return 25
    end

    return kMatureCystArmor

end 

function Cyst:GetMatureMaxEnergy()
    return 0
end

function Cyst:GetCanSleep()
    return true
end    

function Cyst:GetTechButtons(techId)
  
    return  { kTechId.Infestation,  kTechId.None, kTechId.None, kTechId.None,
              kTechId.None, kTechId.None, kTechId.None, kTechId.None }

end

function Cyst:GetInfestationRadius()
    return kInfestationRadius
end

function Cyst:GetInfestationMaxRadius()
    return kInfestationRadius
end

function Cyst:GetCystParentRange()
    return Cyst.kCystMaxParentRange
end  

function Cyst:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

--
-- Note: On the server side, used GetIsActuallyConnected()!
--
function Cyst:GetIsConnected() 
    return self.connected
end

function Cyst:GetIsConnectedAndAlive()
    return self.connected and self:GetIsAlive()
end

function Cyst:GetDescription()

    local prePendText = ConditionalValue(self:GetIsConnected(), "", "Unconnected ")
    return prePendText .. ScriptActor.GetDescription(self)
    
end

function Cyst:OnOverrideSpawnInfestation(infestation)

    infestation.maxRadius = kInfestationRadius
    -- New infestation starts partially built, but this allows it to start totally built at start of game
    local radiusPercent = math.max(infestation:GetRadius(), .2)
    infestation:SetRadiusPercent(radiusPercent)
    
end

function Cyst:GetReceivesStructuralDamage()
    return true
end

function Cyst:CanBeBuilt()
    if self:GetIsBuilt() then
        return false
    end

    local parent = self:GetCystParent()
    if not parent or not parent:GetIsBuilt() then
        return false
    end

    return true
end

function Cyst:GetCanAutoBuild()
    return self:CanBeBuilt()
end

function Cyst:GetHealSprayBuildAllowed()
    return self:CanBeBuilt()
end

function Cyst:GetHasChild()
    return self.hasChild
end

if Client then
    
    -- avoid using OnUpdate for cysts, instead use a variable timed callback
    function Cyst:OnTimedUpdate(deltaTime)
      
      PROFILE("Cyst:OnTimedUpdate")
      if self:GetIsAlive() then
          local animateDirection = self.connected and 1 or -1
          self.connectedFraction = Clamp(self.connectedFraction + animateDirection * deltaTime, 0, self:GetBuiltFraction())      
          if self.connectedFraction > 0 and self.connectedFraction < 1 then
              return kUpdateIntervalAnimation
          end
      end
      return kUpdateIntervalLow
      
    end

end

function Cyst:GetCystParent()

    local parent

    if self.parentId and self.parentId ~= Entity.invalidId then
        parent = Shared.GetEntity(self.parentId)
    end
    
    return parent
    
end

function MarkPotentialDeployedCysts(ents, origin)

    for i = 1, #ents do
    
        local ent = ents[i]
        if ent:isa("Cyst") and GetCystIsRedeployable(ent, origin, Cyst.kRedeployBias) then
            ent.markAsPotentialRedeploy = true
        end
        
    end
    
end

--
-- Returns a parent and the track from that parent, or nil if none found.
--
function GetCystParentFromPoint(origin, normal, connectionMethodName, optionalIgnoreEnt, teamNumber)

    PROFILE("Cyst:GetCystParentFromPoint")
    
    local ents = GetSortedListOfPotentialParents(origin, teamNumber, kCystMaxParentRange, kHiveCystParentRange)
    
    if Client then
        MarkPotentialDeployedCysts(ents, origin)
    end
    
    teamNumber = teamNumber or kAlienTeamType
    for i = 1, #ents do
    
        local ent = ents[i]
        
        -- must be either a built hive or an cyst with a connected infestation
        if optionalIgnoreEnt ~= ent and
           ((ent:isa("Hive") and ent:GetIsBuilt()) or (ent:isa("Cyst") and ent[connectionMethodName](ent))) then
            
            local range = (origin - ent:GetOrigin()):GetLength()
            if range <= ent:GetCystParentRange() then
            
                -- check if we have a track from the entity to origin
                local endOffset = 0.1
                if ent:isa("Hive") then
                    endOffset = 3
                end
                
                
                -- The pathing somehow is able to return two different path ((A -> B) != (B -> A))
                -- Ex: Cysting in derelict between the RT in "Turbines" (a bit above the rt), and "Heat Transfer"
                --     You can check those path with a drifter, it will take two different route.
                local isReachable1, path1 = CreateBetween(origin, normal, ent:GetOrigin(), ent:GetCoords().yAxis, 0.1, endOffset)
                local isReachable2, path2 = CreateBetween(ent:GetOrigin(), ent:GetCoords().yAxis, origin, normal, 0.1, endOffset)
                if isReachable1 and path1 and isReachable2 and path2 then
                
                    -- Check that the total path length is within the range.
                    local pathLength1 = GetPointDistance(path1)
                    local pathLength2 = GetPointDistance(path2)
                    if pathLength1 <= ent:GetCystParentRange() then
                        return ent, path1
                    end
                    if pathLength2 <= ent:GetCystParentRange() then
                        local points = PointArray()
                    
                        if cystChainDebug then
                            Log("GetCystParentFromPoint() Regular path didn't worked, using the reverse")
                end
                
                        -- Reverse the path points so we still get an array of points from A to B
                        for i = 1, #path2 do
                            Pathing.InsertPoint(points, 1, path2[i])
            end
                        return ent, points
                    end
            
        end
        
    end
    
        end
        
    end
    
    return nil, nil
    
end

--
-- Return true if a connected cyst parent is availble at the given origin normal, and no destroyed cysts present
--
function GetIsDeadCystNearby(origin, teamNumber)

    local deadCyst = false
        
    teamNumber = teamNumber or kAlienTeamType
    for _, cyst in ipairs(GetEntitiesForTeamWithinRange("Cyst", teamNumber, origin, kInfestationRadius)) do
        
        if not cyst:GetIsAlive() then
            deadCyst = true
            break
        end
        
    end
    
    return deadCyst

end

--
-- Returns a ghost-guide table for gui-use.
--
function GetCystGhostGuides(commander)

    local parent, path = commander:GetCystParentFromCursor()
    local result = { }
    
    if parent then
        result[parent] = parent:GetCystParentRange()
    end
    
    return result
    
end

function GetSortedListOfPotentialParents(origin, teamNumber, maxCystParentDistance, maxHiveParentDistance)
    
    teamNumber = teamNumber or kAlienTeamType
    maxCystParentDistance = maxCystParentDistance or kCystMaxParentRange
    maxHiveParentDistance = maxHiveParentDistance or kHiveCystParentRange
    
    local parents = {}
    local hives = GetEntitiesForTeamWithinRange("Hive", teamNumber, origin, maxHiveParentDistance)
    local cysts = GetEntitiesForTeamWithinRange("Cyst", teamNumber, origin, maxCystParentDistance)
    
    table.copy(hives, parents)
    table.copy(cysts, parents, true)
    Shared.SortEntitiesByDistance(origin, parents)
    
    -- Filter out invalid parents
    for i = #parents, 1, -1 do
        local parent = parents[i]
        local removeEntry = false

        if parent:isa("Hive") then
            removeEntry = not parent:GetIsBuilt()
        elseif parent:isa("Cyst") then
            removeEntry = not parent:GetIsConnected()
        else
            Log("Unknown parent type: " .. EntityToString(parent))
        end

        removeEntry = removeEntry or not parent:GetIsAlive()
        if removeEntry then
            table.remove(parents, i)
        end
    end
    
    return parents
    
end

-- Temporarily don't use "target" attach point
function Cyst:GetEngagementPointOverride()
    return self:GetOrigin() + Vector(0, 0.2, 0)
end

function Cyst:GetIsHealableOverride()
  return self:GetIsAlive() and self:GetIsConnected()
end

function Cyst:PerformActivation(techId, position, normal, commander)

    if techId == kTechId.Rupture and self:GetMaturityLevel() == kMaturityLevel.Mature then
    
        CreateEntity(Rupture.kMapName, self:GetOrigin(), self:GetTeamNumber())
        self.bursted = true
        self.timeBursted = Shared.GetTime()
        self:ResetMaturity()
        
        return true, true
        
    end
    
    return false, true
    
end

local function UpdateRedeployCircle(self, display)

    if not self.redeployCircleModel then
    
        self.redeployCircleModel = Client.CreateRenderModel(RenderScene.Zone_Default)
        self.redeployCircleModel:SetModel(Commander.kAlienCircleModelName)
        local coords = Coords.GetLookIn(self:GetOrigin() + Vector(0, kZFightingConstant, 0), Vector.xAxis)
        coords:Scale((kCystRedeployRange + Cyst.kRedeployBias) * 2)
        self.redeployCircleModel:SetCoords(coords)
        
    end
    
    self.redeployCircleModel:SetIsVisible(display)
    
end

function Cyst:OnUpdateRender()

    PROFILE("Cyst:OnUpdateRender")
    
    local model = self:GetRenderModel()
    if model then
    

        model:SetMaterialParameter("connected", self.connectedFraction)
        
        model:SetMaterialParameter("killWarning", self.markAsPotentialRedeploy and 1 or 0)
        
        UpdateRedeployCircle(self, self.markAsPotentialRedeploy or false)
        
        self.markAsPotentialRedeploy = false
        
    end
    
end

function Cyst:OverrideHintString(hintString)

    if not self:GetIsConnected() then
        return "CYST_UNCONNECTED_HINT"
    end
    
    return hintString
    
end

local kCystTraceStartPoint =
{
    Vector(0.2, 0.3, 0.2),
    Vector(-0.2, 0.3, 0.2),
    Vector(0.2, 0.3, -0.2),
    Vector(-0.2, 0.3, -0.2),

}

local kDownVector = Vector(0, -1, 0)

local function GetCystDowntraceTrace(origin, collisionRep, physicsMask, filter)

    local startPoint = origin + Vector(0,  1.0, 0)
    local endPoint = origin + Vector(0, -6.0, 0)

    for i = 0, 5 do
        local traceBoxVector = Vector(0.1,0.1,0.1)
        local groundTrace = Shared.TraceBox(traceBoxVector, startPoint, endPoint,  collisionRep, physicsMask, EntityFilterAllButIsa("TechPoint"))

        -- First trace is for the building placement check (don't go throw map tiny holes or stairs)
        if groundTrace.fraction < 1 then

            local distToFloor = startPoint:GetDistanceTo(groundTrace.endPoint)
            local traceFrom = startPoint + Vector(0, -distToFloor + 0.25, 0)
            local traceTo = traceFrom + Vector(0, -0.75, 0)
            local preciseTrace = Shared.TraceRay(traceFrom, traceTo, collisionRep, physicsMask, filter)

            -- Second check is to get the exact ground offset
            if preciseTrace.fraction < 1 then
                return true, preciseTrace
            end
        end

        startPoint = startPoint + Vector(0.01, 0.01, 0.01)
        endPoint = endPoint + Vector(0.01, 0.01, 0.01)
    end

    return false, nil
end

function AlignCyst(coords, normal)

    if Server and normal then
    
        -- get average normal:
        for _, startPoint in ipairs(kCystTraceStartPoint) do
        
            local startTrace = coords:TransformPoint(startPoint)

            local success, trace = GetCystDowntraceTrace(startTrace, CollisionRep.Select, PhysicsMask.CommanderBuild, EntityFilterAll())
            if success and trace.fraction ~= 1 then
                normal = normal + trace.normal
            end
        
        end
        
        normal:Normalize()

        coords.yAxis = normal
        coords.xAxis = coords.yAxis:CrossProduct(coords.zAxis)
        coords.zAxis = coords.xAxis:CrossProduct(coords.yAxis)

    end
    
    return coords

end

function Cyst:SetIncludeRelevancyMask(includeMask)

    includeMask = bit.bor(includeMask, kRelevantToTeam2Commander)    
    ScriptActor.SetIncludeRelevancyMask(self, includeMask)    

end

local kBestLength = 20
local kPointOffset = Vector(0, 0.1, 0)
local kParentSearchRange = 400


local function IsPathable(position)

    local kExtents = Vector(0.4, 0.5, 0.4)
    local noBuild = Pathing.GetIsFlagSet(position, kExtents, Pathing.PolyFlag_NoBuild)
    local walk = Pathing.GetIsFlagSet(position, kExtents, Pathing.PolyFlag_Walk)
    return not noBuild and walk

end

-- Takes a position (vector), and returns the path from the given position to the closest connected
-- parent (connected cyst or hive).
-- returns: PointArray path
--          Entity parent
function FindPathToClosestParent(origin, teamNumber)

    PROFILE("Cyst:FindPathToClosestParent")

    teamNumber = teamNumber or kAlienTeamType
    
    local currentPathLength = 100000
    local closestConnectedPathLength = 100000
    
    local currentPath = PointArray()

    local closestParent, closestConnectedParent
    local maxValidParentTry = 10 -- Maximum number of valid parents we test to pick the closest path
    
    if not IsPathable(origin) then
        return currentPath, nil
    end

    local parents = GetSortedListOfPotentialParents(origin, teamNumber, kParentSearchRange, kParentSearchRange)
    for i = 1, #parents do
    
        local parent = parents[i]
        
        if true then -- Parent is always valid, check done by GetSortedListOfPotentialParents()
        
            local pathLength = 0
            local isReachable, path = CreateBetween(parent:GetOrigin(), parent:GetCoords().yAxis, origin, kPointOffset)

            if parent:GetOrigin():GetDistanceTo(origin) > currentPathLength then
                break
            end
            
            pathLength = GetPointDistance(path)
            
            -- 600 is enough to cover most maps from one end to an other
            if isReachable and 0 < #path and #path < 600 and pathLength < 600
            then

                maxValidParentTry = math.max(0, maxValidParentTry - 1)
                if pathLength < currentPathLength then

                currentPath = path
                currentPathLength = pathLength
                closestParent = parent
                
            end            
            end
        
        
        end
    
        if maxValidParentTry == 0 then
            break
    end
    
    end
    
    return currentPath, closestParent

end

function GetCystParentAvailable(techId, origin, normal, commander)

    PROFILE("Cyst:GetCystParentAvailable")

    local teamNumber = commander and commander:GetTeamNumber() or kAlienTeamType
    local parents = GetEntitiesForTeamWithinRange("Cyst", teamNumber, origin, kParentSearchRange)
    table.copy(GetEntitiesForTeamWithinRange("Hive", teamNumber, origin, kParentSearchRange), parents, true)
    
    return #parents > 0

end

function GetCystPoints_GetPrettyPrintStr(splitPoints, existing)
    local logMsg = ""
    for i = 1, #splitPoints do
        logMsg = logMsg .. " -> " .. ((existing and existing[i]) and "(EC)" or "(C)")
    end
    return logMsg
end
    
function GetCystPoints_AddPointAtValues(splitPoints, normals, existing, exist, insertIndex, point, normal)
    insertIndex = (insertIndex or (#splitPoints + 1))
    -- Shift all existing offset if needed
    for i = #splitPoints, insertIndex, -1 do
        if existing[i] then
            existing[i + 1] = existing[i]
            existing[i] = nil
        end
    end

    table.insert(splitPoints, insertIndex, point)
    table.insert(normals, insertIndex, normal)

    if exist then
        existing[insertIndex] = true
    end
end

function GetCystPoints_AddPointAt(origin, splitPoints, normals, existing, exist, insertIndex)
    -- Insert a cyst point into @splitPoints and @normals
    PROFILE("Cyst:GetCystPoints_AddPointAt")

    local success, trace = GetCystDowntraceTrace(origin, CollisionRep.Default, PhysicsMask.CystBuild, EntityFilterAllButIsa("TechPoint"))

    if success and trace.fraction < 1 then
        GetCystPoints_AddPointAtValues(splitPoints, normals, existing, exist, insertIndex,
                                       trace.endPoint, trace.normal)
        return true, "No error"
    end

    return false, "Shared.TraceRay() failed (no valid point found)"
end

function GetCystPoints_AddSrcDstCyst(path, splitPoints, normals, existing, teamNumber)
    -- Add first/last point of the chain into @splitPoints
    -- If the last point is too close to a cyst, don't recreate it (mark as existing, don't destroy it)
    PROFILE("Cyst:GetCystPoints_AddSrcDstCyst")

    local distToReuse = 1.50
    local rval, rmsg = true, "No error"
    local srcOrig, dstOrig  = path[1], path[#path]
    local cystAroundSrc     = GetEntitiesForTeamWithinRange("Cyst", teamNumber, srcOrig, distToReuse)
    local cystAroundDst     = GetEntitiesForTeamWithinRange("Cyst", teamNumber, dstOrig, distToReuse)

    if #cystAroundSrc == 0 then
        cystAroundSrc = GetEntitiesForTeamWithinRange("Hive", teamNumber, srcOrig, distToReuse)
    end
    if #cystAroundDst == 0 then
        cystAroundDst = GetEntitiesForTeamWithinRange("Hive", teamNumber, dstOrig, distToReuse)
    end

    Shared.SortEntitiesByDistance(srcOrig, cystAroundSrc)
    Shared.SortEntitiesByDistance(dstOrig, cystAroundDst)

    local cystAtSrc     = (#cystAroundSrc > 0 and cystAroundSrc[1] or nil)
    local cystAtDst     = (#cystAroundDst > 0 and cystAroundDst[1] or nil)
    local srcPointOrig  = cystAtSrc and cystAtSrc:GetOrigin() or srcOrig
    local dstPointOrig  = cystAtDst and cystAtDst:GetOrigin() or dstOrig

    rval, rmsg = GetCystPoints_AddPointAt(srcPointOrig, splitPoints, normals, existing, cystAtSrc ~= nil)
    if rval then
        rval, rmsg = GetCystPoints_AddPointAt(dstPointOrig, splitPoints, normals, existing, cystAtDst ~= nil)
    end
    return rval, rmsg
end

function GetCystPoints_AddExistingCysts(path, splitPoints, normals, existing, teamNumber)
    -- Follow path and add existing cysts along it we can reuse for the given chain

    PROFILE("Cyst:GetCystPoints_AddExistingCysts")

    -- Area around a pathing point below which we reuse it
    local cystSearchRange = kCystRedeployRange + 1
    local function _isCystInOurWay(cyst, path, i)
        if i + 1 <= #path and cyst:GetOrigin():GetDistanceTo(path[i]) <= cystSearchRange then
            local dist1 = GetPathDistance(path[i], cyst:GetOrigin())
            local dist2 = dist1 <= cystSearchRange and GetPathDistance(path[i + 1], cyst:GetOrigin())

            return dist1 <= cystSearchRange and dist2 < dist1
        end
        return false
    end

    local rval, rmsg = true, "No error"
    local cystFound = false
    local cystsFound = {}
    local currentDist = 0

    for i = 2, #path do
        local cysts = GetEntitiesForTeamWithinRange("Cyst", teamNumber, path[i], kCystRedeployRange + 1)

        if #cysts > 0 then
            Shared.SortEntitiesByDistance(path[i], cysts)
            for _, cyst in ipairs(cysts)
            do
                if cyst:GetIsAlive() and not cystsFound[cyst] and _isCystInOurWay(cyst, path, i) then
                    cystsFound[cyst] = true
                    rval, rmsg = GetCystPoints_AddPointAt(cyst:GetOrigin(), splitPoints, normals,
                                                          existing, true, #splitPoints)
                    if not rval then
                        return rval, rmsg
                    end
                    break
                end
            end
            currentDist = 0
        end

        currentDist = currentDist + path[i - 1]:GetDistanceTo(path[i])
    end

    return rval, rmsg
end

function GetCystPoints_BuildInBetweenCysts(path, splitPoints, normals, existing, teamNumber)
    -- Build a cyst chain along @path excluding the first and the final point.

    PROFILE("Cyst:GetCystPoints_BuildInBetweenCysts")

    local rval, rmsg = true, "No error"

    local maxDistance = kCystMaxParentRange - 1.5
    local minDistance = kCystRedeployRange - 1
    
    local pathLength = GetPointDistance(path)
    
    -- number of cysts needed for the new path, exluding the first and last cyst
    local requiredCystCount = math.ceil(pathLength / maxDistance)
    
    -- a nice, even distance to spread the cysts out.  This is more desirable as opposed to having
    -- every cyst its maximum distance from its parent until the very end of the chain.
    local evenDistance = pathLength / requiredCystCount
    
    local fromPoint = Vector(path[1])
    local distance = 0
    local totalDistance = 0
        local currentDistance = 0
        
    for i = 2, #path do

        local point = path[i]
        
            if #splitPoints > 20 then
            rval, rmsg = false, "split points exceeded 20 ("
                .. "#path:" .. tostring(#path) .. ", "
                .. "pathDist:" .. tostring(pathLength)
                .. ")"
            break
            end
        
        distance = (path[i] - path[i - 1]):GetLength()
        nextDistance = 0
        if i + 1 <= #path then
            nextDistance = (path[i + 1] - path[i]):GetLength()
        end
            
        totalDistance   = totalDistance   + distance
        currentDistance = currentDistance + distance
                
        if currentDistance < minDistance and currentDistance + nextDistance >= maxDistance then
            if cystChainDebug then
                Log("Pathing not smooth, two points are seperated by " .. tostring(nextDistance) .. "m (too much)")
                end
        end
                
        -- Add a cyst to the chain once we got past the maxDistance
        -- Ensure also that the next distance is never going past our max.
        -- (otherwise we could have unconnected cyst due to the pathing not being smooth enough by default)
        if currentDistance > evenDistance or currentDistance + nextDistance >= maxDistance then
            rval, rmsg = GetCystPoints_AddPointAt(point, splitPoints, normals, existing, false)
            if not rval then
                break
            end
                
            -- Safety check to ensure the pathing is not failing us and that we are not placing
            -- multiple cysts at the same place due to that.
            -- This can happen in Kodiak when cysting from HangarBay into the map corner below on the right
            local distFromLastPoint = fromPoint:GetDistanceTo(splitPoints[#splitPoints])
            if distFromLastPoint <= 1 then
                rval, rmsg = false, "Weird path with two points seperated by more than "
                    .. string.format("%.2f", currentDistance) .. "m (according to the pathing distance) "
                    .. "but only " .. string.format("%.2f", distFromLastPoint)
                    .. "m when comparing the final origins ("
                    .. "#path:" .. tostring(#path) .. ", "
                    .. "pathDist:" .. tostring(pathLength) .. ")"
                break
            end
                
            fromPoint = splitPoints[#splitPoints]
            -- currentDistance = (fromPoint - point):GetLength()
            currentDistance = math.max(0, currentDistance - evenDistance)
        end
            
        -- +1 to exclude the last cyst dropping
        if #splitPoints + 1 == requiredCystCount then
            break
                end
    end
                
    return rval, rmsg
end
                
function GetCystPoints_FixCystChain(path, splitPoints, normals, existing, teamNumber)
    PROFILE("Cyst:GetCystPoints_FixCystChain")
                
    -- Check if each point is connected (otherwise add X fixup cysts inbetween)
    local isReachable, subPath = false, nil
    local rval, rmsg = true, "No error"
    local nbPointsBefore = #splitPoints
                
    for i = #splitPoints, 2, -1 do
        local pointSrc, pointDst = splitPoints[i - 1], splitPoints[i]
        local normalSrc, normalDst = normals[i - 1], normals[i]
        local subSplitPoints, subNormals = {}, {}

        -- Note: Ensure Cyst_Server.lua is using the same check as Cyst.lua for if a cyst is connected
        isReachable, subPath = CreateBetween(pointSrc, normalSrc, pointDst, normalDst)

        if not isReachable then
            rval, rmsg = false, "FixCystChain: a cyst in the chain is unreacheable"
            break
            end
            
        if GetPointDistance(subPath) >= kCystMaxParentRange then
        

            rval, rmsg = GetCystPoints_BuildInBetweenCysts(subPath, subSplitPoints, subNormals, nil, teamNumber)

            if not rval then
                break
        end
    
            for j = 1, #subSplitPoints do
                GetCystPoints_AddPointAtValues(splitPoints, normals, existing, false, i + (j - 1),
                                               subSplitPoints[j], subNormals[j])
    end
        end
    end
    
    return rval, rmsg
end
    
function GetCystPoints_RemoveExistingCysts(path, splitPoints, normals, existing, teamNumber)
    -- Remove existing cysts added to the chain if they are not needed by the caller
    PROFILE("Cyst:GetCystPoints_RemoveExistingCysts")

    local toRemoveIdx = {}

    for i = 1, #splitPoints do
        if existing[i] then
            table.insert(toRemoveIdx, i)
            existing[i] = nil
end
    end

    for i = 1, #toRemoveIdx do
        table.remove(splitPoints, toRemoveIdx[i] - (i - 1))
        table.remove(normals,     toRemoveIdx[i] - (i - 1))
    end
    return true, "No error"
end

function GetCystPoints_CountExistingCysts(path, splitPoints, normals, existing, teamNumber)
    local nbExisting = 0

    PROFILE("Cyst:GetCystPoints_CountExistingCystss")
    for i = 1, #splitPoints do
        nbExisting = nbExisting + (existing[i] and 1 or 0)
    end
    return nbExisting
end

-- Takes a position (vector) and gives us where cysts should go between this position and
-- the closest connected cyst or hive. (first position is the parent's position!!!)
-- Returns: splitPoints -- a list of positions for the new cysts
--          parent -- the parent cyst it is connecting to
--          normals -- the normal vectors of the cysts (ie on flat ground == straight-up)
--          nbExisting -- the number of existing cyst the return points are composed of
--          existing -- the map of splitPoints indexes who are existing cysts
local lastLogMsgPrinted = ""
function GetCystPoints(origin, includeExistingCyst, teamNumber)
    PROFILE("Cyst:GetCystPoints")

    local rval, rmsg = true, "No error"

    local splitPoints = {}
    local normals = {}
    local existing = {}
    local nbExisting = 0
    local path, parent = PointArray(), nil

    if not IsPathable(origin) then
        rmsg = "origin("
            .. string.format("%.3f", origin.x) .. ", "
            .. string.format("%.3f", origin.y) .. ", "
            .. string.format("%.3f", origin.z) .. ") is not pathable"
        if cystChainDebug then
            Log("GetCystPoints(,"
                    .. tostring(includeExistingCyst) .. "," .. tostring(teamNumber) .. ") error: " .. rmsg)
        end
        return {}, nil, {}, 0, {}
    else
        path, parent = FindPathToClosestParent(origin)
    end

    teamNumber = teamNumber or kAlienTeamType
    if parent and #path > 0 then
        if rval then rval, rmsg = GetCystPoints_AddSrcDstCyst(path, splitPoints, normals, existing, teamNumber) end
        if rval then rval, rmsg = GetCystPoints_AddExistingCysts(path, splitPoints, normals, existing, teamNumber) end
        if rval then rval, rmsg = GetCystPoints_FixCystChain(path, splitPoints, normals, existing, teamNumber) end
        if rval then
            if not includeExistingCyst then
                rval, rmsg = GetCystPoints_RemoveExistingCysts(path, splitPoints, normals, existing, teamNumber)
            else
                nbExisting = GetCystPoints_CountExistingCysts(path, splitPoints, normals, existing, teamNumber)
            end
        end
    else
        rval, rmsg = false, string.format("%s%s", (parent and "" or "No parent found. "), (#path > 0 and "" or "Path not found (unreachable)."))
    end

    if rval then
        if cystChainDebug then
            local logMsg = GetCystPoints_GetPrettyPrintStr(splitPoints, existing)

            if not Client or lastLogMsgPrinted ~= logMsg then
                lastLogMsgPrinted = logMsg
                Log("GetCystPoints(," .. tostring(includeExistingCyst) .. "," .. tostring(teamNumber) .. ") " .. logMsg)
            end
        end
        return splitPoints, parent, normals, nbExisting, existing
    end

    if cystChainDebug then
        Log("GetCystPoints(," .. tostring(includeExistingCyst) .. "," .. tostring(teamNumber) .. ") error: " .. rmsg)
    end
    return {}, nil, {}, 0, {}
end

function Cyst:GetCanCatalyzeHeal()
    return true
end

function Cyst:GetInfestationRateMultiplier(growing)
    if not growing then
        return Cyst.kInfestationRecideRateMultiplier
    end

    return Cyst.kInfestationGrowRateMultiplier
end


Shared.LinkClassToMap("Cyst", Cyst.kMapName, networkVars)

Event.Hook("Console_cchain_debug", CystChainToggleDebug)

Event.Hook("Console_cyst_placement_bias", OnCommandCystBias)
