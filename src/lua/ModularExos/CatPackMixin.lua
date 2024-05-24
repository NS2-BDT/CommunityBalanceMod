function CatPackMixin:ClearCatPackMixin()
    
    if self:GetHasCatPackBoost() then
        self.catpackboost = false
    end
    
    if Client then
        self:_RemoveEffect()
    end

end