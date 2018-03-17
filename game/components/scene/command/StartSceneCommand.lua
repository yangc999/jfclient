
local SceneMediator = import("..mediator.SceneMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartSceneCommand = class("StartSceneCommand", SimpleCommand)

function StartSceneCommand:execute(notification)
	local scene = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	gameFacade:registerMediator(SceneMediator.new())
end

return StartSceneCommand