-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Shared.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- Put any classes that are used on both the client and server here.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

math.randomseed(Shared.GetSystemTime())
-- math.random() is more random the more you call it. Don't ask.
for i = 1, 100 do math.random() end

Script.Load("lua/HotloadTools.lua")

Script.Load("lua/JITConsoleCommands.lua")

Script.Load("lua/Locale.lua")

-- Utility and constants
Script.Load("lua/Globals.lua")
Script.Load("lua/DamageTypes.lua")
Script.Load("lua/Debug.lua")
Script.Load("lua/CollisionRep.lua")
Script.Load("lua/Utility.lua")
Script.Load("lua/PlayerInput.lua")
Script.Load("lua/Seasons.lua")

Script.Load("lua/MixinUtility.lua")
Script.Load("lua/AnimatedModel.lua")
Script.Load("lua/Vector.lua")
Script.Load("lua/Entity.lua")
Script.Load("lua/Effects.lua")
Script.Load("lua/NetworkMessages.lua")
Script.Load("lua/TechTreeConstants.lua")
Script.Load("lua/TechData.lua")
Script.Load("lua/TechNode.lua")
Script.Load("lua/TechTree.lua")
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Order.lua")
Script.Load("lua/PropDynamic.lua")
Script.Load("lua/Blip.lua")
Script.Load("lua/MapBlip.lua")
Script.Load("lua/ParticleEffect.lua")
Script.Load("lua/SensorBlip.lua")
Script.Load("lua/SoundEffect.lua")
Script.Load("lua/TrackYZ.lua")
Script.Load("lua/TeamMessenger.lua")
Script.Load("lua/TokenBucket.lua")
Script.Load("lua/RingBuffer.lua")
Script.Load("lua/BuildUtility.lua")

Script.Load("lua/Balance.lua")
Script.Load("lua/BalanceHealth.lua")
Script.Load("lua/BalanceMisc.lua")

Script.Load("lua/TeamJoin.lua")

Script.Load("lua/PulseEffect.lua") -- Create a pulsing highlight effect on an entity.
Script.Load("lua/Camera.lua") -- used for creating camera animations in tutorial.
Script.Load("lua/AreaTrigger.lua") -- used for monitoring regions in the tutorial.

-- Neutral structures
Script.Load("lua/ResourcePoint.lua")
Script.Load("lua/ResourceTower.lua")
Script.Load("lua/Door.lua")
Script.Load("lua/Reverb.lua")
Script.Load("lua/Location.lua")
Script.Load("lua/Trigger.lua")
Script.Load("lua/Ladder.lua")
Script.Load("lua/MinimapExtents.lua")
Script.Load("lua/DeathTrigger.lua")
Script.Load("lua/EventTarget.lua")
Script.Load("lua/TeleportTrigger.lua")
Script.Load("lua/TeleportDestination.lua")
Script.Load("lua/TimedEmitter.lua")
Script.Load("lua/ButtonEmitter.lua")
Script.Load("lua/AmbientSoundPlayer.lua")
Script.Load("lua/PropDynamicAnimator.lua")

Script.Load("lua/thunderdome/ThunderdomeForceField.lua")

Script.Load("lua/Gamerules.lua")
Script.Load("lua/NS2Gamerules.lua")
Script.Load("lua/ConcedeSequence.lua")
Script.Load("lua/TechPoint.lua")
Script.Load("lua/BaseSpawn.lua")
Script.Load("lua/ReadyRoomSpawn.lua")
Script.Load("lua/Pheromone.lua")
Script.Load("lua/Weapons/ViewModel.lua")

