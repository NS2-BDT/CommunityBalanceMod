-- Only allow a single type of exo to appear in the menu, the rest will be done via the modular exo addon
function PrototypeLab:GetItemList(forPlayer)
    if forPlayer and forPlayer:isa("Exo") then
        return { kTechId.DualMinigunExosuit }
    end
    return { kTechId.Jetpack, kTechId.DualMinigunExosuit }
end

function PrototypeLab:GetTechButtons(techId)
    return { kTechId.JetpackTech, kTechId.None, kTechId.None, kTechId.None,
             kTechId.ExosuitTech, kTechId.None, kTechId.None, kTechId.None } -- kTechId.DualRailgunTech
end