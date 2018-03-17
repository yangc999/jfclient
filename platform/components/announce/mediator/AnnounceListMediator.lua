--region *.lua
--Date 2017.11.2
--Author 杨亦松
--系统公告
local Mediator = cc.load("puremvc").Mediator
local AnnounceListMediator = class("AnnounceListMediator", Mediator)
local PANEL_WIDTH = 690
local PANEL_HEIGHT = 470
--local NetSprite = import(".NetSprite")

--加载网络图片
--[[
function AnnounceListMediator:openNetImg(url, parent)
    local netImg = NetSprite.new(url)
    parent:addChild(netImg)
end
--]]


-- 使用 cocos2dx - 3.x 版本的 WebView 控件
function AnnounceListMediator:openWebViews(parent, url, file_path, text, x, y, width, height)
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

--求带中文字符串的长度 如“你好World”返回7
function AnnounceListMediator:getWordLen(input)
    local len  = string.len(input)
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

function AnnounceListMediator:ctor(root)
	AnnounceListMediator.super.ctor(self, "AnnounceListMediator")
	self.root = root
    self.annId = -1                   --当前公告ID
    self.textLineCount = 1        --当前公告总行数
    self.textVec = {}               --所有行的文字(其value也为一个table, key分别为text、Type(Type:0表示标题, 1表示正文))
    self.curTitle = ""                 --当前公告标题
    self.curContent = ""           --当前公告内容
    self.oldItem = nil                --上次选中的公告项
    self.curIndex = 0               --当前选中的列表index 0是第一个列表项
    self.orginZorder = 0
end

function AnnounceListMediator:listNotificationInterests()
    local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.SHOW_ANNOUNCELIST, 
        PlatformConstants.START_LOGOUT,
        PlatformConstants.SHOW_ANNOUNCECONTENT, 
        PlatformConstants.REQUEST_ANNOUNCEBYID,
	}
end

function AnnounceListMediator:onRegister()
    print("AnnounceListMediator:onRegister")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    platformFacade:registerCommand(PlatformConstants.REQUEST_ANNOUNCELIST, cc.exports.RequestAnnounceListCommand)
    platformFacade:registerCommand(PlatformConstants.REQUEST_ANNOUNCEBYID, cc.exports.RequestAnnounceByIDCommand)  --根据ID显示公告

    local ui = cc.CSLoader:createNode("hall_res/activity/activityLayer.csb")  --设置UI的csb
	self:setViewComponent(ui)
    local scene = platformFacade:retrieveMediator("HallMediator").scene --获取要加载上的场景
	scene:addChild(self:getViewComponent()) --获取大厅的Mediator，加载这个公告场景s

    --公告栏的滚动列表
    --self.bgImg = self:getChildByName("Panel_1"):getChildByName("bg") --背景
    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--背景
    self.list = seekNodeByName(self.bgImg, "ListView")
	self.list:setScrollBarEnabled(false)
    self.list:setItemsMargin(1) --列表项之间的间隔
    self.selTemplate = seekNodeByName(ui, "Selected_ListUnit")  --公告列表模板,只是用来复制当模板用
    self.unSelTemplate = seekNodeByName(ui, "UnSelected_ListUnit") --公告列表模板，显示未选中的状态

    self.scrollview = seekNodeByName(self.bgImg,"ScrollView_1")  --获取公告内容显示的滚动区域

    --获取关闭按钮
    local btnClose = seekNodeByName(self.bgImg, "btn_close")
	if btnClose then
		btnClose:addClickEventListener(function()
            btnClose:setZoomScale(-0.1)
			platformFacade:removeMediator("AnnounceListMediator")
		end)
	end

    --大厅启动时请求公告列表
    platformFacade:sendNotification(PlatformConstants.REQUEST_ANNOUNCELIST)

    --图片容器
    self.Panel_Custom = self.bgImg:getChildByName("Panel_Custom")
    self.Panel_Custom:removeAllChildren()
    self.Panel_Custom:setVisible(false)
    --self.Panel_Custom:setBackGroundColorType(LAYOUT_COLOR_NONE)
    --self.Panel_Custom:setBackgroundTransparent()
    self.orginZorder = self.Panel_Custom:getLocalZOrder()
    --print("AnnounceListMediator:End OnRegister")
