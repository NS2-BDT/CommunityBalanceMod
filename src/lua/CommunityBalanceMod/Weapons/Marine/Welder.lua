-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Marine\Welder.lua
--
--    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
--
--    Weapon used for repairing structures and armor of friendly players (marines, exosuits, jetpackers).
--    Uses hud slot 3 (replaces axe)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Weapon.lua")
Script.Load("lua/PickupableWeaponMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/WelderVariantMixin.lua")

class 'Welder' (Weapon)

local kWelderMapName = "welder"
local kWelderModelName = PrecacheAsset("models/marine/welder/welder.model")

local kViewModels = GenerateMarineViewModelPaths("welder")

kWelderHUDSlot = 3

local kWelderTraceExtents = Vector(0.4, 0.4, 0.4)

local networkVars =
{
    welding = "boolean",
    loopingSoundEntId = "entityid",
    deployed = "boolean",
    welder_attached = "boolean",
}

AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(WelderVariantMixin, networkVars)

local kWeldRange = 2.4
local kWelderEffectRate = 0.45

local kFireLoopingSound = PrecacheAsset("sound/NS2.fev/marine/welder/weld")

kWelderHealScoreAdded = 2
-- Every kAmountHealedForPoints points of damage healed, the player gets
-- kHealScoreAdded points to their score.
kWelderAmountHealedForPoints = 600

function Welder:OnCreate()

    Weapon.OnCreate(self)
    
    self.welding = false
    self.deployed = false
    self.welder_attached = false --when first purchased, there's no welder attachment on the front, have to play an extra animation
    
    InitMixin(self, PickupableWeaponMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, WelderVariantMixin)
    
    self.loopingSoundEntId = Entity.invalidId
    
    if Server then
    
        self.loopingFireSound = Server.CreateEntity(SoundEffect.kMapName)
        self.loopingFireSound:SetAsset(kFireLoopingSound)
        -- SoundEffect will automatically be destroyed when the parent is destroyed (the Welder).
        self.loopingFireSound:SetParent(self)
        self.loopingSoundEntId = self.loopingFireSound:GetId()
        
    end
    
end

function Welder:OnInitialized()
    
    -- Set model to be rendered in 3rd-person
    local worldModel = LookupTechData(self:GetTechId(), kTechDataModel)
    if worldModel ~= nil then
        self:SetModel(worldModel)
    end
    
    Weapon.OnInitialized(self)
    
    self.timeWeldStarted = 0
    self.timeLastWeld = 0
    
end

function Welder:GetViewModelName(sex, variant)
    return kViewModels[sex][variant]
end

function Welder:GetAnimationGraphName()
    return WelderVariantMixin.kWelderAnimationGraph
end

function Welder:GetHUDSlot()
    return kWelderHUDSlot
end

function Welder:GetIsDroppable()
    return true
end

function Welder:OnHolster(player)

    Weapon.OnHolster(self, player)
    
    self.welder_attached = true
    self.welding = false
    self.deployed = false
    -- cancel muzzle effect
    self:TriggerEffects("welder_holster")
    
end

function Welder:OnDraw(player, previousWeaponMapName)

    Weapon.OnDraw(self, player, previousWeaponMapName)
    
    self:SetAttachPoint(Weapon.kHumanAttachPoint)
    self.welding = false
    self.deployed = true
    
end

-- for marine third person model pose, "builder" fits perfectly for this.
function Welder:OverrideWeaponName()
    return "builder"
end

function Welder:OnTag(tagName)

    if tagName == "deploy_end" then
        self.deployed = true
    end
    
    if tagName == "welderAdded" then
        self.welder_attached = true
    end

end

function Welder:GetIsAffectedByWeaponUpgrades()
    return false
end

-- don't play 'welder_attack' and 'welder_attack_end' too often, would become annoying with the sound effects and also client fps
function Welder:OnPrimaryAttack(player)

    if not self.deployed then
        return
    end
    
    PROFILE("Welder:OnPrimaryAttack")
    
    if not self.welding then
    
        self:TriggerEffects("welder_start")
        self.timeWeldStarted = Shared.GetTime()
        
        if Server then
            self.loopingFireSound:Start()
        end
        
    end
    
    local hitPoint

    if self.timeLastWeld + kWelderFireDelay < Shared.GetTime() then
    
        hitPoint = self:PerformWeld(player)
        self.timeLastWeld = Shared.GetTime()
        
    end

    self.welding = true
    
    if not self.timeLastWeldEffect or self.timeLastWeldEffect + kWelderEffectRate < Shared.GetTime() then
    
        self:TriggerEffects("welder_muzzle")
        self.timeLastWeldEffect = Shared.GetTime()
        
    end
    
