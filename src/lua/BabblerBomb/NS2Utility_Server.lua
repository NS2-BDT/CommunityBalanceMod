local LockAbility = debug.getupvaluex(UpdateAbilityAvailability, "LockAbility")
local UnlockAbility = debug.getupvaluex(UpdateAbilityAvailability, "UnlockAbility")

function UpdateAbilityAvailability(forAlien, tierOneTechId, tierTwoTechId, tierThreeTechId)

    local time = Shared.GetTime()
    if forAlien.timeOfLastNumHivesUpdate == nil or (time > forAlien.timeOfLastNumHivesUpdate + 0.5) then

        local team = forAlien:GetTeam()
        if team and team.GetTechTree then
        
            local hasOneHiveNow = GetGamerules():GetAllTech() or (tierOneTechId ~= nil and tierOneTechId ~= kTechId.None and GetIsTechUnlocked(forAlien, tierOneTechId))
            local oneHive = forAlien.oneHive
            -- Don't lose abilities unless you die.
            forAlien.oneHive = forAlien.oneHive or hasOneHiveNow

            if forAlien.oneHive then
                UnlockAbility(forAlien, tierOneTechId)
            else
                LockAbility(forAlien, tierOneTechId)
            end
            
            local hasTwoHivesNow = GetGamerules():GetAllTech() or (tierTwoTechId ~= nil and tierTwoTechId ~= kTechId.None and GetIsTechUnlocked(forAlien, tierTwoTechId))
            local hadTwoHives = forAlien.twoHives
            -- Don't lose abilities unless you die.
            forAlien.twoHives = forAlien.twoHives or hasTwoHivesNow

            if forAlien.twoHives then
                UnlockAbility(forAlien, tierTwoTechId)
            else
                LockAbility(forAlien, tierTwoTechId)
            end
            
            local hasThreeHivesNow = GetGamerules():GetAllTech() or (tierThreeTechId ~= nil and tierThreeTechId ~= kTechId.None and GetIsTechUnlocked(forAlien, tierThreeTechId))
            local hadThreeHives = forAlien.threeHives
            -- Don't lose abilities unless you die.
            forAlien.threeHives = forAlien.threeHives or hasThreeHivesNow

            if forAlien.threeHives then
                UnlockAbility(forAlien, tierThreeTechId)
            else
                LockAbility(forAlien, tierThreeTechId)
            end
            
            if forAlien.GetTierFourTechId then
                local tierFourTechId = forAlien:GetTierFourTechId()
                local hasFourHivesNow = GetGamerules():GetAllTech() or (tierFourTechId ~= nil and tierFourTechId ~= kTechId.None and GetIsTechUnlocked(forAlien, tierFourTechId))
                local hadFourHives = forAlien.fourHives
                -- Don't lose abilities unless you die.
                forAlien.fourHives = forAlien.fourHives or hasFourHivesNow

                if forAlien.fourHives then
                    UnlockAbility(forAlien, tierFourTechId)
                else
                    LockAbility(forAlien, tierFourTechId)
                end
            end
        end
        
        forAlien.timeOfLastNumHivesUpdate = time
        
    end

end