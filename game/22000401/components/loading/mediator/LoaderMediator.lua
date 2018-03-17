local Mediator = cc.load("puremvc").Mediator
local LoaderMediator = class("LoaderMediator", Mediator)

function LoaderMediator:ctor()
    print("-------------->LoaderMediator:ctor")
	LoaderMediator.super.ctor(self, "LoaderMediator")
    print("内存000", string.format("%p", self))
end

function LoaderMediator:listNotificationInterests()
    print("-------------->LoaderMediator:listNotificationInterests")
	return
    {
        GameConstants.EXIT_GAME,
        MyGameConstants.C_SHOW_LOADING_ANIMATE,
        MyGameConstants.C_CLOSE_LOADING_ANIMATE,
    }
end

function LoaderMediator:onRegister()
    print("-------------->LoaderMediator:onRegister")
    
end

function LoaderMediator:onRemove()
    print("-------------->LoaderMediator:onRemove")
	self:setViewComponent(nil)
end

function LoaderMediator:handleNotification(notification)
    print("-------------->LoaderMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	
    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("LoadMediator")
    elseif name == MyGameConstants.C_SHOW_LOADING_ANIMATE then
        self:showLoadingAnimate()
    elseif name == MyGameConstants.C_CLOSE_LOADING_ANIMATE then
        self:closeLoadingAnimate()
    end
end

---------------------------------------------------------------------------
-- 显示加载动画
function LoaderMediator:showLoadingAnimate()
    print("LoaderMediator:showLoadingAnimate")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local scene = gameFacade:retrieveMediator("MainMediator").scene

    local layout = ccui.Layout:create()
    self.layout = layout
    print("内存222", string.format("%p", self))
    layout:setContentSize(1280,720)
    layout:setTouchEnabled(true)
    layout:setBackGroundImage("ui_res/auto_shade.png")
    scene:addChild(layout)

    local node = cc.CSLoader:createNode("animate/load/load.csb")
    local action = cc.CSLoader:createTimeline("animate/load/load.csb")
    action:gotoFrameAndPlay(0)
    node:runAction(action)
    node:setPosition(640,360)
    layout:addChild(node)

    gameFacade:sendNotification(MyGameConstants.C_CLOSE_LOADING_ANIMATE)
end

-- 关闭加载动画
function LoaderMediator:closeLoadingAnimate()
    print("LoaderMediator:closeLoadingAnimate")
    print("内存333", string.format("%p", self))
    if self.layout ~= nil then
        print("111")
        self.layout:removeFromParent()
        self.layout = nil
    end
     print("222")
end

return LoaderMediator