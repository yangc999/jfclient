
local Mediator = cc.load("puremvc").Mediator
local DeskListMediator = class("DeskListMediator", Mediator)

function DeskListMediator:ctor()
	DeskListMediator.super.ctor(self, "DeskListMediator")
end	

function DeskListMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.START_LOGOUT, 
		PlatformConstants.UPDATE_SHOWDESK, 
	}
end

function DeskListMediator:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants

	local desklist = platformFacade:retrieveProxy("DeskListProxy")

	local scene = platformFacade:retrieveMediator("HallMediator").scene
	local ui = cc.CSLoader:createNode("hall_res/desklist/DeskListLayer.csb")
	self:setViewComponent(ui)
	scene:addChild(ui)

	self.list = seekNodeByName(ui, "ListView")
	self.seat = seekNodeByName(ui, "Panel_seat")
	self.extra = seekNodeByName(ui, "Panel_extra")
	self.itemTemp = seekNodeByName(ui, "Image_1")

	self.list:setScrollBarEnabled(false)
	self.list:addScrollViewEventListener(function(sender, eventType)
		if eventType == ccui.ScrollviewEventType.containerMoved then
			local innerY = self.list:getInnerContainerPosition().y
			local innerHeight = self.list:getInnerContainerSize().height
			local outHeight = self.list:getContentSize().height
			local edge = 10
			if innerY >= 0-edge then
				if desklist:getData().showTo < desklist:getData().deskNum then
					self.list:getInnerContainer():setPositionY(innerY-self.itemTemp:getContentSize().height)
					desklist:getData().showFrom = desklist:getData().showFrom + 1
					desklist:getData().showTo = desklist:getData().showTo + 1
					desklist:present()
				end
			elseif innerY <= outHeight-innerHeight+edge then
				if desklist:getData().showFrom > 1 then
					self.list:getInnerContainer():setPositionY(innerY+self.itemTemp:getContentSize().height)
					desklist:getData().showFrom = desklist:getData().showFrom - 1
					desklist:getData().showTo = desklist:getData().showTo - 1
					desklist:present()
				end
			end
		elseif eventType == ccui.ScrollviewEventType.scrollingEnded then
			self.loop = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
				platformFacade:sendNotification(PlatformConstants.REQUEST_DESKDETAIL)
			end, 2, false)			
		elseif eventType == ccui.ScrollviewEventType.scrollingBegan then
			if self.loop then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.loop)
			end
		end
	end)

	local desklist = platformFacade:retrieveProxy("DeskListProxy")
	local roomlist = platformFacade:retrieveProxy("RoomListProxy")
	seekNodeByName(ui, "Image_title"):loadTexture(string.format("platform/platform_res/desklist/title-%d.png", desklist:getData().lv))
	seekNodeByName(ui, "Text_entry"):setString(string.format("底注:%d", desklist:getData().entry))

	self.items = {}
	for i=1,5 do
		self.items[i] = self.itemTemp:clone()
		self.items[i]:setVisible(true)
		self.list:pushBackCustomItem(self.items[i])
		seekNodeByName(self.items[i], "ListView_1"):setScrollBarEnabled(false)
		local btn = seekNodeByName(self.items[i], "Button_enter")
		btn:setZoomScale(-0.1)
		btn:getTitleLabel():enableOutline(cc.c3b(173, 35, 0), 2)
		btn:addClickEventListener(function()
			local desk = desklist:getData().showDesk[i]
			if desk then
				gameFacade:sendNotification(GameConstants.REQUEST_FRECONNECT, {gameId=roomlist:getData().gameId, roomId=desklist:getData().roomId, serverId=desk.serverId, idx=desk.deskId})
			end
		end)
	end

	local btn_back = seekNodeByName(ui, "Button_back")
	if btn_back then
		btn_back:setZoomScale(-0.1)
		btn_back:addClickEventListener(function()
			platformFacade:removeMediator("DeskListMediator")
		end)
	end

	platformFacade:registerCommand(PlatformConstants.REQUEST_DESKDETAIL, cc.exports.RequestDeskDetailCommand)

	self.loop = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
		platformFacade:sendNotification(PlatformConstants.REQUEST_DESKDETAIL)
	end, 2, false)
end

function DeskListMediator:onRemove()
	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)

	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:removeProxy("DeskListProxy")
	
	platformFacade:removeCommand(PlatformConstants.REQUEST_DESKDETAIL)
end

function DeskListMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	if name == PlatformConstants.START_LOGOUT then
		platformFacade:removeMediator("DeskListMediator")
	elseif name == PlatformConstants.UPDATE_SHOWDESK then
		local desklist = platformFacade:retrieveProxy("DeskListProxy")
		for i,v in ipairs(self.items) do
			local desk = body[i]
			if desk then
				v:setVisible(true)
				local list = seekNodeByName(v, "ListView_1")
				list:removeAllChildren()
				local count = 0
				for idx,p in ipairs(desk.playerList) do
					if idx <= 4 then
						if p.uid ~= 0 then
							local item = self.seat:clone()
							item:setVisible(true)
							local id = 0
							local img = string.format("%s%d.png", id < 6 and "boy" or "girl", id < 6 and id or id-6)
							local path = "platform_res/common/" .. img
							seekNodeByName(item, "Image_head"):loadTexture(path)
							seekNodeByName(item, "Text_name"):setString("")
							list:pushBackCustomItem(item)
							count = count + 1
						else
							local item = self.seat:clone()
							item:setVisible(true)
							seekNodeByName(item, "Text_name"):setString("")							
							list:pushBackCustomItem(item)
						end
					else
						local item = self.extra:clone()
						item:setVisible(true)
						list:pushBackCustomItem(item)
						break
					end
				end
				seekNodeByName(v, "Text_num"):setString(string.format("房间号:%d", desk.deskId))
				seekNodeByName(v, "Text_count"):setString(string.format("人数:%d/%d", count, desklist:getData().playerNum))
			else
				v:setVisible(false)
			end
		end
	end
end

return DeskListMediator