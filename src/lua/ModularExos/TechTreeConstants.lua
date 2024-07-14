if not EnumUtils then
    Script.Load("lua/ModularExos/EnumUtils.lua")
end

local newTechIds = {
    --"ExoWelder",
    --"ExoFlamer",
    'ExoShield',
    
    --"WeaponCache",
    --"MarineStructureAbility",
}

for _, v in ipairs(newTechIds) do
    EnumUtils.AppendToEnum(kTechId, v)
end