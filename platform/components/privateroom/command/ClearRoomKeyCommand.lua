
local SimpleCommand = cc.load("puremvc").SimpleCommand
local ClearRoomKeyCommand = class("ClearRoomKeyCommand", SimpleCommand)

function ClearRoomKeyCommand:execute(notification)
	print("change choice")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")	
	local roomKey = platformFacade:retrieveProxy("RoomKeyProxy")
	roomKey:getData().key = ""
end

return ClearRoomKeyCommand