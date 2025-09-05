-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\CloakableMixin.lua
--
-- Handles both cloaking and camouflage. Effects are identical except cloaking can also hide
-- structures (camouflage is only for players).
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

CloakableMixin = CreateMixin(CloakableMixin)
CloakableMixin.type = "Cloakable"

CloakableMixin.kCloakRate = 3.0
CloakableMixin.kCloakRatePerLevel = 0
CloakableMixin.kUncloakRate = 5.0 -- decloak over 0.2s. Camouflage and Shade slow decloaking rate, over 0.33s at level 3, (4-(3-1)*1.0 )
CloakableMixin.kUncloakRatePerLevel = 1.0    -- 20% slower decloaking per level, 40% at lvl 3
CloakableMixin.kTriggerCloakDuration = 0.6
CloakableMixin.kTriggerUncloakDuration = 2.75    -- higher level cloak also shortens re-cloaking delay
CloakableMixin.kCloakShortenDelayPerLevel = 0.25 -- 2.5/2.25/2.0 second delay for lvl 1/2/3
CloakableMixin.kPartialUncloakDuration = 1.5   -- apply shortened delay after revealed by scan or touch
CloakableMixin.kInkUncloakDuration     = 0.8
CloakableMixin.kAttackInkUncloakDuration  = 0.8
CloakableMixin.kShadeCloakRate = 3   -- shade passive cloak is level 3

-- reductions in cloak strength when in combat, recently uncloaked, or detected (lowest value is used)
CloakableMixin.kCombatMod = 0.7 -- was 0.8
CloakableMixin.kRecentUncloakedMod = 0.8 -- give a slight feedback when uncloaked, then uncloak at normal rate
CloakableMixin.kDetectedMod = 0.02  -- was 0.4

CloakableMixin.kSpecialMaxCloak = 0.97  -- Onos, whips, harvester
CloakableMixin.kPlayerMaxCloak = 0.9    -- players (except embryos), and cysts are not totally invisible
CloakableMixin.kStructureMaxCloak = 1.0 -- most structures cloak totally invisible
CloakableMixin.kMaxCloak = 0.95           -- Ink and Shade passive can turn everything almost invisible

local kPlayerMaxCloak = 0.88
local kPlayerHideModelMin = 0
local kPlayerHideModelMax = 0.125
local kInkCloakDuration = 0.99 -- Hallucination cloud refreshes this every 0.5s
local kFullyCloakedThreshold = 0.401 -- anything over 40.1% effectiveness is considered fully cloaked
local kEnemyUncloakDistanceSquared = 1.5 ^ 2

CloakableMixin.kInvisibleFarRange = 
{
    8, 6.5, 5
}

CloakableMixin.kSpecialMaxCloakClass =
set {
    "Onos",
    "Whip",
    "Drifter",
    "Harvester",
    "Hydra",
}
-- most players and these classes have cloak strength capped at kPlayerMaxCloak
CloakableMixin.kPlayerMaxCloakClass =
set {
    "Cyst",
    "Babbler",
    "Web",
}

local precached1 = PrecacheAsset("cinematics/vfx_materials/cloaked.surface_shader")
local precached2 = PrecacheAsset("cinematics/vfx_materials/distort.surface_shader")
local kCloakedMaterial = PrecacheAsset("cinematics/vfx_materials/cloaked.material")
local kDistortMaterial = PrecacheAsset("cinematics/vfx_materials/distort.material")

local Client_GetLocalPlayer

if Client then
    Client_GetLocalPlayer = Client.GetLocalPlayer
end

CloakableMixin.expectedMixins =
{
    EntityChange = "Required to update lastTouchedEntityId."
}

CloakableMixin.optionalCallbacks =
{
    OnCloak = "Called when entity becomes fully cloaked",
    GetSpeedScalar = "Called to figure out how fast we're moving, if we can move",
    GetIsCamouflaged = "Aliens that can evolve camouflage have this",
    GetDistortMaterialName = "Entities can provide an alternative material to use instead of the default distortion material",
}

