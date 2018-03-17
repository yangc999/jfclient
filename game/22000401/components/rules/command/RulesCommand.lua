
local RulesMediator = import("..mediator.RulesMediator")
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RulesCommand = class("RulesCommand", SimpleCommand)

function RulesCommand:execute(notification)
    print("-------------->RulesCommand:execute")
	local root = notification:getBody()

	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	gameFacade:registerMediator(RulesMediator.new())
end

return RulesCommand