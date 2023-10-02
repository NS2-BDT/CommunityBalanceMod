-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\PowerPoint.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- Every room has a power point in it, which starts built. It is placed on the wall, around
-- head height. When a power point is taking damage, lights nearby flicker. When a power point
-- is at 35% health or lower, the lights cycle dramatically. When a power point is destroyed,
-- the lights go completely black and all marine structures power down 5 long seconds later, the
-- aux. power comes on, fading the lights back up to ~%35. When down, the power point has
-- ambient electricity flowing around it intermittently, hinting at function. Marines can build
-- the power point by +using it, MACs can build it as well. When it comes back on, all
-- structures power back up and start functioning again and lights fade back up.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/AchievementGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/CorrodeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/PowerSourceMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/ParasiteMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")


local kDefaultUpdateRange = 100

if Client then

    -- The default update range; if the local player is inside this range from the powerpoint, the
    -- lights will update. As the lights controlled by a powerpoint can be located quite far from the powerpoint,
    -- and the area lit by the light even further, this needs to be set quite high.
    -- The powerpoint cycling is also very efficient, so there is no need to keep it low from a performance POV.
    
    function UpdatePowerPointLights()
    
        PROFILE("PowerPoint:UpdatePowerPointLights")
        
        -- Now update the lights every frame
        local player = Client.GetLocalPlayer()
        if player then
        
            local playerPos = player:GetOrigin()
            local range = kDefaultUpdateRange

            if player:isa("Commander") then
                range = range * 10
            end

            local powerPoints = GetEntitiesWithinRange("PowerPoint", playerPos, range)
            
            for i = 1, #powerPoints do

                local powerPoint = powerPoints[i]
                powerPoint:UpdatePoweredLights()
                
            end
            
        end
        
    end
    
end

class 'PowerPoint' (ScriptActor)

if Client then
    Script.Load("lua/PowerPoint_Client.lua")
end

PowerPoint.kMapName = "power_point"

local kUnsocketedSocketModelName = PrecacheAsset("models/system/editor/power_node_socket.model")
local kUnsocketedAnimationGraph

local kSocketedModelName = PrecacheAsset("models/system/editor/power_node.model")
PrecacheAsset("models/marine/powerpoint_impulse/powerpoint_impulse.dds")
PrecacheAsset("models/marine/powerpoint_impulse/powerpoint_impulse.material")
PrecacheAsset("models/marine/powerpoint_impulse/powerpoint_impulse.model")

local kSocketedAnimationGraph = PrecacheAsset("models/system/editor/power_node.animation_graph")

local kDamagedEffect = PrecacheAsset("cinematics/common/powerpoint_damaged.cinematic")
local kOfflineEffect = PrecacheAsset("cinematics/common/powerpoint_offline.cinematic")

local kTakeDamageSound = PrecacheAsset("sound/NS2.fev/marine/power_node/take_damage")
local kDamagedSound = PrecacheAsset("sound/NS2.fev/marine/power_node/damaged")
local kDestroyedSound = PrecacheAsset("sound/NS2.fev/marine/power_node/destroyed")
local kDestroyedPowerDownSound = PrecacheAsset("sound/NS2.fev/marine/power_node/destroyed_powerdown")
local kAuxPowerBackupSound = PrecacheAsset("sound/NS2.fev/marine/power_node/backup")

PowerPoint.kDestroyedMaterial = PrecacheAsset("models/system/editor/power_node_destroyed.material")
PowerPoint.kCriticalDamageMaterial = PrecacheAsset("models/system/editor/power_node_damaged.material")

PowerPoint.kDamagedDongleElectricity = PrecacheAsset("cinematics/common/powernode_dongle_elec.cinematic")
PowerPoint.kDongleAttachmentPoint = "PowerNode_ExtndrNPlug"

PrecacheAsset("shaders/PowerNode_emissive.surface_shader")

PowerPoint.kDamagedPercentage = 0.4

-- Re-build only possible when X seconds have passed after destruction (when aux power kicks in)
local kDestructionBuildDelay = 15

