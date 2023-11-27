


local oldMapBlipMixinGetMapBlipInfo = MapBlipMixin.GetMapBlipInfo

function MapBlipMixin:GetMapBlipInfo()

    if self.OnGetMapBlipInfo then
        return self:OnGetMapBlipInfo()
    end

    local success = true
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    local isParasited = HasMixin(self, "ParasiteAble") and self:GetIsParasited()

    if self:isa("CommandStation") then 
        local occupied = not ( self:GetCommander() == nil )
        blipTeam = self:GetTeamNumber()  

        if occupied then 
            blipType = kMinimapBlipType.CommandStationOccupied
        else 
            blipType = kMinimapBlipType.CommandStation
        end

        return success, blipType, blipTeam, isAttacked, isParasited
         
    elseif self:isa("Whip") then 
        local mature = self:GetIsMature()
        blipTeam = self:GetTeamNumber()  

        if mature then 
            blipType = kMinimapBlipType.WhipMature
        else 
            blipType = kMinimapBlipType.Whip
        end

        return success, blipType, blipTeam, isAttacked, isParasited

    elseif self:isa("Hive") then
        local maturityLevel =  self:GetMaturityFraction()
        local occupied = not ( self:GetCommander() == nil )
        blipTeam = self:GetTeamNumber()  

        if maturityLevel < 0.34 then 
            if occupied then 
                blipType = kMinimapBlipType.HiveFreshOccupied
            else 
                blipType = kMinimapBlipType.HiveFresh
            end

        elseif maturityLevel > 0.65 then 
            if occupied then 
                blipType = kMinimapBlipType.HiveMatureOccupied
            else 
                blipType = kMinimapBlipType.HiveMature
            end

        else 
            if occupied then 
                blipType = kMinimapBlipType.HiveOccupied
            else 
                blipType = kMinimapBlipType.Hive
            end
        end

        return success, blipType, blipTeam, isAttacked, isParasited

    elseif self:isa("Armory") then
        blipTeam = self:GetTeamNumber()  
        
        if self:GetIsAdvanced() then 
            blipType = kMinimapBlipType.AdvancedArmory
        else
            blipType = kMinimapBlipType.Armory
        end
        return success, blipType, blipTeam, isAttacked, isParasited

    elseif self:isa("ARC") then
        blipTeam = self:GetTeamNumber()  

        if self:GetPlayIdleSound() then
            blipType = kMinimapBlipType.ARC
        else
            blipType = kMinimapBlipType.ARCDeployed
        end
      
        return success, blipType, blipTeam, isAttacked, isParasited
    end
    success = false
    
    success, blipType, blipTeam, isAttacked, isParasited = oldMapBlipMixinGetMapBlipInfo(self)

    return success, blipType, blipTeam, isAttacked, isParasited

end


