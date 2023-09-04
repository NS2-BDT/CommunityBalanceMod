

function AlienUI_GetUpgradesForCategory(category)

    local upgrades = {}

    local techTree = GetTechTree()

    if techTree then

        for _, upgradeId in ipairs(techTree:GetAddOnsForTechId(kTechId.AllAliens)) do

            if LookupTechData(upgradeId, kTechDataCategory, kTechId.None) == category then
                table.insert(upgrades, upgradeId)
            end

        end

    end

    -- CommunityBalanceMod: preserve upgrade location for vamp, regen
    if category == kTechId.CragHive and 
        #upgrades == 3 and
        kTechId.Resilience ~= nil and 
        kTechId.Vampirism ~= nil and 
        kTechId.Regeneration ~= nil 
        then 
        upgrades[1] =  kTechId.Vampirism  
        upgrades[2] =  kTechId.Resilience
        upgrades[3] =  kTechId.Regeneration
    end

    
    return upgrades

end
