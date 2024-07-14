Script.Load("lua/LiveMixin.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponHolder.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponSlotMixin.lua")
Script.Load("lua/TechMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")

Script.Load("lua/ModularExos/ExoWeapons/ShieldProjectorMixin.lua")

class 'ExoShield'(Entity)

ExoShield.kMapName = "exoshield"

-- shield state: undeployed --*toggle*   -> deployed
--               deployed   --*delay*    -> active
--               active     --*overheat* -> overheated --*delay* -> deployed
--               active     --*toggle*   -> deployed   --*delay* -> undeployed
-- combat state: idle       --*damage*   -> combat     --*delay* -> idle

-- TODO: Move balance-related stuff into ModularExo_Balance.lua
-- up
ExoShield.kShieldAngleYawMin = math.rad(90) -- left
ExoShield.kShieldAngleYawMax = math.rad(90) -- right



ExoShield.kShieldPitchUpDeadzone = math.rad(10)
ExoShield.kShieldPitchUpLimit = math.rad(30)

ExoShield.kShieldDistance = 2.2
ExoShield.kShieldHeightMin = 2-- down
ExoShield.kShieldHeightMax = 1

local hexagonSideLength, hexagonGap = 0.195, 0.02
ExoShield.kShieldEffectHexagonColCount = math.floor((ExoShield.kShieldAngleYawMin + ExoShield.kShieldAngleYawMax) * ExoShield.kShieldDistance / (math.sqrt(3) * hexagonSideLength + hexagonGap))
ExoShield.kShieldEffectHexagonRowCount = math.floor((ExoShield.kShieldHeightMin + ExoShield.kShieldHeightMax) / (math.sqrt(3) * hexagonSideLength + hexagonGap))

local networkVars = {
    heatAmount             = "float (0 to 1 by 0.01)", -- current shield heat
    isShieldDesired        = "boolean", -- if the user wants the shield up (click to toggle)
    isShieldDeployed       = "boolean", -- if the shield is "powered" (may not be active)
    --isShieldActive = "boolean", -- if the shield is 
    isShieldOverheated     = "boolean", -- if the shield is currently cooling down from an overheat
    shieldDeployChangeTime = "time", -- the time the shield was deployed/undeployed
    lastHitTime            = "time", -- the last time damage was done to the shield
}

--AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(ExoWeaponSlotMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(ShieldProjectorMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)

function ExoShield:OnCreate()
    
    PROFILE("ExoShield:OnCreateRender")
    
    Entity.OnCreate(self)
    
    --InitMixin(self, TechMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, ExoWeaponSlotMixin)
    InitMixin(self, ShieldProjectorMixin)
    InitMixin(self, NanoShieldMixin)
    
    self.heatAmount = 0
    self.isShieldDesired = false
    self.isShieldDeployed = false
    self.isShieldOverheated = false
    self.shieldDeployChangeTime = 0
    self.lastHitTime = 0
    
    self.isShieldActive = false
    self.idleHeatAmount = 0
    self.isInCombat = false
    
    self.isPhysicsActive = false
    
    self.contactEntityIdList = {}
    self.contactEntityIdMap = {}
    
    if Client then
        self.shieldEffectScalar = 0
    end
    
    --self:SetUpdates(true)
end
function ExoShield:OnInitialized()

end
function ExoShield:GetTechId()
    return nil
end
function ExoShield:OnDestroy()
    Entity.OnDestroy(self)
    self:DestroyPhysics()
    if Client then
        if self.shieldModel then
            Client.DestroyRenderModel(self.shieldModel)
            self.shieldModel = nil
        end
        if self.clawLight then
            Client.DestroyRenderLight(self.clawLight)
            self.clawLight = nil
        end
        if self.cinematicList then
            for cinematicI, cinematic in ipairs(self.cinematicList) do
                Client.DestroyCinematic(cinematic)
            end
            self.cinematicList = nil
        end
        if self.heatDisplayUI then
            Client.DestroyGUIView(self.heatDisplayUI)
            self.heatDisplayUI = nil
        end
    end
end

function ExoShield:OnPrimaryAttack(player)
    if not player:GetPrimaryAttackLastFrame() then
        self.isShieldDesired = not self.isShieldDesired -- toggle desired state
    end
end
function ExoShield:OnPrimaryAttackEnd(player)
    self.isShieldDesired = false
end

function ExoShield:UpdateHeat(dt, shouldSet)
    
    
    self.isInCombat = (Shared.GetTime() < self.lastHitTime + ExoShield.kCombatDuration)
    local cooldownRate = (
            self.isShieldOverheated and ExoShield.kHeatOverheatedDrainRate
                    or not self.isShieldDeployed and ExoShield.kHeatUndeployedDrainRate
                    or self.isInCombat and ExoShield.kHeatCombatDrainRate
                    or ExoShield.kHeatActiveDrainRate
    )
    if self.isShieldOverheated and self.heatAmount <= ExoShield.kOverheatCooldownGoal then
        self.isShieldOverheated = false
    end
    local minHeat = 0
    if self.isShieldDeployed then
        local baseHeatScalar = Clamp((Shared.GetTime() - self.shieldDeployChangeTime) / ExoShield.kIdleBaseHeatMaxDelay, 0, 1)
        minHeat = minHeat + ExoShield.kIdleBaseHeatMin + (ExoShield.kIdleBaseHeatMax - ExoShield.kIdleBaseHeatMin) * baseHeatScalar
        if self.isInCombat then
            minHeat = minHeat + ExoShield.kCombatBaseHeatExtra
        end
        minHeat = Clamp(minHeat + math.sin(Shared.GetTime()) * 0.06, 0, 1)
    end
    self.idleHeatAmount = minHeat
    
    if self.heatAmount >= 1 then
        self.isShieldOverheated = true
    end
    if shouldSet then
        self.heatAmount = Clamp(self.heatAmount - cooldownRate * dt, minHeat, 1)
    end
end

function ExoShield:AbsorbDamage(damage)
    self.heatAmount = self.heatAmount + ExoShield.kHeatPerDamage * damage
    -- Print("ouch %s! (%s)", damage, self.heatAmount)
    self.lastHitTime = Shared.GetTime()
end
function ExoShield:AbsorbProjectile(projectileEnt)
    if projectileEnt:isa("Bomb") then
        projectileEnt:TriggerEffects("bomb_absorb")
        self:AbsorbDamage(kBileBombDamage * ExoShield.kCorrodeDamageScalar)
    elseif projectileEnt:isa("WhipBomb") then
        projectileEnt:TriggerEffects("whipbomb_absorb")
        self:AbsorbDamage(kWhipBombardDamage * ExoShield.kCorrodeDamageScalar)
        self.lastHitTime = Shared.GetTime()
    end
end
function ExoShield:OverrideTakeDamage(damage, attacker, doer, point, direction, armorUsed, healthUsed, damageType, preventAlert)
    self:AbsorbDamage(damage)
    --Print("ouch %s", damage)
    return false, false, 0.0001 -- must be >0 if you want damage numbers to appear
end
function ExoShield:GetIsEntityZappable(ent)
    return HasMixin(ent, "Live") and ent:GetIsAlive()--and ent:GetTeam() == kAlienTeamType and HasMixin(ent, "Energy")
end
function ExoShield:StartZappingEntity(ent)
    --Print("New entity %s (%s) in contact", ent:GetId(), ent:GetClassName())
    if #self.contactEntityIdList == 1 then
        if Client then
            if not self.contactSoundEffect then
                self.contactSoundEffect = Client.CreateSoundEffect(Shared.GetSoundIndex("sound/NS2.fev/marine/grenades/pulse/explode"))--"sound/NS2.fev/ambient/neon light loop"))
                self.contactSoundEffect:SetParent(self:GetId())
                self.contactSoundEffect:SetCoords(Coords.GetTranslation(self:GetShieldCoords().origin))
                self.contactSoundEffect:SetPositional(true)
                self.contactSoundEffect:SetRolloff(SoundSystem.Rolloff_Linear)
                self.contactSoundEffect:SetMinDistance(0)
                self.contactSoundEffect:SetMaxDistance(10)
                
                self.contactSoundEffect:SetVolume(1)
                --self.contactSoundEffect:SetPitch(self.pitch)
            end
            self.contactSoundEffect:Start()
        end
    end
