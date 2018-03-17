local GameMusic = import("....GameMusic")
local Mediator = cc.load("puremvc").Mediator
local HelpMediator = class("HelpMediator", Mediator)

function HelpMediator:ctor()
    print("-------------->HelpMediator:ctor")
	HelpMediator.super.ctor(self, "HelpMediator")
end

function HelpMediator:listNotificationInterests()
    print("-------------->HelpMediator:listNotificationInterests")
	return
    {
        GameConstants.EXIT_GAME,
    }
end

function HelpMediator:onRegister()
    print("-------------->HelpMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    local image_root = gameFacade:retrieveMediator("MainMediator").image_root
    self.item = 1

    local csbPath = "ui_csb/HelpLayer.csb"
	local ui = cc.CSLoader:createNode(csbPath)
    local Panel_help = ui:getChildByName("Panel_help")
    local Panel_content = Panel_help:getChildByName("Panel_content")
	self:setViewComponent(ui)
    image_root:addChild(self:getViewComponent(),MyGameConstants.ORDER_RULE)

    -- 关闭
    local Button_close = Panel_help:getChildByName("Button_close")
    Button_close:addClickEventListener(function ()
        self:getViewComponent():removeFromParent()
        gameFacade:removeMediator("HelpMediator")
    end)

    self.Image_tip = Panel_content:getChildByName("Image_tip")

    -- 基本规则
    local Button_basic = Panel_content:getChildByName("Button_basic")
    Button_basic:addClickEventListener(function()
        self:basicCallBack()
    end)
    self.ScrollView_basic = Panel_help:getChildByName("ScrollView_basic")
    self.ScrollView_basic:setVisible(false)

    -- 基本番型
    local Button_foreign = Panel_content:getChildByName("Button_foreign")
    Button_foreign:addClickEventListener(function()
        self:foreignCallBack()
    end)
    self.ScrollView_foreign = Panel_help:getChildByName("ScrollView_foreign")
    self.ScrollView_foreign:setVisible(false)

    -- 特殊规则
    local Button_sepcial = Panel_content:getChildByName("Button_sepcial")
    Button_sepcial:addClickEventListener(function()
        self:specialCallBack()
    end)
    self.ScrollView_sepcial = Panel_help:getChildByName("ScrollView_sepcial")
    self.ScrollView_sepcial:setVisible(false)

    self:initView()
end

function HelpMediator:onRemove()
    print("-------------->HelpMediator:onRemove")
	self:setViewComponent(nil)
end

function HelpMediator:handleNotification(notification)
    print("-------------->HelpMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	
    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("HelpMediator")
    end
end

---------------------------------------------------------------------------
-- 初始化
function HelpMediator:initView()
    self:showTest()
    self.Image_tip:loadTexture("ui_res/help/basic.png")
end

-- 基本牌型
function HelpMediator:basicCallBack()
    GameMusic:playClickEffect()
    self.item = 1
    self:showTest()
    self.Image_tip:loadTexture("ui_res/help/basic.png")
end

-- 基本番型
function HelpMediator:foreignCallBack()
    GameMusic:playClickEffect()
    self.item = 2
    self:showTest()
    self.Image_tip:loadTexture("ui_res/help/foreign.png")
end

-- 特殊规则
function HelpMediator:specialCallBack()
    GameMusic:playClickEffect()
    self.item = 3
    self:showTest()
    self.Image_tip:loadTexture("ui_res/help/special.png")
end

-- 显示内容
function HelpMediator:showTest()
    self.ScrollView_basic:setVisible(false)
    self.ScrollView_foreign:setVisible(false)
    self.ScrollView_sepcial:setVisible(false)
    if self.item == 1 then
        self.ScrollView_basic:setVisible(true)
    elseif self.item == 2 then
        self.ScrollView_foreign:setVisible(true)
    elseif self.item == 3 then
        self.ScrollView_sepcial:setVisible(true)
    end
end

return HelpMediator