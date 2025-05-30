BabblerOwnerMixin = CreateMixin(BabblerOwnerMixin)
BabblerOwnerMixin.type = "BabblerOwner"

BabblerOwnerMixin.networkVars = 
{
    babblerCount = "integer (0 to 18)",
    bombBabblerCount = "integer (0 to 18)"
}

kBabblerHatchTime = 2.5
function BabblerOwnerMixin:__initmixin()
    
    PROFILE("BabblerOwnerMixin:__initmixin")
    
	self.babblerCount = 0
    self.bombBabblerCount = 0

	if Server then
		self:AddTimedCallback(self.HatchBabbler, kBabblerHatchTime)
	end
end

function BabblerOwnerMixin:GetBabblerCount()
	return self.babblerCount
end

function BabblerOwnerMixin:GetBombBabblerCount()
    return self.bombBabblerCount
end

function BabblerOwnerMixin:GetMaxBabblers()
	return 6
end

function BabblerOwnerMixin:OnWeaponAdded(weapon)
    if weapon:GetMapName() == BabblerAbility.kMapName then
        self.babblerBaitId = weapon:GetId()
    end
end

-- Returns if the owner can hatch/spawn a babbler
function BabblerOwnerMixin:GetCanHatchBabbler()
    -- owner needs to be on a playing team
    if not self:GetIsOnPlayingTeam() then
        return false
    end

    -- owner needs to be alive
    if HasMixin(self, "Live") and not self:GetIsAlive() then
        return false
    end
	
    -- owner needs to be not under attack
    if self:GetIsUnderFire() then
        return false
    end

    -- owner needs to be able to attach the babblers
    if not self:GetCanAttachBabbler() then
        return false
    end

    -- owner needs to be below the babbler limit
    local aboveBabblerLimit = self:GetBabblerCount() >= self:GetMaxBabblers()
    if aboveBabblerLimit then
        return false
    end

    -- if all requirements are met owner can hatch another babbler
    return true
end

if Server then

    function BabblerOwnerMixin:BabblerCreated()
        self.babblerCount = self.babblerCount + 1
    end

    function BabblerOwnerMixin:BabblerDestroyed()
        self.babblerCount = math.max(0, self.babblerCount - 1)
    end

    function BabblerOwnerMixin:BombBabblerCreated()
        self.bombBabblerCount = self.bombBabblerCount + 1
    end

    function BabblerOwnerMixin:BombBabblerDestroyed()
        self.bombBabblerCount = math.max(0, self.bombBabblerCount - 1)
    end
	
	function BabblerOwnerMixin:HatchBabbler()
		if self:GetCanHatchBabbler() then

			local origin = self:GetFreeBabblerAttachPointOrigin()
			local babbler = CreateEntity(Babbler.kMapName, origin, self:GetTeamNumber())

			babbler:SetOwner(self)
			babbler:SetSilenced(self.silenced)

			local client = self:GetClient()
			if client and client.variantData then
				babbler:SetVariant( client.variantData.babblerVariant )
			end

			babbler:SetMoveType( kBabblerMoveType.Cling, self, self:GetOrigin(), true )

		end

		return true
	end

    function BabblerOwnerMixin:HatchMaxBabblers()
        while self:GetCanHatchBabbler() do
            self:HatchBabbler()
        end
    end

    function BabblerOwnerMixin:DestroyAllOwnedBabblers()
        for _, babbler in ipairs(GetEntitiesForTeam("Babbler", self:GetTeamNumber())) do
            if babbler:GetOwner() == self then
                babbler:Kill()
            end
        end
    end

	function BabblerOwnerMixin:OnKill()
		self:DestroyAllOwnedBabblers()
	end
end
