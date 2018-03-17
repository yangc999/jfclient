
local TcpMediator = import("..mediator.TcpMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartTcpCommand = class("StartTcpCommand", SimpleCommand)

function StartTcpCommand:execute(notification)
	local body = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	gameFacade:registerMediator(TcpMediator.new())
end

return StartTcpCommand