--CloakableMixin.kCloakRate = 6.0   -- faster cloaking helps newborn babblers not betray their gorge
--CloakableMixin.kUncloakRate = 2.5 -- decloak over 0.4s, camouflage upgrade slows decloaking rate
--CloakableMixin.kUncloakRatePerLevel = 0.41666    -- 16.6664% slower decloaking per level
--CloakableMixin.kTriggerUncloakDuration = 2.49
--CloakableMixin.kMinimumUncloakDuration = 1.49

local kInkCloakDuration = 1.0

--local kFullyCloakedThreshold = 0.406 -- anything over 40.6% effectiveness is considered fully cloaked

--CloakableMixin.kPlayerMaxCloak = 0.88   -- whips are not totally invisible
--CloakableMixin.kStructureMaxCloak = 0.98 
CloakableMixin.kInkMaxCloak = 1.0        -- Ink can turn everything completely invisible

--local kPlayerHideModelMin = 0
--local kPlayerHideModelMax = 0.125

--local kEnemyUncloakDistanceSquared = 1.5 ^ 2

local kDistortMaterial = PrecacheAsset("cinematics/vfx_materials/distort.material")


CloakableMixin.networkVars =
{
    -- set server side to true when cloaked fraction is 1
    fullyCloaked = "boolean",
    -- so client knows in which direction to update the cloakFraction
    cloakingDesired = "boolean",
    --cloakRate = "integer (0 to 3)",
	timeInkCloakEnd = "time (by 0.01)"
}




local oldinit = CloakableMixin.__initmixin
function CloakableMixin:__initmixin()
    oldinit(self)
    --self.cloakRate = 0
    
	self.timeInkCloakEnd = 0

end

local function GetDistortMaterialActual(self)
    if self.GetDistortMaterialName then
        return (self:GetDistortMaterialName())
    else
        return kDistortMaterial
    end
end

function CloakableMixin:InkCloak()
    self:TriggerCloak()
    self.timeInkCloakEnd = Shared.GetTime() + kInkCloakDuration
end

function CloakableMixin:GetIsInInk()
    return self.timeInkCloakEnd > Shared.GetTime()
end

--[[
-- reduced re-cloaking delay when not actively engaging in combat
function CloakableMixin:TriggerUncloak(reducedDelay)
    local now = Shared.GetTime()
    local decloakDuration = (reducedDelay and CloakableMixin.kMinimumUncloakDuration or CloakableMixin.kTriggerUncloakDuration) * 2 / (1 + self.cloakRate)
    self.timeUncloaked = math.max(now + decloakDuration, self.timeUncloaked)
end]]


