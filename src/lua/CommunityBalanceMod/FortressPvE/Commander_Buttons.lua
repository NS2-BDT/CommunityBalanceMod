function CommanderUI_MenuButtonStatus(index)

    local player = Client.GetLocalPlayer()
    local buttonStatus = 0
    local techId = 0
    
    if index <= table.icount(player.menuTechButtons) then
    
        techId = player.menuTechButtons[index]
        
        if techId ~= kTechId.None then
        
            local techNode = GetTechTree():GetTechNode(techId)
            
            if techNode then
            
                if techNode:GetResearching() and not techNode:GetIsUpgrade() then
                
                    -- Don't display
                    buttonStatus = 0

                elseif techNode:GetIsPassive() then

					if not techNode:GetAvailable() then
						buttonStatus = 5
						
						return buttonStatus
					end
					
                    buttonStatus = 4         
                    
                elseif not techNode:GetAvailable() or not player.menuTechButtonsAllowed[index] then
                
                    -- Greyed out
                    buttonStatus = 3
                
                elseif not player.menuTechButtonsAffordable[index] then
                
                    -- red, can't afford, but allowed
                    buttonStatus = 2
                                       
                else
                    -- Available
                    buttonStatus = 1
                end

            else
                -- Print("CommanderUI_MenuButtonStatus(%s): Tech node for id %s not found (%s)", tostring(index), EnumToString(kTechId, techId), table.tostring(player.menuTechButtons))
            end
            
        end
        
    end    
    
    return buttonStatus

end