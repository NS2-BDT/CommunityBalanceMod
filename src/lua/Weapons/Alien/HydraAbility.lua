-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Alien\HydraStructureAbility.lua
--
--    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
--
-- Gorge builds hydra.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'HydraStructureAbility' (StructureAbility)

HydraStructureAbility.kDropRange = 6.5

function HydraStructureAbility:GetDropRange()
    return HydraStructureAbility.kDropRange
end

function HydraStructureAbility:GetEnergyCost()
    return kDropHydraEnergyCost
end

function HydraStructureAbility:GetGhostModelName(ability)       --TD-FIXME Needs means to swap mat

    local player = ability:GetParent()
    if player and player:isa("Gorge") then
    
        local clientVariants = GetAndSetVariantOptions()
        local variant = clientVariants.hydraVariant
        
        if variant == kHydraVariants.Shadow or variant == kHydraVariants.Auric then
            return Hydra.kModelNameShadow
        elseif variant == kHydraVariants.Abyss then
            return Hydra.kModelNameAbyss
        end
        
    end
    
    return Hydra.kModelName
    
end

function HydraStructureAbility:GetDropStructureId()
    return kTechId.Hydra
end

local function EntityCalculateHydraFilter(entity)
    return function (test) return EntityFilterOneAndIsa(entity, "Clog") or test:isa("Hydra") end
end

local function CalculateHydraPosition(position, player, normal)

    PROFILE("CalculateHydraPosition")

	local valid = true
    if valid then
        local extents = GetExtents(kTechId.Hydra) / 2.25
        local traceStart = position + normal * 0.15 -- A bit above to allow hydras to be placed on uneven ground easily
        local traceEnd = position + normal * extents.y
        trace = Shared.TraceBox(extents, traceStart, traceEnd, CollisionRep.Damage, PhysicsMask.Bullets, EntityCalculateHydraFilter(player))

        if trace.fraction ~= 1 then
            -- DebugTraceBox(extents, traceStart, traceEnd, 0.1, 45, 45, 45, 1)
            valid = false
        end
    end

    return valid

end

function HydraStructureAbility:GetIsPositionValid(position, player, surfaceNormal)

    PROFILE("HydraStructureAbility:GetIsPositionValid")

    return CalculateHydraPosition(position, player, surfaceNormal)

end

function HydraStructureAbility:GetSuffixName()
    return "hydra"
end

function HydraStructureAbility:GetDropClassName()
    return "Hydra"
end

function HydraStructureAbility:GetDropMapName()
    return Hydra.kMapName
end
