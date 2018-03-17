
local PlayerInfoMediator = import("..mediator.PlayerInfoMediator")
local PlayerInfoProxy = import("..proxy.PlayerInfoProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local PlayerInfoCommand = class("PlayerInfoCommand", SimpleCommand)

function PlayerInfoCommand:execute(notification)
    print("-------------->PlayerInfoCommand:execute")
	local root = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    gameFacade:registerProxy(PlayerInfoProxy.new())
	gameFacade:registerMediator(PlayerInfoMediator.new(root))
end

return PlayerInfoCommand