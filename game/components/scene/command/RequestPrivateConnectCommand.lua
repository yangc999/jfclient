
local GameRoomProxy = import("..proxy.GameRoomProxy") 
local PrivateRoomMediator = import("..mediator.PrivateRoomMediator") 

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestPrivateConnectCommand = class("RequestPrivateConnectCommand", SimpleCommand)

function RequestPrivateConnectCommand:execute(notification)
	local body = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	gameFacade:registerProxy(GameRoomProxy.new())
	local gameRoom = gameFacade:retrieveProxy("GameRoomProxy")
	gameRoom:getData().gameType = 1
	gameRoom:getData().roomKey = body.sRoomKey
	gameFacade:registerMediator(PrivateRoomMediator.new())
end

return RequestPrivateConnectCommand