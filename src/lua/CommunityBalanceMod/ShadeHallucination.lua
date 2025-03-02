-- ====**** Scripts\ShadeHallucination.lua ****====
-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\CommAbilities\Alien\ShadeHallucination.lua
--
--      Created by: Andreas Urwalek (andi@unknownworlds.com)
--
--      Creates a hallucination of nearby alien structures.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/CommanderAbility.lua")

class 'ShadeHallucination' (CommanderAbility)

ShadeHallucination.kMapName = "shadehallucination"

local kSplashEffect = PrecacheAsset("cinematics/alien/hallucinationcloud.cinematic")
ShadeHallucination.kType = CommanderAbility.kType.Instant

ShadeHallucination.kRadius = 9.0 -- Shade.kCloakRadius

-- overwriting the global GetHallucinationTechId function did not work...
-- not going to use this at all
--[[local gTechIdToHallucinateTechId
local function GetHallucinationTechId(techId)
    if not gTechIdToHallucinateTechId then
    
        gTechIdToHallucinateTechId = {}
        gTechIdToHallucinateTechId[kTechId.Drifter] = kTechId.HallucinateDrifter
        gTechIdToHallucinateTechId[kTechId.Skulk] = kTechId.HallucinateSkulk
        gTechIdToHallucinateTechId[kTechId.Gorge] = kTechId.HallucinateGorge
        gTechIdToHallucinateTechId[kTechId.Lerk] = kTechId.HallucinateLerk
        gTechIdToHallucinateTechId[kTechId.Fade] = kTechId.HallucinateFade
        gTechIdToHallucinateTechId[kTechId.Onos] = kTechId.HallucinateOnos
        
        gTechIdToHallucinateTechId[kTechId.Hive] = kTechId.HallucinateHive
        gTechIdToHallucinateTechId[kTechId.Whip] = kTechId.HallucinateWhip
        gTechIdToHallucinateTechId[kTechId.Shade] = kTechId.HallucinateShade
        gTechIdToHallucinateTechId[kTechId.Crag] = kTechId.HallucinateCrag
        gTechIdToHallucinateTechId[kTechId.Shift] = kTechId.HallucinateShift
        gTechIdToHallucinateTechId[kTechId.Harvester] = kTechId.HallucinateHarvester
        gTechIdToHallucinateTechId[kTechId.Hydra] = kTechId.HallucinateHydra
        
        gTechIdToHallucinateTechId[kTechId.Shell] = kTechId.HallucinateShell
        gTechIdToHallucinateTechId[kTechId.Spur] = kTechId.HallucinateSpur
        gTechIdToHallucinateTechId[kTechId.Veil] = kTechId.HallucinateVeil
    end
    
    return gTechIdToHallucinateTechId[techId]

end--]]

-- use this table to for selection of hallucinations from now
-- duplicates are allowed, and increases chances to draw
local hallucinateStructureTypes = {
    kTechId.HallucinateShade,
    kTechId.HallucinateShade, -- doubles the spawn chance
    kTechId.HallucinateWhip,
    kTechId.HallucinateWhip,
    kTechId.HallucinateWhip, -- triples the spawn chance
    kTechId.HallucinateCrag,
    kTechId.HallucinateShift,
    kTechId.HallucinateShell,
    kTechId.HallucinateSpur,
    kTechId.HallucinateVeil,
    kTechId.HallucinateDrifter,
    kTechId.HallucinateEgg,
}
                                            
local networkVars = { }

function ShadeHallucination:OnInitialized()
    
    if Server then
        -- sound feedback
        --self:TriggerEffects("enzyme_cloud")
    end
    
    CommanderAbility.OnInitialized(self)

end

function ShadeHallucination:GetStartCinematic()
    return nil -- kSplashEffect
end

function ShadeHallucination:GetType()
    return ShadeHallucination.kType
end

function ShadeHallucination:RegisterHallucination(entity)
    
    if not self.hallucinations then
        self.hallucinations = {}
    end
    
    table.insert(self.hallucinations, entity:GetId())
    --Print("Hallu %s", entity:GetId())
end

