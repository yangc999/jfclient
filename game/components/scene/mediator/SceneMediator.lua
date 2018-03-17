
local Mediator = cc.load("puremvc").Mediator
local SceneMediator = class("SceneMediator", Mediator)

function SceneMediator:ctor()
	SceneMediator.super.ctor(self, "SceneMediator")
end

function SceneMediator:listNotificationInterests()
	local GameConstants = cc.exports.GameConstants
	return {GameConstants.EXIT_GAME}
end

function SceneMediator:onRegister()
	local scene = cc.Scene:create()
	cc.Director:getInstance():pushScene(scene)
	self.scene = scene

	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local gameRoom = gameFacade:retrieveProxy("GameRoomProxy")
	local gameId = gameRoom:getData().gameId
	local target = string.format("....%d.init", gameId)
	print("load target", target)
	import(target)

	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants

	--初始化对话框和消息框
	gameFacade:sendNotification(GameConstants.START_MESSAGE, scene)
	local msgData = {scene = scene, msg = msg}
    gameFacade:sendNotification(GameConstants.CREATE_MSGBOX, msgData)
    local msgData2 = {mType = 2,scene = scene, msg = msg}
    gameFacade:sendNotification(GameConstants.CREATE_MSGBOXEX, msgData2)
	gameFacade:sendNotification(GameConstants.SHOW_GAME, scene)


end

function SceneMediator:onRemove()
	--移除消息框
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	gameFacade:removeMediator("MsgBoxMediator")
	cc.Director:getInstance():popScene()
end

function SceneMediator:handleNotification(notification)
	local name = notification:getName()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	if name == GameConstants.EXIT_GAME then
		gameFacade:removeMediator("SceneMediator")
	end
end

return SceneMediator