-- ========= Community Balance Mod ===============================
--
--  "lua\CloakableMixin.lua"
--
--    Created by:   Twiliteblue, Drey (@drey3982)
--
-- ===============================================================

CloakableMixin.kCloakRate = 3.0
CloakableMixin.kCloakRatePerLevel = 0
CloakableMixin.kUncloakRate = 3.0 -- decloak over 0.4s (inverse of 2.5 = 3-0.5) , camouflage upgrade slows decloaking rate
CloakableMixin.kUncloakRatePerLevel = 0.5    -- 20% slower decloaking per level, 40% at lvl 3
CloakableMixin.kTriggerCloakDuration = 0.6
CloakableMixin.kTriggerUncloakDuration = 3.0    -- higher level cloak also shortens re-cloaking delay
CloakableMixin.kCloakShortenDelayPerLevel = 0.5 -- 2.5/2.0/1.5 second delay for lvl 1/2/3
CloakableMixin.kPartialUncloakDuration = 1.0   -- apply shortened delay after revealed by scan or touch
CloakableMixin.kInkUncloakDuration     = 0.8
CloakableMixin.kAttackInkUncloakDuration  = 0.8
CloakableMixin.kShadeCloakRate = 3   -- shade passive cloak is level 3

-- reductions in cloak strength when in combat, recently uncloaked, or detected (lowest value is used)
CloakableMixin.kCombatMod = 0.8
CloakableMixin.kRecentUncloakedMod = 0.9 -- give a slight feedback when uncloaked, then uncloak at normal rate
CloakableMixin.kDetectedMod = 0.02  -- was 0.4

local kInkCloakDuration = 0.99 -- Hallucination cloud refreshes this every 0.5s

local kFullyCloakedThreshold = 0.401 -- anything over 40.1% effectiveness is considered fully cloaked

CloakableMixin.kSpecialMaxCloak = 0.95  -- Onos, whips, harvester
CloakableMixin.kPlayerMaxCloak = 0.9    -- players (except embryos), and cysts are not totally invisible
CloakableMixin.kStructureMaxCloak = 1.0 -- most structures cloak totally invisible
CloakableMixin.kMaxCloak = 0.95           -- Ink and Shade passive can turn everything almost invisible
-- hide from minimap from further than 8/ 5.66/ 4 distance (10/ 7.66/ 6 m for distortion to become visibile)
-- but become up to twice as visible at distances closer than this
CloakableMixin.kInvisibleFarRange = 
{
   8,  6,  4
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

local kPlayerHideModelMin = 0
local kPlayerHideModelMax = 0.125

local kEnemyUncloakDistanceSquared = 1.5 ^ 2

local kCloakedMaterial = PrecacheAsset("cinematics/vfx_materials/cloaked.material")
local kDistortMaterial = PrecacheAsset("cinematics/vfx_materials/distort.material")
--local kDistortMaterial2 = PrecacheAsset("cinematics/vfx_materials/distort_alt.material")

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
	timeInkCloakEnd = "time (by 0.01)",

    timeHazeCloakEnd = "time (by 0.01)"
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
        local decloakDuration = reducedDelay and (customDelay or CloakableMixin.kPartialUncloakDuration) or (CloakableMixin.kTriggerUncloakDuration - self.cloakRate * CloakableMixin.kCloakShortenDelayPerLevel)
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
        -- aliens exit full cloaking @ 99.833% of max speed (136.136% speed in Ink)
        local speedScalar = self:GetSpeedScalar() * (isInInk and 0.44 or 0.6) -- math.min(self:GetSpeedScalar(), 1.36)
                
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
                 (CloakableMixin.kUncloakRate - self.cloakRate * CloakableMixin.kUncloakRatePerLevel)

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

function CloakableMixin:GetInvisibleRange()
    return CloakableMixin.kInvisibleFarRange[self.cloakRate] or CloakableMixin.kInvisibleFarRange[1]
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

        local showDistort = self.cloakFraction ~= 0 and self.cloakFraction ~= 1

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
            

            local clientClockRate = self.cloakRate
            
            local marines = {}
            local player = Client.GetLocalPlayer()
            

            if player and clientClockRate > 0 then


                local ClientOrigin = self:GetOrigin()
                
                local range = CloakableMixin.kInvisibleFarRange[1] + 2
                for _, enemyPlayer in ipairs( GetEntitiesForTeamWithinRange("Player", GetEnemyTeamNumber(player:GetTeamNumber()), ClientOrigin, range) ) do

                    if not enemyPlayer:isa("Spectator") and not enemyPlayer:isa("Commander") then
                        table.insert(marines, enemyPlayer)
                    end
                end

                local function getClientCloakRate(marines, ClientOrigin)
                    for k, v  in ipairs( marines) do 
                        v[distanceToClient] = (v:GetOrigin() - ClientOrigin):GetLengthSquared()
                        if v[distanceToClient] < CloakableMixin.kInvisibleFarRange[3] + 2 then 
                            return 1
                        end
                    end
                    local function compareDistance(a, b)
                        local distance1 = a[distanceToClient]
                        local distance2 = b[distanceToClient]
                        return distance1 < distance2
                    end
                    table.sort(marines, compareDistance)

                    if v[distanceToClient] < CloakableMixin.kInvisibleFarRange[2] + 2 then
                        return 2
                    end



                end

                

                -- loop over all marines, break loop if a marine is closer than 6 meter. 
                -- if not breaked, take closest marine and set clientclockrate to its distance

                Shared.SortEntitiesByDistance(ClientOrigin, marines)


                if #marines > 0 and clientClockRate > 1 then 
                    clientClockRate = 1
                    Log("set to 1")
                end
            end




            self.distortViewMaterial:SetParameter("distortAmount", self.cloakFraction * math.max(1, clientClockRate) / 3 ) -- indicate reduced cloaking distance at lower levels
            --self.distortViewMaterial:SetParameter("speedScalar", self.speedScalar)
            self.distortViewMaterial:SetParameter("maxRange", 0)  -- special case for view model
        end
        
    end

end









function CloakableMixin:OnScan()

    self:TriggerUncloak(true)
    
end

function CloakableMixin:OnTakeDamage(damage, attacker, doer, point)

    if damage > 0 then

        self:TriggerUncloak()
    
    end
    
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