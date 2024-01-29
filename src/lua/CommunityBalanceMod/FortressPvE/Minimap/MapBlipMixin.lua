-- ========= Community Balance Mod ===============================
--
-- "lua\MapBlipMixin.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


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

    if self:isa("Hallucination") then
        local hallucinatedTechId = self:GetAssignedTechId()
        blipType = StringToEnum(kMinimapBlipType, EnumToString(kTechId, hallucinatedTechId))
        blipTeam = self:GetTeamNumber()
        return success, blipType, blipTeam, isAttacked, isParasited
    end


    if self:GetTechId() == kTechId.FortressCrag then 
        blipType = kMinimapBlipType.FortressCrag
        blipTeam = self:GetTeamNumber()
        return success, blipType, blipTeam, isAttacked, isParasited

    elseif self:GetTechId() == kTechId.FortressShade then 
        blipType = kMinimapBlipType.FortressShade
        blipTeam = self:GetTeamNumber()
        return success, blipType, blipTeam, isAttacked, isParasited

    elseif self:GetTechId() == kTechId.FortressShift then 
        blipType = kMinimapBlipType.FortressShift
        blipTeam = self:GetTeamNumber()
        return success, blipType, blipTeam, isAttacked, isParasited
      
    elseif self:GetTechId() == kTechId.FortressWhip then 
        local mature = self:GetIsMature()
        blipTeam = self:GetTeamNumber()
        if mature then 
            blipType = kMinimapBlipType.FortressWhipMature
        else 
            blipType = kMinimapBlipType.FortressWhip
        end
        return success, blipType, blipTeam, isAttacked, isParasited
    end
    success = false

    
    success, blipType, blipTeam, isAttacked, isParasited = oldMapBlipMixinGetMapBlipInfo(self)

    return success, blipType, blipTeam, isAttacked, isParasited

end