-- Marine structures
Script.Load("lua/MAC.lua")
Script.Load("lua/BattleMAC.lua")
Script.Load("lua/Mine.lua")
Script.Load("lua/Extractor.lua")
Script.Load("lua/Armory.lua")
Script.Load("lua/ArmsLab.lua")
Script.Load("lua/Observatory.lua")
Script.Load("lua/PhaseGate.lua")
Script.Load("lua/RoboticsFactory.lua")
Script.Load("lua/PrototypeLab.lua")
Script.Load("lua/CommandStructure.lua")
Script.Load("lua/CommandStation.lua")
Script.Load("lua/Sentry.lua")
Script.Load("lua/ARC.lua")
Script.Load("lua/DIS.lua")
Script.Load("lua/InfantryPortal.lua")
Script.Load("lua/DropPack.lua")
Script.Load("lua/AmmoPack.lua")
Script.Load("lua/MedPack.lua")
Script.Load("lua/CatPack.lua")
Script.Load("lua/ServerParticleEmitter.lua")

-- Alien Comm Abilities
Script.Load("lua/CommAbilities/Alien/CragUmbra.lua")
Script.Load("lua/CommAbilities/Alien/ShadeInk.lua")

-- Alien structures
Script.Load("lua/Harvester.lua")
Script.Load("lua/Infestation.lua")
Script.Load("lua/Hive.lua")
Script.Load("lua/EvolutionChamber.lua")
Script.Load("lua/Shell.lua")
Script.Load("lua/Crag.lua")
Script.Load("lua/WhipBomb.lua")
Script.Load("lua/Whip.lua")
Script.Load("lua/Veil.lua")
Script.Load("lua/Shift.lua")
Script.Load("lua/Spur.lua")
Script.Load("lua/Shade.lua")
Script.Load("lua/Hydra.lua")
Script.Load("lua/TunnelEntrance.lua")
Script.Load("lua/Clog.lua")
Script.Load("lua/Cyst.lua")
Script.Load("lua/Egg.lua")
Script.Load("lua/Embryo.lua")
Script.Load("lua/Hallucination.lua")
Script.Load("lua/Weapons/Alien/Web.lua")

Script.Load("lua/Babbler.lua")
Script.Load("lua/BabblerEgg.lua")

-- Base players
Script.Load("lua/PlayerInfoEntity.lua")
Script.Load("lua/ReadyRoomPlayer.lua")
Script.Load("lua/Spectator.lua")
Script.Load("lua/FilmSpectator.lua")
Script.Load("lua/AlienSpectator.lua")
Script.Load("lua/MarineSpectator.lua")
Script.Load("lua/Ragdoll.lua")
Script.Load("lua/MarineCommander.lua")
Script.Load("lua/AlienCommander.lua")

-- Character class behaviors
Script.Load("lua/Marine.lua")
Script.Load("lua/JetpackMarine.lua")
Script.Load("lua/Exosuit.lua") -- pickupable version
Script.Load("lua/Exo.lua")
Script.Load("lua/Skulk.lua")
Script.Load("lua/Gorge.lua")
Script.Load("lua/Lerk.lua")
Script.Load("lua/Fade.lua")
Script.Load("lua/Onos.lua")

Script.Load("lua/AlienHallucination.lua")
Script.Load("lua/Drifter.lua")
Script.Load("lua/DrifterEgg.lua")

Script.Load("lua/ReadyRoomExo.lua")
Script.Load("lua/ReadyRoomEmbryo.lua")

-- Weapons
Script.Load("lua/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/Weapons/Marine/Rifle.lua")
Script.Load("lua/Weapons/Marine/HeavyMachineGun.lua")
Script.Load("lua/Weapons/Marine/Pistol.lua")
Script.Load("lua/Weapons/Marine/Shotgun.lua")
Script.Load("lua/Weapons/Marine/Axe.lua")
Script.Load("lua/Weapons/Marine/Minigun.lua")
Script.Load("lua/Weapons/Marine/Railgun.lua")
Script.Load("lua/Weapons/Marine/Claw.lua")
Script.Load("lua/Weapons/Marine/GrenadeLauncher.lua")
Script.Load("lua/Weapons/Marine/Flamethrower.lua")
Script.Load("lua/Weapons/Marine/LayMines.lua")
Script.Load("lua/Weapons/Marine/Builder.lua")
Script.Load("lua/Weapons/Marine/Welder.lua")
Script.Load("lua/Weapons/Marine/Submachinegun.lua")
Script.Load("lua/Jetpack.lua")