end

function Welder:GetSprintAllowed()
    return true
end

-- welder wont break sprinting
function Welder:GetTryingToFire(input)
    return false
end

function Welder:GetDeathIconIndex()
    return kDeathMessageIcon.Welder
end

function Welder:OnPrimaryAttackEnd(player)

    if self.welding then
        self:TriggerEffects("welder_end")
    end
    
    self.welding = false
    
    if Server then
        self.loopingFireSound:Stop()
    end
    
end

function Welder:Dropped(prevOwner)

    Weapon.Dropped(self, prevOwner)
    
    if Server then
        self.loopingFireSound:Stop()
    end
    
    self.welding = false
    self.deployed = false
    self.welder_attached = true
    
end

function Welder:GetRange()
    return kWeldRange
end

-- repair rate increases over time
function Welder:GetRepairRate(repairedEntity)

    local repairRate = kPlayerWeldRate
    if repairedEntity.GetReceivesStructuralDamage and repairedEntity:GetReceivesStructuralDamage() then
        repairRate = kStructureWeldRate
    end
    
    return repairRate
    
end

function Welder:GetMeleeBase()
    return 2, 2
end

local function PrioritizeDamagedFriends(weapon, player, newTarget, oldTarget)
    local orig = player:GetOrigin()
    local eyePos = player:GetEyePos()
    local vCoords = player:GetViewCoords()
    local sameTeam = HasMixin(newTarget, "Team") and newTarget:GetTeamNumber() == player:GetTeamNumber()
    local isWeldable = HasMixin(newTarget, "Weldable") and newTarget:GetCanBeWelded(weapon)

    if not oldTarget then
        return true
    end

    if (sameTeam and isWeldable) or (HasMixin(newTarget, "Live") and newTarget:GetIsAlive() and GetAreEnemies(player, newTarget)) then
        -- Don't bother about the distance, the welder has a short enough range aready for us to bother
        -- taking it into account here (~2.5m)
        local oldAngle = 1-vCoords.zAxis:DotProduct(GetNormalizedVector(oldTarget:GetOrigin() - eyePos))
        local newAngle = 1-vCoords.zAxis:DotProduct(GetNormalizedVector(newTarget:GetOrigin() - eyePos))

        -- Trying to check with the model origin if provided, useful for big high units
        -- (no need to do a real traceray with both the origin and modelOrigin check, it's good enough)
        if oldTarget.GetModelOrigin then
            local oldAngleModelOrig = 1-vCoords.zAxis:DotProduct(GetNormalizedVector(oldTarget:GetModelOrigin() - eyePos))
            oldAngle = oldAngleModelOrig < oldAngle and oldAngleModelOrig or oldAngle
        end

        if newTarget.GetModelOrigin then
            local newAngleModelOrig = 1-vCoords.zAxis:DotProduct(GetNormalizedVector(newTarget:GetModelOrigin() - eyePos))
            newAngle = newAngleModelOrig < newAngle and newAngleModelOrig or newAngle
        end

        -- Log("Shoot cone for (old target: %s(%s)) %s(%s)", oldTarget, oldAngle, newTarget, newAngle)
        if newAngle < oldAngle then
            -- Log("NEW: %s closer than %s", newTarget, oldTarget)
            return true
        end
    end

    return false
end

function Welder:PerformWeld(player)

    local attackDirection = player:GetViewCoords().zAxis
    local success = false
    -- prioritize friendlies
    local didHit, target, endPoint, direction, surface

    local viewAngles = player:GetViewAngles()
    local viewCoords = viewAngles:GetCoords()
    local startPoint = player:GetEyePos()
    local endPoint = startPoint + viewCoords.zAxis * self:GetRange()

    -- Filter ourself out of the trace so that we don't hit ourselves.
    -- Filter also clogs out for the ray check because they ray "detection" box is somehow way bigger than the visual model
    local filter = EntityFilterTwo(player, self)
    local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, filter)

    -- Perform a Ray trace first, otherwise fallback to a regular melee capsule
    if (trace.entity) then
        didHit = true
        target = trace.entity
        endPoint = trace.endPoint
        direction = viewCoords.zAxis
        surface = trace.surface
    else
        didHit, target, endPoint, direction, surface = CheckMeleeCapsule(self, player, 0, self:GetRange(), nil, true, 1, PrioritizeDamagedFriends, nil, PhysicsMask.Flame)
    end

    if didHit and target and HasMixin(target, "Live") then
        
        local timeSinceLastWeld = self.welding and Shared.GetTime() - self.timeLastWeld or 0
        
        if GetAreEnemies(player, target) then
            self:DoDamage(kWelderDamagePerSecond * timeSinceLastWeld, target, endPoint, attackDirection)
            success = true     
        elseif player:GetTeamNumber() == target:GetTeamNumber() and HasMixin(target, "Weldable") then
        
            if target:GetHealthScalar() < 1 then
                
                local prevHealthScalar = target:GetHealthScalar()
                local prevHealth = target:GetHealth()
                local prevArmor = target:GetArmor()
                target:OnWeld(self, timeSinceLastWeld, player)
                success = prevHealthScalar ~= target:GetHealthScalar()
                
                if success then
                
                    local addAmount = (target:GetHealth() - prevHealth) + (target:GetArmor() - prevArmor)
                    player:AddContinuousScore("WeldHealth", addAmount, kWelderAmountHealedForPoints, kWelderHealScoreAdded)
                    
                    local oldArmor = player:GetArmor()
                    
                    -- weld owner as well
                    player:SetArmor(oldArmor + kWelderFireDelay * kSelfWeldAmount)

                    if player.OnArmorWelded and oldArmor < player:GetArmor() then
                        player:OnArmorWelded(self)
                    end
                    
                end
                
            end
            
            if HasMixin(target, "Construct") and target:GetCanConstruct(player) then

                --Balance mod
                if player:isa("Marine") and player:GetHasCatPackBoost() then 
                    target:Construct(timeSinceLastWeld * 0.875, player) -- Reduce time between welds by 12.5%
                else 
                    target:Construct(timeSinceLastWeld, player)
                end
            end
            
        end
        
    end
    
    if success then    
        return endPoint
    end
    
