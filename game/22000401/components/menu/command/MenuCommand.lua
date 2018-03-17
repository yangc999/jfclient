
local MenuMediator = import("..mediator.MenuMediator")
local MenuProxy = import("..proxy.MenuProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local MenuCommand = class("OutCardCommand", SimpleCommand)

function MenuCommand:execute(notification)
    print("-------------->MenuCommand:execute")
	local root = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    gameFacade:registerProxy(MenuProxy.new())
	gameFacade:registerMediator(MenuMediator.new(root))
end

return MenuCommand