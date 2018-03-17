local GameMusic = import("....GameMusic")
local Mediator = cc.load("puremvc").Mediator
local PlayerInfoMediator = class("PlayerInfoMediator", Mediator)

--正在游戏状态下每个玩家的头像位置
local PlayingPos = {
    cc.p(42,230),
    cc.p(1234,495),
    cc.p(324,660),
    cc.p(42,495),
}

function PlayerInfoMediator:ctor(root)
    print("-------------->PlayerInfoMediator:ctor")
	PlayerInfoMediator.super.ctor(self, "PlayerInfoMediator",root)
	self.root = root
    self.AnimPos = {
        cc.p(640,272),
        cc.p(973,413),
        cc.p(640,554),
        cc.p(304,413),
    }
end

function PlayerInfoMediator:listNotificationInterests()
    print("-------------->PlayerInfoMediator:listNotificationInterests")
    local MyGameConstants = cc.exports.MyGameConstants
    return {
        "PL_agreegame",
        "PL_makent",
        "PL_auto",
        "PL_piao",
        "PL_updatescore",
        "PL_cursitplayer",
        "PL_curstandplayer",
        "PL_curofflineplayer",
        "PL_currecomeplayer",
        "PL_alluserinfo",
        "PL_gamestation",
        MyGameConstants.START_GAME,
        MyGameConstants.C_GAME_INIT,
        GameConstants.EXIT_GAME,
        GameConstants.UPDATE_USER
    }
end

