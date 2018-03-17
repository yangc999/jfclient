
local MainMediator = import("..mediator.MainMediator")
local MainProxy = import("..proxy.MainProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local ShowMainCommand = class("ShowMainCommand", SimpleCommand)

function ShowMainCommand:ctor()
    print("-------------->ShowMainCommand:ctor")
    ShowMainCommand.super.ctor(self)
end

function ShowMainCommand:execute(notification)
    print("-------------->ShowMainCommand:execute")
    cc.exports.GameUtils = import("....GameUtils"):getInstance()
	local scene = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")

    gameFacade:registerProxy(MainProxy.new())
	gameFacade:registerMediator(MainMediator.new(scene))

    -- 房卡场发送坐桌消息
    if GameUtils:getInstance():getGameType() == 1 then
        gameFacade:sendNotification(GameConstants.REQUEST_PRVSIT)
    end
end

return ShowMainCommand