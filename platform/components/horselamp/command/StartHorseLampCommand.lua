
local HorseLampProxy = import("..proxy.HorseLampProxy")
local HorseLampMediator = import("..mediator.HorseLampMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartHorseLampCommand = class("StartHorseLampCommand", SimpleCommand)

function StartHorseLampCommand:execute(notification)

	local root = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerProxy(HorseLampProxy.new())
    platformFacade:registerMediator(HorseLampMediator.new(root))
end

return StartHorseLampCommand
