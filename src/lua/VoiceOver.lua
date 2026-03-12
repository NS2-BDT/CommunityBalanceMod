-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\VoiceOver.lua
--
-- Created by: Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

LEFT_MENU = 1
RIGHT_MENU = 2
kMaxRequestsPerSide = 6

kVoiceId = enum
({
    'None', 'VoteEject', 'VoteConcede', 'Ping',

    'RequestWeld', 'MarineRequestMedpack', 'MarineRequestAmmo', 'MarineRequestOrder', 'MarineRequestStructure',
    'MarineTaunt', 'MarineTauntExclusive', 'MarineCovering', 'MarineFollowMe', 'MarineHostiles', 'MarineLetsMove', 'MarineAcknowledged',
    
    --Bigmac
    'Mac_RequestWeld','Mac_RequestMedpack', 'Mac_RequestAmmo', 'Mac_RequestOrder', 'Mac_RequestStructure',
    'Mac_Taunt', 'Mac_Covering', 'Mac_FollowMe', 'Mac_Hostiles', 'Mac_LetsMove', 'Mac_Acknowledged',

    --Military mac
    'MilMac_RequestWeld','MilMac_RequestMedpack', 'MilMac_RequestAmmo', 'MilMac_RequestOrder', 'MilMac_RequestStructure',
    'MilMac_Taunt', 'MilMac_Covering', 'MilMac_FollowMe', 'MilMac_Hostiles', 'MilMac_LetsMove', 'MilMac_Acknowledged',

    'AlienRequestHarvester', 'AlienRequestHealing', 'AlienRequestMist', 'AlienRequestDrifter', 'AlienRequestStructure',
    'AlienTaunt', 'AlienFollowMe', 'AlienChuckle', 'EmbryoChuckle',
})

local kAlienTauntSounds =
{
    [kTechId.Skulk] = "sound/NS2.fev/alien/voiceovers/chuckle",
    [kTechId.Gorge] = "sound/NS2.fev/alien/gorge/taunt",
    [kTechId.Lerk] = "sound/NS2.fev/alien/lerk/taunt",
    [kTechId.Fade] = "sound/NS2.fev/alien/fade/taunt",
    [kTechId.Onos] = "sound/NS2.fev/alien/onos/wound_serious",
    [kTechId.Embryo] = "sound/NS2.fev/alien/common/swarm",
    [kTechId.ReadyRoomEmbryo] = "sound/NS2.fev/alien/common/swarm",
}
for _, tauntSound in pairs(kAlienTauntSounds) do
    PrecacheAsset(tauntSound)
end

local function VoteEjectCommander(player)

    if player then
        GetGamerules():CastVoteByPlayer(kTechId.VoteDownCommander1, player)
    end    
    
end

local function VoteConcedeRound(player)

    if player then
        GetGamerules():CastVoteByPlayer(kTechId.VoteConcedeRound, player)
    end  
    
end

local function GetLifeFormSound(player)

    if player and (player:isa("Alien") or player:isa("ReadyRoomEmbryo")) then    
        return kAlienTauntSounds[player:GetTechId()] or ""    
    end
    
    return ""

end

local function PingInViewDirection(player)

    if player and (not player.lastTimePinged or player.lastTimePinged + 60 < Shared.GetTime()) then
    
        local startPoint = player:GetEyePos()
        local endPoint = startPoint + player:GetViewCoords().zAxis * 40        
        local trace = Shared.TraceRay(startPoint, endPoint,  CollisionRep.Default, PhysicsMask.Bullets, EntityFilterOne(player))   
        
        -- seems due to changes to team mixin you can be assigned to a team which does not implement SetCommanderPing
        local team = player:GetTeam()
        if team and team.SetCommanderPing then
            player:GetTeam():SetCommanderPing(trace.endPoint)
        end
        
        player.lastTimePinged = Shared.GetTime()
        
    end

end

