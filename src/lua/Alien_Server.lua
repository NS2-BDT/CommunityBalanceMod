-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Alien_Server.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/AlienUpgradeManager.lua")

function Alien:TriggerEnzyme(duration)

    if not self:GetIsOnFire() and not self:GetElectrified() then
        self.timeWhenEnzymeExpires = math.max(self.timeWhenEnzymeExpires, duration + Shared.GetTime())
    end
    
end

function Alien:Reset()

    Player.Reset(self)
    
    if self:GetTeamNumber() ~= kNeutralTeamType then
        self.oneHive = false
        self.twoHives = false
        self.threeHives = false
    end
    
end

function Alien:OnProcessMove(input)
    PROFILE("Alien:OnProcessMove")
    
    self.hasAdrenalineUpgrade = GetHasAdrenalineUpgrade(self)
    

    -- Update energy (server)
    self:GetEnergy()

    -- need to clear this value or spectators would see the hatch effect every time they cycle through players
    if self.hatched and self.creationTime + 3 < Shared.GetTime() then
        self.hatched = false
    end
    
    Player.OnProcessMove(self, input)
    
    -- In rare cases, Player.OnProcessMove() above may cause this entity to be destroyed.
    -- The below code assumes the player is not destroyed.
    if not self:GetIsDestroyed() then
    
        -- Calculate two and three hives so abilities for abilities
        UpdateAbilityAvailability(self, self:GetTierOneTechId(), self:GetTierTwoTechId(), self:GetTierThreeTechId())

        self.enzymed = self.timeWhenEnzymeExpires > Shared.GetTime()
        self.electrified = self.timeElectrifyEnds > Shared.GetTime()
		self.stormed = self.timeWhenStormExpires > Shared.GetTime() 
		
        self:UpdateAutoHeal()
	end
end

-- deprecated (silence got removed)
function Alien:UpdateSilenceLevel()

    if GetHasSilenceUpgrade(self) then
        self.silenceLevel = self:GetSpurLevel()
    else
        self.silenceLevel = 0
    end

end

function Alien:UpdateAutoHeal()

    PROFILE("Alien:UpdateAutoHeal")

    if self:GetIsHealable() and ( not self.timeLastAlienAutoHeal or self.timeLastAlienAutoHeal + kAlienRegenerationTime <= Shared.GetTime() ) then

        local healRate = 1
        local shellLevel = self:GetShellLevel()
        local hasRegenUpgrade = shellLevel > 0 and GetHasRegenerationUpgrade(self)
        local maxHealth = self:GetBaseHealth()
        
        if hasRegenUpgrade then
            healRate = Clamp(kAlienRegenerationPercentage * maxHealth, kAlienMinRegeneration, kAlienMaxRegeneration) * (shellLevel/3)
        else
            healRate = Clamp(kAlienInnateRegenerationPercentage * maxHealth, kAlienMinInnateRegeneration, kAlienMaxInnateRegeneration) 
        end
        
        if self:GetIsUnderFire() then
            local modifier = kAlienRegenerationCombatModifier
            if self.GetCombatInnateRegenOverride then
                modifier = self:GetCombatInnateRegenOverride() or modifier
            end
            healRate = healRate * modifier
        end

        self:AddHealth(healRate, false, false, not hasRegenUpgrade, self, true)
        self.timeLastAlienAutoHeal = Shared.GetTime()
    
    end 

end

function Alien:GetDamagedAlertId()
    return kTechId.AlienAlertLifeformUnderAttack
end

