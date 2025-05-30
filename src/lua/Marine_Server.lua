-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Marine_Server.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local MarinekSpendResourcesSoundName = PrecacheAsset("sound/NS2.fev/marine/common/player_spend_nanites")
local MarinekSprintStart = PrecacheAsset("sound/NS2.fev/marine/common/sprint_start")
local MarinekSprintTiredEnd = PrecacheAsset("sound/NS2.fev/marine/common/sprint_tired")
local MarinekSprintStartFemale = PrecacheAsset("sound/NS2.fev/marine/common/sprint_tired_female")
local MarinekSprintTiredEndFemale = PrecacheAsset("sound/NS2.fev/marine/common/sprint_start_female")

local function UpdateUnitStatusPercentage(self, target)

    if HasMixin(target, "Construct") and not target:GetIsBuilt() then
        self:SetUnitStatusPercentage(target:GetBuiltFraction() * 100)
    elseif HasMixin(target, "Weldable") then
        self:SetUnitStatusPercentage(target:GetWeldPercentage() * 100)
    end

end

function Marine:OnConstructTarget(target)
    UpdateUnitStatusPercentage(self, target)
end

function Marine:OnWeldTarget(target)
    UpdateUnitStatusPercentage(self, target)
end

function Marine:SetUnitStatusPercentage(percentage)
    self.unitStatusPercentage = Clamp(math.round(percentage), 0, 100)
    self.timeLastUnitPercentageUpdate = Shared.GetTime()
end

function Marine:OnTakeDamage(_, attacker, doer, _)

    if doer then
    
        if doer:isa("Grenade") and doer:GetOwner() == self then
        
            self.onGround = false
            local velocity = self:GetVelocity()
            local fromGrenade = self:GetOrigin() - doer:GetOrigin()
            local length = fromGrenade:Normalize()
            local force = Clamp(1 - (length / 4), 0, 1)
            
            if force > 0 then
                velocity:Add(force * fromGrenade)
                self:SetVelocity(velocity)
            end
            
        end

        if (doer:isa("Gore") or doer:isa("Shockwave")) and not attacker.isHallucination then
        
            self.interruptAim = true
            self.interruptStartTime = Shared.GetTime()
            
        end
    
    end

end

function Marine:GetDamagedAlertId()
    return kTechId.MarineAlertSoldierUnderAttack
end

function Marine:SetPoisoned(attacker)

    self.poisoned = true
    self.timePoisoned = Shared.GetTime()
    
    if attacker then
        self.lastPoisonAttackerId = attacker:GetId()
    end
    
end

function Marine:OnEntityChange(oldId, newId)

    Player.OnEntityChange(self, oldId, newId)

    if oldId == self.lastPoisonAttackerId then
    
        if newId then
            self.lastPoisonAttackerId = newId
        else
            self.lastPoisonAttackerId = Entity.invalidId
        end
        
    end
 
end

function Marine:CopyPlayerDataFrom(player)

    Player.CopyPlayerDataFrom(self, player)
    
    local playerInRR = player:GetTeamNumber() == kNeutralTeamType
    
    if not playerInRR and GetGamerules():GetGameStarted() then
        
        self.grenadesLeft = player.grenadesLeft
        self.grenadeType = player.grenadeType
        
        self.minesLeft = player.minesLeft
        
        if player:isa("Marine") then
            self:TransferParasite(player)
        elseif player:isa("Exo") then
            self:TransferParasite( { parasited = player.prevParasited, timeParasited = player.prevParasitedTime } ) 
        end
        self:TransferBlight(player)
    end
    
end

function Marine:SetRuptured()

    self.timeRuptured = Shared.GetTime()
    self.ruptured = true
    
end

function Marine:OnSprintStart()
    if self:GetIsAlive() then
        local marineType = self:GetMarineTypeString()
        
        if marineType == "bigmac" then
            return
        end

        if marineType == "female" then
             StartSoundEffectOnEntity(MarinekSprintStartFemale, self)
        else 
             StartSoundEffectOnEntity(MarinekSprintStart, self)
        end
    end