function ShadeHallucination:GetRegisteredHallucinations()
    return self.hallucinations or {}
end

local function AllowedToHallucinate(entity)

    local allowed = true
    if entity.timeLastHallucinated and entity.timeLastHallucinated + kShadeHallucinationCooldown > Shared.GetTime() then
        allowed = false
    else
        entity.timeLastHallucinated = Shared.GetTime()
    end    
    
    return allowed

end

if Server then

    -- sort by techId, so the higher life forms are prefered
    local function SortByTechIdAndInRange(alienOne, alienTwo)
        local inRangeOne = alienOne.__inShadeHallucinationRange
        if inRangeOne == alienTwo.__inShadeHallucinationRange then
            if inRangeOne then
                return alienOne:GetTechId() > alienTwo:GetTechId()
            else
                return alienOne:GetTechId() < alienTwo:GetTechId()
            end
        end

        return inRangeOne
    end

    local kNoCollideClassNameList =
    {
    "Babbler",
    "FortressShade",
    "Hallucination"
    }

   --[[ local kHallucinationClassNameMap = {
        [Skulk.kMapName] = SkulkHallucination.kMapName,
        [Gorge.kMapName] = GorgeHallucination.kMapName,
        [Lerk.kMapName] = LerkHallucination.kMapName,
        [Fade.kMapName] = FadeHallucination.kMapName,
        [Onos.kMapName] = OnosHallucination.kMapName
    }--]]
    
    function ShadeHallucination:Perform()

        -- kill all hallucinations before, to prevent unreasonable spam
        for _, hallucination in ipairs(GetEntitiesForTeam("Hallucination", self:GetTeamNumber())) do
            hallucination.consumed = true
            hallucination:Kill()
        end

        --[[for _, playerHallucination in ipairs(GetEntitiesForTeam("Alien", self:GetTeamNumber())) do

            if playerHallucination.isHallucination then
                playerHallucination:TriggerEffects("death_hallucination")
                DestroyEntity(playerHallucination)
            end

        end--]]

        --[[local drifter = GetEntitiesForTeamWithinRange("Drifter", self:GetTeamNumber(), self:GetOrigin(), ShadeHallucination.kRadius)[1]
        if drifter then

            if AllowedToHallucinate(drifter) then

                local angles = drifter:GetAngles()
                angles.pitch = 0
                angles.roll = 0
                local origin = GetGroundAt(self, drifter:GetOrigin() + Vector(0, .1, 0), PhysicsMask.Movement, EntityFilterOne(drifter))

                local hallucination = CreateEntity(Hallucination.kMapName, origin, self:GetTeamNumber())
                self:RegisterHallucination(hallucination)
                hallucination:SetEmulation(GetHallucinationTechId(kTechId.Drifter))
                hallucination:SetAngles(angles)

                local randomDestinations = GetRandomPointsWithinRadius(drifter:GetOrigin(), 4, 10, 10, 1, 1, nil, nil)
                if randomDestinations[1] then
                    -- Make sure drifters don't throttle their update rate which causes movement stutters
                    hallucination:SetUpdates(true, kRealTimeUpdateRate)

                    -- Give random movement order so hallucination doesn't overlap with existing drifter
                    hallucination:GiveOrder(kTechId.Move, nil, randomDestinations[1], nil, true, true)
                end

            end

        end--]]

        -- limit max num of hallucinations to 3
        --[[local aliens = GetEntitiesForTeam("Player", self:GetTeamNumber())
        local teamSize = #aliens
        local numHallcinations = kMaxHallucinations

        local origin = self:GetOrigin()
        local radius = ShadeHallucination.kRadius
        local radiusSquared = radius * radius
        
        --]]
        -- TODO: change hallucinate to targetted ability to clone a structure?
        --[[for i = 1, numHallcinations do
            local alien = aliens[i]
            alien.__inShadeHallucinationRange = alien:GetIsAlive() and alien:GetDistanceSquared(origin) <= radiusSquared
        end
        table.sort(aliens, SortByTechIdAndInRange)
        --]]
        
        --[[local skulkExtends = Vector(Skulk.kXExtents, Skulk.kYExtents, Skulk.kZExtents)
        local maxAllowedHallucinations = math.max(1, math.floor(numHallcinations * kPlayerHallucinationNumFraction))
        for i = 1, maxAllowedHallucinations do
            local alien = aliens[i]
            if AllowedToHallucinate(alien) then
                local newAlienExtents = LookupTechData(alien:GetTechId(), kTechDataMaxExtents, skulkExtends)
                local alienOrigin = alien.__inShadeHallucinationRange and alien:GetModelOrigin() or origin

                local _, capsuleRadius = GetTraceCapsuleFromExtents(newAlienExtents)

                local spawnPoint = GetRandomSpawnForCapsule(newAlienExtents.y, capsuleRadius, alienOrigin, 0.5, 5)

                if spawnPoint then

                    local hallucinationClassName = kHallucinationClassNameMap[alien:GetMapName()] or SkulkHallucination.kMapName
                    local hallucination = CreateEntity(hallucinationClassName, spawnPoint, self:GetTeamNumber())
                    hallucination:SetEmulation(alien)

                    -- For bot exploring
                    SetPlayerStartingLocation(hallucination)

                    -- make drifter keep a record of any hallucinations created from its cloud, so they
                    -- die when drifter dies.
                    self:RegisterHallucination(hallucination)

                else
                    maxAllowedHallucinations = math.min(maxAllowedHallucinations + 1, numHallcinations)
                end

            else
                maxAllowedHallucinations = math.min(maxAllowedHallucinations + 1, numHallcinations)
            end
        end--]]
        
        local shadeExtents = Vector(1, 1.3, 1) --Vector(Shade.kXExtents, Shade.kYExtents, Shade.kZExtents)
        local maxAllowedHallucinations = math.max(1, kMaxHallucinations)

        for i = 1, maxAllowedHallucinations do
            local hallucType = hallucinateStructureTypes[ math.random( #hallucinateStructureTypes ) ]
            --Print("type "..ToString(hallucType))
            local newHallucExtents = LookupTechData(hallucType, kTechDataMaxExtents, shadeExtents)
            local hallucOrigin = self:GetOrigin()

            local _, capsuleRadius = GetTraceCapsuleFromExtents(newHallucExtents)

            local spawnPoint 
            
            -- Don't oversearch, each GetRandomSpawnForCapsule already does that 10 times
            for _ = 1, 20 do
                
                --[[local distance = math.max(2, math.random() * ShadeHallucination.kRadius) -- minimum spawn distance of 2
                local direction = Vector(math.random() - 0.5, math.random() * 0.05, math.random() - 0.5)
                VectorSetLength(direction, distance)
                
                local randomOrigin = nil
                local trace = Shared.TraceRay( hallucOrigin, hallucOrigin + direction, CollisionRep.Damage, PhysicsMask.Movement )
                local groundTrace = Shared.TraceRay( trace.endPoint, trace.endPoint - Vector(0, 40, 0), CollisionRep.Move, PhysicsMask.Movement )
                
                if groundTrace.fraction < 1 then
                    
                    randomOrigin = GetRandomSpawnForCapsule(newHallucExtents.y, capsuleRadius, groundTrace.endPoint, capsuleRadius, capsuleRadius * 2, EntityFilterAll())
                    
                end
                
                if randomOrigin then
                
                    local groundTrace2 = Shared.TraceRay(randomOrigin, randomOrigin - Vector(0, 40, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdollsAndBabblers, EntityFilterAll())
                    if groundTrace2.fraction < 1 then
                        spawnPoint = groundTrace2.endPoint --GetGroundAtPointWithCapsule(randomOrigin, newHallucExtents, PhysicsMask.CommanderBuild, EntityFilterOne(self))
                        break 
                    end
                
                end--]]
                
                local randomOrigin = GetRandomSpawnForCapsule(newHallucExtents.y, capsuleRadius, hallucOrigin, capsuleRadius, ShadeHallucination.kRadius, EntityFilterAll())
                -- ground traced capsule is returning nil for some reason
                --spawnPoint = GetGroundAtPointWithCapsule(randomOrigin, newHallucExtents, PhysicsMask.Movement, EntityFilterAll())
                if randomOrigin then
                    local groundtrace = Shared.TraceRay(randomOrigin, randomOrigin - Vector(0, 40, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdollsAndBabblers, EntityFilterAll())
                    
                    if groundtrace.fraction < 1 then
                        spawnPoint = groundtrace.endPoint --GetGroundAtPointWithCapsule(randomOrigin, newHallucExtents, PhysicsMask.CommanderBuild, EntityFilterOne(self))
                        break 
                    end
                end
                
                
            end
            
            -- Print(ToString(hallucType).." &"..ToString(GetHallucinationTechId(hallucType)))
            if spawnPoint then
                
                local spawnOffset = (hallucType == kTechId.HallucinateDrifter) and Vector(0, Drifter.kHoverHeight, 0) or Vector(0, 0, 0)
                spawnPoint = spawnPoint + spawnOffset --GetGroundAtPointWithCapsule(randomOrigin, newHallucExtents, PhysicsMask.CommanderBuild, EntityFilterOne(self))
                        
                local hallucinationClassName = Hallucination.kMapName --kHallucinationClassNameMap[alien:GetMapName()] or Hallucination.kMapName
                local hallucination = CreateEntity(hallucinationClassName, spawnPoint, self:GetTeamNumber())
                hallucination:SetEmulation(hallucType)

                -- For bot exploring
                --SetPlayerStartingLocation(hallucination)

                -- make shade keep a record of any hallucinations created from its cloud, so they
                -- die when shade dies.
                self:RegisterHallucination(hallucination)

            else -- spawn hallucination near centre of cloud/shade, since a good spawn position was not found
            
                --maxAllowedHallucinations = math.min(maxAllowedHallucinations + 1, kMaxHallucinations)
                local hallucinationClassName = Hallucination.kMapName
                local spawnOffset = (hallucType == kTechId.HallucinateDrifter) and Vector(0, Drifter.kHoverHeight, 0) or Vector(0, 0, 0)
                local traceVector = Vector(math.random() - 0.5, -0.05, math.random() - 0.5) * ShadeHallucination.kRadius * 2
                local finalTrace = Shared.TraceRay(hallucOrigin, hallucOrigin + traceVector, CollisionRep.Default, PhysicsMask.AIMovement, EntityFilterAllButIsaList(kNoCollideClassNameList))
                local hallucination = CreateEntity(hallucinationClassName, finalTrace.endPoint + spawnOffset, self:GetTeamNumber())
                hallucination:SetEmulation(hallucType)

                -- For bot exploring
                --SetPlayerStartingLocation(hallucination)

                self:RegisterHallucination(hallucination)
            end

        end
        
        --[[for _, resourcePoint in ipairs(GetEntitiesWithinRange("ResourcePoint", self:GetOrigin(), ShadeHallucination.kRadius)) do
            
                if resourcePoint:GetAttached() == nil and GetIsPointOnInfestation(resourcePoint:GetOrigin()) then
                
                    local hallucination = CreateEntity(Hallucination.kMapName, resourcePoint:GetOrigin(), self:GetTeamNumber())
                    self:RegisterHallucination(hallucination)
                    hallucination:SetEmulation(kTechId.HallucinateHarvester)
                    hallucination:SetAttached(resourcePoint)
                    
                end
            
            end
        
            for _, techPoint in ipairs(GetEntitiesWithinRange("TechPoint", self:GetOrigin(), ShadeHallucination.kRadius)) do
            
                if techPoint:GetAttached() == nil then
                
                    local coords = techPoint:GetCoords()
                    coords.origin = coords.origin + Vector(0, 2.494, 0)
                    local hallucination = CreateEntity(Hallucination.kMapName, techPoint:GetOrigin(), self:GetTeamNumber())
                    self:RegisterHallucination(hallucination)
                    hallucination:SetEmulation(kTechId.HallucinateHive)
                    hallucination:SetAttached(techPoint)
                    hallucination:SetCoords(coords)
                    
                end
            
            end--]]
            
    end

end

Shared.LinkClassToMap("ShadeHallucination", ShadeHallucination.kMapName, networkVars)