end

function Welder:GetShowDamageIndicator()
    return true
end

function Welder:GetReplacementWeaponMapName()
    return Axe.kMapName
end

function Welder:OnUpdateAnimationInput(modelMixin)

    PROFILE("Welder:OnUpdateAnimationInput")
    
    local parent = self:GetParent()
    local sprinting = parent ~= nil and HasMixin(parent, "Sprint") and parent:GetIsSprinting()
    local activity = (self.welding and not sprinting) and "primary" or "none"
    
    modelMixin:SetAnimationInput("activity", activity)
    modelMixin:SetAnimationInput("needWelder", true)
    modelMixin:SetAnimationInput("welder", self.welder_attached)
    
end

function Welder:UpdateViewModelPoseParameters(viewModel)
    viewModel:SetPoseParam("welder", 1)    
end

function Welder:OnUpdatePoseParameters(viewModel)

    PROFILE("Welder:OnUpdatePoseParameters")
    self:SetPoseParam("welder", 1)
    
end

function Welder:OnUpdateRender()

    Weapon.OnUpdateRender(self)
    
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
                
                local className
                if trace.entity then
                    className = trace.entity:GetClassName()
                end
                
                self:TriggerEffects("welder_hit", { classname = className, effecthostcoords = coords})
                
            end
            
            self.timeLastWeldHitEffect = Shared.GetTime()
            
        end
        
    end
    
end

function Welder:ModifyDamageTaken(damageTable, attacker, doer, damageType)
    if damageType ~= kDamageType.Corrode then
        damageTable.damage = 0
    end
end

function Welder:GetCanTakeDamageOverride()
    return self:GetParent() == nil
end

if Server then

    function Welder:GetDestroyOnKill()
        return true
    end
    
    function Welder:GetSendDeathMessageOverride()
        return false
    end    
    
end

function Welder:GetIsWelding()
    return self.welding
end

if Client then

    function Welder:GetUIDisplaySettings()
        return { xSize = 512, ySize = 512, script = "lua/GUIWelderDisplay.lua", variant = self:GetWelderVariant() }
    end
    
end

Shared.LinkClassToMap("Welder", kWelderMapName, networkVars)
