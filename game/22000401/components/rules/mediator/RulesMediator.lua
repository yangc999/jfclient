local GameMusic = import("....GameMusic")
local Mediator = cc.load("puremvc").Mediator
local RulesMediator = class("RulesMediator", Mediator)

function RulesMediator:ctor()
    print("-------------->RulesMediator:ctor")
	RulesMediator.super.ctor(self, "RulesMediator")
end

function RulesMediator:listNotificationInterests()
    print("-------------->RulesMediator:listNotificationInterests")
	return
    {
        GameConstants.EXIT_GAME,
    }
end

function RulesMediator:onRegister()
    print("-------------->RulesMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    local image_root = gameFacade:retrieveMediator("MainMediator").image_root

    local csbPath = "ui_csb/RulesLayer.csb"
	local ui = cc.CSLoader:createNode(csbPath)
    local Image_bg = ui:getChildByName("Image_bg")
	self:setViewComponent(ui)
    image_root:addChild(self:getViewComponent(),MyGameConstants.ORDER_RULE)

    -- 关闭
    local Button_close = Image_bg:getChildByName("Button_close")
    Button_close:addClickEventListener(function ()
        GameMusic:playClickEffect()
        self:getViewComponent():removeFromParent()
        gameFacade:removeMediator("RulesMediator")
    end)

    self.cardTypeSelect = {}   -- 牌型
    self.ruleSelect = {}       -- 玩法
    self.choosableSelect = {}  -- 可选
    self.zhuaNiaoSelect = {}   -- 抓鸟
    self.payTypeSelect = {}    -- 付费类型

    self.cardTypeSelect[1] = ui:getChildByName("ScrollView_cardtype"):getChildByName("Image_select")
    local ScrollView_playing = ui:getChildByName("ScrollView_playing")
    for i=1,2 do
        self.ruleSelect[i] = ScrollView_playing:getChildByName("Panel_rule"):getChildByName("Panel_select"):getChildByName("Image_sleect_" .. i)
    end
    for i=1,3 do
        self.choosableSelect[i] = ScrollView_playing:getChildByName("Panel_choosable"):getChildByName("Panel_select"):getChildByName("Image_sleect_" .. i)
    end
    for i=1,4 do
        self.zhuaNiaoSelect[i] = ScrollView_playing:getChildByName("Panel_zhuaniao"):getChildByName("Panel_select"):getChildByName("Image_sleect_" .. i)
    end
    for i=1,3 do
        self.payTypeSelect[i] = ScrollView_playing:getChildByName("Panel_paytype"):getChildByName("Panel_select"):getChildByName("Image_sleect_" .. i)
    end

    self:initView()
end

function RulesMediator:onRemove()
    print("-------------->RulesMediator:onRemove")
	self:setViewComponent(nil)
end

function RulesMediator:handleNotification(notification)
    print("-------------->RulesMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	
    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("RulesMediator")
    end
end

---------------------------------------------------------------------------
-- 初始化
function RulesMediator:initView()
    for k,v in pairs(self.cardTypeSelect) do
        v:loadTexture("ui_res/rules/disabled.png")
    end
    for k,v in pairs(self.ruleSelect) do
        v:loadTexture("ui_res/rules/disabled.png")
    end
    for k,v in pairs(self.choosableSelect) do
        v:loadTexture("ui_res/rules/disabled.png")
    end
    for k,v in pairs(self.zhuaNiaoSelect) do
        v:loadTexture("ui_res/rules/disabled.png")
    end
    for k,v in pairs(self.payTypeSelect) do
        v:loadTexture("ui_res/rules/disabled.png")
    end

    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local choiceConfig = platformFacade:retrieveProxy("RoomConfigProxy"):getData().choice
    dump(choiceConfig,"SelectRoomConfig",10)

    for k,v in pairs(choiceConfig) do
        if v.code == "Rule" then
            for m,n in pairs(v.choice) do
                if self.ruleSelect[n.optionId] ~= nil then
                    self.ruleSelect[n.optionId]:loadTexture("ui_res/rules/select.png")
                end
            end
        elseif v.code == "Select" then
            for m,n in pairs(v.choice) do
                if n.optionId == 1 then
                    if self.choosableSelect[n.optionId] ~= nil then
                        self.choosableSelect[n.optionId]:loadTexture("ui_res/rules/select.png")
                    end
                elseif n.optionId == 2 then
                    self.cardTypeSelect[1]:loadTexture("ui_res/rules/select.png")
                else
                    if self.choosableSelect[n.optionId - 1] ~= nil then
                        self.choosableSelect[n.optionId - 1]:loadTexture("ui_res/rules/select.png")
                    end
                end
            end
        elseif v.code == "ZhuaNiao" then
            for m, n in pairs(v.choice) do
                if self.zhuaNiaoSelect[n.optionId - 1] ~= nil then
                    self.zhuaNiaoSelect[n.optionId - 1]:loadTexture("ui_res/rules/select.png")
                end
            end
        elseif v.code == "PayType" then
            for m,n in pairs(v.choice) do
                if self.payTypeSelect[n.optionId] ~= nil then  
                    self.payTypeSelect[n.optionId]:loadTexture("ui_res/rules/select.png")
                end
            end
        end
    end
end

return RulesMediator