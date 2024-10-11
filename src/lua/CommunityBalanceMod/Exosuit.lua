-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Exosuit.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com.at)
--
--    Pickupable entity.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/PickupableMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/ParasiteMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/CorrodeMixin.lua")
Script.Load("lua/ExoVariantMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/StaticTargetMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/AutoWeldMixin.lua")

if Client then
    Script.Load("lua/ExoFlashlight_Client.lua")
end

class 'Exosuit' (ScriptActor)

Exosuit.kMapName = "exosuit"

Exosuit.kModelName = PrecacheAsset("models/marine/exosuit/exosuit_mm.model")
local kAnimationGraph = PrecacheAsset("models/marine/exosuit/exosuit_spawn_only.animation_graph")
local kAnimationGraphSpawnOnly = PrecacheAsset("models/marine/exosuit/exosuit_spawn_only.animation_graph")
local kAnimationGraphEject = PrecacheAsset("models/marine/exosuit/exosuit_spawn_animated.animation_graph")

local kLayoutModels =
{
    ["MinigunMinigun"] = PrecacheAsset("models/marine/exosuit/exosuit_mm.model"),
    ["RailgunRailgun"] = PrecacheAsset("models/marine/exosuit/exosuit_rr.model"),
}

local kFlaresAttachpoint = "Exosuit_UpprTorso"
local kFlareCinematic = PrecacheAsset("cinematics/marine/exo/lens_flare.cinematic")

local networkVars =
{
    ownerId = "entityid",
    flashlightOn = "boolean",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)
