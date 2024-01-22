-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================



local oldGetTechIdIsInstanced = GetTechIdIsInstanced
function GetTechIdIsInstanced(techId)

    local resultGetTechIdIsInstanced = oldGetTechIdIsInstanced

    if resultGetTechIdIsInstanced then 
        return resultGetTechIdIsInstanced
    else
        return kTechId.UpgradeToAdvancedPrototypeLab == techId
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

