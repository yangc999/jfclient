
local RoomListProxy = import("..proxy.RoomListProxy")
local RoomListMediator = import("..mediator.RoomListMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartRoomListCommand = class("StartRoomListCommand", SimpleCommand)

function StartRoomListCommand:execute(notification)
	local root = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerProxy(RoomListProxy.new())
	platformFacade:registerMediator(RoomListMediator.new(root))
end

return StartRoomListCommand