function PlayerInfoMediator:onRegister()
    print("-------------->PlayerInfoMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local MyGameConstants = cc.exports.MyGameConstants
	local GameConstants = cc.exports.GameConstants
    gameFacade:registerCommand(MyGameConstants.AGREE_GAME, cc.exports.PlayerAgreeCommand)
    gameFacade:registerCommand(MyGameConstants.PIAO_RESP, cc.exports.PIAddPiaoCommand)
    gameFacade:registerCommand(MyGameConstants.PLAYER_SIT, cc.exports.PlayerSitCommand)
    gameFacade:registerCommand(MyGameConstants.PLAYER_STAND, cc.exports.PlayerStandCommand)
    gameFacade:registerCommand(MyGameConstants.PLAYER_OFFLINE, cc.exports.PlayerOfflineCommand)
    gameFacade:registerCommand(MyGameConstants.PLAYER_RECOME, cc.exports.PlayerRecomeCommand)

    self.PlayerHeads = {}
    for i = 1 , 4 do
        self.PlayerHeads[i] = {}
        local Panel_player = self.root:getChildByName("Panel_player"):getChildByName("Panel_player_" .. i)
        self.PlayerHeads[i].Panel_player = Panel_player
        Panel_player:setVisible(false)

        self.PlayerHeads[i].Image_head_wx = Panel_player:getChildByName("Image_head_wx")
        local Image_head_bg = self.PlayerHeads[i].Image_head_wx:getChildByName("Image_head_bg")
        Image_head_bg:addClickEventListener( function()

        end)

        self.PlayerHeads[i].Image_head_bg = Image_head_bg
        -- 漂
        self.PlayerHeads[i].Image_piao = Image_head_bg:getChildByName("Image_piao")
        self.PlayerHeads[i].Image_piao:setVisible(false)
        -- 名称
        self.PlayerHeads[i].Text_nick = Image_head_bg:getChildByName("Text_nick")
        -- 分数
        self.PlayerHeads[i].Text_score = Image_head_bg:getChildByName("Text_score")
        self.PlayerHeads[i].Text_score:setString(tostring(0))
        -- 庄家
        self.PlayerHeads[i].Image_NT = Image_head_bg:getChildByName("NT_1")
        self.PlayerHeads[i].Image_NT:setVisible(false)
        -- 离线标记
        self.PlayerHeads[i].Image_offline = Image_head_bg:getChildByName("Image_offline")
        self.PlayerHeads[i].Image_offline:setVisible(false)
        -- 托管
        self.PlayerHeads[i].Image_auto = Image_head_bg:getChildByName("Image_auto")
        self.PlayerHeads[i].Image_auto:setVisible(false)
        -- 准备
        self.PlayerHeads[i].Image_ready = self.root:getChildByName("Panel_ready"):getChildByName("Image_ready_" .. i)
        self.PlayerHeads[i].Image_ready:setVisible(false)
    end
end

function PlayerInfoMediator:onRemove()
    print("-------------->PlayerInfoMediator:onRemove")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	self:setViewComponent(nil)
end

function PlayerInfoMediator:handleNotification(notification)
    print("-------------->PlayerInfoMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local MyGameConstants = cc.exports.MyGameConstants
    local GameConstants = cc.exports.GameConstants
	
    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("PlayerInfoMediator")
        gameFacade:removeProxy("PlayerInfoProxy")
    elseif name == MyGameConstants.C_GAME_INIT then
        self:initView()
    elseif name == MyGameConstants.START_GAME then
        self:gameStart()
        --self:showSitPlayer()
    elseif name == GameConstants.UPDATE_USER then
        self:updateWXHead()
    elseif name == "PL_agreegame" then
        self:agreeGame()
    elseif name == "PL_auto" then
        self:autoNotify()
    elseif name == "PL_makent" then
        self:makeNT()
    elseif name == "PL_updatescore" then
        self:updateScore()
    elseif name == "PL_piao" then
        self:showPiaoResult()
    elseif name == "PL_gamestation" then
        self:gameStation()
    elseif name == "PL_cursitplayer" then
        self:showCurSitPlayer()
    elseif name == "PL_curstandplayer" then
        self:hideCurStandPlayer()
    elseif name == "PL_curofflineplayer" then
        self:showCutPlayer()
    elseif name == "PL_currecomeplayer" then
        self:showRecomePlayer()
    elseif name == "PL_alluserinfo" then
        self:updateUserInfo()
    end

end


--------------------------------------------------------------------------
-- 初始化界面
function PlayerInfoMediator:initView()
    self.root: setLocalZOrder(MyGameConstants.ORDER_PLAYER_INFO) 
    for i=1,4 do
        self.PlayerHeads[i].Image_piao:setVisible(false)
        self.PlayerHeads[i].Image_auto:setVisible(false)
        self.PlayerHeads[i].Image_NT:setVisible(false)
    end
end

-- 录像刷新头像
function PlayerInfoMediator:updateUserInfo()
    print("PlayerInfoMediator:updateUserInfo")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("PlayerInfoProxy"):getData()
    local userInfo = data.AllUserInfo
    print(GameUtils:getInstance():getSelfServerChair())
    dump(userInfo,"userInfo")
    for k,v in pairs(userInfo) do
        local ui_chair = GameUtils:getInstance():getUIChairByServerChair(v.iCID)
        --self.PlayerHeads[ui_chair].Image_head_wx:loadTexture(tostring(v.head))
        self.PlayerHeads[ui_chair].Text_nick:setString(tostring(v.sNick))
        self.PlayerHeads[ui_chair].Text_score:setString(tostring(v.iScore))
        self.PlayerHeads[ui_chair].Panel_player:setVisible(true)
    end
end

function PlayerInfoMediator:gameStart()
    for i=1,4 do
        self.PlayerHeads[i].Image_piao:setVisible(false)
        self.PlayerHeads[i].Image_ready:setVisible(false)
        for j=1,3 do
            local image_point = self.PlayerHeads[i].Image_ready:getChildByName("Image_point_" .. j)
            image_point:stopAllActions()
        end
    end

    -- 比赛场每轮开始重置分数
    if GameUtils:getInstance():getGameType() == 4 then
        local gameFacade = cc.load("puremvc").Facade.getInstance("game")
        local data = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
        local curRound = data.Round.mj_iNowRound
        if curRound == 1 then
            for i = 1, 4 do
                self.PlayerHeads[i].Text_score:setString(0)
            end
        end
    end
end

-- 有玩家准备
function PlayerInfoMediator:agreeGame()
    print("DeskInfoMediator:agreeGame")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("PlayerInfoProxy"):getData()
    local ui_chair = GameUtils:getInstance():getUIChairByServerChair(data.AgreeGameUser)
    self:agreeAnimate(ui_chair)
end

-- 准备动画
function PlayerInfoMediator:agreeAnimate(ui_chair)
    for i=1,3 do
        if self.PlayerHeads[ui_chair].Image_ready:isVisible() then
            break
        end
        local delay = 0
        if i == 1 then
            delay = 0.4
        elseif i == 2 then
            delay = 1.2
        elseif i == 3 then
            delay = 2
        end
        local image_point = self.PlayerHeads[ui_chair].Image_ready:getChildByName("Image_point_" .. i)
        image_point:stopAllActions()
        image_point:setVisible(false)
        local sequence = cc.Sequence:create(cc.DelayTime:create(delay),cc.Show:create(),cc.DelayTime:create(2.4 - delay),cc.Hide:create())
        image_point:runAction(cc.RepeatForever:create(sequence))
    end
    self.PlayerHeads[ui_chair].Image_ready:setVisible(true)
end

-- 某玩家托管或取消托管
function PlayerInfoMediator:autoNotify()
    print("PlayerInfoMediator:autoNotify")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("PlayerInfoProxy"):getData()
    local ui_chair = GameUtils:getInstance():getUIChairByServerChair(data.AutoData.iCID)
    local isAuto = data.AutoData.bAuto
    self.PlayerHeads[ui_chair].Image_auto:setVisible(isAuto)
end

-- 刷新头像 
function PlayerInfoMediator:updateWXHead()
    print("PlayerInfoMediator:updateWXHead")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("DeskProxy"):getData()
    local player = data.player
    dump(player,"player")
    if table.nums(player) >= 1 then
        for k, v in pairs(player) do
            local ui_chair = GameUtils:getInstance():getUIChairByServerChair(k)
            self.PlayerHeads[ui_chair].Image_head_wx:loadTexture(tostring(v.head))
            self.PlayerHeads[ui_chair].Text_nick:setString(tostring(v.name))
            self.PlayerHeads[ui_chair].Panel_player:setVisible(true)
        end
    end
end

-- 显示当前坐下玩家
function PlayerInfoMediator:showCurSitPlayer()
    print("PlayerInfoMediator:showCurSitPlayer")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("PlayerInfoProxy"):getData()
    local player = data.CurSitPlayer
    dump(player,"player")
    if player.iChairID >= 0 and player.iChairID <= 3 then
        local ui_chair = GameUtils:getInstance():getUIChairByServerChair(player.iChairID)
        self.PlayerHeads[ui_chair].Panel_player:setVisible(true)
        self.PlayerHeads[ui_chair].Text_nick:setString(tostring(player.sNickName))
        -- 是否断线
        if player.ePlayerState == 4 then
            self.PlayerHeads[ui_chair].Image_offline:setVisible(true)
        end
    end
end

-- 隐藏离桌玩家
function PlayerInfoMediator:hideCurStandPlayer()
    print("PlayerInfoMediator:hideCurStandPlayer")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("PlayerInfoProxy"):getData()
    local player = data.CurStandPlayer
    dump(player,"player")
    if player.iChairID >= 0 and player.iChairID <= 3 then
        local ui_chair = GameUtils:getInstance():getUIChairByServerChair(player.iChairID)
        self.PlayerHeads[ui_chair].Panel_player:setVisible(false)
        self.PlayerHeads[ui_chair].Image_ready:setVisible(false)
        self.PlayerHeads[ui_chair].Image_offline:setVisible(false)
        for j=1,3 do
            local image_point = self.PlayerHeads[ui_chair].Image_ready:getChildByName("Image_point_" .. j)
            image_point:stopAllActions()
        end
    end

    -- 快速开始模式打完一局有玩家离桌
    if GameUtils:getInstance():getGameType() == 3 then
        for i = 1, 4 do
            self.PlayerHeads[i].Text_score:setString(0)
            for j = 1, 3 do
                local image_point = self.PlayerHeads[i].Image_ready:getChildByName("Image_point_" .. j)
                image_point:stopAllActions()
            end
        end
        if player.iChairID == GameUtils:getInstance():getSelfServerChair() then
            self.PlayerHeads[1].Panel_player:setVisible(true)
            if data.IsPrepare == true then
                gameFacade:sendNotification(MyGameConstants.C_FRE_STARTGAME)
            end
        end
    end
end

-- 有玩家掉线
function PlayerInfoMediator:showCutPlayer()
    print("PlayerInfoMediator:showCutPlayer")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("PlayerInfoProxy"):getData()
    local player = data.CurOfflinePlayer
    dump(player,"player")
    if player.iChairID >= 0 and player.iChairID <= 3 then
        local ui_chair = GameUtils:getInstance():getUIChairByServerChair(player.iChairID)
        self.PlayerHeads[ui_chair].Image_offline:setVisible(true)
    end
end

-- 有玩家重入
function PlayerInfoMediator:showRecomePlayer()
    print("PlayerInfoMediator:showRecomePlayer")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("PlayerInfoProxy"):getData()
    local player = data.CurRecomePlayer
    dump(player,"player")
    if player.iChairID >= 0 and player.iChairID <= 3 then
        local ui_chair = GameUtils:getInstance():getUIChairByServerChair(player.iChairID)
        self.PlayerHeads[ui_chair].Image_offline:setVisible(false)
    end
end

-- 显示坐下玩家
function PlayerInfoMediator:showSitPlayer()
    print("PlayerInfoMediator:showSitPlayer")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("DeskProxy"):getData()
    local player = data.player
    if #player >= 1 then
        for k, v in pairs(player) do
            local ui_chair = GameUtils:getInstance():getUIChairByServerChair(k)
            self.PlayerHeads[ui_chair].Panel_player:setVisible(true)
            self.PlayerHeads[ui_chair].Panel_player:setPosition(PlayingPos[ui_chair])
            self.PlayerHeads[ui_chair].Text_nick:setString(tostring(v.name))
        end
    end
end

-- 刷新分数
function PlayerInfoMediator:updateScore()
    print("PlayerInfoMediator:updateScore")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data =  gameFacade:retrieveProxy("PlayerInfoProxy"):getData()
    local scoreData = data.ScoreData
    if table.nums(scoreData) > 0 then
        for i=0,table.nums(scoreData) - 1 do
            local ui_chair = GameUtils:getInstance():getUIChairByServerChair(i)
            self.PlayerHeads[ui_chair].Text_score:setString(tostring(scoreData[i+1]))
        end
    end
end

-- 定庄
function PlayerInfoMediator:makeNT()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data =  gameFacade:retrieveProxy("PlayerInfoProxy"):getData()
    local MakeNTData = data.MakeNTData
    local curRound = gameFacade:retrieveProxy("DeskInfoProxy"):getData().Round.mj_iNowRound

    if curRound == 1 then
        self:playAnimate()
    else
        local nt_ui_chair = GameUtils:getInstance():getUIChairByServerChair(MakeNTData.nBankerCID)
        self:showNTUser(nt_ui_chair)
    end
end

--播放骰子动画 
function PlayerInfoMediator:playAnimate()
    GameMusic:playOtherEffect(EffectEnum.TOUZ,false)
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local image_root = gameFacade:retrieveMediator("MainMediator").image_root
    local data =  gameFacade:retrieveProxy("PlayerInfoProxy"):getData()
    local MakeNTData = data.MakeNTData

    self.value = {MakeNTData.dice1,MakeNTData.dice2}
    self.shaizi = {}
    self.node = {}
    self.pos = {cc.p(617,359),cc.p(663,403)}

    for i = 1, 2 do
        self.node[i] = cc.CSLoader:createNode("animate/dashai/dashai.csb")
        self.node[i]:setScale(0.7)
        local nt_action = cc.CSLoader:createTimeline("animate/dashai/dashai.csb")
        self.node[i]:runAction(nt_action)
        nt_action:gotoFrameAndPlay(0, false)
        self.node[i]:setPosition(self.pos[i])
        image_root:addChild(self.node[i],MyGameConstants.ORDER_GAME_ANIMATE)
        self.shaizi[i] = self.node[i]:getChildByName("Sprite_shaizi")

        nt_action:setLastFrameCallFunc( function()
            self.shaizi[i]:setTexture("animate/dashai/" .. self.value[i] .. "_1.png")
            performWithDelay(self.root, function()
                self.node[i]:removeFromParent()
            end , 1.5)
        end )
    end

    performWithDelay(self.root, function()
        local nt_ui_chair = GameUtils:getInstance():getUIChairByServerChair(MakeNTData.nBankerCID)
        local pos = self.PlayerHeads[nt_ui_chair].Image_NT:convertToWorldSpace(cc.p(0,0))
        local image_nt = ccui.ImageView:create("ui_res/zhuangjia.png")
        image_nt:setPosition(640,380)
        image_root:addChild(image_nt)

        local moveTo = cc.MoveTo:create(0.15,pos)
        local scaleTo = cc.ScaleTo:create(0.15,0)
        local callBack = cc.CallFunc:create(function()
            local nt_ui_chair = GameUtils:getInstance():getUIChairByServerChair(MakeNTData.nBankerCID)
            self:showNTUser(nt_ui_chair)
            image_nt:removeFromParent()
            image_nt = nil
        end)
        local sequence = cc.Sequence:create(cc.Spawn:create(moveTo,scaleTo),callBack)
        image_nt:runAction(sequence)
    end , 1.35)
end

-- 显示庄家
function PlayerInfoMediator:showNTUser(nt_ui_chair)
    for i = 1,4 do
        self.PlayerHeads[i].Image_NT:setVisible(false)
    end
    self.PlayerHeads[nt_ui_chair].Image_NT:setVisible(true)
end

-- 加漂结果
function PlayerInfoMediator:showPiaoResult()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local image_root = gameFacade:retrieveMediator("MainMediator").image_root
    local data =  gameFacade:retrieveProxy("PlayerInfoProxy"):getData()
    local PiaoData = data.PiaoData
    local ui_chair = GameUtils:getInstance():getUIChairByServerChair(PiaoData.iCID)
    local point = PiaoData.iPiaoPoint

    local path = ""
    if point == 1 or point == 2 then
        self.PlayerHeads[ui_chair].Image_piao:loadTexture("ui_res/piao" .. point .. ".png")
        if point == 1 then
            path = "animate/piao1/piao1.csb"
        else
            path = "animate/piao2/piao2.csb"
        end 
    elseif point == 0 then
        self.PlayerHeads[ui_chair].Image_piao:loadTexture("ui_res/bupiao.png")
        path = "animate/bupiao/bupiao.csb"
    end
    self.PlayerHeads[ui_chair].Image_piao:setVisible(true)

    if path ~= "" then
        local p_node = cc.CSLoader:createNode(path)
        local p_action = cc.CSLoader:createTimeline(path)
        p_node:setScale(0.7)
        p_node:runAction(p_action)
        p_action:gotoFrameAndPlay(0, false)
        p_node:setPosition(self.AnimPos[ui_chair])
        image_root:addChild(p_node,MyGameConstants.ORDER_GAME_ANIMATE)
        p_action:setLastFrameCallFunc( function()
            p_node:removeFromParent()  
            p_node = nil
        end )
    end
end

-- 断线重连
function PlayerInfoMediator:gameStation()
    print("PlayerInfoMediator:gameStation")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("PlayerInfoProxy"):getData()

    local scoreData = nil
    local nt_chair = nil
    local piaoPointData = nil
    local station = data.GameStationData.eMJState
    if station < 15 or station == 24 then
        scoreData = data.GameStationData.vPlayerScores
        nt_chair = data.GameStationData.iZhuangCID
    elseif station == 15 then
        scoreData = data.GameStationData.sPreTile.vPlayerScores
        nt_chair = data.GameStationData.sPreTile.iZhuangCID
        piaoPointData = data.GameStationData.vPiaoPoint
    elseif station >= 16 and station < 24 then
        scoreData = data.GameStationData.sPiaoStat.sPreTile.vPlayerScores
        nt_chair = data.GameStationData.sPiaoStat.sPreTile.iZhuangCID
        piaoPointData = data.GameStationData.sPiaoStat.vPiaoPoint

        local gameType = GameUtils:getInstance():getGameType()
        if gameType ~= 1 and gameType ~= 10 then
            local bAutoTab = data.GameStationData.v_bIsauto
            for i = 0, 3 do
                if bAutoTab[i + 1] == true then
                    local ui_chair = GameUtils:getInstance():getUIChairByServerChair(i)
                    self.PlayerHeads[ui_chair].Image_auto:setVisible(true)
                end
            end
        end
    end

    -- 显示准备状态
    if station == 11 or station == 24 then
        local readyState = data.GameStationData.vBPlayerReady
        for i=1,4 do
            if readyState[i] == true then
                local ui_chair = GameUtils:getInstance():getUIChairByServerChair(i - 1)
                self:agreeAnimate(ui_chair)
            end
        end
    end

    -- 更新庄家
    if nt_chair >= 0 and nt_chair <= 3 then
        local nt_ui_chair = GameUtils:getInstance():getUIChairByServerChair(nt_chair)
        self.PlayerHeads[nt_ui_chair].Image_NT:setVisible(true)
    end

    -- 玩家分数
    if table.nums(scoreData) > 0 then
        for i=0,table.nums(scoreData) - 1 do
            local ui_chair = GameUtils:getInstance():getUIChairByServerChair(i)
            self.PlayerHeads[ui_chair].Text_score:setString(tostring(scoreData[i+1]))
        end
    end

    -- 更新加漂的点数
    if piaoPointData ~= nil and table.nums(piaoPointData) >= 1 then
        for i = 0, 3 do
            local point = piaoPointData[i+1]
            local ui_chair = GameUtils:getInstance():getUIChairByServerChair(i)
            if point == 1 or point == 2 then
                self.PlayerHeads[ui_chair].Image_piao:loadTexture("ui_res/piao" .. point .. ".png")
                self.PlayerHeads[ui_chair].Image_piao:setVisible(true)
            elseif point == 0 then
                self.PlayerHeads[ui_chair].Image_piao:loadTexture("ui_res/bupiao.png")
                self.PlayerHeads[ui_chair].Image_piao:setVisible(true)
            end
        end
    end
end

function PlayerInfoMediator:ui_open()
    self.root:setVisible(true)
end

function PlayerInfoMediator:ui_close()
    self.root:setVisible(false)
end

return PlayerInfoMediator