AddMixinNetworkVars(HiveVisionMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(CorrodeMixin, networkVars)
AddMixinNetworkVars(ExoVariantMixin, networkVars)
AddMixinNetworkVars(EntityChangeMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(AutoWeldMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)

function Exosuit:OnCreate ()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, ParasiteMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, FlinchMixin, { kPlayFlinchAnimations = true })
    InitMixin(self, LOSMixin)
    InitMixin(self, NanoShieldMixin)
    InitMixin(self, PickupableMixin, { kRecipientType = "Marine" })

    self:SetPhysicsGroup(PhysicsGroup.SmallStructuresGroup)
    
    if Client then
        InitMixin(self, UnitStatusMixin)
    end
    
end

function Exosuit:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    if Server then
        
        self:SetModel(Exosuit.kModelName, kAnimationGraph)
        
        self:SetIgnoreHealth(true)
        self:SetMaxArmor(kExosuitArmor)
        self:SetArmor(kExosuitArmor)

        InitMixin(self, StaticTargetMixin)
		Exo.InitExoModel(self, kAnimationGraphEject)
		
    elseif Client then
    
        self:MakeFlashlight()
        
    end
    
    --init'ed a little later, in order for inital (defualt) model set to not trigger skin update
    InitMixin(self, ExoVariantMixin)

    InitMixin(self, HiveVisionMixin)
    InitMixin(self, WeldableMixin)
    InitMixin(self, AutoWeldMixin)
    
end

function Exosuit:OnWeldOverride(doer, elapsedTime, weldPerSecOverride)

    -- macs weld marines by only 50% of the rate
    local macMod = (HasMixin(self, "Combat") and self:GetIsInCombat()) and 0.1 or 0.5    
    local weldMod = ( doer ~= nil and doer:isa("MAC") ) and macMod or 1

    --balance mod
    local catpackBonus = 1
    if doer ~= nil then 
        local doerParent = doer:GetParent()
        if doerParent ~= nil and doerParent:isa("Marine") and doerParent:GetHasCatPackBoost() then 
            catpackBonus = 1.125
        end
    end

    if self:GetArmor() < self:GetMaxArmor() then
    
        local addArmor = (weldPerSecOverride or kPlayerArmorWeldRate) * elapsedTime * weldMod * catpackBonus
        self:SetArmor(self:GetArmor() + addArmor)
        
    end
    
end

if Server then
    
    function Exosuit:GetDestroyOnKill()
        return true
    end

    function Exosuit:OnKill()
    
        self:TriggerEffects("death")
        
    end
    
end

function Exosuit:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = self:GetIsValidRecipient(player)
end

function Exosuit:_GetNearbyRecipient()
end

function Exosuit:OnModelChanged(model)
    if self.OnExoSkinChanged then
        self:OnExoSkinChanged()
    end
end

function Exosuit:SetLayout(layout)
    local model = kLayoutModels[layout] or Exosuit.kModelName
    self:SetModel(model, kAnimationGraphEject)
    self.layout = layout
    
end

function Exosuit:GetLayout()
    return self.layout
end

function Exosuit:OnOwnerChanged(prevOwner, newOwner)

    if not newOwner or not (newOwner:isa("Marine") or newOwner:isa("JetpackMarine")) then
        self.resetOwnerTime = Shared.GetTime() + 0.1
    else
        self.resetOwnerTime = Shared.GetTime() + kItemStayTime
    end
    
end

function Exosuit:OverrideCheckVision()
    return false
end

function Exosuit:OnTouch(recipient)    
end

function Exosuit:GetArmorUseFractionOverride()
    return 1.0
end

function Exosuit:SetFlashlightOn(state)
    self.flashlightOn = state
end

function Exosuit:GetFlashlightOn()
    return self.flashlightOn
end

if Server then

    function Exosuit:OnUpdate(deltaTime)
    
        ScriptActor.OnUpdate(self, deltaTime)
        
        if self.resetOwnerTime and self.resetOwnerTime < Shared.GetTime() then
            self:SetOwner(nil)
            self.resetOwnerTime = nil
        end
        
    end
    
    function Exosuit:OnUseDeferred()
        
        local player = self.useRecipient
        self.useRecipient = nil
        
        if player and not player:GetIsDestroyed() and self:GetIsValidRecipient(player) then
            
            local weapons = player:GetWeapons()
            for i = 1, #weapons do
                weapons[i]:SetParent(nil)
            end
            
            local exoPlayer = player:Replace(Exo.kMapName, player:GetTeamNumber(), false, spawnPoint, {
                rightArmModuleType = self.rightArmModuleType,
                leftArmModuleType  = self.leftArmModuleType,
                utilityModuleType  = self.utilityModuleType,
                abilityModuleType  = self.abilityModuleType,
            })
            exoPlayer.prevPlayerMapName = player:GetMapName()
            exoPlayer.prevPlayerHealth = player:GetHealth()
            exoPlayer.prevPlayerMaxArmor = player:GetMaxArmor()
            exoPlayer.prevPlayerArmor = player:GetArmor()
            if exoPlayer then
                for i = 1, #weapons do
                    exoPlayer:StoreWeapon(weapons[i])
                end
                exoPlayer:SetMaxArmor(self:GetMaxArmor())
                exoPlayer:SetArmor(self:GetArmor())
                exoPlayer:SetFlashlightOn(self:GetFlashlightOn())
                exoPlayer:TransferParasite(self)
                exoPlayer:TransferExoVariant(self)
                
                -- Set the auto-weld cooldown of the player exo to match the cooldown of the dropped
                -- exo.
                local now = Shared.GetTime()
                local timeLastDamage = self:GetTimeOfLastDamage() or 0
                local waitEnd = timeLastDamage + kCombatTimeOut
                local cooldownEnd = math.max(waitEnd, self.timeNextWeld)
                local cooldownRemaining = math.max(0, cooldownEnd - now)
                exoPlayer.timeNextWeld = now + cooldownRemaining
                
                local newAngles = player:GetViewAngles()
                newAngles.pitch = 0
                newAngles.roll = 0
                newAngles.yaw = GetYawFromVector(self:GetCoords().zAxis)
                exoPlayer:SetOffsetAngles(newAngles)
                -- the coords of this entity are the same as the players coords when he left the exo, so reuse these coords to prevent getting stuck
                exoPlayer:SetCoords(self:GetCoords())
                
                player:TriggerEffects("pickup", { effectshostcoords = self:GetCoords() })
                
                DestroyEntity(self)
            
            end
        end
    end

    function Exosuit:OnUse(player, elapsedTime, useSuccessTable)
        if self:GetIsValidRecipient(player) and (not self.useRecipient or self.useRecipient:GetIsDestroyed()) then
            self.useRecipient = player
            self:AddTimedCallback(self.OnUseDeferred, 0)
        end
    end
    
end

if Client then
    function Exosuit:MakeFlashlight()
    
        self.flashlight = CreateExoFlashlight()
        self.flashlight:SetIsVisible(false)
        
        self.flares = Client.CreateCinematic(RenderScene.Zone_Default)
        self.flares:SetCinematic(kFlareCinematic)
        self.flares:SetRepeatStyle(Cinematic.Repeat_Endless)
        self.flares:SetParent(self)
        self.flares:SetCoords(Coords.GetIdentity())
        self.flares:SetAttachPoint(self:GetAttachPointIndex(kFlaresAttachpoint))
		
        self.flares:SetIsVisible(false)
        
    end

    function Exosuit:OnUpdate()
        
        local flashLightVisible = self.flashlightOn and self:GetIsVisible() and self:GetIsAlive()
        
        -- Synchronize the state of the light representing the flash light.
        self.flashlight:SetIsVisible(flashLightVisible)
        self.flares:SetIsVisible(flashLightVisible)
        
        if self.flashlightOn then
        
            local coords = self:GetCoords()
            coords.origin = coords.origin + coords.zAxis * 0.75 + coords.yAxis * 1.5
            
            self.flashlight:SetCoords(coords)
            
        end
    end
end

function Exosuit:OnDestroy()
    ScriptActor.OnDestroy( self )
    
    if self.flashlight then
        Client.DestroyRenderLight(self.flashlight)
        self.flashlight = nil
    end
    
    if self.flares then
        Client.DestroyCinematic(self.flares)
        self.flares = nil
    end
end


--[[ -- only give Exosuits to standard marines
function Exosuit:GetIsValidRecipient(recipient)
    return not recipient:isa("Exo") and not recipient:isa("JetpackMarine") and (self.ownerId == Entity.invalidId or self.ownerId == recipient:GetId())
end --]]

function Exosuit:GetIsValidRecipient(recipient)
    return not recipient:isa("Exo") and (self.ownerId == Entity.invalidId or self.ownerId == recipient:GetId())
end

function Exosuit:GetIsPermanent()
    return true
end

Shared.LinkClassToMap("Exosuit", Exosuit.kMapName, networkVars)
