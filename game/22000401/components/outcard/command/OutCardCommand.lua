
local OutCardMediator = import("..mediator.OutCardMediator")
local OutCardProxy = import("..proxy.OutCardProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local OutCardCommand = class("OutCardCommand", SimpleCommand)

function OutCardCommand:execute(notification)
    print("-------------->OutCardCommand:execute")
	local root = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    gameFacade:registerProxy(OutCardProxy.new())
	gameFacade:registerMediator(OutCardMediator.new(root))
end

return OutCardCommand