local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestJoinCptCommand = class("RequestJoinCptCommand", SimpleCommand)
local JoinMatchMediator = import("..mediator.JoinMatchMediator")
local GameRoomProxy = import("..proxy.GameRoomProxy") 

function RequestJoinCptCommand:execute(notification)
	print("RequestJoinCptCommand")
    local body = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local list = platformFacade:retrieveProxy("CompetitionListProxy"):getData().templateIdTomatchIdList
	local tarslib = cc.load("jfutils").Tars
	if not gameFacade:hasMediator("JoinMatchMediator") then
		gameFacade:registerMediator(JoinMatchMediator.new())
	end
	if not gameFacade:hasProxy("GameRoomProxy") then
		gameFacade:registerProxy(GameRoomProxy.new())
	end
    local gameRoom = gameFacade:retrieveProxy("GameRoomProxy")
    gameRoom:getData().gameType = 4
    dump(list,"GameRoomProxy",10)
    gameRoom:getData().gameId = list[body.templateId].gameId
    gameRoom:getData().roomId = "4:0"..list[body.templateId].startMode..":"..list[body.templateId].gameId
	local pak1 = {
		iMatchID = list[body.templateId].matchId,
	}
	local req1 = tarslib.encode(pak1, "JFGameClientProto::TKOMsgReqJoinMatch")
	gameFacade:sendNotification(GameConstants.SEND_SOCKET, req1, 401)
end

return RequestJoinCptCommand