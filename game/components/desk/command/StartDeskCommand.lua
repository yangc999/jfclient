
local DeskProxy = import("..proxy.DeskProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartDeskCommand = class("StartDeskCommand", SimpleCommand)

function StartDeskCommand:execute(notification)
	local info = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("game")
	platformFacade:registerProxy(DeskProxy.new())
end

return StartDeskCommand