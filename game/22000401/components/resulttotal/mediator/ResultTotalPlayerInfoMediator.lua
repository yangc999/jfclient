
local Mediator = cc.load("puremvc").Mediator
local ResultTotalPlayerInfoMediator = class("ResultTotalPlayerInfoMediator", Mediator)

function ResultTotalPlayerInfoMediator:ctor(root)
    print("-------------->ResultTotalPlayerInfoMediator:ctor")
	ResultTotalPlayerInfoMediator.super.ctor(self, "ResultTotalPlayerInfoMediator",root)
    self.root = root
end

function ResultTotalPlayerInfoMediator:listNotificationInterests()
    print("-------------->ResultTotalPlayerInfoMediator:listNotificationInterests")
	local GameConstants = cc.exports.GameConstants
	return {
		GameConstants.EXIT_GAME,
	}
end

function ResultTotalPlayerInfoMediator:onRegister()
    print("-------------->ResultTotalPlayerInfoMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
   
    self.PlayerInfo = {}
    for i = 1,4 do
        local player = self.root:getChildByName("Panel_playerinfo_" .. i)
        self.PlayerInfo[i] = {}
        if i > MyGameConstants.PLAYER_COUNT then
            playerInfo:setVisible(false)
        else
            -- 微信头像
            self.PlayerInfo[i].Image_Head = player:getChildByName("Image_Head")
            -- 房主
            self.PlayerInfo[i].Image_RoomMaster = self.PlayerInfo[i].Image_Head:getChildByName("Image_RoomMaster")
            self.PlayerInfo[i].Image_RoomMaster:setVisible(false)
            -- 名称
            self.PlayerInfo[i].Text_nick = player:getChildByName("Text_nick")
            -- id
            self.PlayerInfo[i].Text_id = player:getChildByName("Text_id")
            -- 自摸次数
            self.PlayerInfo[i].Text_zm = player:getChildByName("Text_zm")
            -- 点炮次数
            self.PlayerInfo[i].Text_dp = player:getChildByName("Text_dp")
            -- 中鸟次数
            self.PlayerInfo[i].Text_zn = player:getChildByName("Text_zn")
            -- 明杠次数
            self.PlayerInfo[i].Text_mg = player:getChildByName("Text_mg")
            -- 暗杠次数
            self.PlayerInfo[i].Text_ag = player:getChildByName("Text_ag")
            -- 总分
            self.PlayerInfo[i].Text_score = player:getChildByName("Text_score")
            -- 大赢家
            self.PlayerInfo[i].Image_winner = player:getChildByName("Image_winner")
            self.PlayerInfo[i].Image_winner:setVisible(false)
        end
    end

    self:updateTimes()
    self:updateScore()
    self:updateWiners()
    self:updaePlayer()
end

function ResultTotalPlayerInfoMediator:onRemove()
    print("-------------->ResultTotalPlayerInfoMediator:onRemove")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	self:setViewComponent(nil)
end

function ResultTotalPlayerInfoMediator:handleNotification(notification)
    print("-------------->ResultTotalPlayerInfoMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	
    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("ResultTotalPlayerInfoMediator")
    end
end

---------------------------------------------------------------------------

-- 刷新次数
function  ResultTotalPlayerInfoMediator:updateTimes()
    print("ResultTotalPlayerInfoMediator:updateTimes")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("ResultTotalProxy"):getData()
    local TimesData = data.TimesData

    for i,times in pairs(TimesData.zmTimes) do
        self.PlayerInfo[i].Text_zm:setString("自摸次数：" .. tostring(times))
    end

    for i,times in pairs(TimesData.dpTimes) do
        self.PlayerInfo[i].Text_dp:setString("点炮次数：" .. tostring(times))
    end

    for i,times in pairs(TimesData.znTimes) do
        self.PlayerInfo[i].Text_zn:setString("中鸟次数：" .. tostring(times))
    end

    for i,times in pairs(TimesData.mgTimes) do
        self.PlayerInfo[i].Text_mg:setString("明杠次数：" .. tostring(times))
    end

    for i,times in pairs(TimesData.agTimes) do
        self.PlayerInfo[i].Text_ag:setString("暗杠次数：" .. tostring(times))
    end
end

-- 刷新分数
function ResultTotalPlayerInfoMediator:updateScore()
    print("ResultTotalPlayerInfoMediator:updateScore")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("ResultTotalProxy"):getData()
    local ScoreData = data.ScoreData

    for i,score in pairs(ScoreData) do
        self.PlayerInfo[i].Text_score:setString(tostring(score))
    end
end

-- 刷新大赢家
function ResultTotalPlayerInfoMediator:updateWiners()
    print("ResultTotalPlayerInfoMediator:updateWiners")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("ResultTotalProxy"):getData()
    local Winers = data.Winers

    for k,v in pairs(Winers) do
        self.PlayerInfo[v + 1].Image_winner:setVisible(true)
    end
end

-- 刷新玩家信息
function ResultTotalPlayerInfoMediator:updaePlayer()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("DeskProxy"):getData()
    local player = data.player

    local masteriId = 255
    if gameFacade:hasProxy("GameRoomProxy") then
        local gameRoom = gameFacade:retrieveProxy("GameRoomProxy")
        masteriId = gameRoom:getData().masterId
    end
    if table.nums(player) >= 1 then
        for k, v in pairs(player) do
            local ui_chair = GameUtils:getInstance():getUIChairByServerChair(k)
            self.PlayerInfo[k+1].Text_nick:setString(tostring(v.name))
            self.PlayerInfo[k+1].Text_id:setString(tostring(v.uid))
            self.PlayerInfo[k+1].Image_Head:loadTexture(tostring(v.head))
            if masteriId == v.uid then
                self.PlayerInfo[k+1].Image_RoomMaster:setVisible(true)
            end
        end
    end
end

return ResultTotalPlayerInfoMediator