local function GiveWeldOrder(player)

    if ( player:isa("Marine") or player:isa("Exo") ) and player:GetArmor() < player:GetMaxArmor() then
    
        for _, marine in ipairs(GetEntitiesForTeamWithinRange("Marine", player:GetTeamNumber(), player:GetOrigin(), 8)) do
        
            if player ~= marine and marine:GetWeapon(Welder.kMapName) then
                marine:GiveOrder(kTechId.AutoWeld, player:GetId(), player:GetOrigin(), nil, true, false)
            end
        
        end
    
    end

end

local kSoundData = 
{

    -- always part of the menu
    [kVoiceId.VoteEject] = { Function = VoteEjectCommander },
    [kVoiceId.VoteConcede] = { Function = VoteConcedeRound },

    [kVoiceId.Ping] = { Function = PingInViewDirection, Description = "REQUEST_PING", KeyBind = "PingLocation" },

    -- marine vote menu
    [kVoiceId.RequestWeld] = { Sound = "sound/NS2.fev/marine/voiceovers/weld", Function = GiveWeldOrder, Description = "REQUEST_MARINE_WELD", KeyBind = "RequestWeld", AlertTechId = kTechId.None },
    [kVoiceId.MarineRequestMedpack] = { Sound = "sound/NS2.fev/marine/voiceovers/medpack", Description = "REQUEST_MARINE_MEDPACK", KeyBind = "RequestHealth", AlertTechId = kTechId.MarineAlertNeedMedpack },
    [kVoiceId.MarineRequestAmmo] = { Sound = "sound/NS2.fev/marine/voiceovers/ammo", Description = "REQUEST_MARINE_AMMO", KeyBind = "RequestAmmo", AlertTechId = kTechId.MarineAlertNeedAmmo },
    [kVoiceId.MarineRequestOrder] = { Sound = "sound/NS2.fev/marine/voiceovers/need_orders", Description = "REQUEST_MARINE_ORDER",  KeyBind = "RequestOrder", AlertTechId = kTechId.MarineAlertNeedOrder },
    [kVoiceId.MarineRequestStructure] = { Sound = "sound/NS2.fev/marine/voiceovers/need_orders", Description = "REQUEST_STRUCTURE",  KeyBind = "RequestStructure", AlertTechId = kTechId.MarineAlertNeedStructure },

    [kVoiceId.MarineTaunt] = { Sound = "sound/NS2.fev/marine/voiceovers/taunt", Description = "REQUEST_MARINE_TAUNT", KeyBind = "Taunt", AlertTechId = kTechId.None },
    [kVoiceId.MarineTauntExclusive] = { Sound = "sound/NS2.fev/marine/voiceovers/taunt_exclusive", Description = "REQUEST_MARINE_TAUNT", KeyBind = "Taunt", AlertTechId = kTechId.None },
    [kVoiceId.MarineCovering] = { Sound = "sound/NS2.fev/marine/voiceovers/covering", Description = "REQUEST_MARINE_COVERING", KeyBind = "VoiceOverCovering", AlertTechId = kTechId.None },
    [kVoiceId.MarineFollowMe] = { Sound = "sound/NS2.fev/marine/voiceovers/follow_me", Description = "REQUEST_MARINE_FOLLOWME", KeyBind = "VoiceOverFollowMe", AlertTechId = kTechId.None },
    [kVoiceId.MarineHostiles] = { Sound = "sound/NS2.fev/marine/voiceovers/hostiles", Description = "REQUEST_MARINE_HOSTILES", KeyBind = "VoiceOverHostiles", AlertTechId = kTechId.None },
    [kVoiceId.MarineLetsMove] = { Sound = "sound/NS2.fev/marine/voiceovers/lets_move", Description = "REQUEST_MARINE_LETSMOVE", KeyBind = "VoiceOverFollowMe", AlertTechId = kTechId.None },
    [kVoiceId.MarineAcknowledged] = { Sound = "sound/NS2.fev/marine/voiceovers/ack", Description = "REQUEST_MARINE_ACKNOWLEDGED", KeyBind = "VoiceOverAcknowledged", AlertTechId = kTechId.None },
    
    --Bigmac
    [kVoiceId.Mac_RequestWeld] = { Sound = "sound/NS2.fev/marine/voiceovers/bigmac_friendly/weld", Function = GiveWeldOrder, Description = "REQUEST_MARINE_WELD", KeyBind = "RequestWeld", AlertTechId = kTechId.None },
    [kVoiceId.Mac_RequestMedpack] = { Sound = "sound/NS2.fev/marine/voiceovers/bigmac_friendly/medpack", Description = "REQUEST_MARINE_MEDPACK", KeyBind = "RequestHealth", AlertTechId = kTechId.MarineAlertNeedMedpack },
    [kVoiceId.Mac_RequestAmmo] = { Sound = "sound/NS2.fev/marine/voiceovers/bigmac_friendly/ammo", Description = "REQUEST_MARINE_AMMO", KeyBind = "RequestAmmo", AlertTechId = kTechId.MarineAlertNeedAmmo },
    [kVoiceId.Mac_RequestOrder] = { Sound = "sound/NS2.fev/marine/voiceovers/bigmac_friendly/need_orders", Description = "REQUEST_MARINE_ORDER",  KeyBind = "RequestOrder", AlertTechId = kTechId.MarineAlertNeedOrder },
    [kVoiceId.Mac_RequestStructure] = { Sound = "sound/NS2.fev/marine/voiceovers/bigmac_friendly/need_orders", Description = "REQUEST_STRUCTURE",  KeyBind = "RequestStructure", AlertTechId = kTechId.MarineAlertNeedStructure },

    [kVoiceId.Mac_Taunt] = { Sound = "sound/NS2.fev/marine/voiceovers/bigmac_friendly/taunt", Description = "REQUEST_MARINE_TAUNT", KeyBind = "Taunt", AlertTechId = kTechId.None },
    [kVoiceId.Mac_Covering] = { Sound = "sound/NS2.fev/marine/voiceovers/bigmac_friendly/covering", Description = "REQUEST_MARINE_COVERING", KeyBind = "VoiceOverCovering", AlertTechId = kTechId.None },
    [kVoiceId.Mac_FollowMe] = { Sound = "sound/NS2.fev/marine/voiceovers/bigmac_friendly/follow_me", Description = "REQUEST_MARINE_FOLLOWME", KeyBind = "VoiceOverFollowMe", AlertTechId = kTechId.None },
    [kVoiceId.Mac_Hostiles] = { Sound = "sound/NS2.fev/marine/voiceovers/bigmac_friendly/hostiles", Description = "REQUEST_MARINE_HOSTILES", KeyBind = "VoiceOverHostiles", AlertTechId = kTechId.None },
    [kVoiceId.Mac_LetsMove] = { Sound = "sound/NS2.fev/marine/voiceovers/bigmac_friendly/lets_move", Description = "REQUEST_MARINE_LETSMOVE", KeyBind = "VoiceOverFollowMe", AlertTechId = kTechId.None },
    [kVoiceId.Mac_Acknowledged] = { Sound = "sound/NS2.fev/marine/voiceovers/bigmac_friendly/ack", Description = "REQUEST_MARINE_ACKNOWLEDGED", KeyBind = "VoiceOverAcknowledged", AlertTechId = kTechId.None },

    --Military Mac
    [kVoiceId.MilMac_RequestWeld] = { Sound = "sound/NS2.fev/marine/voiceovers/bigmac_combat/weld", Function = GiveWeldOrder, Description = "REQUEST_MARINE_WELD", KeyBind = "RequestWeld", AlertTechId = kTechId.None },
    [kVoiceId.MilMac_RequestMedpack] = { Sound = "sound/NS2.fev/marine/voiceovers/bigmac_combat/medpack", Description = "REQUEST_MARINE_MEDPACK", KeyBind = "RequestHealth", AlertTechId = kTechId.MarineAlertNeedMedpack },
    [kVoiceId.MilMac_RequestAmmo] = { Sound = "sound/NS2.fev/marine/voiceovers/bigmac_combat/ammo", Description = "REQUEST_MARINE_AMMO", KeyBind = "RequestAmmo", AlertTechId = kTechId.MarineAlertNeedAmmo },
    [kVoiceId.MilMac_RequestOrder] = { Sound = "sound/NS2.fev/marine/voiceovers/bigmac_combat/need_orders", Description = "REQUEST_MARINE_ORDER",  KeyBind = "RequestOrder", AlertTechId = kTechId.MarineAlertNeedOrder },
    [kVoiceId.MilMac_RequestStructure] = { Sound = "sound/NS2.fev/marine/voiceovers/bigmac_combat/need_orders", Description = "REQUEST_STRUCTURE",  KeyBind = "RequestStructure", AlertTechId = kTechId.MarineAlertNeedStructure },

    [kVoiceId.MilMac_Taunt] = { Sound = "sound/NS2.fev/marine/voiceovers/bigmac_combat/taunt", Description = "REQUEST_MARINE_TAUNT", KeyBind = "Taunt", AlertTechId = kTechId.None },
    [kVoiceId.MilMac_Covering] = { Sound = "sound/NS2.fev/marine/voiceovers/bigmac_combat/covering", Description = "REQUEST_MARINE_COVERING", KeyBind = "VoiceOverCovering", AlertTechId = kTechId.None },
    [kVoiceId.MilMac_FollowMe] = { Sound = "sound/NS2.fev/marine/voiceovers/bigmac_combat/follow_me", Description = "REQUEST_MARINE_FOLLOWME", KeyBind = "VoiceOverFollowMe", AlertTechId = kTechId.None },
    [kVoiceId.MilMac_Hostiles] = { Sound = "sound/NS2.fev/marine/voiceovers/bigmac_combat/hostiles", Description = "REQUEST_MARINE_HOSTILES", KeyBind = "VoiceOverHostiles", AlertTechId = kTechId.None },
    [kVoiceId.MilMac_LetsMove] = { Sound = "sound/NS2.fev/marine/voiceovers/bigmac_combat/lets_move", Description = "REQUEST_MARINE_LETSMOVE", KeyBind = "VoiceOverFollowMe", AlertTechId = kTechId.None },
    [kVoiceId.MilMac_Acknowledged] = { Sound = "sound/NS2.fev/marine/voiceovers/bigmac_combat/ack", Description = "REQUEST_MARINE_ACKNOWLEDGED", KeyBind = "VoiceOverAcknowledged", AlertTechId = kTechId.None },

    -- alien vote menu
    [kVoiceId.AlienRequestHarvester] = { Sound = "sound/NS2.fev/alien/voiceovers/follow_me", Description = "REQUEST_ALIEN_HARVESTER", KeyBind = "RequestOrder", AlertTechId = kTechId.AlienAlertNeedHarvester },
    [kVoiceId.AlienRequestMist] = { Sound = "sound/NS2.fev/alien/common/hatch", Description = "REQUEST_ALIEN_MIST", KeyBind = "RequestHealth", AlertTechId = kTechId.AlienAlertNeedMist },
    [kVoiceId.AlienRequestDrifter] = { Sound = "sound/NS2.fev/alien/voiceovers/follow_me", Description = "REQUEST_ALIEN_DRIFTER", KeyBind = "RequestAmmo", AlertTechId = kTechId.AlienAlertNeedDrifter },
    [kVoiceId.AlienRequestStructure] = { Sound = "sound/NS2.fev/alien/voiceovers/follow_me", Description = "REQUEST_STRUCTURE", KeyBind = "RequestStructure", AlertTechId = kTechId.AlienAlertNeedStructure },
    [kVoiceId.AlienRequestHealing] = { Sound = "sound/NS2.fev/alien/voiceovers/need_healing", Description = "REQUEST_ALIEN_HEAL", KeyBind = "RequestHealth", AlertTechId = kTechId.None },
    [kVoiceId.AlienTaunt] = { Sound = "", Function = GetLifeFormSound, Description = "REQUEST_ALIEN_TAUNT", KeyBind = "Taunt", AlertTechId = kTechId.None },
    [kVoiceId.AlienFollowMe] = { Sound = "sound/NS2.fev/alien/voiceovers/follow_me", Description = "REQUEST_ALIEN_FOLLOWME", AlertTechId = kTechId.None },
    [kVoiceId.AlienChuckle] = { Sound = "sound/NS2.fev/alien/voiceovers/chuckle", Description = "REQUEST_ALIEN_CHUCKLE", KeyBind = "VoiceOverAcknowledged", AlertTechId = kTechId.None },  
    [kVoiceId.EmbryoChuckle] = { Sound = "sound/NS2.fev/alien/structures/death_large", Description = "REQUEST_ALIEN_CHUCKLE", KeyBind = "VoiceOverAcknowledged", AlertTechId = kTechId.None },     

}

