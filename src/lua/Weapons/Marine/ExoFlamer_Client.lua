-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Flamethrower_Client.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) 
--
-- ========= For more information, visit us at http:--www.unknownworlds.com =====================

local kTrailLength = 9.5
local kImpactEffectRate = 0.3
local kSmokeEffectRate = 1.5
local kPilotEffectRate = 0.3

local kFlameImpactCinematic = PrecacheAsset("cinematics/marine/flamethrower/flame_impact3.cinematic")
local kFlameSmokeCinematic = PrecacheAsset("cinematics/marine/flamethrower/flame_trail_light.cinematic")
local kPilotCinematicName = PrecacheAsset("cinematics/marine/flamethrower/pilot.cinematic")

--[[local kFirstPersonTrailCinematics =
{
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part2.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part2.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part2.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part3.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part3.cinematic"),
}]]

local kTrailCinematics = {
    PrecacheAsset("cinematics/modularexo/blowtorch_trail_part1.cinematic"),
    PrecacheAsset("cinematics/modularexo/blowtorch_trail_part2.cinematic"),
    PrecacheAsset("cinematics/modularexo/blowtorch_trail_part2.cinematic"),
    PrecacheAsset("cinematics/modularexo/blowtorch_trail_part2.cinematic"),
    PrecacheAsset("cinematics/modularexo/blowtorch_trail_part2.cinematic"),
}

local kFirstPersonTrailCinematics = {
    PrecacheAsset("cinematics/modularexo/blowtorch_trail_part1.cinematic"),
    PrecacheAsset("cinematics/modularexo/blowtorch_trail_part2.cinematic"),
    PrecacheAsset("cinematics/modularexo/blowtorch_trail_part2.cinematic"),
    PrecacheAsset("cinematics/modularexo/blowtorch_trail_part2.cinematic"),
    PrecacheAsset("cinematics/modularexo/blowtorch_trail_part2.cinematic"),
    PrecacheAsset("cinematics/modularexo/blowtorch_trail_part2.cinematic"),
}

local kFadeOutCinematicNames = {
    PrecacheAsset("cinematics/marine/flamethrower/flame_residue_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_residue_1p_part2.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_residue_1p_part2.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_residue_1p_part3.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_residue_1p_part3.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_residue_1p_part3.cinematic"),
}

local function UpdateSound(self)
    
    -- Only update when held in inventory
    if self.loopingSoundEntId ~= Entity.invalidId and self:GetParent() ~= nil then
        
        local player = Client.GetLocalPlayer()
        local viewAngles = player:GetViewAngles()
        local yaw = viewAngles.yaw
        
        local soundEnt = Shared.GetEntity(self.loopingSoundEntId)
        if soundEnt then
            
            if soundEnt:GetIsPlaying() and self.lastYaw ~= nil then
                
                -- 180 degree rotation = param of 1
                local rotateParam = math.abs((yaw - self.lastYaw) / math.pi)
                
                -- Use the maximum rotation we've set in the past short interval
                if not self.maxRotate or (rotateParam > self.maxRotate) then
                    
                    self.maxRotate = rotateParam
                    self.timeOfMaxRotate = Shared.GetTime()
                
                end
                
                if self.timeOfMaxRotate ~= nil and Shared.GetTime() > self.timeOfMaxRotate + .75 then
                    
                    self.maxRotate = nil
                    self.timeOfMaxRotate = nil
                
                end
                
                if self.maxRotate ~= nil then
                    rotateParam = math.max(rotateParam, self.maxRotate)
                end
                
                soundEnt:SetParameter("rotate", rotateParam, 1)
            
            end
        
        else
            Print("Flamethrower:OnUpdate(): Couldn't find sound ent on client")
        end
        
        self.lastYaw = yaw
    
    end

end

function ExoFlamer:OnUpdate(deltaTime)
    
    Entity.OnUpdate(self, deltaTime)
    
    UpdateSound(self)

