
local kInstancedTechIds
function GetTechIdIsInstanced(techId)

    if not kInstancedTechIds then

        kInstancedTechIds = set
        {
            kTechId.AdvancedArmoryUpgrade,
            kTechId.UpgradeRoboticsFactory,
            kTechId.UpgradeToCragHive,
            kTechId.UpgradeToShadeHive,
            kTechId.UpgradeToShiftHive,

            kTechId.UpgradeToAdvancedPrototypeLab,
        }

    end

    return kInstancedTechIds[techId]

end
