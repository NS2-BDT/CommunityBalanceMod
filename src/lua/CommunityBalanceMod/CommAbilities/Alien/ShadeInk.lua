-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\ShadeInk.lua
--
-- Created by: Andreas Urwalek (a_urwa@sbox.tugraz.at)
--
-- Creates an Ink cloud!
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/CommanderAbility.lua")

class 'ShadeInk' (CommanderAbility)

ShadeInk.kMapName = "shadeink"


local kShadeInkMarineEffect = PrecacheAsset("cinematics/alien/shade/shade_ink.cinematic")
local kShadeInkAlienEffect = PrecacheAsset("cinematics/alien/shade/shade_ink_alien.cinematic")
local kFakeShadeEffect = PrecacheAsset("cinematics/alien/shade/fake_shade.cinematic")
local kFakeShadeAlienEffect = PrecacheAsset("cinematics/alien/shade/fake_shade_alien.cinematic")
local kStartEffect = PrecacheAsset("cinematics/alien/shade/shade_ink_start.cinematic")
ShadeInk.kNumFakeShades = 3

local kUpdateTime = 0.185

ShadeInk.kType = CommanderAbility.kType.Repeat

ShadeInk.kShadeInkDisorientRadius = 16

local networkVars =
{
    numHives = "integer (1 to 3)"
}

-- random played for marines to confuse them
local kPhantomEffects =
{
    OneHive =
    {
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_fade1.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_skulk2.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_skulk3.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_skulk4.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_gorge5.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_skulk5.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_skulk6.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_gorge1.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_skulk1.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_gorge4.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_fade3.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_gorge6.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_lerk1.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_lerk1.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_lerk2.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_lerk3.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_lerk7.cinematic"),
    },
    
    TwoHive =
    {
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_gorge2.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_gorge3.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_fade2.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_fade3.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_fade4.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_lerk6.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_fade5.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_fade6.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_lerk4.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_lerk5.cinematic"),
    },
    
    ThreeHive =
    {
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_onos1.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_onos2.cinematic"),
        PrecacheAsset("cinematics/alien/shade/phantom/phantom_onos3.cinematic"),
        --PrecacheAsset("cinematics/alien/shade/phantom/phantom_onos4.cinematic"),
        --PrecacheAsset("cinematics/alien/shade/phantom/phantom_onos5.cinematic"),
        --PrecacheAsset("cinematics/alien/shade/phantom/phantom_onos6.cinematic"),
    }
}

local kNumOneHive = #kPhantomEffects.OneHive
local kNumTwoHive = #kPhantomEffects.TwoHive
local kNumThreeHive = #kPhantomEffects.ThreeHive
local kNumEffects = kNumOneHive + kNumTwoHive + kNumThreeHive

local function GetRandomPhantomName(numHives, seed)

    local effectCount = kNumOneHive
    
    if numHives >= 3 then
        effectCount = kNumEffects 
    elseif numHives >= 2 then
        effectCount = kNumOneHive + kNumTwoHive
    end
    
    local randomizer = Randomizer()
    randomizer:randomseed(seed)
    local randomEffectNum = randomizer:random(1, effectCount)

    local effectName

    if randomEffectNum <= kNumOneHive then
        effectName = kPhantomEffects.OneHive[randomEffectNum]
    elseif randomEffectNum <= kNumOneHive + kNumTwoHive then
        effectName = kPhantomEffects.OneHive[randomEffectNum - kNumOneHive]
    else
        effectName = kPhantomEffects.OneHive[randomEffectNum - kNumOneHive - kNumThreeHive]
    end

    return effectName

end

-- play a lighter effect for aliens/spectators so they can see through the ink cloud
local function GetLocalPlayerSeesThrough()
    local localPlayer = Client.GetLocalPlayer()
    if localPlayer and HasMixin(localPlayer, "Team") and localPlayer:GetTeamNumber() == kAlienTeamType or localPlayer:GetTeamNumber() == kNeutralTeamType then
        return true
    end    
    return false
end

if Server then

    function ShadeInk:OnCreate()
    
        self.numHives = Clamp(Shared.GetEntitiesWithClassname("Hive"):GetSize(), 0, 3)
        CommanderAbility.OnCreate(self)

    end
    
end

