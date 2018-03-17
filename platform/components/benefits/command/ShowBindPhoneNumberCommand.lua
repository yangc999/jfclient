
local BenefitsProxy = import("..proxy.BenefitsProxy")
local BindPhoneNumberMediator = import("..mediator.BindPhoneNumberMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local ShowBindPhoneNumberCommand = class("ShowBindPhoneNumberCommand", SimpleCommand)

function ShowBindPhoneNumberCommand:execute(notification)
    print("showBindPhoneNumberCommand11111111111")
    local root = notification:getBody()  --获取根结点

	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerMediator(BindPhoneNumberMediator.new(root))
end

return ShowBindPhoneNumberCommand