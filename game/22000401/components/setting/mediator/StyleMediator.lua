local Mediator = cc.load("puremvc").Mediator
local StyleMediator = class("StyleMediator", Mediator)
local GameMusic = import("....GameMusic")

function StyleMediator:ctor(root)
    print("-------------->StyleMediator:ctor")
	StyleMediator.super.ctor(self, "StyleMediator",root)
    self.root = root
end

function StyleMediator:listNotificationInterests()
    print("-------------->StyleMediator:listNotificationInterests")
	return
    {
        GameConstants.EXIT_GAME,
    }
end

function StyleMediator:onRegister()
    print("-------------->StyleMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    local image_root = gameFacade:retrieveMediator("MainMediator").image_root

    self.Button_tc = {}
    for i=1,3 do
        local Button_tablecloth = self.root:getChildByName("Button_tablecloth_" .. i)
        self.Button_tc[i] = Button_tablecloth
        Button_tablecloth:addClickEventListener(function()
            GameMusic:playClickEffect()
            GameUtils:getInstance():setMJTableCloth(i)
            local gameFacade = cc.load("puremvc").Facade.getInstance("game")
            gameFacade:sendNotification(MyGameConstants.C_UPDATE_TABLECLOTH)
            self:updateTablecloth()
        end)
    end

    self.Button_cb = {}
    for i=1,3 do
        local Button_cardback = self.root:getChildByName("Button_cardback_" .. i)
        self.Button_cb[i] = Button_cardback
        Button_cardback:addClickEventListener(function()
            GameMusic:playClickEffect()
            GameUtils:getInstance():setMJCardBack(i)
            local gameFacade = cc.load("puremvc").Facade.getInstance("game")
            gameFacade:sendNotification(MyGameConstants.C_UPDATE_CARDBACK)
            self:updateCardback()
        end)
    end

    self:updateTablecloth()
    self:updateCardback()
end

function StyleMediator:onRemove()
    print("-------------->StyleMediator:onRemove")
	self:setViewComponent(nil)
end

function StyleMediator:handleNotification(notification)
    print("-------------->StyleMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	
    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("StyleMediator")
    end
end

---------------------------------------------------------------------------
-- 刷新桌布
function StyleMediator:updateTablecloth()
    local colorType = GameUtils:getInstance():getMJTableCloth()
    self.Button_tc[1]:loadTextures("ui_res/Setting/round_normal.png", "", "")
    self.Button_tc[2]:loadTextures("ui_res/Setting/round_normal.png", "", "")
    self.Button_tc[3]:loadTextures("ui_res/Setting/round_normal.png", "", "")
    self.Button_tc[colorType]:loadTextures("ui_res/Setting/round_select.png", "", "")
end

-- 刷新牌背
function StyleMediator:updateCardback()
    local colorType = GameUtils:getInstance():getMJCardBack()
    self.Button_cb[1]:loadTextures("ui_res/Setting/round_normal.png", "", "")
    self.Button_cb[2]:loadTextures("ui_res/Setting/round_normal.png", "", "")
    self.Button_cb[3]:loadTextures("ui_res/Setting/round_normal.png", "", "")
    self.Button_cb[colorType]:loadTextures("ui_res/Setting/round_select.png", "", "")
end

return StyleMediator