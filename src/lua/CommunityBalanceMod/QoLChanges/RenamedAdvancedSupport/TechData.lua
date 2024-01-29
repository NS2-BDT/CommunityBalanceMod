-- ========= Community Balance Mod ===============================
--
-- "lua\TechData.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================

local removeTechDataValue = "BalanceModRemoveTechData"

local function GetTechToChange()
    return {
    
         -- In vanilla EN its called "Advanced Support" and in every other language except russian "Advanced Assistance"
        -- this will overwrite the russian translation too
        [kTechId.AdvancedMarineSupport] = 
        {
            [kTechDataDisplayName] = "ADVANCED_SUPPORT",
            [kTechDataResearchName] = "ADVANCED_SUPPORT",
        }
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