CloakableMixin.networkVars =
{
    -- set server side to true when cloaked fraction is > kFullyCloakedThreshold
    fullyCloaked = "boolean",
    -- so client knows in which direction to update the cloakFraction
    cloakingDesired = "boolean",
    uncloakSlowly  = "boolean",
    cloakRate = "integer (0 to 3)",
	timeInkCloakEnd = "time (by 0.01)"
}

function CloakableMixin:__initmixin()
    
    PROFILE("CloakableMixin:__initmixin")
    
    if Server then
        self.cloakingDesired = false
        self.fullyCloaked = false
        self.uncloakSlowly = false
    end
    
    self.desiredCloakFraction = 0
    self.timeCloaked = 0
    self.timeUncloaked = 0
    self.cloakRate = 0
	self.timeInkCloakEnd = 0    
    
    -- when entity is created on client consider fully cloaked, so units wont show up for a short moment when going through a phasegate for example
    self.cloakFraction = self.fullyCloaked and 1 or 0
    self.speedScalar = 0
    
end

local function GetDistortMaterialActual(self)
    if self.GetDistortMaterialName then
        return (self:GetDistortMaterialName())
    else
        return kDistortMaterial
    end
end

function CloakableMixin:GetCanCloak()

    local canCloak = true
    
    if self.GetCanCloakOverride then
        canCloak = self:GetCanCloakOverride()
    end
    
    return canCloak 

end

function CloakableMixin:GetIsCloaked()
    return self.fullyCloaked
end

function CloakableMixin:TriggerCloak()

    if self:GetCanCloak() then
        self.timeCloaked = Shared.GetTime() + CloakableMixin.kTriggerCloakDuration
    end
    
end

-- Uncloak slower when hit by Scan. May set custom delay on re-cloaking
function CloakableMixin:TriggerUncloak(slowUncloak, customDelay)
    local timeNow = Shared.GetTime()
    self.uncloakSlowly = slowUncloak or false
    if self:GetIsInInk() then
        self.timeUncloaked = timeNow + CloakableMixin.kInkUncloakDuration
    else
        local decloakDuration = customDelay or slowUncloak and CloakableMixin.kPartialUncloakDuration or (CloakableMixin.kTriggerUncloakDuration - self.cloakRate * CloakableMixin.kCloakShortenDelayPerLevel)
        self.timeUncloaked = math.max(timeNow + decloakDuration, self.timeUncloaked)
    end
end

function CloakableMixin:GetCloakFraction()
    return self.cloakFraction
end

