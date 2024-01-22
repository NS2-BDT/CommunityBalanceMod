-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================

kTechDataSwitchUpgradeCost = "switchupgradecost"
local removeTechDataValue = "BalanceModRemoveTechData"

local function GetTechToChange()
    return {
    
        [kTechId.Skulk] = {
            [kTechDataSwitchUpgradeCost] = kSkulkSwitchUpgradeCost
        },
        [kTechId.Gorge] = {
            [kTechDataSwitchUpgradeCost] = kGorgeSwitchUpgradeCost
        },
        [kTechId.Lerk] = {
            [kTechDataSwitchUpgradeCost] = kLerkSwitchUpgradeCost
        },
        [kTechId.Fade] = {
            [kTechDataSwitchUpgradeCost] = kFadeSwitchUpgradeCost
        },
        [kTechId.Onos] = {
            [kTechDataSwitchUpgradeCost] = kOnosSwitchUpgradeCost
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
