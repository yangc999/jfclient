
local WaitingRiseProxy = import("..proxy.WaitingRiseProxy")
local WaitingRiseMediator = import("..mediator.WaitingRiseMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartWaitRiseCommand = class("StartWaitRiseCommand", SimpleCommand)

function StartWaitRiseCommand:execute(notification)
	local scene = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	gameFacade:registerProxy(WaitingRiseProxy.new())
	gameFacade:registerMediator(WaitingRiseMediator.new())
end

return StartWaitRiseCommand