Script.Load("lua/Weapons/CandyThrower.lua")
Script.Load("lua/Weapons/SnowBallThrower.lua")

local GRENADES_ENABLED = true -- false
if GRENADES_ENABLED then

    Script.Load("lua/Weapons/Marine/GasGrenadeThrower.lua")
    Script.Load("lua/Weapons/Marine/ClusterGrenadeThrower.lua")
    Script.Load("lua/Weapons/Marine/PulseGrenadeThrower.lua")
    Script.Load("lua/Weapons/Marine/GasGrenade.lua")
    Script.Load("lua/Weapons/Marine/PulseGrenade.lua")
    Script.Load("lua/Weapons/Marine/ClusterGrenade.lua")
    
end

Script.Load("lua/PowerPoint.lua")
Script.Load("lua/SentryBattery.lua")
Script.Load("lua/NS2Utility.lua")
Script.Load("lua/WeaponUtility.lua")
Script.Load("lua/TeamInfo.lua")
Script.Load("lua/GameInfo.lua")
Script.Load("lua/AlienTeamInfo.lua")
Script.Load("lua/MarineTeamInfo.lua")
Script.Load("lua/PathingUtility.lua")
Script.Load("lua/HotloadConsole.lua")
Script.Load("lua/ServerPerformanceData.lua")
Script.Load("lua/bots/PlayerBot.lua")

Script.Load("lua/HitSounds.lua")

Script.Load("lua/DebugUtils.lua")

gHeightMap = gHeightMap -- survive hotloading; will be nil the first time

local function LoadHeightmap()

    -- Load height map
    gHeightMap = HeightMap()   
    local heightmapFilename = string.format("maps/overviews/%s.hmp", Shared.GetMapName())
    
    if not gHeightMap:Load(heightmapFilename) then
        Shared.Message("Couldn't load height map " .. heightmapFilename)
        gHeightMap = nil
    end

end

local function OnMapPostLoad()
    LoadHeightmap()
end

function GetHeightmap()
    return gHeightMap
end

--
-- Called when two physics bodies collide.
--
function OnPhysicsCollision(body1, body2)

    local entity1 = body1 and body1:GetEntity()
    local entity2 = body2 and body2:GetEntity()
    
    if entity1 and entity1.OnCollision then
        entity1:OnCollision(entity2)
    end
    
    if entity2 and entity2.OnCollision then
        entity2:OnCollision(entity1)
    end

end

-- Set the callback function when there's a collision
Event.Hook("PhysicsCollision", OnPhysicsCollision)

--
-- Called when one physics body enters into a trigger body.
--
function OnPhysicsTrigger(enterObject, triggerObject, enter)

    PROFILE("Shared:OnPhysicsTrigger")

    local enterEntity   = enterObject:GetEntity()
    local triggerEntity = triggerObject:GetEntity()
    
    if enterEntity ~= nil and triggerEntity ~= nil then
    
        if (enter) then
        
            if (enterEntity.OnTriggerEntered ~= nil) then
                enterEntity:OnTriggerEntered(enterEntity, triggerEntity)
            end
            
            if (triggerEntity.OnTriggerEntered ~= nil) then
                triggerEntity:OnTriggerEntered(enterEntity, triggerEntity)
            end
            
        else
        
            if (enterEntity.OnTriggerExited ~= nil) then
                enterEntity:OnTriggerExited(enterEntity, triggerEntity)
            end
            
            if (triggerEntity.OnTriggerExited ~= nil) then
                triggerEntity:OnTriggerExited(enterEntity, triggerEntity)
            end
            
        end
        
    end

