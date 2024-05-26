Script.Load("lua/Weapons/Alien/BileBomb.lua")
Script.Load("lua/BabblerBomb/BabblerBomb.lua")

class 'BabblerBombAbility' (BileBomb)

BabblerBombAbility.kMapName = "babbler_bomb_ability"

local kPlayerVelocityFraction = kBilebombPlayerVelocityFraction
local kBombVelocity = kBabblerBombVelocity

local kBbombViewEffect = PrecacheAsset("cinematics/alien/gorge/bbomb_1p.cinematic")
local kPheromoneTraceWidth = 0.3
local networkVars = {}


local function CreateBombProjectile( self, player )
    
    if not Predict then
        
        -- little bit of a hack to prevent exploitey behavior.  Prevent gorges from bile bombing
        -- through clogs they are trapped inside.
        local startPoint
        local startVelocity
        if GetIsPointInsideClogs(player:GetEyePos()) then
            startPoint = player:GetEyePos()
            startVelocity = Vector(0,0,0)
        else
            local viewCoords = player:GetViewAngles():GetCoords()
            startPoint = player:GetEyePos() + viewCoords.zAxis * 1.5
            startVelocity = viewCoords.zAxis * kBabblerBombVelocity
            
            local startPointTrace = Shared.TraceRay(player:GetEyePos(), startPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOneAndIsa(player, "Bombler"))
            
            startPoint = startPointTrace.endPoint
        end
        
        player:CreatePredictedProjectile( "BabblerBomb", startPoint, startVelocity, 0, 0, nil )
        
    end
    
end


function BabblerBombAbility:OnTag(tagName)

    PROFILE("BabblerBombAbility:OnTag")
    if self.firingPrimary and tagName == "shoot" then
    
        local player = self:GetParent()
        
        if player then
        
			if Server or (Client and Client.GetIsControllingPlayer()) then
                CreateBombProjectile(self, player)
            end
            
            player:DeductAbilityEnergy(self:GetEnergyCost(player))            

			self.timeLastBileBomb = Shared.GetTime()
            self:TriggerEffects("babbler_bomb_fire")
            
            if Client then
            
                local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
                cinematic:SetCinematic(kBbombViewEffect)
                
            end
            
		
        end
    
    end
    
end

function BabblerBombAbility:GetDeathIconIndex()
    return kDeathMessageIcon.Babbler
end

function BabblerBombAbility:GetHUDSlot()
    return 5
end

function BabblerBombAbility:GetPrimaryAttackAllowed()
    return not self:GetParent():GetIsBellySliding() and (self.timeLastBileBomb + (kTimeBetweenBabblerBombShots) < Shared.GetTime()) 
end

function BabblerBombAbility:OnPrimaryAttack(player)
   
    if self:GetPrimaryAttackAllowed() and player:GetEnergy() >= self:GetEnergyCost(player)   then
        self.firingPrimary = true
		self.timeLastBileBomb = Shared.GetTime()
    else
        self.firingPrimary = false
    end  
    
end

function BabblerBombAbility:OnPrimaryAttackEnd()
	
	Ability.OnPrimaryAttackEnd(self, player)

	self.firingPrimary = false
	
end



function BabblerBombAbility:GetEnergyCost(player)
    local energyMultiplier = 1
    return kBabblerBombEnergyCost * energyMultiplier
end

function BabblerBombAbility:GetCooldownFraction()
   
    local now = Shared.GetTime()
   	local timeSince = now - self.timeLastBileBomb
	 
    return 1 - Clamp(timeSince / kTimeBetweenBabblerBombShots, 0, 1)
end

Shared.LinkClassToMap("BabblerBombAbility", BabblerBombAbility.kMapName, networkVars)