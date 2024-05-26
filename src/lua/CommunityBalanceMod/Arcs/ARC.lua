-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\ARC.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- AI controllable "tank" that the Commander can move around, deploy and use for long-distance
-- siege attacks.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

-- This didn't work because the other stuff needs to be loaded... I'm not sure what the best way of going about that is.
function ARC:GetCanFireAtTargetActual(target, targetPoint, manuallyTargeted)

    if not target.GetReceivesStructuralDamage or not target:GetReceivesStructuralDamage() then        
        return false
    end
    

    -- don't target eggs (they take only splash damage)
    -- Hydra exclusion has to due with people using them to prevent ARC shooting Hive. 
    if target:isa("Egg") or target:isa("Cyst") or target:isa("Contamination") then
        return false
    end

    if not manuallyTargeted and target:isa("Hydra") then
        return false
    end
	
	if not manuallyTargeted and target:isa("Hallucination") then
        return false
    end
    
    if not target:GetIsSighted() and not GetIsTargetDetected(target) then
        return false
    end
    
    local distToTarget = (target:GetOrigin() - self:GetOrigin()):GetLengthXZ()
    if (distToTarget > ARC.kFireRange) or (distToTarget < ARC.kMinFireRange) then
        return false
    end
    
    return true
    
end