-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Marine_Client.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Marine.kBuyMenuTexture = "ui/marine_buymenu.dds"
Marine.kBuyMenuUpgradesTexture = "ui/marine_buymenu_upgrades.dds"
Marine.kBuyMenuiconsTexture = "ui/marine_buy_icons.dds"

Marine.kInfestationFootstepCinematic = PrecacheAsset("cinematics/marine/infestation_footstep.cinematic")
Marine.kSpitHitCinematic = PrecacheAsset("cinematics/marine/spit_hit_1p.cinematic")

PrecacheAsset("cinematics/vfx_materials/rupture.surface_shader")
PrecacheAsset("cinematics/vfx_materials/marine_highlight.surface_shader")
local kRuptureMaterial = PrecacheAsset("cinematics/vfx_materials/rupture.material")
local kHighlightMaterial = PrecacheAsset("cinematics/vfx_materials/marine_highlight.material")

Marine.kSpitHitEffectDuration = 1
Marine.kBigMacFirstPersonDeathEffect = PrecacheAsset("cinematics/marine/bigmac/death_1p.cinematic")

local kSensorBlipSize = 25

function Marine:GetHealthbarOffset()
    return 1.2
end

function MarineUI_GetHasArmsLab()

    local player = Client.GetLocalPlayer()
    
    if player then
        return GetHasTech(player, kTechId.ArmsLab)
    end
    
    return false
    
end

function PlayerUI_GetSensorBlipInfo()

    PROFILE("PlayerUI_GetSensorBlipInfo")
    
    local player = Client.GetLocalPlayer()
    local blips = {}
    
    if player and GetHasTech(player, kTechId.AdvancedObservatory) then
    
        local eyePos = player:GetEyePos()
        for _, blip in ientitylist(Shared.GetEntitiesWithClassname("SensorBlip")) do
        
            local blipOrigin = blip:GetOrigin()
            local blipEntId = blip.entId
            local blipName = ""
            
			local IsAdvObservatory = false
			for _, Obs in ipairs(GetEntitiesWithinRange("Observatory", blipOrigin, Observatory.kDetectionRange)) do
				if Obs:GetTechId() == kTechId.AdvancedObservatory then
					IsAdvObservatory = true
				end
			end 

            -- Lookup more recent position of blip
            local blipEntity = Shared.GetEntity(blipEntId)
            
            -- Do not display a blip for the local player.
            if blipEntity ~= player then

                if blipEntity then
                
                    if blipEntity:isa("Player") then
                        blipName = Scoreboard_GetPlayerData(blipEntity:GetClientIndex(), kScoreboardDataIndexName)
                    elseif blipEntity.GetTechId then
                        blipName = GetDisplayNameForTechId(blipEntity:GetTechId())
                    end
                    
                end
                
                if not blipName then
                    blipName = ""
                end
                
                -- Get direction to blip. If off-screen, don't render. Bad values are generated if
                -- Client.WorldToScreen is called on a point behind the camera.
                local normToEntityVec = GetNormalizedVector(blipOrigin - eyePos)
                local normViewVec = player:GetViewAngles():GetCoords().zAxis
               
                local dotProduct = normToEntityVec:DotProduct(normViewVec)
                if dotProduct > 0 and IsAdvObservatory then
                
                    -- Get distance to blip and determine radius
                    local distance = (eyePos - blipOrigin):GetLength()
                    local drawRadius = kSensorBlipSize/distance
                    
                    -- Compute screen xy to draw blip
                    local screenPos = Client.WorldToScreen(blipOrigin)

                    --[[
                    local trace = Shared.TraceRay(eyePos, blipOrigin, CollisionRep.LOS, PhysicsMask.Bullets, EntityFilterTwo(player, entity))                               
                    local obstructed = ((trace.fraction ~= 1) and ((trace.entity == nil) or trace.entity:isa("Door"))) 
                    
                    if not obstructed and entity and not entity:GetIsVisible() then
                        obstructed = true
                    end
                    --]]
                    
                    -- Add to array (update numElementsPerBlip in GUISensorBlips:UpdateBlipList)
                    table.insert(blips, screenPos.x)
                    table.insert(blips, screenPos.y)
                    table.insert(blips, drawRadius)
                    table.insert(blips, true)
                    table.insert(blips, blipName)

                end
                
            end
            
        end
    
    end
    
    return blips
    
