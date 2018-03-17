
local Mediator = cc.load("puremvc").Mediator
local UserInfoMediator = class("UserInfoMediator", Mediator)

function UserInfoMediator:ctor(scene)
	UserInfoMediator.super.ctor(self, "UserInfoMediator")
	self.scene = scene
end

function UserInfoMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.START_LOGOUT, 
		PlatformConstants.UPDATE_USERNAME, 
		PlatformConstants.UPDATE_NICKNAME, 
		PlatformConstants.UPDATE_HEADID, 
		PlatformConstants.UPDATE_HEADSTR, 
		PlatformConstants.UPDATE_GENDER, 
		PlatformConstants.UPDATE_MOBILE, 
		PlatformConstants.UPDATE_SIGNATURE, 
		PlatformConstants.UPDATE_GOLD, 
		PlatformConstants.UPDATE_SAFEGOLD, 
		PlatformConstants.UPDATE_ROOMCARD, 
		PlatformConstants.UPDATE_DIAMOND, 
		PlatformConstants.UPDATE_EXPERIENCE, 
		PlatformConstants.UPDATE_VIPLEVEL,
	}
end

function UserInfoMediator:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	local userinfo = platformFacade:retrieveProxy("UserInfoProxy")
	local login = platformFacade:retrieveProxy("LoginProxy")

	local csbPath = "hall_res/useraccount/userInfoLayer.csb"
	local ui = cc.CSLoader:createNode(csbPath)
	ui:setPosition(0, 0)
	self:setViewComponent(ui)
	self.scene:addChild(self:getViewComponent())

	--关闭按钮监听
	local btn_close = seekNodeByName(ui, "btn_close")
    if btn_close then
    	btn_close:setZoomScale(-0.1)
		btn_close:addClickEventListener(function(btn)
			platformFacade:removeMediator("UserInfoMediator")	
        end)
    end

    --背包按钮监听
	--local btn_mypackage = seekNodeByName(ui, "btn_mypackage")
	--if btn_mypackage then
	--	btn_mypackage:addClickEventListener(function(btn)
	--		platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "功能待开放")
	--	end)
    --end

    --用户id
    local text_id = seekNodeByName(ui, "text_id")
    if text_id then
        text_id:setString("ID:" .. login:getData().uid)
    end    

    --绑定手机号
	--self.btnBangding = seekNodeByName(ui, "btn_bangding")
	--if self.btnBangding then
	--	self.btnBangding:addClickEventListener(function(btn)
	--		platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "功能待开放")
	--	end)
	--	if userinfo:getData().mobile and string.len(userinfo:getData().mobile) > 0 then
	--		self.btnBangding:setVisible(false)
	--	end
	--end

	--人物头像
	self.imgHead = seekNodeByName(ui, "img_head")
	if userinfo:getData().headStr and string.len(userinfo:getData().headStr) > 0 then
		self.imgHead:loadTexture(userinfo:getData().headStr)
	else
		local id = userinfo:getData().headId or 0
		local img = string.format("%s%d.png", id < 6 and "boy" or "girl", id < 6 and id or id-6)
		local path = "platform_res/common/" .. img
		self.imgHead:loadTexture(path)
	end

	--昵称
	self.txtName = seekNodeByName(ui, "text_nickName")
	if userinfo:getData().nickName then
		self.txtName:setString(userinfo:getData().nickName)
	end

	dump(userinfo:getData(),"userinfojay")

	--性别
	self.imgSex = seekNodeByName(ui, "Image_sex")
	local path = "platform_res/common/nan.png"
	if userinfo:getData().gender then
		if userinfo:getData().gender==2 then
			path = "platform_res/common/nv.png"
		end
	end
	self.imgSex:loadTexture(path)

	--金币
    self.txtGold = seekNodeByName(ui, "text_jindou")
	if userinfo:getData().gold then
		self.txtGold:setString(userinfo:getData().gold)
	else
		self.txtGold:setString(0)
	end

    --钻石
    self.txtDiamond = seekNodeByName(ui, "text_yuanbao")
    print("userinfojay self.txtDiamond:",self.txtDiamond,userinfo:getData().diamond)
	if userinfo:getData().diamond then
		self.txtDiamond:setString(userinfo:getData().diamond)
	else
		self.txtDiamond:setString(0)
	end

    --房卡
    self.txtCard = seekNodeByName(ui, "text_fangka")
	if userinfo:getData().roomCard then
		self.txtCard:setString(userinfo:getData().roomCard)
	else
		self.txtCard:setString(0)
	end

	if userinfo:getData().regTime then
		seekNodeByName(ui, "text_jointime"):setString(string.format("%s", userinfo:getData().regTime))
	end
end

function UserInfoMediator:onRemove()
	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

function UserInfoMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	if name == PlatformConstants.START_LOGOUT then
		platformFacade:removeMediator("UserInfoMediator")
		platformFacade:removeProxy("UserInfoProxy")
	elseif name == PlatformConstants.UPDATE_HEADID then
		local id = body or 0
		local img = string.format("%s%d.png", id < 6 and "boy" or "girl", id < 6 and id or id-6)
		local path = "platform_res/common/" .. img
		self.imgHead:loadTexture(path)
	elseif name == PlatformConstants.UPDATE_HEADSTR then
		if body and string.len(body) > 1 then
			self.imgHead:loadTexture(body)
		end
	elseif name == PlatformConstants.UPDATE_NICKNAME then
		self.txtName:setString(body)
	elseif name == PlatformConstants.UPDATE_GOLD then
		self.txtGold:setString(body)
	elseif name == PlatformConstants.UPDATE_DIAMOND then
		self.txtDiamond:setString(body)
	elseif name == PlatformConstants.UPDATE_ROOMCARD then
		--self.txtCard:setString(body)
	elseif name == PlatformConstants.UPDATE_MOBILE then
		--self.btnBangding:setVisible(body and false or true)
	end	
end

return UserInfoMediator