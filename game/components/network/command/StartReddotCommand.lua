
local ReddotMediator = import("..mediator.ReddotMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartReddotCommand = class("StartReddotCommand", SimpleCommand)

function StartReddotCommand:execute(notification)
	local body = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	gameFacade:registerMediator(ReddotMediator.new())
end

return StartReddotCommand