-- ======= Copyright (c) 2003-2010, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\NetworkMessages.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- See the Messages section of the Networking docs in Spark Engine scripting docs for details.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Globals.lua")
Script.Load("lua/TechTreeConstants.lua")
Script.Load("lua/VoiceOver.lua")
Script.Load("lua/InsightNetworkMessages.lua")
Script.Load("lua/SharedDecal.lua")
Script.Load("lua/Balance.lua")
Script.Load("lua/menu2/PlayerScreen/CallingCards/GUIMenuCallingCardData.lua")

Script.Load("lua/bots/BotDebuggingNetworkMessages.lua")

local kInitialAlienVisionStateMessage =
{
    startsOn = "boolean"
}
Shared.RegisterNetworkMessage( "InitAVState", kInitialAlienVisionStateMessage)

--==============================================
-- Stats Related Network Messages
--==============================================

local kMarineCommStatsMessage =
{
    medpackAccuracy = "float (0 to 100 by 0.01)",
    medpackResUsed = "integer (0 to 65535)",
    medpackResExpired = "integer (0 to 65535)",
    medpackEfficiency = "float (0 to 100 by 0.01)",
    medpackRefill = "integer (0 to 262143)",
    ammopackResUsed = "integer (0 to 65535)",
    ammopackResExpired = "integer (0 to 65535)",
    ammopackEfficiency = "float (0 to 100 by 0.01)",
    ammopackRefill = "integer (0 to 262143)",
    catpackResUsed = "integer (0 to 65535)",
    catpackResExpired = "integer (0 to 65535)",
    catpackEfficiency = "float (0 to 100 by 0.01)",
}
Shared.RegisterNetworkMessage("GlobalCommStats", kMarineCommStatsMessage)
Shared.RegisterNetworkMessage("MarineCommStats", kMarineCommStatsMessage) -- Only stats for Marine Commander... for now?

local kBuildingSummaryMessage =
{
    teamNumber = "integer (1 to 2)",
    techId = "enum kTechId",
    built = "integer (0 to 255)",
    lost = "integer (0 to 255)",
}
Shared.RegisterNetworkMessage("BuildingSummary", kBuildingSummaryMessage)

local kKillGraphMessage =
{
    killerTeamNumber = "integer (1 to 2)",
    gameMinute = "float (0 to 1023 by 0.01)",
}
Shared.RegisterNetworkMessage("KillGraph", kKillGraphMessage)

local kRTGraphMessage =
{
    teamNumber = "integer (1 to 2)",
    destroyed = "boolean",
    gameMinute = "float (0 to 1023 by 0.01)",
}
Shared.RegisterNetworkMessage("RTGraph", kRTGraphMessage)

local kHiveSkillGraphMessage = {
    gameMinute = "float (0 to 1023 by 0.01)",
    joined = "boolean",
    teamNumber = "integer (1 to 2)",
    steamId = "integer",z
}
Shared.RegisterNetworkMessage("HiveSkillGraph", kHiveSkillGraphMessage)

local kTechLogMessage =
{
    teamNumber = "integer (1 to 2)",
    techId = "enum kTechId",
    finishedMinute = "float (0 to 1023 by 0.01)",
    activeRTs = "integer (0 to 23)",
    teamRes = "float (0 to " .. kMaxTeamResources .." by 0.01)",
    destroyed = "boolean",
    built = "boolean",
    recycled = "boolean",
}
Shared.RegisterNetworkMessage("TechLog", kTechLogMessage)

local kGameDataMessage =
{
    marineAcc = "float (0 to 100 by 0.01)",
    marineOnosAcc = "float (-1 to 100 by 0.01)",
    marineRTsBuilt = "integer (0 to 255)",
    marineRTsLost = "integer (0 to 255)",
    alienAcc = "float (0 to 100 by 0.01)",
    alienRTsBuilt = "integer (0 to 255)",
    alienRTsLost = "integer (0 to 255)",
    gameLengthMinutes = "float (0 to 1023 by 0.01)",
}
Shared.RegisterNetworkMessage("GameData", kGameDataMessage)

local kPlayerStatsMessage =
{
    isMarine = "boolean",
    playerName = string.format("string (%d)", kMaxNameLength * 4 ),
    kills = string.format("integer (0 to %d)", kMaxKills),
    assists = string.format("integer (0 to %d)", kMaxKills),
    deaths = string.format("integer (0 to %d)", kMaxDeaths),
    score = string.format("integer (0 to %d)", kMaxScore),
    accuracy = "float (0 to 100 by 0.01)",
    accuracyOnos = "float (-1 to 100 by 0.01)",
    pdmg = "float (0 to 524287 by 0.01)",
    sdmg = "float (0 to 524287 by 0.01)",
    minutesBuilding = "float (0 to 1023 by 0.01)",
    minutesPlaying = "float (0 to 1023 by 0.01)",
    minutesComm = "float (0 to 1023 by 0.01)",
    killstreak = "integer (0 to 254)",
    steamId = "integer",
    hiveSkill = "integer",
    isRookie = "boolean",
}
Shared.RegisterNetworkMessage("PlayerStats", kPlayerStatsMessage)

local kEndStatsStatusMessage =
{
    statusId = "enum kPlayerStatus",
    timeMinutes = "float (0 to 1023 by 0.01)",
}
Shared.RegisterNetworkMessage("EndStatsStatus", kEndStatsStatusMessage)