end

function Marine:UnitStatusPercentage()
    return self.unitStatusPercentage
end

local function TriggerSpitHitEffect(coords)

    local spitCinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
    spitCinematic:SetCinematic(Marine.kSpitHitCinematic)
    spitCinematic:SetRepeatStyle(Cinematic.Repeat_None)
    spitCinematic:SetCoords(coords)
    
end

local function UpdatePoisonedEffect(self)

    local feedbackUI = ClientUI.GetScript("GUIPoisonedFeedback")
    if self.poisoned and self:GetIsAlive() and feedbackUI and not feedbackUI:GetIsAnimating() then
        feedbackUI:TriggerPoisonEffect()
    end
    
end

function Marine:UpdateClientEffects(deltaTime, isLocal)
    
    Player.UpdateClientEffects(self, deltaTime, isLocal)
    
    if isLocal then
    
        Client.SetMouseSensitivityScalar(ConditionalValue(self:GetIsStunned(), 0, 1))
        
        self:UpdateGhostModel()
        
        UpdatePoisonedEffect(self)
        
        if self.lastAliveClient ~= self:GetIsAlive() then
            ClientUI.SetScriptVisibility("Hud/Marine/GUIMarineHUD", "Alive", self:GetIsAlive())
            self.lastAliveClient = self:GetIsAlive()
        end
        
        if self.buyMenu then
        
            if not self:GetIsAlive() or not GetIsCloseToMenuStructure(self) or self:GetIsStunned() then
                self:CloseMenu()
            end
            
        end    
        
        if Player.screenEffects.disorient then
            Player.screenEffects.disorient:SetParameter("time", Client.GetTime())
        end
        
        local stunned = HasMixin(self, "Stun") and self:GetIsStunned()
        local blurEnabled = self.buyMenu ~= nil or stunned or (self.viewingHelpScreen == true)
        self:SetBlurEnabled(blurEnabled)
        
        -- update spit hit effect
        if not Shared.GetIsRunningPrediction() then
        
            if self.timeLastSpitHit ~= self.timeLastSpitHitEffect then
            
                local viewAngle = self:GetViewAngles()
                local angleDirection = Angles(GetPitchFromVector(self.lastSpitDirection), GetYawFromVector(self.lastSpitDirection), 0)
                angleDirection.yaw = GetAnglesDifference(viewAngle.yaw, angleDirection.yaw)
                angleDirection.pitch = GetAnglesDifference(viewAngle.pitch, angleDirection.pitch)
                
                TriggerSpitHitEffect(angleDirection:GetCoords())
                
                local intensity = self.lastSpitDirection:DotProduct(self:GetViewCoords().zAxis)
                self.spitEffectIntensity = intensity
                self.timeLastSpitHitEffect = self.timeLastSpitHit
                
            end
            
        end
        
        local spitHitDuration = Shared.GetTime() - self.timeLastSpitHitEffect
        
        if Player.screenEffects.disorient and self.timeLastSpitHitEffect ~= 0 and spitHitDuration <= Marine.kSpitHitEffectDuration then
        
            Player.screenEffects.disorient:SetActive(true)
            local amount = (1 - ( spitHitDuration/Marine.kSpitHitEffectDuration) ) * 3.5 * self.spitEffectIntensity
            Player.screenEffects.disorient:SetParameter("amount", amount)
            
        end
        
    end
    
    if self._renderModel then

        if self.ruptured and not self.ruptureMaterial then

            local material = Client.CreateRenderMaterial()
            material:SetMaterial(kRuptureMaterial)

            local viewMaterial = Client.CreateRenderMaterial()
            viewMaterial:SetMaterial(kRuptureMaterial)
            
            self.ruptureEntities = {}
            self.ruptureMaterial = material
            self.ruptureMaterialViewMaterial = viewMaterial
            AddMaterialEffect(self, material, viewMaterial, self.ruptureEntities)
        
        elseif not self.ruptured and self.ruptureMaterial then

            RemoveMaterialEffect(self.ruptureEntities, self.ruptureMaterial, self.ruptureMaterialViewMaterial)
            Client.DestroyRenderMaterial(self.ruptureMaterial)
            Client.DestroyRenderMaterial(self.ruptureMaterialViewMaterial)
            self.ruptureMaterial = nil
            self.ruptureMaterialViewMaterial = nil
            self.ruptureEntities = nil
            
        end
        
    end
    
    
