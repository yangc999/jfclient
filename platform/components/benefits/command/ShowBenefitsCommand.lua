
local BenefitsProxy = import("..proxy.BenefitsProxy")
local BenefitsMediator = import("..mediator.BenefitsMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartBenefitsCommand = class("StartBenefitsCommand", SimpleCommand)

function StartBenefitsCommand:execute(notification)
    print("StartBenefitsCommand:execute")
	local root = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    platformFacade:registerMediator(BenefitsMediator.new(root))
end

return StartBenefitsCommand
