-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Clog.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/OwnerMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/ClogFallMixin.lua")
Script.Load("lua/DigestMixin.lua")
Script.Load("lua/TechMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/TargetMixin.lua")
Script.Load("lua/UsableMixin.lua")
Script.Load("lua/Mixins/SimplePhysicsMixin.lua")
Script.Load("lua/BiomassHealthMixin.lua")

class 'Clog' (Entity)

Clog.kMapName = "clog"

Clog.kModelName = PrecacheAsset("models/alien/gorge/clog.model")
local kModelNameShadow = PrecacheAsset("models/alien/gorge/clog_shadow.model")
local kModelNameAbyss = PrecacheAsset("models/alien/gorge/clog_abyss.model")
local kModelNameToxin = PrecacheAsset("models/alien/gorge/clog_toxin.model")
local kModelNameKodiak = PrecacheAsset("models/alien/gorge/clog_kodiak.model")
local kModelNameReaper = PrecacheAsset("models/alien/gorge/clog_reaper.model")
local kModelNameNocturne = PrecacheAsset("models/alien/gorge/clog_nocturne.model")
local kModelNameAuric = PrecacheAsset("models/alien/gorge/clog_auric.model")

local kClogModelVariants =
{ 
    [kClogVariants.normal] = Clog.kModelName, 
    [kClogVariants.Shadow] = kModelNameShadow,
    [kClogVariants.Reaper] = kModelNameReaper,
    [kClogVariants.Nocturne] = kModelNameNocturne,
    [kClogVariants.Toxin] = kModelNameToxin,
    [kClogVariants.Abyss] = kModelNameAbyss,
    [kClogVariants.Kodiak] = kModelNameKodiak,
    [kClogVariants.Auric] = kModelNameAuric,
}

local networkVars =
{
    variant = "enum kClogVariants",
}

Clog.kRadius = 0.67

AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)

function Clog:OnCreate()

    Entity.OnCreate(self)
    
    self.boneCoords = CoordsArray()
    
    InitMixin(self, EffectsMixin)
    InitMixin(self, TechMixin) 
    InitMixin(self, TeamMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FireMixin)
    InitMixin(self, TargetMixin)
    InitMixin(self, DigestMixin)
    InitMixin(self, UsableMixin)
    InitMixin(self, ClogFallMixin)
    InitMixin(self, BiomassHealthMixin)
    
    if Server then
    
        InitMixin(self, InvalidOriginMixin)
        InitMixin(self, OwnerMixin)
        InitMixin(self, EntityChangeMixin)       

    end
    
    self:SetRelevancyDistance(kMaxRelevancyDistance)
    self:SetUpdates(false)
    
    self.variant = kDefaultClogVariant
    
end

function Clog:OnInitialized()

    InitMixin(self, SimplePhysicsMixin)
    self:SetUsesSimplePhysics(true) -- so predict will get physics updates
    self:UpdatePhysicsBoundingBox() -- manually update bound box b/c this is a simple physics object -- not from a mesh-model.
    
    if Server then
    
        local mask = bit.bor(kRelevantToTeam1Unit, kRelevantToTeam2Unit, kRelevantToReadyRoom)
        
        if self:GetTeamNumber() == 1 then
            mask = bit.bor(mask, kRelevantToTeam1Commander)
        elseif self:GetTeamNumber() == 2 then
            mask = bit.bor(mask, kRelevantToTeam2Commander)
        end
        
        self:SetExcludeRelevancyMask(mask)
        
    end
    
end

function Clog:GetSimplePhysicsBodyType()
    return kSimplePhysicsBodyType.Sphere
end

function Clog:GetSimplePhysicsBodySize()
    return Clog.kRadius
end

local function ClearRenderModel(self)

    if self._renderModel ~= nil then
        Client.DestroyRenderModel(self._renderModel)
    end
    self._renderModel = nil
    
end

function Clog:OnDestroy()
    ClearRenderModel(self)
    
    self:SetSimplePhysicsEnabled(false) -- triggers the destruction of the physics object
end

function Clog:SetVariant(clogVariant)
    self.variant = clogVariant
