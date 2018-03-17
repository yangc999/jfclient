
local SimpleCommand = cc.load("puremvc").SimpleCommand
local AddRoomKeyCommand = class("AddRoomKeyCommand", SimpleCommand)

function AddRoomKeyCommand:execute(notification)
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")	
	local roomKey = platformFacade:retrieveProxy("RoomKeyProxy")
	if string.len(roomKey:getData().key) < 6 then
		roomKey:getData().key = roomKey:getData().key .. tostring(body)
	end
end

return AddRoomKeyCommand