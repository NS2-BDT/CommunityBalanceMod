-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\CommandStation_Server.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

function CommandStation:GetTeamType()
    return kMarineTeamType
end

function CommandStation:GetCommanderClassName()
    return MarineCommander.kMapName
end

function CommandStation:GetIsPlayerValidForCommander(player)
    return player ~= nil and player:isa("Marine") and self:GetIsPlayerInside(player) and CommandStructure.GetIsPlayerValidForCommander(self, player)
end

function CommandStation:GetKillOrigin()
    return self:GetOrigin() + Vector(0, 1.5, 0)
end

local function KillPlayersInside(self)

    -- Now kill any other players that are still inside the command station so they're not stuck!
    -- Draw debug box if players are players on inside aren't dying or players on the outside are
    --DebugCircle(self:GetKillOrigin(), CommandStation.kCommandStationKillConstant, Vector(0, 1, 0), 1, 1, 1, 1, 1)
    
    for index, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
    
        if not player:isa("Commander") and not player:isa("Spectator") then
        
            if self:GetIsPlayerInside(player) and player:GetId() ~= self.playerIdStartedLogin then
            
                player:Kill(self, self, self:GetOrigin())
                
            end
            
        end
    
    end

end

function CommandStation:LoginPlayer(player, forced )

    local newCommanderPlayer = CommandStructure.LoginPlayer(self, player, forced )
    
    if GetTeamHasCommander(self:GetTeamNumber()) then
        KillPlayersInside(self)
    end

    return newCommanderPlayer
    
end

function CommandStation:OnConstructionComplete()
    self:TriggerEffects("deploy")    
end

function CommandStation:GetCompleteAlertId()
    return kTechId.MarineAlertCommandStationComplete
end

function CommandStation:GetDamagedAlertId()
    return kTechId.MarineAlertCommandStationUnderAttack
end

function CommandStation:OnEntityChange(oldEntityId, _)
    oldCommandStructureOnEntityChange(self, oldEntityId, _)

    if HasMixin(self, "MapBlip") then 
         self:MarkBlipDirty()
    end

end

-- %%% New CBM Functions %%% --
function CommandStation:OnEntityChange(oldEntityId, _)

    if HasMixin(self, "MapBlip") then 
         self:MarkBlipDirty()
    end

end