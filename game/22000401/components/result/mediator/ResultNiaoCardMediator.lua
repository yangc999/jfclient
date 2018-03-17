
local Mediator = cc.load("puremvc").Mediator
local ResultNiaoCardMediator = class("ResultNiaoCardMediator", Mediator)

function ResultNiaoCardMediator:ctor(root)
    print("-------------->ResultNiaoCardMediator:ctor")
	ResultNiaoCardMediator.super.ctor(self, "ResultNiaoCardMediator",root)
    self.root = root
end

function ResultNiaoCardMediator:listNotificationInterests()
    print("-------------->ResultNiaoCardMediator:listNotificationInterests")
	local MyGameConstants = cc.exports.MyGameConstants
	return {
		"RE_updateniaocard",
        GameConstants.EXIT_GAME,
        MyGameConstants.C_CLOSE_RESULT,
	}
end

function ResultNiaoCardMediator:onRegister()
    print("-------------->ResultNiaoCardMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    local colorType = GameUtils:getInstance():getMJCardBack()
    
    -- 鸟牌
    self.niaoCards = {}
    for i = 1,6 do
         local node = self.root:getChildByName("Image_card_" .. i)
         self.niaoCards[i] = node:getChildByName("Image_card")
         self.niaoCards[i]:setVisible(false)
         self.niaoCards[i]:loadTexture(MyGameConstants.COLOR_RES_PATH[colorType] .. "Front_Small_01.png")
    end
    self.root:setVisible(false)
end

function ResultNiaoCardMediator:onRemove()
    print("-------------->ResultNiaoCardMediator:onRemove")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	self:setViewComponent(nil)
end

function ResultNiaoCardMediator:handleNotification(notification)
    print("-------------->ResultNiaoCardMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local MyGameConstants = cc.exports.MyGameConstants
	
    if name == GameConstants.EXIT_GAME or name == MyGameConstants.C_CLOSE_RESULT then
        gameFacade:removeMediator("ResultNiaoCardMediator")
    elseif name == "RE_updateniaocard" then
        self:updateNiaoCard()
    end
end

---------------------------------------------------------------------------

function ResultNiaoCardMediator:updateNiaoCard()
    self.root:setVisible(true)
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("ResultProxy"):getData()
    local NiaoCardData = data.NiaoCardData

    for i, value in pairs(NiaoCardData) do
        if value <= 0 or value > 37 then
            self.niaoCards[i]:setVisible(false)
        else
            local image_value = self.niaoCards[i]:getChildByName("Image_value")
            image_value:loadTexture("ui_res/Mahjong/Small/Small_" .. tostring(value) .. ".png")
            self.niaoCards[i]:setVisible(true)
            if value % 10 == 1 or value % 10 == 5 or value % 10 == 9 or value == 35 then
                self.niaoCards[i]:setColor(MyGameConstants.SELECTED_COLOR)
            end
        end
    end
    

end


return ResultNiaoCardMediator