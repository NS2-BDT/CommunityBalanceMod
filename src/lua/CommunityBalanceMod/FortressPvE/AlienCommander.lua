
AlienCommander.kWhipFury = PrecacheAsset("sound/NS2.fev/alien/structures/whip/fury")
AlienCommander.kCragUmbra = PrecacheAsset("sound/NS2.fev/alien/structures/crag/umbra")


local function GetNearest(self, className)

    local ents = GetEntitiesForTeam(className, self:GetTeamNumber())
    Shared.SortEntitiesByDistance(self:GetOrigin(), ents)
    
    return ents[1]

end


--balance mod
local function GetNearestValid(self, className)

    local teamFilterFunction = CLambda [=[args ent; HasMixin(ent, "Team") and ent:GetTeamNumber() == self[1]]=] {self:GetTeamNumber()}
    local ents =  GetEntitiesWithFilter(Shared.GetEntitiesWithClassname(className), teamFilterFunction)

    for i = #ents, 1, -1 do 
        if ents[i]:GetIsConsuming() or not ents[i]:GetIsBuilt() or ents[i]:GetIsOnFire() then
            table.remove(ents, i)
        elseif className == "Shift" and not GetHasTech(self, kTechId.ShiftHive) and ents[i]:GetTechId() ~= kTechId.FortressShift then 
            table.remove(ents, i)
        elseif className == "Crag" and not GetHasTech(self, kTechId.CragHive) and ents[i]:GetTechId() ~= kTechId.FortressCrag then 
            table.remove(ents, i)
        elseif className == "Shade" and not GetHasTech(self, kTechId.ShadeHive) and ents[i]:GetTechId() ~= kTechId.FortressShade then 
            table.remove(ents, i)
        end
    end

    Shared.SortEntitiesByDistance(self:GetOrigin(), ents)

    return ents[1]

end




local function SelectNearest(self, className)

    local nearestEnt = GetNearest(self, className)
    
    if nearestEnt then

        DeselectAllUnits(self:GetTeamNumber())
        nearestEnt:SetSelected(self:GetTeamNumber(), true, false)
        if Server then
            Server.SendNetworkMessage(self, "SelectAndGoto", BuildSelectAndGotoMessage(nearestEnt:GetId()), true)
        end

        return true
    
    end
    
    return false

end

--balance mod 
local function SelectNearestValid(self, className)

    local nearestEnt = GetNearestValid(self, className)
    
    if nearestEnt then

        DeselectAllUnits(self:GetTeamNumber())
        nearestEnt:SetSelected(self:GetTeamNumber(), true, false)
        if Server then
            Server.SendNetworkMessage(self, "SelectAndGoto", BuildSelectAndGotoMessage(nearestEnt:GetId()), true)
        end

        return true
    
    end
    
    return false

end



