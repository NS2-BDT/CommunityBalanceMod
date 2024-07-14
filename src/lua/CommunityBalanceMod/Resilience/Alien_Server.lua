function Alien:OnHealthArmorDamageTaken()
    self.resilienceTimeEnd = Shared.GetTime() + 3
end
