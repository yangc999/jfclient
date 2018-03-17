
local Mediator = cc.load("puremvc").Mediator
local ResultMediator = class("ResultMediator", Mediator)

local ResultHandCardMediator = import(".ResultHandCardMediator")
local ResultMenuMediator = import(".ResultMenuMediator")
local ResultNiaoCardMediator = import(".ResultNiaoCardMediator")
local ResultPlayerInfoMediator = import(".ResultPlayerInfoMediator")

function ResultMediator:ctor()
    print("-------------->ResultMediator:ctor")
	ResultMediator.super.ctor(self, "ResultMediator")

end

function ResultMediator:listNotificationInterests()
    print("-------------->ResultMediator:listNotificationInterests")
    local GameConstants = cc.exports.GameConstants
	return
    {
        GameConstants.EXIT_GAME,
        MyGameConstants.C_CLOSE_RESULT,
    }
end

function ResultMediator:onRegister()
    print("-------------->ResultMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    local scene = gameFacade:retrieveMediator("MainMediator").scene

    local csbPath = "ui_csb/GameResultLayer.csb"
	local ui = cc.CSLoader:createNode(csbPath)
    local Image_bg = ui:getChildByName("Panel_gameresult"):getChildByName("Image_bg")
	self:setViewComponent(ui)
    scene:addChild(self:getViewComponent())

    -- 鸟牌
    local Panel_niaocards = Image_bg:getChildByName("Panel_niaocards")
	gameFacade:registerMediator(ResultNiaoCardMediator.new(Panel_niaocards))

    -- 手牌
    local Panel_handcards = Image_bg:getChildByName("Panel_handcards")
	gameFacade:registerMediator(ResultHandCardMediator.new(Panel_handcards))

    -- 玩家信息
    local Panel_playerinfo = Image_bg:getChildByName("Panel_playerinfo")
	gameFacade:registerMediator(ResultPlayerInfoMediator.new(Panel_playerinfo))

    -- 菜单
    local Panel_menu = Image_bg:getChildByName("Panel_menu")
	gameFacade:registerMediator(ResultMenuMediator.new(Panel_menu))
end

function ResultMediator:onRemove()
    print("-------------->ResultMediator:onRemove")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

function ResultMediator:handleNotification(notification)
    print("-------------->ResultMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	
    if name == GameConstants.EXIT_GAME or name == MyGameConstants.C_CLOSE_RESULT then
        gameFacade:removeMediator("ResultMediator")
        gameFacade:removeProxy("ResultProxy")
    end
end

return ResultMediator