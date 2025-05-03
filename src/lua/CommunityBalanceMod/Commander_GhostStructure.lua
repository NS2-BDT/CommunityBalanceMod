-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\Commander_GhostStructure.lua
--
--    Created by:   Brian Cronin (brianc@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

assert(Client)

local ghostTechId = kTechId.None
local ghostStructureEnabled = false
local errorMessage = ""
local ghostStructureValid = false
local ghostStructureCoords = Coords()
local ghostNormalizedPickRay = Vector(0,0,0)
local ghostStructureTargetId = Entity.invalidId
local orientationAngle = 0
local specifyingOrientation = false


-- gets set to false when techid changes, set to true if shift is pressed
local checkExitforValid = false

-- true if the current blueprint has an exit to worry about: PG, Robo, Sentries
local blueprintHasExit = false 


-- option preference will be set each time the techid of the current blueprint changes
local isp_alien_enabled = false
local isp_marine_enabled_2 = false
local isp_shift_enabled = false
local isp_orientation_enabled = false


-- new function for Commander_Client to save performance
 function GetGhostStructureCoords()
    return Copy(ghostStructureCoords)
 end

 -- new function for Commander_Client to save performance. If true it will display the exit direction even if the blueprint is invalid
 function GetShowOrientation()
    return blueprintHasExit and checkExitforValid and isp_shift_enabled
 end


function SetCommanderGhostStructureEnabled(enabled)
    ghostStructureEnabled = enabled
end

function GetCommanderGhostStructureEnabled()
    return ghostStructureEnabled
end

function GetCommanderErrorMessage()
    return errorMessage
end

function GetCommanderGhostStructureValid()
    return ghostStructureValid
end

-- true while rotating the blueprint for a valid exit after chosing a location for it with exits 
function GetCommanderGhostStructureSpecifyingOrientation()
    return specifyingOrientation
end

local function GetSpecifiedOrientation(commander)

    local xScalar, yScalar = Client.GetCursorPos()
    local x = xScalar * Client.GetScreenWidth()
    local y = yScalar * Client.GetScreenHeight()

    local startPoint = Client.WorldToScreen(ghostStructureCoords.origin)
    local endPoint = startPoint + (Vector(x, y, 0) - startPoint)

    local vecDiff = startPoint - endPoint

    if vecDiff:GetLength() > 1 then

        local normToMouse = GetNormalizedVector(vecDiff)
        local z = normToMouse.x
        local x = normToMouse.y
        normToMouse.z = -z
        normToMouse.x = x
        normToMouse.y = 0
        return GetYawFromVector(normToMouse)

    end

    return 0

end



-- only apply the ray search for these techs
local function GetImprovedPlacingEnabled(techId)

    local isEnabled = false

    if isp_alien_enabled then 
        --Gorge Tunnels
        isEnabled = isEnabled or (techId >= kTechId.BuildTunnelEntryOne and techId <= kTechId.BuildTunnelExitFour)
        isEnabled = isEnabled or techId == kTechId.Tunnel
        isEnabled = isEnabled or techId == kTechId.TunnelExit
        isEnabled = isEnabled or techId == kTechId.TunnelRelocate

        isEnabled = isEnabled or techId == kTechId.Spur
        isEnabled = isEnabled or techId == kTechId.Veil
        isEnabled = isEnabled or techId == kTechId.Shell
        isEnabled = isEnabled or techId == kTechId.Shade
        isEnabled = isEnabled or techId == kTechId.Shift
        isEnabled = isEnabled or techId == kTechId.Crag
        isEnabled = isEnabled or techId == kTechId.Whip
        isEnabled = isEnabled or techId == kTechId.TeleportWhip
        isEnabled = isEnabled or techId == kTechId.TeleportCrag
        isEnabled = isEnabled or techId == kTechId.TeleportShade
        isEnabled = isEnabled or techId == kTechId.TeleportShift
        isEnabled = isEnabled or techId == kTechId.TeleportVeil
        isEnabled = isEnabled or techId == kTechId.TeleportSpur
        isEnabled = isEnabled or techId == kTechId.TeleportShell
    end
    if isp_marine_enabled_2  then 
        
        isEnabled = isEnabled or techId == kTechId.InfantryPortal
        isEnabled = isEnabled or techId == kTechId.Armory
        isEnabled = isEnabled or techId == kTechId.ArmsLab
        isEnabled = isEnabled or techId == kTechId.Sentry
        isEnabled = isEnabled or techId == kTechId.SentryBattery
        isEnabled = isEnabled or techId == kTechId.Observatory
        isEnabled = isEnabled or techId == kTechId.RoboticsFactory
        isEnabled = isEnabled or techId == kTechId.PhaseGate
        isEnabled = isEnabled or techId == kTechId.PrototypeLab
    end


    return isEnabled
end


local kIgnoreValidExitCheck = { ValidExit = true }
function GetCommanderGhostStructureCoords()

    if ghostStructureEnabled then

        local coords = Coords.GetIdentity()
        local commander = Client.GetLocalPlayer()
        local x, y = Client.GetCursorPosScreen()
        local normalizedPickRay = CreatePickRay(commander, x, y)

        local position, attachEntity


        
    

        --=============================================================================
        -- prevent jiggling blueprints by rounding
        local roundedX = x - x%5 + 2
        local roundedY = y - y%5 + 2

        --use it when the original ray has an invalid target
        --it allows you to test a different ray with an x,y offset and replaces the original ray if its valid
        --x, y are the pixels on the screen
        local function moveRay(moveX, moveY, ghostTechId, commander, ignoreChecks)

            local newPickRay = CreatePickRay(commander, roundedX + moveX * 5, roundedY + moveY * 5)
            local newTrace = GetCommanderPickTarget(commander, newPickRay, false, true, nil, LookupTechData( ghostTechId, kCommanderSelectRadius ), "ray")
            newghostStructureValid, newposition, newattachEntity, newerrorMessage = GetIsBuildLegal(ghostTechId, newTrace.endPoint, orientationAngle, kStructureSnapRadius, commander, nil, ignoreChecks)

            if newghostStructureValid then
                ghostStructureValid = newghostStructureValid
                position = newposition
                attachEntity = newattachEntity
                errorMessage = newerrorMessage
                trace = newTrace
                normalizedPickRay = newPickRay
            end

            return newghostStructureValid
        end
        

        -- gets called once per tick if the normal blueprint is invalid
        -- moveRay overwrites the blueprint when valid, therefore we have to close in as much as we can.
        -- moveRay shouldnt be called more than 20 times to not cause lags on weak hardware
        -- currently it takes around 10- 14 rays
        local function raySearch(ghostTechId, commander, ignoreChecks)
    
            local layer = 4
            local validRightUp =      moveRay(  1 * layer, -1 * layer  , ghostTechId, commander, ignoreChecks)
            local validRightDown =    moveRay(  1 * layer,  1 * layer  , ghostTechId, commander, ignoreChecks)
            local validLeftUp =       moveRay( -1 * layer, -1 * layer  , ghostTechId, commander, ignoreChecks)
            local validLeftDown =     moveRay( -1 * layer,  1 * layer  , ghostTechId, commander, ignoreChecks)

            if (validRightUp or validRightDown or validLeftUp or validLeftDown) then 

                --keep these values for layer 3
                local validRightUpTemp = validRightUp
                local validRightDownTemp = validRightDown
                local validLeftUpTemp = validLeftUp
                local validLeftDownTemp = validLeftDown

                -- check layer 2
                layer = 2 
                if validRightUp then
                    validRightUp = moveRay(   1 * layer,   -1 * layer, ghostTechId, commander, ignoreChecks)
                end
                if validRightDown then
                    validRightDown = moveRay( 1 * layer,   1 * layer, ghostTechId, commander, ignoreChecks)
                end
                if validLeftUp then
                    validLeftUp = moveRay(    -1 * layer,  -1 * layer, ghostTechId, commander, ignoreChecks)
                end
                if validLeftDown then
                    validLeftDown = moveRay(  -1 * layer,  1 * layer, ghostTechId, commander, ignoreChecks)
                end

                if (validRightUp or validRightDown or validLeftUp or validLeftDown) then 
                    -- check layer 1 
                    layer = 1
                    if validRightUp then
                        validRightUp = moveRay(   1 * layer,   -1 * layer, ghostTechId, commander, ignoreChecks)
                    end
                    if validRightDown then
                        validRightDown = moveRay( 1 * layer,   1 * layer, ghostTechId, commander, ignoreChecks)
                    end
                    if validLeftUp then
                        validLeftUp = moveRay(    -1 * layer,  -1 * layer, ghostTechId, commander, ignoreChecks)
                    end
                    if validLeftDown then
                        validLeftDown = moveRay(  -1 * layer,  1 * layer, ghostTechId, commander, ignoreChecks)
                    end

                    if (validRightUp or validRightDown or validLeftUp or validLeftDown) then 
                        --check layer 0
                        local center = moveRay(  0,   0, ghostTechId, commander, ignoreChecks)
                        if not center then 

                            -- check neighbours at layer 1
                            layer = 1
                            if validRightUp or validRightDown then
                                moveRay(   1 * layer,  0, ghostTechId, commander, ignoreChecks)
                            end
                            if validRightDown or validLeftDown then
                                moveRay(   0 ,  1 * layer, ghostTechId, commander, ignoreChecks)
                            end
                            if validLeftUp or validRightUp then
                                moveRay(   0,   -1 * layer, ghostTechId, commander, ignoreChecks)
                            end
                            if validLeftDown or validRightDown then
                                moveRay(  - 1 * layer,   0, ghostTechId, commander, ignoreChecks)
                            end

                        end
                    else 
                        -- check neighbours at layer 2 
                        layer = 2
                        if validRightUp or validRightDown then
                            moveRay(   1 * layer,  0, ghostTechId, commander, ignoreChecks)
                        end
                        if validRightDown or validLeftDown then
                            moveRay(   0 ,  1 * layer, ghostTechId, commander, ignoreChecks)
                        end
                        if validLeftUp or validRightUp then
                            moveRay(   0,   -1 * layer, ghostTechId, commander, ignoreChecks)
                        end
                        if validLeftDown or validRightDown then
                            moveRay(  - 1 * layer,   0, ghostTechId, commander, ignoreChecks)
                        end
                    end



                else 
                    -- check layer 3
                    layer = 3 
                    if validRightUpTemp then
                        validRightUp = moveRay(   1 * layer,   -1 * layer, ghostTechId, commander, ignoreChecks)
                    end
                    if validRightDownTemp then
                        validRightDown = moveRay( 1 * layer,   1 * layer, ghostTechId, commander, ignoreChecks)
                    end
                    if validLeftUpTemp then
                        validLeftUp = moveRay(    -1 * layer,  -1 * layer, ghostTechId, commander, ignoreChecks)
                    end
                    if validLeftDownTemp then
                        validLeftDown = moveRay(  -1 * layer,  1 * layer, ghostTechId, commander, ignoreChecks)
                    end

                    if (validRightUp or validRightDown or validLeftUp or validLeftDown) then 
                        -- check neighbours at layer 3
                        layer = 3
                        if validRightUp or validRightDown then
                            moveRay(   1 * layer,  0, ghostTechId, commander, ignoreChecks)
                        end
                        if validRightDown or validLeftDown then
                            moveRay(   0 ,  1 * layer, ghostTechId, commander, ignoreChecks)
                        end
                        if validLeftUp or validRightUp then
                            moveRay(   0,   -1 * layer, ghostTechId, commander, ignoreChecks)
                        end
                        if validLeftDown or validRightDown then
                            moveRay(  - 1 * layer,   0, ghostTechId, commander, ignoreChecks)
                        end
                    else 
                        -- check neighbours at layer 4
                        layer = 4
                        if validRightUp or validRightDown then
                            moveRay(   1 * layer,  0, ghostTechId, commander, ignoreChecks)
                        end
                        if validRightDown or validLeftDown then
                            moveRay(   0 ,  1 * layer, ghostTechId, commander, ignoreChecks)
                        end
                        if validLeftUp or validRightUp then
                            moveRay(   0,   -1 * layer, ghostTechId, commander, ignoreChecks)
                        end
                        if validLeftDown or validRightDown then
                            moveRay(  - 1 * layer,   0, ghostTechId, commander, ignoreChecks)
                        end
                    end

                end

            else 
                -- check layer 0
                local center = moveRay(  0,   0, ghostTechId, commander, ignoreChecks)
                if not center then 
                    -- check layer 1
                    layer = 1
                    validRightUp = moveRay(   1 * layer,   -1 * layer, ghostTechId, commander, ignoreChecks)
                    validRightDown = moveRay( 1 * layer,   1 * layer, ghostTechId, commander, ignoreChecks)
                    validLeftUp = moveRay(    -1 * layer,  -1 * layer, ghostTechId, commander, ignoreChecks)
                    validLeftDown = moveRay(  -1 * layer,  1 * layer, ghostTechId, commander, ignoreChecks)

                    if (validRightUp or validRightDown or validLeftUp or validLeftDown) then 
                        -- check neighbours at layer 1
                        layer = 1
                        if validRightUp or validRightDown then
                            moveRay(   1 * layer,  0, ghostTechId, commander, ignoreChecks)
                        end
                        if validRightDown or validLeftDown then
                            moveRay(   0 ,  1 * layer, ghostTechId, commander, ignoreChecks)
                        end
                        if validLeftUp or validRightUp then
                            moveRay(   0,   -1 * layer, ghostTechId, commander, ignoreChecks)
                        end
                        if validLeftDown or validRightDown then
                            moveRay(  - 1 * layer,   0, ghostTechId, commander, ignoreChecks)
                        end
                    end
                end
            end
        end
        --=============================================================================


        if specifyingOrientation or (commander.shiftDown and isp_shift_enabled) then

            -- once shiftDown is released, this will force robo, pgs and sentries to be checked for an exit too while moving the blueprint
            if (commander.shiftDown and isp_shift_enabled) then 
                checkExitforValid = true
            end

            orientationAngle = GetSpecifiedOrientation(commander)
            ghostStructureValid, position, attachEntity, errorMessage = GetIsBuildLegal(ghostTechId, ghostStructureCoords.origin, orientationAngle, kStructureSnapRadius, commander)


            --===========================Slight snap to the right angle. Max 20 rays with -
            if ghostStructureValid == false and isp_orientation_enabled then 
                orientationAngle = math.round(orientationAngle*20) /20 -- number ends now with 0.05 to prevent jiggling
                local index = 0
                local lastValidAngle = false

                while index <= 0.5 do
                    index = index + 0.05 
                    
                    ghostStructureValid = GetIsBuildLegal(ghostTechId, ghostStructureCoords.origin, orientationAngle + index, kStructureSnapRadius, commander)
                    if ghostStructureValid then 
                        orientationAngle = orientationAngle + index 
                        break 
                    end 
                    
                    ghostStructureValid = GetIsBuildLegal(ghostTechId, ghostStructureCoords.origin, orientationAngle - index, kStructureSnapRadius, commander)
                    if ghostStructureValid then 
                        orientationAngle = orientationAngle - index 
                        break 
                    end 
                end
            end
            --========================


            -- Preserve position, but update angle from mouse.
            local angles = Angles(0, orientationAngle, 0)
        
            local coordis = Coords.GetLookIn(ghostStructureCoords.origin, angles:GetCoords().zAxis)
            ghostStructureCoords = coordis -- updates the direction cone when rotating
            return coordis
            
        else


            local trace = GetCommanderPickTarget(commander, normalizedPickRay, false, true, nil, LookupTechData( ghostTechId, kCommanderSelectRadius ), "ray")

            if trace.fraction < 1 then

                
                local ignoreChecks
                -- this should force the robo, pg, sentry to check its exit if shift was pressed on the current blueprint
                if checkExitforValid then 
                    ignoreChecks = nil
                else 
                    -- We only want to do the "ValidExit" check after picking a location for a structure requiring a valid exit.
                    ignoreChecks = LookupTechData(ghostTechId, kTechDataSpecifyOrientation, false) and kIgnoreValidExitCheck or nil
                end


                --the usual structure placement check
                ghostStructureValid, position, attachEntity, errorMessage = GetIsBuildLegal(ghostTechId, trace.endPoint, orientationAngle, kStructureSnapRadius, commander, nil, ignoreChecks)

 
                -- if ray is not valid, try 10-15 alternative mouse positions
                if not ghostStructureValid and GetImprovedPlacingEnabled(ghostTechId) then
                    raySearch(ghostTechId, commander, ignoreChecks)
                end

                if trace.entity then
                    ghostStructureTargetId = trace.entity:GetId()
                else
                    ghostStructureTargetId = Entity.invalidId
                end

                if attachEntity then

                    coords = attachEntity:GetAngles():GetCoords()
                    local spawnHeight = LookupTechData(ghostTechId, kTechDataSpawnHeightOffset, 0)
                    coords.origin = position + Vector(0, spawnHeight, 0)

                else
                    local spawnHeight = LookupTechData(ghostTechId, kTechDataSpawnHeightOffset, 0)
                    coords.origin = position
                end

                local coordsMethod = LookupTechData(ghostTechId, kTechDataOverrideCoordsMethod, nil)

                if coordsMethod then
                    coords = coordsMethod(coords, ghostTechId, ghostStructureTargetId )
                end


                local angles = Angles(0, orientationAngle, 0)
                coords = Coords.GetLookIn(coords.origin, angles:GetCoords().zAxis)

                ghostStructureCoords = coords

            else
                ghostStructureCoords = nil
            end


            -- dont move structures if shift is pressed. We only rotate them
            if not (commander.shiftDown and isp_shift_enabled) then 
                ghostNormalizedPickRay = normalizedPickRay
            end 
        end

    end
    return ghostStructureCoords

end


function CommanderGhostStructureLeftMouseButtonDown(x, y)

    if ghostStructureValid and ghostStructureCoords ~= nil then

        local commander = Client.GetLocalPlayer()

        -- 2 step case for pg, robo and sentries. Place them down first and on second mouseDown lock their direction 
        -- gets skipped if the direction is already chosen with shiftkey or no direction needed
        if blueprintHasExit and not specifyingOrientation and not checkExitforValid then
            specifyingOrientation = true
        else

            -- If we're in a mode, clear it and handle it.
            local techNode = GetTechNode(ghostTechId)
            if techNode ~= nil and techNode:GetRequiresTarget() and techNode:GetAvailable() then

                
                -- be random if shiftkey isnt enabled, this is the actual angle which gets used once the blueprint is dropped
                if not isp_shift_enabled  and not specifyingOrientation then 
                    orientationAngle = math.random() * 2 * math.pi
                end
            
                local currentPickVec = (ghostStructureCoords.origin - commander:GetOrigin()):GetUnit()

                -- Using a stored normalized pick ray
                -- because the player may have moved since dropping the sentry/gates/etc and orienting it.
                pickVec = blueprintHasExit and currentPickVec or ghostNormalizedPickRay
                commander:SendTargetedAction(ghostTechId, pickVec, orientationAngle, Shared.GetEntity(ghostStructureTargetId))

            end

            commander:SetCurrentTech(kTechId.None)

        end

    elseif errorMessage and string.len(errorMessage) > 0 and ghostStructureCoords ~= nil then
        Client.AddWorldMessage(kWorldTextMessageType.CommanderError, Locale.ResolveString(errorMessage), ghostStructureCoords.origin)
    end

end

--
-- This function needs to be called when the Commander tech changes.
-- This happens when the Commander clicks on a button for example.
--
function CommanderGhostStructureSetTech(techId)


    isp_alien_enabled = Client.GetOptionBoolean("isp_alien_enabled", true)
    isp_marine_enabled_2 = Client.GetOptionBoolean("isp_marine_enabled_2", true)
    isp_shift_enabled = Client.GetOptionBoolean("isp_shift_enabled", true)
    isp_orientation_enabled = Client.GetOptionBoolean("isp_orientation_enabled", true)


    assert(techId ~= nil)

    local techNode = GetTechNode(techId)
    local showGhost = false


    blueprintHasExit = false
    if LookupTechData(techId, kTechDataSpecifyOrientation) then
       blueprintHasExit = true
    end


    if techNode ~= nil then

        -- we want the usual boring 0 angle if not enabled
        -- dont randomize these techs, looks weird
        if not isp_shift_enabled or blueprintHasExit or techId == kTechId.Harvester or techId == kTechId.Extractor or techId == kTechId.Hive or techId == kTechId.CommandStation or techId == kTechId.MedPack then
            orientationAngle = 0 
        else
            orientationAngle = (math.random() * 2 * math.pi)
        end

        showGhost = not techNode:GetIsEnergyManufacture() and not techNode:GetIsManufacture() and not techNode:GetIsPlasmaManufacture()
                    and not techNode:GetIsResearch() and not techNode:GetIsUpgrade()

    end

    specifyingOrientation = false
    ghostStructureEnabled = showGhost and techId ~= kTechId.None and (LookupTechData(techId, kTechDataModel) ~= nil)
    ghostTechId = techId
    ghostStructureValid = false

    checkExitforValid = false

    GetCommanderGhostStructureCoords()

end
