local StyleMediator = import(".StyleMediator")
local LanguageMediator = import(".LanguageMediator")
local FunctionMediator = import(".FunctionMediator")
local GameMusic = import("....GameMusic")

local Mediator = cc.load("puremvc").Mediator
local SettingMediator = class("SettingMediator", Mediator)

function SettingMediator:ctor()
    print("-------------->SettingMediator:ctor")
	SettingMediator.super.ctor(self, "SettingMediator")
end

function SettingMediator:listNotificationInterests()
    print("-------------->SettingMediator:listNotificationInterests")
	return
    {
        GameConstants.EXIT_GAME,
    }
end

function SettingMediator:onRegister()
    print("-------------->SettingMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    local image_root = gameFacade:retrieveMediator("MainMediator").image_root

    local csbPath = "ui_csb/SettingLayer.csb"
	local ui = cc.CSLoader:createNode(csbPath)
    local Image_bg = ui:getChildByName("Image_bg")
	self:setViewComponent(ui)
    image_root:addChild(self:getViewComponent(),MyGameConstants.ORDER_SETTING)
     self.item = 1

    -- 关闭
    local Button_close = Image_bg:getChildByName("Button_close")
    Button_close:addClickEventListener(function ()
        GameMusic:playClickEffect()
        self:getViewComponent():removeFromParent()
        gameFacade:removeMediator("StyleMediator")
        gameFacade:removeMediator("LanguageMediator")
        gameFacade:removeMediator("FunctionMediator")
        gameFacade:removeMediator("SettingMediator")
    end)

    -- 解散房间(房卡场未开始游戏不显示)
    local Button_jiesan = Image_bg:getChildByName("Button_jiesan")
    Button_jiesan:setVisible(false)
    local gameRoom = gameFacade:retrieveProxy("GameRoomProxy")
    if GameUtils:getInstance():getGameType() == 1 and gameRoom:getData().gameState >= MyGameConstants.GameStation.GS_WAIT_PLAYING then
        Button_jiesan:setVisible(true)
    end       
    Button_jiesan:addClickEventListener( function()
        GameMusic:playClickEffect()
        self:getViewComponent():removeFromParent()
        gameFacade:removeMediator("StyleMediator")
        gameFacade:removeMediator("LanguageMediator")
        gameFacade:removeMediator("FunctionMediator")
        gameFacade:removeMediator("SettingMediator")

        gameFacade:sendNotification(GameConstants.REQUEST_STVOTE)
        gameFacade:sendNotification(GameConstants.REQUEST_VOTE, true)
    end )

    
    -- 功能
    local Panel_func = Image_bg:getChildByName("Panel_func")
    self.Panel_func = Panel_func
    gameFacade:registerMediator(FunctionMediator.new(Panel_func))
    self.Button_func = Image_bg:getChildByName("Button_func")
    self.Button_func:addClickEventListener(function()
        GameMusic:playClickEffect()
        self.item = 1
        self:uiUpdate()
    end)

    -- 语言
    local Panel_language = Image_bg:getChildByName("Panel_language")
    self.Panel_language = Panel_language
    gameFacade:registerMediator(LanguageMediator.new(Panel_language))
    self.Button_language = Image_bg:getChildByName("Button_language")
    self.Button_language:addClickEventListener(function()
        GameMusic:playClickEffect()
        self.item = 2
        self:uiUpdate()
    end)

    -- 风格
    local Panel_style = Image_bg:getChildByName("Panel_style")
    self.Panel_style = Panel_style
    gameFacade:registerMediator(StyleMediator.new(Panel_style))
    self.Button_style = Image_bg:getChildByName("Button_style")
    self.Button_style:addClickEventListener(function()
        GameMusic:playClickEffect()
        self.item = 3
        self:uiUpdate()
        local gameFacade = cc.load("puremvc").Facade.getInstance("game")
        gameFacade:sendNotification(MyGameConstants.C_UPDATE_TABLECLOTH)
        gameFacade:sendNotification(MyGameConstants.C_UPDATE_CARDBACK)
    end)

    self:uiUpdate()
end

function SettingMediator:onRemove()
    print("-------------->SettingMediator:onRemove")
	self:setViewComponent(nil)
end

function SettingMediator:handleNotification(notification)
    print("-------------->SettingMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	
    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("SettingMediator")
    end
end

---------------------------------------------------------------------------
function SettingMediator:uiUpdate()
    if self.item == 1 then
        self.Button_func:loadTextures("ui_res/Setting/gongneng2.png","ui_res/Setting/gongneng2.png","")
        self.Button_language:loadTextures("ui_res/Setting/yuyan1.png","ui_res/Setting/yuyan1.png","")
        self.Button_style:loadTextures("ui_res/Setting/fengge1.png","ui_res/Setting/fengge1.png","")

        self.Button_func:setLocalZOrder(2)
        self.Button_language:setLocalZOrder(1)
        self.Button_style:setLocalZOrder(1)

        self.Panel_func:setVisible(true)
        self.Panel_language:setVisible(false)
        self.Panel_style:setVisible(false)
    elseif self.item == 2 then
        self.Button_func:loadTextures("ui_res/Setting/gongneng1.png","ui_res/Setting/gongneng1.png","")
        self.Button_language:loadTextures("ui_res/Setting/yuyan2.png","ui_res/Setting/yuyan2.png","")
        self.Button_style:loadTextures("ui_res/Setting/fengge1.png","ui_res/Setting/fengge1.png","")

        self.Button_func:setLocalZOrder(1)
        self.Button_language:setLocalZOrder(2)
        self.Button_style:setLocalZOrder(1)

        self.Panel_func:setVisible(false)
        self.Panel_language:setVisible(true)
        self.Panel_style:setVisible(false)
    elseif self.item == 3 then
        self.Button_func:loadTextures("ui_res/Setting/gongneng1.png","ui_res/Setting/gongneng1.png","")
        self.Button_language:loadTextures("ui_res/Setting/yuyan1.png","ui_res/Setting/yuyan1.png","")
        self.Button_style:loadTextures("ui_res/Setting/fengge2.png","ui_res/Setting/fengge2.png","")

        self.Button_func:setLocalZOrder(1)
        self.Button_language:setLocalZOrder(1)
        self.Button_style:setLocalZOrder(2)

        self.Panel_func:setVisible(false)
        self.Panel_language:setVisible(false)
        self.Panel_style:setVisible(true)
    end
end


return SettingMediator