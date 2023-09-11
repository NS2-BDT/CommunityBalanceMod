

Script.Load("lua/CommunityBalanceMod/FortressPvE/TwiliteShade/ShadeHallucination.lua")


--Shade.kHallucinateRange = 8 -- 40
function Shade:GetTechButtons(techId)

    local techButtons = { kTechId.ShadeInk, kTechId.Move, kTechId.ShadeHallucination, kTechId.ShadeCloak, 
                          kTechId.None, kTechId.None, kTechId.None, kTechId.Consume }
    --local techButtons = { kTechId.ShadeInk, kTechId.Move, kTechId.ShadePhantomStructuresMenu, kTechId.ShadeCloak, 
    --                      kTechId.None, kTechId.None, kTechId.None, kTechId.Consume }
    if self.moving then
        techButtons[2] = kTechId.Stop
    end

    return techButtons
    
end

--[[function Shade:GetIsInCloudRange(targetPos)

    PROFILE("Shade:GetIsInEnzymeRange")

    local origin = self:GetOrigin()

    if (targetPos - origin):GetLength() < Shade.kHallucinateRange then

        local trace = Shared.TraceRay(origin, targetPos, CollisionRep.LOS, PhysicsMask.Bullets, EntityFilterAll())
        return trace.fraction == 1

    end

    return false

end--]]

function Shade:TriggerHallucinations()

    -- Create ShadeHallucination entity in world at this position with a small offset
    CreateEntity(ShadeHallucination.kMapName, self:GetOrigin() + Vector(0, 0.2, 0), self:GetTeamNumber())
    return true

end

function Shade:PerformActivation(techId, position, normal, commander)

    local success = false
    
    if techId == kTechId.ShadeInk then
        success = self:TriggerInk()
    elseif techId == kTechId.ShadeHallucination then
        success = self:TriggerHallucinations()
    end
    
    return success, true
    
end

if Server then

    function Shade:OnKill(attacker, doer, point, direction)
        
        ScriptActor.OnKill(self, attacker, doer, point, direction)

        if self.hallucinations then
            for _, entId in ipairs(self.hallucinations) do
                if entId ~= Entity.InvalidId then
                    local ent = Shared.GetEntity(entId)
                    if ent then
                        if HasMixin(ent, "Live") and (ent:GetIsAlive()) then
                            ent:Kill()
                        end
                    end
                end
            end
        end

        self.hallucinations = {}

    end
    
end