end

function Marine:OnSprintEnd(sprintDuration)
    local marineType = self:GetMarineTypeString()

    if marineType == "bigmac" then
        return
    end

    if sprintDuration > 5 then
        if marineType == "female" then
             StartSoundEffectOnEntity(MarinekSprintTiredEndFemale, self)
        else 
             StartSoundEffectOnEntity(MarinekSprintTiredEnd, self)
        end
    end
end

function Marine:InitWeapons()

    Player.InitWeapons(self)
    
    self:GiveItem(Rifle.kMapName)
    self:GiveItem(Pistol.kMapName)
    self:GiveItem(Axe.kMapName)
    self:GiveItem(Builder.kMapName)
    
    self:SetQuickSwitchTarget(Pistol.kMapName)
    self:SetActiveWeapon(Rifle.kMapName)

end

local function GetHostSupportsTechId(forPlayer, host, techId)

    if Shared.GetCheatsEnabled() then
        return true
    end
    
    local techFound = false
    
    if host.GetItemList then
    
        for _, supportedTechId in ipairs(host:GetItemList(forPlayer)) do
        
            if supportedTechId == techId then
            
                techFound = true
                break
                
            end
            
        end
        
    end
    
    return techFound
    
end

function GetHostStructureFor(entity, techId)

    local hostStructures = {}
    table.copy(GetEntitiesForTeamWithinRange("Armory", entity:GetTeamNumber(), entity:GetOrigin(), Armory.kResupplyUseRange), hostStructures, true)
    table.copy(GetEntitiesForTeamWithinRange("PrototypeLab", entity:GetTeamNumber(), entity:GetOrigin(), PrototypeLab.kResupplyUseRange), hostStructures, true)
    
    if table.icount(hostStructures) > 0 then
    
        for _, host in ipairs(hostStructures) do
        
            -- check at first if the structure is hostign the techId:
            if GetHostSupportsTechId(entity,host, techId) then
                return host
            end
        
        end
            
    end
    
    return nil

end

function Marine:OnOverrideOrder(order)
    local orderType = order:GetType()
    if orderType ~= kTechId.Default then return end

    local param = order:GetParam()
    local orderTarget = param and Shared.GetEntity(param)

    local teamNumber = self:GetTeamNumber()
    -- Default orders to unbuilt friendly structures should be construct orders
    if GetOrderTargetIsConstructTarget(order, teamNumber) then

        order:SetType(kTechId.Construct)

    -- Issue weld order for weldable targets. Powerpoints can be welded without a welder!
    elseif GetOrderTargetIsWeldTarget(order, teamNumber) and (self:GetWeapon(Welder.kMapName) or orderTarget:isa("PowerPoint")) then

        order:SetType(kTechId.Weld)

    elseif GetOrderTargetIsDefendTarget(order, teamNumber) then

        order:SetType(kTechId.Defend)

    -- If target is enemy, attack it
    elseif orderTarget and GetAreEnemies(orderTarget, self) and HasMixin(orderTarget, "Live") and orderTarget:GetIsAlive() and (not HasMixin(orderTarget, "LOS") or orderTarget:GetIsSighted()) then

        order:SetType(kTechId.Attack)

    else
        -- Convert default order (right-click) to move order
        order:SetType(kTechId.Move)

    end

end

