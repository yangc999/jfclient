
local GameMusic = import("....GameMusic")
local Mediator = cc.load("puremvc").Mediator
local OutCardMediator = class("OutCardMediator", Mediator)

local UI_MAX_OUTCARD_NUM = 36  -- 每个玩家桌面最大出牌数量

local MiddleOutCardPos = {  -- 中间显示牌的位置
    cc.p(640,248),
    cc.p(959,379),
    cc.p(640,525),
    cc.p(319,379),
}

function OutCardMediator:ctor(root)
    print("-------------->OutCardMediator:ctor")
	OutCardMediator.super.ctor(self, "OutCardMediator",root)
	self.root = root
end

function OutCardMediator:listNotificationInterests()
    print("-------------->OutCardMediator:listNotificationInterests")
	local MyGameConstants = cc.exports.MyGameConstants
    return {
        "OC_clickcardvalue",
        "OC_outcard",
        "OC_actinfo",
        "OC_gamestation",
        MyGameConstants.C_CANCEL_CURSAME_CARD,
        MyGameConstants.C_UPDATE_CARDBACK,
        MyGameConstants.C_GAME_INIT,
        GameConstants.EXIT_GAME,
    }
end

function OutCardMediator:onRegister()
    print("-------------->OutCardMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local MyGameConstants = cc.exports.MyGameConstants
	
    self.all_out_cards = { }
    for i = 1, 4 do
        self.all_out_cards[i] = {}
        local Panel_player_out = self.root:getChildByName("Panel_player_" .. i .. "_out")
        self.all_out_cards[i].Panel_player_out = Panel_player_out
        self.all_out_cards[i].deskCards = { }  -- 桌面上所有打出的牌UI（包括不显示的牌）


        for j = 1, UI_MAX_OUTCARD_NUM do
            local card = Panel_player_out:getChildByName("Image_card_" .. j)
            if card ~= nil then
                self.all_out_cards[i].deskCards[j] = card
                self.all_out_cards[i].deskCards[j].value = 0
            end
        end
    end

    -- 玩家打出的牌 还没有放在桌面上（可以吃碰杠胡）
    local image_root = gameFacade:retrieveMediator("MainMediator").image_root
    local csbPath = "ui_csb/HandOutCardsLayer.csb"
	local ui = cc.CSLoader:createNode(csbPath)
    ui:setPosition(0,0)
    local Panel_player_handouts = ui:getChildByName("Panel_player_handouts")
    image_root:addChild(ui,6)
    for i=1,4 do
        self.all_out_cards[i].handoutCard = Panel_player_handouts:getChildByName("Image_handout_" .. i)
        self.all_out_cards[i].handoutCard:setVisible(false)
    end

    self.Image_out_tip = self.root:getChildByName("Image_out_tip")
    self.Image_out_tip:setVisible(false)
    

    -- 人数相应处理  二人出的牌太多可能放不下(需要多创建很多打出的牌UI)
    local NEW_UI_MAX_OUTCARD_NUM = 48
    if MyGameConstants.PLAYER_COUNT == 2 then

        for i = 1, 4 do
            local X_WIDTH = self.all_out_cards[1].deskCards[36]:getPositionX() - self.all_out_cards[1].deskCards[35]:getPositionX()
            if i == 1 then
                local startPosX, startPosY = self.all_out_cards[i].deskCards[36]:getPosition()
                for j = 1, NEW_UI_MAX_OUTCARD_NUM do
                    local index = NEW_UI_MAX_OUTCARD_NUM - j + 1

                    local XLen = index % 16 == 0 and 16 or index % 16
                    local YLen = math.floor((index - 1) / 16)
                    local x = startPosX -(XLen) * X_WIDTH + 108
                    local y = startPosY - YLen * 48

                    if j > 36 then
                        self.all_out_cards[i].deskCards[j] = cc.CSLoader:createNode("ui_csb/CardNode2.csb")
                        self.all_out_cards[i].deskCards[j]:setPosition(cc.p(x, y))
                        self.all_out_cards[i].Panel_player_out:addChild(self.all_out_cards[i].deskCards[j], YLen)
                    else
                        self.all_out_cards[i].deskCards[j]:setPosition(cc.p(x, y))
                        self.all_out_cards[i].deskCards[j]:setZOrder(YLen)
                    end

                end
            elseif i == 3 then
                local startPosX, startPosY = self.all_out_cards[i].deskCards[1]:getPosition()
                for j = 1, NEW_UI_MAX_OUTCARD_NUM do
                    local index = j
                    local XLen = index % 16 == 0 and 16 or index % 16
                    local YLen = math.floor((index - 1) / 16)
                    local x = startPosX +(16 - XLen) * X_WIDTH - X_WIDTH * 13
                    local y = startPosY - YLen * 48
                    if index > 36 then
                        self.all_out_cards[i].deskCards[index] = cc.CSLoader:createNode("ui_csb/CardNode2.csb")
                        self.all_out_cards[i].deskCards[index]:setPosition(cc.p(x, y))
                        self.all_out_cards[i].Panel_player_out:addChild(self.all_out_cards[i].deskCards[index], YLen)
                    else
                        self.all_out_cards[i].deskCards[index]:setPosition(cc.p(x, y))
                        self.all_out_cards[i].deskCards[index]:setZOrder(YLen)
                    end

                end
            else
                for j = 1, NEW_UI_MAX_OUTCARD_NUM do
                    local startPosX, startPosY = self.all_out_cards[i].deskCards[1]:getPosition()
                    local index = j
                    local XLen = index % 16 == 0 and 16 or index % 16
                    local YLen = math.floor((index - 1) / 16)
                    local x = startPosX +(XLen) * X_WIDTH - X_WIDTH * 14
                    local y = startPosY - YLen * 48
                    if index > 36 then
                        self.all_out_cards[i].deskCards[index] = cc.CSLoader:createNode("ui_csb/CardNode2.csb")
                        self.all_out_cards[i].deskCards[index]:setPosition(cc.p(x, y))
                        self.all_out_cards[i].Panel_player_out:addChild(self.all_out_cards[i].deskCards[index], YLen)
                    else
                        self.all_out_cards[i].deskCards[index]:setPosition(cc.p(x, y))
                    end

                end
            end
        end

        UI_MAX_OUTCARD_NUM = NEW_UI_MAX_OUTCARD_NUM
    else
        UI_MAX_OUTCARD_NUM = 36
    end

    self:initView()
    self:updateCardColor()
end

function OutCardMediator:onRemove()
    print("-------------->OutCardMediator:onRemove")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	self:setViewComponent(nil)
end

function OutCardMediator:handleNotification(notification)
    print("-------------->OutCardMediator:handleNotification")
	local name = notification:getName()
    local body = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local MyGameConstants = cc.exports.MyGameConstants

    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("OutCardMediator")
        gameFacade:removeProxy("OutCardProxy")
    elseif name == MyGameConstants.C_GAME_INIT then
        self:initView()
    elseif name == MyGameConstants.C_UPDATE_CARDBACK then
         self:updateCardColor()
    elseif name == MyGameConstants.GET_TOKEN then
        
    elseif name == MyGameConstants.C_CANCEL_CURSAME_CARD then
        self:cancelCurSameCard()
    elseif name == "OC_clickcardvalue" then
        self:cancelCurSameCard()
        self:showCurSameCard()
    elseif name == "OC_outcard" then
        self:outCardInfo()
        self:setHandOutCardHideByDelay(1)
    elseif name == "OC_actinfo" then
        self:actInfo()
        self:setHandOutCardHideByDelay(0)
    elseif name == "OC_gamestation" then
        self:gameStation()
    end
end

-----------------------------------------------------------------

function OutCardMediator:ui_open()
    self.root:setVisible(true)
end

function OutCardMediator:ui_close()
    self.root:setVisible(false)
end

-- 初始化界面
function OutCardMediator:initView()
    print("OutCardMediator:initView")
    self.root: setLocalZOrder(MyGameConstants.ORDER_OUT_CARD) 
    local colorType = GameUtils:getInstance():getMJCardBack()
    self.Image_out_tip:stopAllActions()
    self.Image_out_tip:setVisible(false)
    self:setHandOutCardHideByDelay(0)
    for i = 1,4 do
        self.all_out_cards[i].handoutCard:setVisible(false)
    end

    for i = 1,4 do
        for j = 1,UI_MAX_OUTCARD_NUM do
            local image_card = self.all_out_cards[i].deskCards[j]:getChildByName("Image_card")
            self.all_out_cards[i].deskCards[j].value = 0
            image_card:setVisible(false)
            image_card:setColor(cc.c3b(255,255,255))
            if i == 1 or i == 3 then
                image_card:loadTexture(MyGameConstants.COLOR_RES_PATH[colorType] .. "Front_Small_01.png")
            else
                image_card:loadTexture(MyGameConstants.COLOR_RES_PATH[colorType] .. "Front_Small_03.png")
            end
            local image = image_card:getChildByName("Image_value")
            image:setVisible(true)
        end
    end
end

-- 更新牌背
function OutCardMediator:updateCardColor()
    local colorType = GameUtils:getInstance():getMJCardBack()
    if colorType < 1 or colorType > 4 then
        return
    end

    for i = 1 , 4 do
        local cardbg = self.all_out_cards[i].handoutCard:getChildByName("Image_card")
        cardbg:loadTexture(MyGameConstants.COLOR_RES_PATH[colorType] .. "Big_01.png")
    end
    for i = 1, 4 do
        for j = 1, UI_MAX_OUTCARD_NUM do
            local image_card = self.all_out_cards[i].deskCards[j]:getChildByName("Image_card")
            if i == 1 or i == 3 then
                image_card:loadTexture(MyGameConstants.COLOR_RES_PATH[colorType] .. "Front_Small_01.png")
            else
                image_card:loadTexture(MyGameConstants.COLOR_RES_PATH[colorType] .. "Front_Small_03.png")
            end
        end
    end
end

-- 取消当前点击牌桌面所有可见的牌颜色
function OutCardMediator:cancelCurSameCard()
    print("OutCardMediator:cancelCurSameCard")
    for i = 1, 4 do
        for j = 1, UI_MAX_OUTCARD_NUM do
            local card = self.all_out_cards[i].deskCards[j]
            if card:isVisible() == true then
                card:setColor(MyGameConstants.UNSELECTED_COLOR)
            end
        end
    end 
end

-- 显示当前点击牌桌面所有可见的牌颜色
function OutCardMediator:showCurSameCard()
    print("OutCardMediator:showCurSameCard")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("OutCardProxy"):getData()
    for i = 1, 4 do
        for j = 1, UI_MAX_OUTCARD_NUM do
            local card = self.all_out_cards[i].deskCards[j]
            if card:isVisible() == true and card.value == data.ClickCardValue then
                card:setColor(MyGameConstants.SELECTED_COLOR)
            end
        end
    end 
end

-- 设置打出的那张牌延迟隐藏
function OutCardMediator:setHandOutCardHideByDelay(delayTime)
    performWithDelay(self.root,
    function()
        for i=1,4 do
            self.all_out_cards[i].handoutCard:stopAllActions()
            self.all_out_cards[i].handoutCard:setScale(1)
            self.all_out_cards[i].handoutCard:setVisible(false)
        end
    end ,
    delayTime)
end

-- 某个玩家出牌
function OutCardMediator:outCardInfo()
    print("OutCardMediator:outCardInfo start")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("OutCardProxy"):getData()
    local OutCardData = data.OutCardData

    local outCardUser = OutCardData.iCID      
    local outCardValue = OutCardData.eDisCardedTile           
    local outCardNums = OutCardData.iDisCardCounts   
    local ui_chair = GameUtils:getInstance():getUIChairByServerChair(outCardUser)        

    for i = 1,4 do
        self.all_out_cards[i].handoutCard:stopAllActions()
        self.all_out_cards[i].handoutCard:setVisible(false)
    end

    -- 放大显示的牌
    local cardbg =  self.all_out_cards[ui_chair].handoutCard:getChildByName("Image_card")
    local image = cardbg:getChildByName("Image_value")
    image:loadTexture("ui_res/Mahjong/Big/Big_"..tostring(outCardValue)..".png")
    self.all_out_cards[ui_chair].handoutCard:setVisible(true)
    self.all_out_cards[ui_chair].handoutCard:setScale(0)
    
    -- 手牌中要出的牌
    local Card = gameFacade:retrieveMediator("HandCardMediator").all_hand_cards[ui_chair].needOutCard
    local needOutCard = nil
    if ui_chair == 1 then
        needOutCard = Card:getChildByName("Image_card_bg")
    else
        needOutCard = Card
    end
    local start_pos = needOutCard:convertToWorldSpace(cc.p(0, 0))
    -- 桌面显示刚出的牌
    local outCard = self.all_out_cards[ui_chair].deskCards[outCardNums]:getChildByName("Image_card")
    local outCard_image = outCard:getChildByName("Image_value")
    local end_pos = outCard_image:convertToWorldSpace(cc.p(0, 0))

    self.all_out_cards[ui_chair].handoutCard:setPosition(start_pos)
    local spawn1 = cc.Spawn:create(cc.ScaleTo:create(0.2,1.2),cc.MoveTo:create(0.2,MiddleOutCardPos[ui_chair]))
    local spawn2 = cc.Spawn:create(cc.ScaleTo:create(0.1,0),cc.MoveTo:create(0.1,end_pos))
    local sequence = cc.Sequence:create(spawn1,cc.DelayTime:create(0.7),spawn2)
    self.all_out_cards[ui_chair].handoutCard:runAction(sequence)

    self:showDeskCard(ui_chair,outCardNums,outCardValue)
    -- 出牌音效
    GameMusic:PlayCardEffect(outCardValue,outCardUser)
end

-- 桌面展示打出的牌 
function OutCardMediator:showDeskCard(ui_chair,card_index,card_value)
    print("OutCardMediator:showDeskCard start")
    if card_index == nil or card_index <= 0 then
        return
    end

    performWithDelay(self.root, function()
        local outcard = self.all_out_cards[ui_chair].deskCards[card_index]:getChildByName("Image_card")
        local image = outcard:getChildByName("Image_value")
        local pos = image:convertToWorldSpace(cc.p(0, 0))
        outcard:setVisible(true)

        -- 更新桌面上打出的牌 和 闪烁的光标位置
        if card_value ~= nil then
            image:loadTexture("ui_res/Mahjong/Small/Small_" .. tostring(card_value) .. ".png")
            -- 上个打出牌玩家的牌上的提示位置微调
            if ui_chair == 1 then
                pos.x = pos.x + 17
                pos.y = pos.y + 55
            elseif ui_chair == 3 then
                pos.x = pos.x + 17
                pos.y = pos.y + 55
            elseif ui_chair == 2 then
                pos.x = pos.x - 10
                pos.y = pos.y + 35
            elseif ui_chair == 4 then
                pos.x = pos.x + 10
                pos.y = pos.y + 8
            end

            self.Image_out_tip:stopAllActions()
            self.Image_out_tip:setPosition(pos)
            self.Image_out_tip:setVisible(true)
            local actionUp = cc.JumpBy:create(1.3, cc.p(0, 0), 10, 2)
            self.Image_out_tip:runAction(cc.RepeatForever:create(actionUp))
        end
        self.all_out_cards[ui_chair].deskCards[card_index].value = card_value
        self.all_out_cards[ui_chair].deskCards[card_index]:setVisible(true)
    end , 0)
end

-- 某个玩家执行了动作
function OutCardMediator:actInfo()
    print("OutCardMediator:onActInfo")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("OutCardProxy"):getData()
    local ActInfoData = data.ActInfoData
    local actFlag = ActInfoData.sAct.eAction  

    if actFlag == MyGameConstants.MJActFlag.Guo then

    elseif actFlag == MyGameConstants.MJActFlag.Chi or actFlag == MyGameConstants.MJActFlag.Peng then
        --隐藏显示出牌的提示图标
        self.Image_out_tip:setVisible(false)
        --将吃碰杠的这张牌从桌子上移除(暗杠和补杠不用拾起)
        self:pickupCardOndesk()
    elseif actFlag == MyGameConstants.MJActFlag.DianGang then
        self.Image_out_tip:setVisible(false)
        self:pickupCardOndesk()
    end

end

-- 吃碰杠胡的时候要将玩家打出的这张牌隐藏
function OutCardMediator:pickupCardOndesk()
    print("OutCardMediator:pickupCardOndesk")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("OutCardProxy"):getData()
    local LastOutCardData = data.LastOutCardData

    local outCardUser = LastOutCardData.iCID      
    local outCardNums = LastOutCardData.iDisCardCounts 
    local ui_chair = GameUtils:getInstance():getUIChairByServerChair(outCardUser)      
    self.all_out_cards[ui_chair].deskCards[outCardNums]:setVisible(false)    
end 

-- 断线重连
function OutCardMediator:gameStation()
    print("OutCardMediator:gameStation start")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("OutCardProxy"):getData()

    local station = data.GameStationData.eMJState
    print("-------------> station = " .. station)
    if station >= 16 and station < 24 then
        local ui_lastOutUser = GameUtils:getInstance():getUIChairByServerChair(data.LastOutCardData.iCID)
        local lastPos = data.LastOutCardData.iDisCardCounts

        local outCardData = data.GameStationData.mCID_DisCarded
        if table.nums(outCardData) >= 1 then
            for k, v in pairs(outCardData) do
                local ui_chair = GameUtils:getInstance():getUIChairByServerChair(v[1])
                print("ui_chair = " .. ui_chair)
                for index, vaule in pairs(v[2]) do
                    local card_index = index
                    if card_index > UI_MAX_OUTCARD_NUM then
                        card_index = card_index % UI_MAX_OUTCARD_NUM
                        -- 超出第三排 从第一排显示
                    end
                    self.all_out_cards[ui_chair].deskCards[card_index].value = vaule
                    local card = self.all_out_cards[ui_chair].deskCards[card_index]:getChildByName("Image_card")
                    card:setVisible(true)
                    local image = card:getChildByName("Image_value")
                    if vaule ~= nil then
                        image:loadTexture("ui_res/Mahjong/Small/Small_" .. tostring(vaule) .. ".png")
                    end
                    self.all_out_cards[ui_chair].deskCards[card_index]:setVisible(true)

                    -- 显示出牌光标
                    if ui_lastOutUser == ui_chair and index == lastPos then
                        local pos = image:convertToWorldSpace(cc.p(0, 0))
                        if ui_chair == 1 then
                            pos.x = pos.x + 17
                            pos.y = pos.y + 55
                        elseif ui_chair == 3 then
                            pos.x = pos.x + 17
                            pos.y = pos.y + 55
                        elseif ui_chair == 2 then
                            pos.x = pos.x - 10
                            pos.y = pos.y + 35
                        elseif ui_chair == 4 then
                            pos.x = pos.x + 10
                            pos.y = pos.y + 8
                        end

                        self.Image_out_tip:setPosition(pos)
                        self.Image_out_tip:setVisible(true)

                        self.Image_out_tip:stopAllActions()
                        local actionUp = cc.JumpBy:create(1.3, cc.p(0, 0), 10, 2)
                        self.Image_out_tip:runAction(cc.RepeatForever:create(actionUp))
                    end
                end
            end
        end
    end
    print("OutCardMediator:gameStation end")
end

return OutCardMediator