--________________________________
--
--  NS2: Combat
--    Copyright 2014 Faultline Games Ltd.
--  and Unknown Worlds Entertainment Inc.
--
--________________________________

class 'SentryAbility'(Entity)

local kExtents = Vector(0.4, 0.5, 0.4) -- 0.5 to account for pathing being too high/too low making it hard to palce tunnels
local function IsPathable(position)
    
    local noBuild = Pathing.GetIsFlagSet(position, kExtents, Pathing.PolyFlag_NoBuild)
    local walk = Pathing.GetIsFlagSet(position, kExtents, Pathing.PolyFlag_Walk)
    return not noBuild and walk

end

local kUpVector = Vector(0, 1, 0)
local kCheckDistance = 0.8 -- bigger than onos
local kVerticalOffset = 0.3
local kVerticalSpace = 2

local kCheckDirections = {
    Vector(kCheckDistance, 0, -kCheckDistance),
    Vector(kCheckDistance, 0, kCheckDistance),
    Vector(-kCheckDistance, 0, kCheckDistance),
    Vector(-kCheckDistance, 0, -kCheckDistance),
}

function SentryAbility:GetIsPositionValid(position, player, surfaceNormal)
    
    local valid = false
    
    --/ allow only on even surfaces
    if surfaceNormal then
        
        if not IsPathable(position) then
            valid = false
        
        elseif surfaceNormal:DotProduct(kUpVector) > 0.9 then
            
            valid = true
            
            local startPos = position + Vector(0, kVerticalOffset, 0)
            
            for i = 1, #kCheckDirections do
                
                local traceStart = startPos + kCheckDirections[i]
                
                local trace = Shared.TraceRay(traceStart, traceStart - Vector(0, kVerticalOffset + 0.1, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, EntityFilterOneAndIsa(player, "Babbler"))
                
                if trace.fraction < 0.60 or trace.fraction >= 1.0 then
                    --the max slope a sentry can be placed on.
                    valid = false
                    break
                end
            
            end
        
        
        end
    
    end
    
    return valid
end

function SentryAbility:AllowBackfacing()
    return false
end

function SentryAbility:GetDropRange()
    return kGorgeCreateDistance
end

function SentryAbility:GetStoreBuildId()
    return false
end

function SentryAbility:GetEnergyCost(player)
    return kDropStructureEnergyCost
end

function SentryAbility:GetGhostModelName(ability)
    return Sentry.kModelName
end

function SentryAbility:GetDropStructureId()
    return kTechId.Sentry
end

function SentryAbility:GetSuffixName()
    return "Sentry"
end

function SentryAbility:GetDropClassName()
    return "Sentry"
end

function SentryAbility:GetDropMapName()
    return Sentry.kMapName
end

function SentryAbility:CreateStructure()
    return false
end

function SentryAbility:IsAllowed(player)
    return true
end