end

-- Set the callback functon when there's a trigger
Event.Hook("PhysicsTrigger", OnPhysicsTrigger)

-- turn on to show outline of view box trace.
Shared.DbgTraceViewBox = false

--
-- Support view aligned box traces. The world-axis aligned box traces doesn't work as soon as you have the
-- least tilt or yaw on the box (such as placing structures on tilted surfaces (like walls). This is a
-- better-than-nothing replacement until engine support comes along.
--
-- The view aligned box places the view along the z-axis. You specify the x,y extents, the roll around the z-axis and
-- the start and endpoints.
--
-- 9 traces are used, one on each corner, one in the middle of each side and one in the middle.
--
-- A possible expansion would be to add more traces for larger boxes to keep an upper limit of the size of a missed object.
--
-- It returns a trace look-alike (ie a table containing an endPoint, fraction and normal)
--
function Shared.TraceViewBox(x, y, roll, startPoint, endPoint, mask, filter)

    -- find the shortest trace of the 9 traces that we are going to do
    local shortestTrace

    -- first start by doing a simple ray trace though the middle
    local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Default, mask, filter)
    if trace.fraction < 1 then
        shortestTrace = trace
    end 
    if Shared.DbgTraceViewBox then
        DebugLine(startPoint,trace.endPoint,30,trace.fraction < 1 and 1 or 0,1,0,1)
    end

    local coords = Coords.GetLookIn(startPoint, endPoint - startPoint)
    local angles = Angles()
    angles:BuildFromCoords(coords)
    angles.roll = roll
    coords = angles:GetCoords()

    for dx =-1,1 do
        for dy = -1,1 do
            local v1 = Vector(dx * x,dy * y, 0)
            local p1 = startPoint + coords:TransformVector(v1)
            local p2 = endPoint + coords:TransformVector(v1)
            trace = Shared.TraceRay(p1, p2, CollisionRep.Default, mask, filter)
            if trace.fraction < 1 then
                if shortestTrace == nil or shortestTrace.fraction > trace.fraction then
                    shortestTrace = trace
                end
            end
            if Shared.DbgTraceViewBox then
                DebugLine(p1,trace.endPoint,30,trace.fraction < 1 and 1 or 0,1,0,1)
            end
        end 
    end
    
    local makeResult = function(fraction, endPoint, normal, entity)
        return { fraction=fraction, endPoint=endPoint, normal=normal, entity=entity }
    end
    
    if shortestTrace then 
        return makeResult(shortestTrace.fraction, startPoint + (endPoint - startPoint) * shortestTrace.fraction, shortestTrace.normal, shortestTrace.entity)
    end
    -- Make the normal non-nil to be consistent with the engine's trace results.
    return makeResult(1, endPoint, Vector.yAxis)
    
end


Event.Hook("MapPostLoad", OnMapPostLoad)

local function HandleDbgValue(index, value)
    index = tonumber(index)
    if index then
        if value then
            if value == "''" then
                value = "" -- need a way to input empty string
            end
            local number = tonumber(value)
            if number then
                Shared.Debug_SetNumber(index, number)
            else
                Shared.Debug_SetString(index, value)
            end
        end
        Log("dbg_value[%s] = %s/'%s'", index, Shared.Debug_GetNumber(index), Shared.Debug_GetString(index))
    else
        Log("dbg_value <index> (<number or string value> - string value can be '' for empty string)") 
        for index=0,Shared.Debug_GetNumValues()-1 do
            Log("dbg_value[%s] = %s/'%s'", index, Shared.Debug_GetNumber(index), Shared.Debug_GetString(index))                      
        end
    end
end


if Client then
    local function OnConsoleDbgValue(index, value)
        HandleDbgValue(index, value)
        return true
    end
    Event.Hook("Console_dbg_value", OnConsoleDbgValue)
