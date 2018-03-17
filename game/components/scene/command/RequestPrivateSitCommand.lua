
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestPrivateSitCommand = class("RequestPrivateSitCommand", SimpleCommand)

function RequestPrivateSitCommand:execute(notification)
	local body = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants

	local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		bAutoSit = body and false or true, 
		iChairID = body and body or 0, 
	}
	dump(pak1, "sit")
	local req1 = tarslib.encode(pak1, "JFGameClientProto::TPMsgReqSitDown")
	gameFacade:sendNotification(GameConstants.SEND_SOCKET, req1, 107)
end

return RequestPrivateSitCommand