if Server then

    local function GetIsPheromone(techId)    
        return techId == kTechId.ThreatMarker or techId == kTechId.LargeThreatMarker or techId ==  kTechId.NeedHealingMarker or techId == kTechId.WeakMarker or techId == kTechId.ExpandingMarker    
    end

    local function GetIsSelectTunnel(techId)
        return techId >= kTechId.SelectTunnelEntryOne and techId <= kTechId.SelectTunnelExitFour
    end




    function AlienCommander:ProcessTechTreeAction(techId, pickVec, orientation, worldCoordsSpecified, targetId, shiftDown)

        local success = false

        if techId == kTechId.Cyst then

            local trace = GetCommanderPickTarget(self, pickVec, worldCoordsSpecified, true, false)

            if trace.fraction ~= 1 then

                local legalBuildPosition, position, _, errorString = GetIsBuildLegal(techId, trace.endPoint, orientation, kStructureSnapRadius, self)

                if legalBuildPosition then
                    self:BuildCystChain(position)
                end

                if errorString then

                    local commander = self:isa("Commander") and self or self:GetOwner()
                    if commander then

                        local message = BuildCommanderErrorMessage(errorString, position)
                        Server.SendNetworkMessage(commander, "CommanderError", message, true)

                    end

                end

            end
        elseif techId >= kTechId.BuildTunnelEntryOne and techId <= kTechId.BuildTunnelExitFour then
            local team = self:GetTeam()
            local teamInfo = team:GetInfoEntity()

            local cost = GetCostForTech(techId)
            local teamResources = teamInfo:GetTeamResources()

            if cost > teamResources then
                self:TriggerNotEnoughResourcesAlert()
                return
            end

            local trace = GetCommanderPickTarget(self, pickVec, worldCoordsSpecified, true, false)

            if trace == nil or trace.fraction >= 1 then
                return
            end

            local legalBuildPosition, position, _, errorString = GetIsBuildLegal(techId, trace.endPoint, orientation,
                    kStructureSnapRadius, self)

            if not legalBuildPosition then

                local commander = self:isa("Commander") and self or self:GetOwner()
                if commander then

                    local message = BuildCommanderErrorMessage(errorString, position)
                    Server.SendNetworkMessage(commander, "CommanderError", message, true)
                    return
                end

            end

            local tunnelManager = teamInfo:GetTunnelManager()
            tunnelManager:CreateTunnelEntrance(position, techId)

            team:AddTeamResources(-cost)
        elseif techId == kTechId.TunnelExit or techId == kTechId.TunnelRelocate then

            -- Cost is in team resources, energy or individual resources, depending on tech node type
            local cost = GetCostForTech(techId)
            local team = self:GetTeam()
            local teamResources = team:GetTeamResources()

            if cost > teamResources then
                self:TriggerNotEnoughResourcesAlert()
                return
            end

            local trace = GetCommanderPickTarget(self, pickVec, worldCoordsSpecified, true, false)

            if trace == nil or trace.fraction >= 1 then
                return
            end

            local legalBuildPosition, position, _, errorString = GetIsBuildLegal(techId, trace.endPoint, orientation,
                    kStructureSnapRadius, self)

            if not legalBuildPosition then

                local commander = self:isa("Commander") and self or self:GetOwner()
                if commander then

                    local message = BuildCommanderErrorMessage(errorString, position)
                    Server.SendNetworkMessage(commander, "CommanderError", message, true)
                    return
                end

            end

            -- Commander must have another tunnel already selected in order to perform this action, figure out which
            -- one it is... because apparently that's not pertinent enough information to include in the damned
            -- message...
            -- If more than one tunnel is selected, cancel the whole damned thing.
            local selectedEntrance
            local selection = self:GetSelection()
            for i = 1, #selection do
                if selection[i]:isa("TunnelEntrance") then
                    if selectedEntrance then
                        return  -- more than one selected, abort.
                    else
                        selectedEntrance = selection[i]
                    end
                end
            end

            if not selectedEntrance then
                return
            end

            local otherEntrance
            if techId == kTechId.TunnelRelocate then
                otherEntrance = selectedEntrance:GetOtherEntrance()
                assert(otherEntrance)
            else
                otherEntrance = selectedEntrance
            end

            local teamInfo = team:GetInfoEntity()
            local tunnelManager = teamInfo:GetTunnelManager()
            tunnelManager:CreateTunnelEntrance(position, nil, otherEntrance)

            team:AddTeamResources(-cost)

            if techId == kTechId.TunnelRelocate then
                selectedEntrance:KillWithoutCollapse()
            end

        else
            success = Commander.ProcessTechTreeAction(self, techId, pickVec, orientation, worldCoordsSpecified, targetId, shiftDown)
        end

        if success then

            local soundToPlay

            if techId == kTechId.ShiftHatch then
                soundToPlay = AlienCommander.kShiftHatch
            elseif techId == kTechId.BoneWall then
                soundToPlay = AlienCommander.kBoneWallSpawnSound
            elseif techId == kTechId.HealWave then
                soundToPlay = AlienCommander.kHealWaveSound
            elseif techId == kTechId.ShadeInk then
                soundToPlay = AlienCommander.kShadeInkSound
            elseif techId == kTechId.Cyst then
                soundToPlay = AlienCommander.kCreateCystSound
            elseif techId == kTechId.NutrientMist then
                soundToPlay = AlienCommander.kCreateMistSound
            elseif techId == kTechId.Rupture then
                soundToPlay = AlienCommander.kRupterSound
            elseif techId == kTechId.Contamination then
                soundToPlay = AlienCommander.kContaminationSound
            elseif techId == kTechId.FortressCragAbility then  
                soundToPlay = AlienCommander.kCragUmbra
            elseif techId == kTechId.FortressShiftAbility then 
               soundToPlay = AlienCommander.kWhipFury 
            elseif techId == kTechId.ShadeHallucination then 
                 soundToPlay = AlienCommander.kWhipFury 
            elseif techId == kTechId.FortressWhipAbility then 
                soundToPlay = AlienCommander.kWhipFury
            elseif techId == kTechId.WhipAbility then 
                soundToPlay = AlienCommander.kWhipFury
            end

            if soundToPlay then
                Shared.PlayPrivateSound(self, soundToPlay, nil, 1.0, self:GetOrigin())
            end

        end

    end
    
    -- check if a notification should be send for successful actions
    function AlienCommander:ProcessTechTreeActionForEntity(techNode, position, normal, pickVec, orientation, entity, trace, targetId)
    
        local techId = techNode:GetTechId()
        local success = false
        local keepProcessing = false
        local processForEntity = true
        
        if not entity and ( techId == kTechId.ShadeInk or techId == kTechId.HealWave ) then
        
            local className = techId == kTechId.HealWave and "Crag" or "Shade"

            entity = GetNearestValid(self, className) -- balance mod
            processForEntity = entity ~= nil

        end



        if techId == kTechId.Cyst then
            success = self:BuildCystChain(position)
        elseif techId == kTechId.SelectDrifter then

            SelectNearest(self, "Drifter")

        elseif GetIsPheromone(techId) then

            success = CreatePheromone(techId, position, self:GetTeamNumber()) ~= nil
            keepProcessing = false
        elseif GetIsSelectTunnel(techId) then
            local teamInfo = GetTeamInfoEntity(self:GetTeamNumber())
            local tunnelmanager = teamInfo:GetTunnelManager()
            local entrance = tunnelmanager:GetTunnelEntrance(techId)

            if entrance then
                local teamNumber = self:GetTeamNumber()
                DeselectAllUnits(teamNumber)
                entrance:SetSelected(teamNumber, true, false)
                if Server then
                    Server.SendNetworkMessage(self, "SelectAndGoto", BuildSelectAndGotoMessage(entrance:GetId()), true)
                end

                success = true
            end
        end
        
        if not success and processForEntity then
            success, keepProcessing = Commander.ProcessTechTreeActionForEntity(self, techNode, position, normal, pickVec, orientation, entity, trace, targetId)
        end
        
        return success, keepProcessing
        
    end
    
end



function AlienCommander:GetTechAllowed(techId, techNode)

    local allowed, canAfford = Commander.GetTechAllowed(self, techId, techNode)
    
    if techId == kTechId.SelectDrifter then
    
        allowed = true
        canAfford = true
        
    elseif techId == kTechId.SelectShift then
    
        allowed = GetNearestValid(self, "Shift") ~= nil
        allowed = allowed and ( GetHasTech(self, kTechId.ShiftHive) or GetHasTech(self, kTechId.FortressShift) ) -- balance mod
        canAfford = true
    
    elseif techId == kTechId.HealWave then
    
        allowed = GetNearestValid(self, "Crag") ~= nil
        allowed = allowed and ( GetHasTech(self, kTechId.CragHive) or GetHasTech(self, kTechId.FortressCrag) )-- balance mod
    
    elseif techId == kTechId.ShadeInk then
    
        allowed = GetNearestValid(self, "Shade") ~= nil
        allowed = allowed and ( GetHasTech(self, kTechId.ShadeHive) or GetHasTech(self, kTechId.FortressShade) ) -- balance mod

    end    
    
    return allowed, canAfford
    
end    
