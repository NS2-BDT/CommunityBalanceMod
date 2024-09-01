
function StormCloudMixin:ModifyMaxSpeed(maxSpeedTable)

    if self.stormed then 
        maxSpeedTable.maxSpeed = maxSpeedTable.maxSpeed * 1.15
    end
end
