function Alien:OnHealthArmorDamageTaken()
    self.heatplatingTimeEnd = Shared.GetTime() + 2
end
