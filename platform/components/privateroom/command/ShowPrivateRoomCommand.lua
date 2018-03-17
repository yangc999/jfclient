
local PrivateRoomMediator = import("..mediator.PrivateRoomMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local ShowPrivateRoomCommand = class("ShowPrivateRoomCommand", SimpleCommand)

function ShowPrivateRoomCommand:execute(notification)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerMediator(PrivateRoomMediator.new())
end

return ShowPrivateRoomCommand