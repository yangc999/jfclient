
local HelpMediator = import("..mediator.HelpMediator")
local SimpleCommand = cc.load("puremvc").SimpleCommand
local HelpCommand = class("HelpCommand", SimpleCommand)

function HelpCommand:execute(notification)
    print("-------------->HelpCommand:execute")
	local root = notification:getBody()

	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	gameFacade:registerMediator(HelpMediator.new())
end

return HelpCommand