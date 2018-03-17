
local TestClientProxy = import("..proxy.TestClientProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local TestClientCommand = class("TestClientCommand", SimpleCommand)

function TestClientCommand:execute(notification)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerProxy(TestClientProxy.new())
end

return TestClientCommand