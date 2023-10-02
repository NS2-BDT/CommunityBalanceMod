-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/MapBlip.lua
--
-- MapBlips are displayed on player minimaps based on relevancy.
--
-- Created by Brian Cronin (brianc@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/MinimapMappableMixin.lua")

class 'MapBlip' (Entity)

MapBlip.kMapName = "MapBlip"

local networkVars =
{
    -- replace m_origin with a less precise version lacking y
    m_origin = "interpolated position (by 0.2 [2 3 5], by 1000 [0 0 0], by 0.2 [2 3 5])",
    -- replace m_angles with a less precise version lacking roll and pitch (range is 0-2pi, -> 0.1 = 6 bits)
    m_angles = "interpolated angles (by 10 [0], by 0.1 [3], by 10 [0])",
    mapBlipType = "enum kMinimapBlipType",
    mapBlipTeam = string.format("integer (%s to %s)", kTeamInvalid, kSpectatorIndex),
    isInCombat = "boolean",
    isParasited = "boolean",
    ownerEntityId = "entityid",
    isHallucination = "boolean",
    active = "boolean"
}

function MapBlip:OnCreate()

    Entity.OnCreate(self)
    
    -- Prevent the engine from calling OnSynchronize or OnUpdate for improved performance
    -- since we create a lot of map blips.
    self:SetUpdates(false)
    
    self:SetOrigin(Vector(0,0,0))
    self:SetAngles(Angles(0,0,0))
    self.mapBlipType = kMinimapBlipType.TechPoint
    self.mapBlipTeam = kTeamReadyRoom
    self.ownerEntityId = Entity.invalidId
    self.isInCombat = false
    self.isParasited = false
    
    self:UpdateRelevancy()
    
    if Client then
        InitMixin(self, MinimapMappableMixin)

        self.clientMapBlipTeam = kMinimapBlipTeam.Neutral
        self.nextClientMapBlipTeamUpdate = 0

        if not MapBlip.kCustomMarineColor then
            MapBlip.kCustomMarineColor = GetAdvancedOption("playercolor_m")
        end

        if not MapBlip.kCustomAlienColor then
            MapBlip.kCustomAlienColor = GetAdvancedOption("playercolor_a")
        end

        if not MapBlip.kCustomMapEntityColor then
            MapBlip.kCustomMapEntityColor = GetAdvancedOption("mapelementscolor")
        end

        if not MapBlip.kFriendsHighlightingEnabled then
            MapBlip.kFriendsHighlightingEnabled = GetAdvancedOption("friends")
        end

        MapBlip.kHighlightSameBuildings = GetAdvancedOption("commhighlight")
        MapBlip.kHighlightSameBuildingsColor = GetAdvancedOption("commhighlightcolor")
        self.highlighted = false

    end
    
end



function MapBlip:UpdateRelevancy()

    self:SetRelevancyDistance(Math.infinity)
    
    local mask = 0

    if self.mapBlipTeam == kTeam1Index or self.mapBlipTeam == kTeamInvalid or self:GetIsSighted() then
        mask = bit.bor(mask, kRelevantToTeam1)
    end
    if self.mapBlipTeam == kTeam2Index or self.mapBlipTeam == kTeamInvalid or self:GetIsSighted() then
        mask = bit.bor(mask, kRelevantToTeam2)
    end
    
    self:SetExcludeRelevancyMask( mask )

end

function MapBlip:SetOwner(ownerId, blipType, blipTeam)

    self.ownerEntityId = ownerId
    self.mapBlipType = blipType
    self.mapBlipTeam = blipTeam
    
    self:Update()

end


function MapBlip:GetOwnerEntityId()
    return self.ownerEntityId
end

-- used by bot brains
function MapBlip:GetType()
    return self.mapBlipType
end

-- required by minimapmappable
function MapBlip:GetMapBlipType()
    return self.mapBlipType
end

function MapBlip:GetTeamNumber()
    return self.mapBlipTeam
end

function MapBlip:GetRotation()
    return self:GetAngles().yaw
end

function MapBlip:GetIsActive()
    return self.active
end

function MapBlip:GetIsSighted()

    local owner = Shared.GetEntity(self.ownerEntityId)
    
    if owner then
    
        if owner.GetTeamNumber and owner:GetTeamNumber() == kTeamReadyRoom and owner:GetAttached() then
            owner = owner:GetAttached()
        end
        
        return HasMixin(owner, "LOS") and owner:GetIsSighted() or false
        
    end
    
    return false
    
end

function MapBlip:GetIsInCombat()
    return self.isInCombat
end

function MapBlip:GetIsParasited()
    return self.isParasited
end

-- Called (server side) when a mapblips owner has changed its map-blip dependent state
function MapBlip:Update()
    PROFILE("MapBlip:Update")

    local owner = self.ownerEntityId and Shared.GetEntity(self.ownerEntityId)
    if owner then
        
        local fowardNormal = owner:GetCoords().zAxis
        -- Don't rotate power nodes
        local yaw = ConditionalValue(owner:isa("PowerPoint"), 0, math.atan2(fowardNormal.x, fowardNormal.z))
        
        self:SetAngles(Angles(0, yaw, 0))
        
        local origin
        if owner.GetPositionForMinimap then
            origin = owner:GetPositionForMinimap()
        else
            origin = owner:GetOrigin()
        end
        
        if origin then
        
            -- always use zero y-origin (for now, if you want to use it for long-range hivesight, add it back
            self:SetOrigin(Vector(origin.x, 0, origin.z))      
            
            self:UpdateRelevancy()
            
            if HasMixin(owner, "MapBlip") then
            
                local success, blipType, blipTeam, isInCombat, isParasited = owner:GetMapBlipInfo()

                self.mapBlipType = blipType
                self.mapBlipTeam = blipTeam
                self.isInCombat = isInCombat    
                self.isParasited = isParasited
                
            end 
            
            if owner:isa("Player") then
                self.clientIndex = owner:GetClientIndex()
                self.isSteamFriend = nil
            end 

            self.isHallucination = owner.isHallucination == true or owner:isa("Hallucination")
            
            self.active = GetIsUnitActive(owner)

        end
        
    end
    
end

function MapBlip:GetIsValid()

    local entity = Shared.GetEntity(self:GetOwnerEntityId())
    if entity == nil then
        return false
    end
    
    if entity.GetIsBlipValid then
        return entity:GetIsBlipValid()
    end
    
    return true
    
end

-- Converts a kMinimapBlipTeam enum type to a regular team index.
local function MinimapTeamToTeam(mmTeam)
    if mmTeam <= 3 or mmTeam >= 10 then
        return kTeamInvalid
    end
    
    return (mmTeam % 2 == 0) and kTeam2Index or kTeam1Index
end

if Client then

    local marineBlipTypes = set
    {
        kMinimapBlipType.Marine,
        kMinimapBlipType.JetpackMarine,
        kMinimapBlipType.Exo
    }

    local alienBlipTypes = set
    {
        kMinimapBlipType.Skulk,
        kMinimapBlipType.Gorge,
        kMinimapBlipType.Lerk,
        kMinimapBlipType.Fade,
        kMinimapBlipType.Onos
    }

    local mapBlipTypes = set
    {
        kMinimapBlipType.TechPoint,
        kMinimapBlipType.ResourcePoint
    }

    local friendTeams = set
    {
        kMinimapBlipTeam.FriendMarine,
        kMinimapBlipTeam.FriendAlien
    }
    
    local kFastMoverTypes = {}
    kFastMoverTypes[kMinimapBlipType.Drifter] = true
    kFastMoverTypes[kMinimapBlipType.MAC]     = true
    
    function MapBlip:GetMapBlipColor(minimap, item)

        local player = Client.GetLocalPlayer()
        local color = self.currentMapBlipColor or Color()
        local blipTeam = self:GetMapBlipTeam(minimap)
        local teamVisible = self.OnSameMinimapBlipTeam(minimap.playerTeam, blipTeam) or minimap.spectating

        self.highlighted = false
        if marineBlipTypes[self.mapBlipType] then

            color = MapBlip.kCustomMarineColor

        elseif alienBlipTypes[self.mapBlipType] and not (teamVisible and self.isHallucination) then

            color = MapBlip.kCustomAlienColor

        elseif mapBlipTypes[self.mapBlipType] then

            color = MapBlip.kCustomMapEntityColor

        elseif MapBlip.kHighlightSameBuildings and
                player and player:GetIsCommander() and
                EnumToString(kTechId, player:GetGhostModelTechId()) == EnumToString(kMinimapBlipType, self.mapBlipType) then

                color = MapBlip.kHighlightSameBuildingsColor
            self.highlighted = true
        end

        if MapBlip.kFriendsHighlightingEnabled and friendTeams[blipTeam] then
            local hue, sat, val = RGBToHSV(color)
            sat = sat * .5
            color = HSVToRGB(hue, sat, val)
        end

        return color
    end

    -- only update the mapblips team on the client every 25 ms to decrease costs of update routine
    -- At least make sure to only run this once every frame per mapblip
    -- Todo: Increase interval further?
    MapBlip.kClientBlipTeamUpdateInterval = 0.025
    function MapBlip:UpdateMapBlipTeam(minimap)
        local now = Shared.GetTime()
        if now < self.nextClientMapBlipTeamUpdate then --likely
            return
        end

        local playerTeam = MinimapTeamToTeam(minimap.playerTeam)
        local blipTeamNumber = self:GetTeamNumber()
        local isEmbryo = (self:GetType() == kMinimapBlipType.Embryo)
        local isEnemy = (blipTeamNumber == GetEnemyTeamNumber(playerTeam))
        local friendshipSecret = isEmbryo and isEnemy

        -- Allow enemies to see friends on the other team.  Used to be a bug, now it's a feature. :)
        if self.isSteamFriend == nil and self.clientIndex and self.clientIndex > 0 then

            local steamId = GetSteamIdForClientIndex(self.clientIndex)
            if steamId then
                self.isSteamFriend = Client.GetIsSteamFriend(steamId) -- expensive
            end

        end

        -- Don't give the enemy privileged information!
        local showAsFriend = not friendshipSecret and self.isSteamFriend

        local blipTeam = kMinimapBlipTeam.Neutral
        if not self:GetIsActive() then

            if blipTeamNumber == kMarineTeamType then
                blipTeam = kMinimapBlipTeam.InactiveMarine
            elseif blipTeamNumber== kAlienTeamType then
                blipTeam = kMinimapBlipTeam.InactiveAlien
            end

        elseif showAsFriend then

            if blipTeamNumber == kMarineTeamType then
                blipTeam = kMinimapBlipTeam.FriendMarine
            elseif blipTeamNumber== kAlienTeamType then
                blipTeam = kMinimapBlipTeam.FriendAlien
            end

        else

            if blipTeamNumber == kMarineTeamType then
                blipTeam = kMinimapBlipTeam.Marine
            elseif blipTeamNumber== kAlienTeamType then
                blipTeam = kMinimapBlipTeam.Alien
            end

        end

        self.clientMapBlipTeam = blipTeam
        self.nextClientMapBlipTeamUpdate = now + MapBlip.kClientBlipTeamUpdateInterval
    end

    function MapBlip:GetMapBlipTeam(minimap)
        PROFILE("MapBlip:GetMapBlipTeam")

        self:UpdateMapBlipTeam(minimap)

        return self.clientMapBlipTeam
    end
     
    function MapBlip:InitActivityDefaults()
        -- default; these usually don't move, and if they move they move slowly. They may be attacked though, and then they
        -- need to animate at a higher rate
        self.combatActivity = kMinimapActivity.Medium
        self.movingActivity = kMinimapActivity.Low
        self.defaultActivity = kMinimapActivity.Static
        
        local isFastMover = kFastMoverTypes[self.mapBlipType]
        
        if isFastMover then
            self.defaultActivity = kMinimapActivity.Low
            self.movingActivity = kMinimapActivity.Medium
        end
        
    end

    function MapBlip:UpdateMinimapActivity(minimap, item)
        PROFILE("MapBlip:UpdateMinimapActivity")

        if self.combatActivity == nil then
            self:InitActivityDefaults()
        end

        local blipTeam = self:GetMapBlipTeam(minimap) -- the blipTeam can change if power changes
        if blipType ~= item.blipType or blipTeam ~= item.blipTeam then
            item.resetMinimapItem = true
        end

        local origin = self:GetOrigin()
        local isMoving = item.prevOrigin ~= origin
        item.prevOrigin = origin

        return self.isInCombat and self.combatActivity or
                isMoving and self.movingActivity or
                self.defaultActivity
    end
    
    local blipRotation = Vector(0,0,0)
    function MapBlip:UpdateMinimapItemHook(minimap, item)
        PROFILE("MapBlip:UpdateMinimapItemHook")

        local rotation = self:GetRotation()
        if rotation ~= item.prevRotation then
            item.prevRotation = rotation
            blipRotation.z = rotation
            item:SetRotation(blipRotation)
        end

        local blipTeam = self:GetMapBlipTeam(minimap)
        local blipColor = item.blipColor
        
        if self.OnSameMinimapBlipTeam(minimap.playerTeam, blipTeam) or minimap.spectating then

            self:UpdateHook(minimap, item)
            
            if self.isHallucination then
                blipColor = kHallucinationColor
            elseif self.isInCombat then
                if self.MinimapBlipTeamIsActive(blipTeam) then

                    if self.highlighted then
                        local percentage = (math.cos(Shared.GetTime() * 10) + 1) * 0.5
                        blipColor = LerpColor(kRed, MapBlip.kHighlightSameBuildingsColor, percentage)
                    else
                        blipColor = self.PulseRed(1.0)
                    end

                else
                    blipColor = self.PulseDarkRed(blipColor)
                end
            end  
        end
        self.currentMapBlipColor = blipColor

    end
    
    function MapBlip:UpdateHook(minimap, item)
        -- empty; allow players to decorate with their names
    end

end -- Client
Shared.LinkClassToMap("MapBlip", MapBlip.kMapName, networkVars)

class 'PlayerMapBlip' (MapBlip)

PlayerMapBlip.kMapName = "PlayerMapBlip"

local playerNetworkVars =
{
    clientIndex = "entityid",
}

if Client then
      function PlayerMapBlip:InitActivityDefaults()
        self.isInCombatActivity = kMinimapActivity.Medium
        self.movingActivity = kMinimapActivity.Medium
        self.defaultActivity = kMinimapActivity.Medium
      end
 
    -- the local player has a special marker; do not show his mapblip 
    function PlayerMapBlip:UpdateMinimapActivity(minimap, item)
        if self.clientIndex == minimap.clientIndex then
            return nil
        end
        return MapBlip.UpdateMinimapActivity(self, minimap, item)
    end
    
    -- players can show their names on the minimap
    function PlayerMapBlip:UpdateHook(minimap, item)
        PROFILE("PlayerMapBlip:UpdateHook")

        minimap:DrawMinimapName(item, self:GetMapBlipTeam(minimap), self.clientIndex, self.isParasited)
    end

end
Shared.LinkClassToMap("PlayerMapBlip", PlayerMapBlip.kMapName, playerNetworkVars)

-- Todo: Eachscan should have it's own animation
class 'ScanMapBlip' (MapBlip)
ScanMapBlip.kMapName = "ScanMapBlip"
if Client then

    function ScanMapBlip:UpdateMinimapActivity()
        return kMinimapActivity.High
    end

    -- Update color, scale and position for animation
    local _blipPos = Vector(0,0,0) -- Avoid GC
    function ScanMapBlip:UpdateMinimapItemHook(minimap, item)
        PROFILE("ScanMapBlip:UpdateMinimapItemHook")

        if not item:GetIsVisible() then return end

        MapBlip.UpdateMinimapItemHook(self, minimap, item)

        local size = minimap.scanSize
        local color = minimap.scanColor
        item:SetSize(size)
        item:SetColor(color)

        -- adjust position
        local origin = self:GetOrigin()
        local xPos, yPos = minimap:PlotToMap(origin.x, origin.z)
        _blipPos.x = xPos - size.x * 0.5
        _blipPos.y = yPos - size.y * 0.5
        item:SetPosition(_blipPos)
    end

end
Shared.LinkClassToMap("ScanMapBlip", ScanMapBlip.kMapName, {})
