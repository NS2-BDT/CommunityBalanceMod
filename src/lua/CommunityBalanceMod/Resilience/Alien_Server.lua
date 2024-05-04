function Alien:OnHealthArmorDamageTaken()
    self.resilienceTimeEnd = Shared.GetTime() + 2
end
