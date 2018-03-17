local ButtonPanelMediator = import(".ButtonPanelMediator")
local Mediator = cc.load("puremvc").Mediator
local MenuMediator = class("MenuMediator", Mediator)
local GameMusic = import("....GameMusic")

function MenuMediator:ctor(root)
    print("-------------->MenuMediator:ctor")
	MenuMediator.super.ctor(self, "MenuMediator",root)
	self.root = root
end

function MenuMediator:listNotificationInterests()
    print("-------------->MenuMediator:listNotificationInterests")
	local MyGameConstants = cc.exports.MyGameConstants
	return {
        "ME_gamestation",
        "ME_auto",
        MyGameConstants.C_FRE_STARTGAME,
        MyGameConstants.C_BUTTONPANEL_CLOSE,
		MyGameConstants.START_GAME,
        MyGameConstants.PIAO_NOTIFY,
        MyGameConstants.C_GAME_INIT,
        MyGameConstants.PLAYER_SIT,
        GameConstants.EXIT_GAME,
	}
end

function MenuMediator:onRegister()
    print("-------------->MenuMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local userStateProxy = platformFacade:retrieveProxy("UserStateProxy")
	local GameConstants = cc.exports.GameConstants
    local MyGameConstants = cc.exports.MyGameConstants
    local PlatformConstants = cc.exports.PlatformConstants

    gameFacade:registerCommand(MyGameConstants.C_RULES_OPEN, cc.exports.RulesCommand)
    gameFacade:registerCommand(MyGameConstants.C_MATCHCARD_OPEN, cc.exports.TestCommand)
    gameFacade:registerCommand(MyGameConstants.C_HELP_OPEN, cc.exports.HelpCommand)
    gameFacade:registerCommand(MyGameConstants.C_SET_OPEN, cc.exports.SettingCommand)
    gameFacade:registerCommand(MyGameConstants.C_PIAO_REQ, cc.exports.PiaoReqCommand)
    gameFacade:registerCommand(MyGameConstants.C_AUTO, cc.exports.AutoReqCommand)

    if gameFacade:hasProxy("GameRoomProxy") then
        local gameRoom = gameFacade:retrieveProxy("GameRoomProxy")
    end

    -- 返回大厅
    self.Button_back = self.root:getChildByName("Button_back")
    self.Button_back:addClickEventListener( function()
        local strMsg = "返回大厅您的房间仍然会保留哦！"
        local function okCall()  --确定按钮回调
            local roomID=GameUtils:getInstance():getGameRoomKey()
            userStateProxy:getData().roomID=roomID
            userStateProxy:getData().stateType=1   --1 为好友房
            platformFacade:sendNotification(PlatformConstants.UPDATE_PRIVATEROOM_STATE)
            print("返回大厅保存房间ID："..userStateProxy:getData().roomID)
            gameFacade:sendNotification(GameConstants.REQUEST_PRVLEAVE)
            gameFacade:sendNotification(GameConstants.EXIT_GAME)
        end 
        local tMsg = {mType = 2, code = 1, msg = strMsg, okCallback = okCall} --类型为2，code无用，msg为显示的描述，okCallback为按确定按钮的回调函数
        gameFacade:sendNotification(GameConstants.UPDATE_MSGBOX_EX, tMsg) 
    end )

    -- 房主解散房间
    self.Button_dismiss_desk = self.root:getChildByName("Button_dismiss_desk")
    self.Button_dismiss_desk:addClickEventListener(function()
        GameMusic:playClickEffect()
        local strMsg = "解散房间不扣房卡，是否确定解散？"
        local function okCall()  --确定按钮回调
            userStateProxy:getData().stateType=0  --0解散房间回到大厅
            platformFacade:sendNotification(PlatformConstants.UPDATE_PRIVATEROOM_STATE)
            gameFacade:sendNotification(GameConstants.REQUEST_PRVDISMISS)
            
        end 
        local tMsg = {mType = 2, code = 1, msg = strMsg, okCallback = okCall} --类型为2，code无用，msg为显示的描述，okCallback为按确定按钮的回调函数
        gameFacade:sendNotification(GameConstants.UPDATE_MSGBOX_EX, tMsg) 
        
    end)
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local login = platformFacade:retrieveProxy("LoginProxy")
    if gameFacade:hasProxy("GameRoomProxy") then
        local gameRoom = gameFacade:retrieveProxy("GameRoomProxy")
        if gameRoom:getData().masterId ~= login:getData().uid then
            self.Button_dismiss_desk:setVisible(false)
            self.Button_back:setPosition(self.Button_dismiss_desk:getPosition())
        end
    end
    
    -- 邀请微信好友
    self.Button_invite_wx = self.root:getChildByName("Button_invite_wx")
    self.Button_invite_wx:setVisible(false)
    self.Button_invite_wx:addClickEventListener( function()
        GameMusic:playClickEffect()
        local strTitle = "转转麻将，房号:" .. tostring(GameUtils:getInstance():getGameRoomKey())
        local strDesc = "老婆不在家，快来和我一起玩转转麻将吧！"
        local strScene = "0"   -- 0 分享到好友   1 分享到朋友圈
        local ShareFriendUrl = "http://share.game4588.com"  --好友分享网址
        cc.exports.wxShareFriends(ShareFriendUrl, strTitle, strDesc, nil, strScene)
    end )

    -- 准备
    self.Button_prepare = self.root:getChildByName("Button_prepare")
    self.Button_prepare:setVisible(false)

    -- 配牌器
    local Button_match = self.root:getChildByName("Button_match")
    Button_match:setVisible(MyGameConstants.IS_SHOW_MATCH_CARD)
    Button_match:addClickEventListener(function ()
        GameMusic:playClickEffect()
        gameFacade:sendNotification(MyGameConstants.C_MATCHCARD_OPEN)
    end)

    -- 玩法
    local Button_play = self.root:getChildByName("Button_play")
    Button_play:addClickEventListener(function ()
        GameMusic:playClickEffect()
        gameFacade:sendNotification(MyGameConstants.C_RULES_OPEN)
    end)

    -- 商城
    local Button_shore = self.root:getChildByName("Button_shore")
    Button_shore:addClickEventListener(function ()
        GameMusic:playClickEffect()
    end)

    gameFacade:registerMediator(ButtonPanelMediator.new())
     -- 收起
    local Button_packup = self.root:getChildByName("Button_packup")
    self.Button_packup = Button_packup
    Button_packup:addClickEventListener(function ()
        GameMusic:playClickEffect()
        Button_packup:setVisible(false)
        gameFacade:sendNotification(MyGameConstants.C_BUTTONPANEL_OPEN)
    end)

    -- 聊天按钮
    local Button_chat = self.root:getChildByName("Button_chat")
    Button_chat:setVisible(false)

    -- 语音
    local Button_voice = self.root:getChildByName("Button_voice")
    Button_voice:setVisible(false)

    -- 飘菜单
    local Panel_piao_root = self.root:getChildByName("Panel_piao")
    self.Panel_piao_root = Panel_piao_root
    local Button_bupiao = Panel_piao_root:getChildByName("Button_bupiao")
    Button_bupiao:addClickEventListener(function()
        GameMusic:playClickEffect()
        self.Panel_piao_root:setVisible(false)
        gameFacade:sendNotification(MyGameConstants.C_PIAO_REQ,{value = 0})
    end)
    
    for i=1,2 do
        local Button_piao = Panel_piao_root:getChildByName("Button_piao_" .. i)
        Button_piao:addClickEventListener(function()
            GameMusic:playClickEffect()
            self.Panel_piao_root:setVisible(false)
            gameFacade:sendNotification(MyGameConstants.C_PIAO_REQ,{value = i})
        end
        )
    end
    Panel_piao_root:setVisible(false)

    -- 遮罩
    self.Panel_shade = self.root:getChildByName("Panel_shade")
    self.Panel_shade:setVisible(false)

    -- 开始游戏
    local Button_startgame = self.root:getChildByName("Button_startgame")
    self.Button_startgame = Button_startgame
    Button_startgame:setVisible(false)
    Button_startgame:addClickEventListener(function()
        GameMusic:playClickEffect()
        Button_startgame:setVisible(false)
        self:freStartGame()
    end)

    -- 匹配提示
    self.Text_mate = self.root:getChildByName("Text_mate")
    self.Text_mate:setVisible(false)

    -- 取消配匹
    self.Button_cancel = self.root:getChildByName("Button_cancel")
    self.Button_cancel:setVisible(false)
    self.Button_cancel:addClickEventListener(function()
        GameMusic:playClickEffect()
        self:hideMate()
        self.Button_startgame:setVisible(true)
        gameFacade:sendNotification(GameConstants.REQUEST_QUKCACQUE)
    end)
    
    -- 托管界面
    self.Panel_auto = self.root:getChildByName("Panel_auto")
    self.Panel_auto:setVisible(false)

    -- 托管
    self.Button_auto = self.root:getChildByName("Button_auto")
    self.Button_auto:setVisible(false)
    self.Button_auto:addClickEventListener(function() 
        GameMusic:playClickEffect()
        self:auto()
        gameFacade:sendNotification(MyGameConstants.C_AUTO,{bAuto = true})
    end)

    -- 取消托管
    self.Button_cancelauto = self.Panel_auto:getChildByName("Button_cancelauto")
    self.Button_cancelauto:addClickEventListener(function()
        self:cancelAuto()
        gameFacade:sendNotification(MyGameConstants.C_AUTO, { bAuto = false })
    end)

    if GameUtils:getInstance():getGameType() == 1 then -- 房卡场
        Button_shore:setVisible(false)
        self.Button_invite_wx:setVisible(true)
        self.Button_auto:setVisible(false)
        Button_play:setVisible(true)
        --Button_voice:setVisible(true)
        --Button_chat:setVisible(true)
        --self.Button_prepare:setVisible(true)
    else
        if GameUtils:getInstance():getGameType() == 3 then
            Button_startgame:setVisible(true)
        end
        
        self.Button_dismiss_desk:setVisible(false)
        self.Button_back:setVisible(false)
        Button_play:setVisible(false)
        self.Button_back:setPosition(self.Button_dismiss_desk:getPosition())
    end
end

function MenuMediator:onRemove()
    print("-------------->MenuMediator:onRemove")
	self:setViewComponent(nil)
end

function MenuMediator:handleNotification(notification)
    print("-------------->MenuMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local MyGameConstants = cc.exports.MyGameConstants
	
    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("MenuMediator")
        gameFacade:removeProxy("MenuProxy")
    elseif name == MyGameConstants.C_GAME_INIT then
        self:initView()
        self:hidePiao()
        self:cancelAuto()
    elseif name == MyGameConstants.C_BUTTONPANEL_CLOSE then
        self:showPickUpButton()
    elseif name == MyGameConstants.C_FRE_STARTGAME then
        self:freStartGame()
    elseif name == MyGameConstants.START_GAME then
        self:GameStart()
    elseif name == MyGameConstants.PIAO_NOTIFY then
        self:showAddPiao()
    elseif name == MyGameConstants.PLAYER_SIT then
        self:hideMate()
    elseif name == "ME_gamestation" then
        self:gameStation()
    elseif name == "ME_auto" then
        self:autoNotify()
    end
end

---------------------------------------------------------------------------

-- 初始化界面
function MenuMediator:initView()
    self.root: setLocalZOrder(MyGameConstants.ORDER_MENU) 
    self.Button_auto:setVisible(false)
end

-- 快速开始金币场开始游戏
function MenuMediator:freStartGame()
    self.root:setLocalZOrder(20)
    self.Panel_shade:setVisible(true)
    self.Text_mate:setVisible(true)
    self.Button_cancel:setVisible(true)
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    gameFacade:sendNotification(GameConstants.REQUEST_QUKQUEUE)
end

-- 隐藏正在匹配界面
function MenuMediator:hideMate()
    self.root:setLocalZOrder(MyGameConstants.ORDER_MENU)
    self.Panel_shade:setVisible(false)
    self.Text_mate:setVisible(false)
    self.Button_cancel:setVisible(false)
    self.Button_startgame:setVisible(false)
end


-- 显示收起按钮
function MenuMediator:showPickUpButton()
    self.Button_packup:setVisible(true)
end

-- 某玩家托管或取消托管
function MenuMediator:autoNotify()
    print("MenuMediator:autoNotify")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("MenuProxy"):getData()
    if GameUtils:getInstance():getSelfServerChair() == data.AutoData.iCID then
        if data.AutoData.bAuto == true then
            self:auto()
        else
            self:cancelAuto()
        end
    end
end

-- 托管
function MenuMediator:auto()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    self.root:setLocalZOrder(20)
    self.Panel_shade:setVisible(true)      
    self.Panel_auto:setVisible(true)

    for i=1,3 do
        local delay = 0
        if i == 1 then
            delay = 0.4
        elseif i == 2 then
            delay = 1.2
        elseif i == 3 then
            delay = 2
        end
        local image_point = self.Panel_auto:getChildByName("Image_point_" .. i)
        image_point:stopAllActions()
        image_point:setVisible(false)
        local sequence = cc.Sequence:create(cc.DelayTime:create(delay),cc.Show:create(),cc.DelayTime:create(2.4 - delay),cc.Hide:create())
        image_point:runAction(cc.RepeatForever:create(sequence))
    end
end

-- 取消托管
function MenuMediator:cancelAuto()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    self.root:setLocalZOrder(MyGameConstants.ORDER_MENU)
    self.Panel_auto:setVisible(false)
    self.Panel_shade:setVisible(false)

    for i = 1, 3 do
        local image_point = self.Panel_auto:getChildByName("Image_point_" .. i)
        image_point:stopAllActions()
    end
end

function MenuMediator:GameStart()
    print("MenuMediator:GameStart")
    self:hideButton()
    self:hidePiao()
    if GameUtils:getInstance():getGameType() ~= 1 then
        self.Button_auto:setVisible(true)
    end
end

function MenuMediator:hideButton()
    self.Button_dismiss_desk:setVisible(false)
    self.Button_back:setVisible(false)
    self.Button_invite_wx:setVisible(false)
    self.Button_prepare:setVisible(false)
end

function MenuMediator:hidePiao()
     self.Panel_piao_root:setVisible(false)
end

function MenuMediator:showAddPiao()
     self.Panel_piao_root:setVisible(true)
end

-- 断线重连
function MenuMediator:gameStation()
    print("MenuMediator:gameStation")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("MenuProxy"):getData()

    local piaoPointData = nil
    local station = data.GameStationData.eMJState
    if station < 15 or station == 24 then

    elseif station == 15 then
        piaoPointData = data.GameStationData.vPiaoPoint
        self:hideButton()
        if GameUtils:getInstance():getGameType() ~= 1 then
            self.Button_auto:setVisible(true)
        end
    elseif station >= 16 and station <= 24 then
        self:hideButton()
        self:hidePiao()
        if GameUtils:getInstance():getGameType() ~= 1 then
            self.Button_auto:setVisible(true)
            local bAutoTab = data.GameStationData.v_bIsauto
            for i=0,3 do
                if i == GameUtils:getInstance():getSelfServerChair() then
                    if bAutoTab[i+1] == true then
                        self:auto()
                    end
                end
            end
        end
    end

    if station == 11 and data.GameStationData.mj_iNowRound > 0 then
        self:hideButton()
        self:hidePiao()
    end

    -- 漂按钮显示
    if station == 15 and piaoPointData ~= nil and table.nums(piaoPointData) >= 1 then
        for i = 0, 3 do
            local point = piaoPointData[i+1]
            local ui_chair = GameUtils:getInstance():getUIChairByServerChair(i)
            if i == GameUtils:getInstance():getSelfServerChair() and point == 255 then
                self.Panel_piao_root:setVisible(true)
            end
        end
    end
end

return MenuMediator