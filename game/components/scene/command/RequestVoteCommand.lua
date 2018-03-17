
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestVoteCommand = class("RequestVoteCommand", SimpleCommand)

function RequestVoteCommand:execute(notification)
	local body = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local private = gameFacade:retrieveProxy("PrivateRoomProxy")

	local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		bVoteResult = body,
	}
	local req1 = tarslib.encode(pak1, "JFGameClientProto::TPMsgReqVoteResult")
	gameFacade:sendNotification(GameConstants.SEND_SOCKET, req1, 115)
end

return RequestVoteCommand