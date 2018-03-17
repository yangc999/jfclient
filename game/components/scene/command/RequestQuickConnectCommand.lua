
local GameRoomProxy = import("..proxy.GameRoomProxy") 
local QuickRoomMediator = import("..mediator.QuickRoomMediator") 

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestQuickConnectCommand = class("RequestQuickConnectCommand", SimpleCommand)

function RequestQuickConnectCommand:execute(notification)
	print("RequestQuickConnectCommand execute")
	local body = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	gameFacade:registerProxy(GameRoomProxy.new())
	local gameRoom = gameFacade:retrieveProxy("GameRoomProxy")
	gameRoom:getData().gameType = 3
	gameRoom:getData().gameId = body.gameId
	gameRoom:getData().roomId = body.roomId
	gameFacade:registerMediator(QuickRoomMediator.new())
	gameFacade:sendNotification(GameConstants.START_GAME)

	local desk = gameFacade:retrieveProxy("DeskProxy")
	local userinfo = platformFacade:retrieveProxy("UserInfoProxy")
	local id = userinfo:getData().headId or 0
	local img = string.format("%s%d.png", id < 6 and "boy" or "girl", id < 6 and id or id-6)
	local path = "platform_res/common/" .. img
	local login = platformFacade:retrieveProxy("LoginProxy")
	local player = clone(desk:getData().player)
	player[0] = {
		name = userinfo:getData().nickName, 
		uid = login:getData().uid, 
		head = userinfo:getData().headStr or path, 
		gender = userinfo:getData().gender, 
		state = 0,
	}	
	desk:getData().player = player
end

return RequestQuickConnectCommand