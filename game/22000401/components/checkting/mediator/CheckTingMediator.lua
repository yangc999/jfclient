local GameMusic = import("....GameMusic")
local Mediator = cc.load("puremvc").Mediator
local CheckTingMediator = class("CheckTingMediator", Mediator)

function CheckTingMediator:ctor()
    print("-------------->CheckTingMediator:ctor")
	CheckTingMediator.super.ctor(self, "CheckTingMediator")
end

function CheckTingMediator:listNotificationInterests()
    print("-------------->CheckTingMediator:listNotificationInterests")
	return
    {
        "CT_card",
        MyGameConstants.C_CLOSE_TINGCARDS,
        GameConstants.EXIT_GAME,
    }
end

function CheckTingMediator:onRegister()
    print("-------------->CheckTingMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    local image_root = gameFacade:retrieveMediator("MainMediator").image_root

    local csbPath = "ui_csb/CheckTingLayer.csb"
	local ui = cc.CSLoader:createNode(csbPath)
	self:setViewComponent(ui)
    image_root:addChild(self:getViewComponent(),MyGameConstants.ORDER_OUT_CARD)

    self.Panel_check_ting_5 = ui:getChildByName("Panel_check_ting_5")
    self.Panel_check_ting_5:setVisible(false)
    self.Panel_check_ting_more = ui:getChildByName("Panel_check_ting_more")
    self.Panel_check_ting_more:setVisible(false)
end

function CheckTingMediator:onRemove()
    print("-------------->RulesMediator:onRemove")
	self:setViewComponent(nil)
end

function CheckTingMediator:handleNotification(notification)
    print("-------------->RulesMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	
    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("CheckTingMediator")
        gameFacade:removeProxy("CheckTingProxy")
    elseif name == MyGameConstants.C_CLOSE_TINGCARDS then
        self:removeCheckTingMediator()
    elseif name == "CT_card" then
        self:showHuCards()
    end
end

-----------------------------------------------------------------------------
-- 删除该层
function CheckTingMediator:removeCheckTingMediator()
    print("CheckTingMediator:removeCheckTingMediator")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    self:getViewComponent():removeFromParent()
    gameFacade:removeMediator("CheckTingMediator")
    gameFacade:removeProxy("CheckTingProxy")
end

-- 显示胡哪些牌
function CheckTingMediator:showHuCards()
    print("CheckTingMediator:showHuCards")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local cardData = gameFacade:retrieveProxy("CheckTingProxy"):getData().CardData

    if #cardData <= 5 then
        self:showPanel_check_ting_5()
    else
        self:showPanel_check_ting_more()
    end
end

function CheckTingMediator:showPanel_check_ting_5()
    print("CheckTingMediator:showPanel_check_ting_5")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local visibleCards = gameFacade:retrieveProxy("HandCardProxy"):getData().VisibleCards
    local cardData = gameFacade:retrieveProxy("CheckTingProxy"):getData().CardData
    --dump(cardData,"cardData")
    self.Panel_check_ting_5:setVisible(true)
    self.Panel_check_ting_more:setVisible(false)
    local Image_bg = self.Panel_check_ting_5:getChildByName("Image_bg")
    local Image_hu = self.Panel_check_ting_5:getChildByName("Image_hu")
    Image_bg:setContentSize(880 - (150*(5 - #cardData)),142)
    local pos = Image_bg:convertToWorldSpace(cc.p(17,250))
    Image_hu:setPositionX(pos.x)

    local cardNode = {}
    for i=1,5 do
        cardNode[i] = Image_bg:getChildByName("Node_" .. i)
        if i <= #cardData then
            local path = "ui_res/Mahjong/Big/Big_"..tostring(cardData[i])..".png"
            local card = cardNode[i]:getChildByName("Image_card_item"):getChildByName("Image_card")
            local Image_value = card:getChildByName("Image_card"):getChildByName("Image_value")
            Image_value:loadTexture(path)
            cardNode[i]:setVisible(true)

            local Text_remain = cardNode[i]:getChildByName("Image_card_item"):getChildByName("Text_remain")
            local num = 4 - visibleCards[cardData[i]]
            Text_remain:setString(tostring(num >= 0 and num or 0))
        else
            cardNode[i]:setVisible(false)
        end
    end
end

function CheckTingMediator:showPanel_check_ting_more()
    print("CheckTingMediator:showPanel_check_ting_more")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local visibleCards = gameFacade:retrieveProxy("HandCardProxy"):getData().VisibleCards
    local cardData = gameFacade:retrieveProxy("CheckTingProxy"):getData().CardData
    dump(cardData,"cardData")
    self.Panel_check_ting_5:setVisible(false)
    self.Panel_check_ting_more:setVisible(true)
    local Image_bg = self.Panel_check_ting_more:getChildByName("Image_bg")

    self.Button_right = self.Panel_check_ting_more:getChildByName("Button_right")
    self.Button_right:setVisible(false)
    self.Button_right:addClickEventListener(function()
        self:rightCallBack()
    end)
    self.Button_left = self.Panel_check_ting_more:getChildByName("Button_left")
    self.Button_left:setVisible(false)
    self.Button_left:addClickEventListener(function()
        self:leftCallBack()
    end)

    if #cardData > 10 then
        self.Button_right:setVisible(true)
    end

    self.item = 1
    self.cardNode = {}
    for i=1,10 do
        self.cardNode[i] = Image_bg:getChildByName("Node_" .. i)
        if i <= #cardData then
            local path = "ui_res/Mahjong/Big/Big_"..tostring(cardData[i])..".png"
            local card = self.cardNode[i]:getChildByName("Image_card_item"):getChildByName("Image_card")
            local Image_value = card:getChildByName("Image_card"):getChildByName("Image_value")
            Image_value:loadTexture(path)
            self.cardNode[i]:setVisible(true)

            local Text_remain = self.cardNode[i]:getChildByName("Image_card_item"):getChildByName("Text_remain")
            local num = 4 - visibleCards[cardData[i]]
            Text_remain:setString(tostring(num >= 0 and num or 0))
        else
            self.cardNode[i]:setVisible(false)
        end
    end
end

function CheckTingMediator:rightCallBack()
    GameMusic:playClickEffect()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local visibleCards = gameFacade:retrieveProxy("HandCardProxy"):getData().VisibleCards
    local cardData = gameFacade:retrieveProxy("CheckTingProxy"):getData().CardData

    self.Button_left:setVisible(true)
    self.item = self.item + 1
    if self.item * 10 >= #cardData then
        self.Button_right:setVisible(false)
    end

     for i=1,10 do
        if i + (self.item-1)*10 <= #cardData then
            local path = "ui_res/Mahjong/Big/Big_"..tostring(cardData[i + (self.item-1)*10])..".png"
            local card = self.cardNode[i]:getChildByName("Image_card_item"):getChildByName("Image_card")
            local Image_value = card:getChildByName("Image_card"):getChildByName("Image_value")
            Image_value:loadTexture(path)
            self.cardNode[i]:setVisible(true)

            local Text_remain = self.cardNode[i]:getChildByName("Image_card_item"):getChildByName("Text_remain")
            local num = 4 - visibleCards[cardData[i]]
            Text_remain:setString(tostring(num >= 0 and num or 0))
        else
            self.cardNode[i]:setVisible(false)
        end
    end
end

function CheckTingMediator:leftCallBack()
    GameMusic:playClickEffect()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local visibleCards = gameFacade:retrieveProxy("HandCardProxy"):getData().VisibleCards
    local cardData = gameFacade:retrieveProxy("CheckTingProxy"):getData().CardData

    self.Button_right:setVisible(true)
    self.item = self.item - 1
    if self.item <= 1 then
        self.Button_left:setVisible(false)
    end

     for i=1,10 do
        if i + (self.item-1)*10  <= #cardData then
            local path = "ui_res/Mahjong/Big/Big_"..tostring(cardData[i + (self.item-1)*10])..".png"
            local card = self.cardNode[i]:getChildByName("Image_card_item"):getChildByName("Image_card")
            local Image_value = card:getChildByName("Image_card"):getChildByName("Image_value")
            Image_value:loadTexture(path)
            self.cardNode[i]:setVisible(true)

            local Text_remain = self.cardNode[i]:getChildByName("Image_card_item"):getChildByName("Text_remain")
            local num = 4 - visibleCards[cardData[i]]
            Text_remain:setString(tostring(num >= 0 and num or 0))
        else
            self.cardNode[i]:setVisible(false)
        end
    end
end

return CheckTingMediator