local macVOs = 
{
    kVoiceId.Mac_RequestWeld,
    kVoiceId.Mac_RequestMedpack,
    kVoiceId.Mac_RequestAmmo,
    kVoiceId.Mac_RequestOrder,
    kVoiceId.Mac_RequestStructure,
    kVoiceId.Mac_Taunt,
    kVoiceId.Mac_Covering,
    kVoiceId.Mac_FollowMe,
    kVoiceId.Mac_Hostiles,
    kVoiceId.Mac_LetsMove,
    kVoiceId.Mac_Acknowledged,

    kVoiceId.MilMac_RequestWeld,
    kVoiceId.MilMac_RequestMedpack,
    kVoiceId.MilMac_RequestAmmo,
    kVoiceId.MilMac_RequestOrder,
    kVoiceId.MilMac_RequestStructure,
    kVoiceId.MilMac_Taunt,
    kVoiceId.MilMac_Covering,
    kVoiceId.MilMac_FollowMe,
    kVoiceId.MilMac_Hostiles,
    kVoiceId.MilMac_LetsMove,
    kVoiceId.MilMac_Acknowledged,
}


-- Initialize the female variants of the voice overs and precache.
for _, soundData in pairs(kSoundData) do

    if soundData.Sound ~= nil and string.len(soundData.Sound) > 0 then
    
        PrecacheAsset(soundData.Sound)
        
        -- Do not look for female versions of alien sounds.
        if string.find(soundData.Sound, "sound/NS2.fev/alien/", 1) == nil and not table.icontains(macVOs, _) then
        
            soundData.SoundFemale = soundData.Sound .. "_female"
            PrecacheAsset(soundData.SoundFemale)
            
        end
        
    end
    
