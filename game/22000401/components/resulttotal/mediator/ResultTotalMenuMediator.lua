local GameMusic = import("....GameMusic")
local Mediator = cc.load("puremvc").Mediator
local ResultTotalMenuMediator = class("ResultTotalMenuMediator", Mediator)

function ResultTotalMenuMediator:ctor(root)
    print("-------------->ResultTotalMenuMediator:ctor")
	ResultTotalMenuMediator.super.ctor(self, "ResultTotalMenuMediator",root)
    self.root = root
end

function ResultTotalMenuMediator:listNotificationInterests()
    print("-------------->ResultTotalMenuMediator:listNotificationInterests")
	local GameConstants = cc.exports.GameConstants
	return {
        GameConstants.EXIT_GAME,
	}
end

function ResultTotalMenuMediator:onRegister()
    print("-------------->ResultTotalMenuMediator:onRegister")
    -- 返回
    local GameConstants = cc.exports.GameConstants
    local button_back = self.root:getChildByName("Button_back")
    button_back:addClickEventListener(function() 
        GameMusic:playClickEffect()
        self:stopCountDown()
        local gameFacade = cc.load("puremvc").Facade.getInstance("game")
        gameFacade:removeMediator("ResultTotalMediator")
        gameFacade:sendNotification(GameConstants.EXIT_GAME)
    end)

    -- 分享
    local button_share = self.root:getChildByName("Button_share")
    button_share:addClickEventListener(function() 
        GameMusic:playClickEffect()
    end)
    
    -- 时间
    self.Text_time = self.root:getChildByName("Text_time")
    -- 日期
    self.Text_date = self.root:getChildByName("Text_date")
    -- 房号
    self.Text_roomnum = self.root:getChildByName("Text_roomnum")

    self:updateDate()
    self:updateRoomNums()
    self:startCountDown()
end

function ResultTotalMenuMediator:onRemove()
    print("-------------->ResultTotalMenuMediator:onRemove")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    self:stopCountDown()
	self:setViewComponent(nil)
end

function ResultTotalMenuMediator:handleNotification(notification)
    print("-------------->ResultTotalMenuMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	
    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("ResultTotalMenuMediator")
    end
end

---------------------------------------------------------------------------
-- 开始倒计时
function ResultTotalMenuMediator:startCountDown()
    print("ResultTotalMenuMediator:startCountDown")
    self:update()
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc( handler(self , self.update ) , 1.0 ,false)
end

-- 停止倒计时
function ResultTotalMenuMediator:stopCountDown()
    if self.schedulerID ~= nil then    
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry( self.schedulerID )
        self.schedulerID = nil
    end
end


function ResultTotalMenuMediator:update()
    if self.Text_time ~= nil then
        self.Text_time:setString(tostring(os.date("%H:%M", os.time())))
    end
end

function ResultTotalMenuMediator:updateDate()
    print("ResultTotalMenuMediator:updateDate")
    self.Text_date:setString(tostring(os.date("%Y-%m-%d", os.time())))
end

-- 更新房号
function  ResultTotalMenuMediator:updateRoomNums()
    print("ResultTotalMenuMediator:updateRoomNums")
    local roomKey = GameUtils:getInstance():getGameRoomKey()
    if roomKey ~= nil then
        self.Text_roomnum:setString("房号：" .. tostring(roomKey))
    else
        self.Text_roomnum:setVisible(false)
    end
end


return ResultTotalMenuMediator