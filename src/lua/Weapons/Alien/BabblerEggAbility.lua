-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Alien\BabblerEggAbility.lua
--
--    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'BabblerEggAbility' (StructureAbility)

function BabblerEggAbility:GetEnergyCost(player)
    return kDropBabblerEggEnergyCost
end

function BabblerEggAbility:GetGhostModelName(ability)       --TD-FIXME Needs means to swap mat

    local player = ability:GetParent()
    if player and player:isa("Gorge") then
    
        local clientVariants = GetAndSetVariantOptions()
        local variant = clientVariants.babblerEggVariant
        
        if variant == kBabblerEggVariants.Shadow or variant == kBabblerEggVariants.Auric then
            return BabblerEgg.kModelNameShadow
        elseif variant == kBabblerEggVariants.Abyss then
            return BabblerEgg.kModelNameAbyss
        end
        
    end
    
    return BabblerEgg.kModelName
    
end

function BabblerEggAbility:GetDropStructureId()
    return kTechId.BabblerEgg
end

local function EntityCalculateBabblerEggFilter(entity)
    return function (test) return EntityFilterOneAndIsa(entity, "Clog") or test:isa("Hydra") or test:isa("BabblerEgg") end
end

local function CalculateBabblerEggPosition(position, player, normal)

    PROFILE("CalculateBabblerEggPosition")

    local valid = true
    if valid then
        local realExtents = GetExtents(kTechId.BabblerEgg)
        local extents = GetExtents(kTechId.BabblerEgg) / 3.00

        local traceStart = position + normal * (realExtents.y - realExtents.y * (30/100))
        local traceEnd   = position + normal * (realExtents.y + 0.01)

        trace = Shared.TraceBox(extents, traceStart, traceEnd, CollisionRep.Damage, PhysicsMask.Bullets, EntityCalculateBabblerEggFilter(player))

        if trace.fraction ~= 1 and not GetIsPointInsideClogs(traceEnd) then
            -- DebugTraceBox(extents, traceStart, traceEnd, 0.1, 45, 45, 45, 1)
            valid = false
        end
    end

    return valid

end

function BabblerEggAbility:GetIsPositionValid(position, player, normal, lastClickedPosition, _, entity)

    PROFILE("BabblerEggAbility:GetIsPositionValid")

    return CalculateBabblerEggPosition(position, player, normal)

end

function BabblerEggAbility:GetSuffixName()
    return "babbleregg"
end

function BabblerEggAbility:GetDropClassName()
    return "BabblerEgg"
end

function BabblerEggAbility:GetDropRange()
    return BabblerEgg.kDropRange
end

function BabblerEggAbility:GetDropMapName()
    return BabblerEgg.kMapName
end
