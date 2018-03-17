
local GameRoomProxy = import("..proxy.GameRoomProxy") 
local GameVideoMediator = import("..mediator.GameVideoMediator") 

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestCreateVideoCommand = class("RequestCreateVideoCommand", SimpleCommand)

function RequestCreateVideoCommand:execute(notification)
    print("RequestCreateVideoCommand")
	local body = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	gameFacade:registerProxy(GameRoomProxy.new())

	local gameRoom = gameFacade:retrieveProxy("GameRoomProxy")
	gameRoom:getData().gameType = 10
	gameRoom:getData().roomKey = body.sRoomKey
    gameRoom:getData().gameId = body.gameId

	gameFacade:registerMediator(GameVideoMediator.new())
end

return RequestCreateVideoCommand