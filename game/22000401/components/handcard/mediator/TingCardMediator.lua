
local Mediator = cc.load("puremvc").Mediator
local ButtonPanelMediator = class("ButtonPanelMediator", Mediator)

function ButtonPanelMediator:ctor()
    print("-------------->ButtonPanelMediator:ctor")
	ButtonPanelMediator.super.ctor(self, "ButtonPanelMediator")
end

function ButtonPanelMediator:listNotificationInterests()
    print("-------------->ButtonPanelMediator:listNotificationInterests")
	local MyGameConstants = cc.exports.MyGameConstants
	return {
        MyGameConstants.C_BUTTONPANEL_OPEN,
        GameConstants.EXIT_GAME,
	}
end

function ButtonPanelMediator:onRegister()
    print("-------------->ButtonPanelMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    local image_root = gameFacade:retrieveMediator("MainMediator").image_root

    local csbPath = "ui_csb/ButtonPanelLayer.csb"
	local ui = cc.CSLoader:createNode(csbPath)
    self.ui = ui
    ui:setVisible(false)
	self:setViewComponent(ui)
    image_root:addChild(self:getViewComponent(),MyGameConstants.ORDER_GAME_ANIMATE)

    -- 弹开panel
    local Panel_fickbtn = ui:getChildByName("Panel_fickbtn")
    Panel_fickbtn:addClickEventListener(function ()
        
    end)

    -- 弹开
    local Button_fick = Panel_fickbtn:getChildByName("Button_fick")
    Button_fick:addClickEventListener(function ()
        self.ui:setVisible(false)
        gameFacade:sendNotification(MyGameConstants.C_BUTTONPANEL_CLOSE)
    end)

    -- 设置
    local Button_set = Panel_fickbtn:getChildByName("Button_set")
    Button_set:addClickEventListener(function ()
        gameFacade:sendNotification(MyGameConstants.C_SET_OPEN)
    end)

    -- 帮助
    local Button_help = Panel_fickbtn:getChildByName("Button_help")
    Button_help:addClickEventListener(function ()
        gameFacade:sendNotification(MyGameConstants.C_HELP_OPEN)
    end)

    -- 金币场返回按钮
    local Button_coinback = Panel_fickbtn:getChildByName("Button_coinback")
    Button_coinback:addClickEventListener(function ()
        if GameUtils:getInstance():getGameType() == 2 then
            gameFacade:sendNotification(GameConstants.REQUEST_FRELEAVE)
        elseif GameUtils:getInstance():getGameType() == 3 then  
            gameFacade:sendNotification(GameConstants.REQUEST_QUKLEAVE)
        end
        gameFacade:sendNotification(GameConstants.EXIT_GAME)
    end)

    if GameUtils:getInstance():getGameType() == 1 then -- 房卡场
        Button_coinback:setVisible(false)
    end
end

function ButtonPanelMediator:onRemove()
    print("-------------->ButtonPanelMediator:onRemove")
	self:setViewComponent(nil)
end

function ButtonPanelMediator:handleNotification(notification)
    print("-------------->ButtonPanelMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local MyGameConstants = cc.exports.MyGameConstants
	
    if name == MyGameConstants.C_BUTTONPANEL_OPEN then
        self:openView()
    elseif name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("ButtonPanelMediator")
    end
end

---------------------------------------------------------------------------
function ButtonPanelMediator:openView()
    self.ui:setVisible(true)
end

return ButtonPanelMediator