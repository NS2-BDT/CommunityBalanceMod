local newTechIds = {
   
    'WhipAbility',

    'UpgradeToFortressCrag',
    'FortressCrag',
    'FortressCragAbility',

    
    'UpgradeToFortressShift',
    'FortressShift',
    'FortressShiftAbility',

    
    'UpgradeToFortressShade',
    'FortressShade',
    'ShadeHallucination',

    
    'UpgradeToFortressWhip',
    'FortressWhip',
    'FortressWhipAbility',

    'HallucinateShell',
    'HallucinateSpur',
    'HallucinateVeil',
    'HallucinateEgg',
    'HallucinateCloning',
    'HallucinateRandom',

}

local removeTechIds = {
}

for _,v in ipairs(removeTechIds) do
    EnumUtils.RemoveFromEnum(kTechId, v)
end

for _,v in ipairs(newTechIds) do
    EnumUtils.AppendToEnum(kTechId, v)
end