-- The amount of time that must pass since the last time a PP was attacked until
-- the team will be notified. This makes sure the team isn't spammed.
local kUnderAttackTeamMessageLimit = 5

-- max amount of "attack" the powerpoint has suffered (?)
local kMaxAttackTime = 10

local kMinFullLightDelay = 2
local kFullPowerOnTime = 4
local kMaxFullLightDelay = 4

PowerPoint.kPowerState = enum( { "unsocketed", "socketed", "destroyed" } )

local networkVars =
{
    lightMode = "enum kLightMode",
    powerState = "enum PowerPoint.kPowerState",
    timeOfLightModeChange = "time",
    timeOfDestruction  = "time",
    timeLastConstruct = "time",
    attackTime = "float (0 to " .. (kMaxAttackTime + 0.1) .. " by 0.01)",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(CorrodeMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(PowerSourceMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)

local function SetupWithInitialSettings(self)

    self.lightMode = kLightMode.Normal
    self.powerState = PowerPoint.kPowerState.socketed

    self:SetModel(kSocketedModelName, kSocketedAnimationGraph)

    self.health = 0
    self.armor = 0

    self.timeOfDestruction = 0

    if Server then

        self.startsBuilt = self.startSocketed
        self.attackTime = 0.0

    elseif Client then

        self.unchangingLights = {}
        self.lightFlickers = {}

    end

end

function PowerPoint:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin, { kPlayFlinchAnimations = true })
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, AchievementGiverMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, PowerSourceMixin)
    InitMixin(self, NanoShieldMixin)
    InitMixin(self, WeldableMixin)
    InitMixin(self, ParasiteMixin)
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
    
    self.lightMode = kLightMode.Normal
    self.powerState = PowerPoint.kPowerState.unsocketed
    
    if Client then 
        self:AddTimedCallback(PowerPoint.OnTimedUpdate, kUpdateIntervalLow)
    end
    
    SetupWithInitialSettings(self)
    
end

function PowerPoint:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    if Server then
    
        -- PowerPoints always belong to the Marine team.
        self:SetTeamNumber(kTeam1Index)
        
        -- extend relevancy range as the powerpoint plays with lights around itself, so
        -- the effects of a powerpoint are visible far beyond the normal relevancy range
        self:SetRelevancyDistance(kDefaultUpdateRange + 20)
        
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
    end
    
    InitMixin(self, IdleMixin)
    
end

function PowerPoint:RequirePrimedNodes()
    return false
end

function PowerPoint:GetRecentlyDestroyed()
    return (self.timeOfDestruction + kDestructionBuildDelay) > Shared.GetTime()
end

function PowerPoint:GetReceivesStructuralDamage()
    return true
end

function PowerPoint:GetDamagedAlertId()
    return kTechId.MarineAlertStructureUnderAttack
end

function PowerPoint:GetCanPower(consumer)
    return self:GetLocationId() == consumer:GetLocationId()
end

function PowerPoint:GetCanTakeDamageOverride()
    return self.powerState ~= PowerPoint.kPowerState.unsocketed and self:GetHealth() > 0
end

--
-- Only allow nano shield on the PowerPoint when it is socketed.
--
function PowerPoint:GetCanBeNanoShieldedOverride(resultTable)
    resultTable.shieldedAllowed = resultTable.shieldedAllowed and self:GetPowerState() == PowerPoint.kPowerState.socketed and self:GetIsBuilt()
end

function PowerPoint:GetWeldPercentageOverride()

    if self:GetPowerState() == PowerPoint.kPowerState.unsocketed then
        return 0
    end
    
    return self:GetHealthScalar()
    
end

function PowerPoint:GetHealthbarOffset()
    return 0.8
end 

function PowerPoint:GetCanBeHealedOverride()
    return
        self:GetPowerState() ~= PowerPoint.kPowerState.unsocketed and
        (self.timeOfDestruction + kDestructionBuildDelay) < Shared.GetTime()
end

function PowerPoint:GetTechButtons()

    local techButtons = { }
    
    if self:GetPowerState() == PowerPoint.kPowerState.unsocketed then
        techButtons = { kTechId.SocketPowerNode }
    end
    
    return techButtons
    