local kEndStatsWeaponMessage =
{
    wTechId = "enum kTechId",
    accuracy = "float (0 to 100 by 0.01)",
    accuracyOnos = "float (-1 to 100 by 0.01)",
    kills = string.format("integer (0 to %d)", kMaxKills),
    teamNumber = "integer (1 to 2)",
    pdmg = "float (0 to 524287 by 0.01)",
    sdmg = "float (0 to 524287 by 0.01)",
}
Shared.RegisterNetworkMessage("EndStatsWeapon", kEndStatsWeaponMessage)

local kDeathStatsMessage =
{
    lastAcc = "float (0 to 100 by 0.01)",
    lastAccOnos = "float (-1 to 100 by 0.01)",
    currentAcc = "float (0 to 100 by 0.01)",
    currentAccOnos = "float (-1 to 100 by 0.01)",
    pdmg = "float (0 to 524287 by 0.01)",
    sdmg = "float (0 to 524287 by 0.01)",
    kills = string.format("integer (0 to %d)", kMaxKills),
}
Shared.RegisterNetworkMessage("DeathStats", kDeathStatsMessage)

--=======================================================================

local kDisabledOptionMessage =
{
    disabledOption = "string (32)"
}
Shared.RegisterNetworkMessage("DisabledOption", kDisabledOptionMessage )

local kAlienWeaponUseHUDSlotMessage =
{
    slotMode = "integer (0 to 3)"
}
Shared.RegisterNetworkMessage( "SetAlienWeaponUseHUDSlot", kAlienWeaponUseHUDSlotMessage)

local kAutopickupMessage =
{
    autoPickup = "boolean",
    autoPickupBetter = "boolean",
}
Shared.RegisterNetworkMessage( "SetAutopickup", kAutopickupMessage)

local kServerConfirmedHitEffectsMessage =
{
    serverBlood = "boolean",
}
Shared.RegisterNetworkMessage( "ServerConfirmedHitEffects", kServerConfirmedHitEffectsMessage)

local kCameraShakeMessage =
{
    intensity = "float (0 to 1 by 0.01)"
}

Shared.RegisterNetworkMessage("CameraShake", kCameraShakeMessage)

function BuildCameraShakeMessage(intensity)

    local t = {}
    t.intensity = intensity
    return t

end

function ParseCameraShakeMessage(message)
    return message.intensity
end

local kSelectUnitMessage =
{
    teamNumber = "integer (0 to 4)",
    unitId = "entityid",
    selected = "boolean",
    keepSelection = "boolean"

}

local kCreateDecalMessage =
{
    normal = string.format("integer(1 to %d)", kNumIndexedVectors),
    posx = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    posy = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    posz = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    decalIndex = string.format("integer (1 to %d)", kNumSharedDecals),
    scale = "float (0 to 5 by 0.05)"
}

Shared.RegisterNetworkMessage("CreateDecal", kCreateDecalMessage)

function BuildCreateDecalMessage(normal, position, decalIndex, scale)

    local t = { }
    t.normal = normal
    t.posx = position.x
    t.posy = position.y
    t.posz = position.z
    t.decalIndex = decalIndex
    t.scale = scale
    return t

end

function ParseCreateDecalMessage(message)
    return GetVectorFromIndex(message.normal), Vector(message.posx, message.posy, message.posz), GetDecalMaterialNameFromIndex(message.decalIndex), message.scale
end

function BuildSelectUnitMessage(teamNumber, unit, selected, keepSelection)

    assert(teamNumber)

    local t =  {}
    t.teamNumber = teamNumber
    t.unitId = unit and unit:GetId() or Entity.invalidId
    t.selected = selected == true
    t.keepSelection = keepSelection == true
    return t

end

function ParseSelectUnitMessage(message)
    return message.teamNumber, Shared.GetEntity(message.unitId), message.selected, message.keepSelection
end

local kSetPlayerCallingCardMessage =
{
    callingCard = "enum kCallingCards"
}
Shared.RegisterNetworkMessage("SetPlayerCallingCard", kSetPlayerCallingCardMessage)