local function BuyExo(self, techId)

    local maxAttempts = 100
    for index = 1, maxAttempts do
    
        -- Find open area nearby to place the big guy.
        -- local capsuleHeight, capsuleRadius = self:GetTraceCapsule()
        local extents = Vector(Exo.kXZExtents, Exo.kYExtents, Exo.kXZExtents)

        local spawnPoint        
        local checkPoint = self:GetOrigin() + Vector(0, 0.02, 0)
        
        if GetHasRoomForCapsule(extents, checkPoint + Vector(0, extents.y, 0), CollisionRep.Move, PhysicsMask.Evolve, self) then
            spawnPoint = checkPoint
        else
            spawnPoint = GetRandomSpawnForCapsule(extents.y, extents.x, checkPoint, 0.5, 5, EntityFilterOne(self))
        end    
            
        local weapons 

        if spawnPoint then
        
            self:AddResources(-GetCostForTech(techId))
            local weapons = self:GetWeapons()
            for i = 1, #weapons do            
                weapons[i]:SetParent(nil)            
            end
            
            local exo

            if techId == kTechId.Exosuit then
                exo = self:GiveExo(spawnPoint)
            elseif techId == kTechId.DualMinigunExosuit then
                exo = self:GiveDualExo(spawnPoint)
            elseif techId == kTechId.ClawRailgunExosuit then
                exo = self:GiveClawRailgunExo(spawnPoint)
            elseif techId == kTechId.DualRailgunExosuit then
                exo = self:GiveDualRailgunExo(spawnPoint)
            end
            
            if exo then                
                for i = 1, #weapons do
                    exo:StoreWeapon(weapons[i])
                end            
            end
            
            exo:TriggerEffects("spawn_exo")
            
            return
            
        end
        
    end
    
    Print("Error: Could not find a spawn point to place the Exo")
    
end

kIsExoTechId = 
{
    [kTechId.Exosuit] = true,
    [kTechId.DualMinigunExosuit] = true,
    [kTechId.ClawRailgunExosuit] = false,
    [kTechId.DualRailgunExosuit] = true
}

function Marine:AttemptToBuy(techIds)

    local techId = techIds[1]
    
    local hostStructure = GetHostStructureFor(self, techId)

    if hostStructure then
    
        local mapName = LookupTechData(techId, kTechDataMapName)
        
        if mapName then
        
            Shared.PlayPrivateSound(self, MarinekSpendResourcesSoundName, nil, 1.0, self:GetOrigin())
            
            if self:GetTeam() and self:GetTeam().OnBought then
                self:GetTeam():OnBought(techId)
            end
            
            if techId == kTechId.Jetpack then

                -- Need to apply this here since we change the class.
                self:AddResources(-GetCostForTech(techId))
                self:GiveJetpack()
                
            elseif kIsExoTechId[techId] then
                BuyExo(self, techId)    
            else
            
                -- Make sure we're ready to deploy new weapon so we switch to it properly.
                local newItem = self:GiveItem(mapName)
                if newItem then

                    if newItem.UpdateWeaponSkins then
                        -- Apply weapon variant
                        newItem:UpdateWeaponSkins( self:GetClient() )
                    end

                    self:TriggerEffects("marine_weapon_pickup", { effecthostcoords = self:GetCoords() })

                    if Server then

                        -- Destroy any dropped weapons that are free, are the same weapon, and that we are the previous owner.
                        -- This is to stop spamming "free" weapons like Rifle from being bought repeatedly at the armory.
                        local cost = LookupTechData(newItem:GetTechId(), kTechDataCostKey, 0)
                        if cost <= 0 then

                            local filterFunction = CLambda [=[
                            (...):GetWeaponWorldState() and
                            (...).prevOwnerId == self[1]
                            ]=] {self:GetId()}

                            local weapons = Shared.GetEntitiesWithClassname(newItem:GetClassName())
                            weapons = GetEntitiesWithFilter(weapons, filterFunction)

                            for i = 1, #weapons do
                                local weapon = weapons[i]
                                if weapon then
                                    DestroyEntity(weapon)
                                end
                            end

                        end

                    end

                    return true
                    
                end
                
            end
            
            return false
            
        end
        
    end
    
    return false
    
end