end

function ExoFlamer:ProcessMoveOnWeapon(input)
    
    Entity.ProcessMoveOnWeapon(self, input)
    
    UpdateSound(self)

end

function ExoFlamer:OnProcessSpectate(deltaTime)
    
    Entity.OnProcessSpectate(self, deltaTime)
    
    UpdateSound(self)

end

function UpdatePilotEffect(self, visible)
    
    if visible then
        
        if not self.pilotCinematic then
            
            self.pilotCinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
            self.pilotCinematic:SetCinematic(kPilotCinematicName)
            self.pilotCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
        
        end
        
        local viewModelEnt = self:GetParent():GetViewModelEntity()
        local renderModel = viewModelEnt and viewModelEnt:GetRenderModel()
        
        if renderModel then
            
            local attachPointIndex = viewModelEnt:GetAttachPointIndex("fxnode_rrailgunmuzzle")
            
            if attachPointIndex >= 0 then
                
                local attachCoords = viewModelEnt:GetAttachPointCoords("fxnode_rrailgunmuzzle")
                self.pilotCinematic:SetCoords(attachCoords)
            
            end
        
        end
    
    else
        
        if self.pilotCinematic then
            Client.DestroyCinematic(self.pilotCinematic)
            self.pilotCinematic = nil
        end
    
    end

end

local kEffectType = enum({ 'FirstPerson', 'ThirdPerson', 'None' })

function ExoFlamer:OnUpdateRender()
    -- Entity.OnUpdateRender(self)
    local parent = self:GetParent()
    local localPlayer = Client.GetLocalPlayer()
    
    if parent and parent:GetIsLocalPlayer() then
        local viewModel = parent:GetViewModelEntity()
        if viewModel and viewModel:GetRenderModel() then
            viewModel:InstanceMaterials()
            viewModel:GetRenderModel():SetMaterialParameter("heatAmount" .. self:GetExoWeaponSlotName(), self.heatAmount)
        end
        local heatDisplayUI = self.heatDisplayUI
        if not heatDisplayUI then
            heatDisplayUI = Client.CreateGUIView(242, 720)
            heatDisplayUI:Load("lua/GUI" .. self:GetExoWeaponSlotName():gsub("^%l", string.upper) .. "FlamerDisplay.lua")
            heatDisplayUI:SetTargetTexture("*exo_railgun_" .. self:GetExoWeaponSlotName())
            self.heatDisplayUI = heatDisplayUI
        end
        heatDisplayUI:SetGlobal("heatAmount" .. self:GetExoWeaponSlotName(), self.heatAmount)
    else
        if self.heatDisplayUI then
            Client.DestroyGUIView(self.heatDisplayUI)
            self.heatDisplayUI = nil
        end
    end
    
    local effectToLoad = (parent ~= nil and localPlayer ~= nil and parent == localPlayer and localPlayer:GetIsFirstPerson()) and kEffectType.FirstPerson or kEffectType.ThirdPerson
    if self.effectLoaded ~= effectToLoad then
        if self.trailCinematic then
            Client.DestroyTrailCinematic(self.trailCinematic)
            self.trailCinematic = nil
        end
        if effectToLoad ~= kEffectType.None then
            self:InitTrailCinematic(effectToLoad, parent)
        end
        self.effectLoaded = effectToLoad
    end
    if self.trailCinematic then
        self.trailCinematic:SetIsVisible(self.createParticleEffects == true)
        --if self.createParticleEffects then
        --    self:CreateImpactEffect(self:GetParent())
        --end
    end
    -- UpdatePilotEffect(self, effectToLoad == kEffectType.FirstPerson and self.clip > 0 and self:GetIsActive())
end

