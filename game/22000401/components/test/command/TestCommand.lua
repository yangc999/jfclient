
local TestMediator = import("..mediator.TestMediator")
local SimpleCommand = cc.load("puremvc").SimpleCommand
local TestCommand = class("TestCommand", SimpleCommand)

function TestCommand:execute(notification)
    print("-------------->TestCommand:execute")
	local root = notification:getBody()

	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	gameFacade:registerMediator(TestMediator.new())
end

return TestCommand