GUICommanderButtons.kButtonStatusPassiveOff = { Id = 5, Color = Color(0.45, 0.45, 0.45, 1), Visible = true }
GUICommanderButtons.kButtonStatusData[GUICommanderButtons.kButtonStatusPassiveOff.Id] = GUICommanderButtons.kButtonStatusPassiveOff

function GUICommanderButtons:UpdateInput()

    local tooltipButtonIndex
    
    if self.highlightItem then
    
        self.highlightItem:SetIsVisible(false)
        
        local mouseX, mouseY = Client.GetCursorPosScreen()
        
        if CommanderUI_GetUIClickable() and GUIItemContainsPoint(self.background, mouseX, mouseY) then
        
            for i, buttonItem in ipairs(self.buttons) do
            
                local buttonStatus = CommanderUI_MenuButtonStatus(i)
                if GUIItemContainsPoint(buttonItem, mouseX, mouseY) then
                
                    if (buttonItem:GetIsVisible() and buttonStatus == GUICommanderButtons.kButtonStatusEnabled.Id) and
                       (self.targetedButton == nil or self.targetedButton == i) then
                       
                        HighlightButton(self, buttonItem)
                        tooltipButtonIndex = i
                        
                        break
                        
                    -- Off or red buttons can still have a tooltip.
                    elseif buttonStatus == GUICommanderButtons.kButtonStatusOff.Id or buttonStatus == GUICommanderButtons.kButtonStatusRed.Id or buttonStatus == GUICommanderButtons.kButtonStatusPassive.Id or buttonStatus == GUICommanderButtons.kButtonStatusPassiveOff.Id then
                    
                        tooltipButtonIndex = i
                        break
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
    return tooltipButtonIndex
    
end


function GUICommanderButtons:UpdateButtonStatus(buttonIndex)

    local buttonStatus = CommanderUI_MenuButtonStatus(buttonIndex)
    local buttonCooldownFraction = CommanderUI_MenuButtonCooldownFraction(buttonIndex)
    local buttonItem = self.buttons[buttonIndex]
    local cooldownItem = self.cooldowns[buttonIndex]
    local backgroundItem = self.buttonbackground[buttonIndex]    
    
    if cooldownItem then
    
        cooldownItem:SetIsVisible(buttonCooldownFraction ~= 0)
        if buttonCooldownFraction ~= 0 then
        
            cooldownItem:SetPercentage(buttonCooldownFraction)
            cooldownItem:Update()
            
        end
        
    end
    
    buttonItem:SetIsVisible(GUICommanderButtons.kButtonStatusData[buttonStatus].Visible)
    
    if buttonStatus == GUICommanderButtons.kButtonStatusEnabled.Id or buttonStatus == GUICommanderButtons.kButtonStatusPassive.Id then
        buttonItem:SetColor(kIconColors[self.teamType])
    else    
        buttonItem:SetColor(GUICommanderButtons.kButtonStatusData[buttonStatus].Color)
    end
    
    if buttonItem:GetIsVisible() then
    
        local buttonWidth = CommanderUI_MenuButtonWidth()
        local buttonHeight = CommanderUI_MenuButtonHeight()
        local buttonXOffset, buttonYOffset = CommanderUI_MenuButtonOffset(buttonIndex)
        
        if buttonXOffset and buttonYOffset then
        
            local textureXOffset = buttonXOffset * buttonWidth
            local textureYOffset = buttonYOffset * buttonHeight
            buttonItem:SetTexturePixelCoordinates(textureXOffset, textureYOffset, textureXOffset + buttonWidth, textureYOffset + buttonHeight)
            
        end
        
    end
    
    if self.targetedButton ~= nil then
    
        if self.targetedButton == buttonIndex then
            buttonItem:SetColor(kIconColors[self.teamType])
        else
            buttonItem:SetColor(GUICommanderButtons.kButtonStatusOff.Color)
        end
        
    end  
    
    backgroundItem:SetIsVisible(buttonItem:GetIsVisible() and buttonStatus ~= GUICommanderButtons.kButtonStatusPassive.Id and buttonStatus ~= GUICommanderButtons.kButtonStatusPassiveOff.Id)
    
end