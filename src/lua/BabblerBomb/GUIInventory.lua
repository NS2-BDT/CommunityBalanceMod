local oldLocalAdjust = GUIInventory.LocalAdjustSlot
function GUIInventory:LocalAdjustSlot(index, hudSlot, techId, isActive, resetAnimations, alienStyle)
	oldLocalAdjust(self, index, hudSlot, techId, isActive, resetAnimations, alienStyle)
	if techId == kTechId.BabblerBombAbility then
		local inventoryItem = self.inventoryIcons[index]
		inventoryItem.Graphic:SetTexture(kBabblerBombTexture)
		inventoryItem.Graphic:SetTexturePixelCoordinates(0,0,128,64)
	end  

end
