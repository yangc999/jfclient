
local LocationProxy = import("..proxy.LocationProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartLocationCommand = class("StartLocationCommand", SimpleCommand)

function StartLocationCommand:execute(notification)
	local info = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("game")
	platformFacade:registerProxy(LocationProxy.new())
end

return StartLocationCommand