end

--[=[
local gFlashlightDefault = 
{
    intensity = 10,
    outrad = math.rad(36),
    inrad = math.rad(24),
    shadows = 0,
    shadfade = 0.25,
    specular = 1,
    atmod = 0.025,
    dist = 22,
    color = Color(0.8, 0.8, 1),
    goboFile = PrecacheAsset("models/marine/male/flashlight.dds")
}

local gActiveFlashlightData = 
{
    intensity = gFlashlightDefault.intensity,
    outrad = gFlashlightDefault.outrad,
    inrad = gFlashlightDefault.inrad,
    shadows = gFlashlightDefault.shadows,
    shadfade = gFlashlightDefault.shadfade,
    specular = gFlashlightDefault.specular,
    atmod = gFlashlightDefault.atmod,
    dist = gFlashlightDefault.dist,
    color = gFlashlightDefault.color,
    gobo = gFlashlightDefault.goboFile
}

local gFlashlightDirty = false

local function TempFlashLightTune(part, amt)
    if not Shared.GetCheatsEnabled() then
        Log("This command requires cheats to function")
        return
    end

    if not part and not amt then
        Log("Marine Flashlights Tuning:")
        Log("  Options:")
        Log("\t intensity [0.0 - 30.0 float] - Sets the brightness of flashlights")
        Log("\t outrad [0.0 - 85.0 float] - Sets maximum radius of the outter bounds of the light")
        Log("\t inrad [0.0 - 85.0 float] - Sets maximum radius of the outter bounds of the light. Cannot exceed outter-radius")
        Log("\t dist [0.0 - 35.0 float] - Sets the maximum distance of the light. Anything beyond this value won't be illuminated")
        Log("\t shadows [0 or 1 integer] - Toggles shadow casting on/off. Default is OFF. Note: has negative performance impact when ON")
        Log("\t shadfade [0.0 - 1.0 float] - Sets distance factor for how quickly shadows fade out")
        Log("\t spec [0 or 1 integer] - Toggles specular lighting ON/OFF when flashlights illuminate anything with a specular map")
        Log("\t atmod [0.0 - 5.0 float] - Set the Atmospheric Density of flashlights. Higher means more 'fog'. Recommend using values incrementing in 0.005 steps")
        Log("\t color ([0-255,0-255,0-255]) - Sets the color of flashlight, but be in 0 to 255 RGB values, with parentheses! Note, text format is important here!")
        Log("\t gobo [string] - 'ns2' directory relative file path to gobo texture with file extension. Applying this disables Specular")
        Log("\n  examples: flashlight shadows 1\n  flashlights inrad 12.5")
        return
    end

    assert(part)
    assert( 
        part == "intensity" or 
        part == "outrad" or 
        part == "inrad" or 
        part == "shadows" or 
        part == "spec" or 
        part == "atmod" or
        part == "shadfade" or
        part == "dist" or
        part == "color" or
        part == "gobo"
    )

    if part ~= "color" and part ~= "gobo" then
        assert( type(tonumber(amt)) == "number" )
        amt = tonumber(amt)
    elseif part == "gobo" then
        if amt ~= nil then
            assert( type(tostring(amt) == "string") )
            assert( string.find(amt, '.dds') ~= nil )
            amt = tostring(amt)
        end
    end

    local player = Client.GetLocalPlayer()

    if not player or not ( player:isa("Marine") or player:isa("Exo") ) then
        Log("Failed to fetch local-player or not correct class")
        return
    end

    if part == "intensity" then
        if amt < 0 or amt > 30 then
            Log("Invalid intensity value, must be 0 - 30")
            return
        end
        Log("Set Flashlight Intensity to %s", amt)
        gActiveFlashlightData.intensity = amt

    elseif part == "outrad" then
        if player.flashlight:GetInnerCone() >= math.rad(amt) then
            Log("Cannot set Outer radius smaller or equal to Inner radius")
            return
        end
        Log("Set Flashlight Outer cone radius to %s", amt)
        gActiveFlashlightData.outrad = math.rad(amt)

    elseif part == "inrad" then
        if player.flashlight:GetOuterCone() <= math.rad(amt) then
            Log("Cannot set Inner radius geater or equal to Outer radius")
            return
        end
        Log("Set Flashlight Inner cone radius to %s", amt)
        gActiveFlashlightData.inrad = math.rad(amt)

    elseif part == "shadows" then
        local toggle = amt == 1
        Log("Set Flashlight Shadows to %s", toggle and "Enabled" or "Disabled")
        gActiveFlashlightData.shadows = toggle

    elseif part == "shadfade" then
        if amt < 0.01 or amt > 0.9 then
            Log("Invalid Shadow Fade Rate, allowed: 0 - 0.9")
            return
        end
        Log("Set Flashlight Shadow Fade-Rate to %s", amt)
        gActiveFlashlightData.shadfade = amt

    elseif part == "dist" then
        if amt < 1 or amt > 35 then
            Log("Invalid distance value, allow: 1 - 35")
        end
        Log("Set Flashlight max Distance to %s", amt)
        gActiveFlashlightData.dist = amt

    elseif part == "spec" then
        local toggle = amt == 1
        Log("Set Flashlight Specular to %s", toggle and "Enabled" or "Disabled")
        gActiveFlashlightData.specular = toggle

    elseif part == "atmod" then
        if amt < 0 or amt > 5 then
            Log("Invalid atmos-density value, allow: 0.0 - 5.0")
            return
        end
        Log("Set Flashlight Atmosheric-Density to %s", amt)
        gActiveFlashlightData.atmod = amt

    elseif part == "gobo" then
        if gActiveFlashlightData.goboFile == amt then
            Log("Duplicate gobo filename")
            return
        end

        if amt == nil then
            Log("  Removed Gobo Texture.\n Specular re-enabled")
            gActiveFlashlightData.goboFile = ""
            gActiveFlashlightData.specular = true
        else
            Log("  Set Gobo Texture to: %s \n Specular disabled, does not work with gobo", amt)
            gActiveFlashlightData.goboFile = amt
            gActiveFlashlightData.specular = false
        end

    elseif part == "color" then
        Log("\t\t %s", amt)
        local oPp = string.find( amt, '(', 1, true )
        Log("\t\t %s", oPp)
        local ePp = string.find( amt, ')', string.len(amt) - 1, true)
        Log("\t\t %s", oPp)
        if oPp == nil or ePp == nil then
            Log("Invalid format, Color value must be enclosed in parenthesis")
            return
        end

        local tV = string.sub( amt, oPp + 1, ePp - 1 )
        local cCs = StringSplit( tV, ',' )

        local newColor = Color()
        for _, cC in ipairs(cCs) do
            
            if _ == 1 then
                newColor.r = tonumber(cC) / 255
            elseif _ == 2 then
                newColor.g = tonumber(cC) / 255
            elseif _ == 3 then
                newColor.b = tonumber(cC) / 255
            else
                Log("Oh god, 4th dimensional Colors! We're all going to die!!!!!")
                return
            end
        end

        Log("Set Flashlight color to %s", newColor)
        gActiveFlashlightData.color = newColor
    end

    gFlashlightDirty = true
end
Event.Hook("Console_flashlight", TempFlashLightTune)

local function RestoreFlashlightDefault()
    Log("Reset Flashlight Properties")
    gActiveFlashlightData = nil
    gActiveFlashlightData = 
    {
        intensity = gFlashlightDefault.intensity,
        outrad = gFlashlightDefault.outrad,
        inrad = gFlashlightDefault.inrad,
        shadows = gFlashlightDefault.shadows,
        shadfade = gFlashlightDefault.shadfade,
        specular = gFlashlightDefault.specular,
        atmod = gFlashlightDefault.atmod,
        dist = gFlashlightDefault.dist,
        color = gFlashlightDefault.color,
        goboFile = ""
    }

    Log("  Intensity:      %s", gActiveFlashlightData.intensity)
    Log("  Distance:       %s", gActiveFlashlightData.dist)
    Log("  Outer Rad:      %s", math.deg(gActiveFlashlightData.outrad) )
    Log("  Inner Rad:      %s", math.deg(gActiveFlashlightData.inrad) )
    Log("  Shadows:        %s", gActiveFlashlightData.shadows)
    Log("  Shadow Fade:    %s", gActiveFlashlightData.shadfade)
    Log("  Specular:       %s", gActiveFlashlightData.specular)
    Log("  Atmo-Density:   %s", gActiveFlashlightData.atmod)
    Log("  Color:          %s", gActiveFlashlightData.color)
    Log("  GoboTexture:    %s", gActiveFlashlightData.goboFile)

    gFlashlightDirty = true
end
Event.Hook("Console_resetflashlight", RestoreFlashlightDefault)

local function DumpFlashlightSettings()
    if not Shared.GetCheatsEnabled() then
        Log("Command requires cheats")
        return
    end

    local player = Client.GetLocalPlayer()
    if not player or not ( player:isa("Marine") or player:isa("Exo") ) then
        Log("Failed to fetch local-player or not correct class")
        return
    end

    Log("Marine Flashlight Settings:")
    Log("  Intensity:      %s", player.flashlight:GetIntensity())
    Log("  Distance:       %s", player.flashlight:GetRadius())
    Log("  Outer Rad:      %s", math.deg(player.flashlight:GetOuterCone()) )
    Log("  Inner Rad:      %s", math.deg(player.flashlight:GetInnerCone()) )
    Log("  Shadows:        %s", player.flashlight:GetCastsShadows())
    Log("  Shadow Fade:    %s", player.flashlight:GetShadowFadeRate())
    Log("  Specular:       %s", player.flashlight:GetSpecular())
    Log("  Atmo-Density:   %s", player.flashlight:GetAtmosphericDensity())
    Log("  Color:          %s", player.flashlight:GetColor())
    --Log("  GoboTexture:    %s", player.flashlight:GetGoboTexture())
end
Event.Hook("Console_dumpflashlight", DumpFlashlightSettings)
--]=]