end
function ExoShield:StopZappingEntity(ent)
    if #self.contactEntityIdList == 0 then
        if Client then
            self.contactSoundEffect:Stop()
        end
    end
end
function ExoShield:UpdateZapping(deltaTime)
    for entI, entId in ipairs(self.contactEntityIdList) do
        local ent = Shared.GetEntity(entId)
        if HasMixin(ent, "Energy") then
            ent:AddEnergy(-ent:GetMaxEnergy() * ExoShield.kContactEnergyDrainRatePercent * deltaTime)
            ent:AddEnergy(-ExoShield.kContactEnergyDrainRateFixed * deltaTime)
        end
    end
end
function ExoShield:GetIsNanoShielded()
    return true
end

function ExoShield:GetOwner()
    return self:GetParent()
end
function ExoShield:GetIsShieldActive()
    return self.isShieldActive
end
function ExoShield:GetShieldTeam()
    return kMarineTeamType
end
function ExoShield:GetShieldProjectorCoordinates()
    local player = self:GetParent()
    local playerViewCoords = player:GetViewCoords()
    local playerAngles = Angles()
    playerAngles:BuildFromCoords(playerViewCoords)
    
    playerAngles.pitch = Clamp(playerAngles.pitch + ExoShield.kShieldPitchUpDeadzone, -ExoShield.kShieldPitchUpLimit, 0)
    
    local projectorCoords = playerAngles:GetCoords() -- GetViewCoords seems to twitch when used directly..
    projectorCoords.origin = playerViewCoords.origin
    
    return projectorCoords, playerAngles
end
function ExoShield:GetShieldDistance()
    return ExoShield.kShieldDistance
end
function ExoShield:GetShieldAngleExtents()
    return ExoShield.kShieldAngleYawMin, ExoShield.kShieldAngleYawMax
end

--function ExoShield:OnUpdate(deltaTime)
function ExoShield:ProcessMoveOnWeapon(player, input)
    
    PROFILE("ExoShield:ProcessMoveOnWeapon")
    
    local deltaTime = input.time
    local time = Shared.GetTime()
    
    if self.isShieldDesired and not self.isShieldOverheated then
        if not self.isShieldDeployed and time > self.shieldDeployChangeTime + ExoShield.kShieldToggleDelay then
            self.isShieldDeployed = true
            self.shieldDeployChangeTime = time
        end
    elseif self.isShieldDeployed and time > self.shieldDeployChangeTime + ExoShield.kShieldToggleDelay then
        self.isShieldDeployed = false
        self.shieldDeployChangeTime = time
    end
    
    self.isShieldActive = (self.isShieldDeployed and time > self.shieldDeployChangeTime + ExoShield.kShieldOnDelay)
    if Server then
        self:UpdateHeat(deltaTime, true)
        self:UpdateZapping(deltaTime)
    else
        self:UpdateHeat(deltaTime, false)
    end
    self:UpdatePhysics(deltaTime)
    
    self:UpdateShieldProjectorMixin(deltaTime)
end

function ExoShield:UpdatePhysics()
    --Print("?!?")
    PROFILE("ExoShield:UpdatePhysics")
    
    if self.isShieldActive and not self.isPhysicsActive then
        self:CreatePhysics()
    elseif not self.isShieldActive and self.isPhysicsActive then
        self:DestroyPhysics()
    end
    if self.isPhysicsActive then
        for physBodyI, physBody in ipairs(self.physBodyList) do
            local rowI = math.floor(physBodyI / ExoShield.kPhysBodyColCount) + 1
            local colI = physBodyI % ExoShield.kPhysBodyColCount
            
            local coords = self:GetShieldCoords((colI - 0.5) / ExoShield.kPhysBodyColCount, (rowI - 0.5) / ExoShield.kPhysBodyRowCount)
            physBody:SetCoords(coords)
        end
    end
