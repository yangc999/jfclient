
local Mediator = cc.load("puremvc").Mediator
local PrivateGameListMediator = class("PrivateGameListMediator", Mediator)

function PrivateGameListMediator:ctor(root)
	PrivateGameListMediator.super.ctor(self, "PrivateGameListMediator", root)
end

function PrivateGameListMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.UPDATE_ROOMSLC, 
	}
end

function PrivateGameListMediator:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	local roomCfg = platformFacade:retrieveProxy("RoomConfigProxy")
	local gameList = platformFacade:retrieveProxy("GameListProxy")

	local ui = self:getViewComponent()
	self.list = seekNodeByName(ui, "ListView_game")
	self.list:setScrollBarEnabled(false)
	self.list:removeAllChildren()
	self.tmp = seekNodeByName(ui, "Panel_Item")

	local privateGame = gameList:getData().private
	for i,v in ipairs(privateGame) do
		local item = self.tmp:clone()
		item:setVisible(true)
		local txt = seekNodeByName(item, "Text_name")
		txt:setVisible(false)
		local newTxt = ccui.Text:create(v.gameName, "platform/font/fangzhenyuanstatic.ttf", 30)
		newTxt:setName("txt")
		newTxt:enableOutline(cc.c3b(173, 35, 0), 2)
		newTxt:setPosition(txt:getPositionX(), txt:getPositionY())
		item:addChild(newTxt)
		seekNodeByName(item, "Btn_game"):setZoomScale(-0.1)
		seekNodeByName(item, "Btn_game"):addClickEventListener(function()
			roomCfg:getData().select = i
			platformFacade:sendNotification(PlatformConstants.REQUEST_ROOMCFG, v.gameId)
		end)
		self.list:pushBackCustomItem(item)
	end

	if #self.list:getItems() > 0 then
		roomCfg:getData().select = 1
		platformFacade:sendNotification(PlatformConstants.REQUEST_ROOMCFG, privateGame[1].gameId)
	end
end

function PrivateGameListMediator:onRemove()
end

function PrivateGameListMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	local PlatformConstants = cc.exports.PlatformConstants
	if name == PlatformConstants.UPDATE_ROOMSLC then
		for i,v in ipairs(self.list:getItems()) do
			if i == body then
				seekNodeByName(v, "Btn_game"):setEnabled(false)
			else
				seekNodeByName(v, "Btn_game"):setEnabled(true)
			end
		end
	end
end

return PrivateGameListMediator