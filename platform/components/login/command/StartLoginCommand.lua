
local LoginProxy = import("..proxy.LoginProxy")
local LoginMediator = import("..mediator.LoginMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartLoginCommand = class("StartLoginCommand", SimpleCommand)

function StartLoginCommand:execute(notification)
	local scene = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerProxy(LoginProxy.new())
	platformFacade:registerMediator(LoginMediator.new(scene))
	local load = platformFacade:retrieveProxy("LoadProxy")
	if table.indexof(load:getData().loginMethod, "wx") then
		platformFacade:sendNotification(PlatformConstants.START_INITWX)
	end
end

return StartLoginCommand