-- create randomly placed fake shades
--[[
function ShadeInk:CreateStartEffect()

    if Client then
    
        local numFakeShadesCreated = 0
        
        local effectName = kFakeShadeEffect
        
        if GetLocalPlayerSeesThrough() then
            effectName = kFakeShadeAlienEffect
        end
        
        -- all players should see the same effect
        local randomizer = Randomizer()
        randomizer:randomseed(self.timeCreated)
        
        for j = 1, ShadeInk.kNumFakeShades * 10 do 
        
            if numFakeShadesCreated >= ShadeInk.kNumFakeShades then
                break
            end    
        
            local hostCoords = self:GetCoords()
            local startPoint = hostCoords.origin + hostCoords.yAxis * 0.2
            
            local xDirection = 1
            local yDirection = 1
            
            if randomizer:random(-2, 1) < 0 then
                xDirection = -1
            end
            
            if randomizer:random(-2, 1) < 0 then
                yDirection = -1
            end
            
            local minRange = 200 * (numFakeShadesCreated + 1)
            local maxRange = minRange + 200
            
            xOffset = (randomizer:random(minRange, maxRange) / 100) * xDirection
            zOffset = (randomizer:random(minRange, maxRange) / 100) * yDirection
            
            startPoint = startPoint + hostCoords.xAxis * xOffset
            startPoint = startPoint + hostCoords.zAxis * zOffset
            
            local endPoint = startPoint - hostCoords.yAxis * 3
            local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Default, PhysicsMask.Bullets, EntityFilterAll())
            
            if trace.endPoint ~= endPoint then
                local cinematicCoords = Coords.GetIdentity()
                cinematicCoords.origin = trace.endPoint
                
                local cinematic = Client.CreateCinematic(RenderScene.Zone_Default)
                cinematic:SetCinematic(effectName)
                cinematic:SetCoords(cinematicCoords)
                
                numFakeShadesCreated = numFakeShadesCreated + 1
            end    
        
        end
    
    end
    
end
--]]

if Client then

    function ShadeInk:GetStartCinematic()
        return kStartEffect
    end

    function ShadeInk:Perform()
    
        --[[
        local player = Client.GetLocalPlayer()
        
        if player and player:isa("Marine") then
    
            local randomEffectName = GetRandomPhantomName(self.numHives, Shared.GetTime())
            
            local phantomEffect = Client.CreateCinematic(RenderScene.Zone_Default)
            phantomEffect:SetCinematic(randomEffectName)
            
            local direction = GetNormalizedVectorXZ(player:GetOrigin() - self:GetOrigin())
            local spawnPoint = self:GetOrigin() + direction * 6 + Vector(0, 4, 0) + player:GetViewCoords().xAxis * (math.random() - 0.5) * 3
            
            local coords = Coords.GetLookIn( GetGroundAtPosition(spawnPoint, EntityFilterAll(), PhysicsMask.Bullets, Vector(0.1, 0.1, 0.1)), -direction)
            phantomEffect:SetCoords(coords)
        
        end
        --]]
        
    end

end

function ShadeInk:GetRepeatCinematic()
    return kShadeInkAlienEffect
end

function ShadeInk:GetType()
    return ShadeInk.kType
end
    
function ShadeInk:GetLifeSpan()
    return kShadeInkDuration
end

function ShadeInk:GetUpdateTime()
    return kUpdateTime
end

if Server then

    local function OnCommandInkAll(client, distance)

        if Shared.GetCheatsEnabled() then
        
            for _, shade in ientitylist(Shared.GetEntitiesWithClassname("Shade")) do
                
                shade:TriggerInk()
                
            end
            
        end
        
    end

    Event.Hook("Console_inkall", OnCommandInkAll)
    
	function ShadeInk:Perform()
        for _, target in ipairs(GetEntitiesWithMixinForTeamWithinRange("Detectable", self:GetTeamNumber(), self:GetOrigin(), ShadeInk.kShadeInkDisorientRadius)) do
            target:SetDetected(false)
        end
        
        for _, target in ipairs(GetEntitiesWithMixinForTeamWithinRange("Cloakable", self:GetTeamNumber(), self:GetOrigin(), ShadeInk.kShadeInkDisorientRadius)) do
            target:InkCloak()
        end
    end
end

Shared.LinkClassToMap("ShadeInk", ShadeInk.kMapName, networkVars)