end

function Clog:SpaceClearForEntity(location)
    return true
end

function Clog:GetHealthPerBioMass()
    return kClogHealthPerBioMass
end

function Clog:GetIsFlameAble()
    return true
end

function Clog:GetIsFlameableMultiplier()
    return 7
end

function Clog:GetReceivesStructuralDamage()
    return true
end

function Clog:GetShowCrossHairText(toPlayer)
    return false
end

function Clog:GetCanBeHealedOverride()
    return false
end

function Clog:SetCoords(coords)
    
    if self._renderModel then    
        self._renderModel:SetCoords(coords)        
    end
    
    Entity.SetCoords(self, coords)
    
    if self.OnUpdatePhysics then
        self:OnUpdatePhysics()
    end
    
end

function Clog:SetOrigin(origin)
    
    local newCoords = self:GetCoords()
    newCoords.origin = origin

    if self._renderModel then    
        self._renderModel:SetCoords(newCoords)        
    end
    
    Entity.SetOrigin(self, origin)
    
    if self.OnUpdatePhysics then
        self:OnUpdatePhysics()
    end
    
end

function Clog:GetModelOrigin()
    return self:GetOrigin()    
end

if Server then

    function Clog:GetDestroyOnKill()
        return true
    end

    function Clog:OnKill()
    
        self:TriggerEffects("death")
        
    end
    
    function Clog:GetSendDeathMessageOverride()
        return false
    end
    
    local kClogSpawnCinematicVariants = 
    {
        [kClogVariants.normal] = "clog_spawn",
        [kClogVariants.Shadow] = "clog_spawn_shadow",
        [kClogVariants.Reaper] = "clog_spawn_reaper",
        [kClogVariants.Nocturne] = "clog_spawn_nocturne",
        [kClogVariants.Kodiak] = "clog_spawn_kodiak",
        [kClogVariants.Abyss] = "clog_spawn_abyss",
        [kClogVariants.Toxin] = "clog_spawn_toxin",
        [kClogVariants.Auric] = "clog_spawn_auric",
    }

    function Clog:OnCreatedByGorge()
        local spawnCin = kClogSpawnCinematicVariants[self.variant]
        self:TriggerEffects( spawnCin, {effecthostcoords = self:GetCoords()})
        self:TriggerEffects("clog_slime")
    end

elseif Client then

    function Clog:GetShowHealthFor()
        return false
    end
    
    function Clog:OnUpdateRender()
    
        PROFILE("Clog:OnUpdateRender")
        
        if self.variant ~= self.renderVariant then
            ClearRenderModel(self)
        end

        if self._renderModel then
            self._renderModel:SetCoords(self:GetCoords())
        else
            self._renderModel = Client.CreateRenderModel(RenderScene.Zone_Default)
            self._renderModel:SetModel(Shared.GetModelIndex(kClogModelVariants[self.variant]))
            self._renderModel:SetCoords(self:GetCoords())
            self.renderVariant = self.variant
        end

    end
    
end

function Clog:GetEffectParams(tableParams)

    -- Only override if not specified
    if not tableParams[kEffectFilterClassName] and self.GetClassName then
        tableParams[kEffectFilterClassName] = self:GetClassName()
    end
    
    if not tableParams[kEffectHostCoords] and self.GetCoords then
        tableParams[kEffectHostCoords] = Coords.GetTranslation( self:GetOrigin() )
    end
    
end

function Clog:OnCapsuleTraceHit(entity)
end

-- simple solution for now to avoid griefing
function Clog:GetCanDigest(player)
    return player:GetIsAlive() and player:GetTeamNumber() == self:GetTeamNumber()
end

function Clog:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = player:GetTeamNumber() == self:GetTeamNumber()
end

function Clog:GetUsablePoints()
    return { self:GetOrigin() }
end

function Clog:GetIsWallWalkingAllowed()
    return true
end

-- %%% New CBM Functions %%% --
function Clog:GetDigestDuration()
    return 1
end

Shared.LinkClassToMap("Clog", Clog.kMapName, networkVars, true)
