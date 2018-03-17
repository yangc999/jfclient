local GameLogic = import("....GameLogic")
local Mediator = cc.load("puremvc").Mediator
local ResultHandCardMediator = class("ResultHandCardMediator", Mediator)

function ResultHandCardMediator:ctor(root)
    print("-------------->ResultHandCardMediator:ctor")
	ResultHandCardMediator.super.ctor(self, "ResultHandCardMediator",root)
    self.root = root
end

function ResultHandCardMediator:listNotificationInterests()
    print("-------------->ResultHandCardMediator:listNotificationInterests")
	local MyGameConstants = cc.exports.MyGameConstants
	return {
		"RE_updatehandcard",
        GameConstants.EXIT_GAME,
        MyGameConstants.C_CLOSE_RESULT,
	}
end

function ResultHandCardMediator:onRegister()
    print("-------------->ResultHandCardMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    local colorType = GameUtils:getInstance():getMJCardBack()
    
    self.Image_hu = self.root:getChildByName("Image_hu")
    self.cards = {}
    self.nodes = {}
    for i = 1,18 do
        self.nodes[i] = self.root:getChildByName("Node_" .. i)
        self.cards[i] = self.nodes[i]:getChildByName("Image_card")
        self.cards[i]:loadTexture(MyGameConstants.COLOR_RES_PATH[colorType] .."Big_01.png")
        self.cards[i]:setVisible(false)
    end
end

function ResultHandCardMediator:onRemove()
    print("-------------->ResultHandCardMediator:onRemove")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	self:setViewComponent(nil)
end

function ResultHandCardMediator:handleNotification(notification)
    print("-------------->ResultHandCardMediator:handleNotification")	
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local MyGameConstants = cc.exports.MyGameConstants
	
    if name == GameConstants.EXIT_GAME or name == MyGameConstants.C_CLOSE_RESULT then
        gameFacade:removeMediator("ResultHandCardMediator")
    elseif name == "RE_updatehandcard" then
        self:updateHandCard()
    end
end

---------------------------------------------------------------------------
function ResultHandCardMediator:updateHandCard()
    print("ResultHandCardMediator:updateHandCard")
    local MyGameConstants = cc.exports.MyGameConstants
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("ResultProxy"):getData()
    local HandCardData = data.HandCardData

    local card_index = 1
    local cpgCards = HandCardData.vChiPengGang
    local handCards = HandCardData.vAllTiles
    local huCard = nil
    dump(handCards,"result handCards")
    local deskInfo = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
    -- 将胡的牌放到最后
    if data.HuUserChair ~= 255 then
        huCard = handCards[#handCards]
        table.remove(handCards,#handCards)
    end
    GameLogic:sort(handCards,deskInfo.LaiZi)
    if huCard ~= nil then
        table.insert(handCards,huCard)
    end

    -- 是否显示胡图片
    if data.HuUserChair == 255 then
        self.Image_hu:setVisible(false)
    end

--    -- 测试数据
--    local card_index = 1
--    local cpgCards = {{usFlags = 1,vaulue = {1,2,3}}, {usFlags = 2,vaulue = {5,5,5}},{usFlags = 3,vaulue = {7,7,7,7}},{usFlags = 5,vaulue = {8,8,8,8}}}
--    local handCards = {15,15}

    if cpgCards ~= nil then
        for k, v in pairs(cpgCards) do
            local usFlags = v.iType
            if usFlags == MyGameConstants.MJActFlag.Chi or usFlags == MyGameConstants.MJActFlag.Peng then
                for i, value in pairs(v.vTiles) do
                    if i == 4 then
                        break
                    end
                    local image = self.cards[card_index]:getChildByName("Image_value")
                    self:setImageValue(image, value)
                    self.cards[card_index]:setVisible(true)
                    card_index = card_index + 1
                end
                self:moveRight(card_index)
            else
                if usFlags == MyGameConstants.MJActFlag.AnGang then
                    -- 暗杠
                    for i, value in pairs(v.vTiles) do
                        if i == 4 then
                            local image = self.cards[card_index]:getChildByName("Image_value")
                            self:setImageValue(image, value)
                            self.nodes[card_index]:setPosition(self.nodes[card_index - 2]:getPositionX(), 102)
                        else
                            self:setCardImage(self.cards[card_index])
                        end
                        self.cards[card_index]:setVisible(true)
                        card_index = card_index + 1
                    end
                else
                    for i, value in pairs(v.vTiles) do
                        if i == 4 then
                            self.nodes[card_index]:setPosition(self.nodes[card_index - 2]:getPositionX(), 102)
                        end
                        local image = self.cards[card_index]:getChildByName("Image_value")
                        self:setImageValue(image, value)
                        self.cards[card_index]:setVisible(true)
                        card_index = card_index + 1
                    end
                end
                self:moveLeft(card_index)
            end

        end
    end
    
    if 18 - card_index + 1 >= #handCards then
        for k,value in pairs(handCards) do
            local image = self.cards[card_index]:getChildByName("Image_value")
            self:setImageValue(image, value)
            self.cards[card_index]:setVisible(true)
            if k == #handCards then
                self.cards[card_index]:setColor(MyGameConstants.SELECTED_COLOR) 
                self.cards[card_index]:setPositionX(self.cards[card_index]:getPositionX()+40)
                self.nodes[card_index]:setScale(0.8)
            end
            card_index = card_index + 1
        end
    end
end

-- 从card_index起将牌位置向左移动
function ResultHandCardMediator:moveLeft(card_index)
    for i = card_index,18 do
        local posX = self.cards[i]:getPositionX()
        self.cards[i]:setPositionX(posX - 45)
    end
end

-- 从card_index起将牌位置向右移动
function ResultHandCardMediator:moveRight(card_index)
    for i = card_index,18 do
        local posX = self.cards[i]:getPositionX()
        self.cards[i]:setPositionX(posX + 25)
    end
end

-- 暗杠设置麻将子
function ResultHandCardMediator:setCardImage(card)
    local image = card:getChildByName("Image_value")
    image:setVisible(false)
    local colorType = GameUtils:getInstance():getMJCardBack()
    card:loadTexture(MyGameConstants.COLOR_RES_PATH[colorType] .."Big_03.png")
end

-- 设置麻将值
function ResultHandCardMediator:setImageValue(image,value)
    image:loadTexture("ui_res/Mahjong/Big/Big_"..value..".png")
end


return ResultHandCardMediator