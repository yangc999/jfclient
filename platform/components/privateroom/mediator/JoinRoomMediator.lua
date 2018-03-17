
local Mediator = cc.load("puremvc").Mediator
local JoinRoomMediator = class("JoinRoomMediator", Mediator)

function JoinRoomMediator:ctor()
	JoinRoomMediator.super.ctor(self, "JoinRoomMediator")
end	

function JoinRoomMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.START_LOGOUT, 
		PlatformConstants.REQUEST_PRVCONNECT, 
		PlatformConstants.UPDATE_ROOMKEY, 
	}
end

function JoinRoomMediator:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	platformFacade:registerCommand(PlatformConstants.ADD_ROOMKEY, cc.exports.AddRoomKeyCommand)
	platformFacade:registerCommand(PlatformConstants.SUB_ROOMKEY, cc.exports.SubRoomKeyCommand)
	platformFacade:registerCommand(PlatformConstants.CLR_ROOMKEY, cc.exports.ClearRoomKeyCommand)

	local ui = cc.CSLoader:createNode("hall_res/openRoom/inputNumLayer.csb")
	self:setViewComponent(ui)
	local scene = platformFacade:retrieveMediator("HallMediator").scene
	scene:addChild(self:getViewComponent())

	local btn_back = seekNodeByName(ui, "btn_close")
	if btn_back then
		btn_back:setZoomScale(-0.1)
		btn_back:addClickEventListener(function()
			platformFacade:removeMediator("JoinRoomMediator")
		end)
	end

	local btn_again = seekNodeByName(ui, "btn_again")
	if btn_again then
		btn_again:setZoomScale(-0.1)
		btn_again:addClickEventListener(function()
			platformFacade:sendNotification(PlatformConstants.CLR_ROOMKEY)
		end)
	end

	local btn_delete = seekNodeByName(ui, "btn_delete")
	if btn_delete then
		btn_delete:setZoomScale(-0.1)
		btn_delete:addClickEventListener(function()
			platformFacade:sendNotification(PlatformConstants.SUB_ROOMKEY)
		end)
	end

    for i=0,9 do
		local btn_i = seekNodeByName(ui, "btn_an_"..i)
		btn_i:setZoomScale(-0.1)
		btn_i:addClickEventListener(function()
			platformFacade:sendNotification(PlatformConstants.ADD_ROOMKEY, tostring(i))
		end)
	end
	
	for i=1,6 do
		local item = seekNodeByName(ui, "input"..i)
		local num = seekNodeByName(item, "nums")
		num:setVisible(false)
	end

	platformFacade:sendNotification(PlatformConstants.CLR_ROOMKEY)
end

function JoinRoomMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	platformFacade:removeCommand(PlatformConstants.ADD_ROOMKEY)
	platformFacade:removeCommand(PlatformConstants.SUB_ROOMKEY)
	platformFacade:removeCommand(PlatformConstants.CLR_ROOMKEY)

	platformFacade:removeProxy("RoomKeyProxy")

	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

function JoinRoomMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	if name == PlatformConstants.START_LOGOUT then
		platformFacade:removeMediator("JoinRoomMediator")
	elseif name == PlatformConstants.UPDATE_ROOMKEY then
		local key = body and body or ""
		print("roomkey", key)
		if self:getViewComponent() then
			for i=1,6 do
				local item = seekNodeByName(self:getViewComponent(), "input"..i)
				local num = seekNodeByName(item, "nums")
				local str = string.sub(key, i, i)
				if str ~= "" then
					num:setVisible(true)
					num:setString(str)
				else
					num:setVisible(false)
				end
			end
		end
		if string.len(key) == 6 then
			local gameFacade = cc.load("puremvc").Facade.getInstance("game")
			local GameConstants = cc.exports.GameConstants
			print("joinRoom roomKey:",key)
			local function sendMsgCallback()
				print("JoinPrivateRoom timeout")
		        platformFacade:sendNotification(PlatformConstants.CLR_ROOMKEY)
		    end
			cc.exports.showLoadingAnim("正在进入房间...","进入房间失败",sendMsgCallback,5)
			gameFacade:sendNotification(GameConstants.REQUEST_PRVCONNECT, {sRoomKey=key})
		end
	end
end

return JoinRoomMediator