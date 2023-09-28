local newTechIds = {
    "UpgradeToAdvancedPrototypeLab",
    "AdvancedPrototypeLab",
    'ExosuitTech',

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

}

local removeTechIds = {
    'ExosuitTech',
}

for _,v in ipairs(removeTechIds) do
    EnumUtils.RemoveFromEnum(kTechId, v)
end

for _,v in ipairs(newTechIds) do
    EnumUtils.AppendToEnum(kTechId, v)
end