end

function PowerPoint:PerformActivation(techId, position, normal, commander)

    if techId == kTechId.SocketPowerNode then
    
        self:SocketPowerNode()
        return true, true
        
    end
    
    return false, true
    
end

function PowerPoint:SocketPowerNode()

    assert(self.powerState == PowerPoint.kPowerState.unsocketed)
    
    self.buildFraction = 0
    self.constructionComplete = false
    self:SetInternalPowerState(PowerPoint.kPowerState.socketed)
    
    if GetGamerules():GetAutobuild() then
        self:SetConstructionComplete()
    end
    
end

function PowerPoint:GetPowerState()
    return self.powerState
end

local function HasConsumerRequiringPower_Internal( self, onlyBuilt )

    for _, chair in ientitylist( Shared.GetEntitiesWithClassname("CommandStation") ) do
        if chair:GetLocationId() == self:GetLocationId() 
            and ( not onlyBuilt or chair:GetIsBuilt() ) 
        then
            return true
        end
    end
    
    local consumers = GetEntitiesWithMixin("PowerConsumer")
    Shared.SortEntitiesByDistance(self:GetOrigin(), consumers)
    for _, consumer in ipairs(consumers) do
        if self:GetCanPower( consumer ) and consumer:GetRequiresPower() and consumer.GetIsBuilt and ( not onlyBuilt or consumer:GetIsBuilt() ) then
            return true
        end
    end

    return false
    
end

function PowerPoint:HasUnbuiltConsumerRequiringPower()
    PROFILE("PowerPoint:HasUnbuiltConsumerRequiringPower")
    return HasConsumerRequiringPower_Internal( self, false )
end

function PowerPoint:HasConsumerRequiringPower()
    PROFILE("PowerPoint:HasConsumerRequiringPower")
    return HasConsumerRequiringPower_Internal( self, true )
end

function PowerPoint:GetCanConstructOverride( player )
    local isBuildable = not self:GetIsBuilt() and self:GetPowerState() ~= PowerPoint.kPowerState.unsocketed and GetAreFriends(player,self)
    return isBuildable
end

function PowerPoint:GetIsDisabled()
    return self:GetPowerState() == PowerPoint.kPowerState.destroyed
end

function PowerPoint:GetIsSocketed()
    return self:GetPowerState() ~= PowerPoint.kPowerState.unsocketed
end

function PowerPoint:SetLightMode(lightMode)
    
    if self:GetIsDisabled() then
        lightMode = kLightMode.NoPower
    end
    
    local time = Shared.GetTime()
    
    if self.lastLightMode == kLightMode.NoPower and lightMode == kLightMode.Damaged then
        local fullFullLightTime = self.timeOfLightModeChange + kMinFullLightDelay + kMaxFullLightDelay + kFullPowerOnTime    
        if time < fullFullLightTime then
            -- Don't allow the light mode to change to damaged until after the power is fully restored
            return
        end
    end

    -- Don't change light mode too often or lights will change too much
    if self.lightMode ~= lightMode or (not self.timeOfLightModeChange or (time > (self.timeOfLightModeChange + 1.0))) then
        self.lastLightMode, self.lightMode = self.lightMode, lightMode        
        self.timeOfLightModeChange = time
    end
    
end

function PowerPoint:GetIsMapEntity()
    return true
end

function PowerPoint:GetLightMode()
    return self.lightMode
end

function PowerPoint:GetTimeOfLightModeChange()
    return self.timeOfLightModeChange
end

function PowerPoint:GetCanBeUsed(player, useSuccessTable)

    if player:isa("Exo") then
        useSuccessTable.useSuccess = false
        return
    end

    useSuccessTable.useSuccess = not self:GetRecentlyDestroyed() and self.powerState ~= PowerPoint.kPowerState.unsocketed and (not self:GetIsBuilt() or (self:GetIsBuilt() and self:GetHealthScalar() < 1))
end

