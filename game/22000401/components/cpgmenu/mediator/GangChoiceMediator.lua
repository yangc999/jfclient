
local Mediator = cc.load("puremvc").Mediator
local GangChoiceMediator = class("GangChoiceMediator", Mediator)

function GangChoiceMediator:ctor()
    print("-------------->GangChoiceMediator:ctor")
	GangChoiceMediator.super.ctor(self, "GangChoiceMediator")
    local MyGameConstants = cc.exports.MyGameConstants	
end

function GangChoiceMediator:listNotificationInterests()
    print("-------------->GangChoiceMediator:listNotificationInterests")
	local GameConstants = cc.exports.GameConstants
	return {
		GameConstants.EXIT_GAME,
	}
end

function GangChoiceMediator:onRegister()
    print("-------------->GangChoiceMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local MyGameConstants = cc.exports.MyGameConstants

    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("CPGMenuProxy"):getData()
    local ActNotifyData = data.ActNotifyData
    local mj_vActs = ActNotifyData.mj_vActs
    
    self.gangSels = {}                 -- 杠的选择数值
    for k, act in pairs(mj_vActs) do
        if act.eAction == MyGameConstants.MJActFlag.AnGang then 
            self.gangSels[#self.gangSels + 1] = act.eActTile
        end
    end
    if #self.gangSels > 3 then
        return false
    end
   
    local image_root = gameFacade:retrieveMediator("MainMediator").image_root
    local csbPath = "ui_csb/GangChoiceLayer.csb"
	local ui = cc.CSLoader:createNode(csbPath)
	self:setViewComponent(ui)
	image_root:addChild(self:getViewComponent(),5)

    local Panel_root = ui:getChildByName("Panel_gang_choices")
    local Panel_gang_2_choices = Panel_root:getChildByName("Panel_gang_2_choices")
    local Panel_gang_3_choices = Panel_root:getChildByName("Panel_gang_3_choices")

    local choicesNum = #self.gangSels  -- 杠的个数
    if choicesNum == 2 then
        Panel_gang_3_choices:setVisible(false)
        self.Panel_gang_choices = Panel_gang_2_choices
    elseif choicesNum == 3 then
        Panel_gang_2_choices:setVisible(false)
        self.Panel_gang_choices = Panel_gang_3_choices
    end

    local Image_bg = self.Panel_gang_choices:getChildByName("Image_bg")
    self.Image_bg = Image_bg

    for i = 1,choicesNum do
        local choice = Image_bg:getChildByName("Panel_gang_choice_" .. i)
        
        for j = 1 , 4 do 
            local card_bg = choice:getChildByName("Image_card_" .. j):getChildByName("Image_card")
            card_bg:addClickEventListener(function()
                self:chooseGang(i)
            end)
            local card = card_bg:getChildByName("Image_value")
            card:loadTexture("ui_res/Mahjong/Big/Big_" .. self.gangSels[i] .. ".png")

        end
    end

    local touch_listener = cc.EventListenerTouchOneByOne:create()
    touch_listener:setSwallowTouches(true) 
    touch_listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = image_root:getEventDispatcher()      
    eventDispatcher:addEventListenerWithSceneGraphPriority(touch_listener, self.Image_bg) 
end

function GangChoiceMediator:onRemove()
    print("-------------->GangChoiceMediator:onRemove")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	self:setViewComponent(nil)
end

function GangChoiceMediator:handleNotification(notification)
    print("-------------->GangChoiceMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	local MyGameConstants = cc.exports.MyGameConstants

    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("GangChoiceMediator")
    end
end

--------------------------------------------------------------------------------------
function GangChoiceMediator:onTouchBegan(touch, event)
    local p = self.Image_bg:convertToNodeSpace(touch:getLocation())
    local  rect = cc.rect(0, 0, self.Image_bg:getContentSize().width, self.Image_bg:getContentSize().height)
    if cc.rectContainsPoint(rect, p) then

    else
        self:getViewComponent():removeFromParent()
        local gameFacade = cc.load("puremvc").Facade.getInstance("game")
        gameFacade:sendNotification("CP_actnotify")
        gameFacade:removeMediator("GangChoiceMediator")
    end
end

-- 选择杠法
function GangChoiceMediator:chooseGang(index)
    print("choose gang " .. index)
    local MyGameConstants = cc.exports.MyGameConstants
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("CPGMenuProxy"):getData()
    local ActNotifyData = data.ActNotifyData
    
    local pak1 = {
        eChosenAction =
        {
            eAction = MyGameConstants.MJActFlag.AnGang,
            eActTile = self.gangSels[index],
            iActCID = GameUtils:getInstance():getSelfServerChair(),
        }
    }
    GameUtils:getInstance():sendNotification(25, pak1, "MJProto::TMJ_actionChoseCPGHG")

    self:getViewComponent():removeFromParent()
	gameFacade:removeMediator("GangChoiceMediator")
end

return GangChoiceMediator