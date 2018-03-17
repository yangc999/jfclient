--region *.lua
--Date
--用户协议和个人隐私的页面
local Mediator = cc.load("puremvc").Mediator
--local lua_to_plat = require('components/Tools/lua_to_plat.lua')

local UserPrivacyMediator = class("UserPrivacyMediator", Mediator)

local UserAgreeUrl = "http://bzwysrgx.oss-cn-shenzhen.aliyuncs.com/yshj/apk/site/UserAgreement.htm"
local UserPrivacyUrl = "http://bzwysrgx.oss-cn-shenzhen.aliyuncs.com/yshj/apk/site/PrivacyPolicy.htm"

function UserPrivacyMediator:openWebViews(parent, url, file_path, text, x, y, width, height)
    print("start lua_to_plat:openWebViews")
    if device.platform == "windows" then
    else
        local webView = ccexp.WebView:create()
        webView:setPosition( x,  y )
        webView:setContentSize(width,  height)
    
        if url then
            webView:loadURL( url )
        elseif file_path then
            print( "webView:" , file_path )
            webView:loadFile(file_path)
        elseif text then
            webView:loadHTMLString( text )
        end

        webView:setScalesPageToFit(true)

        webView:setOnShouldStartLoading(function(sender, url)
            print("onWebViewShouldStartLoading, url is ", url)
            return true
        end)
        webView:setOnDidFinishLoading(function(sender, url)
            print("onWebViewDidFinishLoading, url is ", url)
        end)
        webView:setOnDidFailLoading(function(sender, url)
            print("onWebViewDidFinishLoading, url is ", url)
        end)
        if device.platform ~= "windows" then
          webView:setBackgroundTransparent()
        end
        parent:addChild( webView )
        webView:reload()
    end

    print("end lua_to_plat:openWebViews")
    return webView
end

function UserPrivacyMediator:ctor(utype)  --type 1 用户协议 2 个人隐私
	UserPrivacyMediator.super.ctor(self, "UserPrivacyMediator")
	self.urltype = utype  --设置网页类型
    print("UserPrivacyMediator:ctor(utype)",self.urltype)
end

function UserPrivacyMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.START_LOGIN, 
	}
end

function UserPrivacyMediator:onRegister()
    print(" UserPrivacyMediator:onRegister")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    local ui = cc.CSLoader:createNode("hall_res/help/userprivacy.csb")  --设置UI的csb
	self:setViewComponent(ui)
    --local scene = platformFacade:retrieveMediator("HallMediator").scene 
    local scene = cc.Director:getInstance():getRunningScene() --获取要加载上的场景
	scene:addChild(self:getViewComponent()) --获取大厅的Mediator，加载这个公告场景s

    --背景
    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--背景

    --获取关闭按钮
    local btnClose = seekNodeByName(self.bgImg, "btn_close")
	if btnClose then
		btnClose:addClickEventListener(function()
            btnClose:setZoomScale(-0.1)
			platformFacade:removeMediator("UserPrivacyMediator")
		end)
	end

    --获取确定按钮
    local btnOK = seekNodeByName(self.bgImg, "btnOK")
	if btnOK then
       btnOK:addClickEventListener(function()
            btnOK:setZoomScale(-0.1)
            platformFacade:removeMediator("UserPrivacyMediator")
     end)
    end

    self.Panel_Custom = self.bgImg:getChildByName("Panel_Custom")
    self.Panel_Custom:removeAllChildren()

    local title = seekNodeByName(self.bgImg, "Img_title")

    print("展示网页")
    local size = self.Panel_Custom:getContentSize()
    --local testResult = lua_to_plat:testFunc()
    --print("testResult = ".. testResult)self.urltype
    if self.urltype == 1 then
      title:loadTexture("platform_res/agreement/title.png")
      -- print("self.urltype1:",self.urltype)
      self:openWebViews(self.Panel_Custom, UserAgreeUrl, nil, nil, size.width / 2, size.height / 2, size.width, size.height)
    else
      title:loadTexture("platform_res/help/title_person.png")
      -- print("self.urltype2:",self.urltype)
      self:openWebViews(self.Panel_Custom, UserPrivacyUrl, nil, nil, size.width / 2, size.height / 2, size.width, size.height)
    end
    
end

function UserPrivacyMediator:handleNotification(notification)
    print("UserPrivacyMediator:handleNotification")
    local name = notification:getName()
    local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    --local shopProxy = platformFacade:retrieveProxy("ShopProxy")
    if name == PlatformConstants.START_LOGOUT then
        platformFacade:removeMediator("UserPrivacyMediator")
    end
end

function UserPrivacyMediator:onRemove()
    print("UserPrivacyMediator:onRemove")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
	--platformFacade:removeCommand(PlatformConstants.START_GAMEHELPLAYER)

    self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

return UserPrivacyMediator
--endregion
