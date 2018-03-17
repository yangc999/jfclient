
local TestServerProxy = import("..proxy.TestServerProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local TestServerCommand = class("TestServerCommand", SimpleCommand)

function TestServerCommand:execute(notification)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerProxy(TestServerProxy.new())
end

return TestServerCommand