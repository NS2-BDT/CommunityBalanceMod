local kleftweldereffect = PrecacheAsset("cinematics/marine/welder/exowelder_muzzle.cinematic")
local krightweldereffect = PrecacheAsset("cinematics/marine/welder/exowelder_muzzle.cinematic")

Script.Load("lua/Weapons/Weapon.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponHolder.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponSlotMixin.lua")
Script.Load("lua/TechMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/EffectsMixin.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")

class 'ExoWelder'(Entity)

ExoWelder.kMapName = "exowelder"

local kWelderTraceExtents = Vector(0.4, 0.4, 0.4)

local networkVars = {
    welding           = "boolean",
    loopingSoundEntId = "entityid",
    
}

AddMixinNetworkVars(ExoWeaponSlotMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)

local kFireLoopingSound = PrecacheAsset("sound/NS2.fev/marine/welder/weld")
local kAmountHealedForPoints = 600

function ExoWelder:OnCreate()
    
    Entity.OnCreate(self)
    
    --InitMixin(self, LiveMixin)
    InitMixin(self, ExoWeaponSlotMixin)
    InitMixin(self, DamageMixin)
    
    self.loopingSoundEntId = Entity.invalidId
    self.welding = false
    
    if Server then
        
        self.loopingFireSound = Server.CreateEntity(SoundEffect.kMapName)
        self.loopingFireSound:SetAsset(kFireLoopingSound)
        -- SoundEffect will automatically be destroyed when the parent is destroyed (the Welder).
        self.loopingFireSound:SetParent(self)
        self.loopingSoundEntId = self.loopingFireSound:GetId()
    
    end

end

function ExoWelder:OnInitialized()
    
    Entity.OnInitialized(self)
    
    self.timeWeldStarted = 0
    self.timeLastWeld = 0


end

--[[local kMuzzleEffectName = PrecacheAsset("cinematics/marine/magmalance/muzzle_flash.cinematic")
local function CreateMuzzleEffect(self)

    local coords = Coords.GetIdentity()
    coords.origin = Vector(-0.65, -0.15, 1.7)

    local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
    cinematic:SetCinematic(kMuzzleEffectName)
    cinematic:SetCoords(coords)

end]]

function ExoWelder:OnTag(tagName)
    
    if tagName == "deploy_end" then
        self.deployed = true
    end

end

function ExoWelder:GetIsAffectedByWeaponUpgrades()
    return true
end

function ExoWelder:OnPrimaryAttack(player)
    
    
    PROFILE("ExoWelder:OnPrimaryAttack")
    
    if not self.welding then
        
        -- self:TriggerEffects("welder_start")
        self.timeWeldStarted = Shared.GetTime()
        
        if Server then
            self.loopingFireSound:Start()
        end
    
    end
    
    self.welding = true
    local hitPoint = nil
    
    if self.timeLastWeld + ExoWelder.kWelderFireDelay < Shared.GetTime() then
        
        hitPoint = self:PerformWeld(player)
        self.timeLastWeld = Shared.GetTime()
    
    end
    
    if not self.timeLastWeldEffect or self.timeLastWeldEffect + ExoWelder.kWelderEffectRate < Shared.GetTime() then
        
        if self:GetIsLeftSlot() then
            player:TriggerEffects("leftexowelder_muzzle")
        elseif self:GetIsRightSlot() then
            player:TriggerEffects("rightexowelder_muzzle")
        end
        self.timeLastWeldEffect = Shared.GetTime()
    end

end

function ExoWelder:GetDeathIconIndex()
    return kDeathMessageIcon.Welder
end

function ExoWelder:OnPrimaryAttackEnd(player)
    
    if self.welding then
        player:TriggerEffects("welder_end")
    end
    
    self.welding = false
    
    if Server then
        self.loopingFireSound:Stop()
    end

end

function ExoWelder:ProcessMoveOnWeapon(player, input)
    
    if self.welding then
        
        local exoWeaponHolder = player:GetActiveWeapon()
    
    end


end

function ExoWelder:GetRange()
    return ExoWelder.kWeldRange
end

--function ExoWelder:GetRepairRate(repairedEntity)

--  local repairRate = kPlayerWeldRate
--   if repairedEntity.GetReceivesStructuralDamage and repairedEntity:GetReceivesStructuralDamage() then
--    repairRate = kStructureWeldRate
--  end

-- return repairRate

--end

function ExoWelder:GetMeleeBase()
    return 2, 2
end

function ExoWelder:GetMeleeOffset()
    return 0.0
end

--local function PrioritizeDamagedFriends(weapon, player, newTarget, oldTarget)
--    _D("WTF", weapon, player)
--  return not oldTarget or (HasMixin(newTarget, "Team") and newTarget:GetTeamNumber() == player:GetTeamNumber() and (HasMixin(newTarget, "Weldable") and newTarget:GetCanBeWelded(player)))
--end

local function PrioritizeDamagedFriends(weapon, player, newTarget, oldTarget)
    return true
end

function ExoWelder:GetTechId()
    return kTechId.ExoWelder
end

