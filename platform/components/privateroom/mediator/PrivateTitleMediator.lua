
local Mediator = cc.load("puremvc").Mediator
local PrivateTitleMediator = class("PrivateTitleMediator", Mediator)

function PrivateTitleMediator:ctor(root)
	PrivateTitleMediator.super.ctor(self, "PrivateTitleMediator", root)
end

function PrivateTitleMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.SHOW_GAMELIST, 
		PlatformConstants.SHOW_ROOMLIST, 
		PlatformConstants.UPDATE_NICKNAME, 
		PlatformConstants.UPDATE_HEADID, 
		PlatformConstants.UPDATE_HEADSTR, 
		PlatformConstants.UPDATE_DIAMOND, 
		PlatformConstants.UPDATE_ROOMCARD, 
	}
end

function PrivateTitleMediator:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	local userinfo = platformFacade:retrieveProxy("UserInfoProxy")
	local ui = self:getViewComponent()

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

	self.txtName = seekNodeByName(ui, "nickname")
	if userinfo:getData().nickName then
		self.txtName:setString(userinfo:getData().nickName)
	end

	self.txtCard = seekNodeByName(ui, "userfangka")
	if userinfo:getData().roomCard then
		local roomCardStr=cc.exports.formatLongNum(userinfo:getData().roomCard)
		self.txtCard:setString(roomCardStr)
	else
		self.txtCard:setString(0)
	end
	
	self.txtDiamond = seekNodeByName(ui, "userdiamond")
	if userinfo:getData().diamond then
        local diamondStr = cc.exports.formatLongNum(userinfo:getData().diamond)
		self.txtDiamond:setString(diamondStr)
	else
		self.txtDiamond:setString(0)
	end

    --金币面板
    -- local coin_panel = seekNodeByName(ui, "img_jidou_bg")
    -- if coin_panel then
    --    local btn_AddCoin = seekNodeByName(coin_panel, "btn_addjindou")
    --    btn_AddCoin:addClickEventListener(function()
    --      print("click btn_AddCoin")
    --      platformFacade:sendNotification(PlatformConstants.START_SHOPLAYER,4)  --启动商城 
    --    end)
    -- end
    --房卡面板
    -- local roomCard_panel = seekNodeByName(ui, "img_fangka_bg")
    -- if roomCard_panel then
    --    local btn_AddRoomCard = seekNodeByName(roomCard_panel, "btn_addfangka")
    --    btn_AddRoomCard:addClickEventListener(function()
    --      print("click btn_AddRoomCard")
    --      platformFacade:sendNotification(PlatformConstants.START_SHOPLAYER,3)  --启动商城
    --    end)
    -- end

end

function PrivateTitleMediator:onRemove()
end

function PrivateTitleMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	local PlatformConstants = cc.exports.PlatformConstants
	if name == PlatformConstants.UPDATE_NICKNAME then
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
		local diamondStr = cc.exports.formatLongNum(body)
		self.txtDiamond:setString(diamondStr)
	elseif name == PlatformConstants.UPDATE_ROOMCARD then
		local roomCardStr = cc.exports.formatLongNum(body)
		self.txtCard:setString(roomCardStr)
	end
end

return PrivateTitleMediator