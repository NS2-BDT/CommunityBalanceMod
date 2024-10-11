
if not EnumUtils then
    Script.Load("lua/BabblerBomb/EnumUtils.lua")
end

local newTechIds = {
	
	'BabblerBombAbility',
    'BabblerBomb',
    'Bombler',
    
 }

for _, v in ipairs(newTechIds) do
    EnumUtils.AppendToEnum(kTechId, v)
end