-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\CommandStructure_Server.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local kCheckForLoginTimer = 0.25

function CommandStructure:SetCustomPhysicsGroup()
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
end

function CommandStructure:OnKill(attacker, doer, point, direction)

    self:Logout()
    ScriptActor.OnKill(self, attacker, doer, point, direction)
    
    -- NOTE: Shared.GetEntity(self.objectiveInfoEntId) shouldn't be needed here.
    -- Please remove this code once we have the EntityRef() object implemented.
    if self.objectiveInfoEntId and self.objectiveInfoEntId ~= Entity.invalidId and Shared.GetEntity(self.objectiveInfoEntId) then
    
        DestroyEntity(Shared.GetEntity(self.objectiveInfoEntId))
        self.objectiveInfoEntId = Entity.invalidId
        
    end

end

function CommandStructure:OnSighted(sighted)

    local attached = self:GetAttached()
    if attached and sighted then
        attached.showObjective = true
    end

end

-- Children should override this
function CommandStructure:GetTeamType()
    return kNeutralTeamType
end

local function CheckForLogin(self)

    self:UpdateCommanderLogin()
    return true
    
end

function CommandStructure:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self.commanderId = Entity.invalidId
    self.occupied = false
    self.closedTime = 0
    self.loginAllowed = false
    self:AddTimedCallback(CheckForLogin, kCheckForLoginTimer)
    
    if Server then
    
        local objectiveInfoEnt = CreateEntity(ObjectiveInfo.kMapName, self:GetOrigin(), self:GetTeamNumber())
        objectiveInfoEnt:SetOwner(self:GetId())
        self.objectiveInfoEntId = objectiveInfoEnt:GetId()
    
    end
    
end

function CommandStructure:OnDestroy()
    
    -- NOTE: Shared.GetEntity(self.objectiveInfoEntId) shouldn't be needed here.
    -- Please remove this code once we have the EntityRef() object implemented.
    if self.objectiveInfoEntId and self.objectiveInfoEntId ~= Entity.invalidId and Shared.GetEntity(self.objectiveInfoEntId) then
    
        DestroyEntity(Shared.GetEntity(self.objectiveInfoEntId))
        self.objectiveInfoEntId = Entity.invalidId
        
    end

    local commandStructures = GetEntitiesForTeam("CommandStructure", self:GetTeamNumber())
    local isLastStructure = true

    for _, structure in ipairs(commandStructures) do
        if structure and structure:GetId() ~= self:GetId() then
            isLastStructure = false
        end
    end

    -- NOTE: immediately cancels danger music when chair destroyed as this chair will no longer be around to ensure it's stopped "at the right time"
    -- Danger music is allowed to continue as "end game" music if this was the last structure on the team
    if self.dangerMusicActive and not isLastStructure then
        Server.SendNetworkMessage("DangerMusicUpdate", { origin = self:GetOrigin(), teamIndex = self:GetTeamNumber(), active = false })
    end
    
    ScriptActor.OnDestroy(self)
    
end

--Called via timed callback defined in CommandStructure.lua - OnCreate
function CommandStructure:UpdateDangerMusicState()

    local time = Shared.GetTime()

    if not self.dangerMusicActive then

        local isValidStructure = 
            self:GetIsAlive() and self:GetIsBuilt() and GetGamerules():GetGameStarted() and 
            self:GetIsInCombat() and self:GetHealthScalar() <= kDangerMusicHealthStartAmount and
            not self.dangerMusicActive and self:GetTeam():GetNumCommandStructures() == 1

        if isValidStructure then

            self.dangerMusicActive = true
            self.lastDangerMusicTime = time

            --send to all, reliable channel
            Server.SendNetworkMessage("DangerMusicUpdate", { origin = self:GetOrigin(), teamIndex = self:GetTeamNumber(), active = self.dangerMusicActive }, true )

        end

    else

        --Only send no danger when game is still going
        local noDanger = 
            not self:GetIsInCombat() and self.lastDangerMusicTime + kDangerMusicMinDelayTime <= time and
            not GetGameInfoEntity():GetGameEnded() and self:GetIsAlive() and
            self:GetTeam():GetNumCommandStructures() == 1

        if noDanger then

            self.dangerMusicActive = false
            self.lastDangerMusicTime = time

            --send to all, reliable channel
            Server.SendNetworkMessage("DangerMusicUpdate", { origin = self:GetOrigin(), teamIndex = self:GetTeamNumber(), active = self.dangerMusicActive }, true )

        end

    end

    --always repeat callback
    return true

