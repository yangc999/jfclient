
local Mediator = cc.load("puremvc").Mediator
local EatChoiceMediator = class("EatChoiceMediator", Mediator)

function EatChoiceMediator:ctor(root)
    print("-------------->EatChoiceMediator:ctor")
	EatChoiceMediator.super.ctor(self, "EatChoiceMediator",root)
    self.root = root
end

function EatChoiceMediator:listNotificationInterests()
    print("-------------->EatChoiceMediator:listNotificationInterests")
	local GameConstants = cc.exports.GameConstants
	return {
		GameConstants.EXIT_GAME,
	}
end

function EatChoiceMediator:onRegister()
    print("-------------->EatChoiceMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local MyGameConstants = cc.exports.MyGameConstants

    local MyGameConstants = cc.exports.MyGameConstants
    self.choicesNum = 0

    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("CPGMenuProxy"):getData()
    local ActNotifyData = data.ActNotifyData

    local eatFlag = ActNotifyData.usChiFlags
        
    if eatFlag == MyGameConstants.EatType.usTZ 
        or eatFlag == MyGameConstants.EatType.usZW 
        or eatFlag == MyGameConstants.EatType.usTW then
        self.choicesNum = 2
    else
        self.choicesNum = 3
    end

    local csbPath = "ui_csb/EatChoiceLayer.csb"
	local ui = cc.CSLoader:createNode(csbPath)
	self:setViewComponent(ui)
	self.root:addChild(self:getViewComponent(),5)

    local Panel_root = ui:getChildByName("Panel_eat_choices")
    local Panel_eat_2_choices = Panel_root:getChildByName("Panel_eat_2_choices")
    local Panel_eat_3_choices = Panel_root:getChildByName("Panel_eat_3_choices")

    if self.choicesNum == 2 then
        Panel_eat_3_choices:setVisible(false)
        self.Panel_eat_choices = Panel_eat_2_choices
    elseif self.choicesNum == 3 then
        Panel_eat_2_choices:setVisible(false)
        self.Panel_eat_choices = Panel_eat_3_choices
    end

    local Image_bg = self.Panel_eat_choices:getChildByName("Image_bg")
    self.Image_bg = Image_bg

    self.Choices = {}
    for i = 1,self.choicesNum do
        self.Choices[i] = Image_bg:getChildByName("Panel_eat_choice_" .. i)
        self.Choices[i].Cards = {}
        for j = 1 , 3 do 
            local card_bg = self.Choices[i]:getChildByName("Image_card_" .. j):getChildByName("Image_card")
            card_bg:addClickEventListener(function()
                self:chooseEat(i)
            end)
            self.Choices[i].Cards[j] = card_bg:getChildByName("Image_value")
        end
    end
    
    -- 吃的牌值
    local eatValue = ActNotifyData.eatValue

    --客户端显示 可选择的吃牌信息
    local cards = {}

    if eatFlag == MyGameConstants.EatType.usTZ then
        cards = {{eatValue-1,eatValue,eatValue+1},{eatValue,eatValue+1,eatValue+2}}
    elseif eatFlag == MyGameConstants.EatType.usTW then
        cards = {{eatValue-2,eatValue-1,eatValue},{eatValue,eatValue+1,eatValue+2}}
    elseif eatFlag == MyGameConstants.EatType.usZW then
        cards = {{eatValue-2,eatValue-1,eatValue},{eatValue-1,eatValue,eatValue+1}}
    else
        cards = {{eatValue-2,eatValue-1,eatValue},{eatValue-1,eatValue,eatValue+1},{eatValue,eatValue+1,eatValue+2}}
    end

    if eatValue >= 31 and eatValue<= 34 then
        --风牌吃的时候显示特殊处理
        for i,cardsitem in pairs (cards) do
            for j = 1,3 do
                if cardsitem[j] <31 then
                    cardsitem[j] = cardsitem[j] + 4
                elseif cardsitem[j] >34 then
                    cardsitem[j] = cardsitem[j] - 4
                end
            end
        end
    end

    local touch_listener = cc.EventListenerTouchOneByOne:create()
    touch_listener:setSwallowTouches(false) 
    touch_listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self:getEventDispatcher()      
    eventDispatcher:addEventListenerWithSceneGraphPriority(touch_listener, self.Image_bg) 
    self:initEatChoiceCards(cards)
end

function EatChoiceMediator:onRemove()
    print("-------------->EatChoiceMediator:onRemove")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	if self:getViewComponent() ~= nil then
        self:getViewComponent():removeFromParent()
    end
	self:setViewComponent(nil)
end

function EatChoiceMediator:handleNotification(notification)
    print("-------------->EatChoiceMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	local MyGameConstants = cc.exports.MyGameConstants

    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("EatChoiceMediator")
    end
end

--------------------------------------------------------------------------------------
function EatChoiceMediator:onTouchBegan(touch, event)
    
    local p = self.Image_bg:convertToNodeSpace(touch:getLocation())
    local  rect = cc.rect(0, 0, self.Image_bg:getContentSize().width, self.Image_bg:getContentSize().height)
    if cc.rectContainsPoint(rect, p) then
        
    else
        local gameFacade = cc.load("puremvc").Facade.getInstance("game")
        gameFacade:sendNotification("CP_actnotify")
        gameFacade:removeMediator("EatChoiceMediator")
    end
end


function EatChoiceMediator:initEatChoiceCards(cards)
    
    for i = 1,self.choicesNum do
        for j = 1 , 3 do
            self.Choices[i].Cards[j]:loadTexture("ui_res/Mahjong/Big/Big_" .. cards[i][j] .. ".png")
            self.Choices[i].Cards[j].Value = cards[i][j]
        end
    end
end

--选择吃法
function EatChoiceMediator:chooseEat(index)
    print("eatchoice  index = " .. index)
    local eat_cards = {}
    for i = 1 , 3 do
        print( "cards value = " .. self.Choices[index].Cards[i].Value)
        eat_cards[i] = self.Choices[index].Cards[i].Value
    end

    local MyGameConstants = cc.exports.MyGameConstants
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("CPGMenuProxy"):getData()
    local ActNotifyData = data.ActNotifyData
    local eatFlag = ActNotifyData.usChiFlags
    
    local choiceEatFlag = 0

    --根据点选的位置 选择吃法  
    if index == 3 then
        choiceEatFlag = MyGameConstants.EatType.usT
        
    elseif index == 2 then
        if eatFlag == MyGameConstants.EatType.usTZ or eatFlag == MyGameConstants.EatType.usTW then
            choiceEatFlag = MyGameConstants.EatType.usT
        else
            choiceEatFlag = MyGameConstants.EatType.usZ
        end

    else
        if eatFlag == MyGameConstants.EatType.usTZ then
            choiceEatFlag = MyGameConstants.EatType.usZ
        else
            choiceEatFlag = MyGameConstants.EatType.usW
        end
    end
    
    local pak1 = {
        chiValue = ActNotifyData.eatValue,
        ActFlag = MyGameConstants.MJActFlag.Chi,
        EatFlag = choiceEatFlag,
    }
    GameUtils:getInstance():sendNotification(24, pak1, "MJContext::TMJ_actionPlayerReady")

    self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

return EatChoiceMediator