-- special threatment for mines and welders
function Marine:GiveItem(itemMapName,setActive, suppressError)
    local newItem

    if setActive == nil then
		setActive = true
	end
	
    if itemMapName then
        
        local continue = true
        
        if itemMapName == LayMines.kMapName then
        
            local mineWeapon = self:GetWeapon(LayMines.kMapName)
            
            if mineWeapon then
                mineWeapon:Refill(kNumMines)
                continue = false
                setActive = false
            end
            
        elseif itemMapName == Welder.kMapName then
        
            -- since axe cannot be dropped we need to delete it before adding the welder (shared hud slot)
            local switchAxe = self:GetWeapon(Axe.kMapName)
            
            if switchAxe then
                self:RemoveWeapon(switchAxe)
                DestroyEntity(switchAxe)
                continue = true
            else
                continue = false -- don't give a second welder
            end
        
        end
        
        if continue == true then
            return Player.GiveItem(self, itemMapName, setActive, suppressError)
        end
        
    end
    
    return newItem
    
end

function Marine:DropAllWeapons()
    
    -- local weaponSpawnCoords = self:GetAttachPointCoords(Weapon.kHumanAttachPoint)
    local weaponList = self:GetHUDOrderedWeaponList()
    
    for w = 1, #weaponList do
    
        local weapon = weaponList[w]
    
        if weapon:isa("GrenadeThrower") then
            weapon:DropItLikeItsHot( self )
            if weapon.grenadesLeft > 0 then
                self.grenadesLeft = weapon.grenadesLeft
                self.grenadeType = weapon.kMapName
            end
        elseif weapon:isa("LayMines") then
            if weapon.minesLeft > 0 then
                self.minesLeft = weapon.minesLeft
            end
        elseif weapon:GetIsDroppable() and LookupTechData(weapon:GetTechId(), kTechDataCostKey, 0) > 0 then
            self:Drop(weapon, true, true)
        end
        
    end
    
end

function Marine:OnKill(attacker, doer, point, direction)
    
    local lastWeaponList = self:GetHUDOrderedWeaponList()
    
    self.lastWeaponList = { }
    for _, weapon in ipairs(lastWeaponList) do
        table.insert(self.lastWeaponList, weapon:GetMapName())
        -- If cheats are enabled, destroy the weapons so they don't drop
        if Shared.GetCheatsEnabled() and weapon:GetIsDroppable() and LookupTechData(weapon:GetTechId(), kTechDataCostKey, 0) > 0 then
            DestroyEntity(weapon)
        end
    end
    
    -- Drop all weapons which cost resources
    self:DropAllWeapons()
    
    -- Destroy remaining weapons
    self:DestroyWeapons()
    
    Player.OnKill(self, attacker, doer, point, direction)
    
    -- Don't play alert if we suicide
    if attacker ~= self then
        self:GetTeam():TriggerAlert(kTechId.MarineAlertSoldierLost, self)
    end
    
    -- Note: Flashlight is powered by Marine's beating heart. Eco friendly.
    self:SetFlashlightOn(false)
    self.originOnDeath = self:GetOrigin()
    
end

function Marine:GetOriginOnDeath()
    return self.originOnDeath
end

function Marine:GiveJetpack()

    local activeWeapon = self:GetActiveWeapon()
    local activeWeaponMapName
    local health = self:GetHealth()
    
    if activeWeapon ~= nil then
        activeWeaponMapName = activeWeapon:GetMapName()
    end
    
    local jetpackMarine = self:Replace(JetpackMarine.kMapName, self:GetTeamNumber(), true, Vector(self:GetOrigin()))
    
    jetpackMarine:SetActiveWeapon(activeWeaponMapName)
    jetpackMarine:SetHealth(health)
    
end


function Marine:GiveExo(spawnPoint, isPickup)

    local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "MinigunMinigun" }, isPickup)
    return exo
    
end

function Marine:GiveDualExo(spawnPoint, isPickup)

    local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "MinigunMinigun" }, isPickup)
    return exo
    
end

function Marine:GiveClawRailgunExo(spawnPoint, isPickup)

    local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "ClawRailgun" }, isPickup)
    return exo
    
end

function Marine:GiveDualRailgunExo(spawnPoint, isPickup)

    local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "RailgunRailgun" }, isPickup)
    return exo
    
end


