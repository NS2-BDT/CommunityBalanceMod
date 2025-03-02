-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\AlienStructureMoveMixin.lua
--
--    Created by:   Mats Olsson (mats.olsson@matsotech.se)
--
--    Move alien structures
--
--    CQ: how much work to generalize it to generic AI-movement (including arcs, drifters, macs)?
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

AlienStructureMoveMixin = CreateMixin(AlienStructureMoveMixin)
AlienStructureMoveMixin.type = "AlienUpgrade"

AlienStructureMoveMixin.expectedMixins =
{
    Orders = "Need to have a move order to follow",
    Pathing = "Requires for MoveToTarget",
}

AlienStructureMoveMixin.requiredCallbacks =
{
    -- CQ: GetMaxSpeed is a bit hackish (global, no connection to any mixin and here we use it as CURRENT rather than MAX speed)
    GetMaxSpeed = "Speed of structure movement"
}

AlienStructureMoveMixin.optionalCallbacks =
{
    GetStructureMovable = "Implement and return false if the structure can't move right now (default true)",
}

AlienStructureMoveMixin.optionalConstants =
{
    kAlienStructureMoveSound = "Precached asset for sound used when moving. Defaults to PrecacheAsset(sound/NS2.fev/alien/infestation/build)"
}

AlienStructureMoveMixin.networkVars =
{
    moving = "boolean"
}

local kAlienStructureMoveSound = PrecacheAsset("sound/NS2.fev/alien/infestation/build")

function AlienStructureMoveMixin:__initmixin()
    
    PROFILE("AlienStructureMoveMixin:__initmixin")
    
    if Server then    
        self.distanceMoved = 0
        self.moving = false
    elseif Client then
        self.alienStructureMoveSound = self:GetMixinConstants().kAlienStructureMoveSound or kAlienStructureMoveSound
    end
    
end

function AlienStructureMoveMixin:GetIsMoving()
    return self.moving
end

if Server then

    local function CanMove(self)
        local order = self:GetCurrentOrder()
        local isRepositoning = HasMixin(self, "Repositioning") and self:GetIsRepositioning()
        local hasMoveOrder = order and order:GetType() == kTechId.Move
        local canMove = GetIsUnitActive(self) and (isRepositoning or hasMoveOrder)

        -- CQ: this is interesting ... who is responsible for this rule? Doing it like this means that
        -- this mixin knows about the teleporting mixin. OTOH, the teleporting mixin could know about
        -- us and implement a GetStructureMoveable() to block when teleporting. OT3H, GetStructureMovable
        -- is not stackable for multiple mixins (only the first method can return a value)
        -- Correct solution would be for the actual class to implement it, but that either duplicates code
        -- or you move up the default to the best base class and comment that it is only used for moving
        -- things.
        canMove = canMove and (not HasMixin(self, "TeleportAble") or not self:GetIsTeleporting())

        canMove = canMove and (not self.GetStructureMoveable or self:GetStructureMoveable(self))
        
        return canMove
    end
       
    -- Support for both StaticTargetMixin and TargetCacheMixin.
    -- Structures implementing StaticTarget are "move rarely" structures, so we need to
    -- notify the StaticTargetMixin that they have shifted position. For performance reasons,
    -- we notify only when the structure has moved 1 m or when they stop moving.
    -- Structures that move
    local function HandleTargeting(self, speed, deltaTime)
        
        self.distanceMoved = self.distanceMoved + speed * deltaTime
        
        if self.distanceMoved > 1 or (self.distanceMoved > 0 and not self.moving) then
        
            if HasMixin(self, "StaticTarget") then
                self:StaticTargetMoved()
            end

            -- CQ: Update TargetCacheMixin to have a required AttackerMoved method to handle a target selector user moving
            if not self.moving and self.AttackerMoved then
                self:AttackerMoved()
            end
           
            self.distanceMoved = 0
            
        end        
        
    end
        
    -- Remove from mesh when we start moving and add back when we stop moving
    local function HandleObstacle(self)


        local isRepositoning = HasMixin(self, "RepositioningMixin") and self:GetIsRepositioning()

        --Balancemodfix:
        isRepositoning = HasMixin(self, "Repositioning") and self:GetIsRepositioning()

        local removeFromMesh = CanMove(self) or isRepositoning

        if not removeFromMesh and GetIsUnitActive(self) and self.removedMesh then
            self:AddToMesh()
            self.removedMesh = false
        end

        if removeFromMesh and not self.removedMesh then
            self:RemoveFromMesh()
            self:OnObstacleChanged()
            self.removedMesh = true
        end

    end
    
    function AlienStructureMoveMixin:OnUpdate(deltaTime)
      
        PROFILE("AlienStructureMoveMixin:OnUpdate")
    
        local currentOrder = self:GetCurrentOrder()
        local speed = 0

        if CanMove(self) then

            self.moving = true
            speed = self:GetMaxSpeed()
            
            --[[ CQ: remove shiftboost
            if self.shiftBoost then
                speed = speed * kShiftStructurespeedScalar
            end
            --]]
            if currentOrder then
                self:RemoveFromMesh() -- So we don't block our own self
                self:MoveToTarget(PhysicsMask.AIMovement, currentOrder:GetLocation(), speed, deltaTime)
            
                if self:IsTargetReached(currentOrder:GetLocation(), kAIMoveOrderCompleteDistance) then
                    self:CompletedCurrentOrder()
                    self.moving = false
                end
            end
            
        else
            self.moving = false
        end
        
        HandleTargeting(self, speed, deltaTime)
        
        if HasMixin(self, "Obstacle") then
            HandleObstacle(self)
        end   
        
    end

elseif Client then 

    function AlienStructureMoveMixin:OnUpdate(deltaTime)
      
        PROFILE("AlienStructureMoveMixin:OnUpdate")
        
        if self.clientMoving ~= self.moving then
        
            if self.moving then
                Shared.PlaySound(self, self.alienStructureMoveSound, 1)
            else
                Shared.StopSound(self, self.alienStructureMoveSound)
            end
            
            self.clientMoving = self.moving
        
        end
        
        if self.moving and (not self.timeLastDecalCreated or self.timeLastDecalCreated + 1.1 < Shared.GetTime() ) then
        
            self:TriggerEffects("structure_move")
            self.timeLastDecalCreated = Shared.GetTime()
        
        end
    
    end
end
