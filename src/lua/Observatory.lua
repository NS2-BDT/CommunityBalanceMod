-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Observatory.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/Marine/Scan.lua")

Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/AchievementGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/CorrodeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/DetectorMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/PowerConsumerMixin.lua")
Script.Load("lua/GhostStructureMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/ParasiteMixin.lua")
Script.Load("lua/BlightMixin.lua")
Script.Load("lua/BlowtorchTargetMixin.lua")
Script.Load("lua/SupplyUserMixin.lua")

class 'Observatory' (ScriptActor)

Observatory.kMapName = "observatory"

Observatory.kModelName = PrecacheAsset("models/marine/observatory/observatory.model")
-- used by MarineCommander_Server.lua
Observatory.kCommanderScanSound = PrecacheAsset("sound/NS2.fev/marine/commander/scan_com")

local kDistressBeaconSoundMarine = PrecacheAsset("sound/NS2.fev/marine/common/distress_beacon_marine")

Observatory.kDistressBeaconTime = kDistressBeaconTime
Observatory.kDistressBeaconRange = kDistressBeaconRange
Observatory.kDetectionRange = 22 -- From NS1
Observatory.kRelevancyPortalRange = 40

local kAnimationGraph = PrecacheAsset("models/marine/observatory/observatory.animation_graph")

local kAdvObservatoryMaterial = PrecacheAsset("models/marine/observatory/observatory_adv.material")

local networkVars = {
    beaconLocation = "vector",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(CorrodeMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(ObstacleMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(PowerConsumerMixin, networkVars)
AddMixinNetworkVars(GhostStructureMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)
AddMixinNetworkVars(BlightMixin, networkVars)

function Observatory:OnCreate()

    ScriptActor.OnCreate(self)

    if Server then

        self.distressBeaconSound = Server.CreateEntity(SoundEffect.kMapName)
        self.distressBeaconSound:SetAsset(kDistressBeaconSoundMarine)
        self.distressBeaconSound:SetRelevancyDistance(Math.infinity)

        self:AddTimedCallback(Observatory.RevealCysts, 0.4)

        self.beaconRelevancyPortal = -1

    end

    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin, { kPlayFlinchAnimations = true })
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, AchievementGiverMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, DetectorMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, PowerConsumerMixin)
    InitMixin(self, ParasiteMixin)
	InitMixin(self, BlightMixin)

    if Client then
        InitMixin(self, CommanderGlowMixin)
		InitMixin(self, BlowtorchTargetMixin)
    end

    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)

	self.kAdvObservatoryMaterial = false

end

function Observatory:OnInitialized()

    ScriptActor.OnInitialized(self)

    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)

    self:SetModel(Observatory.kModelName, kAnimationGraph)

    if Server then

        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end

        InitMixin(self, StaticTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
        InitMixin(self, SupplyUserMixin)

    elseif Client then

        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)

    end

    InitMixin(self, IdleMixin)

    self.beaconLocation = self:GetDistressOrigin()

end

local function DestroyRelevancyPortal(self)
    if self.beaconRelevancyPortal ~= -1 then
        Server.DestroyRelevancyPortal(self.beaconRelevancyPortal)
        self.beaconRelevancyPortal = -1
    end
end

function Observatory:OnDestroy()

    ScriptActor.OnDestroy(self)

    if Server then

        DestroyEntity(self.distressBeaconSound)
        self.distressBeaconSound = nil
        DestroyRelevancyPortal(self)

    end

end

function Observatory:GetTechButtons(techId)

	local kObservatoryTechButtons = { kTechId.Scan, kTechId.DistressBeacon, kTechId.Detector, kTechId.None,
                                  kTechId.PhaseTech, kTechId.CargoTech, kTechId.None, kTechId.None }
    
	if self:GetTechId() ~= kTechId.AdvancedObservatory then
        kObservatoryTechButtons[4] = kTechId.UpgradeObservatory
    end     
	
    if techId == kTechId.RootMenu then
        return kObservatoryTechButtons
    end

    return nil

end

function Observatory:GetDetectionRange()

    if GetIsUnitActive(self) then
        return Observatory.kDetectionRange
    end

    return 0

end

function Observatory:GetRequiresPower()
    return true
end

function Observatory:GetReceivesStructuralDamage()
    return true
end

function Observatory:GetDamagedAlertId()
    return kTechId.MarineAlertStructureUnderAttack
end

