--region *.lua
--Date
--用户协议UI

local Mediator = cc.load("puremvc").Mediator
--local lua_to_plat = require('components/Tools/lua_to_plat.lua')

local AgreementMediator = class("AgreementMediator", Mediator)

local AgreeUrl = "http://bzwysrgx.oss-cn-shenzhen.aliyuncs.com/yshj/apk/site/UserAgreement.htm"

-- 使用 cocos2dx - 3.x 版本的 WebView 控件
function AgreementMediator:openWebViews(parent, url, file_path, text, x, y, width, height)
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

function AgreementMediator:ctor(root)
	AgreementMediator.super.ctor(self, "AgreementMediator")
	self.root = root  --设置场景
end

function AgreementMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {}
end

function AgreementMediator:onRegister()
    print(" AgreementMediator:onRegister")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    platformFacade:registerCommand(PlatformConstants.START_LOGIN, cc.exports.StartLoginCommand)

    local csbPath = "hall_res/agreement/AgreementLayer.csb"
	local ui = cc.CSLoader:createNode(csbPath)
	
	--ui:setPosition(display.cx, display.cy)
    --ui:setPosition(0, 0)
	self:setViewComponent(ui)
    self.root:addChild(self:getViewComponent())
	--self.scene:addChild(self:getViewComponent())

    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")        --获取背景

    --local chkAgree = seekNodeByName(self.bgImg, "chkAgree")  --勾选按钮
	--获取关闭按钮
    local btnClose = seekNodeByName(self.bgImg, "btn_close")
	if btnClose then	
		btnClose:addClickEventListener(function()
            btnClose:setZoomScale(-0.1)
             --退出游戏
            --cc.Director:getInstance():endToLua()
            platformFacade:removeMediator("AgreementMediator")
		end)
	end

    --获取确定按钮
    local btnOK = seekNodeByName(self.bgImg, "btnOK")
	if btnOK then
		
		btnOK:addClickEventListener(function()
            btnOK:setZoomScale(-0.1)
             --退出游戏
            --cc.Director:getInstance():endToLua()
            local bAgree = true
               
            if bAgree then --玩家点同意
               print("进入Login")
               cc.UserDefault:getInstance():setStringForKey("useragree", "true")  --记录下用户的选项，设置保存在本地
               platformFacade:sendNotification(PlatformConstants.SET_USERAGREE)  --发送消息，用户同意用户协议
               platformFacade:removeMediator("AgreementMediator")  --关掉自身
            else
               cc.UserDefault:getInstance():setStringForKey("useragree", "false")
              --退出游戏
              cc.Director:getInstance():endToLua()
            end
		end)
	end

    self.Panel_Custom = self.bgImg:getChildByName("Panel_Custom")
    self.Panel_Custom:removeAllChildren()
    print("展示网页")
    local size = self.Panel_Custom:getContentSize()
    --local testResult = lua_to_plat:testFunc()
    --print("testResult = ".. testResult)
    self:openWebViews(self.Panel_Custom, AgreeUrl, nil, nil, size.width / 2, size.height / 2, size.width, size.height)
end

function AgreementMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    platformFacade:removeCommand(PlatformConstants.START_LOGIN)

	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

return AgreementMediator
--endregion
