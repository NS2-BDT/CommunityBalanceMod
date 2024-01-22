-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


--
--      Creates a hallucination of nearby alien structures.

Script.Load("lua/CommAbilities/CommanderAbility.lua")

class 'ShadeHallucination' (CommanderAbility)

ShadeHallucination.kMapName = "shadehallucination"

ShadeHallucination.kSplashEffect = PrecacheAsset("cinematics/alien/hallucinationcloud.cinematic")
ShadeHallucination.kType = CommanderAbility.kType.Instant

ShadeHallucination.kRadius = 9.0 -- Shade.kCloakRadius

-- use this table to for selection of hallucinations from now
-- duplicates are allowed, and increases chances to draw
local hallucinateStructureTypes = {
    kTechId.HallucinateShade,
    kTechId.HallucinateWhip,
    kTechId.HallucinateWhip,
    kTechId.HallucinateWhip, -- triples the spawn chance
    kTechId.HallucinateCrag,
    kTechId.HallucinateShift,
    kTechId.HallucinateShell,
    kTechId.HallucinateSpur,
    kTechId.HallucinateVeil,
    kTechId.HallucinateEgg,
}
                                            
local networkVars = { }

function ShadeHallucination:OnInitialized()
    CommanderAbility.OnInitialized(self)

end

function ShadeHallucination:GetStartCinematic()
    return nil
end

function ShadeHallucination:GetType()
    return ShadeHallucination.kType
end

function ShadeHallucination:RegisterHallucination(entity)
    
    if not self.hallucinations then
        self.hallucinations = {}
    end
    
    table.insert(self.hallucinations, entity:GetId())
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

    local kNoCollideClassNameList =
    {
    "Babbler",
    "FortressShade",
    "Hallucination"
    }


    function ShadeHallucination:Perform()

        -- kill all hallucinations before, to prevent unreasonable spam
        for _, hallucination in ipairs(GetEntitiesForTeam("Hallucination", self:GetTeamNumber())) do
            hallucination.consumed = true
            hallucination:Kill()
        end
        
        local shadeExtents = Vector(1, 1.3, 1) --Vector(Shade.kXExtents, Shade.kYExtents, Shade.kZExtents)
        local maxAllowedHallucinations = math.max(1, kMaxHallucinations)

        for i = 1, maxAllowedHallucinations do
            local hallucType = hallucinateStructureTypes[ math.random( #hallucinateStructureTypes ) ]

            local newHallucExtents = LookupTechData(hallucType, kTechDataMaxExtents, shadeExtents)
            local hallucOrigin = self:GetOrigin()

            local _, capsuleRadius = GetTraceCapsuleFromExtents(newHallucExtents)

            local spawnPoint 
            
            -- Don't oversearch, each GetRandomSpawnForCapsule already does that 10 times
            for _ = 1, 20 do
                
                local randomOrigin = GetRandomSpawnForCapsule(newHallucExtents.y, capsuleRadius, hallucOrigin, capsuleRadius, ShadeHallucination.kRadius, EntityFilterAll())
     
                if randomOrigin then
                    local groundtrace = Shared.TraceRay(randomOrigin, randomOrigin - Vector(0, 40, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdollsAndBabblers, EntityFilterAll())
                    
                    if groundtrace.fraction < 1 then
                        spawnPoint = groundtrace.endPoint
                        break 
                    end
                end
            end
            
            if spawnPoint then
                
                local spawnOffset = Vector(0, 0, 0)
                spawnPoint = spawnPoint + spawnOffset 
                        
                local hallucinationClassName = Hallucination.kMapName --kHallucinationClassNameMap[alien:GetMapName()] or Hallucination.kMapName
                local hallucination = CreateEntity(hallucinationClassName, spawnPoint, self:GetTeamNumber())
                hallucination:SetEmulation(hallucType)

                -- make shade keep a record of any hallucinations created from its cloud, so they
                -- die when shade dies.
                self:RegisterHallucination(hallucination)

            else -- spawn hallucination near centre of cloud/shade, since a good spawn position was not found
            
                local hallucinationClassName = Hallucination.kMapName
                local spawnOffset =  Vector(0, 0, 0)
                local traceVector = Vector(math.random() - 0.5, -0.05, math.random() - 0.5) * ShadeHallucination.kRadius * 2
                local finalTrace = Shared.TraceRay(hallucOrigin, hallucOrigin + traceVector, CollisionRep.Default, PhysicsMask.AIMovement, EntityFilterAllButIsaList(kNoCollideClassNameList))
                local hallucination = CreateEntity(hallucinationClassName, finalTrace.endPoint + spawnOffset, self:GetTeamNumber())
                hallucination:SetEmulation(hallucType)

                self:RegisterHallucination(hallucination)
            end

        end
        
    end
end

Shared.LinkClassToMap("ShadeHallucination", ShadeHallucination.kMapName, networkVars)