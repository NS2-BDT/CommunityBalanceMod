
if Server then

    local UnsightImmediately = debug.getupvaluex(LOSMixin.OnTeamChange, "UnsightImmediately")

    function LOSMixin:OnCloak()
        UnsightImmediately(self)
    end
end
