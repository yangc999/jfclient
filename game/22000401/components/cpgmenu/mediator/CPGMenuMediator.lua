local GameMusic = import("....GameMusic")
local Mediator = cc.load("puremvc").Mediator
local CPGMenuMediator = class("CPGMenuMediator", Mediator)

function CPGMenuMediator:ctor(node)
    print("-------------->CPGMenuMediator:ctor")
	CPGMenuMediator.super.ctor(self, "CPGMenuMediator",node)
	self.root = node:getChildByName("Panel_chipeng")

    self.AnimPos = {
        cc.p(640,272),
        cc.p(973,413),
        cc.p(640,554),
        cc.p(304,413),
    }

    self.menuPos = {
        cc.p(240,218), 
        cc.p(400,218), 
        cc.p(560,218),
        cc.p(720,218),
        cc.p(880,218),
        cc.p(1040,218),
    }
end

function CPGMenuMediator:listNotificationInterests()
    print("-------------->CPGMenuMediator:listNotificationInterests")
	local GameConstants = cc.exports.GameConstants
	return {
		"CP_actnotify",
        "CP_actinfo",
        MyGameConstants.C_GAME_INIT,
        MyGameConstants.GET_TOKEN,
        GameConstants.EXIT_GAME,
	}
end

function CPGMenuMediator:onRegister()
    print("-------------->CPGMenuMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local MyGameConstants = cc.exports.MyGameConstants

    gameFacade:registerCommand(MyGameConstants.C_EAT_REQ, cc.exports.CPEatReqCommand)
    gameFacade:registerCommand(MyGameConstants.C_PENG_REQ, cc.exports.CPPengReqCommand)
    gameFacade:registerCommand(MyGameConstants.C_GANG_REQ, cc.exports.CPGangReqCommand)
    gameFacade:registerCommand(MyGameConstants.C_HU_REQ, cc.exports.CPHuReqCommand)
    gameFacade:registerCommand(MyGameConstants.C_PASS_REQ, cc.exports.CPPassReqCommand)

    self.button_c = self.root:getChildByName("Button_c")
    self.button_c:addClickEventListener(function() 
        self:ui_close()
        GameMusic:playClickEffect()
        gameFacade:sendNotification(MyGameConstants.C_EAT_REQ)
    end)
    self.button_p = self.root:getChildByName("Button_p")
    self.button_p:addClickEventListener(function() 
        self:ui_close()
        GameMusic:playClickEffect()
        local gameFacade = cc.load("puremvc").Facade.getInstance("game")
        gameFacade:sendNotification(MyGameConstants.C_PENG_REQ)
    end)
    self.button_g = self.root:getChildByName("Button_g")  
    self.button_g:addClickEventListener(function() 
       self:ui_close()
       GameMusic:playClickEffect()
       gameFacade:sendNotification(MyGameConstants.C_GANG_REQ)
    end)

    self.button_h = self.root:getChildByName("Button_h")
    self.button_h:addClickEventListener(function() 
       self:ui_close()
       GameMusic:playClickEffect()
       gameFacade:sendNotification(MyGameConstants.C_HU_REQ)
    end)

    self.button_pass = self.root:getChildByName("Button_pass")
    self.button_pass:addClickEventListener(function() 
        self:ui_close()
        GameMusic:playClickEffect()
        gameFacade:sendNotification(MyGameConstants.C_PASS_REQ)
    end)

    local h_node = cc.CSLoader:createNode("animate/hu/hu01.csb")
    local h_action = cc.CSLoader:createTimeline("animate/hu/hu01.csb")
    h_node:runAction(h_action)
    h_action:gotoFrameAndPlay(0)
    h_node:setPosition(self.menuPos[4])
    self.root:addChild(h_node)
    self.h_node = h_node

    local g_node = cc.CSLoader:createNode("animate/gang/gang01.csb")
    local g_action = cc.CSLoader:createTimeline("animate/gang/gang01.csb")
    g_node:runAction(g_action)
    g_action:gotoFrameAndPlay(0)
    g_node:setPosition(self.menuPos[3])
    self.root:addChild(g_node)
    self.g_node = g_node

    local p_node = cc.CSLoader:createNode("animate/peng/peng01.csb")
    local p_action = cc.CSLoader:createTimeline("animate/peng/peng01.csb")
    p_node:runAction(p_action)
    p_action:gotoFrameAndPlay(0)
    p_node:setPosition(self.menuPos[2])
    self.root:addChild(p_node)
    self.p_node = p_node

    local c_node = cc.CSLoader:createNode("animate/chl/chl01.csb")
    local c_action = cc.CSLoader:createTimeline("animate/chl/chl01.csb")
    c_node:runAction(c_action)
    c_action:gotoFrameAndPlay(0)
    c_node:setPosition(self.menuPos[1])
    self.root:addChild(c_node)
    self.c_node = c_node 

    self.root:setVisible(false)
end

function CPGMenuMediator:onRemove()
    print("-------------->CPGMenuMediator:onRemove")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	self:setViewComponent(nil)
end

function CPGMenuMediator:handleNotification(notification)
    print("-------------->CPGMenuMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	local MyGameConstants = cc.exports.MyGameConstants

    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("CPGMenuMediator")
        gameFacade:removeProxy("CPGMenuProxy")
    elseif name == MyGameConstants.C_GAME_INIT then
        self:initView()
        self:ui_close()
    elseif name == "CP_actnotify" then
        self:actNotify()
    elseif name == MyGameConstants.GET_TOKEN then
        self:ui_close()
    elseif name == "CP_actinfo" then
        self:ui_close()
        self:actInfo()
    end
end

---------------------------------------------------------------
-- 初始化界面
function CPGMenuMediator:initView()
    self.root:setLocalZOrder(MyGameConstants.ORDER_CHI_PENG_GANG)
end

-- 显示出牌选择界面
function CPGMenuMediator:ui_open()
    self.root:setVisible(true)
end

-- 隐藏出牌选择界面
function CPGMenuMediator:ui_close()
    self.root:setVisible(false)
    self.c_node:setVisible(false)
    self.p_node:setVisible(false)
    self.g_node:setVisible(false)
    self.h_node:setVisible(false)
end

-- 收到可以执行某些动作 
function CPGMenuMediator:actNotify()
    print("CPGMenuMediator:actNotify")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("CPGMenuProxy"):getData()
    local ActNotifyData = data.ActNotifyData
    local mj_vActs = ActNotifyData.mj_vActs
    dump(mj_vActs,"mj_vActs")

--    -- 测试
--    local mj_vActs = {
--        {eAction = 32},
--        {eAction = 48},
--        {eAction = 64},
--    }
    
    local nums = table.nums(mj_vActs) 
    if nums <= 1 then
        return 
    end

    local buttons = { self.button_pass, self.button_c, self.button_p, self.button_g, self.button_h }
    local nodes = { self.button_pass, self.c_node, self.p_node, self.g_node, self.h_node }
    local isShow = { true, false, false,false, false }
    
    for k,act in pairs(mj_vActs) do
        if act.eAction == 16 then
            isShow[2] = true
        elseif act.eAction == 32 then
            isShow[3] = true
        elseif act.eAction >= MyGameConstants.MJActFlag.DianGang and act.eAction <= MyGameConstants.MJActFlag.BuGang  then
            isShow[4] = true
        elseif act.eAction == MyGameConstants.MJActFlag.Hu then
            isShow[5] = true
        end
    end
    dump(isShow,"isShow")
    self.button_pass:setVisible(true)
    local index = 4
    local show_index = 6
    for i = 1, 5 do
        if isShow[i] then
            buttons[i]:setPosition(self.menuPos[show_index])
            nodes[i]:setPosition(self.menuPos[show_index])
            show_index = show_index - 1
        end
        buttons[i]:setVisible(isShow[i])
        nodes[i]:setVisible(isShow[i])
    end
            
    self:ui_open()
end

-- 某玩家执行某个动作
function CPGMenuMediator:actInfo()
    print("CPGMenuMediator:actInfo start")
    local MyGameConstants = cc.exports.MyGameConstants
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("CPGMenuProxy"):getData()
    local ActInfoData = data.ActInfoData
    local sAct = ActInfoData.sAct
    
    local actFlag = sAct.eAction
    local ui_chair = GameUtils:getInstance():getUIChairByServerChair(sAct.iActCID)
    local image_root = gameFacade:retrieveMediator("MainMediator").image_root

    if actFlag ==  MyGameConstants.MJActFlag.Chi then     
        local c_node = cc.CSLoader:createNode("animate/chl/chl.csb")
        local c_action = cc.CSLoader:createTimeline("animate/chl/chl.csb")
        c_node:runAction(c_action)
        c_action:gotoFrameAndPlay(0)
        c_node:setPosition(self.AnimPos[ui_chair])
        image_root:addChild(c_node,MyGameConstants.ORDER_GAME_ANIMATE)

        c_action:setLastFrameCallFunc( function()
            c_node:removeFromParent()
            c_node = nil
        end)

    elseif actFlag ==  MyGameConstants.MJActFlag.Peng then
        local p_node = cc.CSLoader:createNode("animate/peng/peng.csb")
        local p_action = cc.CSLoader:createTimeline("animate/peng/peng.csb")
        p_node:runAction(p_action)
        p_action:gotoFrameAndPlay(0,false)
        p_node:setPosition(self.AnimPos[ui_chair])
        image_root:addChild(p_node,MyGameConstants.ORDER_GAME_ANIMATE)
        p_action:setLastFrameCallFunc( function()
            p_node:removeFromParent()
            p_node = nil
        end)
    elseif actFlag >= MyGameConstants.MJActFlag.DianGang and actFlag <= MyGameConstants.MJActFlag.BuGang then
        local g_node = cc.CSLoader:createNode("animate/gang/gang.csb")
        local g_action = cc.CSLoader:createTimeline("animate/gang/gang.csb")
        g_node:runAction(g_action)
        g_action:gotoFrameAndPlay(0)
        g_node:setPosition(self.AnimPos[ui_chair])
        image_root:addChild(g_node,MyGameConstants.ORDER_GAME_ANIMATE)
        g_action:setLastFrameCallFunc( function()
            g_node:removeFromParent()
            g_node = nil
        end)
    elseif actFlag ==  MyGameConstants.MJActFlag.Hu then
        local h_node = nil
        local h_action = nil
        if false then
            h_node = cc.CSLoader:createNode("animate/zimo/zimo.csb")
            h_action = cc.CSLoader:createTimeline("animate/zimo/zimo.csb")
        else
            h_node = cc.CSLoader:createNode("animate/hu/hu.csb")
            h_action = cc.CSLoader:createTimeline("animate/hu/hu.csb")
        end
        h_node:runAction(h_action)
        h_action:gotoFrameAndPlay(0)
        h_node:setPosition(self.AnimPos[ui_chair])
        image_root:addChild(h_node,MyGameConstants.ORDER_GAME_ANIMATE)
        h_action:setLastFrameCallFunc( function()
            h_node:removeFromParent()
            h_node = nil
        end )
    end
    GameMusic:PlayActEffect(actFlag,sAct.iActCID)
    print("CPGMenuMediator:actInfo end")
end

return CPGMenuMediator