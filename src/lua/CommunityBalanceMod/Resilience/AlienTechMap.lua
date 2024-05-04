
for i = #kAlienTechMap, 1 , -1 do 
    if kAlienTechMap[i] and kAlienTechMap[i][1] == kTechId.Carapace then
        
        table.remove(kAlienTechMap, i)
    end
end
local resilience = { kTechId.Resilience, 10, 5 }
table.insert(kAlienTechMap, resilience)