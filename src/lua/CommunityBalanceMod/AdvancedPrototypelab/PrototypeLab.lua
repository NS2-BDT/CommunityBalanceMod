

-- changed for advanced proto test
function PrototypeLab:GetTechButtons(techId)

    local techButtons = 
    { kTechId.JetpackTech, kTechId.None, kTechId.None, kTechId.None, 
      kTechId.None, kTechId.None, kTechId.None, kTechId.None }
    
      if self:GetTechId() == kTechId.PrototypeLab and self:GetResearchingId() ~= kTechId.UpgradeToAdvancedPrototypeLab then
        techButtons[5] = kTechId.UpgradeToAdvancedPrototypeLab
      end

    return techButtons
end

function PrototypeLab:GetItemList(forPlayer)
    if forPlayer and forPlayer:isa("Exo") then
        return { kTechId.DualMinigunExosuit }
    else
        return {kTechId.Jetpack, kTechId.DualMinigunExosuit}
    end
end


class 'AdvancedPrototypeLab' (PrototypeLab)

AdvancedPrototypeLab.kMapName = "advancedprotolab"

Shared.LinkClassToMap("AdvancedPrototypeLab", AdvancedPrototypeLab.kMapName, {})



local kHaloAttachPoint = "target"
local kHaloCinematicResearch = PrecacheAsset("cinematics/marine/exo/exo_holo_research.cinematic")
local kHaloCinematicFinished = PrecacheAsset("cinematics/marine/exo/exo_holo_finished.cinematic")

if Client then

    function PrototypeLab:OnUpdateRender()

        if not self.haloCinematicResearch then
            self.haloCinematicResearch = Client.CreateCinematic(RenderScene.Zone_Default)
            self.haloCinematicResearch:SetCinematic(kHaloCinematicResearch)
            self.haloCinematicResearch:SetParent(self)
            self.haloCinematicResearch:SetAttachPoint(self:GetAttachPointIndex(kHaloAttachPoint))
            self.haloCinematicResearch:SetCoords(Coords.GetIdentity())
            self.haloCinematicResearch:SetRepeatStyle(Cinematic.Repeat_Loop)
        end

        if not self.haloCinematicFinished then
            self.haloCinematicFinished = Client.CreateCinematic(RenderScene.Zone_Default)
            self.haloCinematicFinished:SetCinematic(kHaloCinematicFinished)
            self.haloCinematicFinished:SetParent(self)
            self.haloCinematicFinished:SetAttachPoint(self:GetAttachPointIndex(kHaloAttachPoint))
            self.haloCinematicFinished:SetCoords(Coords.GetIdentity())
            self.haloCinematicFinished:SetRepeatStyle(Cinematic.Repeat_Loop)
        end
        
        self.haloCinematicResearch:SetIsVisible(self.GetResearchingId(self) == kTechId.UpgradeToAdvancedPrototypeLab and self.GetIsResearching(self) and self:GetIsPowered())
        self.haloCinematicFinished:SetIsVisible(self:GetTechId() == kTechId.AdvancedPrototypeLab and self:GetIsPowered())
    end
end