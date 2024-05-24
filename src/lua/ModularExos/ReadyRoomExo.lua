function ReadyRoomExo:PerformEject()
    if Server and self:GetIsAlive() then
        
        -- pickupable version
        local exosuit = CreateEntity(Exosuit.kMapName, self:GetOrigin(), self:GetTeamNumber(), {
            -- powerModuleType    = self.powerModuleType   ,
            rightArmModuleType = self.rightArmModuleType,
            leftArmModuleType  = self.leftArmModuleType,
            utilityModuleType  = self.utilityModuleType,
            abilityModuleType  = self.abilityModuleType,
        })
        exosuit:SetCoords(self:GetCoords())
        exosuit:SetFlashlightOn(self:GetFlashlightOn())
        exosuit:SetExoVariant(self:GetExoVariant())
        exosuit:TriggerEffects("death")
        DestroyEntity(exosuit)
        
        
        local marine = self:Replace(self.prevPlayerMapName or Marine.kMapName, nil, nil, self:GetOrigin() + Vector(0, 0.2, 0) )
        marine.onGround = false
        local initialVelocity = self:GetViewCoords().zAxis
        initialVelocity:Scale(4)
        initialVelocity.y = 9
        marine:SetVelocity(initialVelocity)
        
        if marine:isa("JetpackMarine") then
            marine:SetFuel(0.25)
        end
    
    end
end

function ReadyRoomExo:InitExoModel()
    Exo.InitExoModel(self)
end