function PowerPoint:GetCanBeUsedConstructed()
    return self.powerState == PowerPoint.kPowerState.destroyed
end

-- Disallow usage/construction during warmup as that introduces usability issues
function PowerPoint:GetCanBeUsedDuringWarmup()
    return false
end

function PowerPoint:OverrideVisionRadius()
    return 2
end

function PowerPoint:GetAttackTime()
    return self.attackTime
end

function PowerPoint:OverrideCheckVision()
    return self:GetHealth() > 0 and self:GetAttackTime() > 0
end

function PowerPoint:OverrideCheckVisibilty(viewer)
    -- If the other entity is not visible then we cannot see it.
    if not self:GetIsVisible() then
        return false
    end

    if GetAreEnemies(self, viewer) and not self:GetCanTakeDamage() then
        return false
    end

    -- Check if this entity is beyond our vision radius.
    local maxDist = viewer:GetVisionRadius()
    local dist = (self:GetOrigin() - viewer:GetOrigin()):GetLengthSquared()
    if dist > (maxDist * maxDist) then
        return false
    end

    -- If viewer is close enough they can see us see it no matter what
    if dist < (kStructureLOSDistance * kStructureLOSDistance) then
        return true
    end

    return GetCanSeeEntity(viewer, self)
end

function PowerPoint:GetCanBeWeldedOverride(player)
    return not self:GetRecentlyDestroyed() and self:GetPowerState() ~= PowerPoint.kPowerState.unsocketed and self:GetHealthScalar() < 1, true
end

function PowerPoint:GetRecentlyRepaired()
    return self.timeOfNextBuildWeldEffects ~= nil and (math.abs(Shared.GetTime() - self.timeOfNextBuildWeldEffects) < 5)
end

function PowerPoint:GetTechAllowed(techId, techNode, player)
    return true, true
end


function PowerPoint:OnUse(player, elapsedTime, useSuccessTable)

    local success = false
    if player:isa("Marine") then
        if self:GetIsBuilt() and self:GetHealthScalar() < 1 then
    
            if Server then
                -- exclude the welder, as the welding is performed elsewhere.
                -- Doing it here will double up the effect.
                local activeWeapon = player:GetActiveWeapon()
                if activeWeapon:GetMapName() ~= Welder.kMapName then
                    self:OnWeld(player, elapsedTime)
                end
            end
            success = true
            
            if player.OnConstructTarget then
                player:OnConstructTarget(self)
            end

        end
    end
    
    useSuccessTable.useSuccess = useSuccessTable.useSuccess or success
    
end

