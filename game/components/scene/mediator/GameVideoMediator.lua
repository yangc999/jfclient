
local Mediator = cc.load("puremvc").Mediator
local GameVideoMediator = class("GameVideoMediator", Mediator)

function GameVideoMediator:ctor()
    print("GameVideoMediator")
	GameVideoMediator.super.ctor(self, "GameVideoMediator")
end

function GameVideoMediator:listNotificationInterests()
	local GameConstants = cc.exports.GameConstants
	return {
		GameConstants.EXIT_GAME
	}
end

function GameVideoMediator:onRegister()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	gameFacade:registerCommand(GameConstants.DOWNLOAD_HEAD, cc.exports.DownloadPlayerHeadCommand)
	gameFacade:sendNotification(GameConstants.START_GAME)
end

function GameVideoMediator:onRemove()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	gameFacade:removeCommand(GameConstants.DOWNLOAD_HEAD)
    --gameFacade:removeCommand(GameConstants.REQUEST_VIDEOCREATE)
	gameFacade:removeProxy("GameRoomProxy")
end

function GameVideoMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local GameConstants = cc.exports.GameConstants
	local PlatformConstants = cc.exports.PlatformConstants
	if name == GameConstants.EXIT_GAME then
		gameFacade:removeMediator("GameVideoMediator")
	end
end

return GameVideoMediator