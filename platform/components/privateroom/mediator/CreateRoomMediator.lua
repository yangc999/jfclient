
local PrivateGameListMediator = import(".PrivateGameListMediator")
local RoomConfigMediator = import(".RoomConfigMediator")

local Mediator = cc.load("puremvc").Mediator
local CreateRoomMediator = class("CreateRoomMediator", Mediator)

function CreateRoomMediator:ctor()
	CreateRoomMediator.super.ctor(self, "CreateRoomMediator")
end	

function CreateRoomMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.START_LOGOUT, 
		PlatformConstants.UPDATE_ANTICHEATING,
		PlatformConstants.DISMISS_CREATE_ROOM
	}
end

function CreateRoomMediator:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	platformFacade:registerCommand(PlatformConstants.REQUEST_ROOMCFG, cc.exports.RequestRoomConfigCommand)
	platformFacade:registerCommand(PlatformConstants.REQUEST_ROOMCREATE, cc.exports.RequestCreateRoomCommand)
	platformFacade:registerCommand(PlatformConstants.START_GAMEHELPLAYER, cc.exports.StartGameHelpLayerCommand)  --启动玩法帮助界面的指令

	local ui = cc.CSLoader:createNode("hall_res/openRoom/createRoomNewLayer.csb")
	self:setViewComponent(ui)
	local scene = platformFacade:retrieveMediator("HallMediator").scene
	scene:addChild(self:getViewComponent())

	local btn_back = seekNodeByName(ui, "btn_back")
	if btn_back then
		btn_back:setZoomScale(-0.1)
		btn_back:addClickEventListener(function()
			platformFacade:removeMediator("RoomConfigMediator")
			platformFacade:removeMediator("PrivateGameListMediator")
			platformFacade:removeMediator("CreateRoomMediator")
        end)
	end

	local btn_ok = seekNodeByName(ui, "btn_ok")
	if btn_ok then
		btn_ok:setZoomScale(-0.1)
		btn_ok:addClickEventListener(function()
			platformFacade:sendNotification(PlatformConstants.REQUEST_ROOMCREATE)
		end)
	end

	--防作弊开关
	local img_cheat = seekNodeByName(ui, "Image_fangzuobi")
	
	local roomConfig = platformFacade:retrieveProxy("RoomConfigProxy")
	if cc.UserDefault:getInstance():getIntegerForKey("iAntiCheating",0) == 0 then
		 roomConfig:getData().iAntiCheating = false
		 img_cheat:loadTexture( "hall_res/openRoom/createRoom/NO.png" )
	else
		roomConfig:getData().iAntiCheating = true
		img_cheat:loadTexture( "hall_res/openRoom/createRoom/YES.png" )
	end
	
	if img_cheat then	
		img_cheat:addClickEventListener(function()
			local roomConfig = platformFacade:retrieveProxy("RoomConfigProxy")
			roomConfig:getData().iAntiCheating = not roomConfig:getData().iAntiCheating
		end)
	end
	

	--防作弊问号图标
	local img_cheat_why = seekNodeByName(ui, "Image_fangzuobi_why")
	if img_cheat_why then
		img_cheat_why:addClickEventListener(function()
			platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "功能正在火热开发中...")
		end)
	end

	--玩法按钮
	local img_wanfa = seekNodeByName(ui, "Image_wanfa")
	if img_wanfa then
		img_wanfa:addClickEventListener(function()
			platformFacade:sendNotification(PlatformConstants.START_GAMEHELPLAYER)
		end)
	end

	local panelOption = seekNodeByName(ui, "Panel_option")
	platformFacade:registerMediator(RoomConfigMediator.new(panelOption))

	local panelList = seekNodeByName(ui, "Panel_list")
	platformFacade:registerMediator(PrivateGameListMediator.new(panelList))

end

function CreateRoomMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	platformFacade:removeCommand(PlatformConstants.REQUEST_ROOMCFG)
	platformFacade:removeCommand(PlatformConstants.REQUEST_ROOMCREATE)
	platformFacade:removeCommand(PlatformConstants.START_GAMEHELPLAYER)

	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

function CreateRoomMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	if name == PlatformConstants.START_LOGOUT then
		platformFacade:removeMediator("RoomConfigMediator")
		platformFacade:removeMediator("PrivateGameListMediator")
		platformFacade:removeMediator("CreateRoomMediator")

	elseif name == PlatformConstants.UPDATE_ANTICHEATING then
		local ui = self:getViewComponent()
		local img_cheat = seekNodeByName(ui, "Image_fangzuobi")

		if body then
			img_cheat:loadTexture( "hall_res/openRoom/createRoom/YES.png" )
			cc.UserDefault:getInstance():setIntegerForKey("iAntiCheating", 1)
		else
			img_cheat:loadTexture("hall_res/openRoom/createRoom/NO.png")
			cc.UserDefault:getInstance():setIntegerForKey("iAntiCheating", 0)
		end
	elseif name == PlatformConstants.DISMISS_CREATE_ROOM then
		print("创建房间的配置窗口消失")
		platformFacade:removeMediator("RoomConfigMediator")
		platformFacade:removeMediator("PrivateGameListMediator")
		platformFacade:removeMediator("CreateRoomMediator")
	end
end

return CreateRoomMediator