local function UpdateDesiredCloakFraction(self, deltaTime)
    
    local timeNow = Shared.GetTime()
    
    if Server then
    
        local isAlive = HasMixin(self, "Live") and self:GetIsAlive() or true
        local isCamouflaged = self.GetIsCamouflaged and self:GetIsCamouflaged()
        local isShadeCloaked = timeNow < self.timeCloaked

        self.cloakRate = 0
        
        -- for pre-calculation of cloaking and decloaking variables (via cloakRate)
        if isCamouflaged then
                        
            if self:isa("Player") then
                self.cloakRate = self:GetVeilLevel()
            elseif self:isa("Babbler") then
                local babblerParent = self:GetParent()
                if babblerParent and HasMixin(babblerParent, "Cloakable") then
                    self.cloakRate = babblerParent.cloakRate
                end
            else
                self.cloakRate = 1  -- cyst passive cloak is lvl 1 
            end
            
        end
            
        self.cloakingDesired = false        
        -- allow partial camouflage/cloaking when not in combat, cloakRate == 0 means fully decloak
		self.cloakRate = isShadeCloaked and CloakableMixin.kShadeCloakRate or self.cloakRate
        
        -- Ink cloak is the most powerful
        if timeNow < self.timeInkCloakEnd then
        
            local dealtDamageRecently = self.timeLastDamageDealt and (self.timeLastDamageDealt + CloakableMixin.kAttackInkUncloakDuration >= timeNow) or false
            self.cloakRate = 3
            self.cloakingDesired = not dealtDamageRecently
            
        -- Animate towards uncloaked if triggered
        elseif timeNow >= self.timeUncloaked and ( not GetConcedeSequenceActive() ) and isAlive then
            --and (not HasMixin(self, "Detectable") or not self:GetIsDetected())
            
            -- Uncloaking takes precedence over cloaking

            if isCamouflaged then
                
                self.cloakingDesired = self.cloakRate > 0 -- true
                
                --[[if self:isa("Player") then
                    self.cloakRate = self:GetVeilLevel()
                elseif self:isa("Babbler") then
                    local babblerParent = self:GetParent()
                    if babblerParent and HasMixin(babblerParent, "Cloakable") then
                        self.cloakRate = babblerParent.cloakRate
                    end
                else
                    self.cloakRate = 1
                end--]]
                
            end
            
            if isShadeCloaked then
                self.cloakingDesired = true
                self.cloakRate = math.max(self.cloakRate, CloakableMixin.kShadeCloakRate)
            end

        end
    
    end
    
    local newDesiredCloakFraction = self.cloakingDesired and 1 or 0
    local isInInk = self:GetIsInInk()
    
    -- Update cloaked fraction according to our speed and max speed
    if self.GetSpeedScalar then
        -- Always cloak (visually) no matter how fast we go.
        -- allow aliens including celerity gorge to run and remain "fully cloaked" while in Ink
        -- aliens exit full cloaking @ 99.875% of max speed (130% speed in Ink)
        local speedScalar = math.max(0, self:GetSpeedScalar() - 0.25) * (isInInk and 0.6 or 0.8) -- math.min(self:GetSpeedScalar(), 1.36)
                
        newDesiredCloakFraction = math.min(1, newDesiredCloakFraction - speedScalar) 

    end
    
    if newDesiredCloakFraction ~= nil then

        local isInCombat = HasMixin(self, "Combat") and self:GetIsInCombat()
        local isDetected = HasMixin(self, "Detectable") and self:GetIsDetected()

        -- detected + combat should reduce cloaking below fullyCloaked threshold
        -- magic numbers ahead!
        
        -- reduce cloak strength if alien dealt damage recently, or in combat, or is detected

        --local dealtDamageRecently = self.GetTimeLastDamageDealt and (self:GetTimeLastDamageDealt() + 0.499 > timeNow) or false
        local uncloakedRecently = timeNow < self.timeUncloaked
        
        -- allow aliens remain "fully cloaked" while in Ink, even when taking damage
        -- scan and obs break "fully cloaked" status

        local maxCloakModifier = math.min( (isInCombat and CloakableMixin.kCombatMod or 1), (uncloakedRecently and CloakableMixin.kRecentUncloakedMod or 1), (isDetected and CloakableMixin.kDetectedMod or 1) )

        local maxCloakingFraction = CloakableMixin.kSpecialMaxCloakClass[self:GetClassName()] and CloakableMixin.kSpecialMaxCloak
                                    or (self:isa("Player") or CloakableMixin.kPlayerMaxCloakClass[self:GetClassName()]) and not self:isa("Embryo") and CloakableMixin.kPlayerMaxCloak -- embryos cloak fully
                                    or CloakableMixin.kStructureMaxCloak

        -- ink may improve invisibility
        maxCloakingFraction = maxCloakModifier * math.max( maxCloakingFraction, (isShadeCloaked or isInInk) and CloakableMixin.kMaxCloak or 0 )
        local minCloakingFraction = math.min(isInInk and 0.1 or 0, maxCloakingFraction)

        self.desiredCloakFraction = Clamp(newDesiredCloakFraction, minCloakingFraction, maxCloakingFraction)
        
    end
    
end

