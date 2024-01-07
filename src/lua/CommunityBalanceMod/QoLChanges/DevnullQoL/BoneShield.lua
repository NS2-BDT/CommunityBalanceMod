if Client then
	function BoneShield:OnUpdateRender()
		local localPlayer = Client.GetLocalPlayer()

		if self.guiObj then
			local now = Shared.GetTime()
			local shouldBeVisible = localPlayer and localPlayer:isa("Onos") and (self.active or now <= self.hitPointsRechargeStartTime) and not HelpScreen_GetHelpScreen():GetIsBeingDisplayed() and not GetMainMenu():GetVisible()

			self.guiObj:SetVisible(shouldBeVisible)

			if shouldBeVisible then
				self.guiObj:SetCurrentHP(self.hitPoints)
				if self.lastHitPoints - self.hitPoints > 1 then -- netvar jitter workaround
					self.guiObj:StartFlashing()
				end

				self.guiObj:SetBroken(self.hitPoints <= kEpsilon)

				self.lastHitPoints = self.hitPoints
			end
		end
	end
end