function ExoFlamer:InitTrailCinematic(effectType, player)
    
    self.trailCinematic = Client.CreateTrailCinematic(RenderScene.Zone_Default)
    
    local minHardeningValue = 0.5
    local numFlameSegments = 30
    
    if effectType == kEffectType.FirstPerson then
        
        self.trailCinematic:SetCinematicNames(kFirstPersonTrailCinematics)
        -- set an attach function which returns the player view coords if we are the local player 
        
        if self:GetIsRightSlot() then
            self.trailCinematic:AttachToFunc(self, TRAIL_ALIGN_Z, Vector(-0.7, -0.19, 1.45),
                                             function(attachedEntity, deltaTime)
                                                 local player = attachedEntity:GetParent()
                                                 return player ~= nil and player:GetViewCoords()
                                             end
            )
        
        elseif self:GetIsLeftSlot() then
            self.trailCinematic:AttachToFunc(self, TRAIL_ALIGN_Z, Vector(0.7, -0.19, 1.45),
                                             function(attachedEntity, deltaTime)
                                                 local player = attachedEntity:GetParent()
                                                 return player ~= nil and player:GetViewCoords()
                                             end
            )
        end
    
    elseif effectType == kEffectType.ThirdPerson then
        
        self.trailCinematic:SetCinematicNames(kTrailCinematics)
        
        if self:GetIsLeftSlot() then
            
            -- attach to third person fx node otherwise with an X offset since we align it along the X-Axis (the attackpoint is oriented in the model like that)
            self.trailCinematic:AttachTo(player, TRAIL_ALIGN_X, Vector(0.8, 0, 0), player:GetAttachPointIndex("fxnode_lrailgunmuzzle"))
            minHardeningValue = 0.1
            numFlameSegments = 16
        
        elseif self:GetIsRightSlot() then
            
            -- attach to third person fx node otherwise with an X offset since we align it along the X-Axis (the attackpoint is oriented in the model like that)
            self.trailCinematic:AttachTo(player, TRAIL_ALIGN_X, Vector(0.8, 0, 0), player:GetAttachPointIndex("fxnode_rrailgunmuzzle"))
            minHardeningValue = 0.1
            numFlameSegments = 16
        end
    
    end
    
    --self.trailCinematic:SetFadeOutCinematicNames(kFadeOutCinematicNames)
    self.trailCinematic:SetIsVisible(false)
    self.trailCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
    self.trailCinematic:SetOptions({
                                       numSegments              = numFlameSegments,
                                       collidesWithWorld        = true,
                                       visibilityChangeDuration = 0.2,
                                       fadeOutCinematics        = true,
                                       stretchTrail             = false,
                                       trailLength              = kExoFlamerTrailLength,
                                       minHardening             = minHardeningValue,
                                       maxHardening             = 2,
                                       hardeningModifier        = 0.8,
                                       trailWeight              = 0.2
                                   })

end

function ExoFlamer:CreateImpactEffect(player)
    
    if (not self.timeLastImpactEffect or self.timeLastImpactEffect + kImpactEffectRate < Shared.GetTime()) and player then
        
        self.timeLastImpactEffect = Shared.GetTime()
        
        local viewAngles = player:GetViewAngles()
        local viewCoords = viewAngles:GetCoords()
        
        viewCoords.origin = self:GetBarrelPoint(player) + viewCoords.zAxis * (-0.4) + viewCoords.xAxis * (-0.2)
        local endPoint = self:GetBarrelPoint(player) + viewCoords.xAxis * (-0.2) + viewCoords.yAxis * (-0.3) + viewCoords.zAxis * self:GetRange()
        
        local trace = Shared.TraceRay(viewCoords.origin, endPoint, CollisionRep.Default, PhysicsMask.Flame, EntityFilterAll())
        
        local range = (trace.endPoint - viewCoords.origin):GetLength()
        if range < 0 then
            range = range * (-1)
        end
        
        if trace.endPoint ~= endPoint and trace.entity == nil then
            
            local angles = Angles(0, 0, 0)
            angles.yaw = GetYawFromVector(trace.normal)
            angles.pitch = GetPitchFromVector(trace.normal) + (math.pi / 2)
            
            local normalCoords = angles:GetCoords()
            normalCoords.origin = trace.endPoint
            
            Shared.CreateEffect(nil, kFlameImpactCinematic, nil, normalCoords)
        
        end
    
    end

