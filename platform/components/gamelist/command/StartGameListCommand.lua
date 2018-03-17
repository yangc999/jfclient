
local GameListProxy = import("..proxy.GameListProxy")
local GameListMediator = import("..mediator.GameListMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartGameListCommand = class("StartGameListCommand", SimpleCommand)

function StartGameListCommand:execute(notification)
	local root = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerProxy(GameListProxy.new())
	platformFacade:registerMediator(GameListMediator.new(root))
end

return StartGameListCommand