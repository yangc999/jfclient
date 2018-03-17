local Mediator = cc.load("puremvc").Mediator
local LanguageMediator = class("LanguageMediator", Mediator)
local GameMusic = import("....GameMusic")

function LanguageMediator:ctor(root)
    print("-------------->LanguageMediator:ctor")
    LanguageMediator.super.ctor(self, "LanguageMediator", root)
    self.root = root
end

function LanguageMediator:listNotificationInterests()
    print("-------------->LanguageMediator:listNotificationInterests")
    return
    {
        GameConstants.EXIT_GAME,
    }
end

function LanguageMediator:onRegister()
    print("-------------->LanguageMediator:onRegister")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local GameConstants = cc.exports.GameConstants

    local Button_common = self.root:getChildByName("Button_common")
    self.Button_common = Button_common
    Button_common:addClickEventListener( function()
        GameMusic:playClickEffect()
        GameUtils:getInstance():setMJLanguageType(0)
        self:uiUpdate()
    end )

    local Button_localism = self.root:getChildByName("Button_localism")
    self.Button_localism = Button_localism
    Button_localism:addClickEventListener( function()
        GameMusic:playClickEffect()
        GameUtils:getInstance():setMJLanguageType(1)
        self:uiUpdate()
    end )

    self:uiUpdate()
end

function LanguageMediator:onRemove()
    print("-------------->LanguageMediator:onRemove")
    self:setViewComponent(nil)
end

function LanguageMediator:handleNotification(notification)
    print("-------------->LanguageMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	
    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("LanguageMediator")
    end
end

---------------------------------------------------------------------------
function LanguageMediator:uiUpdate()
    local languageType = GameUtils:getInstance():getMJLanguageType()
    if languageType == 0 then
        self.Button_common:loadTextures("ui_res/Setting/round_select.png","","")
        self.Button_localism:loadTextures("ui_res/Setting/round_normal.png","","")
    elseif languageType == 1 then
        self.Button_common:loadTextures("ui_res/Setting/round_normal.png","","")
        self.Button_localism:loadTextures("ui_res/Setting/round_select.png","","")
    end
end


return LanguageMediator