end

function ExoFlamer:OnProcessMove(input)

	Entity.OnProcessMove(self, input)
	
	local player = self:GetParent()
	
	if player then

		local eyePos = player:GetEyePos()
		local DamageEnts = {}
		local WeldingEnts = {}
		local count = 0
		local kTraceOrder = { 4, 1, 3, 5, 7, 0, 2, 6, 8 }
		
		local coords = player:GetViewAngles():GetCoords()
		local fireDirection = player:GetViewCoords().zAxis
		local extents = Vector(kExoFlamerConeWidth/6, kExoFlamerConeWidth/6, kExoFlamerConeWidth/6)
		local range = self:GetRange()
		local damageHeight = self.kDamageRadius / 2
		
		local startPoint = Vector(eyePos)
		local filterEnts = EntityFilterAllButMixin("BlowtorchTarget")
		
		self.blowtorchTargetId = {}
		
		for _, pointIndex in ipairs(kTraceOrder) do

			local dx = pointIndex % 3 - 1
			local dy = math.floor(pointIndex / 3) - 1
			local point = eyePos + coords.xAxis * (dx * kExoFlamerConeWidth / 3) + coords.yAxis * (dy * kExoFlamerConeWidth / 3)
			local trace = TraceMeleeBox(self, point, fireDirection, extents, range, PhysicsMask.Flame, filterEnts)
		
			local endPoint = trace.endPoint
			local normal = trace.normal
		
			if trace.fraction < 1 then
				
				local traceEnt = trace.entity
				if traceEnt and HasMixin(traceEnt, "Live") and traceEnt:GetCanTakeDamage() and traceEnt:GetTeamNumber() ~= self:GetTeamNumber() then
					if not table.find(DamageEnts, traceEnt) then
						table.insert(DamageEnts, traceEnt)
						table.insert(self.blowtorchTargetId, traceEnt:GetId())
					end
				end
				
				if traceEnt and HasMixin(traceEnt, "Live") and HasMixin(traceEnt, "Weldable") and traceEnt:GetTeamNumber() == self:GetTeamNumber() then
					if not table.find(WeldingEnts, traceEnt) and traceEnt:GetHealthScalar() < 1 then
						table.insert(WeldingEnts, traceEnt)
						table.insert(self.blowtorchTargetId, traceEnt:GetId())
					end
				end
			end
		end
		
		for i = 1, #DamageEnts do
			local Ent = DamageEnts[i]
			Ent:SetBlowtorchTargetDamage()
		end
		
		for i = 1, #WeldingEnts do
			local Ent = WeldingEnts[i]
			Ent:SetBlowtorchTargetWeld()
		end

	end
end

function ExoFlamer:GetTargetId()
	return self.blowtorchTargetId
end

--[[ disabled, causes bad performance
function ExoFlamer:CreateSmokeEffect(player)

    if not self.timeLastLightningEffect or self.timeLastLightningEffect + kSmokeEffectRate < Shared.GetTime() then
    
        self.timeLastLightningEffect = Shared.GetTime()
        
        local viewAngles = player:GetViewAngles()
        local viewCoords = viewAngles:GetCoords()
        
        viewCoords.origin = self:GetBarrelPoint(player) + viewCoords.zAxis * 1 + viewCoords.xAxis * (-0.4) + viewCoords.yAxis * (-0.3)
        
        local cinematic = kFlameSmokeCinematic
        
        local effect = Client.CreateCinematic(RenderScene.Zone_Default)    
        effect:SetCinematic(cinematic)
        effect:SetCoords(viewCoords)
        
    end

end
]]


