-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\ScanMini.lua
--
--    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
--
-- A Commander ability that gives LOS to marine team for a short time.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/CommanderAbility.lua")
Script.Load("lua/MapBlipMixin.lua")

class 'ScanMini' (CommanderAbility)

ScanMini.kMapName = "scanmini"

ScanMini.kScanMiniEffect = PrecacheAsset("cinematics/marine/observatory/scan.cinematic")
ScanMini.kScanMiniSound = PrecacheAsset("sound/NS2.fev/marine/commander/scan")

ScanMini.kType = CommanderAbility.kType.Repeat
local kScanMiniInterval = 0.2
ScanMini.kScanMiniDistance = kScanMiniRadius

local networkVars = { }

function ScanMini:OnCreate()

    CommanderAbility.OnCreate(self)
    
    if Server then
        StartSoundEffectOnEntity(ScanMini.kScanMiniSound, self)
    end
    
end

function ScanMini:OnInitialized()

    CommanderAbility.OnInitialized(self)
    
    if Server then
    
        DestroyEntitiesWithinRange("ScanMini", self:GetOrigin(), ScanMini.kScanMiniDistance * 0.5, EntityFilterOne(self)) 
    
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
    end
    
end

function ScanMini:OverrideCheckVision()
    return true
end

function ScanMini:GetVisionRadius()
    return ScanMini.kScanMiniDistance
end

function ScanMini:GetRepeatCinematic()
    return ScanMini.kScanMiniEffect
end

function ScanMini:GetType()
    return ScanMini.kType
end

function ScanMini:GetLifeSpan()
    return kScanMiniDuration
end

function ScanMini:GetUpdateTime()
    return kScanMiniInterval
end

if Server then

    function ScanMini:ScanMiniEntity(ent)
        if HasMixin(ent, "LOS") then
            ent:SetIsSighted(true, self)
        end

        if HasMixin(ent, "Detectable") then
            ent:SetDetected(true)
        end

        -- Allow entities to respond
        if ent.OnScan then
            ent:OnScan()
        end
    end

    function ScanMini:Perform()
    
        PROFILE("ScanMini:Perform")
        
        local inkClouds = GetEntitiesForTeamWithinRange("ShadeInk", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), ScanMini.kScanMiniDistance)

        if #inkClouds > 0 then
            
            for _, cloud in ipairs(inkClouds) do
                cloud:SetIsSighted(true)
            end

        else

            -- avoid scanning entities twice
            local scannedIdMap = {}
            local enemies = GetEntitiesWithMixinForTeamWithinXZRange("LOS", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), ScanMini.kScanMiniDistance)
            for _, enemy in ipairs(enemies) do

                local entId = enemy:GetId()
                scannedIdMap[entId] = true

                self:ScanMiniEntity(enemy)

            end

            local detectable = GetEntitiesWithMixinForTeamWithinXZRange("Detectable", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), ScanMini.kScanMiniDistance)
            for _, enemy in ipairs(detectable) do

                local entId = enemy:GetId()
                if not scannedIdMap[entId] then
                    self:ScanMiniEntity(enemy)
                end

            end
            
        end    
        
    end
    
    function ScanMini:OnDestroy()
    
        for _, entity in ipairs( GetEntitiesWithMixinForTeamWithinRange("LOS", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), ScanMini.kScanMiniDistance)) do
            entity.updateLOS = true
        end
        
        CommanderAbility.OnDestroy(self)
    
    end
    
end

Shared.LinkClassToMap("ScanMini", ScanMini.kMapName, networkVars)
