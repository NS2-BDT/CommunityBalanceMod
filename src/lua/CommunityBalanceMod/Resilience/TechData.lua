-- ========= Community Balance Mod ===============================
--
-- "lua\TechData.lua"
--
--    Created by:   4sdfg, Drey (@drey3982)
--
-- ===============================================================



local removeTechDataValue = "BalanceModRemoveTechData"

local function GetTechToAdd()
    return {
        {
            [kTechDataId] = kTechId.Resilience,
            [kTechDataCategory] = kTechId.CragHive,
            [kTechDataDisplayName] = "RESILIENCE",
            [kTechDataCostKey] = kResilienceCost,
            [kTechDataTooltipInfo] = "RESILIENCE_TOOLTIP",
        },
    }
end

local function GetTechToChange()
    return {
    }
end

local function GetTechToRemove() 
    return {
        [kTechId.Carapace] = true
    }
end

local function TechDataChanges(techData)
    -- Handle changes / removes
    local techToChange = GetTechToChange()
    local techToRemove = GetTechToRemove()
    local indexToRemove = {}

    for techIndex,record in ipairs(techData) do
        local techDataId = record[kTechDataId]

        if techToRemove[techDataId] then
            table.insert(indexToRemove, techIndex)
        elseif techToChange[techDataId] then
            for index, value in pairs(techToChange[techDataId]) do
                if value == removeTechDataValue then
                    techData[techIndex][index] = nil
                else
                    techData[techIndex][index] = value
                end
            end
        end
    end

    -- Remove tech
    local offset = 0
    for _,idx in ipairs(indexToRemove) do
        table.remove(techData, idx - offset)
        offset = offset + 1
    end

    -- Add new tech
    local techToAdd = GetTechToAdd()
    for _,v in ipairs(techToAdd) do
        table.insert(techData, v)
    end
end

local oldBuildTechData = BuildTechData
function BuildTechData()
    local techData = oldBuildTechData()
    TechDataChanges(techData)
    return techData
end
