

function MAC:PlayChatSound(soundName)   --FIXME This can be heard by Alien Comm without LOS ...switch to Team sound?

    -- Balance Mod, added 8 seconds
    if self.timeOfLastChatterSound == 0 or (Shared.GetTime() > self.timeOfLastChatterSound + 2 + 8) and self:GetIsAlive() then

        local team = self:GetTeam()
        team:PlayPrivateTeamSound(soundName, self:GetOrigin(), false, nil, false, nil)  --FIXME This seems to make it 2D Only (not positional)
        
        local enemyTeamNumber = GetEnemyTeamNumber(team:GetTeamNumber())
        local enemyTeam = GetGamerules():GetTeam(enemyTeamNumber)
        if enemyTeam ~= nil then  --SeenByTeam? ...not sure that exists
            team:PlayPrivateTeamSound(soundName, self:GetOrigin(), false, nil, false, nil)
        end
        --self:PlaySound(soundName)
        self.timeOfLastChatterSound = Shared.GetTime()
    end
    
end