if Server then

    local function PowerUp(self)

        self:SetInternalPowerState(PowerPoint.kPowerState.socketed)
        self:SetLightMode(kLightMode.Normal)
        self:StopSound(kAuxPowerBackupSound)
        self:TriggerEffects("fixed_power_up")
        self:SetPoweringState(true)

        --Ensure rebuilt (infested, destroyed, rebuilt, still in infestation range) nodes are updated
        self:InfestationNeedsUpdate()

    end
    
    -- Repaired by marine with welder or MAC
    function PowerPoint:OnWeldOverride(entity, elapsedTime)

        local welded = false

        -- Marines can repair power points
        if entity:isa("Welder") then

            local amount = kWelderPowerRepairRate * elapsedTime
            welded = (self:AddHealth(amount) > 0)

        elseif entity:isa("MAC") then

            welded = self:AddHealth(MAC.kRepairHealthPerSecond * elapsedTime) > 0

        else

            local amount = kBuilderPowerRepairRate * elapsedTime
            welded = (self:AddHealth(amount) > 0)

        end

        if self:GetHealthScalar() > self.kDamagedPercentage then

            self:StopDamagedSound()

            if self:GetLightMode() == kLightMode.LowPower and self:GetIsPowering() then
                self:SetLightMode(kLightMode.Normal)
            end

        end

        if self:GetPowerState() == PowerPoint.kPowerState.destroyed then
            if self:GetHealthScalar() == 1 then

                self:StopDamagedSound()
                self.health = kPowerPointHealth
                self.armor = kPowerPointArmor
                self:SetMaxHealth(kPowerPointHealth)
                self:SetMaxArmor(kPowerPointArmor)
                self.alive = true

                PowerUp(self)
            else
                --Required here as in this state PowerPoint doesn't "read" as infestable (aka, it's dead, Jim)
                self:InfestationNeedsUpdate()
            end
        end

        if welded then
            self:AddAttackTime(-0.1)
        end

    end
    
    function PowerPoint:GetDestroyMapBlipOnKill()
        return false
    end
    
    function PowerPoint:OnConstructionComplete()

        self:StopDamagedSound()
        
        self.health = kPowerPointHealth
        self.armor = kPowerPointArmor
        
        self:SetMaxHealth(kPowerPointHealth)
        self:SetMaxArmor(kPowerPointArmor)
        
        self.alive = true
        
        PowerUp(self)
        
    end
    
    function PowerPoint:SetInternalPowerState(powerState)
    
        -- Let the team know if power is back online.
        if self.powerState == PowerPoint.kPowerState.destroyed and powerState == PowerPoint.kPowerState.socketed then
        
            SendTeamMessage(self:GetTeam(), kTeamMessageTypes.PowerRestored, self:GetLocationId())
            self:MarkBlipDirty()
            
        end
        
        -- Mark the mapblip dirty when switching from unsocketed to socketed so we can see the change
        if self.powerState == PowerPoint.kPowerState.unsocketed and powerState == PowerPoint.kPowerState.socketed and self.MarkBlipDirty then
            self:MarkBlipDirty()
        end
        
        self.powerState = powerState
        
        local modelToLoad = kSocketedModelName
        local graphToLoad = kSocketedAnimationGraph
        
        if powerState == PowerPoint.kPowerState.unsocketed then
        
            modelToLoad = kUnsocketedSocketModelName
            graphToLoad = kUnsocketedAnimationGraph
            
        end
        
        self:SetModel(modelToLoad, graphToLoad)
        
    end
    
    function PowerPoint:StopDamagedSound()
    
        if self.playingLoopedDamaged then
        
            self:TriggerEffects("powerpoint_damaged_loop_stop")
            self.playingLoopedDamaged = false
            
        end
        
    end
    
    -- send a message every kUnderAttackTeamMessageLimit seconds when a base power node is under attack
    local function CheckSendDamageTeamMessage(self)

        if not self.timePowerNodeAttackAlertSent or self.timePowerNodeAttackAlertSent + kUnderAttackTeamMessageLimit < Shared.GetTime() then

            -- Check if there is a built Command Station in the same location as this PowerPoint.
            local foundStation = false
            local stations = GetEntitiesForTeam("CommandStation", self:GetTeamNumber())
            for s = 1, #stations do
            
                local station = stations[s]
                if station:GetIsBuilt() and station:GetLocationName() == self:GetLocationName() then
                    foundStation = true
                end
                
            end
            
            -- Only send the message if there was a CommandStation found at this same location.
            if foundStation then
                SendTeamMessage(self:GetTeam(), kTeamMessageTypes.PowerPointUnderAttack, self:GetLocationId())
                self:GetTeam():TriggerAlert(kTechId.MarineAlertStructureUnderAttack, self, true)
            end
            
            self.timePowerNodeAttackAlertSent = Shared.GetTime()
            
        end
        
    end
    
    function PowerPoint:DoDamageLighting()
        if self.powerState == PowerPoint.kPowerState.socketed then
            local healthScalar = self:GetHealthScalar()
            if healthScalar < self.kDamagedPercentage then
                self:SetLightMode(kLightMode.LowPower)
            else
                self:SetLightMode(kLightMode.Damaged)
            end
        end
        self:AddAttackTime(0.9)
    end
    
    function PowerPoint:OnTakeDamage(damage, attacker, doer, direction, damageType, preventAlert)

        -- Sync build fraction with health scalar
        local healthScalar = self:GetHealthScalar()
        self.buildTime = healthScalar * self:GetTotalConstructionTime()
        self.buildFraction = healthScalar

        if not self:GetIsBuilt() then
            return
        end
        
        if self.powerState == PowerPoint.kPowerState.socketed and damage > 0 then
        
            self:DoDamageLighting()

            self:PlaySound(kTakeDamageSound)
            
            if healthScalar < self.kDamagedPercentage then
                
                if not self.playingLoopedDamaged then
                
                    self:TriggerEffects("powerpoint_damaged_loop")
                    self.playingLoopedDamaged = true
                    
                end
                
            end
            
            if not preventAlert then
                CheckSendDamageTeamMessage(self)
            end
            
        end
        
    end
    
    local function PlayAuxSound(self)
    
        if not self:GetIsDisabled() then
            self:PlaySound(kAuxPowerBackupSound)
        end
        
    end
    
    function PowerPoint:OnKill(attacker, doer, point, direction)
    
        ScriptActor.OnKill(self, attacker, doer, point, direction)
        
        self:StopDamagedSound()
        
        self:MarkBlipDirty()
        
        self:PlaySound(kDestroyedSound)
        self:PlaySound(kDestroyedPowerDownSound)
        
        self:SetInternalPowerState(PowerPoint.kPowerState.destroyed)
        
        self:SetLightMode(kLightMode.NoPower)
        
        -- Remove effects such as parasite when destroyed.
        self:ClearGameEffects()

        if attacker and attacker:isa("Player") and GetEnemyTeamNumber(self:GetTeamNumber()) == attacker:GetTeamNumber() then
            attacker:AddScore(self:GetPointValue())
        end
        
        -- Let the team know the power is down.
        SendTeamMessage(self:GetTeam(), kTeamMessageTypes.PowerLost, self:GetLocationId())
        
        -- A few seconds later, switch on aux power.
        self:AddTimedCallback(PlayAuxSound, 4)
        self.timeOfDestruction = Shared.GetTime()
        
    end
    
    function PowerPoint:Reset()
    
        SetupWithInitialSettings(self)
        
        ScriptActor.Reset(self)
        
        self:MarkBlipDirty()
        
    end
    
    function PowerPoint:GetSendDeathMessageOverride()
        return self:GetIsPowering()
    end
    
    function PowerPoint:AddAttackTime(value)
        self.attackTime = Clamp(self.attackTime + value, 0, kMaxAttackTime)
    end
    
