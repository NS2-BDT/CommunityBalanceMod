-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\CommAbilities\Alien\HallucinationCloud.lua
--
--      Created by: Andreas Urwalek (andi@unknownworlds.com)
--
--      Creates a hallucination of every affected alien.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/CommanderAbility.lua")

class 'HallucinationCloud' (CommanderAbility)

HallucinationCloud.kMapName = "hallucinationcloud"

HallucinationCloud.kSplashEffect = PrecacheAsset("cinematics/alien/hallucinationcloud.cinematic")
HallucinationCloud.kType = CommanderAbility.kType.Repeat
HallucinationCloud.kLifeSpan = 3.1  -- was 4.1
HallucinationCloud.kThinkTime = 0.5

HallucinationCloud.kRadius = 10

local kMaxAllowedHallucinations = 1

local gTechIdToHallucinateTechId
function GetHallucinationTechId(techId)

    if not gTechIdToHallucinateTechId then
    
        gTechIdToHallucinateTechId = {}
        gTechIdToHallucinateTechId[kTechId.Drifter] = kTechId.HallucinateDrifter
        gTechIdToHallucinateTechId[kTechId.Skulk] = kTechId.HallucinateSkulk
        gTechIdToHallucinateTechId[kTechId.Gorge] = kTechId.HallucinateGorge
        gTechIdToHallucinateTechId[kTechId.Lerk] = kTechId.HallucinateLerk
        gTechIdToHallucinateTechId[kTechId.Fade] = kTechId.HallucinateFade
        gTechIdToHallucinateTechId[kTechId.Onos] = kTechId.HallucinateOnos
        
        gTechIdToHallucinateTechId[kTechId.Hive] = kTechId.HallucinateHive
        gTechIdToHallucinateTechId[kTechId.Whip] = kTechId.HallucinateWhip
        gTechIdToHallucinateTechId[kTechId.Shade] = kTechId.HallucinateShade
        gTechIdToHallucinateTechId[kTechId.Crag] = kTechId.HallucinateCrag
        gTechIdToHallucinateTechId[kTechId.Shift] = kTechId.HallucinateShift
        gTechIdToHallucinateTechId[kTechId.Harvester] = kTechId.HallucinateHarvester
        gTechIdToHallucinateTechId[kTechId.Hydra] = kTechId.HallucinateHydra
    
    end
    
    return gTechIdToHallucinateTechId[techId]

end

local networkVars = { }

function HallucinationCloud:OnInitialized()
    
    if Server then
        -- sound feedback
        self:TriggerEffects("enzyme_cloud")    
    end
    
    CommanderAbility.OnInitialized(self)

end

function HallucinationCloud:GetStartCinematic()
    return HallucinationCloud.kSplashEffect
end

function HallucinationCloud:GetRepeatCinematic()
    return HallucinationCloud.kSplashEffect
end

function HallucinationCloud:GetType()
    return HallucinationCloud.kType
end

function HallucinationCloud:GetLifeSpan()
    return HallucinationCloud.kLifeSpan
end

function HallucinationCloud:GetUpdateTime()
    return HallucinationCloud.kThinkTime 
end

function HallucinationCloud:RegisterHallucination(entity)
    
    if not self.hallucinations then
        self.hallucinations = {}
    end
    
    table.insert(self.hallucinations, entity:GetId())
    
end

function HallucinationCloud:GetRegisteredHallucinations()
    return self.hallucinations or {}
end

local function AllowedToHallucinate(entity)

    local allowed = true
    if entity.timeLastHallucinated and entity.timeLastHallucinated + kHallucinationCloudCooldown > Shared.GetTime() then
        allowed = false
    else
        entity.timeLastHallucinated = Shared.GetTime()
    end    
    
    return allowed

end

if Server then

    -- sort by techId, so the higher life forms are prefered
    local function SortByTechIdAndInRange(alienOne, alienTwo)
        local inRangeOne = alienOne.__inHallucinationCloudRange
        if inRangeOne == alienTwo.__inHallucinationCloudRange then
            if inRangeOne then
                return alienOne:GetTechId() > alienTwo:GetTechId()
            else
                return alienOne:GetTechId() < alienTwo:GetTechId()
            end
        end

        return inRangeOne
    end

    local kHallucinationClassNameMap = {
        [Skulk.kMapName] = SkulkHallucination.kMapName,
        [Gorge.kMapName] = GorgeHallucination.kMapName,
        [Lerk.kMapName] = LerkHallucination.kMapName,
        [Fade.kMapName] = FadeHallucination.kMapName,
        [Onos.kMapName] = OnosHallucination.kMapName
    }
    
    function HallucinationCloud:Perform()
        
        local teamNumber = self:GetTeamNumber()
        local origin = self:GetOrigin()
        -- only cloak players, drifters and eggs
        local targets = GetEntitiesForTeamWithinXZRange("Player", teamNumber, origin, HallucinationCloud.kRadius)
        table.copy(GetEntitiesForTeamWithinXZRange("Drifter", teamNumber, origin, HallucinationCloud.kRadius), targets, true)
        table.copy(GetEntitiesForTeamWithinXZRange("Egg", teamNumber, origin, HallucinationCloud.kRadius), targets, true)
        
        for _, cloakable in ipairs( targets ) do
            if HasMixin(cloakable, "Detectable")then
                cloakable:SetDetected(false)
            end
            if HasMixin(cloakable, "Cloakable")then
                cloakable:InkCloak()  -- apply special cloaking status
            end
		end
    end
end

Shared.LinkClassToMap("HallucinationCloud", HallucinationCloud.kMapName, networkVars)