end

function CommandStructure:GetCommanderClassName()
    return Commander.kMapName   
end

function CommandStructure:GetWaitForCloseToLogin()
    return true
end

function CommandStructure:GetIsPlayerValidForCommander(player)
    local team = self:GetTeam()
    return player ~= nil and not team:GetHasCommander() and player:GetIsAlive() and player:GetTeamNumber() == self:GetTeamNumber() 
end

function CommandStructure:UpdateCommanderLogin(force)

    local allowedToLogin = not self:GetWaitForCloseToLogin() or (Shared.GetTime() - self.closedTime < 1)
    if self.occupied and self.commanderId == Entity.invalidId and allowedToLogin or force then
    
        -- Don't turn player into commander until short time later
        local player = Shared.GetEntity(self.playerIdStartedLogin)
        
        if (self:GetIsPlayerValidForCommander(player) and GetIsUnitActive(self)) or force then
            self:LoginPlayer(player)
        -- Player was killed, became invalid or left the server somehow
        else
        
            self.occupied = false
            self.commanderId = Entity.invalidId
            -- TODO: trigger client side in OnTag
            self:TriggerEffects(self:isa("Hive") and "hive_logout" or "commandstation_logout")
            
        end
        
    end
    
end

function CommandStructure:OnCommanderLogin(commanderPlayer,forced)
    local teamInfo = self:GetTeam():GetInfoEntity()
    if teamInfo then
        teamInfo:OnCommanderLogin(commanderPlayer,forced)
    end
end

function CommandStructure:LoginPlayer(player,forced)

    local commanderStartOrigin = Vector(player:GetOrigin())
    local commanderStartAngles = player:GetViewAngles()
    
    if player.OnCommanderStructureLogin then
        player:OnCommanderStructureLogin(self)
    end
    
    -- Create Commander player
    local className = self:GetCommanderClassName()
    local commanderPlayer = player:Replace(className, player:GetTeamNumber(), true, commanderStartOrigin)
    if not commanderPlayer:GetIsVirtual() then
    --When a Bot commander is logged in, and a CC is destroyed, they switch so fast, they do not become "Commander"
    --it's safe in this context, due to how Bot commanders are handled (i.e. don't 'lock' CC/Hive), so allow it.
        assert(commanderPlayer:isa("Commander"), "Error: Commander login attempt from invalid Class[%s]", commanderPlayer:GetClassName())
    end
    
    -- Set all child entities and view model invisible
    local function SetInvisible(childEntity)
        childEntity:SetIsVisible(false)
    end
    commanderPlayer:ForEachChild(SetInvisible)
    
    if commanderPlayer:GetViewModelEntity() then
        commanderPlayer:GetViewModelEntity():SetModel("")
    end
    
    -- Clear game effects on player
    commanderPlayer:ClearGameEffects()    
    commanderPlayer:SetCommandStructure(self)
    
    -- Save origin so we can restore it on logout
    commanderPlayer.lastGroundOrigin = Vector(commanderStartOrigin)
    commanderPlayer.lastGroundAngles = commanderStartAngles

    self.commanderId = commanderPlayer:GetId()
    
    -- Must reset offset angles once player becomes commander
    commanderPlayer:SetOffsetAngles(Angles(0, 0, 0))
    
    -- Callbacks (this also sets pres to 0)
    self:OnCommanderLogin(commanderPlayer,forced)

    -- Handle Stats
    if Server then

        local steamId = player:GetSteamId()
        if steamId > 0 then

            local teamNumber = player:GetTeamNumber()

            -- Init the player stats in case they haven't attacked at all so they still show up in the stats
            StatsUI_MaybeInitClientStats(steamId, nil, teamNumber)

            if teamNumber == kTeam1Index then

                StatsUI_SetMarineCommmaderSteamID(player:GetSteamId())
                StatsUI_ResetCommStats(StatsUI_GetMarineCommmaderSteamID())
            end
        end
    end
    
    return commanderPlayer
    
end

function CommandStructure:GetCommander()
    return Shared.GetEntity(self.commanderId)
end

