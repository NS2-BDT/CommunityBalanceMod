

local kHaloCinematic = PrecacheAsset("cinematics/marine/arms_lab/arms_lab_holo.cinematic")
local kHaloAttachPoint = "ArmsLab_hologram"

if Client then

    function ArmsLab:OnUpdateRender()

        if not self.haloCinematic then
            self.haloCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
            self.haloCinematic:SetCinematic(kHaloCinematic)
            self.haloCinematic:SetParent(self)
            self.haloCinematic:SetAttachPoint(self:GetAttachPointIndex(kHaloAttachPoint))
            self.haloCinematic:SetCoords(Coords.GetIdentity())
            self.haloCinematic:SetRepeatStyle(Cinematic.Repeat_Loop)
        end
        
        self.haloCinematic:SetIsVisible(self.GetIsResearching(self) and self:GetIsPowered())
        
    end
    
end