end

function GetVoiceSoundData(voiceId)
    return kSoundData[voiceId]
end

local kMarineMenu =
{
    [LEFT_MENU] = { kVoiceId.RequestWeld, kVoiceId.MarineRequestMedpack, kVoiceId.MarineRequestAmmo, kVoiceId.MarineRequestOrder, kVoiceId.MarineRequestStructure, kVoiceId.Ping },
    [RIGHT_MENU] = { kVoiceId.MarineTaunt, kVoiceId.MarineCovering, kVoiceId.MarineFollowMe, kVoiceId.MarineHostiles, kVoiceId.MarineAcknowledged}
}

local kMarineMacMenu =
{
    [LEFT_MENU] = { kVoiceId.Mac_RequestWeld, kVoiceId.Mac_RequestMedpack, kVoiceId.Mac_RequestAmmo, kVoiceId.Mac_RequestOrder, kVoiceId.Mac_RequestStructure, kVoiceId.Ping },
    [RIGHT_MENU] = { kVoiceId.Mac_Taunt, kVoiceId.Mac_Covering, kVoiceId.Mac_FollowMe, kVoiceId.Mac_Hostiles, kVoiceId.Mac_Acknowledged}
}

local kMarineMilMacMenu =
{
    [LEFT_MENU] = { kVoiceId.MilMac_RequestWeld, kVoiceId.MilMac_RequestMedpack, kVoiceId.MilMac_RequestAmmo, kVoiceId.MilMac_RequestOrder, kVoiceId.MilMac_RequestStructure, kVoiceId.Ping },
    [RIGHT_MENU] = { kVoiceId.MilMac_Taunt, kVoiceId.MilMac_Covering, kVoiceId.MilMac_FollowMe, kVoiceId.MilMac_Hostiles, kVoiceId.MilMac_Acknowledged}
}

