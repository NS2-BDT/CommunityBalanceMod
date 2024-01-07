function Flamethrower:CreateFlame(player, position, normal, direction)

    -- create flame entity, but prevent spamming:
    local nearbyFlames = GetEntitiesForTeamWithinRange("Flame", self:GetTeamNumber(), position, 1.7)

    if (#nearbyFlames == 0) then

        local flame = CreateEntity(Flame.kMapName, position, player:GetTeamNumber())
        flame:SetOwner(player)

        local coords = Coords.GetTranslation(position)
		
		if math.abs(Math.DotProduct(normal, direction)) > 0.9999 then
            direction = normal:GetPerpendicular()
        end
		
        coords.yAxis = normal
        coords.zAxis = direction

        coords.xAxis = coords.yAxis:CrossProduct(coords.zAxis)
        coords.xAxis:Normalize()

        coords.zAxis = coords.xAxis:CrossProduct(coords.yAxis)
        coords.zAxis:Normalize()

        flame:SetCoords(coords)
		
    end

end