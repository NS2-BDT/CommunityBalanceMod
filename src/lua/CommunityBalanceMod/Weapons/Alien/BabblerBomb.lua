Script.Load("lua/Weapons/Alien/Bomb.lua")
Script.Load("lua/CommunityBalanceMod/Weapons/Alien/Bombler.lua")

class 'BabblerBomb' (Bomb)

BabblerBomb.kMapName            = "babbler_bomb"
BabblerBomb.kModelName          = PrecacheAsset("models/alien/babbler/babbler_egg.model")
kBomblerMaxNumber = 6
BabblerBomb.kRadius             = 0.5

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

        local ownerOk = false
        if (Shared.GetTime() - self.timeCreated) > 2 then
            ownerOk = true
        end
		
        if (ownerOk or (not self:GetOwner() or not targetHit ~= self:GetOwner())) and not self.detonated then

            -- Disables also collision.
            self:SetModel(nil)

            self:TriggerEffects("babbler_hatch")
            self:TriggerEffects("babbler_bomb_hit")
            
           -- Check for room
            local owner = self:GetOwner()
            local spawnPointIndex = 1
            local lastSuccessfulSpawnPoint = self:GetOrigin()
		    local currentNumberOfBomblers = 0
        
            for i = 1, kMaxNumBomblers do
        
                local spawnPoint = nil
                -- Loop through available spawn points and try to find one.
                for idx = spawnPointIndex, #kBabblerSpawnPoints do
					local potentialSpawn = self:GetOrigin() + kBabblerSpawnPoints[idx]
                    					
					if GetHasRoomForCapsule(babblerExtents,	potentialSpawn,	CollisionRep.Move, PhysicsMask.AllButPCsAndRagdolls, self) then
						spawnPoint = potentialSpawn
						spawnPointIndex = spawnPointIndex + 1 -- Advance to the next spawn point
						
						break
					end
                end
						
               -- Fall back to the last successful spawn point if we didn't find one
				if not spawnPoint then
					spawnPoint = lastSuccessfulSpawnPoint
				end
				
				local bombler = CreateEntity(Bombler.kMapName, spawnPoint, self:GetTeamNumber())
				
				if bombler then
					bombler:SetOwner(owner)
					lastSuccessfulSpawnPoint = spawnPoint 
				end

            end
           	 
            DestroyEntity(self)
            CreateExplosionDecals(self, "bilebomb_decal")

        end

    end

end

Shared.LinkClassToMap("BabblerBomb", BabblerBomb.kMapName, networkVars)