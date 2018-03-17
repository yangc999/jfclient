local GameMusic = import("....GameMusic")
local GameLogic = import("....GameLogic")
local Mediator = cc.load("puremvc").Mediator
local TestMediator = class("TestMediator", Mediator)

function TestMediator:ctor()
    print("-------------->TestMediator:ctor")
	TestMediator.super.ctor(self, "TestMediator")
end

function TestMediator:listNotificationInterests()
    print("-------------->TestMediator:listNotificationInterests")
	return
    {
        GameConstants.EXIT_GAME,
    }
end

function TestMediator:onRegister()
    print("-------------->TestMediator:onRegister")

    self.iType = 2           -- 配牌类型   1-发牌  2-换牌  3-抓牌
    self.fapaiNums = 13      -- 发牌数量
    self.cardSelectTab = {}
    self.selectCardValue = {}        

	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    local image_root = gameFacade:retrieveMediator("MainMediator").image_root

    gameFacade:registerCommand(MyGameConstants.GAME_TEST,cc.exports.TestResultCommand)

    local csbPath = "ui_csb/TestLayer.csb"
	local ui = cc.CSLoader:createNode(csbPath)
    local Image_bg = ui:getChildByName("Panel"):getChildByName("Image_bg")
	self:setViewComponent(ui)
    image_root:addChild(self:getViewComponent(),MyGameConstants.ORDER_RULE)

    -- 提示
    local Image_tips = Image_bg:getChildByName("Image_tips")
    self.Image_tips = Image_tips
    Image_tips:setVisible(false)

    local Panel_button = Image_bg:getChildByName("Panel_button")
    -- 关闭
    local Button_close = Panel_button:getChildByName("Button_close")
    Button_close:addClickEventListener(function ()
        GameMusic:playClickEffect()
        self:getViewComponent():removeFromParent()
        gameFacade:removeMediator("TestMediator")
    end)

    -- 发牌
    local Button_fapai = Panel_button:getChildByName("Button_fapai")
    self.Button_fapai = Button_fapai
    Button_fapai:addClickEventListener(function()
        GameMusic:playClickEffect()
        self.iType = 1
        self:initButton()
    end)

    -- 换牌
    local Button_huanpai = Panel_button:getChildByName("Button_huanpai")
    self.Button_huanpai = Button_huanpai
    Button_huanpai:addClickEventListener(function()
        GameMusic:playClickEffect()
        self.iType = 2
        self:initButton()
    end)

    -- 抓牌
    local Button_zhuapai = Panel_button:getChildByName("Button_zhuapai")
    self.Button_zhuapai = Button_zhuapai
    Button_zhuapai:addClickEventListener(function()
        GameMusic:playClickEffect()
        self.iType = 3
        self:initButton()
    end)

    -- 重置
    local Button_cancel = Panel_button:getChildByName("Button_cancel")
    Button_cancel:addClickEventListener(function()
        GameMusic:playClickEffect()
        self.selectCardValue = {}
        for k,v in pairs(self.cardSelectTab) do
            v:setVisible(false)
        end
    end)

    -- 确认
    local Button_sure = Panel_button:getChildByName("Button_sure")
    Button_sure:addClickEventListener(function()
        GameMusic:playClickEffect()
        self:sureCallBack()
    end)

    local Panel_select = Image_bg:getChildByName("Panel_select")
    for i = 1, 18 do
        local button = Panel_select:getChildByName("Button_" .. i)
        button:setVisible(false)
        button:setZoomScale(-0.1)
        self.cardSelectTab[i] = button
        button:addClickEventListener( function()
            print(tostring(button.value))
            GameLogic:removeOneItemInTable(self.selectCardValue, button.value)
            self:showSelectCard()
        end )
    end

    local Panel_cardVaule = Image_bg:getChildByName("Panel_cardVaule")
    for i=1,37 do
        if i % 10 ~= 0 then
            local button = Panel_cardVaule:getChildByName("Button_" .. i)
            button:setZoomScale(-0.1)
            button:addClickEventListener(function ()
                if #self.selectCardValue < 18 then
                    self.selectCardValue[#self.selectCardValue + 1] = i
                    self:showSelectCard()
                end
            end)
        end
    end

    self:initButton()
end

function TestMediator:onRemove()
    print("-------------->TestMediator:onRemove")
	self:setViewComponent(nil)
end

function TestMediator:handleNotification(notification)
    print("-------------->TestMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	
    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("TestMediator")
    end
end

---------------------------------------------------------------------------
-- 初始化按钮
function TestMediator:initButton()
    self.Button_fapai:loadTextures("ui_res/Test/2.png","","")
    self.Button_huanpai:loadTextures("ui_res/Test/2.png","","")
    self.Button_zhuapai:loadTextures("ui_res/Test/2.png","","")

    if self.iType == 1 then
        self.Button_fapai:loadTextures("ui_res/Test/1.png","","")
    elseif self.iType == 2 then 
        self.Button_huanpai:loadTextures("ui_res/Test/1.png","","")
    elseif self.iType == 3 then 
        self.Button_zhuapai:loadTextures("ui_res/Test/1.png","","")
    end
end

function TestMediator:showSelectCard()
    dump(self.selectCardValue,"selectCardValue")
    for k, v in pairs(self.cardSelectTab) do
        v:setVisible(false)
    end

    for i=1,#self.selectCardValue do
        if self.cardSelectTab[i] ~= nil then
            self.cardSelectTab[i].value = self.selectCardValue[i]
            local image = self.cardSelectTab[i]:getChildByName("Image_card")
            image:loadTexture("ui_res/Mahjong/Small/Small_" .. self.selectCardValue[i] .. ".png" )
            self.cardSelectTab[i]:setVisible(true)
        end
    end
end

function TestMediator:sureCallBack()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local handCards = gameFacade:retrieveProxy("HandCardProxy"):getData().SelfHandCards  -- 手牌

    if self.iType == 1 then
        if #self.selectCardValue ~= self.fapaiNums then
            self:tipsAnimate()
            return
        end
    elseif self.iType == 2 then
        if #self.selectCardValue ~= #handCards then
            self:tipsAnimate()
            return
        end
    elseif self.iType == 3 then
        if #self.selectCardValue ~= 1 then
            self:tipsAnimate()
            return
        end
    end

    local pak1 = {
        iCID = GameUtils:getInstance():getSelfServerChair(),
        iType = self.iType,
        vTiles = self.selectCardValue
    }
    GameUtils:getInstance():sendNotification(32, pak1, "MJProto::TMJ_Test")

    self:getViewComponent():removeFromParent()
    gameFacade:removeMediator("TestMediator")
end

-- 提示框动画
function TestMediator:tipsAnimate()
    self.Image_tips:stopAllActions()
    self.Image_tips:setOpacity(255)
    self.Image_tips:setVisible(true)
    self.Image_tips:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.FadeOut:create(1)))
end

return TestMediator