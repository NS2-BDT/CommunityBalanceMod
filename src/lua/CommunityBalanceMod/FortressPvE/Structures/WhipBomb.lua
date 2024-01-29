-- ========= Community Balance Mod ===============================
--
-- "lua\WhipBomb.lua"
--
--    Created by:   Twiliteblue, Drey (@drey3982)
--
-- ===============================================================

WhipBomb.kFortressBallMaterial = PrecacheAsset("models/alien/Whip/ball_adv.material")

kBombardVariants = enum({ "normal", "fortress" })

local networkVars =
{
	bombVariant = "enum kBombardVariants",
}

local oldOnInitialized = WhipBomb.OnInitialized
function WhipBomb:OnInitialized()

	oldOnInitialized(self)
    
    self.bombVariant = kBombardVariants.normal
    
    if Client then
		self.dirtySkinState = true
    end
	
end

if Client then

    function WhipBomb:OnUpdateRender()
        
        if self.dirtySkinState then
            local model = self:GetRenderModel()
            if model and model:GetReadyForOverrideMaterials() and self.bombVariant ~= kBombardVariants.normal then
				local material = WhipBomb.kFortressBallMaterial
				local materialIndex = 0
				model:SetOverrideMaterial( materialIndex, material )

                self:SetHighlightNeedsUpdate()
                
                self.dirtySkinState = false
            else
                return false --skip to next frame
            end

        end

    end

end

Shared.LinkClassToMap("WhipBomb", WhipBomb.kMapName, networkVars)