
local Mediator = cc.load("puremvc").Mediator
local RoomListMediator = class("RoomListMediator", Mediator)

function RoomListMediator:ctor(root)
	RoomListMediator.super.ctor(self, "RoomListMediator", root)
end	

function RoomListMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.START_LOGOUT, 
		PlatformConstants.SHOW_GAMELIST, 
		PlatformConstants.SHOW_ROOMLIST, 
		PlatformConstants.UPDATE_PUBROOM, 
		PlatformConstants.UPDATE_QUICKROOM, 
	}
end

function RoomListMediator:onRegister()
	local root = self:getViewComponent()

	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	
	self.list = seekNodeByName(root, "ListView")
	self.template = seekNodeByName(root, "Panel_listItem")
	self.quick = seekNodeByName(root, "Button_quick")
	self.quick:setZoomScale(-0.1)
	self.quick:addClickEventListener(function()
		local proxy = platformFacade:retrieveProxy("RoomListProxy")
		local userinfo = platformFacade:retrieveProxy("UserInfoProxy")
		local gold = userinfo:getData().gold
		local gameId = proxy:getData().gameId
		local roomId
		for i,v in ipairs(proxy:getData().quick) do
			print("gold", gold)
			dump(v, "quick")
			if gold >= v.minGold then
				roomId = v.roomId
			end
		end
		if gameId and roomId then
			gameFacade:sendNotification(GameConstants.REQUEST_QUKCONNECT, {gameId=gameId, roomId=roomId})
		else
			platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "金币不足")
		end
	end)

	platformFacade:registerCommand(PlatformConstants.REQUEST_DESKLIST, cc.exports.RequestDeskListCommand)
	platformFacade:registerCommand(PlatformConstants.START_DESKLIST, cc.exports.StartDeskListCommand)
end

function RoomListMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	platformFacade:removeCommand(PlatformConstants.REQUEST_DESKLIST)
	platformFacade:removeCommand(PlatformConstants.START_DESKLIST)
end

function RoomListMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	if name == PlatformConstants.START_LOGOUT then
		platformFacade:removeMediator("RoomListMediator")
	elseif name == PlatformConstants.SHOW_GAMELIST then
		self:getViewComponent():setVisible(false)
	elseif name == PlatformConstants.SHOW_ROOMLIST then
		self:getViewComponent():setVisible(true)
	elseif name == PlatformConstants.UPDATE_PUBROOM then
		dump(body, "pubroom")
		local gameFacade = cc.load("puremvc").Facade.getInstance("game")
		local GameConstants = cc.exports.GameConstants
		self.list:removeAllChildren()
		local proxy = platformFacade:retrieveProxy("RoomListProxy")
		dump(body, "room")
		for i,v in ipairs(body) do
			local roomItem = self.template:clone()
			roomItem:setVisible(true)
			local roomId = v.roomId
			local minGold = v.minGold
			local imgRoomItem = seekNodeByName(roomItem, "Image_roomitem")
			if imgRoomItem then
				imgRoomItem:loadTexture(string.format("platform/platform_res/hall/bg-%d.png", i))
				imgRoomItem:addClickEventListener(function()
					local userinfo = platformFacade:retrieveProxy("UserInfoProxy")
					local gold = userinfo:getData().gold
					if gold >= minGold then
						platformFacade:sendNotification(PlatformConstants.REQUEST_DESKLIST, {roomId=roomId, lv=i, entry=minGold})
					else
						platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "金币不足")
					end
					--platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "功能待开放")
				end)
			end
			local imgNameItem = seekNodeByName(roomItem, "Image_nameitem")
			if imgNameItem then
				imgNameItem:loadTexture(string.format("platform/platform_res/hall/title-%d.png", i))
			end
			local entry = seekNodeByName(roomItem, "Text_entry")
			if entry then
				entry:setString(string.format("底分:%d", minGold))
			end
			local name = seekNodeByName(roomItem, "Text_play")
			if name then
				name:setString("玩法")
				name:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果
			end
			-- local info = string.split(v.gameName, ";")
			-- if info[2] then
			-- 	local name = seekNodeByName(roomItem, "Text_play")
			-- 	if name then
			-- 		name:setString(info[2])
			-- 	end
			-- else
			-- 	local belt = seekNodeByName(roomItem, "Image_titlebg")
			-- 	belt:setVisible(false)
			-- 	local name = seekNodeByName(roomItem, "Text_play")
			-- 	name:setVisible(false)
			-- end
			self.list:pushBackCustomItem(roomItem)
		end
	elseif name == PlatformConstants.UPDATE_QUICKROOM then
		if body and table.nums(body) > 0 then
			self.quick:setVisible(true)
		else
			self.quick:setVisible(false)
		end		
	end
end

return RoomListMediator