--[[
local function UpdateDesiredCloakFraction(self, deltaTime)

    if Server then
    
        local isInInk = false
        local timeNow = Shared.GetTime()
        local isAlive = HasMixin(self, "Live") and self:GetIsAlive() or true
        self.cloakingDesired = false
		
        if timeNow < self.timeInkCloakEnd then
            self.cloakRate = 3
            self.cloakingDesired = true
            isInInk = true
            
        -- Animate towards uncloaked if triggered
        elseif timeNow > self.timeUncloaked and ( not GetConcedeSequenceActive() ) and isAlive then
            --and (not HasMixin(self, "Detectable") or not self:GetIsDetected())
            
            -- Uncloaking takes precedence over cloaking

            if self.GetIsCamouflaged and self:GetIsCamouflaged() then
                
                self.cloakingDesired = true
                
                if self:isa("Player") then
                    self.cloakRate = self:GetVeilLevel()
                elseif self:isa("Babbler") then
                    local babblerParent = self:GetParent()
                    if babblerParent and HasMixin(babblerParent, "Cloakable") then
                        self.cloakRate = babblerParent.cloakRate
                    end
                else
                    self.cloakRate = 3
                end
                
            end
            
            if timeNow < self.timeCloaked then
                self.cloakingDesired = true
                self.cloakRate = math.max(self.cloakRate, 1)
            end

        end
    
    end
    
    local newDesiredCloakFraction = self.cloakingDesired and 1 or 0

    -- Update cloaked fraction according to our speed and max speed
    if self.GetSpeedScalar then
        -- Always cloak (visually) no matter how fast we go.
        -- TODO: Fix that GetSpeedScalar returns incorrect values for aliens with celerity
        local speedScalar = math.min(self:GetSpeedScalar(), 1.35)
        newDesiredCloakFraction = newDesiredCloakFraction - 0.6 * speedScalar  -- aliens exit full cloaking @ 99% of max speed

    end
    
    if newDesiredCloakFraction ~= nil then
		local maxCloakingFraction = ( HasMixin(self, "Detectable") and self:GetIsDetected() or HasMixin(self, "Combat") and self:GetIsInCombat() ) and kFullyCloakedThreshold or (self:isa("Player") or self:isa("Drifter") or self:isa("Whip")) and CloakableMixin.kPlayerMaxCloak or CloakableMixin.kStructureMaxCloak
		maxCloakingFraction = math.min(maxCloakingFraction + (isInInk and 0.2 or 0), 1)
        self.desiredCloakFraction = Clamp(newDesiredCloakFraction, 0, maxCloakingFraction)
    end
    
end
]]


--[[
local function UpdateCloakState(self, deltaTime)
    PROFILE("CloakableMixin:OnUpdate")
    -- Account for trigger cloak, uncloak, camouflage speed
    UpdateDesiredCloakFraction(self, deltaTime)
    
    -- Animate towards desired/internal cloak fraction (so we never "snap")
    local rate = (self.desiredCloakFraction > self.cloakFraction) and CloakableMixin.kCloakRate * (self.cloakRate / 3) or (CloakableMixin.kUncloakRate - self.cloakRate * CloakableMixin.kUncloakRatePerLevel )

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
                self:TriggerUncloak()
            else
                self.lastTouchedEntityId = nil
            end
        
        end
        
    end
    
end

--]]

--[[
function CloakableMixin:OnUpdate(deltaTime)
    UpdateCloakState(self, deltaTime)
end

function CloakableMixin:OnProcessMove(input)
    UpdateCloakState(self, input.time)
end

function CloakableMixin:OnProcessSpectate(deltaTime)
    UpdateCloakState(self, deltaTime)
end

local Client_GetLocalPlayer

if Client then
    Client_GetLocalPlayer = Client.GetLocalPlayer
end
]]

if Client then
    --[[
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
        ]]
    function CloakableMixin:_UpdateViewModelRender()
    
        -- always show view model distort effect
        local viewModelEnt = self:GetViewModelEntity()
        if viewModelEnt and viewModelEnt:GetRenderModel() then
        
            -- Show view model as enemies see us, so we know how cloaked we are
            if not self.distortViewMaterial then
                self.distortViewMaterial = AddMaterial(viewModelEnt:GetRenderModel(), GetDistortMaterialActual(self))
            end
            
            -- When in combat, indicate that we may be visible to the enemy

            --[[
            local cloakedFraction = (HasMixin(self, "Combat") and self:GetIsInCombat() and 0.2 or CloakableMixin.kPlayerMaxCloak) * self.cloakFraction
            self.distortViewMaterial:SetParameter("distortAmount", cloakedFraction) 
            ]]

            self.distortViewMaterial:SetParameter("distortAmount", self.cloakedFraction)
            self.distortViewMaterial:SetParameter("speedScalar", self.speedScalar)
        end
        
    end
    
end


--[[
function CloakableMixin:OnScan()

    self:TriggerUncloak(true)
    
end

function CloakableMixin:OnTakeDamage(damage, attacker, doer, point)

    if damage > 0 then

        self:TriggerUncloak(true)
    
    end
    
end
]]