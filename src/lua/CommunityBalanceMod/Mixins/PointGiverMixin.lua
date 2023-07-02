

if Server then 
    oldPointGiverMixinOnConstruct = PointGiverMixin.OnConstruct
    function PointGiverMixin:OnConstruct(builder, newFraction, oldFraction)
        if self:GetClassName() == "Hydra" then
            return
        end
        oldPointGiverMixinOnConstruct(self, builder, newFraction, oldFraction )
    end
end

