
local BenefitsProxy = import("..proxy.BenefitsProxy")
local AssistanceTipsMediator = import("..mediator.AssistanceTipsMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local ShowAssistanceTipsCommand = class("ShowAssistanceTipsCommand", SimpleCommand)

function ShowAssistanceTipsCommand:execute(notification)

    local root = notification:getBody()  --获取根结点

    print("ShowAssistanceTipsCommand:execute")

	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerMediator(AssistanceTipsMediator.new(root))
end

return ShowAssistanceTipsCommand