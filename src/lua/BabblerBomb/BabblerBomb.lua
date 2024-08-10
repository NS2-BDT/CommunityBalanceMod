Script.Load("lua/Weapons/Alien/Bomb.lua")
Script.Load("lua/BabblerBomb/Bombler.lua")

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
    local babblerExtents = Vector(kCheckDist, kCheckDist, kCheckDist)
    
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
                    spawnPointIndex = idx
                    if GetHasRoomForCapsule(babblerExtents, self:GetOrigin() + kBabblerSpawnPoints[spawnPointIndex], CollisionRep.Move, PhysicsMask.AllButPCsAndRagdolls, self) then
                        spawnPoint = kBabblerSpawnPoints[spawnPointIndex]
                        break
                    end
                end
				
						
               -- Fall back to the last successful spawn point if we didn't find one
                if spawnPoint then
                    spawnPointIndex = spawnPointIndex + 1
                else
                    spawnPoint = lastSuccessfulSpawnPoint
                end
                
				
				local bombler = CreateEntity(Bombler.kMapName, self:GetOrigin() + kBabblerSpawnPoints[i], self:GetTeamNumber())
                bombler:SetOwner(owner)
							
					
                if owner and owner:isa("Gorge") then
                   -- bombler:SetVariant(owner:GetVariant())
                end
				 if owner then
                   -- owner:GetTeam():AddGorgeStructure(owner, bombler)
                end

            end
           
	 
            DestroyEntity(self)
            
            CreateExplosionDecals(self, "bilebomb_decal")

        end

    end

end

Shared.LinkClassToMap("BabblerBomb", BabblerBomb.kMapName, networkVars)