local GameLogic = import("....GameLogic")
local GameMusic = import("....GameMusic")
local Mediator = cc.load("puremvc").Mediator
local CardNode = import("....CardNode")
local HandCardMediator = class("HandCardMediator", Mediator)

function HandCardMediator:ctor(root)
	HandCardMediator.super.ctor(self, "HandCardMediator",root)
	self.root = root
end

function HandCardMediator:listNotificationInterests()
	local MyGameConstants = cc.exports.MyGameConstants
	return {
        "HC_clickcardvalue",
        "HC_fetchcards",
        "HC_videofetchcards",
        "HC_getToken",
        "HC_outcardreq",
        "HC_outcard",
        "HC_actinfo",
        "HC_gamestation",
        "HC_test",
        MyGameConstants.C_CANCEL_CURSAME_CARD,
        MyGameConstants.C_GAME_INIT,
        MyGameConstants.C_HANDCARD_INITPOS,
        MyGameConstants.C_UPDATE_CARDBACK,
        GameConstants.EXIT_GAME,
	}
end

function HandCardMediator:onRegister()
    print("-------------->DeskInfoMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local MyGameConstants = cc.exports.MyGameConstants
	
    gameFacade:registerCommand(MyGameConstants.FETCH_HANDCARDS,cc.exports.HCFetchHandCommand)
	gameFacade:registerCommand(MyGameConstants.FETCH_VIDEO_HANDCARDS,cc.exports.HCVideoFetchHandCommand)
    gameFacade:registerCommand(MyGameConstants.C_OUTCARD_REQ, cc.exports.HCOutCardReqCommand)

    self.all_hand_cards = {}            --所有玩家的手牌table
    self.Panel_cpg_cards = {}           --所有玩家的吃碰杠牌的Panel数组
    self.Panel_handcards = {}           --所有玩家的手牌的Panel数组
    self.Panel_resultcards = {}         --所有玩家的结算牌的Panel数组

    for i = 1,4 do
        self.all_hand_cards[i] = {}
        self.all_hand_cards[i].cpgCards = {}
        self.all_hand_cards[i].handCards = {}
        self.all_hand_cards[i].resultCards = {}
        --初始化吃碰杠牌栏
        local playerHandCards = self.root:getChildByName("Panel_player_".. i .."_hand")
        local Panel_cpg_card = playerHandCards:getChildByName("Panel_cpg_cards")

        self.Panel_cpg_cards[i] = Panel_cpg_card
        for j = 1,4 do
            self.all_hand_cards[i].cpgCards[j] = Panel_cpg_card:getChildByName("Panel_cards_" ..j)
            self.all_hand_cards[i].cpgCards[j].cards = {}
            self.all_hand_cards[i].cpgCards[j].isAnGang = false
            for k = 1,4 do
                self.all_hand_cards[i].cpgCards[j].cards[k] = self.all_hand_cards[i].cpgCards[j]:getChildByName("Image_card_"..k):getChildByName("Image_card")
                self.all_hand_cards[i].cpgCards[j].cards[k].value = 0
            end
            self.all_hand_cards[i].cpgCards[j]:setVisible(false)
        end
        
        --初始化手牌,玩家1的手牌由代码生成
        if i == 1 then  
            for j = 1,14 do
                local card = CardNode:create(0,j)
                if j == 14 then
                    card:setPosition(( MyGameConstants.FIRST_LEFT_DIS + (j-1)*  MyGameConstants.CARDS_DISTANCE + 30) , MyGameConstants.CARD_POSITION_Y)
                    
                    self.all_hand_cards[i].needOutCard = card -- 最右边需要打出去的牌
                else 
                    card:setPosition(( MyGameConstants.FIRST_LEFT_DIS + (j-1)* MyGameConstants.CARDS_DISTANCE) , MyGameConstants.CARD_POSITION_Y)
                    
                    self.all_hand_cards[i].handCards[j] = card
                end
                self.root:addChild(card)
            end
        else
            local Panel_inhand = playerHandCards:getChildByName("Panel_inhand_cards")
            self.Panel_handcards[i] = Panel_inhand
            for j = 1 , 14 do
                local CardNode = Panel_inhand:getChildByName("Image_card_" .. j); 
                if j == 14 then
                    
                    self.all_hand_cards[i].needOutCard = CardNode:getChildByName("Image_card")
                    self.all_hand_cards[i].needOutCard:setVisible(false)
                else
                    self.all_hand_cards[i].handCards[j] = CardNode:getChildByName("Image_card")
                end
                
            end
        end

        --初始化结算的牌 
        local ui_resultCards = playerHandCards:getChildByName("Panel_result_cards")
        self.Panel_resultcards[i] = ui_resultCards
        for j = 1,14 do
            self.all_hand_cards[i].resultCards[j] = ui_resultCards:getChildByName("Image_card_" .. j):getChildByName("Image_card")
            self.all_hand_cards[i].resultCards[j]:setVisible(false)
        end
    end
   -- self:onCardColorChange()
    
    --人数处理
    if MyGameConstants.PLAYER_COUNT == 2 then
        --需要隐藏相应位置的UI
        self.root:getChildByName("Panel_player_2_hand"):setVisible(false)
        self.root:getChildByName("Panel_player_4_hand"):setVisible(false)

    elseif MyGameConstants.PLAYER_COUNT == 3 then
        --需要隐藏相应位置的UI
        self.root:getChildByName("Panel_player_3_hand"):setVisible(false)
    end

    self.root:setVisible(false)
    self:updateCardColor()
end

function HandCardMediator:onRemove()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	self:setViewComponent(nil)
end

function HandCardMediator:handleNotification(notification)
    print("-------------->HandCardMediator:handleNotification")
	local name = notification:getName()
    local body = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local MyGameConstants = cc.exports.MyGameConstants

    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("HandCardMediator")
        gameFacade:removeProxy("HandCardProxy")
    elseif name == MyGameConstants.C_GAME_INIT then
        self:initView()
        self:hideAllOutTingTips()
        self:ui_close()
    elseif name == MyGameConstants.C_HANDCARD_INITPOS then
        self:resetPlayerHandCardsPosition()
    elseif name == MyGameConstants.C_UPDATE_CARDBACK then
        self:updateCardColor()
    elseif name == MyGameConstants.C_CANCEL_CURSAME_CARD then
        self:cancelCurSameCard()
    elseif name == "HC_clickcardvalue" then
        self:cancelCurSameCard()
        self:showCurSameCard()
    elseif name == "HC_fetchcards" then
        self:ui_open()
        self:FetchCards()
    elseif name == "HC_videofetchcards" then
        self:ui_open()
        self:VideoFetchCards()
    elseif name == "HC_getToken" then
        self:getToken()
        self:showOutCardTing()
    elseif name == "HC_outcardreq" then
        self:hideNeedOutCard()
        self:updateSelfCards()
        self:resetPlayerHandCardsPosition()
        self:hideAllOutTingTips()
    elseif name == "HC_outcard" then
        self:outCardInfo()
        self:hideAllOutTingTips()
    elseif name == "HC_actinfo" then
        self:actInfo()
    elseif name == "HC_gamestation" then
        self:gameStation()
    elseif name == "HC_test" then
        self:Test()
	end
end

-------------------------------------------------------------------------
function HandCardMediator:ui_open()
    self.root:setVisible(true)
end

function HandCardMediator:ui_close()
    self.root:setVisible(false)
end

-- 更新牌背
function HandCardMediator:updateCardColor()
    print("HandCardMediator:updateCardColor")
    local colorType = GameUtils:getInstance():getMJCardBack()
    if colorType < 1 or colorType > 4 then
        return
    end

    for i = 1, 4 do
        -- cpgCards
        local cpg_new_texture = nil
        if i == 1 then
            cpg_new_texture = MyGameConstants.COLOR_RES_PATH[colorType] .. "Big_01.png"
        elseif i == 3 then
            cpg_new_texture = MyGameConstants.COLOR_RES_PATH[colorType] .. "Front_Small_01.png"
        else
            cpg_new_texture = MyGameConstants.COLOR_RES_PATH[colorType] .. "Front_Small_03.png"
        end
        local cpg_new_texture_back = nil
        if i == 1 then
            cpg_new_texture_back = MyGameConstants.COLOR_RES_PATH[colorType] .. "Big_03.png"
        elseif i == 3 then
            cpg_new_texture_back = MyGameConstants.COLOR_RES_PATH[colorType] .. "Front_Small_05.png"
        else
            cpg_new_texture_back = MyGameConstants.COLOR_RES_PATH[colorType] .. "Front_Small_06.png"
        end

        for j = 1, 4 do
            if self.all_hand_cards[i].cpgCards[j].isAnGang then
                for k = 1, 4 do
                    if k == 4 then
                        local isShow = false
                        if MyGameConstants.IS_SHOW_ANGANG_CARD then
                            if k == 4 then
                                isShow = true
                            end
                        else
                            if k == 4 and i == 1 then
                                isShow = true
                            end
                        end
                        -- 如果暗杠第四张牌不展示
                        if isShow then
                            self.all_hand_cards[i].cpgCards[j].cards[k]:loadTexture(cpg_new_texture)
                        else
                            self.all_hand_cards[i].cpgCards[j].cards[k]:loadTexture(cpg_new_texture_back)
                        end
                    else
                        self.all_hand_cards[i].cpgCards[j].cards[k]:loadTexture(cpg_new_texture_back)
                    end
                end
            else
                for k = 1, 4 do
                    self.all_hand_cards[i].cpgCards[j].cards[k]:loadTexture(cpg_new_texture)
                end
            end
        end

        local hand_new_texture = nil
        if i == 1 then
            hand_new_texture = MyGameConstants.COLOR_RES_PATH[colorType] .. "Big_02.png"
        elseif i == 3 then
            hand_new_texture = MyGameConstants.COLOR_RES_PATH[colorType] .. "Front_Small_02.png"
        else
            hand_new_texture = MyGameConstants.COLOR_RES_PATH[colorType] .. "Front_Small_04.png"
        end
        for j = 1, 14 do
            if j == 14 then
                -- needOutCard
                if i == 1 then
                    local image = self.all_hand_cards[i].needOutCard:getChildByName("Image_card_bg")
                    image:loadTexture(hand_new_texture)
                else
                    self.all_hand_cards[i].needOutCard:loadTexture(hand_new_texture)
                end
            else
                -- handCards
                if i == 1 then
                    local image = self.all_hand_cards[i].handCards[j]:getChildByName("Image_card_bg")
                    image:loadTexture(hand_new_texture)
                else
                    self.all_hand_cards[i].handCards[j]:loadTexture(hand_new_texture)
                end
            end
        end
        -- resultCards
        local result_new_texture = nil
        if i == 1 then
            result_new_texture = MyGameConstants.COLOR_RES_PATH[colorType] .. "Big_01.png"
        elseif i == 3 then
            result_new_texture = MyGameConstants.COLOR_RES_PATH[colorType] .. "Front_Small_01.png"
        else
            result_new_texture = MyGameConstants.COLOR_RES_PATH[colorType] .. "Front_Small_03.png"
        end
        for j = 1, 14 do
            self.all_hand_cards[i].resultCards[j]:loadTexture(result_new_texture)
        end
    end
end

-- 初始化界面
function HandCardMediator:initView()  
    print("HandCardMediator:initView")
    self.root:setLocalZOrder(MyGameConstants.ORDER_HAND_CARD)
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("HandCardProxy"):getData()
    data.SelfHandCards = {}
    data.IsCanOutCard = false
    local colorType = GameUtils:getInstance():getMJCardBack()

    for i = 1,4 do
        for j = 1,4 do
            self.all_hand_cards[i].cpgCards[j]:setVisible(false)
            if self.all_hand_cards[i].cpgCards[j].isAnGang then
                self.all_hand_cards[i].cpgCards[j].isAnGang = false
            end
            for k = 1,4 do
                local card = self.all_hand_cards[i].cpgCards[j].cards[k]
                card.value = 0
                card:setColor(MyGameConstants.UNSELECTED_COLOR)
                local path = ""
                if i == 1 then
                    path = "Big_01.png"
                elseif i == 3 then
                    path = "Front_Small_01.png"
                else
                    path = "Front_Small_03.png"
                end
                card:loadTexture(MyGameConstants.COLOR_RES_PATH[colorType] .. path)
                local value = card:getChildByName("Image_value")
                value:setVisible(true)

                -- 删除吃碰杠显示箭头
                local image = card:getChildByName("image")
                if image ~= nil then
                    image:removeFromParent()
                end
            end
        end
        for j = 1,14 do
            if j == 14 then
                self.all_hand_cards[i].needOutCard:setVisible(false)
            else 
                self.all_hand_cards[i].handCards[j]:setVisible(true)
            end
        end

        for j = 1,14 do
            self.all_hand_cards[i].resultCards[j]:setVisible(false)
        end
    end

    for i = 1, 4 do
        if i == 2 or i == 4 then
            self.Panel_cpg_cards[i]:setPosition(0,0)
            self.Panel_handcards[i]:setPosition(0,0)
            self.Panel_resultcards[i]:setPosition(0,0)
        end
    end
end

-- 下发手牌
function HandCardMediator:FetchCards()
    print("HandCardMediator:FetchCards")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("HandCardProxy"):getData()
    local HandCards = data.HandCards
    
    local self_server_chair = GameUtils:getInstance():getSelfServerChair()
    for chair = 0, MyGameConstants.PLAYER_COUNT-1 do
        local ui_chair = GameUtils:getInstance():getUIChairByServerChair(chair)
        for i = 1, 13 do
            if ui_chair == 1 then
                self.all_hand_cards[ui_chair].handCards[i]:setCardImage(HandCards[i])
                self.all_hand_cards[ui_chair].handCards[i]:setVisible(true)
            else
               -- self:setResultCardValue(ui_chair, i, cards[chair + 1][i])
            end
        end
    end
end

-- 录像下发手牌
function HandCardMediator:VideoFetchCards()
    print("HandCardMediator:VideoFetchCards")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("HandCardProxy"):getData()
    local UserHandCards = data.UserHandCards
    
    local self_server_chair = GameUtils:getInstance():getSelfServerChair()
    for chair = 0, MyGameConstants.PLAYER_COUNT-1 do
        local ui_chair = GameUtils:getInstance():getUIChairByServerChair(chair)
        local HandCards = UserHandCards[chair+1]
        for i = 1, 13 do
            if ui_chair == 1 then
                self.all_hand_cards[ui_chair].handCards[i]:setCardImage(HandCards[i])
                self.all_hand_cards[ui_chair].handCards[i]:setVisible(true)
            else
                self.all_hand_cards[ui_chair].handCards[i]:setVisible(false)
                self:setResultCardValue(ui_chair, i, HandCards[i])
            end
        end
    end
end

-- 设置结算牌的牌面并显示 ui_chair 玩家的位置索引  2-4   card_index:牌的位置索引 1-14
function HandCardMediator:setResultCardValue(ui_chair,card_index,card_value)
    print("HandCardMediator:setResultCardValue" )
    if card_value == nil or card_value <= 0 or card_value == 254 then
        if card_index == 14 then
            self.all_hand_cards[ui_chair].needOutCard:setVisible(true)
        end
        return 
    end

    local card = self.all_hand_cards[ui_chair].resultCards[card_index]
    local image_name = self:getImageName(ui_chair,card_value)
    if card then
        card:getChildByName("Image_value"):loadTexture(image_name)
        card:setVisible(true)
    end
    if card_index == 14 then
        self.all_hand_cards[ui_chair].needOutCard:setVisible(false)
    elseif card_index < 14 then
        self.all_hand_cards[ui_chair].handCards[card_index]:setVisible(false)
    end
end

-- 玩家拿到令牌
function HandCardMediator:getToken()
    print("HandCardMediator:getToken")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("HandCardProxy"):getData()
    local tokenData = data.TokenData
    local ui_chair = GameUtils:getInstance():getUIChairByServerChair(tokenData.iCID)
    local card_value = tokenData.eDrawedTile

    --如果拿到令牌有抓到牌
    if card_value == 254 then
        if GameUtils:getInstance():getGameType() ~= 10 then
            self:setResultCardValue( ui_chair , 14 , card_value)
        end
    else
        if ui_chair ~= 1 and GameUtils:getInstance():getGameType() == 10 then
            self:setResultCardValue( ui_chair , 14 , card_value)
        else
            self:fetchOneCard(ui_chair,card_value)
        end
    end
end

-- 显示打哪些牌可以听
function  HandCardMediator:showOutCardTing()
    if MyGameConstants.IS_SHOW_CHECK_TING == true then
        local gameFacade = cc.load("puremvc").Facade.getInstance("game")
        local handCard = gameFacade:retrieveProxy("HandCardProxy"):getData()
        local desk = gameFacade:retrieveProxy("DeskInfoProxy"):getData()

        local outCardTing = GameLogic:getTingCards(handCard.SelfHandCards,desk.LaiZi,desk.IsCan7Dui)
        dump(outCardTing,"outCardTing")
        for i, card in pairs(self.all_hand_cards[1].handCards) do
            if card:isVisible() and GameLogic:isInTable(card.Value,outCardTing) then
                card:setTingTipVisible(true)
            end
        end

        local card = self.all_hand_cards[1].needOutCard
        if card:isVisible() and GameLogic:isInTable(card.Value,outCardTing) then
            card:setTingTipVisible(true)
        end
    end
end

-- 隐藏可听牌的提示
function HandCardMediator:hideAllOutTingTips()
    for i,card in pairs (self.all_hand_cards[1].handCards) do
        card:setTingTipVisible(false)
    end
    self.all_hand_cards[1].needOutCard:setTingTipVisible(false)
end

-- 自己抓一张牌 
function HandCardMediator:fetchOneCard(ui_chair,card_value)
    print("HandCardMediator:fetchOneCardBySelf value = " .. card_value)
    if card_value == 254 then
        return 
    end
    GameMusic:playOtherEffect(EffectEnum.ZHUAP,false)

    if ui_chair == 1 then
        self.all_hand_cards[ui_chair].needOutCard:setCardImage(card_value)
        self.all_hand_cards[ui_chair].needOutCard:setVisible(true)

        -- 调整位置
        for j = 1, 13 do
            self.all_hand_cards[ui_chair].handCards[j]:down()
        end
        self.all_hand_cards[ui_chair].needOutCard:down()
    end

    
end

-- 某玩家的出牌
function HandCardMediator:outCardInfo()
    print("HandCardMediator:outCardInfo start")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("HandCardProxy"):getData()

    local outCardData = data.OutCardData

    local ui_chair = GameUtils:getInstance():getUIChairByServerChair(outCardData.iCID)
    if ui_chair == 1 then
        self:updateSelfCards()
        if self.all_hand_cards[ui_chair].needOutCard:isVisible() then
            self.all_hand_cards[ui_chair].needOutCard:setVisible(false)
        end
    else
        if GameUtils:getInstance():getGameType() == 10 then
            self:updateOtherUserHandCards(outCardData.iCID)
            self.all_hand_cards[ui_chair].resultCards[14]:setVisible(false)
        else
            self.all_hand_cards[ui_chair].needOutCard:setVisible(false)
        end
    end
end

-- 对玩家的手牌进行更新
function HandCardMediator:updateSelfCards()
    print("HandCardMediator:updateSelfCards")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("HandCardProxy"):getData()

    local currentcards = data.SelfHandCards
    dump(currentcards,"currentcards")
    local selfChair = GameUtils:getInstance():getSelfServerChair()
    --更新手里的牌
    local j = 1;
    for i = 1, 13 do
        if self.all_hand_cards[1].handCards[i]:isVisible() then
            if #currentcards >= j then
                self.all_hand_cards[1].handCards[i]:setCardImage(currentcards[j])
                j=j+1
            end
        end
    end

    if self.all_hand_cards[1].needOutCard:isVisible() then
        if #currentcards >= j then
            self.all_hand_cards[1].needOutCard:setCardImage(currentcards[j])
        end
    end
end

-- 隐藏最右边的牌
function HandCardMediator:hideNeedOutCard()
    self.all_hand_cards[1].needOutCard:setVisible(false)
end

-- 玩家所有牌回到初始位置
function HandCardMediator:resetPlayerHandCardsPosition()
    for i=1,13 do
        self.all_hand_cards[1].handCards[i]:down()
    end
    self.all_hand_cards[1].needOutCard:down()
end

-- 某玩家执行了某个动作
function HandCardMediator:actInfo()
    print("HandCardMediator:actInfo")
    local MyGameConstants = cc.exports.MyGameConstants
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("HandCardProxy"):getData()
    local ActInfoData = data.ActInfoData
    local actFlag = ActInfoData.sAct.eAction
    if actFlag ==  MyGameConstants.MJActFlag.Guo then
        
    elseif actFlag == MyGameConstants.MJActFlag.Chi then
        self:showActFrom(actFlag,ActInfoData.sAct.iFromCID,ActInfoData.sAct.iActCID,ActInfoData.sCPG.index + 1)
        self:eatCard()
    elseif actFlag == MyGameConstants.MJActFlag.Peng then
        self:showActFrom(actFlag,ActInfoData.sAct.iFromCID,ActInfoData.sAct.iActCID,ActInfoData.sCPG.index + 1)
        self:pengCard()
    elseif actFlag >= MyGameConstants.MJActFlag.DianGang and actFlag <= MyGameConstants.MJActFlag.BuGang then
        if actFlag == MyGameConstants.MJActFlag.DianGang or actFlag == MyGameConstants.MJActFlag.BuGang then
            self:showActFrom(actFlag,ActInfoData.sCPG.iFromCID,ActInfoData.sAct.iActCID,ActInfoData.sCPG.index + 1)
        end
        self:gangCard()
    elseif actFlag == MyGameConstants.MJActFlag.Hu then
        self:huCard()
    end
    print("HandCardMediator:actInfo end")
end

-- 展示吃碰杠哪家的牌
function HandCardMediator:showActFrom(actType,fromUser,toUser,index)
    print("HandCardMediator:showActFrom")
    if MyGameConstants.IS_SHOW_CPG_FROM then
        local ui_chair_from = GameUtils:getInstance():getUIChairByServerChair(fromUser)
        local ui_chair_to = GameUtils:getInstance():getUIChairByServerChair(toUser)
        if actType == MyGameConstants.MJActFlag.BuGang then
            local card = self.all_hand_cards[ui_chair_to].cpgCards[index].cards[1]
            local arror = card:getChildByName("image")
            if arror ~= nil then
                arror:removeFromParent()
            end
        elseif actType == MyGameConstants.MJActFlag.Chi or actType == MyGameConstants.MJActFlag.Peng or actType == MyGameConstants.MJActFlag.DianGang then
            local card = self.all_hand_cards[ui_chair_to].cpgCards[index].cards[1]
            local image = ccui.ImageView:create("ui_res/actarrow.png")
            image:setPosition(0,0)
            image:setName("image")
            card:addChild(image)
            if ui_chair_to == 1 then    
                image:setPosition(35,40)
                if ui_chair_from == 2 then
                    image:setRotation(90)
                elseif ui_chair_from == 3 then
                    
                elseif ui_chair_from == 4 then
                    image:setRotation(-90)
                end
            elseif ui_chair_to == 2 then
                image:setPosition(38,26)
                image:setScale(0.8)
                if ui_chair_from == 1 then
                    image:setRotation(180)
                elseif ui_chair_from == 3 then

                elseif ui_chair_from == 4 then
                    image:setRotation(-90)
                end
            elseif ui_chair_to == 3 then
                image:setPosition(17.85,22)
                image:setScale(0.8)
                if ui_chair_from == 1 then
                    image:setRotation(180)
                elseif ui_chair_from == 2 then
                    image:setRotation(90)
                elseif ui_chair_from == 4 then
                    image:setRotation(-90)
                end
            elseif ui_chair_to == 4 then
                image:setPosition(10,26.6)
                image:setScale(0.8)
                if ui_chair_from == 1 then
                    image:setRotation(180)
                elseif ui_chair_from == 2 then
                    image:setRotation(90)
                elseif ui_chair_from == 3 then

                end
            end
        end
    end
end

-- 处理吃牌
function HandCardMediator:eatCard()
    print("HandCardMediator:eatCard")
    local MyGameConstants = cc.exports.MyGameConstants
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("HandCardProxy"):getData()
    local ActInfoData = data.ActInfoData

    local ui_chair = GameUtils:getInstance():getUIChairByServerChair(ActInfoData.byToUser)
    local nIndex = ActInfoData.nIdx + 1 -- 牌栏位置
    local eatcards = ActInfoData.cpgCards

    for i = 1,4 do
        local card = self.all_hand_cards[ui_chair].cpgCards[nIndex].cards[i]
        if i == 4 then
            card:setVisible(false)
        else
            local image_name = self:getImageName(ui_chair,eatcards[i])
            card:getChildByName("Image_value"):loadTexture(image_name)
            card:getChildByName("Image_value"):setVisible(true)
            card.value = eatcards[i]
        end
    end
    self.all_hand_cards[ui_chair].cpgCards[nIndex]:setVisible(true)
    self:removeCards(ui_chair,3,true)
    --更新左右两边牌的位置
    self:updateCardPos(ui_chair,nIndex)

    --对玩家手牌进行更新
    if ui_chair == 1 then
        self:updateSelfCards()
    elseif GameUtils:getInstance():getGameType() == 10 then
        for i=1,14 do
            if i <= nIndex * 3 then
                local card = self.all_hand_cards[ui_chair].resultCards[i]
                if card ~= nil then
                    card:setVisible(false)
                end
            end
        end
        self:updateOtherUserHandCards(ActInfoData.sAct.iActCID)
    end
end

--处理碰牌
function HandCardMediator:pengCard()
    print("HandCardMediator:pengCard")
    local MyGameConstants = cc.exports.MyGameConstants
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("HandCardProxy"):getData()
    local ActInfoData = data.ActInfoData

    local ui_chair = GameUtils:getInstance():getUIChairByServerChair(ActInfoData.sAct.iActCID)
    local nIndex = ActInfoData.sCPG.index + 1 -- 牌栏位置
    local pengcards = ActInfoData.sCPG.vTiles
    
    for i = 1,4 do
        local card = self.all_hand_cards[ui_chair].cpgCards[nIndex].cards[i]
        if i == 4 then
            card:setVisible(false)
        else
            local image_name = self:getImageName(ui_chair,pengcards[i])
            card:getChildByName("Image_value"):loadTexture(image_name)
            card:getChildByName("Image_value"):setVisible(true)
            card.value = pengcards[i]
        end
    end
    self.all_hand_cards[ui_chair].cpgCards[nIndex]:setVisible(true)
    self:removeCards(ui_chair,3,true)
    self:updateCardPos(ui_chair,nIndex)

    --对玩家手牌进行更新
    if ui_chair == 1 then
        self:updateSelfCards()
    elseif GameUtils:getInstance():getGameType() == 10 then
        for i=1,14 do
            if i <= nIndex * 3 then
                local card = self.all_hand_cards[ui_chair].resultCards[i]
                if card ~= nil then
                    card:setVisible(false)
                end
            end
        end
        self:updateOtherUserHandCards(ActInfoData.sAct.iActCID)
    end
end

-- 处理杠牌
function HandCardMediator:gangCard()
    print("MJHandCardLayer:gangCard")
    local MyGameConstants = cc.exports.MyGameConstants
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("HandCardProxy"):getData()
    local ActInfoData = data.ActInfoData

    local colorType = GameUtils:getInstance():getMJCardBack()
    local ui_chair = GameUtils:getInstance():getUIChairByServerChair(ActInfoData.sAct.iActCID)
    local nIndex = ActInfoData.sCPG.index + 1 -- 牌栏位置
    local gangcards = ActInfoData.sCPG.vTiles

    local gangType = ActInfoData.sAct.eAction -- 杠的类型
    if gangType ~= MyGameConstants.MJActFlag.BuGang then
        self:removeCards(ui_chair,3,false)
    end

    self.all_hand_cards[ui_chair].needOutCard:setVisible(false)
    for i = 1,4 do
        local card = self.all_hand_cards[ui_chair].cpgCards[nIndex].cards[i]
        local value = card:getChildByName("Image_value")
        if gangType == MyGameConstants.MJActFlag.AnGang then
            --暗杠牌栏处理,记录下 当前位置的杠类型 (暗杠换肤的时候需要用到)
             self.all_hand_cards[ui_chair].cpgCards[nIndex].isAnGang = true
            local isShow = false 
            if MyGameConstants.IS_SHOW_ANGANG_CARD then
                if i == 4 then
                    isShow = true
                    card.value = gangcards[i]
                end
            else
                if i == 4 and ui_chair == 1 then
                    isShow = true
                    card.value = gangcards[i]
                end
            end

            if isShow then
                --只有自己的牌才显示暗杠的是什么
                local image_name = self:getImageName(ui_chair,gangcards[i])
                value:loadTexture(image_name)
                value:setVisible(true)
            else
                --前三张牌翻面显示
                if ui_chair == 2 or ui_chair == 4  then
                   card:loadTexture(MyGameConstants.COLOR_RES_PATH[colorType] .. "Front_Small_06.png")
                   value:setVisible(false)
                elseif ui_chair == 3  then 
                   card:loadTexture(MyGameConstants.COLOR_RES_PATH[colorType] .. "Front_Small_05.png")
                   value:setVisible(false)
                elseif ui_chair == 1  then
                   card:loadTexture(MyGameConstants.COLOR_RES_PATH[colorType] .. "Big_03.png")
                   value:setVisible(false)
                end
            end
        else
            local image_name = self:getImageName(ui_chair,gangcards[i])
            value:loadTexture(image_name)
            value:setVisible(true)
            card.value = gangcards[i]
        end
        --更新左右两边牌的位置  如果是补杠  不能直接传nIndex
        if gangType ~= MyGameConstants.MJActFlag.BuGang then
            self:updateCardPos(ui_chair,nIndex)
        end
        card:setVisible(true)
    end
    self.all_hand_cards[ui_chair].cpgCards[nIndex]:setVisible(true)
    
    --对玩家手牌进行更新
    if ui_chair == 1 then
        self:updateSelfCards()
    elseif GameUtils:getInstance():getGameType() == 10 then
        for i=1,14 do
            if i <= nIndex * 3 then
                local card = self.all_hand_cards[ui_chair].resultCards[i]
                if card ~= nil then
                    card:setVisible(false)
                end
            end
        end
        self:updateOtherUserHandCards(ActInfoData.sAct.iActCID)
    end
end

-- 胡牌UI处理
function HandCardMediator:huCard()
    print("HandCardMediator:huCard")
    local MyGameConstants = cc.exports.MyGameConstants
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("HandCardProxy"):getData()
    local ActInfoData = data.ActInfoData
    local ui_chair = GameUtils:getInstance():getUIChairByServerChair(ActInfoData.sAct.iActCID)

    local tiles = ActInfoData.vAllTiles
    local deskInfo = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
    GameLogic:sort(tiles,deskInfo.LaiZi)
    local index = 1
    for j = 1, 14 do
        local card = self.all_hand_cards[ui_chair].resultCards[j]
        if j <= 14 - #tiles then
            card:setVisible(false)
        else
            local image_name = self:getImageName(ui_chair, tiles[index])
            card:getChildByName("Image_value"):loadTexture(image_name)
            card:setVisible(true)
            index = index + 1
        end
        -- 隐藏胡牌玩家手牌
        if j ~= 14 then
            self.all_hand_cards[ui_chair].handCards[j]:setVisible(false)
        end
    end
    self.all_hand_cards[ui_chair].needOutCard:setVisible(false)

    if ui_chair == 2 or ui_chair == 4 then
        local pox_y = self.Panel_handcards[ui_chair]:getPositionY()
        if ui_chair == 2 then
            --pox_y = pox_y + 20
        else
            --pox_y = pox_y - 20
        end
        self.Panel_resultcards[ui_chair]:setPositionY(pox_y)
    end
end

-- 获取当前牌值对应的麻将子名
function HandCardMediator:getImageName(ui_chair,card_value)
    if ui_chair == 1 then
        return "ui_res/Mahjong/Big/Big_".. tostring(card_value)..".png"
    else
        return "ui_res/Mahjong/Small/Small_".. tostring(card_value)..".png"
    end
end

--[[
从手里拿走几张牌 只是隐藏 非真正移除
@param ui_chair 椅子位置
@param removeNum移除了几张牌
@param isShowNeedoutCard是否显示要出的牌
]]
function HandCardMediator:removeCards(ui_chair ,removeNum,isShowNeedoutCard)
    for i = 1, 13 do
        local handcard = self.all_hand_cards[ui_chair].handCards[i]

        if handcard:isVisible() then
            handcard:setVisible(false)
            if ui_chair == 1 then
                handcard.Value = -1
            end
            removeNum = removeNum - 1
            if removeNum == 0 then
                break
            end
        end
    end

    if GameUtils:getInstance():getGameType() ~= 10 or ui_chair == 1 then
        self.all_hand_cards[ui_chair].needOutCard:setVisible(isShowNeedoutCard)
    end
end

-- 实时计算牌的位置
function HandCardMediator:updateCardPos(ui_chair,cpg_nums)
    print("HandCardMediator:updateCardPos")
    local panel_cpg = self.Panel_cpg_cards[ui_chair]
    local panel_handcard = self.Panel_handcards[ui_chair]

    if ui_chair == 4 then
        if cpg_nums == 1 then
            panel_handcard:setPositionY(25)
        elseif cpg_nums == 2 then
            panel_handcard:setPositionY(0)
        elseif cpg_nums == 3 then
            panel_handcard:setPositionY(-25)
        elseif cpg_nums == 4 then
            panel_handcard:setPositionY(-45)
        end
    end

    if ui_chair == 2 then
        if cpg_nums == 1 then
            panel_handcard:setPositionY(-30)
        elseif cpg_nums == 2 then
            panel_handcard:setPositionY(-5)
        elseif cpg_nums == 3 then
            panel_handcard:setPositionY(20)
        elseif cpg_nums == 4 then
            panel_handcard:setPositionY(45)
        end
    end
end

-- 取消当前点击牌桌面所有可见的牌颜色
function HandCardMediator:cancelCurSameCard()
    print("HandCardMediator:cancelCurSameCard")
    for i = 1, 4 do
        for j = 1, 4 do
            if self.all_hand_cards[i].cpgCards[j]:isVisible() == true then
                for k = 1, 4 do
                    local card = self.all_hand_cards[i].cpgCards[j].cards[k]
                    if card:isVisible() == true then
                        card:setColor(MyGameConstants.UNSELECTED_COLOR)
                    end
                end
            end
        end
    end
end

-- 显示当前点击牌桌面所有可见的牌颜色
function HandCardMediator:showCurSameCard()
    print("HandCardMediator:showCurSameCard")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("HandCardProxy"):getData()
    for i = 1, 4 do
        for j = 1, 4 do
            if self.all_hand_cards[i].cpgCards[j]:isVisible() == true then
                for k = 1, 4 do
                    local card = self.all_hand_cards[i].cpgCards[j].cards[k]
                    if card:isVisible() == true and card.value == data.ClickCardValue then
                        card:setColor(MyGameConstants.SELECTED_COLOR)
                    end
                end
            end
        end
    end
end

-- 断线重连
function HandCardMediator:gameStation()
    print("HandCardMediator:gameStation")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("HandCardProxy"):getData()

    local colorType = GameUtils:getInstance():getMJCardBack()
    local station = data.GameStationData.eMJState
    if station >= 16 and station < 24 then
        self:ui_open()
        local allHandCards = data.GameStationData.vAllHandtiles
        if table.nums(allHandCards) >= 1 then
            for k, v in pairs(allHandCards) do
                local ui_chair = GameUtils:getInstance():getUIChairByServerChair(k - 1)

                -- 显示吃碰杠牌
                if v.vChiPengGang ~= nil and table.nums(v.vChiPengGang) >= 1 then
                    for i, cpData in pairs(v.vChiPengGang) do
                        local bAnGang = cpData.bAnGang
                        local iType = cpData.iType
                        local nIndex = cpData.index + 1
                        local cardData = cpData.vTiles
                        self:showActFrom(iType,cpData.iFromCID,k-1,nIndex)
                        if iType == MyGameConstants.MJActFlag.Chi
                            or iType == MyGameConstants.MJActFlag.Peng then
                            for n = 1, 4 do
                                local card = self.all_hand_cards[ui_chair].cpgCards[nIndex].cards[n]
                                if n == 4 then
                                    card:setVisible(false)
                                else
                                    local image_name = self:getImageName(ui_chair, cardData[n])
                                    card:getChildByName("Image_value"):loadTexture(image_name)
                                    card:getChildByName("Image_value"):setVisible(true)
                                    card.value = cardData[n]
                                end
                            end

                        elseif iType >= MyGameConstants.MJActFlag.DianGang and iType <= MyGameConstants.MJActFlag.BuGang then
                            for n = 1, 4 do
                                local card = self.all_hand_cards[ui_chair].cpgCards[nIndex].cards[n]
                                local value = card:getChildByName("Image_value")
                                if iType == MyGameConstants.MJActFlag.AnGang then
                                    -- 暗杠牌栏处理,记录下 当前位置的杠类型 (暗杠换肤的时候需要用到)
                                    self.all_hand_cards[ui_chair].cpgCards[nIndex].isAnGang = true
                                    local isShow = false
                                    if MyGameConstants.IS_SHOW_ANGANG_CARD then
                                        if n == 4 then
                                            isShow = true
                                        end
                                    else
                                        if n == 4 and ui_chair == 1 then
                                            isShow = true
                                        end
                                    end

                                    if isShow then
                                        -- 只有自己的牌才显示暗杠的是什么
                                        local image_name = self:getImageName(ui_chair, cardData[n])
                                        value:loadTexture(image_name)
                                        value:setVisible(true)
                                        card.value = cardData[n]
                                    else
                                        -- 前三张牌翻面显示
                                        if ui_chair == 2 or ui_chair == 4 then
                                            card:loadTexture(MyGameConstants.COLOR_RES_PATH[colorType] .. "Front_Small_06.png")
                                            value:setVisible(false)
                                        elseif ui_chair == 3 then
                                            card:loadTexture(MyGameConstants.COLOR_RES_PATH[colorType] .. "Front_Small_05.png")
                                            value:setVisible(false)
                                        elseif ui_chair == 1 then
                                            card:loadTexture(MyGameConstants.COLOR_RES_PATH[colorType] .. "Big_03.png")
                                            value:setVisible(false)
                                        end
                                    end
                                else
                                    local image_name = self:getImageName(ui_chair, cardData[n])
                                    value:loadTexture(image_name)
                                    value:setVisible(true)
                                    card.value = cardData[n]
                                end
                                card:setVisible(true)
                            end
                        end
                        self:updateCardPos(ui_chair, nIndex)
                        self.all_hand_cards[ui_chair].cpgCards[nIndex]:setVisible(true)
                    end
                end

                -- 显示手牌
                if v.vAllTiles ~= nil and table.nums(v.vAllTiles) >= 1 then
                    local hideNums = 0
                    if v.vChiPengGang ~= nil then
                        hideNums = table.nums(v.vChiPengGang) * 3
                    end
                    local cardNums = #v.vAllTiles
                    for i = 1, 13 do
                        if i <= hideNums then
                            self.all_hand_cards[ui_chair].handCards[i]:setVisible(false)
                        else
                            self.all_hand_cards[ui_chair].handCards[i]:setVisible(true)
                        end
                    end
                    if (hideNums + cardNums) == 14 then
                        self.all_hand_cards[ui_chair].needOutCard:setVisible(true)
                    end
                    if ui_chair == 1 then
                        self:updateSelfCards()
                    end

                    -- 录像中处理断线重连手牌
                    if ui_chair ~= 1 and GameUtils:getInstance():getGameType() == 10 then
                        for i = 1, 13 do
                            self.all_hand_cards[ui_chair].handCards[i]:setVisible(false)
                        end
                        self.all_hand_cards[ui_chair].needOutCard:setVisible(false)

                        local hideNums = 0
                        if v.vChiPengGang ~= nil then
                            hideNums = table.nums(v.vChiPengGang) * 3
                        end
                        local cardNums = #v.vAllTiles
                        for i = 1, 13 do
                            if i <= hideNums then
                                self.all_hand_cards[ui_chair].resultCards[i]:setVisible(false)
                            else
                                self.all_hand_cards[ui_chair].resultCards[i]:setVisible(true)
                            end
                        end
                        if (hideNums + cardNums) == 14 then
                            self.all_hand_cards[ui_chair].resultCards[14]:setVisible(true)
                        end

                        self:updateOtherUserHandCards(k - 1)
                    end
                end
            end
        end
    end

    -- 显示查听
    if data.GameStationData.eMJState >= 16 and data.GameStationData.eMJState < 24 then
        if data.GameStationData.iTokenOwnerCID == GameUtils:getInstance():getSelfServerChair() then
            self:showOutCardTing()
        end
    end
end

-- 录像中刷新其他玩家手牌
function HandCardMediator:updateOtherUserHandCards(server_chair)
    print("HandCardMediator:updateOtherUserHandCards")
    if server_chair < 0 or server_chair > 3 then
        return
    end
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("HandCardProxy"):getData()
    local allHandCards = data.AllHandCards

    local handCards = allHandCards[server_chair + 1]
    local ui_chair = GameUtils:getInstance():getUIChairByServerChair(server_chair)
    local j = 1
    if ui_chair >= 2 and ui_chair <= 4 then
        for i = 1, 14 do
            local card = self.all_hand_cards[ui_chair].resultCards[i]
            if card:isVisible() == true or i == 14 then
                if #handCards >= j then
                    local image_name = self:getImageName(ui_chair, handCards[j])
                    card:getChildByName("Image_value"):loadTexture(image_name)
                    card:setVisible(true)
                    j = j + 1
                end
            end
        end
    end
end

-- 配牌
function HandCardMediator:Test()
    self:updateSelfCards()
end

return HandCardMediator