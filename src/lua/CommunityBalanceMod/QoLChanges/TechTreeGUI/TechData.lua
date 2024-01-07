local removeTechDataValue = "BalanceModRemoveTechData"

local function GetTechToChange()
    return {
    
        [kTechId.ShiftHive] = 
        {
            [kTechDataUpgradeTech] = kTechId.Hive,
        },

        [kTechId.CragHive] = 
        {
            [kTechDataUpgradeTech] = kTechId.Hive,
        },

        [kTechId.ShadeHive] = 
        {
            [kTechDataUpgradeTech] = kTechId.Hive,
        },
    }
end


local oldBuildTechData = BuildTechData
function BuildTechData()
    local techData = oldBuildTechData()
    local techToChange = GetTechToChange()

    for techIndex,record in ipairs(techData) do
        local techDataId = record[kTechDataId]
        if techToChange[techDataId] then
            for index, value in pairs(techToChange[techDataId]) do
                if value == removeTechDataValue then
                    techData[techIndex][index] = nil
                else
                    techData[techIndex][index] = value
                end
            end
        end
    end


    return techData
end
