local kUnitMaxLOSDistance = kPlayerLOSDistance
local kUnitMinLOSDistance = kStructureLOSDistance

-- Mark entities dirty within a radius equal to the max vision radius plus the distance that could
-- be covered in the 1-second between LOS updates.  We use the drifter speed because the drifter is
-- the fastest non-player entity, and we use 2x that to cover cases where the drifter and the
-- object it is observing are moving directly away from each other.  We just assume that whatever
-- the other object is, it is only moving as fast or slower than the drifter.
local maxEntityMoveSpeed = 11 -- drifter's speed, hard-coded here. :(
local kUnitLOSDirtyDistance = kUnitMaxLOSDistance + maxEntityMoveSpeed --* 2  -- frequency is increased so distance is halved

--local kLOSTimeout = 0.599  -- was 1

local function UpdateLOS(self)

    local mask = bit.bor(kRelevantToTeam1Unit, kRelevantToTeam2Unit, kRelevantToReadyRoom)
    
    if self.sighted then
        mask = bit.bor(mask, kRelevantToTeam1Commander, kRelevantToTeam2Commander)
    elseif self:GetTeamNumber() == 1 then
        mask = bit.bor(mask, kRelevantToTeam1Commander)
    elseif self:GetTeamNumber() == 2 then
        mask = bit.bor(mask, kRelevantToTeam2Commander)
    end
    
    self:SetExcludeRelevancyMask(mask)
    self.visibleClient = self.sighted
    UpdateEntityForTeamBrains(self)
    
    if self.lastSightedState ~= self.sighted then
    
        if self.OnSighted then
            self:OnSighted(self.sighted)
        end
        
        self.lastSightedState = self.sighted
        
    end
    
end

if Server then
    local function UnsightImmediately(self)
        self:SetIsSighted(false)
        UpdateLOS(self)
    end
    
    function LOSMixin:OnCloak()
        UnsightImmediately(self)
    end
end

--local SharedUpdate = debug.getupvaluex(LOSMixin.OnUpdate, "SharedUpdate")
--debug.replaceupvalue( SharedUpdate, "kLOSTimeout", kLOSTimeout, true)