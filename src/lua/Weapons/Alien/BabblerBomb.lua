Script.Load("lua/Weapons/Alien/Bomb.lua")

class 'BabblerBomb' (Bomb)

BabblerBomb.kMapName            = "babbler_bomb"
BabblerBomb.kModelName          = PrecacheAsset("models/alien/babbler/babbler_egg.model")
local kBomblerMaxNumber = 6
BabblerBomb.kRadius             = 0.5
local kUpdateMoveInterval = 0.3

local networkVars = { }

function BabblerBomb:GetProjectileModel()
    return BabblerBomb.kModelName
end 

if Server then

   -- Babblers are 0.25 wide. Give ourselves some wiggle room
    local kCheckDist = Babbler.kRadius + 0.25
    local kVerticalOffset = kCheckDist
    local kBabblerSpawnPoints =
    {
        Vector(kCheckDist, kVerticalOffset, kCheckDist),
        Vector(-kCheckDist, kVerticalOffset, -kCheckDist),
        Vector(0, kVerticalOffset, kCheckDist),
        Vector(0, kVerticalOffset, -kCheckDist),
        Vector(kCheckDist, kVerticalOffset, 0),
        Vector(-kCheckDist, kVerticalOffset, 0),    
    }
    local babblerExtents = Vector(0.1, 0.1, 0.1)
    
    function BabblerBomb:OnInitialized()
        self.timeCreated = Shared.GetTime()
    end

    function BabblerBomb:ProcessHit(targetHit, surface, normal)

        if self.detonated then return end
		
		local Babblers = GetEntitiesForTeamWithinRange("Babbler", self:GetTeamNumber(), self:GetOrigin(), 6)
		
		if #Babblers > 12 then return end
		
        local owner = self:GetOwner()
        local currentTime = Shared.GetTime()
        local ownerOk = not owner or (currentTime - self.timeCreated > 2)

        if not ownerOk and targetHit == owner then return end

        self.detonated = true
        self:SetModel(nil)
        self:TriggerEffects("babbler_hatch")
        self:TriggerEffects("babbler_bomb_hit")
        CreateExplosionDecals(self, "bilebomb_decal")

        local spawnCount = kBomblerMaxNumber
        local spawnPointIndex = 1
        local lastSuccessfulSpawnPoint = self:GetOrigin()

        for i = 1, spawnCount do
            local spawnPoint = nil

            for idx = spawnPointIndex, #kBabblerSpawnPoints do
                local candidate = self:GetOrigin() + kBabblerSpawnPoints[idx]
                if GetHasRoomForCapsule(Vector(0.1, 0.1, 0.1), candidate, CollisionRep.Move, PhysicsMask.AllButPCsAndRagdolls, self) then
                    spawnPoint = candidate
                    spawnPointIndex = idx + 1
                    break
                end
            end

            if not spawnPoint then
                spawnPoint = lastSuccessfulSpawnPoint
            end

            local babbler = CreateEntity(Babbler.kMapName, spawnPoint, self:GetTeamNumber())
            if babbler then
                babbler.babblerBombSpawned = true
               
                babbler:SetOwner(owner)
                babbler:SetMoveType(kBabblerMoveType.None)

                lastSuccessfulSpawnPoint = spawnPoint
                babbler:AddTimedCallback(babbler.MoveRandom, kUpdateMoveInterval + math.random() / 5)

                local targetPos = (targetHit and targetHit.GetEngagementPoint and targetHit:GetEngagementPoint()) or (targetHit and targetHit:GetOrigin()) or spawnPoint
                if targetHit and targetHit:GetIsAlive() then
                    babbler:SetMoveType(kBabblerMoveType.Attack, targetHit, targetPos)
                else
                    babbler:SetMoveType(kBabblerMoveType.Move, nil, spawnPoint)
                end

                babbler:AddTimedCallback(function()
                    if babbler:GetIsAlive() then
                        babbler:Kill()
                    end
                    return false
                end, 8)
            end
        end

        DestroyEntity(self)
    end
end

Shared.LinkClassToMap("BabblerBomb", BabblerBomb.kMapName, networkVars)