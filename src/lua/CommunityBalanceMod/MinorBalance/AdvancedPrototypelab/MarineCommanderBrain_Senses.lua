
local oldCreateMarineComSenses = CreateMarineComSenses
function CreateMarineComSenses()


    local s = oldCreateMarineComSenses()

    s:Add("mainAdvancedPrototypeLab", function(db)
        local startingLocationId = Shared.GetStringIndex(db.bot.brain:GetStartingTechPoint() or "")
        local units = GetEntitiesAliveForTeamByLocationWithTechId( "PrototypeLab", db.bot:GetTeamNumber(), startingLocationId, kTechId.AdvancedPrototypeLab )
        if #units > 0 then
            return units[1]
        end
    end)

  
    return s

end
