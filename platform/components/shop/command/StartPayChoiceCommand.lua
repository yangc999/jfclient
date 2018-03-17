--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ShopProxy = import("..proxy.ShopProxy")
local PayChoiceMediator = import("..mediator.PayChoiceMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartPayChoiceCommand = class("StartPayChoiceCommand", SimpleCommand)

function StartPayChoiceCommand:execute(notification)
    print("StartPayChoiceCommand:execute")
    dump(notification, "notification")
    local body = notification:getBody()
    --dump(notification,"StartPayChoiceCommand notification")
	
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerProxy(ShopProxy.new())
	platformFacade:registerMediator(PayChoiceMediator.new(body))
end

return StartPayChoiceCommand

--endregion
