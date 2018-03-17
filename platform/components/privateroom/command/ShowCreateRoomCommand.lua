
local RoomConfigProxy = import("..proxy.RoomConfigProxy")
local CreateRoomMediator = import("..mediator.CreateRoomMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local ShowCreateRoomCommand = class("ShowCreateRoomCommand", SimpleCommand)

function ShowCreateRoomCommand:execute(notification)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerProxy(RoomConfigProxy.new())
	platformFacade:registerMediator(CreateRoomMediator.new())
end

return ShowCreateRoomCommand