function Marine:OnUpdateRender()

    PROFILE("Marine:OnUpdateRender")
    
    Player.OnUpdateRender(self)
    
    local isLocal = self:GetIsLocalPlayer()
    
    -- Synchronize the state of the light representing the flash light.
    self.flashlight:SetIsVisible(self.flashlightOn and (isLocal or self:GetIsVisible()) )
    
    if self.flashlightOn then
        
        local angles = self:GetViewAnglesForRendering()
        local coords = angles:GetCoords()
        coords.origin = self:GetEyePos() + coords.zAxis * 0.75
        
        self.flashlight:SetCoords(coords)
        

        -- Only display atmospherics for third person players.
        local density = kDefaultMarineFlashlightAtmoDensity
        if isLocal and not self:GetIsThirdPerson() then
            density = 0
        end
        self.flashlight:SetAtmosphericDensity(density)
        
        --[=[
        if gFlashlightDirty then
            self.flashlight:SetIntensity( gActiveFlashlightData.intensity )
            self.flashlight:SetRadius( gActiveFlashlightData.dist )
            self.flashlight:SetOuterCone( gActiveFlashlightData.outrad )
            self.flashlight:SetInnerCone( gActiveFlashlightData.inrad )
            self.flashlight:SetCastsShadows( gActiveFlashlightData.shadows )
            self.flashlight:SetShadowFadeRate( gActiveFlashlightData.shadfade )
            self.flashlight:SetSpecular( gActiveFlashlightData.specular )
            self.flashlight:SetAtmosphericDensity( gActiveFlashlightData.atmod )
            self.flashlight:SetColor( gActiveFlashlightData.color )
            if gActiveFlashlightData.goboFile then
                self.flashlight:SetGoboTexture( gActiveFlashlightData.goboFile )
            end
            Log("--Updated Flashlight Properties--")
            gFlashlightDirty = false
        end
        --]=]

    end
    
    --[[ disabled for now
    local localPlayer = Client.GetLocalPlayer()
    local showHighlight = localPlayer ~= nil and localPlayer:isa("Alien") and self:GetIsAlive()
    local model = self:GetRenderModel()

    if model then
    
        if showHighlight and not self.marineHighlightMaterial then
            
            self.marineHighlightMaterial = AddMaterial(model, kHighlightMaterial)
            
        elseif not showHighlight and self.marineHighlightMaterial then
        
            RemoveMaterial(model, self.marineHighlightMaterial)
            self.marineHighlightMaterial = nil
        
        end
        
        if self.marineHighlightMaterial then
            self.marineHighlightMaterial:SetParameter("distance", (localPlayer:GetEyePos() - self:GetOrigin()):GetLength())
        end
    
    end
    --]]

