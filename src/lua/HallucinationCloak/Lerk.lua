function Lerk:GetSpeedScalar()
    return self:GetVelocity():GetLength() / 9
end