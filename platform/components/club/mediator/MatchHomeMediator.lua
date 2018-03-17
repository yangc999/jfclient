--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local Mediator = cc.load("puremvc").Mediator
local MatchHomeMediator = class("MatchHomeMediator", Mediator)

function MatchHomeMediator:ctor(root)
	MatchHomeMediator.super.ctor(self, "MatchHomeMediator")
	self.root = root
end

function MatchHomeMediator:listNotificationInterests()
    local PlatformConstants = cc.exports.PlatformConstants
	return {
    
	}
end

function MatchHomeMediator:onRegister()
    print("MatchHomeMediator:onRegister")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local ui = cc.CSLoader:createNode("hall_res/club/matchlLayer.csb")  --设置UI的csb
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")

    platformFacade:registerCommand(PlatformConstants.START_MATCHSHARE, cc.exports.StartMatchShareCommand)

	self:setViewComponent(ui)
    local scene = platformFacade:retrieveMediator("HallMediator").scene --获取要加载上的场景
	scene:addChild(self:getViewComponent()) --获取大厅的Mediator，加载这个公告场景

    --获取关闭按钮
    local btnClose = seekNodeByName(ui, "btn_back")
	if btnClose then
		btnClose:addClickEventListener(function()
            print("click btnClose")
            btnClose:setZoomScale(-0.1)
			platformFacade:removeMediator("MatchHomeMediator")
		end)
	end

    --钻石面板
    local diamond_panel = seekNodeByName(ui, "img_diamond_bg")
    if diamond_panel then

		diamond_panel:addClickEventListener(function()
			print("click btn_adddiamond")
			platformFacade:sendNotification(PlatformConstants.START_SHOPLAYER, 2)  --启动商城钻石页面
		end)
		self.txtDiamond = seekNodeByName(ui, "usermoney")
		if userinfo:getData().diamond then
			self.txtDiamond:setString(userinfo:getData().diamond)
		end
    end

    --房卡面板
    local fangka_panel = seekNodeByName(ui, "img_fangka_bg")
    if fangka_panel then
       fangka_panel:addClickEventListener(function()
         print("click btn_AddRoomCard")
         platformFacade:sendNotification(PlatformConstants.START_SHOPLAYER, 3)  --启动商城房卡页面
       end)
       self.txtRoomCard = seekNodeByName(ui, "userfangka")
	   if userinfo:getData().roomCard then
		  self.txtRoomCard:setString(userinfo:getData().roomCard)
	   end
    end

    --头像监听
	local btn_headimg = seekNodeByName(ui, "btn_headimg")
	if btn_headimg then
		btn_headimg:addClickEventListener(function(btn)
			local scene = platformFacade:retrieveMediator("HallMediator").scene
			platformFacade:sendNotification(PlatformConstants.SHOW_USERINFO, scene)
		end)
    end
	self.imgHead = btn_headimg
	if userinfo:getData().headStr and string.len(userinfo:getData().headStr) > 0 then
		self.imgHead:loadTexture(userinfo:getData().headStr)
	else
		local id = userinfo:getData().headId or 0
		local img = string.format("%s%d.png", id < 6 and "boy" or "girl", id < 6 and id or id-6)
		local path = "platform_res/common/" .. img
		self.imgHead:loadTexture(path)
	end

    --用户名
    self.txtName = seekNodeByName(ui, "nickname")
	if userinfo:getData().nickName then
		self.txtName:setString(userinfo:getData().nickName)
	end

    --分享按钮
    local btn_share = seekNodeByName(ui, "btn_share")
    if btn_share then
       btn_share:addClickEventListener(function(btn)
            print("click btn_share")
			--local scene = platformFacade:retrieveMediator("HallMediator").scene
			platformFacade:sendNotification(PlatformConstants.START_MATCHSHARE)
		end)
    end
end

function MatchHomeMediator:onRemove()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
	platformFacade:removeCommand(PlatformConstants.START_MATCHSHARE)

    self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)

end

function MatchHomeMediator:handleNotification(notification)
    print("MatchHomeMediator:handleNotification")
    local name = notification:getName()
    local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    if name == PlatformConstants.START_LOGOUT then
		platformFacade:removeMediator("MatchHomeMediator")
        --platformFacade:removeProxy("AnnounceProxy")
    elseif name == PlatformConstants.UPDATE_NICKNAME then
		self.txtName:setString(tostring(body))
    elseif name == PlatformConstants.UPDATE_HEADID then
		local id = body or 0
		local img = string.format("%s%d.png", id < 6 and "boy" or "girl", id < 6 and id or id-6)
		local path = "platform_res/common/" .. img
		self.imgHead:loadTexture(path)
	elseif name == PlatformConstants.UPDATE_HEADSTR then
		if body and string.len(body) > 1 then
			self.imgHead:loadTexture(body)
		end
	elseif name == PlatformConstants.UPDATE_DIAMOND then
		self.txtDiamond:setString(tostring(body))
	elseif name == PlatformConstants.UPDATE_ROOMCARD then
		self.txtRoomCard:setString(tostring(body))
    end
end

return MatchHomeMediator
--endregion