end

function Marine:TriggerFootstep()

    Player.TriggerFootstep(self)
    
    if self:GetGameEffectMask(kGameEffect.OnInfestation) and self:GetIsSprinting() and self == Client.GetLocalPlayer() and not self:GetIsThirdPerson() then
    
        local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
        cinematic:SetRepeatStyle(Cinematic.Repeat_None)
        cinematic:SetCinematic(Marine.kInfestationFootstepCinematic)
    
    end

end

gCurrentHostStructureId = Entity.invalidId

function MarineUI_SetHostStructure(structure)

    if structure then
        gCurrentHostStructureId = structure:GetId()
    end    

end

function MarineUI_GetCurrentHostStructure()

    if gCurrentHostStructureId and gCurrentHostStructureId ~= Entity.invalidId then
        return Shared.GetEntity(gCurrentHostStructureId)
    end

    return nil    

end

-- Bring up buy menu
function Marine:BuyMenu(structure)
    
    -- Don't allow display in the ready room
    if self:GetTeamNumber() ~= 0 and Client.GetLocalPlayer() == self then
    
        if not self.buyMenu and
           not HelpScreen_GetHelpScreen():GetIsBeingDisplayed() and 
           not GetMainMenu():GetVisible() then
        
            self.buyMenu = GetGUIManager():CreateGUIScript("GUIMarineBuyMenu")
            
            MarineUI_SetHostStructure(structure)
            
            if structure then
                self.buyMenu:SetHostStructure(structure)
            end
            
            self:TriggerEffects("marine_buy_menu_open")
            
        end
        
    end
    