local function UpdateCloakState(self, deltaTime)
    PROFILE("CloakableMixin:OnUpdate")
    -- Account for trigger cloak, uncloak, camouflage speed
    UpdateDesiredCloakFraction(self, deltaTime)
    
    -- Animate towards desired/internal cloak fraction (so we never "snap")
    local rate = (self.desiredCloakFraction > self.cloakFraction) and CloakableMixin.kCloakRate + self.cloakRate * CloakableMixin.kCloakRatePerLevel or 
                 self.uncloakSlowly and (CloakableMixin.kUncloakRate - math.max(self.cloakRate - 1, 0) * CloakableMixin.kUncloakRatePerLevel) or
                 CloakableMixin.kUncloakRate

    local newCloak = Clamp(Slerp(self.cloakFraction, self.desiredCloakFraction, deltaTime * rate), 0, 1)
           
    if self:isa("Babbler") and self:GetIsClinged() then
        local babblerParent = self:GetParent()
        if babblerParent and HasMixin(babblerParent, "Cloakable") then
            newCloak = babblerParent:GetCloakFraction()
        end
    end
    
    if newCloak ~= self.cloakFraction then
    
        local callOnCloak = (newCloak > kFullyCloakedThreshold) and (self.cloakFraction <= newCloak) and self.OnCloak
        self.cloakFraction = newCloak
        
        if callOnCloak then
            self:OnCloak()
        end        
        
    end

    if Server then
        
        self.fullyCloaked = self:GetCloakFraction() > kFullyCloakedThreshold
        
        if self.lastTouchedEntityId then
        
            local enemyEntity = Shared.GetEntity(self.lastTouchedEntityId)
            if enemyEntity and (self:GetOrigin() - enemyEntity:GetOrigin()):GetLengthSquared() < kEnemyUncloakDistanceSquared then
                -- quick uncloak, but recloak quicker after touching an enemy
                self:TriggerUncloak(false, CloakableMixin.kPartialUncloakDuration)
            else
                self.lastTouchedEntityId = nil
            end
        
        end
        
    end
    
end

function CloakableMixin:OnUpdate(deltaTime)
    UpdateCloakState(self, deltaTime)
end

function CloakableMixin:OnProcessMove(input)
    UpdateCloakState(self, input.time)
end

function CloakableMixin:OnProcessSpectate(deltaTime)
    UpdateCloakState(self, deltaTime)
end    

if Server then

    function CloakableMixin:OnEntityChange(oldId)
    
        if oldId == self.lastTouchedEntityId then
            self.lastTouchedEntityId = nil
        end

    end
    
elseif Client then

    function CloakableMixin:OnUpdateRender()

        PROFILE("CloakableMixin:OnUpdateRender")

        self:_UpdateOpacity()
        
        local model = self:GetRenderModel()
    
        if model then

            local player = Client_GetLocalPlayer()

            self:_UpdatePlayerModelRender(model)        
            
            -- Now process view model
            if self == player then                
                self:_UpdateViewModelRender()                
            end
            
        end
 
    end

    function CloakableMixin:_UpdateOpacity()
    
        local player = Client_GetLocalPlayer()
    
        -- Only draw models when mostly uncloaked
        local albedoVisibility = 1 - Clamp( ( self.cloakFraction - kPlayerHideModelMin ) / ( kPlayerHideModelMax + kPlayerHideModelMin ), 0, 1 )
        
        if player and player:isa("AlienCommander") then
            albedoVisibility = 1
        end
    
        -- cloaked aliens off infestation are not 100% hidden
        local opacity = albedoVisibility
        self:SetOpacity(opacity, "cloak")
               
        if self == player then
        
            local viewModelEnt = self:GetViewModelEntity()
            if viewModelEnt then
                viewModelEnt:SetOpacity(opacity, "cloak")
            end
        
        end

    end
    
    function CloakableMixin:_UpdatePlayerModelRender(model)
    
        local player = Client_GetLocalPlayer()
        local hideFromEnemy = GetAreEnemies(self, player)
        local useMaterial = (self.cloakingDesired or self:GetCloakFraction() ~= 0) and not hideFromEnemy
    
        if not self.cloakedMaterial and useMaterial then
            self.cloakedMaterial = AddMaterial(model, kCloakedMaterial)
        elseif self.cloakedMaterial and not useMaterial then
        
            RemoveMaterial(model, self.cloakedMaterial)
            self.cloakedMaterial = nil
            
        end

        if self.cloakedMaterial then

            -- show it animated for the alien commander. the albedo texture needs to remain visible for outline so we show cloaked in a different way here
            local distortAmount = self.cloakFraction
            if player and player:isa("AlienCommander") then            
                distortAmount = distortAmount * 0.5 + math.sin(Shared.GetTime() * 0.05) * 0.05            
            end
            
            -- Main material parameter that affects our appearance
            self.cloakedMaterial:SetParameter("cloakAmount", self.cloakFraction)          

        end

        --local hideFromFriends = not GetAreFriends(self, player)
        local showDistort = self.cloakFraction ~= 0 and self.cloakFraction ~= 1 and hideFromEnemy

        if showDistort and not self.distortMaterial then

            self.distortMaterial = AddMaterial(model, GetDistortMaterialActual(self) )

        elseif not showDistort and self.distortMaterial then
        
            RemoveMaterial(model, self.distortMaterial)
            self.distortMaterial = nil
        
        end
        
        if self.distortMaterial then        
            self.distortMaterial:SetParameter("distortAmount", self.cloakFraction)
            --self.distortMaterial:SetParameter("speedScalar", self.speedScalar)
            if hideFromEnemy then
                self.distortMaterial:SetParameter("maxRange", self:GetInvisibleRange() )
            end
        end

    end
    
    function CloakableMixin:_UpdateViewModelRender()
    
        -- always show view model distort effect
        local viewModelEnt = self:GetViewModelEntity()
        if viewModelEnt and viewModelEnt:GetRenderModel() then
        
            -- Show view model as enemies see us, so we know how cloaked we are
            if not self.distortViewMaterial then
                self.distortViewMaterial = AddMaterial(viewModelEnt:GetRenderModel(), GetDistortMaterialActual(self))
            end
            
            -- darken when self is sighted by enemy, and darken slightly based on cloak level
            self.distortViewMaterial:SetParameter("distortAmount", self.cloakFraction * (self.visibleClient and 0.4 or 1) * math.max(1, 0.45 + self.cloakRate * 0.15))
            --self.distortViewMaterial:SetParameter("speedScalar", self.speedScalar)
            self.distortViewMaterial:SetParameter("maxRange", 0)  -- special case for view model
        end
        
    end
    