elseif Server then
    local function OnConsoleDbgValue(client, index, value)
        if client == nil then
            HandleDbgValue(index,value)
        end
    end
  
    Event.Hook("Console_dbg_value", OnConsoleDbgValue)
end

local function OnMapPreLoad()
   
    UpdateMapForSeasons()
    
    Shared.PreLoadSetGroupNeverVisible(kCollisionGeometryGroupName)   
    Shared.PreLoadSetGroupNeverVisible(kMovementCollisionGroupName)   
    Shared.PreLoadSetGroupNeverVisible(kInvisibleCollisionGroupName)
    Shared.PreLoadSetGroupPhysicsId(kNonCollisionGeometryGroupName, 0)

    Shared.PreLoadSetGroupNeverVisible(kCommanderBuildGroupName)   
    Shared.PreLoadSetGroupPhysicsId(kCommanderBuildGroupName, PhysicsGroup.CommanderBuildGroup)      
    
    -- Any geometry in kCommanderInvisibleGroupName or kCommanderNoBuildGroupName shouldn't interfere with selection or other commander actions
    Shared.PreLoadSetGroupPhysicsId(kCommanderInvisibleGroupName, PhysicsGroup.CommanderPropsGroup)
    Shared.PreLoadSetGroupPhysicsId(kCommanderInvisibleVentsGroupName, PhysicsGroup.CommanderPropsGroup)
    Shared.PreLoadSetGroupPhysicsId(kCommanderInvisibleNonCollisionGroupName, 0)
    Shared.PreLoadSetGroupPhysicsId(kCommanderNoBuildGroupName, PhysicsGroup.CommanderPropsGroup)
    
    -- Don't have bullets collide with collision geometry
    Shared.PreLoadSetGroupPhysicsId(kCollisionGeometryGroupName, PhysicsGroup.CollisionGeometryGroup)
    Shared.PreLoadSetGroupPhysicsId(kMovementCollisionGroupName, PhysicsGroup.CollisionGeometryGroup)
    
    -- Pathing mesh
    Shared.PreLoadSetGroupNeverVisible(kPathingLayerName)
    Shared.PreLoadSetGroupPhysicsId(kPathingLayerName, PhysicsGroup.PathingGroup)
    
end

Shared.Debug_InitializeValues()

Event.Hook("MapPreLoad", OnMapPreLoad)

-- %%% New CBM Functions %%% --
--Script.Load("lua/Weapons/Marine/ExoWelder.lua")
Script.Load("lua/Weapons/Marine/ExoFlamer.lua")
-- Script.Load("lua/Weapons/Marine/ExoShield.lua")
Script.Load("lua/Weapons/Marine/PlasmaLauncher.lua")
--Script.Load("lua/ModularExos/WeaponCache.lua")
--Script.Load("lua/ModularExos/ExoWeapons/MarineStructureAbility.lua")

Script.Load("lua/Exo.lua")
Script.Load("lua/Weapons/ModularExo_Data.lua")
Script.Load("lua/NetworkMessages.lua")

function ModularExo_ConvertNetMessageToConfig(message)
    return {
        -- [kExoModuleSlots.PowerSupply] = message.powerModuleType    or kExoModuleTypes.None,
        [kExoModuleSlots.LeftArm]  = message.leftArmModuleType or kExoModuleTypes.None,
        [kExoModuleSlots.RightArm] = message.rightArmModuleType or kExoModuleTypes.None,
        [kExoModuleSlots.Utility]  = message.utilityModuleType or kExoModuleTypes.None,
        [kExoModuleSlots.Ability]  = message.abilityModuleType or kExoModuleTypes.None,
    }
end

