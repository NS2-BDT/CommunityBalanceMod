local function FillClip(self)
	-- Stick the bullets in the clip back into our pool so that we don't lose
	-- bullets. Not realistic, but more enjoyable
	self.ammo = self.ammo + self.clip

	-- Transfer bullets from our ammo pool to the weapon's clip
	self.clip = math.min(self.ammo, self:GetClipSize())
	self.ammo = math.min(self.ammo - self.clip, self:GetMaxAmmo())
end

function ClipWeapon:OnTag(tagName)
	PROFILE("ClipWeapon:OnTag")

	if tagName == "shoot" then
		local player = self:GetParent()

		-- We can get a shoot tag even when the clip is empty if the frame rate is low
		-- and the animation loops before we have time to change the state.
		-- we can also get tag from other weapons whose animation is running, so make sure that we are actually
		-- attacking before we act on the shoot.
		if self:GetIsAllowedToShoot(player) then
			self:FirePrimary(player)

			-- Don't decrement ammo in Darwin mode
			if not player or not player:GetDarwinMode() then
				self.clip = self.clip - 1
			end

			self:CreatePrimaryAttackEffect(player)

			self.timeAttackFired = Shared.GetTime()

			self.shooting = true

		-- DebugFireRate(self)
		end

		-- If we fired the last bullet, reload immediatly
		if self.clip == 0 and self.ammo > 0 then
			player:Reload()
		end
	elseif tagName == "reload" then
		FillClip(self)
		self.reloaded = true
		self.shooting = false
	elseif tagName == "deploy_end" then
		self.deployed = true
		if self.clip == 0 and self.ammo > 0 then
			local player = self:GetParent()
			player:Reload()
		end
	elseif tagName == "reload_end" and self.reloaded then
		self.reloading = false
		self.reloaded = false
	elseif tagName == "shoot_empty" then
		self:TriggerEffects("clipweapon_empty")
	end
end
