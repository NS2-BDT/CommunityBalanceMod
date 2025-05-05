-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Harvester.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CloakableMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/ResourceTower.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/TeleportMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/CatalystMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/CommunityBalanceMod/DouseMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/MaturityMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/BiomassMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/ConsumeMixin.lua")
Script.Load("lua/HarvesterVariantMixin.lua")
Script.Load("lua/RailgunTargetMixin.lua")
Script.Load("lua/CommunityBalanceMod/BlowtorchTargetMixin.lua")

class 'Harvester' (ResourceTower)
Harvester.kMapName = "harvester"

Harvester.kModelName = PrecacheAsset("models/alien/harvester/harvester.model")
local kAnimationGraph = PrecacheAsset("models/alien/harvester/harvester.animation_graph")

local networkVars = { }

AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)
AddMixinNetworkVars(TeleportMixin, networkVars)
AddMixinNetworkVars(CatalystMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(DouseMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(MaturityMixin, networkVars)
AddMixinNetworkVars(HiveVisionMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(HarvesterVariantMixin, networkVars)
AddMixinNetworkVars(ConsumeMixin, networkVars)

function Harvester:OnCreate()

    ResourceTower.OnCreate(self)
    
    InitMixin(self, CloakableMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, FireMixin)
    InitMixin(self, TeleportMixin)
    InitMixin(self, CatalystMixin)
    InitMixin(self, UmbraMixin)
	InitMixin(self, DouseMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, MaturityMixin)
    InitMixin(self, BiomassMixin)
    InitMixin(self, ConsumeMixin)
    
    if Server then
        InitMixin(self, InfestationTrackerMixin)
    elseif Client then
        InitMixin(self, CommanderGlowMixin)
		InitMixin(self, RailgunTargetMixin)
		InitMixin(self, BlowtorchTargetMixin)		
    end    

end

function Harvester:OnInitialized()

    ResourceTower.OnInitialized(self)
    
    self:SetModel(Harvester.kModelName, kAnimationGraph)
    
    if Server then
    
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
        self.glowIntensity = ConditionalValue(self:GetIsBuilt(), 1, 0)
        
    end
    
    InitMixin(self, IdleMixin)

    if not Predict then
        InitMixin(self, HarvesterVariantMixin)
        self:ForceStructureSkinsUpdate()
    end

end

function Harvester:GetBioMassLevel()
    return kHarvesterBiomass
end

function Harvester:GetMaturityRate()
    return kHarvesterMaturationTime
end

function Harvester:GetMatureMaxHealth()
    return kMatureHarvesterHealth
end 

function Harvester:GetMatureMaxArmor()
    return kMatureHarvesterArmor
end

function Harvester:GetDamagedAlertId()
    return kTechId.AlienAlertHarvesterUnderAttack
end

function Harvester:GetResetsPathing()
    return true
end

if Client then

    function Harvester:OnUpdate(deltaTime)
    
        ResourceTower.OnUpdate(self, deltaTime)
        
        if self:GetIsBuilt() then
            self.glowIntensity = math.min(3, self.glowIntensity + deltaTime)
        end
        
    end    

    function Harvester:OnUpdateRender()
    
        PROFILE("Harvester:OnUpdateRender")

        local model = self:GetRenderModel()
        if model then
            model:SetMaterialParameter("glowIntensity", self.glowIntensity)        
        end
        
    end

end

if Server then

    function Harvester:OnTakeDamage(damage, attacker, doer, point)
    
        if damage > 0 then
            local time = Shared.GetTime()
            if self:GetIsAlive() and (self.lastFlinchEffectTime == nil or (time > (self.lastFlinchEffectTime + 1))) then
            
                local team = self:GetTeam()
                -- Trigger alert for Commander
                team:TriggerAlert(kTechId.AlienAlertHarvesterUnderAttack, self)
                self.lastFlinchEffectTime = time
                
            end
            
        end
        
    end

end

function Harvester:GetHealthbarOffset()
    return 2.2
end

function Harvester:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

Shared.LinkClassToMap("Harvester", Harvester.kMapName, networkVars)