Script.Load("lua/Weapons/Alien/BileBomb.lua")

class 'BabblerBombAbility' (BileBomb)

BabblerBombAbility.kMapName = "babbler_bomb_ability"

local kPlayerVelocityFraction = kBilebombPlayerVelocityFraction
local kBombVelocity = kBabblerBombVelocity
local kBabblerBombRechargeInterval = 6

local kBbombViewEffect = PrecacheAsset("cinematics/alien/gorge/bbomb_1p.cinematic")
local kPheromoneTraceWidth = 0.3
local networkVars = {

    remainingCharges = "integer (0 to 3)",
    lastChargeUsedTime = "time"
}

function BabblerBombAbility:OnCreate()

    BileBomb.OnCreate(self)
    self.timeLastBabblerBomb = 0
    self.remainingCharges = 0
    self.lastChargeUsedTime = Shared.GetTime()
    
    self:SetUpdates(true)
end


local function CreateBombProjectile( self, player )
    
    if not Predict then
        
        local startPoint
        local startVelocity
        if GetIsPointInsideClogs(player:GetEyePos()) then
            startPoint = player:GetEyePos()
            startVelocity = Vector(0,0,0)
        else
            local viewCoords = player:GetViewAngles():GetCoords()
            startPoint = player:GetEyePos() + viewCoords.zAxis * 1.5
            startVelocity = viewCoords.zAxis * kBabblerBombVelocity
            
            local startPointTrace = Shared.TraceRay(player:GetEyePos(), startPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOneAndIsa(player, "Babbler"))
            
            startPoint = startPointTrace.endPoint
        end
        
        player:CreatePredictedProjectile( "BabblerBomb", startPoint, startVelocity, 0, 0, nil )
        
    end
    
end

function BabblerBombAbility:OnPrimaryAttack(player)

    if not player then
        self.firingPrimary = false
        return
    end

    if self:GetPrimaryAttackAllowed() then
        self.firingPrimary = true
    else
        self.firingPrimary = false
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
			
            self:TriggerEffects("babbler_bomb_fire")

            if Client then
                local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
                cinematic:SetCinematic(kBbombViewEffect)
            end

            player:DeductAbilityEnergy(self:GetEnergyCost(player))
            self.remainingCharges = self.remainingCharges - 1
            self.lastChargeUsedTime = Shared.GetTime()
            self.timeLastBabblerBomb = Shared.GetTime()

        end
    end
    
end

function BabblerBombAbility:RechargeCharges()

    if not self.remainingCharges then
        self.remainingCharges = 3
        self.lastChargeUsedTime = Shared.GetTime()
    end

    if self.remainingCharges < self:GetMaxCharges() then
        local now = Shared.GetTime()
        local elapsed = now - self.lastChargeUsedTime
        local interval = self:GetRechargeInterval()
        local gained = math.floor(elapsed / interval)

        if gained > 0 then
            self.remainingCharges = math.min(self:GetMaxCharges(), self.remainingCharges + gained)
            self.lastChargeUsedTime = self.lastChargeUsedTime + gained * interval
        end
    end
end

function BabblerBombAbility:GetDeathIconIndex()
    return kDeathMessageIcon.Babbler
end

function BabblerBombAbility:GetTimeLastBabblerBomb()
    return self.timeLastBabblerBomb
end

function BabblerBombAbility:GetHUDSlot()
    return 5
end

function BabblerBombAbility:GetPrimaryAttackAllowed()

    local player = self:GetParent()
    if not player then return false end

    local isCooldownReady = Shared.GetTime() >= self.timeLastBabblerBomb + kTimeBetweenBabblerBombShots
    local hasEnoughEnergy = player:GetEnergy() >= self:GetEnergyCost(player)
    local hasCharges = self.remainingCharges > 0

    return not player:GetIsBellySliding() and isCooldownReady and hasEnoughEnergy and hasCharges
    
end

function BabblerBombAbility:OnPrimaryAttackEnd()
	
	Ability.OnPrimaryAttackEnd(self, player)

	self.firingPrimary = false
	
end

function BabblerBombAbility:GetRechargeInterval()
    return kBabblerBombRechargeInterval
end

function BabblerBombAbility:GetEnergyCost(player)
    local energyMultiplier = 1
    return kBabblerBombEnergyCost * energyMultiplier
end

function BabblerBombAbility:GetCurrentCharges()
    return self.remainingCharges
end

function BabblerBombAbility:GetMaxCharges()
    return 3
end

function BabblerBombAbility:GetCooldownFraction()
    local maxCharges = self:GetMaxCharges()
    local currentCharges = self:GetCurrentCharges()

    if currentCharges >= maxCharges then
        return 0
    end

    local now = Shared.GetTime()
    local rechargeInterval = self:GetRechargeInterval()
    local elapsed = now - self.lastChargeUsedTime

    return 1 - Clamp(elapsed / rechargeInterval, 0, 1)
end

Shared.LinkClassToMap("BabblerBombAbility", BabblerBombAbility.kMapName, networkVars)