end

-- Pass negative to uncloak
function CloakableMixin:OnScan()

    self:TriggerUncloak(true)
    
end

function CloakableMixin:PrimaryAttack()

    self:TriggerUncloak()
    
end

function CloakableMixin:OnGetIsSelectable(result, byTeamNumber)
    result.selectable = result.selectable and (byTeamNumber == self:GetTeamNumber() or not self:GetIsCloaked())
end

function CloakableMixin:SecondaryAttack()

    local weapon = self:GetActiveWeapon()
    if weapon and weapon:GetHasSecondary(self) then
        
        self:TriggerUncloak()
        
    end
    
end

function CloakableMixin:OnTakeDamage(damage, attacker, doer, point)

    if damage > 0 then

        self:TriggerUncloak()
    
    end
    
end

function CloakableMixin:OnCapsuleTraceHit(entity)

    PROFILE("CloakableMixin:OnCapsuleTraceHit")

    if GetAreEnemies(self, entity) then

        self:TriggerUncloak()
        self.lastTouchedEntityId = entity:GetId()
        
    end

end

-- %%% New CBM Functions %%% --
function CloakableMixin:InkCloak()
    local timeNow = Shared.GetTime()
    self:TriggerCloak()
    self.timeInkCloakEnd = timeNow + kInkCloakDuration
end

function CloakableMixin:GetIsInInk()
    local timeNow = Shared.GetTime()
    return self.timeInkCloakEnd > timeNow
end

function CloakableMixin:GetInvisibleRange()
    return CloakableMixin.kInvisibleFarRange[self.cloakRate] or CloakableMixin.kInvisibleFarRange[1]
end

function CloakableMixin:OverrideCheckVisibilty(viewer)

    if self.fullyCloaked then
        -- Check if this entity is beyond our turn invisible range.
        local maxDist = self:GetInvisibleRange()
        local dist = (self:GetOrigin() - viewer:GetOrigin()):GetLengthSquared()
        if GetAreEnemies(self, viewer) and dist > (maxDist * maxDist) then
            return false
        end
    end
    
    return GetCanSeeEntity(viewer, self)

end