local kExoMenu = 
{
    [LEFT_MENU] = { kVoiceId.RequestWeld, kVoiceId.MarineRequestOrder, kVoiceId.MarineRequestStructure, kVoiceId.Ping },
    [RIGHT_MENU] = { kVoiceId.MarineTaunt, kVoiceId.MarineCovering, kVoiceId.MarineFollowMe, kVoiceId.MarineHostiles, kVoiceId.MarineAcknowledged }
}

local kExoMacMenuMenu = 
{
    [LEFT_MENU] = { kVoiceId.Mac_RequestWeld, kVoiceId.Mac_RequestOrder, kVoiceId.Mac_RequestStructure, kVoiceId.Ping },
    [RIGHT_MENU] = { kVoiceId.Mac_Taunt, kVoiceId.Mac_Covering, kVoiceId.Mac_FollowMe, kVoiceId.Mac_Hostiles, kVoiceId.Mac_Acknowledged}
}

local kExoMilMacMenu = 
{
    [LEFT_MENU] = { kVoiceId.MilMac_RequestWeld, kVoiceId.MilMac_RequestOrder, kVoiceId.MilMac_RequestStructure, kVoiceId.Ping },
    [RIGHT_MENU] = { kVoiceId.MilMac_Taunt, kVoiceId.MilMac_Covering, kVoiceId.MilMac_FollowMe, kVoiceId.MilMac_Hostiles, kVoiceId.MilMac_Acknowledged}
}