function CommandStructure:OnUse(player, _, useSuccessTable)

    local teamNum = self:GetTeamNumber()
    local csUseSuccess = false
    self.gettingUsed = true
    
    if teamNum == 0 or teamNum == player:GetTeamNumber() then --Why 0?
    
        if self:GetIsBuilt() and (player:isa("Marine") or player:isa("Alien")) then
        
            -- Make sure player wasn't ejected early in the game from either team's command
            local playerSteamId = Server.GetOwner(player):GetUserId()
            if not GetGamerules():GetPlayerBannedFromCommand(playerSteamId) then

                if GetGamerules():OnCommanderLogin(self, player) then
                
                    -- Must use attach point if specified (Command Station)            
                    if not self.occupied and self.loginAllowed then
                    
                        self.playerIdStartedLogin = player:GetId()                        
                        self.occupied = true
                        csUseSuccess = true
                        
                        -- TODO: trigger client side in OnTag
                        self:TriggerEffects(self:isa("Hive") and "hive_login" or "commandstation_login")
                        
                    end
                    
                end
                
            end
            
        elseif not self:GetIsBuilt() and player:isa("Marine") and self:isa("CommandStation") then
            csUseSuccess = true
        end
        
    end
    
    if not csUseSuccess then
        player:TriggerInvalidSound()
    end

    self.gettingUsed = false
    useSuccessTable.useSuccess = useSuccessTable.useSuccess and csUseSuccess
    
end

function CommandStructure:OnEntityChange(oldEntityId, _)

    if self.commanderId == oldEntityId then
    
        self.occupied = false
        self.commanderId = Entity.invalidId
        
    elseif self.objectiveInfoEntId == oldEntityId then
        self.objectiveInfoEntId = Entity.invalidId
    end
    
	if HasMixin(self, "MapBlip") then 
         self:MarkBlipDirty()
    end
end

--[[
 * Returns the logged out player if there is currently one logged in.
]]
function CommandStructure:Logout()

    -- Change commander back to player.
    local commander = self:GetCommander()
    local returnPlayer

    self.playerIdStartedLogin = nil
    self.occupied = false
    self.commanderId = Entity.invalidId
    
    if commander then
    
        local previousWeaponMapName = commander.previousWeaponMapName
        local previousOrigin = commander.lastGroundOrigin
        local previousAngles = commander.lastGroundAngles
        local previousHealth = commander.previousHealth
        local previousArmor = commander.previousArmor
        local previousMaxArmor = commander.maxArmor
        local previousAlienEnergy = commander.previousAlienEnergy
        -- local timeStartedCommanderMode = commander.timeStartedCommanderMode

        local gamerules = GetGamerules()
        if gamerules and gamerules.OnCommanderLogout then
            gamerules:OnCommanderLogout(self, commander)
        end
        
        local returnPlayer = commander:Replace(commander.previousMapName, commander:GetTeamNumber(), true, previousOrigin)    
        
        if returnPlayer.OnCommanderStructureLogout then
            returnPlayer:OnCommanderStructureLogout(self)
        end
        
        returnPlayer:SetActiveWeapon(previousWeaponMapName)
        returnPlayer:SetOrigin(previousOrigin)
        returnPlayer:SetOffsetAngles(previousAngles)
        returnPlayer:SetHealth(previousHealth)
        returnPlayer:SetMaxArmor(previousMaxArmor)
        returnPlayer:SetArmor(previousArmor)
        returnPlayer.frozen = false
        
        if returnPlayer.TransferParasite then
            returnPlayer:TransferParasite(commander)
        end

        if returnPlayer.TransferBlight then
            returnPlayer:TransferBlight(commander)
        end
        
        returnPlayer.hasAdrenalineUpgrade = GetHasAdrenalineUpgrade(returnPlayer)
        
        -- Restore previous alien energy
        if previousAlienEnergy and returnPlayer.SetEnergy then
            returnPlayer:SetEnergy(previousAlienEnergy)            
        end
        
        returnPlayer:UpdateArmorAmount()
        
        returnPlayer.oneHive = commander.oneHive
        returnPlayer.twoHives = commander.twoHives
        returnPlayer.threeHives = commander.threeHives
        
        -- TODO: trigger client side in OnTag
        self:TriggerEffects(self:isa("Hive") and "hive_logout" or "commandstation_logout")

    end

    return returnPlayer
    
end

function CommandStructure:OnOverrideOrder(order)

    --Convert default to set rally point.
    if order:GetType() == kTechId.Default then
        order:SetType(kTechId.SetRally)
    end
    
end

function CommandStructure:OnTag(tagName)

    PROFILE("CommandStructure:OnTag")
    
    if tagName == "closed" then
        self.closedTime = Shared.GetTime()
    elseif tagName == "opened" then
        self.loginAllowed = true
    elseif tagName == "login_start" then
        self.loginAllowed = false
    end
    
end