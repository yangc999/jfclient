
local BenefitsProxy = import("..proxy.BenefitsProxy")
local TaskProxy = import("....components.tasks.proxy.TaskProxy")
local BenefitsMediator = import("..mediator.BenefitsMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartBenefitsCommand = class("StartBenefitsCommand", SimpleCommand)

function StartBenefitsCommand:execute(notification)
    print("StartBenefitsCommand:execute")
	local root = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerProxy(BenefitsProxy.new())
    platformFacade:registerProxy(TaskProxy.new())
end

return StartBenefitsCommand
