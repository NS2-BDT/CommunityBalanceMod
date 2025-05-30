-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\FireMixin.lua
--
--    Created by:   Andrew Spiering (andrew@unknownworlds.com) and
--                  Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

FireMixin = CreateMixin( FireMixin )
FireMixin.type = "Fire"

local precached = PrecacheAsset("cinematics/vfx_materials/burning.surface_shader")
local precached2 = PrecacheAsset("cinematics/vfx_materials/burning_view.surface_shader")

local kBurningViewMaterial = PrecacheAsset("cinematics/vfx_materials/burning_view.material")
local kBurningMaterial = PrecacheAsset("cinematics/vfx_materials/burning.material")
local kBurnBigCinematic = PrecacheAsset("cinematics/marine/flamethrower/burn_big.cinematic")
local kBurnHugeCinematic = PrecacheAsset("cinematics/marine/flamethrower/burn_huge.cinematic")
local kBurnMedCinematic = PrecacheAsset("cinematics/marine/flamethrower/burn_med.cinematic")
local kBurnSmallCinematic = PrecacheAsset("cinematics/marine/flamethrower/burn_small.cinematic")
local kBurn1PCinematic = PrecacheAsset("cinematics/marine/flamethrower/burn_1p.cinematic")

local kBurnUpdateRate = 0.5

local kFireCinematicTable = { }
kFireCinematicTable["Hive"] = kBurnHugeCinematic
kFireCinematicTable["CommandStation"] = kBurnHugeCinematic
kFireCinematicTable["Clog"] = kBurnSmallCinematic
kFireCinematicTable["Onos"] = kBurnBigCinematic
kFireCinematicTable["MAC"] = kBurnSmallCinematic
kFireCinematicTable["Drifter"] = kBurnSmallCinematic
kFireCinematicTable["Sentry"] = kBurnSmallCinematic
kFireCinematicTable["Egg"] = kBurnSmallCinematic
kFireCinematicTable["Embryo"] = kBurnSmallCinematic

local function GetOnFireCinematic(ent, firstPerson)

    if firstPerson then
        return kBurn1PCinematic
    end
    
    return kFireCinematicTable[ent:GetClassName()] or kBurnMedCinematic
    
end

local kFireLoopingSound = { }
kFireLoopingSound["Entity"] = PrecacheAsset("sound/NS2.fev/common/fire_small")
kFireLoopingSound["Onos"] = PrecacheAsset("sound/NS2.fev/common/fire_large")
kFireLoopingSound["Hive"] = PrecacheAsset("sound/NS2.fev/common/fire_large")

local function GetOnFireSound(entClassName)
    return kFireLoopingSound[entClassName] or kFireLoopingSound["Entity"]
end
FireMixin.networkVars =
{
    isOnFire = "boolean",
    timeBurnInit = "time"
}

function FireMixin:__initmixin()
    
    PROFILE("FireMixin:__initmixin")
    
    self.timeBurnInit = 0    
    self.isOnFire = false
    
    if Server then
    
        self.fireAttackerId = Entity.invalidId
        self.fireDoerId = Entity.invalidId
        
        self.onFireSound = Server.CreateEntity(SoundEffect.kMapName)
        self.onFireSound:SetAsset(GetOnFireSound(self:GetClassName()))
        self.onFireSound:SetParent(self)
        self.timeBurnRefresh = 0
        self.timeBurnDuration = 0

    end

    self:AddFieldWatcher("isOnFire", FireMixin.OnFireStateChange)
    
end

function FireMixin:OnDestroy()

    if self:GetIsOnFire() then
        self:SetGameEffectMask(kGameEffect.OnFire, false)
    end
    
    if Server then
    
        -- The onFireSound was already destroyed at this point, clear the reference.
        self.onFireSound = nil
        
    end
    
end

function FireMixin:SetOnFire(attacker, doer)

    if Server and not self:GetIsDestroyed() then
    
        if not self:GetCanBeSetOnFire() then
            return
        end
        
        self:SetGameEffectMask(kGameEffect.OnFire, true)
        
        if attacker then
            self.fireAttackerId = attacker:GetId()
        end
        
        if doer then
            self.fireDoerId = doer:GetId()
        end
        
        local time = Shared.GetTime()

        self.timeBurnRefresh = time
        self.timeLastFireDamageUpdate = time

        self.isOnFire = true
        
        --Flat restriction to single-shot player burn time. ideally will diminish "burn-out" deaths
        if self:isa("Player") then
            self.timeBurnDuration = kFlamethrowerBurnDuration
        else
            self.timeBurnDuration = math.min(self.timeBurnDuration + kFlamethrowerBurnDuration, kFlamethrowerMaxBurnDuration)
        end
        
    end
    
end

function FireMixin:GetIsOnFire()

    if Client then
        return self.isOnFire
    end
    
    return self:GetGameEffectMask(kGameEffect.OnFire)
    
end

function FireMixin:GetCanBeSetOnFire()

    if self.OnOverrideCanSetFire then
        return self:OnOverrideCanSetFire()
    else
        return true
    end
    
end

