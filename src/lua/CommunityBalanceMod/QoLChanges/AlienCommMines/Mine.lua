
if Client then
    
    function Mine:OnGetIsVisible(visibleTable, viewerTeamNumber)
        
        local player = Client.GetLocalPlayer()
        
        if player and player:isa("Commander") and viewerTeamNumber == GetEnemyTeamNumber(self:GetTeamNumber()) then
            
            -- visibleTable.Visible = false
        
        end
    
    end

end