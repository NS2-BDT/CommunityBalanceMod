-- ========= Community Balance Mod ===============================
--
--  "lua\Drifter.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


function Drifter:ProcessGrowOrder(moveSpeed, deltaTime)

    local currentOrder = self:GetCurrentOrder()

    if currentOrder ~= nil then

        local target = Shared.GetEntity(currentOrder:GetParam())

        if not target or target:GetIsBuilt() or not target:GetIsAlive() then
            self:CompletedCurrentOrder()


        -- Balance mod
        elseif target.GetIsTeleporting ~= nil and target:GetIsTeleporting() then 
            self:CompletedCurrentOrder()
        else

            local targetPos = target:GetOrigin()
            local toTarget = targetPos - self:GetOrigin()
            -- Continuously turn towards the target. But don't mess with path finding movement if it was done.

            if (toTarget):GetLength() > 3 then
                self:MoveToTarget(PhysicsMask.AIMovement, targetPos, moveSpeed, deltaTime)
            else

                if toTarget then
                    self:SmoothTurn(deltaTime, GetNormalizedVector(toTarget), 0)
                end

                target:RefreshDrifterConstruct()
                self.constructing = true
            end

        end

    end

end
