
local SimpleCommand = cc.load("puremvc").SimpleCommand
local SubRoomKeyCommand = class("SubRoomKeyCommand", SimpleCommand)

function SubRoomKeyCommand:execute(notification)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")	
	local roomKey = platformFacade:retrieveProxy("RoomKeyProxy")
	roomKey:getData().key = string.sub(roomKey:getData().key, 1, -2)
end

return SubRoomKeyCommand