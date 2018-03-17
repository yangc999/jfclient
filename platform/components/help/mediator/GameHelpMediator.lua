--region *.lua
--Date
--游戏玩法帮助
local Mediator = cc.load("puremvc").Mediator
local GameHelpMediator = class("GameHelpMediator", Mediator)
local GameHelpProxy = import("..proxy.GameHelpProxy")

--构造游戏帮助数据
function GameHelpMediator:buildHelpList()
   local gameHelpList = {}
   local help1 = {id="1",title="转转麻将", url = "http://bzwysrgx.oss-cn-shenzhen.aliyuncs.com/yshj/apk/site/help.htm"}
   local help2 = {id="2", title = "南昌麻将", url = "http://bzwysrgx.oss-cn-shenzhen.aliyuncs.com/yshj/apk/site/ComQuestion.htm"}
   local help3 = {id="3", title = "用户协议", url = "http://bzwysrgx.oss-cn-shenzhen.aliyuncs.com/yshj/apk/site/UserAgreement.htm"}
   local help4 = {id="4", title = "个人隐私", url = "http://bzwysrgx.oss-cn-shenzhen.aliyuncs.com/yshj/apk/site/PrivacyPolicy.htm"}
   
   table.insert(gameHelpList, help1)
  -- table.insert(gameHelpList, help2)
   --table.insert(gameHelpList, help3)
   --table.insert(gameHelpList, help4)

   return gameHelpList
end

-- 使用 cocos2dx - 3.x 版本的 WebView 控件
function GameHelpMediator:openWebViews(parent, url, file_path, text, x, y, width, height)
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

function GameHelpMediator:ctor()
    GameHelpMediator.super.ctor(self, "GameHelpMediator")
    --self.root = root
    self.oldItem = nil
    self.curIndex = -1
end

function GameHelpMediator:listNotificationInterests()
    local PlatformConstants = cc.exports.PlatformConstants
	return {
        PlatformConstants.START_LOGOUT,
	}
end

function GameHelpMediator:onRegister()
    print("GameHelpMediator:onRegister")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    --platformFacade:registerCommand(PlatformConstants.REQUEST_ANNOUNCELIST, cc.exports.RequestAnnounceListCommand)
    local ui = cc.CSLoader:createNode("hall_res/help/gameHelpLayer.csb")  --设置UI的csb
	self:setViewComponent(ui)
    local scene = platformFacade:retrieveMediator("HallMediator").scene --获取要加载上的场景
	scene:addChild(self:getViewComponent()) --获取大厅的Mediator，加载这个公告场景s

    --背景
    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--背景

    --获取关闭按钮
    local btnClose = seekNodeByName(self.bgImg, "btn_close")
	if btnClose then
		btnClose:addClickEventListener(function()
            btnClose:setZoomScale(-0.1)
			platformFacade:removeMediator("GameHelpMediator")
		end)
	end
    --图片容器
    self.Panel_Help = self.bgImg:getChildByName("PanelHelp")
    self.Panel_Help:removeAllChildren()
    self.Panel_Help:setVisible(true)

    --列表模板
    self.list = seekNodeByName(self.bgImg, "ListView")
	self.list:setScrollBarEnabled(false)
    self.list:setItemsMargin(1) --列表项之间的间隔
    self.selTemplate = seekNodeByName(ui, "listUnit")  --公告列表模板,只是用来复制当模板用
    self.selTemplate:setVisible(false)

    self:showGameHelpList()  --显示列表
end

function GameHelpMediator:showGameHelpList()
   print("GameHelpMediator:showGameHelpList")
   self.list:removeAllChildren()
   self.Panel_Help:removeAllChildren()

   --local annItem   --一个列表项
   local annSelItem --列表选中项

   local gameHelpList = self:buildHelpList()
  -- dump(gameHelpList, "self:buildHelpList()")
   --遍历所有的帮助列表
   print("GameHelpMediator:遍历所有的公告列表")
   self.list:setVisible(true)
   for _,gameHelp in ipairs(gameHelpList) do
        --dump(gameHelp, "gameHelp")
        local annItem = self.selTemplate:clone()
        --dump(annItem, "annItem")
        annItem:setVisible(true)
        local txtAnn = seekNodeByName(annItem,"Text_Ann")
        txtAnn:setTextHorizontalAlignment(1)  --居中对齐
        txtAnn:setString(gameHelp.title)
        txtAnn:enableOutline(cc.c3b(84,75,95), 1)
        self.list:pushBackCustomItem(annItem)  --列表里加上列表项
        --添加点击事件  
        annItem:addClickEventListener(function()
            local index = self.list:getCurSelectedIndex()
            if self.curIndex == index then
                return  --重复点击同一项，不做任何处理
            end
            self.curIndex = index
            local selItem = self.list:getItem(index)
            if selItem then
                selItem:loadTexture("platform_res/common/btn-yellow.png")  --设置为选中图标
                local txtTitle = seekNodeByName(selItem,"Text_Ann")
                txtTitle:enableOutline(cc.c3b(173, 35, 0), 1)  --设置描边颜色
            end
             --如果有上次点击过的项目，把它恢复为非选中状态
            if self.oldItem~=nil then
                self.oldItem:loadTexture("platform_res/common/btn-blue.png") --旧项目为非选中状态
                local txtTitle = seekNodeByName(self.oldItem,"Text_Ann")
                txtTitle:enableOutline(cc.c3b(84,75,95), 1)
            end
            --处理完毕，当前选中项为老项目
            self.oldItem = selItem
            --显示出网页
            local size = self.Panel_Help:getContentSize()
            self.Panel_Help:setVisible(true)
            local url = gameHelp.url
            print("help url:" .. url)
            self:openWebViews(self.Panel_Help, url, nil, nil, size.width / 2, size.height / 2, size.width, size.height)
        end)
   end  --end for
   --默认第一个项目为选中状态
    local firstItem = self.list:getItem(0)
    if firstItem~=nil then
      firstItem:loadTexture("platform_res/common/btn-yellow.png")
      self.oldItem = firstItem
      self.curIndex=firstItem
      local txtTitle = seekNodeByName(firstItem,"Text_Ann")
      txtTitle:enableOutline(cc.c3b(173, 35, 0), 1)  --设置描边颜色
    end
    --默认显示第一个网页的情况
    local size = self.Panel_Help:getContentSize()
    self.Panel_Help:setVisible(true)
    local urlFirst = gameHelpList[1].url
    self:openWebViews(self.Panel_Help, urlFirst, nil, nil, size.width / 2, size.height / 2, size.width, size.height)
end

function GameHelpMediator:handleNotification(notification)
    print("GameHelpMediator:handleNotification")
    local name = notification:getName()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	if name == PlatformConstants.START_LOGOUT then
		platformFacade:removeMediator("GameHelpMediator")
        --platformFacade:removeProxy("AnnounceProxy")
    end
end

function GameHelpMediator:onRemove()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
	--platformFacade:removeCommand(PlatformConstants.REQUEST_ANNOUNCELIST)
    --platformFacade:removeCommand(PlatformConstants.REQUEST_ANNOUNCEBYID)

    self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)

end

return GameHelpMediator
--endregion