function ModularExo_ConvertConfigToNetMessage(config)
    return {
        -- powerModuleType    = config[kExoModuleSlots.PowerSupply] or kExoModuleTypes.None,
        leftArmModuleType  = config[kExoModuleSlots.LeftArm] or kExoModuleTypes.None,
        rightArmModuleType = config[kExoModuleSlots.RightArm] or kExoModuleTypes.None,
        utilityModuleType  = config[kExoModuleSlots.Utility] or kExoModuleTypes.None,
        abilityModuleType  = config[kExoModuleSlots.Ability] or kExoModuleTypes.None,
    }
end

function ModularExo_GetIsConfigValid(config)
    local resourceCost = 0
    --   local powerCost = 0
    --  local powerSupply = nil -- We don't know yet
    local leftArmType = nil
    local rightArmType = nil
    for slotType, slotTypeData in pairs(kExoModuleSlotsData) do
        local moduleType = config[slotType]
        if moduleType == nil or moduleType == kExoModuleTypes.None then
            if slotTypeData.required then
                -- The config MUST give a module type for this slot type
                return false, "missing required slot" -- not a valid config
            else
                -- This slot type is optional, so it's OK to leave it out
            end
        else
            -- The config has module type for this slot type
            local moduleTypeData = kExoModuleTypesData[moduleType]
            if moduleTypeData == nil or moduleTypeData.category ~= slotTypeData.category then
                -- They have provided the wrong category of module type for this slot type
                -- For example, an armor module in a weapon slot
                return false, "wrong slot type" -- not a valid config
            end
            
            --if kMarineTeamType and moduleTypeData.requiredTechId and not GetIsTechResearched(kMarineTeamType, moduleTypeData.requiredTechId) then
            --     return false, "tech not researched"
            --end
            
            if moduleTypeData.resourceCost then
                resourceCost = resourceCost + moduleTypeData.resourceCost
            end
            
            if slotType == kExoModuleSlots.LeftArm then
                leftArmType = moduleTypeData.armType
            elseif slotType == kExoModuleSlots.RightArm then
                rightArmType = moduleTypeData.armType
            end
        end
    end
    -- Ok, we've iterated over certain module types and it seems OK
    
    local exoTexturePath = nil
    local modelDataForRightArmType = kExoWeaponRightLeftComboModels[rightArmType]
    if not modelDataForRightArmType.isValid then
        -- This means we don't have model data for the situation where the arm type is on the right
        -- Which means, this isn't a valid config! (e.g: claw selected for right arm)
        return false, "bad model right"
    else
        local modelData = modelDataForRightArmType[leftArmType]
        if not modelData.isValid then
            -- The left arm type is not supported for the given right arm type
            return false, "bad model left"
        else
            -- This combo of right and left arm types is supported!
            exoTexturePath = modelData.imageTexturePath
        end
    end
    
    if GetGameInfoEntity and GetGameInfoEntity() and GetGameInfoEntity():GetWarmUpActive() then
        resourceCost = 0
    end
    
    -- This config is valid
    -- Return true, to indicate that
    -- Also return the power supply and power cost, in case the GUI needs those values
    -- Also return the image texture path, in case the GUI needs that!
    return true, nil, resourceCost, exoTexturePath
end

function ModularExo_GetConfigWeight(config)
    local weight = 0
    for slotType, slotTypeData in pairs(kExoModuleSlotsData) do
        local moduleType = config[slotType]
        if moduleType and moduleType ~= kExoModuleTypes.None then
            local moduleTypeData = kExoModuleTypesData[moduleType]
            if moduleTypeData then
                weight = weight + (moduleTypeData.weight or 0)
            end
        end
    end
    return weight
end

function ModularExo_GetConfigArmor(config)
    local armorBonus = 0
    for slotType, slotTypeData in pairs(kExoModuleSlotsData) do
        local moduleType = config[slotType]
        if moduleType and moduleType ~= kExoModuleTypes.None then
            local moduleTypeData = kExoModuleTypesData[moduleType]
            if moduleTypeData then
                armorBonus = armorBonus + (moduleTypeData.armorValue or 0)
            end
        end
    end
    return armorBonus
end

