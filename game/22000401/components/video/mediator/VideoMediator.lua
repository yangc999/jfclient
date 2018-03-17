local VideoMenuMediator = import("..mediator.VideoMenuMediator")
local VideoActMenuMediator = import("..mediator.VideoActMenuMediator")

local Mediator = cc.load("puremvc").Mediator
local VideoMediator = class("VideoMediator", Mediator)

function VideoMediator:ctor(root)
    print("-------------->VideoMediator:ctor")
	VideoMediator.super.ctor(self, "VideoMediator")
    self.root = root
end

function VideoMediator:listNotificationInterests()
    print("-------------->VideoMediator:listNotificationInterests")
    local GameConstants = cc.exports.GameConstants
	return
    {
        GameConstants.EXIT_GAME,
    }
end

function VideoMediator:onRegister()
    print("-------------->VideoMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    gameFacade:registerCommand(MyGameConstants.C_PLAY_VIDEO,cc.exports.PlayerVideoCommand)
    gameFacade:registerCommand(MyGameConstants.C_ADVANCE,cc.exports.AdvanceCommand)
    gameFacade:registerCommand(MyGameConstants.C_BACKWARD,cc.exports.BackwardCommand)

    local Panel_video = self.root:getChildByName("Panel_video")
	-- 按钮
    local Panel_menu = Panel_video:getChildByName("Panel_menu")
	gameFacade:registerMediator(VideoMenuMediator.new(Panel_menu))

    -- 动作按钮
    local Panel_act_menu = Panel_video:getChildByName("Panel_act_menu")
	gameFacade:registerMediator(VideoActMenuMediator.new(Panel_act_menu))

    gameFacade:sendNotification(MyGameConstants.C_PLAY_VIDEO)
end

function VideoMediator:onRemove()
    print("-------------->VideoMediator:onRemove")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    gameFacade:removeCommand(MyGameConstants.C_ADVANCE)
    gameFacade:removeCommand(MyGameConstants.C_BACKWARD)
    gameFacade:removeCommand(MyGameConstants.C_PLAY_VIDEO)
	self:setViewComponent(nil)
end

function VideoMediator:handleNotification(notification)
    print("-------------->VideoMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	
    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("VideoMediator")
        gameFacade:removeProxy("VideoProxy")
    end
end

return VideoMediator