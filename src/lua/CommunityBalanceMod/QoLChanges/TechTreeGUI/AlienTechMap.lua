

for i = #kAlienTechMap, 1 , -1 do 
    if kAlienTechMap[i] and 
    ( kAlienTechMap[i][1] == kTechId.BabblerEgg 
    or kAlienTechMap[i][1] == kTechId.WebTech ) then 
        
        table.remove(kAlienTechMap, i)
        
    end
end
local mist = { kTechId.NutrientMist, 2.5, 8 }
table.insert(kAlienTechMap, mist)