function ExoWelder:PerformWeld(player)
    
    local attackDirection = player:GetViewCoords().zAxis
    local success = false
    -- prioritize friendlies
    local didHit, target, endPoint, direction, surface = CheckMeleeCapsule(self, player, 0, self:GetRange(), nil, true, 1, PrioritizeDamagedFriends, nil, PhysicsMask.Flame)
    
    if didHit and target and HasMixin(target, "Live") then
        
        if GetAreEnemies(player, target) then
            self:DoDamage(ExoWelder.kWelderDamagePerSecond * ExoWelder.kWelderFireDelay, target, endPoint, attackDirection)
            success = true
        elseif player:GetTeamNumber() == target:GetTeamNumber() and HasMixin(target, "Weldable") then
            
            
            if target:GetHealthScalar() < 1 then
                
                local prevHealthScalar = target:GetHealthScalar()
                local prevHealth = target:GetHealth()
                local prevArmor = target:GetArmor()
                -- target:OnWeld(self, kWelderFireDelay, player)
                if target:GetCanBeWelded(player) then
                    if target.OnWeldOverride then
                        target:OnWeldOverride(player, ExoWelder.kWelderFireDelay)
                    else
                        target:AddHealth(self:GetRepairRate(target) * ExoWelder.kWelderFireDelay)
                    
                    end
                    if player and player.OnWeldTarget then
                        player:OnWeldTarget(target)
                    end
                end
                
                success = prevHealthScalar ~= target:GetHealthScalar()
                
                if success then
                    
                    local addAmount = (target:GetHealth() - prevHealth) + (target:GetArmor() - prevArmor)
                    player:AddContinuousScore("WeldHealth", addAmount, ExoWelder.kAmountHealedForPoints, ExoWelder.kHealScoreAdded)
                    
                    -- weld owner as well
                    player:SetArmor(player:GetArmor() + ExoWelder.kWelderFireDelay * ExoWelder.kSelfWeldAmount)
                
                end
            
            end
            
            if HasMixin(target, "Construct") then
                target:Construct(ExoWelder.kWelderFireDelay, player)
            end
        
        end
    
    end
    
    if success then
        return endPoint
    end

end

function ExoWelder:GetRepairRate(repairedEntity)
    
    local repairRate = ExoWelder.kPlayerWeldRate
    if repairedEntity.GetReceivesStructuralDamage and repairedEntity:GetReceivesStructuralDamage() then
        repairRate = ExoWelder.kStructureWeldRate
    end
    
    return repairRate

end

function ExoWelder:GetShowDamageIndicator()
    return true
end

function ExoWelder:OnUpdateAnimationInput(modelMixin)
    
    PROFILE("ExoWelder:OnUpdateAnimationInput")
    
    local parent = self:GetParent()
    --local sprinting = parent ~= nil and HasMixin(parent, "Sprint") and parent:GetIsSprinting()
    local activity = self.welding and "primary" or "none"
    --modelMixin:SetAnimationInput("activity_" .. self:GetExoWeaponSlotName(), activity)

end

function ExoWelder:UpdateViewModelPoseParameters(viewModel)
    viewModel:SetPoseParam("welder", 1)
end

function ExoWelder:OnUpdatePoseParameters(viewModel)
    
    PROFILE("ExoWelder:OnUpdatePoseParameters")
    self:SetPoseParam("welder", 1)

end

function ExoWelder:OnUpdateRender()
    
    PROFILE("ExoWelder:OnUpdateRender")
    
    --Entity.OnUpdateRender(self)
    
    if self.ammoDisplayUI then
        
        local progress = PlayerUI_GetUnitStatusPercentage()
        self.ammoDisplayUI:SetGlobal("weldPercentage", progress)
    
    end
    
    local parent = self:GetParent()
    if parent and self.welding then
        
        if (not self.timeLastWeldHitEffect or self.timeLastWeldHitEffect + 0.06 < Shared.GetTime()) then
            
            local viewCoords = parent:GetViewCoords()
            
            local trace = Shared.TraceRay(viewCoords.origin, viewCoords.origin + viewCoords.zAxis * self:GetRange(), CollisionRep.Damage, PhysicsMask.Flame, EntityFilterTwo(self, parent))
            if trace.fraction ~= 1 then
                
                local coords = Coords.GetTranslation(trace.endPoint - viewCoords.zAxis * .1)
                
                local className = nil
                if trace.entity then
                    className = trace.entity:GetClassName()
                end
                
                parent:TriggerEffects("welder_hit", { classname = className, effecthostcoords = coords })
            
            end
            
            self.timeLastWeldHitEffect = Shared.GetTime()
        
        end
    
    end
end

function ExoWelder:ModifyDamageTaken(damageTable, attacker, doer, damageType)
    if damageType ~= kDamageType.Corrode then
        damageTable.damage = 0
    end
end

function ExoWelder:GetCanTakeDamageOverride()
    return self:GetParent() == nil
end

if Server then
    
    function ExoWelder:OnKill()
        DestroyEntity(self)
    end
    
    function ExoWelder:GetSendDeathMessageOverride()
        return false
    end

end

function ExoWelder:GetIsWelding()
    return self.welding
end

function ExoWelder:OnTag(tagName)
    
    PROFILE("ExoWelder:OnTag")
    
    if not self:GetIsLeftSlot() then
        
        if tagName == "deploy_end" then
            self.deployed = true
        end
    
    end

end

Shared.LinkClassToMap("ExoWelder", ExoWelder.kMapName, networkVars)