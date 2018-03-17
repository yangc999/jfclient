local GameMusic = import("....GameMusic")
local Mediator = cc.load("puremvc").Mediator
local DeskInfoMediator = class("DeskInfoMediator", Mediator)

function DeskInfoMediator:ctor(root)
    print("-------------->DeskInfoMediator:ctor")
	DeskInfoMediator.super.ctor(self, "DeskInfoMediator",root)
	self.root = root
end

function DeskInfoMediator:listNotificationInterests()
    print("-------------->DeskInfoMediator:listNotificationInterests")
	local MyGameConstants = cc.exports.MyGameConstants
    local GameConstants = cc.exports.GameConstants
	return {
        "DI_updateround",
        "DI_makent",
        "DI_actnotify",
        "DI_getTokens",
        "DI_niaocard",
        "DI_gamestation",
        GameConstants.UPDATE_RANDING,
        MyGameConstants.C_UPDATE_CARDBACK,
        MyGameConstants.C_GAME_INIT,
        GameConstants.EXIT_GAME,
	}
end

function DeskInfoMediator:onRegister()
    print("-------------->DeskInfoMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local MyGameConstants = cc.exports.MyGameConstants
	
	gameFacade:registerCommand(MyGameConstants.START_GAME, cc.exports.DIStartGameCommand)
    gameFacade:registerCommand(MyGameConstants.NIAO_CARD, cc.exports.DINiaoCardCommand)

    self.AnimPos = {
        cc.p(640,272),
        cc.p(973,413),
        cc.p(640,554),
        cc.p(304,413),
    }

     -- 比赛场排名
    self.Text_ranking = self.root:getChildByName("Text_ranking")
    self.Text_ranking:setVisible(false)

     -- 桌子号
    self.Text_desknum = self.root:getChildByName("Text_desknum")
    self.Text_desknum:setVisible(false)

     -- 场次
    self.Text_session = self.root:getChildByName("Text_session")
    self.Text_session:setVisible(false)

     -- 底注
    self.Text_pour = self.root:getChildByName("Text_pour")
    self.Text_pour:setVisible(false)
  
    -- 房号
    self.Text_roomnum = self.root:getChildByName("Text_roomnum")
    self:updateRoomNums()
    
    -- 剩余牌和局数背景
    self.Panel_info = self.root:getChildByName("Panel_info")
    self.Panel_info:setVisible(false)

    -- 局数
    self.Text_round = self.Panel_info:getChildByName("Text_round")

    -- 剩余牌
    self.Text_remain = self.Panel_info:getChildByName("Text_remain")

    -- 水印
    self.Image_shuiyin = self.root:getChildByName("Image_shuiyin")
    self.Image_shuiyin:setVisible(true)

    -- 网络
    self.Image_newwork = self.root:getChildByName("Image_newwork")
    -- 电量
    self.Image_battery = self.root:getChildByName("Image_battery")

    -- 系统时间
    self.Text_time = self.root:getChildByName("Text_time")

    -- 倒计时背景
    self.TimeCountBg = self.root:getChildByName("TimeCountBg")
    self.Panel_direct = self.TimeCountBg:getChildByName("Panel_direct")
    self.Image_east = self.Panel_direct:getChildByName("Image_east")
    self.Image_south = self.Panel_direct:getChildByName("Image_south")
    self.Image_western = self.Panel_direct:getChildByName("Image_western")
    self.Image_north = self.Panel_direct:getChildByName("Image_north")

    self.Notice_Up = self.TimeCountBg:getChildByName("Notice_Up")
    self.Notice_Up:setVisible(false)
    self.Notice_left = self.TimeCountBg:getChildByName("Notice_left")
    self.Notice_left:setVisible(false)
    self.Notice_Right = self.TimeCountBg:getChildByName("Notice_Right")
    self.Notice_Right:setVisible(false)
    self.Notice_Down = self.TimeCountBg:getChildByName("Notice_Down")
    self.Notice_Down:setVisible(false)

    self.Text_djs = self.TimeCountBg:getChildByName("Text_djs")
    self.Text_djs:setVisible(false)
    --self.Text_djs:setString(tostring(0))

    -- 鸟牌
    local image_root = gameFacade:retrieveMediator("MainMediator").image_root
    local csbPath = "ui_csb/NiaoCardLayer.csb"
	local ui = cc.CSLoader:createNode(csbPath)
    ui:setPosition(0,0)
    local Panel_niaocard = ui:getChildByName("Panel_niaocard")
    image_root:addChild(ui,6)
    self.Panel_niaocard = Panel_niaocard
    Panel_niaocard:setVisible(false)
    self.niaoCards = {}
    for i=1,6 do
        self.niaoCards[i] = Panel_niaocard:getChildByName("card_" .. i)
        self.niaoCards[i]:setVisible(false)
    end
    
    self:updateDeskNum()
    self:updateNetWorkBattery()
    self:updateCardColor()
    self.Text_time:registerScriptHandler(handler(self,self.onNodeEvent))
end

function DeskInfoMediator:onRemove()
    print("-------------->DeskInfoMediator:onRemove")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    self:stopCountDown()  
	self:setViewComponent(nil)
end

function DeskInfoMediator:handleNotification(notification)
    print("-------------->DeskInfoMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	local MyGameConstants = cc.exports.MyGameConstants

    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("DeskInfoMediator")
        gameFacade:removeProxy("DeskInfoProxy")
    elseif name == MyGameConstants.C_UPDATE_CARDBACK then
        self:updateCardColor()
    elseif name == MyGameConstants.C_GAME_INIT then
        self:initView()
        self:stopCount()
        self:hideNiaoCards()
        self:setInfobg(false)
    elseif name == GameConstants.UPDATE_RANDING then
        self:updateRanking()
    elseif name == "DI_updateround" then
        self:GameStart()
        self:updateRound()
    elseif name == "DI_makent" then
        self:rotationTimeCountBg()
    elseif name == "DI_actnotify" then
        self:showActNotifyUser()
        self:stopCount()
        self:startMiddleCountDown()
    elseif name == "DI_getTokens" then
        self:updateSurplusCardNums()
        self:setInfobg(true)
        self:stopCount()
        self:startMiddleCountDown()
        self:showTokenUser()
    elseif name == "DI_niaocard" then
        self:updateNiaoCard()
    elseif name == "DI_gamestation" then
        self:gameStation()
    end
end


-----------------------------------------------------------------
-- 初始化界面
function DeskInfoMediator:initView()
    self.root:setLocalZOrder(MyGameConstants.ORDER_PLAYER_INFO)
    self.Image_east:loadTexture("ui_res/direct/east.png")
    self.Image_south:loadTexture("ui_res/direct/south.png")
    self.Image_western:loadTexture("ui_res/direct/western.png")
    self.Image_north:loadTexture("ui_res/direct/north.png")

    self.Notice_Up:stopAllActions()
    self.Notice_Down:stopAllActions()
    self.Notice_left:stopAllActions()
    self.Notice_Right:stopAllActions()
    self.Notice_Up:setVisible(false)
    self.Notice_left:setVisible(false)
    self.Notice_Right:setVisible(false)
    self.Notice_Down:setVisible(false)
    self.Text_djs:setVisible(false)
end

-- 比赛场刷新排名
function DeskInfoMediator:updateRanking()
    print("DeskInfoMediator:updateRanking")
    if GameUtils:getInstance():getGameType() == 4 then
        local gameFacade = cc.load("puremvc").Facade.getInstance("game")
        local data = gameFacade:retrieveProxy("GameRoomProxy"):getData().matchData
        if data.iRanking~= nil then
            self.Text_ranking:setString("排名：" .. tostring(data.iRanking) .. "/" ..tostring(data.iPlayerNum))
            self.Text_ranking:setVisible(true)
        end
    end
end

-- 刷新桌子号，场次，底注
function DeskInfoMediator:updateDeskNum()
    print("DeskInfoMediator:updateDeskNum")
    local gameType = GameUtils:getInstance():getGameType()
    if gameType == 2 then
        local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
        local DeskListProxy = platformFacade:retrieveProxy("DeskListProxy"):getData()
        print("lv = " .. DeskListProxy.lv)
        print("entry = " .. DeskListProxy.entry)
        print("deskNum = " .. DeskListProxy.deskNum)

        local text = "新手场"
        if DeskListProxy.lv == 1 then
            text = "新手场"
        elseif DeskListProxy.lv == 2 then
            text = "普通场"
        elseif DeskListProxy.lv == 3 then
            text = "精英场"
        elseif DeskListProxy.lv == 4 then
            text = "土豪场"
        end

        self.Text_session:setString("场次：" .. tostring(text))
        self.Text_session:setVisible(true)
        self.Text_pour:setString("底注：" .. tostring(DeskListProxy.entry))
        self.Text_pour:setVisible(true)
        self.Text_desknum:setString("桌号：" .. tostring(DeskListProxy.deskNum))
        self.Text_desknum:setVisible(true)
    end
end

-- 刷新网络电量
function DeskInfoMediator:updateNetWorkBattery()
    --print("DeskInfoMediator:updateNetWorkBattery")
    local networkType = cc.exports.getNetworkType()
    local networkStrength = cc.exports.getNetworkStrength()
    local batteryLevel = cc.exports.getBatteryLevel()
    --print("网络类型 = " .. tostring(networkType))
    --print("网络强度 = " .. tostring(networkStrength))
    --print("电量强度 = " .. tostring(batteryLevel))

    local workImageName = ""
    if networkType == "WIFI" then
        if tonumber(networkStrength) <= 33 then
            workImageName = "wifi_1.png"
        elseif tonumber(networkStrength) <= 66 then
            workImageName = "wifi_2.png"
        else
            workImageName = "wifi_3.png"
        end
    elseif networkType == "MOBILE" then
        if tonumber(networkStrength) <= 33 then
            workImageName = "rate_1.png"
        elseif tonumber(networkStrength) <= 66 then
            workImageName = "rate_2.png"
        else
            workImageName = "rate_3.png"
        end
    end
    self.Image_newwork:loadTexture("ui_res/networkbattery/" .. workImageName)

    local batteryImageName = ""
    if tonumber(batteryLevel) <= 0.04 then
       batteryImageName = "battery_0.png"
    elseif tonumber(batteryLevel) <= 0.28 then
        batteryImageName = "battery_1.png"
    elseif tonumber(batteryLevel) <= 0.52 then
        batteryImageName = "battery_2.png"
    elseif tonumber(batteryLevel) <= 0.76 then
        batteryImageName = "battery_3.png"
    else
        batteryImageName = "battery_4.png"
    end
    self.Image_battery:loadTexture("ui_res/networkbattery/" .. batteryImageName)
end

-- 更新鸟牌牌背
function DeskInfoMediator:updateCardColor()
    local colorType = GameUtils:getInstance():getMJCardBack()
    if colorType < 1 or colorType > 4 then
        return
    end
    for i = 1 ,6 do
        self.niaoCards[i]:getChildByName("Image_card"):loadTexture(MyGameConstants.COLOR_RES_PATH[colorType] .."Big_01.png")
    end  
end

-- 更新房号
function DeskInfoMediator:updateRoomNums()
    local roomKey = GameUtils:getInstance():getGameRoomKey()
    if roomKey ~= nil then
        self.Text_roomnum:setString("房号：" .. tostring(roomKey))
    else
        self.Text_roomnum:setVisible(false)
    end
end

function DeskInfoMediator:onNodeEvent(event)
    if event == "enter" then
        performWithDelay(self.Text_time, function()
            self:startCountDown()
        end , 0.1)
    elseif event == "exit" then
        self:stopCountDown()
    end
end

function DeskInfoMediator:startCountDown()
    self:update()
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc( handler(self , self.update ) , 1.0 ,false)
end

function DeskInfoMediator:stopCountDown()
    if self.schedulerID ~= nil then    
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry( self.schedulerID )
        self.schedulerID = nil
    end
end

function DeskInfoMediator:update()
    if self.Text_time ~= nil then
        self.Text_time:setString(tostring(os.date("%H:%M", os.time())))
        self:updateNetWorkBattery()
    else
        --print("Text_time is nil ")
    end
end

-- 是否显示剩余牌和当前局数信息
function DeskInfoMediator:setInfobg(visible)
    self.Panel_info:setVisible(visible)
end

function DeskInfoMediator:GameStart()
    print("DeskInfoMediator:onGameStart start")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local start_node = cc.CSLoader:createNode("animate/duiju/duiju.csb")
    self.start_node = start_node
    local start_action = cc.CSLoader:createTimeline("animate/duiju/duiju.csb")
    start_node:runAction(start_action)
    start_action:gotoFrameAndPlay(0,false)
    start_node:setPosition(cc.p(640,360))
   
    local image_root = gameFacade:retrieveMediator("MainMediator").image_root
    image_root:addChild(start_node,MyGameConstants.ORDER_GAME_ANIMATE)
    
    start_action:setLastFrameCallFunc( function()
        self.start_node:removeFromParent()
        GameMusic:playOtherEffect(EffectEnum.KAIS,false)
    end)
    print("DeskInfoMediator:onGameStart end")
end

-- 刷新局数
function DeskInfoMediator:updateRound()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
    local curRound = data.Round.mj_iNowRound
    local allRound = data.Round.mj_iAllRound

    if curRound and allRound then
        local gameType = GameUtils:getInstance():getGameType()
        if gameType == 1 or gameType == 10 then
            self.Text_round:setString(tostring(curRound .. "/" .. allRound))
        else
            self.Text_round:setString(tostring(curRound))
        end
    end
end

-- 更新剩余张数
function DeskInfoMediator:updateSurplusCardNums()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
    local TokenData = data.TokenData
    local nums = TokenData.iTileWallNums
    self.Text_remain:setString(tostring(nums))
end

-- 开始倒计时
function DeskInfoMediator:startMiddleCountDown()
    print("DeskInfoMediator:startMiddleCountDown")
    self.TimeCountBg:setVisible(true)
    self.curCountDountTime = 15
    self.Text_djs:setString(tostring(self.curCountDountTime))
    self.Text_djs:setVisible(true)

    local callback = cc.CallFunc:create( function()
        self.curCountDountTime = self.curCountDountTime - 1
        if self.curCountDountTime >= 0 then
            if self.Text_djs ~= nil then
                self.Text_djs:setString(tostring(self.curCountDountTime))
            end
        else
            self:stopCount()
        end
    end )

    local sequence = cc.Sequence:create(cc.DelayTime:create(1),callback)
    self.Text_djs:runAction(cc.RepeatForever:create(sequence))
end

function DeskInfoMediator:stopCount()
    self.Text_djs:stopAllActions()
end

-- 旋转东南西北位置
function DeskInfoMediator:rotationTimeCountBg()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
    local MakeNTData = data.MakeNTData

    local nt_ui_chair = GameUtils:getInstance():getUIChairByServerChair(MakeNTData.nBankerCID)
    local rotation = (- nt_ui_chair + 1)* 90
    self.Panel_direct:setRotation(rotation) 
end

-- 自己收到动作信息时显示倒计时
function DeskInfoMediator:showActNotifyUser()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
    local ActNotifyData = data.ActNotifyData
    local ui_chair = GameUtils:getInstance():getUIChairByServerChair(ActNotifyData.iCID)
    self:onPointToUser(ui_chair)
end

-- 显示倒计时指向玩家
function DeskInfoMediator:showTokenUser()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
    local TokenData = data.TokenData
    local ui_chair = GameUtils:getInstance():getUIChairByServerChair(TokenData.iCID)
    self:onPointToUser(ui_chair)
end

--倒计时指向
function DeskInfoMediator:onPointToUser(ui_chair)
    local rotion = self.Panel_direct:getRotation()
    self.Image_east:loadTexture("ui_res/direct/east.png")
    self.Image_south:loadTexture("ui_res/direct/south.png")
    self.Image_western:loadTexture("ui_res/direct/western.png")
    self.Image_north:loadTexture("ui_res/direct/north.png")
    self.Notice_Up:setVisible(false)
    self.Notice_Down:setVisible(false)
    self.Notice_left:setVisible(false)
    self.Notice_Right:setVisible(false)
    if ui_chair == MyGameConstants.Direct.Down then
        self.Notice_Down:setVisible(true)
        if rotion == 0 then
            self.Image_east:loadTexture("ui_res/direct/east_select.png")
        elseif rotion == -90 then
            self.Image_north:loadTexture("ui_res/direct/north_select.png")
        elseif rotion == -180 then
            self.Image_western:loadTexture("ui_res/direct/western_select.png")
        elseif rotion == -270 then
            self.Image_south:loadTexture("ui_res/direct/south_select.png")
        end
    elseif ui_chair == MyGameConstants.Direct.Right then  
        self.Notice_Right:setVisible(true)
        if rotion == 0 then
            self.Image_south:loadTexture("ui_res/direct/south_select.png")
        elseif rotion == -90 then
            self.Image_east:loadTexture("ui_res/direct/east_select.png")
        elseif rotion == -180 then
            self.Image_north:loadTexture("ui_res/direct/north_select.png")
        elseif rotion == -270 then
            self.Image_western:loadTexture("ui_res/direct/western_select.png")
        end
    elseif ui_chair == MyGameConstants.Direct.Up then  
        self.Notice_Up:setVisible(true)
        if rotion == 0 then
            self.Image_western:loadTexture("ui_res/direct/western_select.png")
        elseif rotion == -90 then
            self.Image_south:loadTexture("ui_res/direct/south_select.png")
        elseif rotion == -180 then
            self.Image_east:loadTexture("ui_res/direct/east_select.png")
        elseif rotion == -270 then
            self.Image_north:loadTexture("ui_res/direct/north_select.png")
        end
    elseif ui_chair == MyGameConstants.Direct.Left then  
        self.Notice_left:setVisible(true)
        if rotion == 0 then
            self.Image_north:loadTexture("ui_res/direct/north_select.png")
        elseif rotion == -90 then
            self.Image_western:loadTexture("ui_res/direct/western_select.png")
        elseif rotion == -180 then
            self.Image_south:loadTexture("ui_res/direct/south_select.png")
        elseif rotion == -270 then
            self.Image_east:loadTexture("ui_res/direct/east_select.png")
        end
    end

    -- 先停止所有动作
    self.Notice_Up:stopAllActions()
    self.Notice_Down:stopAllActions()
    self.Notice_left:stopAllActions()
    self.Notice_Right:stopAllActions()
    local blink = cc.Blink:create(1,1)
    local blinkmeta = nil
    if self.Notice_Up:isVisible() then
        blinkmeta = self.Notice_Up
    elseif self.Notice_Down:isVisible() then
        blinkmeta = self.Notice_Down
    elseif self.Notice_left:isVisible() then
        blinkmeta = self.Notice_left
    elseif self.Notice_Right:isVisible() then
        blinkmeta = self.Notice_Right
    end           
    blinkmeta:runAction(cc.RepeatForever:create(blink))
end

-- 更新鸟牌
function DeskInfoMediator:updateNiaoCard()
    self.Panel_niaocard:setVisible(true)
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
    local NiaoCardData = data.NiaoCardData
    
    if #NiaoCardData < 1 then
        return false
    end

    local num = #NiaoCardData
    self.Panel_niaocard:setPositionX((6 - num) * 48)
    local time = 0
    for k,v in pairs(NiaoCardData) do
        time = time + 0.3
        performWithDelay(self.root,
        function()
            self.niaoCards[k]:setVisible(true)
            local image = self.niaoCards[k]:getChildByName("Image_card"):getChildByName("Image_value")
            image:loadTexture("ui_res/Mahjong/Big/Big_" .. tostring(v) .. ".png")
            if v % 10 == 1 or v % 10 == 5 or v % 10 == 9 or v == 35 then
                self.niaoCards[k]:setColor(MyGameConstants.SELECTED_COLOR)
            end
        end,
        time)
    end

    performWithDelay(self.root,
    function()
        self.Panel_niaocard:setVisible(false)
    end ,
    time + 2) 
end

-- 隐藏鸟牌
function DeskInfoMediator:hideNiaoCards()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
    data.NiaoCard = {}

    self.Panel_niaocard:setVisible(false)
    self.Panel_niaocard:setPosition(0,0)
    for i=1,6 do
        self.niaoCards[i]:setVisible(false)
        self.niaoCards[i]:setColor(cc.c3b(255,255,255))
    end
end

-- 断线重连
function DeskInfoMediator:gameStation()
    print("DeskInfoMediator:gameStation")
    self:updateNetWorkBattery()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
    dump(data.GameStationData,"gameStation")

    local curData = nil
    local nt_chair = 255
    local station = data.GameStationData.eMJState
    if station < 15 or station == 24 then
        curData = data.GameStationData
        nt_chair = data.GameStationData.iZhuangCID
    elseif station == 15 then
        curData = data.GameStationData.sPreTile
        nt_chair = data.GameStationData.sPreTile.iZhuangCID
    elseif station >= 16 and station < 24 then
        curData = data.GameStationData.sPiaoStat.sPreTile
        nt_chair = data.GameStationData.sPiaoStat.sPreTile.iZhuangCID
    end

    -- 局数
    local curRound = curData.mj_iNowRound
    local allRound = curData.mj_iAllRound
    if curRound and allRound then
        if GameUtils:getInstance():getGameType() == 1 then
            self.Text_round:setString(tostring(curRound .. "/" .. allRound))
        else
            self.Text_round:setString(tostring(curRound))
        end
    end

    -- 剩余牌数
    if station >= 16 and station < 24 then
        if data.GameStationData.wallNumas ~= nil then
            self.Text_remain:setString(tostring(data.GameStationData.wallNumas))
        end
    end

    -- 旋转东南西北方位
    if nt_chair >= 0 and nt_chair <= 3 then
        local nt_ui_chair = GameUtils:getInstance():getUIChairByServerChair(nt_chair)
        local rotation =(- nt_ui_chair + 1) * 90
        self.Panel_direct:setRotation(rotation)
    end
end

return DeskInfoMediator