end

function Marine:UpdateMisc(input)

    Player.UpdateMisc(self, input)
    
    if not Shared.GetIsRunningPrediction() then

        if input.move.x ~= 0 or input.move.z ~= 0 then

            self:CloseMenu()
            
        end
        
    end
    
end

function Marine:OnCountDown()

    Player.OnCountDown(self)
    
    ClientUI.SetScriptVisibility("Hud/Marine/GUIMarineHUD", "Countdown", false)
    
end

function Marine:OnCountDownEnd()

    Player.OnCountDownEnd(self)
    
    ClientUI.SetScriptVisibility("Hud/Marine/GUIMarineHUD", "Countdown", true)
    
    local script = ClientUI.GetScript("Hud/Marine/GUIMarineHUD")
    if script then
        script:TriggerInitAnimations()
    end
    
end

function Marine:OnOrderSelfComplete(orderType)
    self:TriggerEffects(ConditionalValue(PlayerUI_GetTypeAutoOrderOrPheromone(orderType), "complete_autoorder", "complete_order"))
end

function Marine:GetSpeedDebugSpecial()
    return self:GetSprintTime() / SprintMixin.kMaxSprintTime
end

function Marine:UpdateGhostModel()

    self.currentTechId = nil
    self.ghostStructureCoords = nil
    self.ghostStructureValid = false
    self.showGhostModel = false
    
    local weapon = self:GetActiveWeapon()

    if weapon and weapon:isa("LayMines") then
    
        self.currentTechId = kTechId.Mine
        self.ghostStructureCoords = weapon:GetGhostModelCoords()
        self.ghostStructureValid = weapon:GetIsPlacementValid()
        self.showGhostModel = weapon:GetShowGhostModel()
    
    end

end

function Marine:GetShowGhostModel()
    return self.showGhostModel
end    

function Marine:GetGhostModelTechId()
    return self.currentTechId
end

function Marine:GetGhostModelCoords()
    return self.ghostStructureCoords
end

function Marine:GetIsPlacementValid()
    return self.ghostStructureValid
end

function Marine:GetFirstPersonDeathEffect()
    if self.marineType == kMarineVariantsBaseType.bigmac then
        return Marine.kBigMacFirstPersonDeathEffect
    end
    return (Player.GetFirstPersonDeathEffect(self))
end

function Marine:GetCanSeeConstructIcon(ofEntity)
    if ofEntity:isa("PowerPoint") then
        return ofEntity:HasUnbuiltConsumerRequiringPower()
    end

    return true
end
