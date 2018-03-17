
local HallMediator = import("..mediator.HallMediator")
local HallProxy = import("..proxy.HallProxy")
local UserStateProxy = import("..proxy.UserStateProxy")
local SimpleCommand = cc.load("puremvc").SimpleCommand
local ShowHallCommand = class("ShowHallCommand", SimpleCommand)

function ShowHallCommand:execute(notification)
	local scene = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    platformFacade:registerProxy(HallProxy.new())
	platformFacade:registerProxy(UserStateProxy.new())
	platformFacade:registerMediator(HallMediator.new(scene))
end

return ShowHallCommand