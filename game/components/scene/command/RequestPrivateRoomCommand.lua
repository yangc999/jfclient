
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestPrivateRoomCommand = class("RequestPrivateRoomCommand", SimpleCommand)

function RequestPrivateRoomCommand:execute(notification)
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local gameRoom = gameFacade:retrieveProxy("GameRoomProxy")

	local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		sPrivateRoomKey = gameRoom:getData().roomKey,
	}
	dump(pak1, "privateroom")
	local req1 = tarslib.encode(pak1, "JFGameClientProto::TPMsgReqEnterRoom")
	gameFacade:sendNotification(GameConstants.SEND_SOCKET, req1, 101)
end

return RequestPrivateRoomCommand