end
function ExoShield:CreatePhysics()
    if not self.isPhysicsActive then
        self.isPhysicsActive = true
        self.physBodyList = {}
        local width = math.sqrt(2 * ExoShield.kShieldDistance ^ 2 * (1 - math.cos((ExoShield.kShieldAngleYawMin + ExoShield.kShieldAngleYawMax) / ExoShield.kPhysBodyColCount)))
        local height = (ExoShield.kShieldHeightMin + ExoShield.kShieldHeightMax) / ExoShield.kPhysBodyRowCount
        local projectorCoords = self:GetShieldProjectorCoordinates()
        for rowI = 1, ExoShield.kPhysBodyRowCount do
            for colI = 1, ExoShield.kPhysBodyColCount do
                local physBody = Shared.CreatePhysicsBoxBody(true, Vector(width / 2, height / 2, ExoShield.kShieldDepth / 2), 10, projectorCoords)
                physBody:SetEntity(self)
                physBody:SetPhysicsType(CollisionObject.Dynamic)
                physBody:SetGroup(PhysicsGroup.ShieldGroup)
                --physBody:SetGroupFilterMask(PhysicsMask.None)
                physBody:SetTriggeringEnabled(true)
                physBody:SetCollisionEnabled(true)
                physBody:SetGravityEnabled(false)
                table.insert(self.physBodyList, physBody)
            end
        end
        --Print("Phyzzz on %s!", Server and "Server" or Client and "Client" or "?!?")
    end
end
function ExoShield:DestroyPhysics()
    if self.isPhysicsActive then
        for i, physBody in ipairs(self.physBodyList) do
            Shared.DestroyCollisionObject(physBody)
        end
        self.isPhysicsActive = false
        --Print("Phyzzz dead on %s.", Server and "Server" or Client and "Client" or "?!?")
    end
end

