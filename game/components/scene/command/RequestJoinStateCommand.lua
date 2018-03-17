local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestJoinStateCommand = class("RequestJoinStateCommand", SimpleCommand)
local JoinMatchMediator = import("..mediator.JoinMatchMediator")
local GameRoomProxy = import("..proxy.GameRoomProxy") 

function RequestJoinStateCommand:execute(notification)
	print("RequestJoinStateCommand")
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
    gameRoom:getData().gameId = body.gameId
    gameRoom:getData().roomId = "4:00:"..body.gameId
	local pak1 = {
    gameId=gameRoom:getData().gameId
    }
	local req1 = tarslib.encode(pak1, "JFGameClientProto::TKOMsgReqCheckMatch")
	gameFacade:sendNotification(GameConstants.SEND_SOCKET, req1, 416)
end

return RequestJoinStateCommand