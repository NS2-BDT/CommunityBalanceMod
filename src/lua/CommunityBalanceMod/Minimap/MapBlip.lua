

-- Balance Mod, Added Hive to exceptions at yaw.


-- Called (server side) when a mapblips owner has changed its map-blip dependent state
function MapBlip:Update()
    PROFILE("MapBlip:Update")

    local owner = self.ownerEntityId and Shared.GetEntity(self.ownerEntityId)
    if owner then
        
        local fowardNormal = owner:GetCoords().zAxis
        -- Don't rotate power nodes
        local yaw = ConditionalValue(owner:isa("PowerPoint") or owner:isa("Hive"), 0, math.atan2(fowardNormal.x, fowardNormal.z))
        
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

