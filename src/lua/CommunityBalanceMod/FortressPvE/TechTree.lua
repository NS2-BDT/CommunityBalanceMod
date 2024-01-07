

local kInstancedTechIds

local oldGetTechIdIsInstanced = GetTechIdIsInstanced
function GetTechIdIsInstanced(techId)


    if not kInstancedTechIds then

        kInstancedTechIds = set
        {
            kTechId.UpgradeToFortressCrag,
            kTechId.UpgradeToFortressCrag,
            kTechId.UpgradeToFortressShade,
            kTechId.UpgradeToFortressWhip,
        }
    end

    local resultGetTechIdIsInstanced = oldGetTechIdIsInstanced

    if resultGetTechIdIsInstanced then 
        return resultGetTechIdIsInstanced
    else
        return kInstancedTechIds[techId]
    end

end


function TechTree:ChangeNode(techId, prereq1, prereq2, addOnTechId)

    assert(self.nodeList[techId] ~= nil)

    if prereq1 == nil then
        prereq1 = kTechId.None
    end
    
    if prereq2 == nil then
        prereq2 = kTechId.None
    end
    
    local node = self.nodeList[techId]
    node:SetPrereq1(prereq1)
    node:SetPrereq2(prereq2)

    if addOnTechId ~= nil then
        node.addOnTechId = addOnTechId
    end
    
end

