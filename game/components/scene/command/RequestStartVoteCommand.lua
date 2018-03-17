
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestStartVoteCommand = class("RequestStartVoteCommand", SimpleCommand)

function RequestStartVoteCommand:execute(notification)
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local private = gameFacade:retrieveProxy("PrivateRoomProxy")

	local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		eResson = 2,
	}
	local req1 = tarslib.encode(pak1, "JFGameClientProto::TPMsgReqDismissRoom")
	gameFacade:sendNotification(GameConstants.SEND_SOCKET, req1, 113)
end

return RequestStartVoteCommand