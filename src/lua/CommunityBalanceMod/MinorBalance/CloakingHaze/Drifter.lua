-- ========= Community Balance Mod ===============================
--
-- "lua\Drifter.lua"
--
--    Created by:   Twiliteblue, Drey (@drey3982)
--
-- ===============================================================


Script.Load("lua/CommunityBalanceMod/MinorBalance/CloakingHaze/CloakingHaze.lua")

function Drifter:GetTechButtons(techId)

    local techButtons = { kTechId.EnzymeCloud, kTechId.CloakingHaze, kTechId.MucousMembrane, kTechId.None,
                          kTechId.Grow, kTechId.Move, kTechId.Patrol, kTechId.Consume }

                          
    return techButtons

end


function Drifter:PerformActivation(techId, position, normal, commander)

    local success = false
    local keepProcessing = true

    -- added Cloaking Haze
    if techId == kTechId.EnzymeCloud or techId == kTechId.Hallucinate or techId == kTechId.MucousMembrane or techId == kTechId.Storm or techId == kTechId.CloakingHaze then

        local team = self:GetTeam()
        local cost = GetCostForTech(techId)
        if cost <= team:GetTeamResources() then

            self:GiveOrder(techId, nil, position + Vector(0, 0.2, 0), nil, not commander.shiftDown, false)
            -- Only 1 Drifter will process this activation.
            keepProcessing = false

        end

        -- return false, team res will be drained once we reached the destination and created the enzyme entity
        success = false

    else
        return ScriptActor.PerformActivation(self, techId, position, normal, commander)
    end

    return success, keepProcessing

end


local OldUpdateTasks = debug.getupvaluex(Drifter.OnUpdate, "UpdateTasks")
local FindTask = debug.getupvaluex(OldUpdateTasks, "FindTask")
local kTurnRateLimitOrderTypes = set
{
    kTechId.Move,
    kTechId.Patrol
}


-- added cloaking Haze as 1 line
local function UpdateTasks(self, deltaTime)

    if not self:GetIsAlive() then
        return
    end

    local now = Shared.GetTime()

    local currentOrder = self:GetCurrentOrder()
    if currentOrder ~= nil then

        local maxSpeedTable = { maxSpeed = Drifter.kMoveSpeed }
        self:ModifyMaxSpeed(maxSpeedTable)
        local drifterMoveSpeed = maxSpeedTable.maxSpeed

        local currentOrigin = Vector(self:GetOrigin())

        if self.newOrderFirstUpdate then -- This is the first update on a order.

            if kTurnRateLimitOrderTypes[currentOrder:GetType()] then

                local timeSinceLastMoveOrderStarted = now - self.timeLastMoveOrderStarted

                if timeSinceLastMoveOrderStarted <= self.kMoveTurnLimitSeconds then
                    self.timeTurnRateLimitEnds = now + self.kMoveTurnLimitSeconds -- Time it takes to do a 180 turn with "slow" speed
                end

                self.timeLastMoveOrderStarted = now

            end

            self.newOrderFirstUpdate = false

        end

        local currentOrder = currentOrder:GetType()
        if currentOrder == kTechId.Move or currentOrder == kTechId.Patrol then
            self:ProcessMoveOrder(drifterMoveSpeed, deltaTime)
        elseif currentOrder == kTechId.Follow then
            self:ProcessFollowOrder(drifterMoveSpeed, deltaTime)
        elseif currentOrder == kTechId.EnzymeCloud or currentOrder == kTechId.Hallucinate or currentOrder == kTechId.MucousMembrane or currentOrder == kTechId.Storm 
            or currentOrder == kTechId.CloakingHaze then -- added Cloaking Haze
            self:ProcessEnzymeOrder(drifterMoveSpeed, deltaTime)
        elseif currentOrder == kTechId.Grow then
            self:ProcessGrowOrder(drifterMoveSpeed, deltaTime)
        end

        -- Check difference in location to set moveSpeed
        local distanceMoved = (self:GetOrigin() - currentOrigin):GetLength()

        self.moveSpeed = (distanceMoved / drifterMoveSpeed) / deltaTime

    else -- No orders to process

        self.newOrderFirstUpdate = true

        if not self.timeLastTaskCheck or self.timeLastTaskCheck + 2 < now then

            if GetIsUnitActive(self) then
                FindTask(self)
            end
            self.timeLastTaskCheck = now

        end

    end

    -- Update Turn Rate Limiter
    self.turnRateLimited = (now < self.timeTurnRateLimitEnds)

end

debug.setupvaluex(Drifter.OnUpdate, "UpdateTasks", UpdateTasks)