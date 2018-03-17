
local Mediator = cc.load("puremvc").Mediator
local VideoActMenuMediator = class("VideoActMenuMediator", Mediator)

function VideoActMenuMediator:ctor(root)
    print("-------------->VideoActMenuMediator:ctor")
	VideoActMenuMediator.super.ctor(self, "VideoActMenuMediator")
    self.root = root
end

function VideoActMenuMediator:listNotificationInterests()
    print("-------------->VideoActMenuMediator:listNotificationInterests")
    local GameConstants = cc.exports.GameConstants
	return
    {
        "video_actnotify",
        MyGameConstants.ACT_INFO,
        MyGameConstants.GET_TOKEN,
        MyGameConstants.C_GAME_INIT,
        GameConstants.EXIT_GAME,
    }
end

function VideoActMenuMediator:onRegister()
    print("-------------->VideoActMenuMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")

    -- 玩家的吃碰杠补胡过
	self.Panel_player = {}  
    for i=1,4 do
        local player = self.root:getChildByName("Panel_player_" .. i)
        player:setVisible(false)
        self.Panel_player[i] = player
        self.Panel_player[i].Button_chi = player:getChildByName("Button_chi")
        self.Panel_player[i].Button_peng = player:getChildByName("Button_peng")
        self.Panel_player[i].Button_gang = player:getChildByName("Button_gang")
        self.Panel_player[i].Button_bu = player:getChildByName("Button_bu")
        self.Panel_player[i].Button_hu = player:getChildByName("Button_hu")
        self.Panel_player[i].Button_pass = player:getChildByName("Button_pass")
    end
end

function VideoActMenuMediator:onRemove()
    print("-------------->VideoActMenuMediator:onRemove")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	self:setViewComponent(nil)
end

function VideoActMenuMediator:handleNotification(notification)
    print("-------------->VideoActMenuMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	
    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("VideoActMenuMediator")
    elseif name == "video_actnotify" then
        self:showAction()
    elseif name == MyGameConstants.ACT_INFO or name == MyGameConstants.GET_TOKEN or name == MyGameConstants.C_GAME_INIT then
        self:hideAction()
    end
end
--------------------------------------------------------------------
-- 显示玩家的动作信息
function VideoActMenuMediator:showAction()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("VideoProxy"):getData()
    local ActNotifyData = data.ActNotifyData
    local mj_vActs = ActNotifyData.mj_vActs
    --dump(mj_vActs,"mj_vActs",10)

    local nums = table.nums(mj_vActs) 
    if nums <= 1 then
        return 
    end

    local ui_chair = GameUtils:getInstance():getUIChairByServerChair(mj_vActs[1].iActCID)
    local player = self.Panel_player[ui_chair]
    player:setVisible(true)

    local buttons = {player.Button_chi,player.Button_peng,player.Button_gang,player.Button_bu,player.Button_hu,player.Button_pass}
    local isShow = {false, false,false, false,false,true }
    
    for k,act in pairs(mj_vActs) do
        if act.eAction == 16 then
            isShow[1] = true
        elseif act.eAction == 32 then
            isShow[2] = true
        elseif act.eAction >= MyGameConstants.MJActFlag.DianGang and act.eAction <= MyGameConstants.MJActFlag.BuGang  then
            isShow[3] = true
        elseif act.eAction == MyGameConstants.MJActFlag.Hu then
            isShow[5] = true
        end
    end

    for i,button in pairs(buttons) do
        button:setBright(isShow[i])
    end
end

-- 隐藏动作信息
function  VideoActMenuMediator:hideAction()
    for i=1,4 do
        self.Panel_player[i]:setVisible(false)
    end
end

return VideoActMenuMediator