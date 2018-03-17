
local BenefitsProxy = import("..proxy.BenefitsProxy")
local SignMediator = import("..mediator.SignMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local ShowSignCommand = class("ShowSignCommand", SimpleCommand)

function ShowSignCommand:execute(notification)

    local root = notification:getBody()  --获取根结点

    print("showSignCommand:execute")

	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerMediator(SignMediator.new(root))
end

return ShowSignCommand