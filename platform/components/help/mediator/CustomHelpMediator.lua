--region *.lua
--Date
--客服常见问题帮助UI
local Mediator = cc.load("puremvc").Mediator
local CustomHelpMediator = class("CustomHelpMediator", Mediator)
local HelpUrl = "http://bzwysrgx.oss-cn-shenzhen.aliyuncs.com/yshj/apk/site/ComQuestion.htm"
--local GameHelpProxy = import("..proxy.GameHelpProxy")

-- 使用 cocos2dx - 3.x 版本的 WebView 控件
function CustomHelpMediator:openWebViews(parent, url, file_path, text, x, y, width, height)
    print("start openWebViews")
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

    print("end openWebViews")
    return webView
end

function CustomHelpMediator:ctor()
    CustomHelpMediator.super.ctor(self, "CustomHelpMediator")
    --self.root = root
end

function CustomHelpMediator:listNotificationInterests()
    local PlatformConstants = cc.exports.PlatformConstants
	return {
        PlatformConstants.START_LOGOUT,
	}
end

function CustomHelpMediator:onRegister()
    print("CustomHelpMediator:onRegister")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local load = platformFacade:retrieveProxy("LoadProxy")

    local ui = cc.CSLoader:createNode("hall_res/help/helpLayer.csb")  --设置UI的csb
	self:setViewComponent(ui)
    local scene = platformFacade:retrieveMediator("HallMediator").scene --获取要加载上的场景
	scene:addChild(self:getViewComponent()) --获取大厅的Mediator，加载这个公告场景

     --背景
    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--背景
    --获取关闭按钮
    local btnClose = seekNodeByName(self.bgImg, "btn_close")
	if btnClose then
		btnClose:addClickEventListener(function()
            btnClose:setZoomScale(-0.1)
			platformFacade:removeMediator("CustomHelpMediator")
		end)
	end

    --网页容器
    self.Panel_Help = self.bgImg:getChildByName("Panel_Content")
    self.Panel_Help:removeAllChildren()
    self.Panel_Help:setVisible(false)
    --self.Panel_Help:setBackGroundColorType(LAYOUT_COLOR_NONE)
    --self.Panel_Help:setBackgroundTransparent()
    --列表模板
    self.list = seekNodeByName(self.bgImg, "ListView")
	self.list:setScrollBarEnabled(false)
    self.list:setItemsMargin(1) --列表项之间的间隔
    self.selTemplate = seekNodeByName(ui, "imgTemple")  --公告列表模板,只是用来复制当模板用
    self.selTemplate:setVisible(false)

    --联系电话
    self.txtPhone = seekNodeByName(ui, "txtPhone")
    self.txtPhone:setTextHorizontalAlignment(0)
    local strPhone = load:getData().officialPhoneNum
    print("Phone:" .. strPhone)
    self.txtPhone:setString(strPhone)
    --官方微信
    self.txtWeiXin = seekNodeByName(ui, "txtWeiXin")
    self.txtWeiXin:setTextHorizontalAlignment(0)
    local strWeiXin = load:getData().officialWxAccount
    print("WeiXin:" .. strWeiXin)
    self.txtWeiXin:setString(strWeiXin)

    self:showCustomHelpList()  --显示列表
    local size = self.Panel_Help:getContentSize()
    dump(size, "self.Panel_Help size:")
    self.Panel_Help:setVisible(true)
    self:openWebViews(self.Panel_Help, HelpUrl, nil, nil, size.width / 2, size.height / 2, size.width, size.height)
end

--显示帮助列表
function CustomHelpMediator:showCustomHelpList()
    print("CustomHelpMediator:showCustomHelpList")
    self.list:removeAllChildren()
    local annItem = self.selTemplate:clone()
    annItem:setVisible(true)
    local txtAnn = seekNodeByName(annItem,"Text_Ann")
    txtAnn:setTextHorizontalAlignment(1)  --居中对齐
    --txtAnn:setString(gameHelp.title)
    txtAnn:enableOutline(cc.c3b(173, 35, 0), 1)
    self.list:pushBackCustomItem(annItem)  --列表里加上列表项

    --添加点击事件  
    annItem:addClickEventListener(function()
        local size = self.Panel_Help:getContentSize()
        local url = HelpUrl
        print("help url:" .. url)
        self.Panel_Help:setVisible(true)
        self:openWebViews(self.Panel_Help, url, nil, nil, size.width / 2, size.height / 2, size.width, size.height)
    end)
end

function CustomHelpMediator:handleNotification(notification)
    print("CustomHelpMediator:handleNotification")
    local name = notification:getName()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	if name == PlatformConstants.START_LOGOUT then
		platformFacade:removeMediator("CustomHelpMediator")
        --platformFacade:removeProxy("AnnounceProxy")
    end
end

function CustomHelpMediator:onRemove()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
	--platformFacade:removeCommand(PlatformConstants.REQUEST_ANNOUNCELIST)
    --platformFacade:removeCommand(PlatformConstants.REQUEST_ANNOUNCEBYID)

    self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)

end

return CustomHelpMediator

--endregion