function FireMixin:UpdateFireState()
    PROFILE("FireMixin:UpdateFireState")

    if Client then
        self:UpdateFireMaterial()
        self:_UpdateClientFireEffects()
    end

    if Server and self:GetIsOnFire() then
        local time = Shared.GetTime()
        if self:GetIsAlive() and (not self.timeLastFireDamageUpdate or self.timeLastFireDamageUpdate + kBurnUpdateRate <= time) then

            local attacker
            if self.fireAttackerId ~= Entity.invalidId then
                attacker = Shared.GetEntity(self.fireAttackerId)
            end

            local doer
            if self.fireDoerId ~= Entity.invalidId then
                doer = Shared.GetEntity(self.fireDoerId)
            end

            local damageOverTime = kBurnUpdateRate * kBurnDamagePerSecond

            -- Upgrade damage based on marine weapons upgrades if we are on that team.
            local scalar = 1

            if attacker then -- Sanity check, but EntityChangeMixin should cause us to update our attacker entity id here.

                --Balance Mod: add target for DamageTypes.lua
                local target = self
                scalar = NS2Gamerules_GetUpgradedDamageScalar( attacker, kTechId.Flamethrower, target)
            end

            damageOverTime = damageOverTime * scalar

            if self.GetReceivesStructuralDamage and self:GetReceivesStructuralDamage() then
                damageOverTime = damageOverTime * kStructuralDamageScalar
            end

            if self.GetIsFlameAble and self:GetIsFlameAble() then
                damageOverTime = damageOverTime * kFlameableMultiplier
            end

            local _, damageDone = self:DeductHealth(damageOverTime, attacker, doer)

            if attacker then
                SendDamageMessage( attacker, self:GetId(), damageDone, self:GetOrigin(), damageDone )
            end

            self.timeLastFireDamageUpdate = time

        end

        -- See if we put ourselves out
        if time - self.timeBurnRefresh > self.timeBurnDuration then
            self:SetGameEffectMask(kGameEffect.OnFire, false)
        end

    end

    return self:GetIsOnFire() -- remove timed callback when we are not burning
end

function FireMixin:OnProcessMove()
    self:UpdateFireState()
end

-- using a timed callback to bypass the parents update rate
function FireMixin:OnFireStateChange()
    if self.isOnFire then
        self:AddTimedCallback(FireMixin.UpdateFireState, kDefaultUpdateRate)
    end

    return true
end

if Client then

    function FireMixin:UpdateFireMaterial()

        if self._renderModel then

            if self.isOnFire and not self.fireMaterial then

                self.fireMaterial = Client.CreateRenderMaterial()
                self.fireMaterial:SetMaterial(kBurningMaterial)
                self._renderModel:AddMaterial(self.fireMaterial)

            elseif not self.isOnFire and self.fireMaterial then

                self._renderModel:RemoveMaterial(self.fireMaterial)
                Client.DestroyRenderMaterial(self.fireMaterial)
                self.fireMaterial = nil

            end
        end

        if self:isa("Player") and self:GetIsLocalPlayer() then

            local viewModelEntity = self:GetViewModelEntity()
            if viewModelEntity then

                local viewModel = self:GetViewModelEntity():GetRenderModel()
                if viewModel and (self.isOnFire and not self.viewFireMaterial) then

                    self.viewFireMaterial = Client.CreateRenderMaterial()
                    self.viewFireMaterial:SetMaterial(kBurningViewMaterial)
                    viewModel:AddMaterial(self.viewFireMaterial)

                elseif viewModel and (not self.isOnFire and self.viewFireMaterial) then

                    viewModel:RemoveMaterial(self.viewFireMaterial)
                    Client.DestroyRenderMaterial(self.viewFireMaterial)
                    self.viewFireMaterial = nil

                end

            end

        end

    end
    
    function FireMixin:_UpdateClientFireEffects()

        -- Play on-fire cinematic every so often if we're on fire
        if self:GetGameEffectMask(kGameEffect.OnFire) and self:GetIsAlive() and self:GetIsVisible() then
        
            -- If we haven't played effect for a bit
            local time = Shared.GetTime()
            
            if not self.timeOfLastFireEffect or (time > (self.timeOfLastFireEffect + .5)) then
            
                local firstPerson = (Client.GetLocalPlayer() == self)
                local cinematicName = GetOnFireCinematic(self, firstPerson)
                
                if firstPerson then
                    local viewModel = self:GetViewModelEntity()
                    if viewModel then
                        Shared.CreateAttachedEffect(self, cinematicName, viewModel, Coords.GetTranslation(Vector(0, 0, 0)), "", true, false)
                    end
                else
                    Shared.CreateEffect(self, cinematicName, self, self:GetAngles():GetCoords())
                end
                
                self.timeOfLastFireEffect = time
                
            end
            
        end
        
    end

end

function FireMixin:OnEntityChange(entityId, newEntityId)

    if entityId == self.fireAttackerId then
        self.fireAttackerId = newEntityId or Entity.invalidId
    end
    
    if entityId == self.fireDoerId then
        self.fireDoerId = newEntityId or Entity.invalidId
    end
    
end

function FireMixin:OnGameEffectMaskChanged(effect, state)

    if effect ~= kGameEffect.OnFire then return end

    if state then
    
        if Server and not self.onFireSound:GetIsPlaying() then
            self.onFireSound:Start()
        end
        self.timeBurnInit = Shared.GetTime()
  
    else

        self.fireAttackerId = Entity.invalidId
        self.fireDoerId = Entity.invalidId
        
        if Server then
            self.onFireSound:Stop()
            self.timeBurnInit = 0
            self.timeBurnRefresh = 0
            self.isOnFire = false
            self.timeBurnDuration = 0
        end

    end
    
end

function FireMixin:OnUpdateAnimationInput(modelMixin)
    PROFILE("FireMixin:OnUpdateAnimationInput")
    modelMixin:SetAnimationInput("onfire", self:GetIsOnFire())
end
