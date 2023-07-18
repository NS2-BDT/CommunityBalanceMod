CloakableMixin.kCloakRate = 4.0   -- faster cloaking
CloakableMixin.kUncloakRate = 3.0 -- decloak over 0.4s (inverse of 3.0-0.5) , camouflage upgrade slows decloaking rate
CloakableMixin.kUncloakRatePerLevel = 0.5    -- 16.66% slower decloaking per level, 50% at lvl 3
CloakableMixin.kTriggerCloakDuration = 0.6
CloakableMixin.kTriggerUncloakDuration = 2.499  -- higher level cloak also shortens re-cloaking delay
CloakableMixin.kPartialUncloakDuration = 1.499  -- apply shortened delay after revealed by scan, non-aggressive action, or touch
CloakableMixin.kInkUncloakDuration     = 0.599

CloakableMixin.kShadeCloakRate = 2

local kInkCloakDuration = 0.6 -- was 1.0 -- Hallucination cloud refreshes this every 0.5s

local kFullyCloakedThreshold = 0.401 -- anything over 40.1% effectiveness is considered fully cloaked

CloakableMixin.kPlayerMaxCloak = 0.88   -- players, whips and cysts are not totally invisible
CloakableMixin.kStructureMaxCloak = 1.0 
--CloakableMixin.kInkMaxCloak = 1.0        -- Ink can turn everything completely invisible

local kPlayerHideModelMin = 0
local kPlayerHideModelMax = 0.125

local kEnemyUncloakDistanceSquared = 1.5 ^ 2

local kDistortMaterial = PrecacheAsset("cinematics/vfx_materials/distort.material")

local Client_GetLocalPlayer

if Client then
    Client_GetLocalPlayer = Client.GetLocalPlayer
end
    
CloakableMixin.networkVars =
{
    -- set server side to true when cloaked fraction is > kFullyCloakedThreshold
    fullyCloaked = "boolean",
    -- so client knows in which direction to update the cloakFraction
    cloakingDesired = "boolean",
    cloakRate = "integer (0 to 3)",
	timeInkCloakEnd = "time (by 0.01)"
}

local oldinit = CloakableMixin.__initmixin
function CloakableMixin:__initmixin()
    oldinit(self)
    self.cloakRate = 0
    
	self.timeInkCloakEnd = 0

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

function CloakableMixin:InkCloak()
    local timeNow = Shared.GetTime()
    self:TriggerCloak()
    self.timeInkCloakEnd = timeNow + kInkCloakDuration
end

function CloakableMixin:GetIsInInk()
    local timeNow = Shared.GetTime()
    return self.timeInkCloakEnd > timeNow
end

-- reduced re-cloaking delay when not actively engaging in combat
-- (bool, time-seconds)
function CloakableMixin:TriggerUncloak(reducedDelay, customDelay)

    local timeNow = Shared.GetTime()
    if self:GetIsInInk() then
        self.timeUncloaked = timeNow + CloakableMixin.kInkUncloakDuration
    else
        local decloakDuration = (reducedDelay and (customDelay or CloakableMixin.kPartialUncloakDuration) or CloakableMixin.kTriggerUncloakDuration) * 2 / (1 + self.cloakRate)
        self.timeUncloaked = math.max(timeNow + decloakDuration, self.timeUncloaked)
    end
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
        
            local dealtDamageRecently = self.GetTimeLastDamageDealt and (self:GetTimeLastDamageDealt() + 0.499 > timeNow) or false
            self.cloakRate = 3
            self.cloakingDesired = not dealtDamageRecently
            
        -- Animate towards uncloaked if triggered
        elseif timeNow > self.timeUncloaked and ( not GetConcedeSequenceActive() ) and isAlive then
            --and (not HasMixin(self, "Detectable") or not self:GetIsDetected())
            
            -- Uncloaking takes precedence over cloaking

            if isCamouflaged then
                
                self.cloakingDesired = true
                
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
                self.cloakRate = math.max(self.cloakRate, CloakableMixin.kShadeCloakRate) -- shade passive cloak is now level 2
            end

        end
    
    end
    
    local newDesiredCloakFraction = self.cloakingDesired and 1 or 0
    local isInInk = self:GetIsInInk()
    
    -- Update cloaked fraction according to our speed and max speed
    if self.GetSpeedScalar then
        -- Always cloak (visually) no matter how fast we go.
        -- allow aliens including celerity gorge to run and remain "fully cloaked" while in Ink
        -- TODO: Fix that GetSpeedScalar returns incorrect values for aliens with celerity
        local speedScalar = math.min(self:GetSpeedScalar(), 1.35) * (isInInk and 0.444 or 0.6)       
                
        newDesiredCloakFraction = newDesiredCloakFraction - speedScalar  -- aliens exit full cloaking @ 99.833% of max speed

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
        local maxCloakModifier = (isInCombat and 0.7 or 1) * (uncloakedRecently and 0.6 or 1) * (isDetected and 0.4 or 1)
        
        local maxCloakingFraction = maxCloakModifier * ( (self:isa("Player") or self:isa("Drifter") or self:isa("Whip") or self:isa("Cyst")) and CloakableMixin.kPlayerMaxCloak or CloakableMixin.kStructureMaxCloak )

        local minCloakingFraction = math.min(isInInk and 0.1 or 0, maxCloakingFraction)

        self.desiredCloakFraction = Clamp(newDesiredCloakFraction, minCloakingFraction, maxCloakingFraction)
        
    end
    
end

local function UpdateCloakState(self, deltaTime)
    PROFILE("CloakableMixin:OnUpdate")
    -- Account for trigger cloak, uncloak, camouflage speed
    UpdateDesiredCloakFraction(self, deltaTime)
    
    -- Animate towards desired/internal cloak fraction (so we never "snap")
    --local rate = (self.desiredCloakFraction > self.cloakFraction) and CloakableMixin.kCloakRate * (self.cloakRate / 3) or (CloakableMixin.kUncloakRate - self.cloakRate * CloakableMixin.kUncloakRatePerLevel 
    local rate = (self.desiredCloakFraction > self.cloakFraction) and CloakableMixin.kCloakRate or (CloakableMixin.kUncloakRate - self.cloakRate * CloakableMixin.kUncloakRatePerLevel )

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
                self:TriggerUncloak(true)
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

if Client then

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

    function CloakableMixin:_UpdateViewModelRender()
    
        -- always show view model distort effect
        local viewModelEnt = self:GetViewModelEntity()
        if viewModelEnt and viewModelEnt:GetRenderModel() then
        
            -- Show view model as enemies see us, so we know how cloaked we are
            if not self.distortViewMaterial then
                self.distortViewMaterial = AddMaterial(viewModelEnt:GetRenderModel(), GetDistortMaterialActual(self))
            end
            
            self.distortViewMaterial:SetParameter("distortAmount", self.cloakFraction)
            self.distortViewMaterial:SetParameter("speedScalar", self.speedScalar)
        end
        
    end
    
end

function CloakableMixin:OnScan()

    self:TriggerUncloak(true)
    
end

function CloakableMixin:OnTakeDamage(damage, attacker, doer, point)

    if damage > 0 then

        self:TriggerUncloak(true)
    
    end
    
end