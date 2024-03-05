
for i = #kAlienTechMap, 1 , -1 do 
    if kAlienTechMap[i] and kAlienTechMap[i][1] == kTechId.Carapace then
        
        table.remove(kAlienTechMap, i)
    end
end
local heatplating = { kTechId.Heatplating, 10, 5 }
table.insert(kAlienTechMap, heatplating)