function Observatory:GetDistressOrigin()

    -- Respawn at nearest built command station
    local origin
    local nearest = GetNearest(self:GetOrigin(), "CommandStation", self:GetTeamNumber(), function(ent) return ent:GetIsBuilt() and ent:GetIsAlive() end)
    if nearest then
        -- Log("Nearest CC ID: %s", nearest:GetLocationId())
        origin = nearest:GetModelOrigin()
    end

    return origin

end

local function TriggerMarineBeaconEffects(self)

    for _, player in ipairs(GetEntitiesForTeam("Player", self:GetTeamNumber())) do

        if player:GetIsAlive() and (player:isa("Marine") or player:isa("Exo")) then
            player:TriggerEffects("player_beacon")
        end

    end

end

local function SetupBeaconRelevancyPortal(self, destination)

    DestroyRelevancyPortal(self)

    local source = Vector(Math.infinity, Math.infinity, Math.infinity)

    local mask = 0
    local teamNumber = self:GetTeamNumber()
    if teamNumber == 1 then
        mask = kRelevantToTeam1Unit
    elseif teamNumber == 2 then
        mask = kRelevantToTeam2Unit
    end

    if mask ~= 0 then
        self.beaconRelevancyPortal = Server.CreateRelevancyPortal(source, destination, mask, 0)
    end

end

function Observatory:TriggerDistressBeacon()

    local success = false

    if not self:GetIsBeaconing() then

        self.distressBeaconSound:Start()

        local origin = self:GetDistressOrigin()

        if origin then

            self.distressBeaconSound:SetOrigin(origin)

            -- Beam all faraway players back in a few seconds!
            self.distressBeaconTime = Shared.GetTime() + Observatory.kDistressBeaconTime

            if Server then

                TriggerMarineBeaconEffects(self)

                local location = GetLocationForPoint(self:GetDistressOrigin())
                local locationName = location and location:GetName() or ""
                local locationId = Shared.GetStringIndex(locationName)
                SendTeamMessage(self:GetTeam(), kTeamMessageTypes.Beacon, locationId)

                SetupBeaconRelevancyPortal(self, origin)

            end

            success = true

        end

    end

    return success, not success

end

function Observatory:CancelDistressBeacon()

    self.distressBeaconTime = nil
    self.distressBeaconSound:Stop()
    DestroyRelevancyPortal(self)

end

-- Check if both origins are in the location (game wise, not mapping wise since a "location" is composed of several mapping "location" entities)
local function GetIsSameLocation(CC_orig, player_orig)
    local loc1 = GetLocationForPoint(CC_orig)
    local loc2 = GetLocationForPoint(player_orig)

    if loc1 and loc2 then
        local location1_id = Shared.GetStringIndex(loc1:GetName())
        local location2_id = Shared.GetStringIndex(loc2:GetName())

        -- Log("Locations1: %s %s/%s", loc1, loc1:GetName(), location1_id)
        -- Log("Locations2: %s %s/%s", loc2, loc2:GetName(), location2_id)
        -- Log("Distance: %s", CC_orig:GetDistanceTo(player_orig))
        if location1_id == location2_id then
            return true
        end
    end

    return false
end

local function GetIsPlayerNearby(_, player, toOrigin)
    return (player:GetOrigin() - toOrigin):GetLength() < Observatory.kDistressBeaconRange
end

function Observatory:GetPlayersToBeacon(toOrigin)

    local players = {}
    local playerIds = self:GetTeam():GetPlayerIds()
    for playerId in playerIds:Iterate() do
        local player = Shared.GetEntity(playerId)
        -- Only beacon Marines (no Exo, Commander or TeamSpectator (dead player))
        if player and player:isa("Marine") then

            -- Don't respawn players that are already nearby.
            -- Log("Player location id: %s", player:GetLocationId())
            local inTheSameLocation = GetIsSameLocation(toOrigin, player:GetOrigin())
            if not inTheSameLocation then
                table.insert(players, player)
            end

        end

    end

    return players

end

local function BeaconGetMarineSpawnPoints(orig, number)
    local entities = {}
    local extents = LookupTechData(kTechId.Marine, kTechDataMaxExtents)
    local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)
    local range = Observatory.kDistressBeaconRange

    number = number or 1
    for _ = 1, number do

        local success = false

        -- Persistence is the path to victory.
        for _ = 1, 150 do

            local position = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, orig, 2, range, EntityFilterAll())
            if position then
                -- Check if we are in the same location room
                success = GetIsSameLocation(orig, position)

                if success then
                    -- Log("Location found in %s for a marine", marineLocation and marineLocation:GetName() or "")
                    table.insert(entities, position)
                    break
                end
            end

        end
    end

    return entities
