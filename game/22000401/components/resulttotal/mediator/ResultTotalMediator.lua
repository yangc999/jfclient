local ResultTotalMenuMediator = import(".ResultTotalMenuMediator")
local ResultTotalPlayerInfoMediator = import(".ResultTotalPlayerInfoMediator")

local Mediator = cc.load("puremvc").Mediator
local ResultTotalMediator = class("ResultTotalMediator", Mediator)

function ResultTotalMediator:ctor()
    print("-------------->ResultTotalMediator:ctor")
	ResultTotalMediator.super.ctor(self, "ResultTotalMediator")
end

function ResultTotalMediator:listNotificationInterests()
    print("-------------->ResultTotalMediator:listNotificationInterests")
	local GameConstants = cc.exports.GameConstants
	return {
        GameConstants.EXIT_GAME,   
	}
end

function ResultTotalMediator:onRegister()
    print("-------------->ResultTotalMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    local scene = gameFacade:retrieveMediator("MainMediator").scene

    local csbPath = "ui_csb/PlayersScoreLayer.csb"
	local ui = cc.CSLoader:createNode(csbPath)
    local Image_bg = ui:getChildByName("Panel_players_score"):getChildByName("Image_bg")
	self:setViewComponent(ui)
    scene:addChild(self:getViewComponent())

    -- 玩家信息
    local Panel_playerinfo = Image_bg:getChildByName("Panel_playerinfo")
	gameFacade:registerMediator(ResultTotalPlayerInfoMediator.new(Panel_playerinfo))

    -- 菜单
    local Panel_menu = Image_bg:getChildByName("Panel_menu")
	gameFacade:registerMediator(ResultTotalMenuMediator.new(Panel_menu))
end

function ResultTotalMediator:onRemove()
    print("-------------->ResultTotalMediator:onRemove")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

function ResultTotalMediator:handleNotification(notification)
    print("-------------->ResultTotalMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	
    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("ResultTotalMediator")
        gameFacade:removeProxy("ResultTotalProxy")
    end
end

---------------------------------------------------------------------------


return ResultTotalMediator