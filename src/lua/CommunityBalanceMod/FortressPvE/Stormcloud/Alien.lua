
local networkVars =
{


    stormed = "boolean",
}



Shared.LinkClassToMap("Alien", Alien.kMapName, networkVars, true)


local oldAlienOnCreate = Alien.OnCreate
function Alien:OnCreate()
    oldAlienOnCreate(self)
    self.stormed = false     

    if Server then
            self.timeWhenStormExpires = 0                    
    end

end

          

function Alien:GetIsStormed()
    return self.stormed
end

function Alien:ClearStorm()
    local rval = (self.stormed == true)

    if Server then
        self.timeWhenStormExpires = 0 -- Expire with zero. Shared.GetTime at this point will cause harmonic oscillation under constant electrify effect
    end

    self.stormed = false

    return rval
end

      

