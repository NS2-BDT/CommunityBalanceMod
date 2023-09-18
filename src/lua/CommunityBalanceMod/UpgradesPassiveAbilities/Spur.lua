
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/AlienStructureMoveMixin.lua")

Spur.kWalkingSound = PrecacheAsset("sound/NS2.fev/alien/structures/whip/walk")

local networkVars = { }

-- new ones
AddMixinNetworkVars(AlienStructureMoveMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)

Shared.LinkClassToMap("Spur", Spur.kMapName, networkVars)


local OldSpurOnCreate = Spur.OnCreate
function Spur:OnCreate()

    OldSpurOnCreate(self)

    InitMixin(self, PathingMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, AlienStructureMoveMixin, { kAlienStructureMoveSound = Spur.kWalkingSound })
    
end

local OldSpurOnInitialized = Spur.OnInitialized
function Spur:OnInitialized()

    OldSpurOnInitialized(self)

    if Server then
        InitMixin(self, RepositioningMixin)
    end
end


function Spur:GetTechButtons(techId)

    local techButtons = { kTechId.Move, kTechId.None, kTechId.None, kTechId.None,
                          kTechId.None, kTechId.None, kTechId.None, kTechId.Consume }

    if self.moving then
        techButtons[1] = kTechId.Stop
    end

    return techButtons
end


function Spur:GetMaxSpeed()
    return kAlienStructureMoveSpeed / 2
end

function Spur:OverrideRepositioningSpeed()
    return kAlienStructureMoveSpeed * 0.5
end


function Spur:GetCanReposition()
    return true
end

function Spur:OnOrderChanged()
    if self:GetIsConsuming() then
        self:CancelResearch()
    end

    local currentOrder = self:GetCurrentOrder()
    if GetIsUnitActive(self) and currentOrder and currentOrder:GetType() == kTechId.Move then
        self:SetUpdateRate(kRealTimeUpdateRate)
    end
end


function Spur:PerformAction(techNode)
    if techNode:GetTechId() == kTechId.Stop then
        self:ClearOrders()
    end
end