end

function AnnounceListMediator:onRemove()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
	platformFacade:removeCommand(PlatformConstants.REQUEST_ANNOUNCELIST)
    platformFacade:removeCommand(PlatformConstants.REQUEST_ANNOUNCEBYID)

    self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)

end


--显示公告列表
function AnnounceListMediator:showAnnounceList()
    print("响应显示公告列表消息")
    -- local lenstr1 = self:getWordLen("呆呆座的小宇宙")
    --print("呆呆座的小宇宙 len:" .. lenstr1)
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local announceProxy = platformFacade:retrieveProxy("AnnounceProxy")  --公告数据模型
    -- local proxy = platformFacade:retrieveProxy("AnnounceProxy") 
    local anounceList = announceProxy:getData().anlist  --获取公告列表数据
    --dump(anounceList, "UI中公告列表:")
    --先清除所有的孩子结点
    self.list:removeAllChildren()
    local annItem   --公告列表项
    local annSelItem --公告列表选中项
    local annId = -1    --公告ID
    local annTitle = "" --公告标题
    --遍历所有的公告列表
    print("AnnounceListMediator:遍历所有的公告列表")
    print("anounceList length:" .. #anounceList)
    dump(anounceList, "公告列表")
    for _,announce in ipairs(anounceList) do
                 
                --dump(announce, "公告项:")
                annId = announce.id  --公告id
                annTitle = announce.title --announce.title

                annItem = self.unSelTemplate:clone()
                annSelItem = self.selTemplate:clone()
		        annItem:setVisible(true)
                annSelItem:setVisible(true)
                --列表上的文字
                local title = seekNodeByName(annItem,"Text_Ann")
                --设置居中对齐，0：左对齐，1：居中， 2：右对齐
                title:setTextHorizontalAlignment(1)

                title:setString(annTitle)
                print("annTitle:" .. annTitle)
                self.list:pushBackCustomItem(annItem)  --列表里加上列表项

                annItem:addClickEventListener(function()
                    print("click 公告 id:" .. announce.id)

                    announceProxy:getData().curId = announce.id
                    announceProxy:getData().curTitle = announce.title

                    local index = self.list:getCurSelectedIndex()
                    if self.curIndex == index then
                        return  --重复点击同一项，不做任何处理
                    end
                    self.curIndex = index
                    print("当前选中的Index:" .. index)
                    local selItem = self.list:getItem(index)
                    selItem:loadTexture("platform_res/promotion/btn-yellow.png")  --设置为选中图标
                    local txtTitle = seekNodeByName(selItem,"Text_Ann")
                    txtTitle:enableOutline(cc.c3b(173, 35, 0), 2)  --设置描边颜色
                    --查找缓存中是否有此公告内容
                    local anDetailList = announceProxy:getData().anConlist
                    dump(anDetailList, "anDetailList")
                    local bFound = false
                    for _,v in ipairs(anDetailList) do
				         if v.id==announce.id then --找到了
                             dump(v, "anDetailList . v")
				             local annContent = v.content.body
                             local showType = v.content.textType
                             print("annContent:" .. annContent)
                             print("showType:" .. showType)
                             self.curContent = annContent
                             self:showAnnounceConntent(annContent, showType) --直接显示
                             bFound = true
                             break  
				         end
			        end
                    if bFound == false then
                       platformFacade:sendNotification(PlatformConstants.REQUEST_ANNOUNCEBYID, announce.id)   --显示公告内容
                    end
			        
                    
                    --如果有上次点击过的项目，把它恢复为非选中状态
                    if self.oldItem~=nil then
                      self.oldItem:loadTexture("platform_res/promotion/btn-blue.png") --旧项目为非选中状态
                      local txtTitle = seekNodeByName(self.oldItem,"Text_Ann")
                      txtTitle:enableOutline(cc.c3b(84,75,95), 2)
                    end
                    --处理完毕，当前选中项为老项目
                    self.oldItem = selItem
		        end)
     end --end for

     --默认第一个项目为选中状态
     local firstItem = self.list:getItem(0)
     if firstItem~=nil then
       firstItem:loadTexture("platform_res/promotion/btn-yellow.png")
       local txtTitle = seekNodeByName(firstItem,"Text_Ann")
       txtTitle:enableOutline(cc.c3b(173, 35, 0), 2)  --设置描边颜色
       self.oldItem = firstItem
     end
    
     --默认显示第一个公告
     if #anounceList >= 1 then
           local anounce = anounceList[1]
           if anounce ~= nil then
              platformFacade:sendNotification(PlatformConstants.REQUEST_ANNOUNCEBYID, anounce.id)   --显示公告内容
              announceProxy:getData().curId = anounce.id
              announceProxy:getData().curTitle = anounce.title
           end
     else
             self:showAnnounceConntent("暂无公告",0)
     end
end

--分析公告内容
function AnnounceListMediator:analysisNotice(m_content)
    print("AnnounceListMediator:analysisNotice")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local announceProxy = platformFacade:retrieveProxy("AnnounceProxy")  --公告数据模型
    self.textLineCount = 1       --当前公告总行数
    self.textVec = {}               --所有行的文字(其value也为一个table, key分别为text、Type(Type:0表示标题, 1表示正文))
    --分析公告内容, m_content每行90个字符， 最后分析成多少行：linecount, 解析成一个vec：textVec
    local conLen = self:getWordLen(m_content)
    if conLen>26 then --公告长度超过一行
       m_content = "   " .. m_content   -- 为了排版美观前面加上两个空格
    end
     local _, linecount, textVec = self:autoFormatString(m_content, 80)  --将公告内容以80像素长度分段组织处理,存入textVec列表中
     --print("linecount:" .. linecount)
     --dump(textVec, "textVec")
     
     self.annId = announceProxy:getData().curId
     --print("announceProxy.curId:" .. self.annId)
     self.curTitle = announceProxy:getData().curTitle
     --print("announceProxy.curTitle:" .. self.curTitle)
    --先插入标题(Type:0表示标题, 1表示正文)
    if(self.curTitle ~= "") then
       table.insert(self.textVec, {text = tostring(self.curTitle), Type = 0})       
       self.textLineCount = linecount+1     --加1表示标题
    else
       self.textLineCount = linecount
    end

    --填充文本
    for k1, v1 in pairs(textVec) do
        if v1 ~= nil then
            table.insert(self.textVec, {text = v1, Type = 1})
        end
    end
    --dump(self.textVec, "self.textVec:")
end

--显示公告内容
function AnnounceListMediator:showAnnounceConntent(m_content, conType)
    print("AnnounceListMediator:showAnnounceConntent:" .. m_content)

    if m_content==nil then
       return
    end
    if conType == 0 then --类型为文本内容
         print("now show 文本类型")
         self.Panel_Custom:setVisible(false)
         self.Panel_Custom:removeAllChildren()
         self.scrollview:removeAllChildren() --先删掉以前所有的内容
         self:analysisNotice(m_content)  --解析文本成列表形式
         local size = self.scrollview:getContentSize()
         self.scrollview:setInnerContainerSize(cc.size(size.width, size.height+200))  --公告时内部的长度应该变长，以适应更多的消息

         local g_promotion_content_color_new = cc.c3b(107,125,189)  --内容颜色
         local g_promotion_title_color_new = cc.c3b(71,88,202)            --标题颜色
         --print("公告总行数:" .. self.textLineCount)

         for i = 1,self.textLineCount do
             local richText = ccui.RichText:create()
             richText:ignoreContentAdaptWithSize(true) 
             richText:setAnchorPoint(cc.p(0.0,1.0))

            -- dump(self.textVec[i])
             if self.textVec[i] ~= nil and self.textVec[i].text ~= nil then
                 local idx = 1
                 --local desc = "呆呆座的小宇宙"
                 local desc = self.textVec[i].text 
                 local color = cc.c3b(199,222,253)
                 local textFont = "宋体"
                 local textSize = 20
                 local rowSpace = 40  --行间距

                 --标题
                if self.textVec[i].Type == 0 then
                    --print("Type == 0")
                    color = cc.c3b(255,255,255)   --g_promotion_title_color_new
                    textFont = "font/fangzhenyuanstatic.ttf"
                    textSize = 34   
                
                else --正文
                   -- print("Type == 1")
                    color = cc.c3b(196,221,254)--g_promotion_content_color_new  cc.c3b(107,125,189)
                    textFont = "font/fangzhenyuanstatic.ttf"
                    textSize = 24
                end

                 local element = ccui.RichElementText:create(idx, color, 255, desc, textFont, textSize)
                 richText:pushBackElement(element)
                 if i==1 then
                    richText:setPosition(25, self.scrollview:getInnerContainerSize().height-(i-1) * rowSpace - 30)  --因为第一行是公告标题，第二行是正文开始，所以第一行距离第二行要远点
                 else
                    richText:setPosition(25, self.scrollview:getInnerContainerSize().height-(i-1) * rowSpace - 50)
                 end

            
                  --25是文字距左边边界的长度
                richText:formatText()
    
                self.scrollview:addChild(richText)
             end
        
         end
         self.scrollview:scrollToTop(0.1,false)
     elseif conType == 1 then  --图片类型
         print("now show 图片类型")
         self.Panel_Custom:setVisible(true)
         self.Panel_Custom:removeAllChildren()
         self.scrollview:removeAllChildren()
         local panOrder = self.Panel_Custom:getLocalZOrder()
         local scrolOrder = self.scrollview:getLocalZOrder()

         --self.scrollview:setPosition(cc.p(300, 53))  --重置位置
         --local size = self.Panel_Custom:getContentSize()
         local size = cc.size(PANEL_WIDTH, PANEL_HEIGHT)
         self:openWebViews(self.Panel_Custom, m_content, nil, nil, size.width / 2, size.height / 2, size.width, size.height)
         --self:openNetImg("http://192.168.0.172:8080/0.png", self.Panel_Custom)
     end
     print("End AnnounceListMediator:showAnnounceConntent")
end

function AnnounceListMediator:handleNotification(notification)
    print("AnnounceListMediator:handleNotification")
    local name = notification:getName()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	if name == PlatformConstants.START_LOGOUT then
		platformFacade:removeMediator("AnnounceMediator")
        platformFacade:removeProxy("AnnounceProxy")
    elseif name == PlatformConstants.SHOW_ANNOUNCELIST then
         self:showAnnounceList()  --显示公告列表
    elseif name == PlatformConstants.REQUEST_ANNOUNCEBYID then
         self.annId = notification.getBody
    elseif name == PlatformConstants.SHOW_ANNOUNCECONTENT then
        local notice = notification:getBody()
        local annContent = notice.body
        local showType = notice.textType
        print("annContent:" .. annContent)
        print("showType:" .. showType)
        self.curContent = annContent
        --print("handdle notification announce content:" .. annContent)
        self:showAnnounceConntent(annContent, showType)
	end
end

--序列化字符串，将长长的公告信息分行存入textVec列表中  length 每行最大长度
function AnnounceListMediator:autoFormatString(instr, length)
    print("start PromotionLayerNew:autoFormatString")
    if instr == '' or length <= 0 then
        return instr, 1, {""}
    end

    local beginPos = 0
    -- 字符串的初始位置
    local resultStr = ''
    -- 返回的字符串
    local lineCount = 0
    local str_vec = { }
    -- 创建一个字符串类型的顺序容器

    while true do
        local offset = 0
        local dropping = string.byte(instr, beginPos + length)
        local dropping2 = string.byte(instr, beginPos + length + 1)
        if dropping then
            if dropping >= 128 and dropping < 192 then
                -- 汉字
                if dropping2 and dropping2 >= 128 and dropping2 < 192 then
                    offset = 1
                end
            else
                if dropping2 and dropping2 >= 128 and dropping2 < 192 then
                    offset = 2
                end
            end
        end

        table.insert(str_vec, string.sub(instr, beginPos + 1, beginPos + length + offset))
        lineCount = lineCount + 1
        if beginPos + length + offset >= string.len(instr) then
            break
        else
            beginPos = beginPos + length + offset
        end
    end

    for index = 1, #str_vec do
        resultStr = resultStr .. str_vec[index] .. "\n"
    end
    string.sub(resultStr, 0, string.len(resultStr) -1)
    print("end PromotionLayerNew:autoFormatString")
    return resultStr, lineCount, str_vec
end

return AnnounceListMediator

--endregion
