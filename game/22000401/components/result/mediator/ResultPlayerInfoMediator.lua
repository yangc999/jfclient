
local Mediator = cc.load("puremvc").Mediator
local ResultPlayerInfoMediator = class("ResultPlayerInfoMediator", Mediator)

function ResultPlayerInfoMediator:ctor(root)
    print("-------------->ResultPlayerInfoMediator:ctor")
	ResultPlayerInfoMediator.super.ctor(self, "ResultPlayerInfoMediator",root)
    self.root = root
end

function ResultPlayerInfoMediator:listNotificationInterests()
    print("-------------->ResultPlayerInfoMediator:listNotificationInterests")
	local MyGameConstants = cc.exports.MyGameConstants
	return {
		"RE_updatescore",
        GameConstants.EXIT_GAME,
        MyGameConstants.C_CLOSE_RESULT,
	}
end

function ResultPlayerInfoMediator:onRegister()
    print("-------------->ResultPlayerInfoMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
   
    self.PlayerInfo = {}
    for i = 1,4 do
        local player = self.root:getChildByName("playerinfo_" .. i)
        self.PlayerInfo[i] = {}
        if i > MyGameConstants.PLAYER_COUNT then
            playerInfo:setVisible(false)
        else
            -- 微信头像
            self.PlayerInfo[i].Image_Head = player:getChildByName("Image_Head")
            -- 庄家
            self.PlayerInfo[i].Image_nt = self.PlayerInfo[i].Image_Head:getChildByName("Image_nt")
            self.PlayerInfo[i].Image_nt:setVisible(false)
            -- 名称
            self.PlayerInfo[i].Text_nick = player:getChildByName("Text_nick")
            -- id
            self.PlayerInfo[i].Text_id = player:getChildByName("Text_id")
            -- 胡分
            self.PlayerInfo[i].Text_hu_score = player:getChildByName("Text_hu_score")
            -- 杠分
            self.PlayerInfo[i].Text_gang_score = player:getChildByName("Text_gang_score")
            -- 鸟分
            self.PlayerInfo[i].Text_niao_score = player:getChildByName("Text_niao_score")
            -- 飘分
            self.PlayerInfo[i].Text_piao_score = player:getChildByName("Text_piao_score")
            -- 总分
            self.PlayerInfo[i].Text_all_score = player:getChildByName("Text_all_score")
        end
    end
    self:updaePlayer()
end

function ResultPlayerInfoMediator:onRemove()
    print("-------------->ResultMediator:onRemove")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	self:setViewComponent(nil)
end

function ResultPlayerInfoMediator:handleNotification(notification)
    print("-------------->ResultPlayerInfoMediator:handleNotification")	
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local MyGameConstants = cc.exports.MyGameConstants
	
    if name == GameConstants.EXIT_GAME or name == MyGameConstants.C_CLOSE_RESULT then
        gameFacade:removeMediator("ResultPlayerInfoMediator")
    elseif name == "RE_updatescore" then
        self:updateScore()
    end

end

---------------------------------------------------------------------------

-- 刷新分数
function  ResultPlayerInfoMediator:updateScore()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("ResultProxy"):getData()
    local ScoreData = data.ScoreData
    dump(ScoreData,"ScoreData")

    for i,score in pairs(ScoreData.HuScore) do
        self.PlayerInfo[i].Text_hu_score:setString("胡分：" .. tostring(score))
    end

    for i,score in pairs(ScoreData.GangScore) do
        self.PlayerInfo[i].Text_gang_score:setString("杠分：" .. tostring(score))
    end

    for i,score in pairs(ScoreData.NiaoScore) do
        self.PlayerInfo[i].Text_niao_score:setString("鸟分：" .. tostring(score))
    end

    for i,score in pairs(ScoreData.PiaoScore) do
        self.PlayerInfo[i].Text_piao_score:setString("飘分：" .. tostring(score))
    end

    for i,score in pairs(ScoreData.AllScore) do
        self.PlayerInfo[i].Text_all_score:setString(tostring(score))
    end

end

-- 刷新玩家信息
function ResultPlayerInfoMediator:updaePlayer()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    if GameUtils:getInstance():getGameType() == 10 then
        local data = gameFacade:retrieveProxy("PlayerInfoProxy"):getData()
        local player = data.AllUserInfo
        print(GameUtils:getInstance():getSelfServerChair())
        --dump(userInfo,"userInfo")
        local nt_server_chair = GameUtils:getInstance():getNTServerChair()
        if table.nums(player) >= 1 then
            for k, v in pairs(player) do
                self.PlayerInfo[k].Text_nick:setString(tostring(v.sNick))
                self.PlayerInfo[k].Text_id:setString(tostring(v.iPlayerID))
                --self.PlayerInfo[k].Image_Head:loadTexture(tostring(v.head))
                if nt_server_chair == k - 1 then
                    self.PlayerInfo[k].Image_nt:setVisible(true)
                end
            end
        end
    else
        local data = gameFacade:retrieveProxy("DeskProxy"):getData()
        local player = data.player
        local nt_server_chair = GameUtils:getInstance():getNTServerChair()
        if table.nums(player) >= 1 then
            for k, v in pairs(player) do
                self.PlayerInfo[k + 1].Text_nick:setString(tostring(v.name))
                self.PlayerInfo[k + 1].Text_id:setString(tostring(v.uid))
                self.PlayerInfo[k + 1].Image_Head:loadTexture(tostring(v.head))
                if nt_server_chair == k then
                    self.PlayerInfo[k + 1].Image_nt:setVisible(true)
                end
            end
        end
    end
end


return ResultPlayerInfoMediator