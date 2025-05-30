-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Hive_Client.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

function Hive:OnUpdate(deltaTime)

    CommandStructure.OnUpdate(self, deltaTime)
      
    -- Attach mist effect if we don't have one already
    local coords = self:GetCoords()
    local effectName = Hive.kIdleMistEffect
    
    if self:GetTechId() == kTechId.Hive then
        effectName = Hive.kIdleMistEffect
    end
    
    local isVisible = not self:GetIsCloaked() and self:GetIsAlive()
    
    self:AttachEffect(effectName, coords, Cinematic.Repeat_Endless)
    self:SetEffectVisible(effectName, isVisible)
    -- Disable other stuff :P
    self:SetEffectVisible(Hive.kSpecksEffect, isVisible)
    self:SetEffectVisible(Hive.kGlowEffect, isVisible)
    
    local locallyFirstSight = self:GetIsSighted() == true and self:GetIsSighted() ~= self.clientHiveSighted
    
    if locallyFirstSight then
    
        self.clientHiveSighted = true
        local techPoint = self:GetAttached()
        if techPoint then
            techPoint:SetSmashScouted()
        end
        
    end
    
    if self:GetIsBuilt() then
        self.glowIntensity = math.min(3, self.glowIntensity + deltaTime)
    end
    
end

function Hive:OnUpdateRender()

	function Hive:GetShowElectrifyEffect()
		return self.electrified
	end

    PROFILE("Hive:OnUpdateRender")

    CommandStructure.OnUpdateRender(self)
    
    local model = self:GetRenderModel()
	local electrified = self:GetShowElectrifyEffect()
	
    if model then
        model:SetMaterialParameter("glowIntensity", self.glowIntensity)
        model:SetMaterialParameter("bioMassLevel", self.bioMassLevel)   
    end
    
	if model then
		if self.electrifiedClient ~= electrified then
		
			if electrified then
				self.electrifiedMaterial = AddMaterial(model, Alien.kElectrifiedThirdpersonMaterialName)
				self.electrifiedMaterial:SetParameter("elecAmount",  1.5)
			else
				if RemoveMaterial(model, self.electrifiedMaterial) then
					self.electrifiedMaterial = nil
				end
			end
			self.electrifiedClient = electrified
		end
	end	
end

function Hive:GetInfestationNumBlobSplats()
    return 5
end

