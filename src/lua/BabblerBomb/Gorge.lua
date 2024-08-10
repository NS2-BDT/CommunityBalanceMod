Script.Load("lua/BabblerBomb/BabblerBomb.lua")
Script.Load("lua/BabblerBomb/BabblerBombAbility.lua")

if Server then
	
	if kCombatVersion then
		function Gorge:GetTierThreeTechId()
			return kTechId.BabblerBombAbility
		end
	else
        function Gorge:GetTierFourTechId()
            return kTechId.BabblerBombAbility
        end
    end

end
