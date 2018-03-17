local GameMusic = import("....GameMusic")
local Mediator = cc.load("puremvc").Mediator
local MainMediator = class("MainMediator", Mediator)
local GameLogic = import("....GameLogic")
function MainMediator:ctor(scene)
    print("------------>MainMediator:ctor")
	MainMediator.super.ctor(self, "MainMediator",scene)
	self.scene = scene
end

function MainMediator:listNotificationInterests()
    print("------------>MainMediator:listNotificationInterests")
	local GameConstants = cc.exports.GameConstants
	return {
        GameConstants.EXIT_GAME,
        MyGameConstants.C_UPDATE_TABLECLOTH
	}
end

function MainMediator:onRegister()
    print("------------>MainMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    local MyGameConstants = cc.exports.MyGameConstants

    gameFacade:registerCommand(MyGameConstants.ROUND_FINISH, cc.exports.ResultCommand)
    gameFacade:registerCommand(MyGameConstants.PAIJU_INFO, cc.exports.ResultTotalCommand)

    gameFacade:registerCommand(GameConstants.PENETRATE_MSG,cc.exports.RecvMsgCommand)
    gameFacade:registerCommand(MyGameConstants.C_PREPARE_REQ, cc.exports.RequestPrepareCommand)
    gameFacade:registerCommand(MyGameConstants.C_SHOW_TINGCARDS, cc.exports.CheckTingCommand)
    gameFacade:registerCommand(MyGameConstants.C_SHOW_CURSAME_CARD, cc.exports.StartCurSameCardCommand)
    gameFacade:registerCommand(MyGameConstants.MAKE_NT, cc.exports.StartMakeNTCommand)
    gameFacade:registerCommand(MyGameConstants.AUTO_INFO, cc.exports.StartAutoInfoCommand)
    gameFacade:registerCommand(MyGameConstants.OUTCARD_INFO, cc.exports.StartOutCardCommand)
    gameFacade:registerCommand(MyGameConstants.GET_TOKEN, cc.exports.StartGetTokenCommand)
    gameFacade:registerCommand(MyGameConstants.ACT_NOTIFY, cc.exports.StartActNotifyCommand)
    gameFacade:registerCommand(MyGameConstants.ACT_INFO, cc.exports.StartActInfoCommand)
    gameFacade:registerCommand(MyGameConstants.GAME_STATION, cc.exports.StartGameStationCommand)

    gameFacade:registerCommand("start_outcard", cc.exports.OutCardCommand)
    gameFacade:registerCommand("start_handcard", cc.exports.HandCardCommand)
    gameFacade:registerCommand("start_chipeng", cc.exports.CPGMenuCommand)
    gameFacade:registerCommand("start_playerinfo", cc.exports.PlayerInfoCommand)
    gameFacade:registerCommand("start_deskinfo", cc.exports.DeskInfoCommand)
    gameFacade:registerCommand("start_loading", cc.exports.LoadingCommand)
    gameFacade:registerCommand("start_menu", cc.exports.MenuCommand)
    gameFacade:registerCommand("start_video", cc.exports.VideoCommand)
    
    local startTime = os.clock()
    print(tostring(startTime))

    print("load MJBaseLayer csb")
	local csbPath = "ui_csb/MJBaseLayer.csb"
	local ui = cc.CSLoader:createNode(csbPath)
    local image_root = ui:getChildByName("Image_root")
    self.image_root = image_root
	self:setViewComponent(ui)
	self.scene:addChild(self:getViewComponent())

    -- 桌子信息
    print("init Panel_desk")
    local Panel_desk = image_root:getChildByName("Panel_desk")
    Panel_desk:setLocalZOrder(MyGameConstants.ORDER_DESK_INFO)
	gameFacade:sendNotification("start_deskinfo",Panel_desk)

    -- 玩家信息
    print("load PlayerHeadLayer csb")
    local csbPath1 = "ui_csb/PlayerHeadLayer.csb"
	local node = cc.CSLoader:createNode(csbPath1)
    node:setPosition(0,0)
    image_root:addChild(node)
    node:setLocalZOrder(MyGameConstants.ORDER_PLAYER_INFO)
	gameFacade:sendNotification("start_playerinfo",node)
    
    if GameUtils:getInstance():getGameType() == 10 then
        -- 录像
        print("load GameVideoLayer csb")
        local csbPath = "ui_csb/GameVideoLayer.csb"
        local Panel_video = cc.CSLoader:createNode(csbPath)
        Panel_video:setPosition(0, 0)
        --image_root:addChild(Panel_video)
        self.scene:addChild(Panel_video,1)
        Panel_video:setLocalZOrder(MyGameConstants.ORDER_GAME_VIDEO)
        gameFacade:sendNotification("start_video", Panel_video)
    else
        -- 菜单层录像中不显示
        print("load MenuLayerNode csb")
        local csbPath2 = "ui_csb/MenuLayerNode.csb"
        local Panel_menu = cc.CSLoader:createNode(csbPath2)
        Panel_menu:setPosition(0, 0)
        image_root:addChild(Panel_menu)
        Panel_menu:setLocalZOrder(MyGameConstants.ORDER_MENU)
        gameFacade:sendNotification("start_menu", Panel_menu)
    end

    -- 吃碰杠按钮
    print("load ChiPengLayer csb")
    local csbPath5 = "ui_csb/ChiPengLayer.csb"
    local cp_node = cc.CSLoader:createNode(csbPath5)
    cp_node:setPosition(0, 0)
    image_root:addChild(cp_node)
    cp_node:setLocalZOrder(MyGameConstants.ORDER_CHI_PENG_GANG)
    gameFacade:sendNotification("start_chipeng", cp_node)

    -- 出的牌
    print("load OutCardsLayerNode csb")
    local csbPath3 = "ui_csb/OutCardsLayerNode.csb"
	local Panel_mj_outCard = cc.CSLoader:createNode(csbPath3)
    Panel_mj_outCard:setPosition(0,0)
    image_root:addChild(Panel_mj_outCard)
    Panel_mj_outCard:setLocalZOrder(MyGameConstants.ORDER_OUT_CARD)
	gameFacade:sendNotification("start_outcard",Panel_mj_outCard)

    -- 手牌
    print("load HandCardsLayerNode csb")
    local csbPath4 = "ui_csb/HandCardsLayerNode.csb"
	local Panel_mj_handCard = cc.CSLoader:createNode(csbPath4)
    Panel_mj_handCard:setPosition(0,0)
    image_root:addChild(Panel_mj_handCard)
    Panel_mj_handCard:setLocalZOrder(MyGameConstants.ORDER_HAND_CARD)
	gameFacade:sendNotification("start_handcard",Panel_mj_handCard)

    gameFacade:sendNotification("start_loading")

    -- 游戏初始化
    gameFacade:sendNotification(MyGameConstants.C_GAME_INIT)

    -- 设置音量大小
    local musicVolume = GameUtils:getInstance():getMJMusicValue()
    AudioEngine.setMusicVolume(musicVolume / 100)
    local effectsVolume = GameUtils:getInstance():getMJEffectValue()
    AudioEngine.setEffectsVolume(effectsVolume / 100)
    -- 播放背景音乐
    GameMusic:playBGM()
    -- 刷新桌布
    self:updateTableCloth()

    local endTime = os.clock()
    print(tostring(endTime))
    print("loading time = " .. tostring(endTime - startTime))

--    local video = cc.FileUtils:getInstance():getDataFromFile("videodata")
--    print(type(video))
--    print(string.len(video))
--    print(tostring(video))

    -- 胡牌算法测试
--    local sTime = os.clock()
--    local tab = {1,3,7,11,15,18,19,21,24,26}
--    for i=1,34 do
--        print("-------> is check hu = " .. tostring(GameLogic:check_3x_2(tab,4)))
--    end
--    local eTime = os.clock()
--    print("need time = " .. tostring(eTime - sTime))

    -- 测试结算界面
    --gameFacade:registerCommand(MyGameConstants.ROUND_FINISH, cc.exports.ResultCommand)
    --gameFacade:sendNotification(MyGameConstants.ROUND_FINISH)

    --测试总结算界面
    --gameFacade:registerCommand(MyGameConstants.PAIJU_INFO, cc.exports.ResultTotalCommand)
    --gameFacade:sendNotification(MyGameConstants.PAIJU_INFO)
end

function MainMediator:onRemove()
    print("------------>MainMediator:onRemove")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local MyGameConstants = cc.exports.MyGameConstants

	gameFacade:removeCommand(MyGameConstants.AGREE_GAME)
    gameFacade:removeCommand(MyGameConstants.START_GAME)
    gameFacade:removeCommand(MyGameConstants.AUTO_INFO)
    gameFacade:removeCommand(MyGameConstants.PIAO_NOTIFY)
    gameFacade:removeCommand(MyGameConstants.PIAO_RESP)
    gameFacade:removeCommand(MyGameConstants.MAKE_NT)
    gameFacade:removeCommand(MyGameConstants.FETCH_HANDCARDS)
    gameFacade:removeCommand(MyGameConstants.FETCH_VIDEO_HANDCARDS)
    gameFacade:removeCommand(MyGameConstants.GET_TOKEN)
    gameFacade:removeCommand(MyGameConstants.OUTCARD_INFO)
    gameFacade:removeCommand(MyGameConstants.ACT_NOTIFY)
    gameFacade:removeCommand(MyGameConstants.ACT_REQ)
    gameFacade:removeCommand(MyGameConstants.ACT_INFO)
    gameFacade:removeCommand(MyGameConstants.NIAO_CARD)
    gameFacade:removeCommand(MyGameConstants.ROUND_FINISH)
    gameFacade:removeCommand(MyGameConstants.PAIJU_INFO)
    gameFacade:removeCommand(MyGameConstants.TEST_GAME)
    gameFacade:removeCommand(MyGameConstants.PLAYER_SIT)
    gameFacade:removeCommand(MyGameConstants.PLAYER_STAND)
    gameFacade:removeCommand(MyGameConstants.PLAYER_OFFLINE)
    gameFacade:removeCommand(MyGameConstants.PLAYER_RECOME)
    gameFacade:removeCommand(MyGameConstants.GAME_STATION)
    gameFacade:removeCommand(MyGameConstants.GAME_TEST)

    gameFacade:removeCommand(MyGameConstants.C_SHOW_CURSAME_CARD)
    gameFacade:removeCommand(MyGameConstants.C_PREPARE_REQ)
    gameFacade:removeCommand(MyGameConstants.C_OUTCARD_REQ)
    gameFacade:removeCommand(MyGameConstants.C_PIAO_REQ)
    gameFacade:removeCommand(MyGameConstants.C_AUTO)
    gameFacade:removeCommand(MyGameConstants.C_EAT_REQ)
    gameFacade:removeCommand(MyGameConstants.C_PENG_REQ)
    gameFacade:removeCommand(MyGameConstants.C_GANG_REQ)
    gameFacade:removeCommand(MyGameConstants.C_HU_REQ)
    gameFacade:removeCommand(MyGameConstants.C_PASS_REQ)
    gameFacade:removeCommand(MyGameConstants.C_RULES_OPEN)
    gameFacade:removeCommand(MyGameConstants.C_MATCHCARD_OPEN)
    gameFacade:removeCommand(MyGameConstants.C_HELP_OPEN)
    gameFacade:removeCommand(MyGameConstants.C_SET_OPEN)
    gameFacade:removeCommand(MyGameConstants.C_GAME_INIT)
    gameFacade:removeCommand(MyGameConstants.C_SHOW_RESULTTOTAL)
    gameFacade:removeCommand(MyGameConstants.C_HANDCARD_INITPOS)
    gameFacade:removeCommand(MyGameConstants.C_UPDATE_TABLECLOTH)
    gameFacade:removeCommand(MyGameConstants.C_UPDATE_CARDBACK)
    gameFacade:removeCommand(MyGameConstants.C_SHOW_TINGCARDS)

    gameFacade:removeCommand("start_outcard")
    gameFacade:removeCommand("start_handcard")
    gameFacade:removeCommand("start_chipeng")
    gameFacade:removeCommand("start_playerinfo")
    gameFacade:removeCommand("start_deskinfo")
    gameFacade:removeCommand("start_loading")
    gameFacade:removeCommand("start_menu")
    gameFacade:removeCommand("start_video")

    GameUtils:getInstance():onDestroy()
    AudioEngine.stopAllEffects()
    AudioEngine.stopMusic()
	self:getViewComponent():removeFromParent()
    
    for k,v in pairs(package.loaded) do
        local findIndex = string.find(k,tostring(MyGameConstants.GAME_ID))
        if findIndex ~= nil then
            package.loaded[k]=nil
        end
    end

    MyGameConstants = nil
	self:setViewComponent(nil)
end

function MainMediator:handleNotification(notification)
    print("------------>MainMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	
    if name == GameConstants.EXIT_GAME then
		gameFacade:removeMediator("MainMediator")
        gameFacade:removeProxy("MainProxy")
    elseif name == MyGameConstants.C_UPDATE_TABLECLOTH then
        self:updateTableCloth()
    end
end
---------------------------------------------------
-- 更新桌布
function MainMediator:updateTableCloth()
    local colorType = GameUtils:getInstance():getMJTableCloth()
    if colorType >= 1 and colorType <= 3 then
        self.image_root:loadTexture(MyGameConstants.COLOR_RES_PATH[colorType] .. "BJ.png")
    end
end

return MainMediator