
local LoadProxy = import("..proxy.LoadProxy")
local LoadMediator = import("..mediator.LoadMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local InitConfigCommand = class("InitConfigCommand", SimpleCommand)

function InitConfigCommand:execute(notification)
	local scene = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	platformFacade:registerProxy(LoadProxy.new())
	platformFacade:registerMediator(LoadMediator.new(scene))
end

return InitConfigCommand