local kSetPlayerVariantMessage =
{
    isMale = "boolean",
    marineVariant = "enum kMarineVariants",
    skulkVariant = "enum kSkulkVariants",
    gorgeVariant = "enum kGorgeVariants",
    lerkVariant = "enum kLerkVariants",
    fadeVariant = "enum kFadeVariants",
    onosVariant = "enum kOnosVariants",

    shoulderPadIndex = string.format("integer (0 to %d)", #kShoulderPad2ItemId),
    exoVariant = "enum kExoVariants",
    rifleVariant = "enum kRifleVariants",
    pistolVariant = "enum kPistolVariants",
    axeVariant = "enum kAxeVariants",
    shotgunVariant = "enum kShotgunVariants",
    flamethrowerVariant = "enum kFlamethrowerVariants",
    grenadeLauncherVariant = "enum kGrenadeLauncherVariants",
    welderVariant = "enum kWelderVariants",
    hmgVariant = "enum kHMGVariants",
    macVariant = "enum kMarineMacVariants",
    arcVariant = "enum kMarineArcVariants",
    marineStructuresVariant = "enum kMarineStructureVariants",
    extractorVariant = "enum kExtractorVariants",

    alienStructuresVariant = "enum kAlienStructureVariants",
    harvesterVariant = "enum kHarvesterVariants",
    eggVariant = "enum kEggVariants",
    cystVariant = "enum kAlienCystVariants",
    drifterVariant = "enum kAlienDrifterVariants",
    alienTunnelsVariant = "enum kAlienTunnelVariants",
    clogVariant = "enum kClogVariants",
    hydraVariant = "enum kHydraVariants",
    babblerVariant = "enum kBabblerVariants",
    babblerEggVariant = "enum kBabblerEggVariants",
}
Shared.RegisterNetworkMessage("SetPlayerVariant", kSetPlayerVariantMessage)

function BuildVoiceMessage(voiceId)

    local t = {}
    t.voiceId = voiceId
    return t

end

function ParseVoiceMessage(message)
    return message.voiceId
end

local kVoiceOverMessage =
{
    voiceId = "enum kVoiceId",
}

Shared.RegisterNetworkMessage( "VoiceMessage", kVoiceOverMessage )

local kMaxDamagePerHit = 511
local kHitEffectMessage =
{
    -- TODO: figure out a reasonable precision for the position
    posx = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    posy = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    posz = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    doerId = "entityid",
    surface = "enum kHitEffectSurface",
    targetId = "entityid",
    showtracer = "boolean",
    altMode = "boolean",
    damage = string.format("integer (0 to %d)", kMaxDamagePerHit),
    direction = string.format("integer(1 to %d)", kNumIndexedVectors),
}

function BuildHitEffectMessage(position, doer, surface, target, showtracer, altMode, damage, direction)

    local t = { }
    t.posx = position.x
    t.posy = position.y
    t.posz = position.z
    t.doerId = (doer and doer:GetId()) or Entity.invalidId
    t.surface = (surface and StringToEnum(kHitEffectSurface, surface)) or kHitEffectSurface.metal
    t.targetId = (target and target:GetId()) or Entity.invalidId
    t.showtracer = showtracer == true
    t.altMode = altMode == true
    t.damage = math.min(damage, kMaxDamagePerHit)
    t.direction = direction or 1
    return t

end

function ParseHitEffectMessage(message)

    local position = Vector(message.posx, message.posy, message.posz)
    local doer = Shared.GetEntity(message.doerId)
    local surface = EnumToString(kHitEffectSurface, message.surface)
    local target = Shared.GetEntity(message.targetId)
    local showtracer = message.showtracer
    local altMode = message.altMode
    local damage = message.damage
    local direction = GetVectorFromIndex(message.direction)

    return position, doer, surface, target, showtracer, altMode, damage, direction

end

Shared.RegisterNetworkMessage( "HitEffect", kHitEffectMessage )

kDamageMessageType = enum({ 'Default', 'Boneshield' })
--For damage numbers
local kDamageMessage =
{
    posx = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    posy = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    posz = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    targetId = "entityid",
    amount = "float (0 to 2048 by 0.0625)", -- 1/16, 16 bits total
    type = "enum kDamageMessageType",
}

function BuildDamageMessage(targetEntityId, amount, hitpos, type)

    local t = {}
    t.posx = hitpos.x
    t.posy = hitpos.y
    t.posz = hitpos.z
    t.amount = math.min( math.max( amount, 0 ), 2048 )
    t.targetId = (targetEntityId or Entity.invalidId)
    t.type = type

    return t

end

function ParseDamageMessage(message)
    local position = Vector(message.posx, message.posy, message.posz)
    return message.targetId, message.amount, position, message.type
end

function SendDamageMessage( attacker, targetEntityId, amount, point, overkill, weapon, type ) -- TODO(Salads): Clean this up, two places use weapon arg...

    if amount > 0 then

        local type = type or kDamageMessageType.Default

        local msg = BuildDamageMessage(targetEntityId, amount, point, type)

        -- damage reports must always be reliable when not spectating
        Server.SendNetworkMessage(attacker, "Damage", msg, true)

        for _, spectator in ientitylist(Shared.GetEntitiesWithClassname("Spectator")) do

            if attacker == Server.GetOwner(spectator):GetSpectatingPlayer() then
                Server.SendNetworkMessage(spectator, "Damage", msg, false)
            end

        end

    end

end

Shared.RegisterNetworkMessage( "Damage", kDamageMessage )

local kMarkEnemyMessage =
{
    targetId = "entityid",
    weaponId = "enum kTechId",
}

function BuildMarkEnemyMessage(target, weapon)

    local t = {}
    t.targetId = (target and target:GetId()) or Entity.invalidId
    t.weaponId = weapon
    return t

end

function ParseMarkEnemyMessage(message)
    return Shared.GetEntity(message.targetId), message.weaponId
end

function SendMarkEnemyMessage( attacker, target, amount, weapon )

    if attacker and target and target:isa("Player") and amount > 0 and IsAllowedWeaponToMarkEnemy(weapon) then

        local msg = BuildMarkEnemyMessage(target, weapon)

        -- mark enemy must always be reliable when not spectating
        Server.SendNetworkMessage(attacker, "MarkEnemy", msg, true)

    end

end

Shared.RegisterNetworkMessage( "MarkEnemy", kMarkEnemyMessage )

local kHitSoundMessage =
{
    hitsound = "integer (1 to 3)",
}

function BuildHitSoundMessage( hitsound )

    local t = {}
    t.hitsound = hitsound
    return t

end

function ParseHitSoundMessage(message)
    return message.hitsound
end

Shared.RegisterNetworkMessage( "HitSound", kHitSoundMessage )

--For commander abilities, such as nanoshield
local kAbilityResultMessage =
{
    techId = "enum kTechId",
    success = "boolean",
    castTime = "time",  -- When the ability was cast and succeded. Used for cooldown enforcement.
}

function BuildAbilityResultMessage( techId, success, castTime )

    local t = {}
    t.techId = techId
    t.success = success
    t.castTime = castTime
    return t

end

Shared.RegisterNetworkMessage( "AbilityResult", kAbilityResultMessage )

-- Tell players WHY they can't join a team
local kJoinErrorMessage =
{
    reason = "integer (0 to 3)"
}
function BuildJoinErrorMessage( reason )
    return { reason = reason }
end
Shared.RegisterNetworkMessage( "JoinError", kJoinErrorMessage )

--Used to tell the server that a client has played the tutorial
Shared.RegisterNetworkMessage( "PlayedTutorial", {} )

Shared.RegisterNetworkMessage( "CommanderLoginError", {} )

local kCommanderPingMessage =
{
    position = "vector"
}

function BuildCommanderPingMessage(position)

    local t = {}
    t.position = position
    return t

end

Shared.RegisterNetworkMessage( "CommanderPing", kCommanderPingMessage )

-- From TechNode.kTechNodeVars
local kTechNodeUpdateMessage =
{
    techId                  = "enum kTechId",
    available               = "boolean",
    researchProgress        = "float",
    prereqResearchProgress  = "float",
    researched              = "boolean",
    researching             = "boolean",
    hasTech                 = "boolean"
}

-- Tech node messages. Base message is in TechNode.lua
function BuildTechNodeUpdateMessage(techNode)

    local t = {}

    t.techId                    = techNode.techId
    t.available                 = techNode.available
    t.researchProgress          = techNode.researchProgress
    t.prereqResearchProgress    = techNode.prereqResearchProgress
    t.researched                = techNode.researched
    t.researching               = techNode.researching
    t.hasTech                   = techNode.hasTech

    return t

end

Shared.RegisterNetworkMessage( "TechNodeUpdate", kTechNodeUpdateMessage )

local kMaxPing = 999

local kPingMessage =
{
    clientIndex = "entityid",
    ping = "integer (0 to " .. kMaxPing .. ")"
}

function BuildPingMessage(clientIndex, ping)

    local t = {}

    t.clientIndex       = clientIndex
    t.ping              = math.min(ping, kMaxPing)

    return t

end

function ParsePingMessage(message)
    return message.clientIndex, message.ping
end

Shared.RegisterNetworkMessage( "Ping", kPingMessage )

kWorldTextMessageType = enum({ 'Resources', 'Resource', 'Damage', 'DamageBoneshield', 'CommanderError' })
kWorldTextDamageTypes = set
{
    kWorldTextMessageType.Damage,
    kWorldTextMessageType.DamageBoneshield,
}

local kWorldTextMessage =
{
    messageType = "enum kWorldTextMessageType",
    data = "float",
    position = "vector"
}

function BuildWorldTextMessage(messageType, data, position)

    local t = { }

    t.messageType = messageType
    t.data = data
    t.position = position

    return t

end

Shared.RegisterNetworkMessage("WorldText", kWorldTextMessage)

local kCommanderErrorMessage =
{
    data = "string (48)",
    position = "vector"
}

function BuildCommanderErrorMessage(data, position)

    local t = { }

    t.data = data
    t.position = position

    return t

end

Shared.RegisterNetworkMessage("CommanderError", kCommanderErrorMessage)

-- For idle workers
local kSelectAndGotoMessage =
{
    entityId = "entityid"
}

function BuildSelectAndGotoMessage(entId)
    local t = {}
    t.entityId = entId
    return t
end

function ParseSelectAndGotoMessage(message)
    return message.entityId
end

Shared.RegisterNetworkMessage("SelectAndGoto", kSelectAndGotoMessage)
Shared.RegisterNetworkMessage("ComSelect", kSelectAndGotoMessage)

-- For taking damage
local kTakeDamageIndicator =
{
    worldX = "float",
    worldZ = "float",
    damage = "float"
}

function BuildTakeDamageIndicatorMessage(sourceVec, damage)
    local t = {}
    t.worldX = sourceVec.x
    t.worldZ = sourceVec.z
    t.damage = damage
    return t
end

function ParseTakeDamageIndicatorMessage(message)
    return message.worldX, message.worldZ, message.damage
end

Shared.RegisterNetworkMessage("TakeDamageIndicator", kTakeDamageIndicator)

-- Player id changed
local kEntityChangedMessage =
{
    oldEntityId = "entityid",
    newEntityId = "entityid",
}

function BuildEntityChangedMessage(oldId, newId)

    local t = {}

    t.oldEntityId = oldId
    t.newEntityId = newId

    return t

end

-- Selection
local kMarqueeSelectMessage =
{
    pickStartVec = "vector",
    pickEndVec = "vector",
}

function BuildMarqueeSelectCommand(pickStartVec, pickEndVec)

    local t = {}

    t.pickStartVec = Vector(pickStartVec)
    t.pickEndVec = Vector(pickEndVec)

    return t

end

function ParseCommMarqueeSelectMessage(message)
    return message.pickStartVec, message.pickEndVec
end

local kClickSelectMessage =
{
    pickVec = "vector"
}

function BuildClickSelectCommand(pickVec)

    local t = {}
    t.pickVec = Vector(pickVec)
    return t

end

function ParseCommClickSelectMessage(message)
    return message.pickVec
end

local kCreateHotkeyGroupMessage =
{
    groupNumber = "integer (1 to " .. ToString(kMaxHotkeyGroups) .. ")"
}
function BuildCreateHotkeyGroupMessage(setGroupNumber)

    local t = {}

    t.groupNumber = setGroupNumber

    return t

end

local kSelectHotkeyGroupMessage =
{
    groupNumber = "integer (1 to " .. ToString(kMaxHotkeyGroups) .. ")"
}

function BuildSelectHotkeyGroupMessage(setGroupNumber)

    local t = {}

    t.groupNumber = setGroupNumber

    return t

end

function ParseSelectHotkeyGroupMessage(message)
    return message.groupNumber
end

-- Commander actions
local kCommAction =
{
    techId = "enum kTechId",
    shiftDown = "boolean"
}

function BuildCommActionMessage(techId, shiftDown)

    local t = {}

    t.techId = techId
    t.shiftDown = shiftDown == true

    return t

end

function ParseCommActionMessage(t)
    return t.techId, t.shiftDown
end

local kCommTargetedAction =
{
    techId = "enum kTechId",

    -- normalized pick coords for CommTargetedAction
    -- or world coords for kCommTargetedAction
    x = "float",
    y = "float",
    z = "float",

    orientationRadians  = "angle (11 bits)",
    targetId = "entityid",

    shiftDown = "boolean"
}

function BuildCommTargetedActionMessage(techId, x, y, z, orientationRadians, targetId, shiftDown)

    local t = {}

    t.techId = techId
    t.x = x
    t.y = y
    t.z = z
    t.orientationRadians = orientationRadians
    t.targetId = targetId
    t.shiftDown = shiftDown == true

    return t

end

function ParseCommTargetedActionMessage(t)
    return t.techId, Vector(t.x, t.y, t.z), t.orientationRadians, t.targetId, t.shiftDown
end


local kDangerMusicUpdateMessage =
{
    origin = "vector",
    teamIndex = "integer (" .. kTeam1Index .. " to " .. kTeam2Index .. ")",
    active = "boolean",
}
function ParseDangerMusicUpdateMessage( origin, teamIndex, active ) --is this actually needed?
    local t = {}

    t.origin = origin
    t.teamIndex = teamIndex
    t.active = active

    return t
end


local kGorgeBuildStructureMessage =
{
    origin = "vector",
    direction = "vector",
    structureIndex = "integer (1 to 5)",
    lastClickedPosition = "vector",
    lastClickedPositionNormal = "vector"
}

function BuildGorgeDropStructureMessage(origin, direction, structureIndex, lastClickedPosition, lastClickedPositionNormal)

    local t = {}

    t.origin = origin
    t.direction = direction
    t.structureIndex = structureIndex
    t.lastClickedPosition = lastClickedPosition or Vector(0,0,0)
    t.lastClickedPositionNormal = lastClickedPositionNormal or Vector(0,0,0)

    return t

end

function ParseGorgeBuildMessage(t)
    return t.origin, t.direction, t.structureIndex, t.lastClickedPosition, t.lastClickedPositionNormal
end

local kMutePlayerMessage =
{
    muteClientIndex = "entityid",
    setMute = "boolean"
}

function BuildMutePlayerMessage(muteClientIndex, setMute)

    local t = {}

    t.muteClientIndex = muteClientIndex
    t.setMute = setMute

    return t

end

function ParseMutePlayerMessage(t)
    return t.muteClientIndex, t.setMute
end

local kDebugLineMessage =
{
    startPoint = "vector",
    endPoint = "vector",
    lifetime = "float",
    r = "float",
    g = "float",
    b = "float",
    a = "float"
}

function BuildDebugLineMessage(startPoint, endPoint, lifetime, r, g, b, a)

    local t = { }

    t.startPoint = startPoint
    t.endPoint = endPoint
    t.lifetime = lifetime
    t.r = r
    t.g = g
    t.b = b
    t.a = a

    return t

end

function ParseDebugLineMessage(t)
    return t.startPoint, t.endPoint, t.lifetime, t.r, t.g, t.b, t.a
end

local kDebugCapsuleMessage =
{
    sweepStart = "vector",
    sweepEnd = "vector",
    capsuleRadius = "float",
    capsuleHeight = "float",
    lifetime = "float"
}

function BuildDebugCapsuleMessage(sweepStart, sweepEnd, capsuleRadius, capsuleHeight, lifetime)

    local t = { }

    t.sweepStart = sweepStart
    t.sweepEnd = sweepEnd
    t.capsuleRadius = capsuleRadius
    t.capsuleHeight = capsuleHeight
    t.lifetime = lifetime

    return t

end

function ParseDebugCapsuleMessage(t)
    return t.sweepStart, t.sweepEnd, t.capsuleRadius, t.capsuleHeight, t.lifetime
end

local kDebugDumpRoundEndStatsMessage =
{
    dumpRoundStats = "boolean"
}


local kMinimapAlertMessage =
{
    techId = "enum kTechId",
    worldX = "float",
    worldZ = "float",
    entityId = "entityid",
    entityTechId = "enum kTechId"
}

local kTechNodeInstanceMessage =
{
    progress = "float",
    entity = "entityid",
    researchId = string.format("integer (0 to %d)", #kTechId),
    removed = "boolean"
}
Shared.RegisterNetworkMessage( "TechNodeInstance", kTechNodeInstanceMessage )

function ParseTechNodeInstanceMessage(techNode, networkVars)

    if not techNode.instances then
        techNode.instances = IterableDict()
    end

    if techNode.instances[networkVars.entity] then

        techNode.instances[networkVars.entity].progress = networkVars.progress
        techNode.instances[networkVars.entity].researchId = networkVars.researchId
        techNode.instances[networkVars.entity].removed = networkVars.removed

    else
        techNode.instances[networkVars.entity] = { progress = networkVars.progress, researchId = networkVars.researchId, removed = networkVars.removed }
    end
end

function BuildTechNodeInstanceMessage(techNode, entityId)

    local t = {}

    local instance = techNode.instances[entityId]

    t.progress = instance.progress
    t.entity = entityId
    t.researchId = instance.researchId
    t.removed = instance.removed

    return t

end

-- From TechNode.kTechNodeVars
local kTechNodeBaseMessage =
{

    -- Unique id
    techId              = string.format("integer (0 to %d)", #kTechId),

    -- Type of tech
    techType            = "enum kTechType",

    -- Tech nodes that are required to build or research (or kTechId.None)
    prereq1             = string.format("integer (0 to %d)", #kTechId),
    prereq2             = string.format("integer (0 to %d)", #kTechId),

    -- This node is an upgrade, addition, evolution or add-on to another node
    -- This includes an alien upgrade for a specific lifeform or an alternate
    -- ammo upgrade for a weapon. For research nodes, they can only be triggered
    -- on structures of this type (ie, mature versions of a structure).
    addOnTechId         = string.format("integer (0 to %d)", #kTechId),

    -- If tech node can be built/researched/used. Requires prereqs to be met and for
    -- research, means that it hasn't already been researched and that it's not
    -- in progress. Computed when structures are built or killed or when
    -- global research starts or stops (TechTree:ComputeAvailability()).
    available           = "boolean",

    -- Seconds to complete research or upgrade. Structure build time is kept in Structure.buildTime (Server).
    time                = "integer (0 to 360)",

    -- 0-1 research progress. This is non-authoritative and set/duplicated from Structure:SetResearchProgress()
    -- so player buy menus can display progress.
    researchProgress    = "float",

    -- 0-1 research progress of the prerequisites of this node.
    prereqResearchProgress = "float",

    -- True after being researched.
    researched          = "boolean",

    -- True for research in progress (not upgrades)
    researching         = "boolean",

    -- If true, tech tree activity requires ghost, otherwise it will execute at target location's position (research, most actions)
    requiresTarget      = "boolean",

    hasTech             = "boolean"

}

-- Build tech node from data sent in base update
-- Was TechNode:InitializeFromNetwork
function ParseTechNodeBaseMessage(techNode, networkVars)

    techNode.techId                 = networkVars.techId
    techNode.techType               = networkVars.techType
    techNode.prereq1                = networkVars.prereq1
    techNode.prereq2                = networkVars.prereq2
    techNode.addOnTechId            = networkVars.addOnTechId
    techNode.cost                   = LookupTechData(networkVars.techId, kTechDataCostKey, 0)
    techNode.available              = networkVars.available
    techNode.time                   = networkVars.time
    techNode.researchProgress       = networkVars.researchProgress
    techNode.prereqResearchProgress = networkVars.prereqResearchProgress
    techNode.researched             = networkVars.researched
    techNode.researching            = networkVars.researching
    techNode.requiresTarget         = networkVars.requiresTarget
    techNode.hasTech                = networkVars.hasTech

end

-- Update values from kTechNodeUpdateMessage
-- Was TechNode:UpdateFromNetwork
function ParseTechNodeUpdateMessage(techNode, networkVars)

    techNode.available              = networkVars.available
    techNode.researchProgress       = networkVars.researchProgress
    techNode.prereqResearchProgress = networkVars.prereqResearchProgress
    techNode.researched             = networkVars.researched
    techNode.researching            = networkVars.researching
    techNode.hasTech                = networkVars.hasTech

end

function BuildTechNodeBaseMessage(techNode)

    local t = {}

    t.techId                    = techNode.techId
    t.techType                  = techNode.techType
    t.prereq1                   = techNode.prereq1
    t.prereq2                   = techNode.prereq2
    t.addOnTechId               = techNode.addOnTechId
    t.available                 = techNode.available
    t.time                      = techNode.time
    t.researchProgress          = techNode.researchProgress
    t.prereqResearchProgress    = techNode.prereqResearchProgress
    t.researched                = techNode.researched
    t.researching               = techNode.researching
    t.requiresTarget            = techNode.requiresTarget
    t.hasTech                   = techNode.hasTech

    return t

end

local kSetNameMessage =
{
    name = string.format("string (%d)", kMaxNameLength * 4 )
}
Shared.RegisterNetworkMessage("SetName", kSetNameMessage)

local kChatClientMessage =
{
    teamOnly = "boolean",
    message = string.format("string (%d)", kMaxChatLength * 4 + 1)
}

function BuildChatClientMessage(teamOnly, chatMessage)
    return { teamOnly = teamOnly, message = chatMessage }
end

local kChatMessage =
{
    teamOnly = "boolean",
    playerName = string.format("string (%d)", kMaxNameLength * 4 ),
    locationId = "integer (-1 to 1000)",
    teamNumber = "integer (" .. kTeamInvalid .. " to " .. kSpectatorIndex .. ")",
    teamType = "integer (" .. kNeutralTeamType .. " to " .. kAlienTeamType .. ")",
    message = string.format("string (%d)", kMaxChatLength * 4 + 1)
}

function BuildChatMessage(teamOnly, playerName, playerLocationId, playerTeamNumber, playerTeamType, chatMessage)

    local message = { }

    message.teamOnly = teamOnly
    message.playerName = playerName
    message.locationId = playerLocationId
    message.teamNumber = playerTeamNumber
    message.teamType = playerTeamType
    message.message = chatMessage

    return message

end

local kVoteConcedeCastMessage =
{
    voterName = string.format("string (%d)", kMaxNameLength * 4 ),
    votesMoreNeeded = "integer (0 to 64)"
}

local kTeamConcededMessage =
{
    teamNumber = string.format("integer (-1 to %d)", kRandomTeamType)
}

local kVoteEjectCastMessage =
{
    voterName = string.format("string (%d)", kMaxNameLength * 4 ),
    votesMoreNeeded = "integer (0 to 64)"
}

local kGameEndMessage =
{
    win = "integer (0 to 2)",
}

local kDebugGrenades =
{
    enabled = "boolean"
}


Shared.RegisterNetworkMessage("GameEnd", kGameEndMessage)

Shared.RegisterNetworkMessage("EntityChanged", kEntityChangedMessage)
Shared.RegisterNetworkMessage("ResetGame", {} )

-- Selection
Shared.RegisterNetworkMessage("SelectUnit", kSelectUnitMessage)
Shared.RegisterNetworkMessage("SelectHotkeyGroup", kSelectHotkeyGroupMessage)

-- Commander actions
Shared.RegisterNetworkMessage("CommAction", kCommAction)
Shared.RegisterNetworkMessage("CommTargetedAction", kCommTargetedAction)
Shared.RegisterNetworkMessage("CommTargetedActionWorld", kCommTargetedAction)
Shared.RegisterNetworkMessage("CreateHotKeyGroup", kCreateHotkeyGroupMessage)

-- Command Structure Events
Shared.RegisterNetworkMessage("DangerMusicUpdate", kDangerMusicUpdateMessage)

-- Notifications
Shared.RegisterNetworkMessage("MinimapAlert", kMinimapAlertMessage)
Shared.RegisterNetworkMessage("VoteConcedeCast", kVoteConcedeCastMessage)
Shared.RegisterNetworkMessage("VoteEjectCast", kVoteEjectCastMessage)
Shared.RegisterNetworkMessage("TeamConceded", kTeamConcededMessage)

-- Player actions
Shared.RegisterNetworkMessage("MutePlayer", kMutePlayerMessage)

-- Gorge select structure message
Shared.RegisterNetworkMessage("GorgeBuildStructure", kGorgeBuildStructureMessage)

-- Chat
Shared.RegisterNetworkMessage("ChatClient", kChatClientMessage)
Shared.RegisterNetworkMessage("Chat", kChatMessage)
Shared.RegisterNetworkMessage("ChatUnlocalized", kChatMessage)

-- Debug messages
Shared.RegisterNetworkMessage("DebugLine", kDebugLineMessage)
Shared.RegisterNetworkMessage("DebugCapsule", kDebugCapsuleMessage)

Shared.RegisterNetworkMessage("DumpRoundStats", kDebugDumpRoundEndStatsMessage)


--Specific Entity Debug Tools
Shared.RegisterNetworkMessage("DebugGrenades", kDebugGrenades)

Shared.RegisterNetworkMessage( "TechNodeBase", kTechNodeBaseMessage )
Shared.RegisterNetworkMessage( "ClearTechTree", {} )

local kCommunicationStatusMessage =
{
    communicationStatus = "enum kPlayerCommunicationStatus"
}

function BuildCommunicationStatus(communicationStatus)

    local t = {}

    t.communicationStatus = communicationStatus

    return t

end

function ParseCommunicationStatus(t)
    return t.communicationStatus
end

Shared.RegisterNetworkMessage( "SetCommunicationStatus", kCommunicationStatusMessage )

local kBuyMessage =
{
    techId1 = "enum kTechId",
    techId2 = "enum kTechId",
    techId3 = "enum kTechId",
    techId4 = "enum kTechId",
    techId5 = "enum kTechId",
    techId6 = "enum kTechId",
    techId7 = "enum kTechId",
    techId8 = "enum kTechId"
}
local kBuyMessageMaxEntries = table.countkeys(kBuyMessage)

function BuildBuyMessage(techIds)

    assert(#techIds <= kBuyMessageMaxEntries)

    local buyMessage = { techId1 = kTechId.None, techId2 = kTechId.None, techId3 = kTechId.None,
                         techId4 = kTechId.None, techId5 = kTechId.None, techId6 = kTechId.None,
                         techId7 = kTechId.None, techId8 = kTechId.None }

    for t = 1, #techIds do
        buyMessage["techId" .. t] = techIds[t]
    end

    return buyMessage

end

function ParseBuyMessage(buyMessage)

    local maxNumTechs = kBuyMessageMaxEntries

    -- We need to iterate over the buyMessage table and insert
    -- the tech Ids in the correct order into the techIds list.
    local techIds = { }
    for t = 1, maxNumTechs do

        local techId = buyMessage["techId" .. t]
        if techId and techId ~= kTechId.None then
            table.insert(techIds, techId)
        end

    end

    return techIds

end

Shared.RegisterNetworkMessage("Buy", kBuyMessage)

local kAutoConcedeWarning =
{
    time = "time",
    team1Conceding = "boolean"
}
Shared.RegisterNetworkMessage("AutoConcedeWarning", kAutoConcedeWarning)

local kScoreUpdate =
{
    points = "integer (0 to " .. kMaxScore .. ")",
    res = "integer (0 to " .. kMaxPersonalResources .. ")",
    wasKill = "boolean"
}
Shared.RegisterNetworkMessage("ScoreUpdate", kScoreUpdate)

Shared.RegisterNetworkMessage("SetAchievement", { name = "string (48)" } )

Shared.RegisterNetworkMessage("SpectatePlayer", { entityId = "entityid"})
Shared.RegisterNetworkMessage("SwitchFromFirstPersonSpectate", { mode = "enum kSpectatorMode" })
Shared.RegisterNetworkMessage("SwitchFirstPersonSpectatePlayer", { forward = "boolean" })
Shared.RegisterNetworkMessage("SetClientIndex", { clientIndex = "entityid" })
Shared.RegisterNetworkMessage("ServerHidden", { hidden = "boolean" })
Shared.RegisterNetworkMessage("SetClientTeamNumber", { teamNumber = string.format("integer (-1 to %d)", kRandomTeamType) })
Shared.RegisterNetworkMessage("WaitingForAutoTeamBalance", { waiting = "boolean" })
Shared.RegisterNetworkMessage("SetTimeWaveSpawnEnds", { time = "time" })
Shared.RegisterNetworkMessage("SetIsRespawning", { isRespawning = "boolean" })
Shared.RegisterNetworkMessage("SetDesiredSpawnPoint", { desiredSpawnPoint = "position" })

local kTeamNumDef = "integer (" .. kTeamInvalid .. " to " .. kSpectatorIndex .. ")"
Shared.RegisterNetworkMessage("DeathMessage", { killerIsPlayer = "boolean", killerId = "integer", killerTeamNumber = kTeamNumDef, iconIndex = "enum kDeathMessageIcon", targetIsPlayer = "boolean", targetId = "integer", targetTeamNumber = kTeamNumDef })

Shared.RegisterNetworkMessage("DumpTeamBrain", {})

if Shared.GetThunderdomeEnabled() then
    --End of round message to notify clients to check if they've unlocked any items
    Shared.RegisterNetworkMessage("Thunderdome_EndRoundItemsCheck")
    --Notify clients the match is finalized and lobby state should be updated
    Shared.RegisterNetworkMessage("Thunderdome_MatchFinalized")
end

Shared.RegisterNetworkMessage("RoundStatsProcessingCompleted", {})

-- %%% New CBM Functions %%% --
Script.Load("lua/CommunityBalanceMod/Weapons/ModularExo_Data.lua")

local kExoBuyMessage = {
    leftArmModuleType  = "enum kExoModuleTypes",
    rightArmModuleType = "enum kExoModuleTypes",
    utilityModuleType  = "enum kExoModuleTypes",
    abilityModuleType  = "enum kExoModuleTypes"
    
}

Shared.RegisterNetworkMessage("ExoModularBuy", kExoBuyMessage)

if Server then
    
    local function OnMessageExoModularBuy(client, message)
        local player = client:GetControllingPlayer()
        if player and player:GetIsAllowedToBuy() and player.ProcessExoModularBuyAction then
			player:ProcessExoModularBuyAction(message)
        end
    end
    Server.HookNetworkMessage("ExoModularBuy", OnMessageExoModularBuy)
    
    function ModularExo_FindExoSpawnPoint(self)
        local maxAttempts = 100
        for index = 1, maxAttempts do
            
            -- Find open area nearby to place the big guy.
            local capsuleHeight, capsuleRadius = self:GetTraceCapsule()
            local extents = Vector(Exo.kXZExtents, Exo.kYExtents, Exo.kXZExtents)
            
            local spawnPoint
            local checkPoint = self:GetOrigin() + Vector(0, 0.02, 0)
            
            if GetHasRoomForCapsule(extents, checkPoint + Vector(0, extents.y, 0), CollisionRep.Move, PhysicsMask.Evolve, self) then
                spawnPoint = checkPoint
            else
                spawnPoint = GetRandomSpawnForCapsule(extents.y, extents.x, checkPoint, 0.5, 5, EntityFilterOne(self))
            end
            
            local weapons
            
            if spawnPoint then
                return spawnPoint
            end
        end
    end
    
    function ModularExo_HandleExoModularBuy(self, message)
        local exoConfig = ModularExo_ConvertNetMessageToConfig(message)

        local discount = 0
        if self:isa("Exo") then
            local isValid, badReason, resCost = ModularExo_GetIsConfigValid(ModularExo_ConvertNetMessageToConfig(self))
            discount = resCost
        end
        
        local isValid, badReason, resCost = ModularExo_GetIsConfigValid(exoConfig)
        resCost = math.max(0,resCost - discount)

        local playerPos = self:GetOrigin()
        local nearestProto = GetNearest(playerPos, "PrototypeLab", kMarineTeamType)

        if not isValid or resCost > self:GetResources() or nearestProto:GetTechId() ~= kTechId.AdvancedPrototypeLab then
            Print("Invalid exo config: %s", badReason)
            return
        end

        local spawnPoint = ModularExo_FindExoSpawnPoint(self)
        if spawnPoint == nil then
            Print("Could not find exo spawnpoint")
            return
        end
        
		self:AddResources(-resCost)
		
        local weapons = self:GetWeapons()
        for i = 1, #weapons do
            weapons[i]:SetParent(nil)
        end
        local exoVariables = message
        
        local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, exoVariables)
        
        if not exo then
            Print("Could make replacement exo entity")
            return
        end
        if self:isa("Exo") then
            exo:SetMaxArmor(self:GetMaxArmor())
            exo:SetArmor(self:GetArmor())
        else
            exo.prevPlayerMapName = self:GetMapName()
            exo.prevPlayerHealth = self:GetHealth()
            exo.prevPlayerMaxArmor = self:GetMaxArmor()
            exo.prevPlayerArmor = self:GetArmor()
            for i = 1, #weapons do
                exo:StoreWeapon(weapons[i])
            end
        end
        
        exo:TriggerEffects("spawn_exo")
    end
end