end

-- Spawn players at nearest Command Station to Observatory - not initial marine start like in NS1. Allows relocations and more versatile tactics.
function Observatory:RespawnPlayer(player, distressOrigin)

    local spawnPoints = BeaconGetMarineSpawnPoints(distressOrigin, 1)
    local spawnPoint = #spawnPoints > 0 and spawnPoints[1] or nil

    if spawnPoint then

        player:SetOrigin(spawnPoint)
        if player.TriggerBeaconEffects then
            player:TriggerBeaconEffects()
        end

    end

    return spawnPoint
end

function Observatory:PerformDistressBeacon()

    self.distressBeaconSound:Stop()

    local anyPlayerWasBeaconed = false
    local successfullPositions = {}
    local failedPlayers = {}

    local distressOrigin = self:GetDistressOrigin()
    if distressOrigin then

        for _, player in ipairs(self:GetPlayersToBeacon(distressOrigin)) do

            -- Notify LOS mixin of the impending move (to prevent aliens scouted by this
            -- player from getting stuck scouted).
            if Server and HasMixin(player, "LOS") then
                player:MarkNearbyDirtyImmediately()
            end

            if Server and player.OnPreBeacon then
                player:OnPreBeacon()
            end

            local respawnPoint = self:RespawnPlayer(player, distressOrigin)
            if respawnPoint then

                anyPlayerWasBeaconed = true
                table.insert(successfullPositions, respawnPoint)

            else
                table.insert(failedPlayers, player)
            end

        end

        -- Also respawn players that are spawning in at infantry portals near command station (use a little extra range to account for vertical difference)
        for _, ip in ipairs(GetEntitiesForTeamWithinRange("InfantryPortal", self:GetTeamNumber(), distressOrigin, kInfantryPortalAttachRange + 1)) do

            ip:FinishSpawn()
            local spawnPoint = ip:GetAttachPointOrigin("spawn_point")
            table.insert(successfullPositions, spawnPoint)

        end

    end

    local usePositionIndex = 1
    local numPosition = #successfullPositions
    if numPosition == 0 then return false end

    for i = 1, #failedPlayers do

        local player = failedPlayers[i]

        player:SetOrigin(successfullPositions[usePositionIndex])
        if player.TriggerBeaconEffects then
            player:TriggerBeaconEffects()
        end

        usePositionIndex = Math.Wrap(usePositionIndex + 1, 1, numPosition)

    end

    if anyPlayerWasBeaconed then
        self:TriggerEffects("distress_beacon_complete")
    end

    return anyPlayerWasBeaconed
end

function Observatory:OnPowerOff()

    -- Cancel distress beacon on power down
    if self:GetIsBeaconing() then
        self:CancelDistressBeacon()
    end

end

function Observatory:RevealCysts()

    PROFILE("Observatory:RevealCysts")

    for _, cyst in ipairs(GetEntitiesForTeamWithinRange("Cyst", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), Observatory.kDetectionRange)) do
        if self:GetIsBuilt() and self:GetIsPowered() then
            cyst:SetIsSighted(true)
        end
    end

    local distressOrigin = self:GetDistressOrigin()
    if self.beaconLocation ~= distressOrigin then
        self.beaconLocation = self:GetDistressOrigin()
    end

    return self:GetIsAlive()

end

function Observatory:OnUpdate(deltaTime)

    ScriptActor.OnUpdate(self, deltaTime)

    if self:GetIsBeaconing() and (Shared.GetTime() >= self.distressBeaconTime) then

        self:PerformDistressBeacon()
        DestroyRelevancyPortal(self)

        self.distressBeaconTime = nil

    end

    if self.beaconRelevancyPortal ~= -1 and self.distressBeaconTime then
        local rangeFrac = 1.0 - math.min(math.max(self.distressBeaconTime - Shared.GetTime(), 0) / self.kDistressBeaconTime, 1.0)
        local range = self.kRelevancyPortalRange * rangeFrac
        Server.SetRelevancyPortalRange(self.beaconRelevancyPortal, range)
    end

end

