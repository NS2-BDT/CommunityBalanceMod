
function StormCloudMixin:ModifyMaxSpeed(maxSpeedTable)

    if self.stormed and GetHasCelerityUpgrade(self) then 
		local SpurLevel = self:GetSpurLevel()
		local SpeedAdd = math.min(2.25 - SpurLevel*0.5,1.5)
        maxSpeedTable.maxSpeed = maxSpeedTable.maxSpeed + SpeedAdd
	elseif self.stormed then
		maxSpeedTable.maxSpeed = maxSpeedTable.maxSpeed + 1.5
    end
end
