
local GameRoomProxy = import("..proxy.GameRoomProxy") 
local FreeRoomMediator = import("..mediator.FreeRoomMediator") 

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestFreeConnectCommand = class("RequestFreeConnectCommand", SimpleCommand)

function RequestFreeConnectCommand:execute(notification)
	local body = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	gameFacade:registerProxy(GameRoomProxy.new())
	local gameRoom = gameFacade:retrieveProxy("GameRoomProxy")
	gameRoom:getData().gameType = 2
	gameRoom:getData().gameId = body.gameId
	gameRoom:getData().serverId = body.serverId
	gameRoom:getData().roomId = body.roomId
	gameFacade:registerMediator(FreeRoomMediator.new())
	
	local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		iTableID = body.idx, 
	}
	dump(pak1, "enter")
	local req1 = tarslib.encode(pak1, "JFGameClientProto::TFSMsgReqEnterRoom")
	gameFacade:sendNotification(GameConstants.SEND_SOCKET, req1, 201)
end

return RequestFreeConnectCommand