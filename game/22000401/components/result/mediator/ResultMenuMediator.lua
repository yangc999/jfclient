local GameMusic = import("....GameMusic")
local Mediator = cc.load("puremvc").Mediator
local ResultMenuMediator = class("ResultMenuMediator", Mediator)

function ResultMenuMediator:ctor(root)
    print("-------------->ResultMenuMediator:ctor")
	ResultMenuMediator.super.ctor(self, "ResultMenuMediator",root)
    self.root = root
end

function ResultMenuMediator:listNotificationInterests()
    print("-------------->ResultMenuMediator:listNotificationInterests")
	local MyGameConstants = cc.exports.MyGameConstants
	return {
		"RE_updateround",
        "RE_updatebutton",
        GameConstants.EXIT_GAME,
        MyGameConstants.C_CLOSE_RESULT,
	}
end

function ResultMenuMediator:onRegister()
    print("-------------->ResultMenuMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    local MyGameConstants = cc.exports.MyGameConstants

    gameFacade:registerCommand(MyGameConstants.C_SHOW_RESULTTOTAL,cc.exports.ShowResultTotalCommand)
    
    -- 返回
    local button_back = self.root:getChildByName("Button_back")
    button_back:setVisible(false)
    button_back:addClickEventListener(function() 
        GameMusic:playClickEffect()
        gameFacade:sendNotification(MyGameConstants.C_CLOSE_RESULT)
        if GameUtils:getInstance():getGameType() == 2 then
            gameFacade:sendNotification(GameConstants.REQUEST_FRELEAVE)
        elseif GameUtils:getInstance():getGameType() == 3 then  
            gameFacade:sendNotification(GameConstants.REQUEST_QUKLEAVE)
        end
        gameFacade:sendNotification(GameConstants.EXIT_GAME)
    end)

    -- 分享
    local button_share = self.root:getChildByName("Button_share")
    button_share:addClickEventListener( function()
        GameMusic:playClickEffect()
        cc.utils:captureScreen( function(succeed, outputFile)
            if succeed then
                local strScene = "0"  -- 0 分享到好友   1 分享到朋友圈
                local ShareFriendUrl = "http://share.game4588.com"  --好友分享网址
                local imageName = cc.FileUtils:getInstance():getWritablePath() .. "game_share.png"
                local strImgPath = cc.FileUtils:getInstance():fullPathForFilename(imageName)
                cc.exports.wxShareFriends(ShareFriendUrl, "", "", strImgPath, strScene)
            end
        end ,
        "game_share.png")
    end )

    -- 继续游戏
    local button_continue = self.root:getChildByName("Button_continue")
    self.button_continue = button_continue
    --button_continue:setPositionX(740)
    button_continue:addClickEventListener( function()
        GameMusic:playClickEffect()
        gameFacade:sendNotification(MyGameConstants.C_GAME_INIT)
        self:stopCountDown()
        button_continue:setVisible(false)
        local player = gameFacade:retrieveProxy("PlayerInfoProxy"):getData() 
        if player.BFreUserleave == true then
            gameFacade:sendNotification(MyGameConstants.C_FRE_STARTGAME)
        else
            gameFacade:sendNotification(MyGameConstants.C_PREPARE_REQ)
        end
        gameFacade:sendNotification(MyGameConstants.C_CLOSE_RESULT)
    end )

    -- 换桌
    local button_changedesk = self.root:getChildByName("Button_changedesk")
    button_changedesk:setVisible(false)
    button_changedesk:addClickEventListener(function() 
        
    end)

    -- 查看牌局
    local Button_pj = self.root:getChildByName("Button_pj")
    self.Button_pj = Button_pj
    Button_pj:setVisible(false)
    --Button_pj:setPositionX(740)
    Button_pj:addClickEventListener(function() 
        GameMusic:playClickEffect()
        self:stopCountDown()
        gameFacade:sendNotification(MyGameConstants.C_CLOSE_RESULT)
        gameFacade:sendNotification(MyGameConstants.C_SHOW_RESULTTOTAL)
    end)

    -- 时间
    self.Text_time = self.root:getChildByName("Text_time")
    -- 日期
    self.Text_date = self.root:getChildByName("Text_date")
    -- 房号
    self.Text_roomnum = self.root:getChildByName("Text_roomnum")
    -- 桌号
    local Text_desknum = self.root:getChildByName("Text_desknum")
    Text_desknum:setVisible(false)
    -- 局数
    self.Text_round = self.root:getChildByName("Text_round")

    if GameUtils:getInstance():getGameType() ~= 1 then
        --button_share:setVisible(false)
        Button_pj:setVisible(false)
        button_back:setVisible(true)
    end

    -- 录像里隐藏按钮
    if GameUtils:getInstance():getGameType() == 10 then
        button_back:setVisible(false)
        button_share:setVisible(false)
        button_continue:setVisible(false)
    end

    self:updateDate()
    self:updateRoomNums()
    self:startCountDown()
end

function ResultMenuMediator:onRemove()
    print("-------------->ResultMenuMediator:onRemove")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    self:stopCountDown()
	self:setViewComponent(nil)
end

function ResultMenuMediator:handleNotification(notification)
    print("-------------->ResultMenuMediator:handleNotification")	
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local MyGameConstants = cc.exports.MyGameConstants
	
    if name == GameConstants.EXIT_GAME or name == MyGameConstants.C_CLOSE_RESULT then
        gameFacade:removeMediator("ResultMenuMediator")
    elseif name == "RE_updateround" then
        self:updateRound()
    elseif name == "RE_updatebutton" then
        self:showButtonPJ()
    end
end

---------------------------------------------------------------------------
function ResultMenuMediator:startCountDown()
    self:update()
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc( handler(self , self.update ) , 1.0 ,false)
end

function ResultMenuMediator:stopCountDown()
    if self.schedulerID ~= nil then    
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry( self.schedulerID )
        self.schedulerID = nil
    end
end

function ResultMenuMediator:update()
    if self.Text_time ~= nil then
        self.Text_time:setString(tostring(os.date("%H:%M", os.time())))
    end
end

function ResultMenuMediator:updateDate()
    self.Text_date:setString(tostring(os.date("%Y-%m-%d", os.time())))
end

-- 显示查看牌局按钮
function ResultMenuMediator:showButtonPJ()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("ResultProxy"):getData()
    local bFinished = data.bFinished
    if bFinished == true and GameUtils:getInstance():getGameType() == 1 then
        self.button_continue:setVisible(false)
        self.Button_pj:setVisible(true)
    end
end

-- 更新局数
function ResultMenuMediator:updateRound()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("ResultProxy"):getData()
    local iNowRound = data.Round.iNowRound
    local iAllRound = data.Round.iAllRound
    self.Text_round:setString("局数：" .. tostring(iNowRound))
end

-- 更新房号
function  ResultMenuMediator:updateRoomNums()
    local roomKey = GameUtils:getInstance():getGameRoomKey()
    if roomKey ~= nil then
        self.Text_roomnum:setString("房号：" .. tostring(roomKey))
    else
        self.Text_roomnum:setVisible(false)
    end
end


return ResultMenuMediator