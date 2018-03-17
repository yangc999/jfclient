
local RoomKeyProxy = import("..proxy.RoomKeyProxy")
local JoinRoomMediator = import("..mediator.JoinRoomMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local ShowJoinRoomCommand = class("ShowJoinRoomCommand", SimpleCommand)

function ShowJoinRoomCommand:execute(notification)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerProxy(RoomKeyProxy.new())
	platformFacade:registerMediator(JoinRoomMediator.new())
end

return ShowJoinRoomCommand