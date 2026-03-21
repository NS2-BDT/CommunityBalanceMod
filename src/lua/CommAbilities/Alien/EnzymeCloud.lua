-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\CommAbilities\Alien\EnzymeCloud.lua
--
--      Created by: Andreas Urwalek (andi@unknownworlds.com)
--
--      Buffs nearby alien players, increase attack speed by ~25%.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/CommanderAbility.lua")

class 'EnzymeCloud' (CommanderAbility)

EnzymeCloud.kMapName = "enzymecloud"

EnzymeCloud.kSplashEffect = PrecacheAsset("cinematics/alien/cyst/enzymecloud_splash.cinematic")
EnzymeCloud.kRepeatEffect = PrecacheAsset("cinematics/alien/cyst/enzymecloud_large.cinematic")

EnzymeCloud.kType = CommanderAbility.kType.Repeat

EnzymeCloud.kEnzymeCloudDuration = kEnzymeCloudDuration
local kEnzymeCloudUpdateTime = 0.16

EnzymeCloud.kOnPlayerDuration = 2.3
EnzymeCloud.kRadius = kEnzymeCloudAbilityRadius

local kUnitSpeedBoostDuration = 1

local networkVars = { }

function EnzymeCloud:OnInitialized()
    
    if Server then
        -- sound feedback
        self:TriggerEffects("enzyme_cloud")
        DestroyEntitiesWithinRange("EnzymeCloud", self:GetOrigin(), 25, EntityFilterOne(self))
    end
    
    CommanderAbility.OnInitialized(self)

end

function EnzymeCloud:GetStartCinematic()
    return EnzymeCloud.kSplashEffect
end   

-- don't create the effect until the size has been specified and sent
function EnzymeCloud:GetRepeatCinematic()
    return EnzymeCloud.kRepeatEffect
end

function EnzymeCloud:GetType()
    return EnzymeCloud.kType
end
    
function EnzymeCloud:GetLifeSpan()
    return EnzymeCloud.kEnzymeCloudDuration
end

function EnzymeCloud:GetUpdateTime()
    return kEnzymeCloudUpdateTime
end

if Server then

    function EnzymeCloud:Perform()
        
        -- search for aliens in range and buff their speed by 25%
        for _, alien in ipairs(GetEntitiesForTeamWithinRange("Alien", self:GetTeamNumber(), self:GetOrigin(), EnzymeCloud.kRadius)) do
            alien:TriggerEnzyme(EnzymeCloud.kOnPlayerDuration)
        end
        
        --[[ Disabled faster speed
        for _, unit in ipairs(GetEntitiesWithMixinForTeamWithinRange("Storm", self:GetTeamNumber(), self:GetOrigin(), EnzymeCloud.kRadius)) do
            unit:SetSpeedBoostDuration(kUnitSpeedBoostDuration)
        end
        --]]

    end

end

Shared.LinkClassToMap("EnzymeCloud", EnzymeCloud.kMapName, networkVars)