end

function PowerPoint:OnUpdateAnimationInputLiveMixinOverride(modelMixin)
    PROFILE("PowerPoint:OnUpdateAnimationInputLiveMixinOverride")
    modelMixin:SetAnimationInput( "alive", not self:GetIsBuilt() or self:GetIsAlive() )
end

local function CreateEffects(self)

    -- Create looping cinematics if we're low power or no power
    local lightMode = self:GetLightMode() 
    local model = self:GetRenderModel()
    local destroyed = self:GetIsBuilt() and not self:GetIsAlive()
    local criticalDamage = lightMode == kLightMode.LowPower
    local isBuilt = self:GetIsBuilt()

    if model then
        if destroyed then
            model:SetOverrideMaterial( 0, PowerPoint.kDestroyedMaterial )
        elseif criticalDamage and isBuilt then
            model:SetOverrideMaterial( 0, PowerPoint.kCriticalDamageMaterial )
        else
            model:ClearOverrideMaterials()
        end
    end

    if lightMode == kLightMode.LowPower and not self.lowPowerEffect and isBuilt then
    
        self.lowPowerEffect = Client.CreateCinematic(RenderScene.Zone_Default)
        self.lowPowerEffect:SetCinematic(kDamagedEffect)
        self.lowPowerEffect:SetRepeatStyle(Cinematic.Repeat_Loop)
        self.lowPowerEffect:SetCoords(self:GetCoords())
        
    elseif lightMode == kLightMode.NoPower and ( not self.noPowerEffect and not self.noPowerDongleEffect ) and isBuilt and not self:GetRecentlyDestroyed() then
        
        self.noPowerEffect = Client.CreateCinematic(RenderScene.Zone_Default)
        self.noPowerEffect:SetCinematic(kOfflineEffect)
        self.noPowerEffect:SetRepeatStyle(Cinematic.Repeat_Loop)
        self.noPowerEffect:SetCoords(self:GetCoords())

        self.noPowerDongleEffect = Client.CreateCinematic(RenderScene.Zone_Default)
        self.noPowerDongleEffect:SetCinematic(PowerPoint.kDamagedDongleElectricity)
        self.noPowerDongleEffect:SetParent(self)
        self.noPowerDongleEffect:SetCoords(Coords.GetIdentity())
        self.noPowerDongleEffect:SetAttachPoint( self:GetAttachPointIndex(PowerPoint.kDongleAttachmentPoint) )
        self.noPowerDongleEffect:SetRepeatStyle(Cinematic.Repeat_Loop)

    end
    
    if self:GetPowerState() == PowerPoint.kPowerState.socketed and self:GetIsBuilt() and self:GetIsVisible() then
    
        if self.lastImpulseEffect == nil then
            self.lastImpulseEffect = Shared.GetTime() - PowerPoint.kImpulseEffectFrequency
        end
        
        if self.lastImpulseEffect + PowerPoint.kImpulseEffectFrequency < Shared.GetTime() then
        
            self:CreateImpulseEffect()
            self.createStructureImpulse = true
            
        end
        
        if self.lastImpulseEffect + 1 < Shared.GetTime() and self.createStructureImpulse == true then
        
            self:CreateImpulseStructureEffect()
            self.createStructureImpulse = false
            
        end
        
    end
    
