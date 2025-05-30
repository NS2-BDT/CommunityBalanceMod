-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\CommandStation.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/Marine/NanoShield.lua")

Script.Load("lua/CorrodeMixin.lua")
Script.Load("lua/RecycleMixin.lua")

Script.Load("lua/CommandStructure.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/GhostStructureMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/ParasiteMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/MarineStructureVariantMixin.lua")
Script.Load("lua/BlightMixin.lua")
Script.Load("lua/BlowtorchTargetMixin.lua")

class 'CommandStation' (CommandStructure)

CommandStation.kMapName = "commandstation"

CommandStation.kModelName = PrecacheAsset("models/marine/command_station/command_station.model")
local kAnimationGraph = PrecacheAsset("models/marine/command_station/command_station.animation_graph")

local CommandStationkUnderAttackSound = PrecacheAsset("sound/NS2.fev/marine/voiceovers/commander/command_station_under_attack")

local precached = PrecacheAsset("models/marine/command_station/command_station_display.surface_shader")

local kLoginAttachPoint = "login"
CommandStation.kCommandStationKillConstant = 1.05

if Server then
    Script.Load("lua/CommandStation_Server.lua")
end

local networkVars = 
{
}

AddMixinNetworkVars(CorrodeMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(GhostStructureMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)
AddMixinNetworkVars(HiveVisionMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(MarineStructureVariantMixin, networkVars)
AddMixinNetworkVars(BlightMixin, networkVars)

function CommandStation:OnCreate()

    CommandStructure.OnCreate(self)
    
    InitMixin(self, CorrodeMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, ParasiteMixin)
    InitMixin(self, DissolveMixin)
	InitMixin(self, BlightMixin)
	
    if Client then
		InitMixin(self, BlowtorchTargetMixin)
    end
end

function CommandStation:OnInitialized()

    CommandStructure.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, HiveVisionMixin)
        
    self:SetModel(CommandStation.kModelName, kAnimationGraph)
    
    if Server then
    
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
    
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        
    end
    
    InitMixin(self, IdleMixin)
    
    --Must be init'd last
    if not Predict then
        InitMixin(self, MarineStructureVariantMixin)
    end

end

function CommandStation:GetIsWallWalkingAllowed()
    return false
end

local kHelpArrowsCinematicName = PrecacheAsset("cinematics/marine/commander_arrow.cinematic")
local precached2 = PrecacheAsset("models/misc/commander_arrow.model")

if Client then

    function CommandStation:GetHelpArrowsCinematicName()
        return kHelpArrowsCinematicName
    end
    
end

function CommandStation:GetRequiresPower()
    return false
end

function CommandStation:GetNanoShieldOffset()
    return Vector(0, -0.3, 0)
end

function CommandStation:GetUsablePoints()

    local loginPoint = self:GetAttachPointOrigin(kLoginAttachPoint)
    return { loginPoint }
    
end

function CommandStation:GetTechButtons()
    return { kTechId.AdvancedMarineSupport, kTechId.None, kTechId.None }
end

function CommandStation:GetCanRecycleOverride()
    return not self:GetIsOccupied()
end

function CommandStation:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = CommandStructure.GetTechAllowed(self, techId, techNode, player)

    if techId == kTechId.Recycle then
        allowed = allowed and not self:GetIsOccupied()
    end
    
    return allowed, canAfford
    
end

function CommandStation:GetIsPlayerInside(player)

    -- Check to see if we're in range of the visible center of the login platform
    local vecDiff = (player:GetModelOrigin() - self:GetKillOrigin())
    return vecDiff:GetLength() < CommandStation.kCommandStationKillConstant
    
end

function CommandStation:GetHealthbarOffset()
    return 2
end

-- return a good spot from which a player could have entered the hive
-- used for initial entry point for the commander
function CommandStation:GetDefaultEntryOrigin()
    return self:GetOrigin() + Vector(0,0.9,0)
end

if Client then

    local kDisplayMaterialIndex = 1

    local kCommandStationState = enum( { "Normal", "Locked", "Welcome", "Unbuilt", "Destroyed" } )

    function CommandStation:UpdateDisplayState(optModel)

        local model = optModel ~= nil and optModel or self:GetRenderModel()
        if model then
        
            local state = kCommandStationState.Normal
            
            if self:GetIsGhostStructure() then
                state = kCommandStationState.Unbuilt
            elseif not self:GetIsAlive() then
                state = kCommandStationState.Destroyed
            elseif self:GetIsOccupied() then
                state = kCommandStationState.Welcome
            elseif GetTeamHasCommander(self:GetTeamNumber()) then
                state = kCommandStationState.Locked
            end
            
            model:SetMaterialParameter("state", state)
            
        end

    end

    function CommandStation:OnUpdateRender()

        PROFILE("CommandStation:OnUpdateRender")

        CommandStructure.OnUpdateRender(self)
        
        self:UpdateDisplayState()
        
    end

    function CommandStation:OnStructureSkinChangedExtras(variant)
        assert(variant)

        if variant == kDefaultMarineStructureVariant then
            return
        end

        --Only need to be concerned about setting the material, when Default is used, all mat-overrides are cleared
        local displayMaterial = self:GetSkinMaterialName( self:GetClassName(), self.structureVariant, kDisplayMaterialIndex )        
        if displayMaterial then
            local model = self:GetRenderModel()
            if model then
                model:SetOverrideMaterial( kDisplayMaterialIndex, displayMaterial )
                self:UpdateDisplayState(model)
            end
        end

    end

end


Shared.LinkClassToMap("CommandStation", CommandStation.kMapName, networkVars)