function Observatory:PerformActivation(techId, position, normal, commander)

    -- local success = false

    if GetIsUnitActive(self) then

        if techId == kTechId.DistressBeacon then
            return self:TriggerDistressBeacon()
        end

    end

    return ScriptActor.PerformActivation(self, techId, position, normal, commander)

end

function Observatory:GetIsBeaconing()
    return self.distressBeaconTime ~= nil
end

if Server then

    function Observatory:OnKill(killer, doer, point, direction)

        if self:GetIsBeaconing() then
            self:CancelDistressBeacon()
        end

        ScriptActor.OnKill(self, killer, doer, point, direction)

    end

end

function Observatory:OverrideVisionRadius()
    return Observatory.kDetectionRange
end

if Server then

    local function OnConsoleDistress()

        if Shared.GetCheatsEnabled() or Shared.GetDevMode() then
            local beacons = Shared.GetEntitiesWithClassname("Observatory")
            for _, beacon in ientitylist(beacons) do
                beacon:TriggerDistressBeacon()
                return -- don't beacon more than one at a time.
            end
        end

    end

    Event.Hook("Console_distress", OnConsoleDistress)

end

if Server then

    function Observatory:OnConstructionComplete()

        if self.phaseTechResearched then

            local techTree = GetTechTree(self:GetTeamNumber())
            if techTree then
                local researchNode = techTree:GetTechNode(kTechId.PhaseTech)
                researchNode:SetResearched(true)
                techTree:QueueOnResearchComplete(kTechId.PhaseTech, self)
            end

        end

    end

    function Observatory:UpdateResearch() -- CBM Function

        local researchId = self:GetResearchingId()

        if researchId == kTechId.UpgradeObservatory then

            local techTree = self:GetTeam():GetTechTree()
            local researchNode = techTree:GetTechNode(kTechId.AdvancedObservatory)
            researchNode:SetResearchProgress(self.researchProgress)
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress))

        end

    end

    function Observatory:OnResearchCancel(researchId) -- CBM Function

        if researchId == kTechId.UpgradeObservatory then

            local team = self:GetTeam()

            if team then

                local techTree = team:GetTechTree()
                local researchNode = techTree:GetTechNode(kTechId.AdvancedObservatory)
                if researchNode then

                    researchNode:ClearResearching()
                    techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", 0))

                end
            end
        end
    end

end

function Observatory:GetHealthbarOffset()
    return 0.9
end

function Observatory:ShowDestinationOverride()

    local player = Client.GetLocalPlayer()
    return player ~= nil and player:isa("Commander")

end

function Observatory:GetDestinationLocationName()

    if self.beaconLocation and self.beaconLocation ~= 0 then
        local location = GetLocationForPoint(self.beaconLocation)
        if location then
            return location and location:GetName() or ""
        end
    end
    return ""

end

function Observatory:OverrideHintString( hintString, forEntity )

    if not GetAreEnemies(self, forEntity) and self.beaconLocation and self.beaconLocation ~= 0 then
        local location = GetLocationForPoint(self.beaconLocation)
        local locationName = location and location:GetName() or ""
        if locationName and locationName~="" then
            return string.format(Locale.ResolveString( "OBSERVATORY_BEACON_TO_HINT" ), locationName )
        end
    end

    return hintString

end

-- CBM Functions --
function Observatory:OnResearchComplete(researchId)

    if researchId == kTechId.UpgradeObservatory then
        self:UpgradeToTechId(kTechId.AdvancedObservatory)
    end

	if HasMixin(self, "MapBlip") then 
		self:MarkBlipDirty()
	end
        
end

if Client then
    
    function Observatory:OnUpdateRender()

		local model = self:GetRenderModel()

	    if not self.kAdvObservatoryMaterial and self:GetTechId() == kTechId.AdvancedObservatory then
			
			if model and model:GetReadyForOverrideMaterials() then
				local material = kAdvObservatoryMaterial
				assert(material)
				model:SetOverrideMaterial( 0, material )

				model:SetMaterialParameter("highlight", 0.91)

				self.kAdvObservatoryMaterial = true
				self:SetHighlightNeedsUpdate()
			end
	    end
    end
end

Shared.LinkClassToMap("Observatory", Observatory.kMapName, networkVars)

class 'AdvancedObservatory' (Observatory)
AdvancedObservatory.kMapName = "advancedObservatory"
Shared.LinkClassToMap("AdvancedObservatory", AdvancedObservatory.kMapName, {})