end

local function DeleteEffects(self)

    local lightMode = self:GetLightMode() 
    
    if lightMode ~= kLightMode.LowPower and self.lowPowerEffect then
    
        Client.DestroyCinematic(self.lowPowerEffect)
        self.lowPowerEffect = nil
        self.timeCreatedLowPower = nil
        
    end
    
    if lightMode ~= kLightMode.NoPower and ( self.noPowerEffect or self.noPowerDongleEffect) then
    
        Client.DestroyCinematic(self.noPowerEffect)
        Client.DestroyCinematic(self.noPowerDongleEffect)
        self.noPowerEffect = nil
        self.noPowerDongleEffect = nil
        self.timeCreatedNoPower = nil
        
    end
    
end

if Server then
    function PowerPoint:OnUpdate(deltaTime)

        self:AddAttackTime(-0.1)
        
        if self:GetLightMode() == kLightMode.Damaged and self:GetAttackTime() == 0 then
            self:SetLightMode(kLightMode.Normal)
        end
                
    end
end

if Client then
    function PowerPoint:OnTimedUpdate(deltaTime)
        CreateEffects(self)
        DeleteEffects(self)
        return true
    end
end


function PowerPoint:CanBeWeldedByBuilder()
    return self:GetHealthScalar() < 1 and self.powerState == PowerPoint.kPowerState.destroyed
end

function PowerPoint:GetCanBeUsedDead()
    return true
end

function PowerPoint:GetShowUnitStatusForOverride(forEntity)
    if GetAreEnemies(self, forEntity) then
        return self:GetCanTakeDamage()
    end

    return self:GetIsBuilt() or self:GetCanTakeDamage() or self:HasUnbuiltConsumerRequiringPower()
end

local kPowerPointTargetOffset = Vector(0, 0.3, 0)
function PowerPoint:GetEngagementPointOverride()
    return self:GetCoords():TransformPoint(kPowerPointTargetOffset)
end

-- Starts with 0% hp, other structures start with an offset
function PowerPoint:GetStartingHealthScalar()
    return 0
end

-- Can only die after it has been built
function PowerPoint:GetCanDieOverride()
    return self:GetIsBuilt()
end

function PowerPoint:OnGetIsSelectableOveride(result, byTeamNumber)
    local isSelectable = result.selectable

    if self:GetTeamNumber() ~= byTeamNumber then
        return isSelectable and self:GetCanTakeDamage()
    end

    return isSelectable
end

Shared.LinkClassToMap("PowerPoint", PowerPoint.kMapName, networkVars)