function ExoShield:OnUpdateRender()
    PROFILE("ExoShield:OnUpdateRender")
    
    --Print("meow")
    local time = Shared.GetTime()
    local lastTime = self.lastOnUpdateRenderTime or 0
    local deltaTime = time - lastTime
    self.lastOnUpdateRenderTime = time
    
    local delay = self.isShieldDeployed and ExoShield.kShieldEffectOnDelay or ExoShield.kShieldEffectOffDelay
    self.shieldEffectScalar = Clamp((time - self.shieldDeployChangeTime) / delay, 0, 1)
    --Print(tostring(self.shieldDeployChangeTime))
    if not self.isShieldDeployed then
        self.shieldEffectScalar = 1 - self.shieldEffectScalar
    end
    
    local coords = self:GetShieldCoords()
    
    --local player = self:GetParent()
    if not self.clawLight then
        self.clawLight = Client.CreateRenderLight()
        self.clawLight:SetType(RenderLight.Type_Point)
        self.clawLight:SetCastsShadows(false)
        self.clawLight:SetAtmosphericDensity(1)
        self.clawLight:SetSpecular(0)
    end
    self.clawLight:SetIsVisible(self.shieldEffectScalar > 0)
    self.clawLight:SetRadius(10 * self.shieldEffectScalar)
    self.clawLight:SetIntensity(15 * self.shieldEffectScalar)
    self.clawLight:SetColor(LerpColor(Color(0, 0.7, 1, 1), Color(1, 0, 0, 1), self.heatAmount))
    self.clawLight:SetCoords(coords)
    
    if false and not self.shieldModel then
        self.shieldModelIsViewModel = shouldDisplayAsViewModel
        self.shieldModel = Client.CreateRenderModel(RenderScene.Zone_Default)
        self.shieldModel:SetModel("models/effects/arc_blast.model")
    end
    --[[ local rotAngles = Angles(-math.pi/2, 0, 0)
    coords = coords*rotAngles:GetCoords()
    coords.xAxis = coords.xAxis*24.00
    coords.yAxis = coords.yAxis*0.05
    coords.zAxis = coords.zAxis*15.00*(0.1+math.max(0, self.shieldEffectScalar-0.5)/0.5*0.9) ]]
    if self.shieldModel then
        self.shieldModel:SetIsVisible(self.shieldEffectScalar > 0)
        self.shieldModel:SetCoords(coords)
    end
    
    if not self.cinematicList then
        --Print("%s", self.cinematicList)
        local projectorCoords = self:GetShieldProjectorCoordinates()
        self.cinematicList = {}
        self.cinematicCoordsList = {}
        for cinematicI = 1, ExoShield.kShieldEffectHexagonColCount * ExoShield.kShieldEffectHexagonRowCount do
            local cinematic = Client.CreateCinematic(RenderScene.Zone_Default)
            cinematic:SetCinematic("cinematics/modularexo/exoshield_hexagon_idle.cinematic")
            cinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
            --cinematic:SetCoords(coords)
            self.cinematicList[cinematicI] = cinematic
            local coords = Coords.GetIdentity()
            coords.xAxis, coords.yAxis, coords.zAxis = projectorCoords.xAxis, projectorCoords.yAxis, projectorCoords.zAxis
            coords.origin = Vector(0, 0, 0)
            self.cinematicCoordsList[cinematicI] = projectorCoords
        end
    end
    if self.cinematicList then
        
        local projectorCoords = self:GetShieldProjectorCoordinates()
        for cinematicI, cinematic in ipairs(self.cinematicList) do
            local rowI = math.floor(cinematicI / ExoShield.kShieldEffectHexagonColCount) + 1
            local colI = cinematicI % ExoShield.kShieldEffectHexagonColCount
            local isEven = (colI % 2 == 0)
            local newCoords = self:GetShieldCoords(
                    (colI - 0.5) / ExoShield.kShieldEffectHexagonColCount,
                    (rowI - (isEven and 0 or 0.5)) / ExoShield.kShieldEffectHexagonRowCount
            )
            newCoords.origin = newCoords.origin - projectorCoords.origin
            
            local hexagonSize = math.sqrt(3) * hexagonSideLength
            local startPoint = Vector(projectorCoords.origin)
            startPoint.y = projectorCoords.origin.y + newCoords.origin.y
            local endPoint = projectorCoords.origin + newCoords.origin--startPoint.origin+(newCoords.origin-startPoint.origin)*2
            local trace = Shared.TraceBox(
                    Vector(hexagonSize, hexagonSize, hexagonSize),
                    startPoint, endPoint,
                    CollisionRep.Default, PhysicsMask.MarineBullets, EntityFilterTwo(self, self:GetParent())
            )
            local rate = RRR or 11 + 3 * (2 * math.random() - 1)
            local angRate = math.pi * 2 / (4 + 1 * (2 * math.random() - 1))
            --[[ if trace.fraction ~= 1 then
                rate = rate*3
                local normal = -trace.normal
                newCoords = Angles(0, math.atan2(normal.x, normal.z), 0):GetCoords()
                newCoords.origin = trace.endPoint-projectorCoords.origin
                local f = trace.fraction--Clamp((trace.fraction-0.5)*2, 0, 1)
                --newCoords.xAxis = newCoords.xAxis*f
                --newCoords.yAxis = newCoords.yAxis*f
                --newCoords.zAxis = newCoords.zAxis*f
            end ]]
            
            local prevCoords = self.cinematicCoordsList[cinematicI]
            local prevAngles = Angles()
            prevAngles:BuildFromCoords(prevCoords)
            local newAngles = Angles()
            newAngles:BuildFromCoords(newCoords)
            local angles = SlerpAngles(prevAngles, newAngles, math.pi * 2 * angRate * deltaTime)
            local anglesCoords = angles:GetCoords()
            anglesCoords.origin = SlerpVector(prevCoords.origin, newCoords.origin, rate * deltaTime)
            self.cinematicCoordsList[cinematicI] = anglesCoords
            
            local actualCoords = Coords.GetIdentity()
            actualCoords.xAxis, actualCoords.yAxis, actualCoords.zAxis = anglesCoords.xAxis, anglesCoords.yAxis, anglesCoords.zAxis
            actualCoords.origin = anglesCoords.origin + projectorCoords.origin
            cinematic:SetCoords(actualCoords)
            
            cinematic:SetIsVisible(self.isShieldActive)
        end
    end
    
    local parent = self:GetParent()
    if parent and parent:GetIsLocalPlayer() then
        local heatDisplayUI = self.heatDisplayUI
        if not heatDisplayUI then
            heatDisplayUI = Client.CreateGUIView(242 + 64, 720)
            heatDisplayUI:Load("lua/ModularExos/GUI/GUI" .. self:GetExoWeaponSlotName():gsub("^%l", string.upper) .. "ShieldDisplay.lua")
            heatDisplayUI:SetTargetTexture("*exo_claw_" .. self:GetExoWeaponSlotName())
            self.heatDisplayUI = heatDisplayUI
        end
        heatDisplayUI:SetGlobal("heatAmount" .. self:GetExoWeaponSlotName(), self.heatAmount)
        heatDisplayUI:SetGlobal("idleHeatAmount" .. self:GetExoWeaponSlotName(), self.idleHeatAmount)
        heatDisplayUI:SetGlobal("shieldStatus" .. self:GetExoWeaponSlotName(), (
                self.isShieldOverheated and "overheat"
                        or not self.isShieldDesired and "off"
                        or self.isInCombat and "combat"
                        or "on"
        ))
    end