-- Morph into new class or buy upgrade.
function Alien:ProcessBuyAction(techIds)

    ASSERT(type(techIds) == "table")

    --Nothing to buy
    if table.icount(techIds) == 0 then
        return true
    end

    local success = false

    local gameRules = GetGamerules()
    if gameRules:GetGameStarted() or gameRules:GetWarmUpActive() then
        
        local upgradeIds = {}
        local lifeFormTechId
        for _, techId in ipairs(techIds) do
            
            if LookupTechData(techId, kTechDataGestateName) then
                lifeFormTechId = techId
            else
                table.insertunique(upgradeIds, techId)
            end
            
        end

        local upgradeManager = AlienUpgradeManager()
        upgradeManager:Populate(self)

        -- add this first because it will allow switching existing upgrades
        if lifeFormTechId then
            upgradeManager:AddUpgrade(lifeFormTechId)
        end

        for _, newUpgradeId in ipairs(upgradeIds) do

            if newUpgradeId ~= kTechId.None then
                upgradeManager:AddUpgrade(newUpgradeId, true)
            end
            
        end

        --check if there has been any change before starting to evolve
        if not upgradeManager:GetHasChanged() then
            self:TriggerInvalidSound()
            return false
        end

        local position = self:GetOrigin()
        local eggExtents = LookupTechData(kTechId.Embryo, kTechDataMaxExtents)
        -- eggExtents.y + 0.2 was chosen through process of elimination to work with all lifeforms in vents. Change at own risk.
        local trace = Shared.TraceCapsule(position + Vector(0, eggExtents.y + 0.2, 0), position + Vector(0, -4.5, 0),
            math.max(eggExtents.x, eggExtents.z), eggExtents.y,
            CollisionRep.Move, PhysicsMask.AllButPCs, EntityFilterAll())
        
        -- no_evolve geo blocks all lifeforms
        local evolve_blocked = trace.surface == "no_evolve"
        -- no_evolve_{lifeform} blocks evolving to that specific lifeform
        if lifeFormTechId and not evolve_blocked then
            local gestate_name = LookupTechData(lifeFormTechId, kTechDataGestateName)
            evolve_blocked = trace.surface == ("no_evolve_" .. tostring(gestate_name)) -- eat nil values if returned
        end

        if not evolve_blocked then
        
            -- Check for room
            local newLifeFormTechId = upgradeManager:GetLifeFormTechId()
            local newAlienExtents = LookupTechData(newLifeFormTechId, kTechDataMaxExtents)
            local physicsMask = PhysicsMask.Evolve
            
            -- Add a bit to the extents when looking for a clear space to spawn.
            local spawnBufferExtents = Vector(0.1, 0.1, 0.1)
            
            local evolveAllowed = self:GetIsOnGround() and GetHasRoomForCapsule(eggExtents + spawnBufferExtents, position + Vector(0, eggExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, physicsMask, self)

            local roomAfter
            local spawnPoint
       
            -- If not on the ground for the buy action, attempt to automatically
            -- put the player on the ground in an area with enough room for the new Alien.
            if not evolveAllowed then
            
                for _ = 1, 100 do
                
                    spawnPoint = GetRandomSpawnForCapsule(eggExtents.y, math.max(eggExtents.x, eggExtents.z), self:GetModelOrigin(), 0.5, 5, EntityFilterOne(self))
  
                    if spawnPoint then
                        self:SetOrigin(spawnPoint)
                        position = spawnPoint
                        break 
                    end
                    
                end
                

            end
            
            if not GetHasRoomForCapsule(newAlienExtents + spawnBufferExtents, self:GetOrigin() + Vector(0, newAlienExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdollsAndBabblers, nil, EntityFilterOne(self)) then
           
                for _ = 1, 100 do

                    roomAfter = GetRandomSpawnForCapsule(newAlienExtents.y, math.max(newAlienExtents.x, newAlienExtents.z), self:GetModelOrigin(), 0.5, 5, EntityFilterOne(self))
                    
                    if roomAfter then
                        evolveAllowed = true
                        break
                    end

                end
                
            else
                roomAfter = position
                evolveAllowed = true
            end
            
            if evolveAllowed and roomAfter ~= nil then

                local oldLifeFormTechId = self:GetTechId()
                local newPlayer = self:Replace(Embryo.kMapName)
                position.y = position.y + Embryo.kEvolveSpawnOffset
                newPlayer:SetOrigin(position)
                
                -- Clear angles, in case we were wall-walking or doing some crazy alien thing
                local angles = Angles(self:GetViewAngles())
                angles.roll = 0.0
                angles.pitch = 0.0
                newPlayer:SetOriginalAngles(angles)
                newPlayer:SetValidSpawnPoint(roomAfter)
                
                -- Eliminate velocity so that we don't slide or jump as an egg
                newPlayer:SetVelocity(Vector(0, 0, 0))                
                newPlayer:DropToFloor()
                
                newPlayer:SetResources(upgradeManager:GetAvailableResources())
                newPlayer:SetGestationData(upgradeManager:GetUpgrades(), self:GetTechId(), self:GetHealthScalar(), self:GetArmorScalar())
                
                if oldLifeFormTechId and lifeFormTechId and oldLifeFormTechId ~= lifeFormTechId then
                    newPlayer.oneHive = false
                    newPlayer.twoHives = false
                    newPlayer.threeHives = false
                end
                
                success = true
                
            end    
            
        end
    
    end
    
    if not success then
        self:TriggerInvalidSound()
    end    
    
    return success
    
end

function Alien:GetTierOneTechId()
    return kTechId.None
end

function Alien:GetTierTwoTechId()
    return kTechId.None
end

function Alien:GetTierThreeTechId()
    return kTechId.None
end

function Alien:OnKill(attacker, doer, point, direction)

    Player.OnKill(self, attacker, doer, point, direction)
    
    self.oneHive = false
    self.twoHives = false
    self.threeHives = false
    
    if self.isHallucination then
        self:TriggerEffects("death_hallucination")
    end
    
end

function Alien:CopyPlayerDataForReadyRoomFrom(player)

    local respawnMapName = ReadyRoomTeam.GetRespawnMapName(nil,player)
    local gestationMapName = respawnMapName == ReadyRoomEmbryo.kMapName and player.gestationClass or nil

    local charge = 
        ( respawnMapName == Onos.kMapName or gestationMapName == Onos.kMapName ) and 
        ( player.oneHive or GetIsTechUnlocked( player, kTechId.Charge ) )

    local sstep = 
        ( respawnMapName == Fade.kMapName or gestationMapName == Fade.kMapName ) and 
        ( player.oneHive or GetIsTechUnlocked( player, kTechId.ShadowStep ) )

    local leap = 
        ( respawnMapName == Skulk.kMapName or gestationMapName == Skulk.kMapName ) and 
        ( player.twoHives or GetIsTechUnlocked( player, kTechId.Leap ) )
        
    self.oneHive = charge or sstep
    self.twoHives = leap
    self.gestationClass = gestationMapName
    
end

function Alien:CopyPlayerDataFrom(player)

    Player.CopyPlayerDataFrom(self, player)
    
    local selfInRR, playerInRR = self:GetTeamNumber() == kNeutralTeamType, player:GetTeamNumber() == kNeutralTeamType
    
    if selfInRR and not playerInRR then
        
        -- copy for ready room, give the tech if they deserve it
        Alien.CopyPlayerDataForReadyRoomFrom( self, player )
        
    elseif not selfInRR and playerInRR then
        
       -- don't copy Alien data from player while entering the game
       
    elseif player:isa("AlienSpectator") then
        
        -- don't copy Alien data from an AlienSpectator if not going to the RR
        
    else
        
        -- otherwise copy Alien data across
        
        self.oneHive = player.oneHive
        self.twoHives = player.twoHives
        self.threeHives = player.threeHives
        
    end
    
end

-- %%% New CBM Functions %%% --
function Alien:TriggerStorm(duration)
    if not self:GetIsOnFire() and not self:GetElectrified() then
        self.timeWhenStormExpires = math.max(self.timeWhenStormExpires, duration + Shared.GetTime())
    end
end

function Alien:OnHealthArmorDamageTaken()
    self.resilienceTimeEnd = Shared.GetTime() + 3
end