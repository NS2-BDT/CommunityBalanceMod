-- ========= Community Balance Mod ===============================
--
-- "lua\AlienTechMap.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


local newTech = { kTechId.FortressWhip, 5.5, -0.5 }
table.insert(kAlienTechMap, newTech)
local newTech = { kTechId.FortressShift, 6.5, -0.5 }
table.insert(kAlienTechMap, newTech)
local newTech = { kTechId.FortressShade, 7.5, -0.5 }
table.insert(kAlienTechMap, newTech)
local newTech = { kTechId.FortressCrag, 8.5, -0.5 }
table.insert(kAlienTechMap, newTech)

local newLine =  GetLinePositionForTechMap(kAlienTechMap, kTechId.Crag, kTechId.FortressCrag)
table.insert(kAlienLines, newLine)
local newLine =  GetLinePositionForTechMap(kAlienTechMap, kTechId.Shift, kTechId.FortressShift)
table.insert(kAlienLines, newLine)
local newLine =  GetLinePositionForTechMap(kAlienTechMap, kTechId.Shade, kTechId.FortressShade)
table.insert(kAlienLines, newLine)
local newLine =  GetLinePositionForTechMap(kAlienTechMap, kTechId.Whip, kTechId.FortressWhip)
table.insert(kAlienLines, newLine)