end

function ExoShield:GetShieldCoords(xFraction, yFraction)
    xFraction = xFraction or 0.5
    yFraction = yFraction or 0.5
    
    local projectorCoords, projectorAngles = self:GetShieldProjectorCoordinates()
    
    projectorAngles.yaw = projectorAngles.yaw - ExoShield.kShieldAngleYawMin + xFraction * (ExoShield.kShieldAngleYawMin + ExoShield.kShieldAngleYawMax)
    --projectorAngles.pitch = projectorAngles.pitch-ExoShield.kShieldAnglePitchMin+yFraction*(ExoShield.kShieldAnglePitchMin+ExoShield.kShieldAnglePitchMax)
    local forwardOffset = projectorAngles:GetCoords().zAxis * ExoShield.kShieldDistance
    projectorAngles.pitch = 0
    local shieldCoords = projectorAngles:GetCoords()
    shieldCoords.origin = (
            projectorCoords.origin
                    + forwardOffset
                    + Vector(0, -ExoShield.kShieldHeightMin + yFraction * (ExoShield.kShieldHeightMax + ExoShield.kShieldHeightMin), 0)
    )
    
    return shieldCoords
end

function ExoShield:GetSurfaceOverride(dmg)
    return "nanoshield" -- alternatively: "electronic", "armor", "flame", "ethereal", "hallucination", "structure"
end

function ExoShield:OnTag(tagName)
    PROFILE("ExoShield:OnTag")
    local player = self:GetParent()
    if player then
        if tagName == "hit" then
        elseif tagName == "claw_attack_start" then
            --player:TriggerEffects("claw_attack")
        end
    end
end

function ExoShield:OnUpdateAnimationInput(modelMixin)
    --modelMixin:SetAnimationInput("activity_" .. self:GetExoWeaponSlotName(), self.isShieldActive)
end

function ExoShield:GetWeight()
    return 0
end

function ExoShield:OnTriggerEntered(entA, entB)
    local ent = (entA == self and entB or entA)
    --Print("Entity %s (%s) entered trigger", ent:GetId(), ent:GetClassName())
    if not self.contactEntityIdMap[ent:GetId()] and self:GetIsEntityZappable(ent) then
        local i = #self.contactEntityIdList + 1
        self.contactEntityIdList[i] = ent:GetId()
        self.contactEntityIdMap[ent:GetId()] = i
        self:StartZappingEntity(ent)
    end
end
function ExoShield:OnTriggerExited(entA, entB)
    local ent = (entA == self and entB or entA)
    --Print("Entity %s (%s) exited trigger", ent:GetId(), ent:GetClassName())
    if self.contactEntityIdMap[ent:GetId()] then
        self.contactEntityIdList[self.contactEntityIdMap[ent:GetId()]] = nil
        self.contactEntityIdMap[ent:GetId()] = nil
        self:StopZappingEntity(ent)
    end
end
function ExoShield:OnEntityChange(oldId, newId)
    if self.contactEntityIdMap[oldId] then
        self.contactEntityIdList[self.contactEntityIdMap[oldId]] = nil
        self.contactEntityIdMap[oldId] = nil
        self:StopZappingEntity(ent)
    end
end

-- to fix a bug
function ExoShield:GetExoWeaponSlotName()
    return "left"
end
function ExoShield:GetIsLeftSlot()
    return true
end
function ExoShield:GetIsRightSlot()
    return false
end
function ExoShield:GetExoWeaponSlot()
    return ExoWeaponHolder.kSlotNames.Left
end

Shared.LinkClassToMap("ExoShield", ExoShield.kMapName, networkVars)


