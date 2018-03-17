
local HandCardMediator = import("..mediator.HandCardMediator")
local HandCardProxy = import("..proxy.HandCardProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local HandCardCommand = class("HandCardCommand", SimpleCommand)

function HandCardCommand:execute(notification)
	local root = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    gameFacade:registerProxy(HandCardProxy.new())
	gameFacade:registerMediator(HandCardMediator.new(root))
end

return HandCardCommand