local kAlienMenu =
{
    [LEFT_MENU] = { kVoiceId.AlienRequestHealing, kVoiceId.AlienRequestDrifter, kVoiceId.AlienRequestStructure, kVoiceId.Ping },
    [RIGHT_MENU] = { kVoiceId.AlienTaunt, kVoiceId.AlienChuckle }    
}

local kEmbryoMenu = 
{
    [LEFT_MENU] = { kVoiceId.AlienRequestMist },
    [RIGHT_MENU] = { kVoiceId.AlienTaunt, kVoiceId.EmbryoChuckle }
}

local kRequestMenus = 
{
    ["Spectator"] = { },
    ["AlienSpectator"] = { },
    ["MarineSpectator"] = { },
    
    ["Marine"] = kMarineMenu,
    ["JetpackMarine"] = kMarineMenu,

    ["Exo"] = kExoMenu,
    --Special one-offs to handle BMAC piloted Exos
    ["ExoBigMac"] = kExoMacMenuMenu,
    ["ExoMilitaryMac"] = kExoMilMacMenu,

    ["BigMac"] = kMarineMacMenu,
    ["MilitaryMac"] = kMarineMilMacMenu,
    
    ["Skulk"] = kAlienMenu,
    ["Gorge"] =
    {
        [LEFT_MENU] = { kVoiceId.AlienRequestHealing, kVoiceId.AlienRequestDrifter, kVoiceId.AlienRequestStructure, kVoiceId.Ping },
        [RIGHT_MENU] = { kVoiceId.AlienTaunt, kVoiceId.AlienChuckle }
    },
    
    ["Lerk"] = kAlienMenu,
    ["Fade"] = kAlienMenu,
    ["Onos"] = kAlienMenu,
    ["Embryo"] = kEmbryoMenu,
    ["ReadyRoomPlayer"] = kMarineMenu,
    ["ReadyRoomExo"] = kExoMenu,
    ["ReadyRoomEmbryo"] = kEmbryoMenu,
}

function GetRequestMenu(side, className)
    
    local menu = kRequestMenus[className]
    
    if menu and menu[side] then
        return menu[side]
    end
    
    return { }
    
end

if Client then

    function GetVoiceDescriptionText(voiceId)
    
        local descriptionText = ""
        
        local soundData = kSoundData[voiceId]
        if soundData then
            descriptionText = Locale.ResolveString(soundData.Description)
        end
        
        return descriptionText
        
    end
    
    function GetVoiceKeyBind(voiceId)
    
        local soundData = kSoundData[voiceId]
        if soundData then
            return soundData.KeyBind
        end    
        
    end
    
end


local kAutoMarineVoiceOvers = {}
local kAutoAlienVoiceOvers = {}
