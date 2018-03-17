
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestFreeSitCommand = class("RequestFreeSitCommand", SimpleCommand)

function RequestFreeSitCommand:execute(notification)
	local body = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants

	local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		iTableID = body, 
		bAutoSit = true, 
		iChairID = 0, 
	}
	dump(pak1, "sit")
	local req1 = tarslib.encode(pak1, "JFGameClientProto::TFSMsgReqSitDown")
	gameFacade:sendNotification(GameConstants.SEND_SOCKET, req1, 204)
end

return RequestFreeSitCommand