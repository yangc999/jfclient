--region *.lua
--Date
--战绩页面
local Mediator = cc.load("puremvc").Mediator
local MatchRecordsMediator = class("MatchRecordsMediator", Mediator)

function MatchRecordsMediator:ctor()
    MatchRecordsMediator.super.ctor(self, "MatchRecordsMediator")
    self.list = nil
end	

function MatchRecordsMediator:listNotificationInterests()
	  local PlatformConstants = cc.exports.PlatformConstants
	  return{
		    PlatformConstants.START_LOGOUT,
        PlatformConstants.UPDATE_MATCHRECORDNUM,
        PlatformConstants.UPDATE_MATCHRECORDLIST,
        PlatformConstants.GET_MATCHRECORDDETAIL,
	  }
end

--返回纪录列表index的最小和最大值
function MatchRecordsMediator:getMinMaxIndex(vecIndex)
    local len = #vecIndex

    if len==0 then
        return 0,0
    else
        return vecIndex[1], vecIndex[len]
    end
end

function MatchRecordsMediator:onRegister()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
    local matchRecordProxy = platformFacade:retrieveProxy("MatchRecordsProxy")
    
	  platformFacade:registerCommand(PlatformConstants.REQUEST_MATCHRECORDNUM, cc.exports.RequestRecordsNumCommand) --请求战绩总数
    platformFacade:registerCommand(PlatformConstants.REQUEST_MATCHRECORDLIST, cc.exports.RequestRecordListCommand) --请求战绩列表
    platformFacade:registerCommand(PlatformConstants.REQUEST_MATCHRECORDDETAIL, cc.exports.RequestRecordDetailCommand) --请求战局详情列表
    platformFacade:registerCommand(PlatformConstants.START_MATCHRECORDDETAIL, cc.exports.StartMatchRecordDetailCommand) --启动战绩详情页面

  	local ui = cc.CSLoader:createNode("hall_res/openRoom/matchRecordLayer.csb")
  	self:setViewComponent(ui)
  	local scene = platformFacade:retrieveMediator("HallMediator").scene
  	scene:addChild(self:getViewComponent())

    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--背景
    --获取关闭按钮
    local btnClose = seekNodeByName(self.bgImg, "btn_close")
	  if btnClose then
    		btnClose:addClickEventListener(function()
            btnClose:setZoomScale(-0.1)
    			  platformFacade:removeMediator("MatchRecordsMediator")
    		end)
  	end

    --获取查看他人回放按钮
    local btnViewOther = seekNodeByName(self.bgImg, "btnSeeReplay")
  	if btnViewOther then
    		btnViewOther:addClickEventListener(function()
                btnViewOther:setZoomScale(-0.1)
    			--platformFacade:removeMediator("MatchRecordsMediator")
                platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX, "功能在开发中...")
    		end)
  	end
    
    self.usrTemplate = seekNodeByName(ui, "imgTemplate")
    self.usrTemplate:setVisible(false)

    self.list = seekNodeByName(ui, "ListView") --列表框
    self.list:setItemsMargin(1)
    --先清除所有的孩子结点
    self.list:removeAllChildren()

    --listView的滚动事件
    local function scrollViewEvent(sender, evenType)
        if evenType == ccui.ScrollviewEventType.scrollToBottom then --滚动到底  scrollToBottom
            print("SCROLL_TO_BOTTOM")
            self:showNextPage()
            self.list:scrollToBottom(0.1, false)  --自动滚到底
        elseif evenType ==  ccui.ScrollviewEventType.scrollToTop then --滚动到头
            print("SCROLL_TO_TOP")
            self:showPrePage()
            self.list:scrollToTop(0.1, false)
        end
    end
    --listView添加滚动事件
    self.list:addScrollViewEventListener(scrollViewEvent)
    print("请求战绩总数")
    platformFacade:sendNotification(PlatformConstants.REQUEST_MATCHRECORDNUM) --请求抽奖总数
end

function MatchRecordsMediator:showPrePage()
    print("MatchRecordsMediator:showPrePage")

    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local matchRecordProxy = platformFacade:retrieveProxy("MatchRecordsProxy")
    local bScrollTop = matchRecordProxy:getData().bScrollListTop --是否滚到最顶

    if bScrollTop==true then
       return
    end

    local numRecords = matchRecordProxy:getData().nRecordNum  --返回纪录总数
    print("record nums:" .. numRecords)
    if numRecords<=0 then  --纪录数小于0，直接返回
        matchRecordProxy:getData().bScrollListTop = false
        return
    end
    
    local minIndex = matchRecordProxy:getData().nMinIndex
    local maxIndex = matchRecordProxy:getData().nMaxIndex
    print("求最小和最大索引")
    print("minIndex:" .. minIndex)
    print("maxIndex:" .. maxIndex)

    local lenVec = maxIndex - minIndex
    if lenVec<=0 then
        print("战绩纪录数小于0")
        matchRecordProxy:getData().bScrollListBottom = false --设定不要重复显示
        return
    end

    local lenVec = maxIndex - minIndex  --当前无纪录，直接返回
    if lenVec<=0 then
        matchRecordProxy:getData().bScrollListTop = false
        return
    end
    --获取当前最小和最大的索引下标
    if minIndex<=0 then
        print("已经是首页")
        matchRecordProxy:getData().bScrollListTop = false
        return
    end

    matchRecordProxy:getData().bScrollListTop = true --设定不要重复显示

    print("minIndex = ".. minIndex .. " maxIndex = " .. maxIndex)
    local minIndex2 = minIndex - 10
    if minIndex2<=0 then  --求上一页的最小下标
        minIndex2 = 0
    end

    --取得现在要取得的最小和最大索引值
    local nowMinIndex = minIndex2
    local nowMaxIndex = minIndex-1
    print("要求的新最小最大下标")
    print("nowMinIndex :" .. nowMinIndex)
    print("nowMaxIndex:" .. nowMaxIndex)

    local vRecordList = matchRecordProxy:getData().vRecordList   --当前的战绩纪录
    local nLen = #vRecordList --取得当前的战绩纪录数

     if nowMinIndex>=0 then  --如果当前的长度比要取的最大索引值还大，就从旧数据中取
       print("从旧数据中取")
       matchRecordProxy:getData().nMinIndex = nowMinIndex
       matchRecordProxy:getData().nMaxIndex = nowMaxIndex
       --5秒之后，将变量重置回去，防止卡死
       performWithDelay( self:getViewComponent() , function()
         matchRecordProxy:getData().bScrollListTop = false
       end, 5)
       return
    end
   
    --dump(vecIndexNow, "Now ready get vecIndexList")
    local tIndexs = {min=nowMinIndex, max = nowMaxIndex}
    dump(tIndexs, "showPrePage indexMinMax")
    platformFacade:sendNotification(PlatformConstants.REQUEST_MATCHRECORDLIST,tIndexs) --请求战绩列表
	--5秒之后，将变量重置回去，防止卡死
    performWithDelay( self:getViewComponent() , function()
        matchRecordProxy:getData().bScrollListTop = false
    end, 5)
end

function MatchRecordsMediator:showNextPage()
    print("MatchRecordsMediator:showNextPage")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local matchRecordProxy = platformFacade:retrieveProxy("MatchRecordsProxy")
    local bScrollBottom = matchRecordProxy:getData().bScrollListBottom

    if bScrollBottom == true then
       print("self.bScrollBottom = true")
       return
    end

    local numRecords = matchRecordProxy:getData().nRecordNum  --返回纪录总数
    print("record nums:" .. numRecords)
    if numRecords<=0 then  --纪录数小于0，直接返回
        matchRecordProxy:getData().bScrollListBottom = false --设定不要重复显示
        return
    end
    --local vecIndexCur = matchRecordProxy:getData().vIndexList  --获取当前的纪录数组
    --dump(vecIndexCur, "current indexList")
    local minIndex = matchRecordProxy:getData().nMinIndex
    local maxIndex = matchRecordProxy:getData().nMaxIndex
    local lenVec = maxIndex - minIndex
    if lenVec<=0 then
        print("战绩纪录数小于0")
        matchRecordProxy:getData().bScrollListBottom = false --设定不要重复显示
        return
    end
   -- local minIndex,maxIndex = self:getMinMaxIndex(vecIndexCur)
    if maxIndex>= numRecords-1 then
        print("已经是在最尾页")
        matchRecordProxy:getData().bScrollListBottom = false --设定不要重复显示
        return
    end

    matchRecordProxy:getData().bScrollListBottom = true --设定不要重复显示

    print("minIndex = ".. minIndex .. " maxIndex = " .. maxIndex)
    --最下一页的最大index
    local maxIndex2 = maxIndex + 10
    if maxIndex2>=numRecords-1 then  --如果+10超过最大纪录数了，取最大纪录数为index下限
        maxIndex2 = numRecords-1
    end

    local vRecordList = matchRecordProxy:getData().vRecordList   --当前的战绩纪录
    local nLen = #vRecordList --取得当前的战绩纪录数
    --取得现在要取得的最小和最大索引值
    local nowMinIndex = maxIndex+1
    local nowMaxIndex = maxIndex2

    if nLen>=nowMaxIndex then  --如果当前的长度比要取的最大索引值还大，就从旧数据中取
       print("从旧数据中取")
       matchRecordProxy:getData().nMinIndex = nowMinIndex
       matchRecordProxy:getData().nMaxIndex = nowMaxIndex
       --5秒之后，将变量重置回去，防止卡死
       performWithDelay( self:getViewComponent() , function()
         matchRecordProxy:getData().bScrollListBottom = false
       end, 5)
       return
    end
    local tIndexs = {min=nowMinIndex, max = nowMaxIndex}
    dump(tIndexs, "showNextPage indexMinMax")
    platformFacade:sendNotification(PlatformConstants.REQUEST_MATCHRECORDLIST,tIndexs) --请求战绩列表

    --5秒之后，将变量重置回去，防止卡死
    performWithDelay( self:getViewComponent() , function()
        matchRecordProxy:getData().bScrollListBottom = false
    end, 5)

end

function MatchRecordsMediator:handleNotification(notification)
    local name = notification:getName()
    print("MatchRecordsMediator handleNotification=",name)
  	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
  	local PlatformConstants = cc.exports.PlatformConstants
    local body = notification:getBody()
    local matchRecordProxy = platformFacade:retrieveProxy("MatchRecordsProxy")
    if name == PlatformConstants.START_LOGOUT then
		    platformFacade:removeMediator("MatchRecordsMediator")
        --platformFacade:removeProxy("LotteryProxy")
    elseif name == PlatformConstants.UPDATE_MATCHRECORDNUM then
       if body == false then  --返回结果失败
          platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "服务器未返回数据")
       else  --请求发送战绩列表
          local num = matchRecordProxy:getData().nRecordNum
          if num == 0 then
            -- platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "您还没有相关的战绩")
             return
          end
          print("num = " .. num)
          local vecIndex = {}
          local len = 0
          if num<=10 then
            len = num
          else 
            len = 10
          end
          --只显示前10个
          for i=1,len do
               table.insert(vecIndex, i-1) 
          end
          matchRecordProxy:getData().vIndexList = vecIndex  --战绩纪录索引列表
          print("indexMinMax vecIndexLen=",#vecIndex)
          local minIndex,maxIndex = self:getMinMaxIndex(vecIndex)
          matchRecordProxy:getData().nMinIndex = minIndex
          matchRecordProxy:getData().nMaxIndex = maxIndex
          local tIndexs = {min=minIndex, max = maxIndex}
          dump(tIndexs, "indexMinMax")
          platformFacade:sendNotification(PlatformConstants.REQUEST_MATCHRECORDLIST,tIndexs) --请求战绩列表
       end
    elseif name == PlatformConstants.UPDATE_MATCHRECORDLIST then  --更新战绩列表
        matchRecordProxy:getData().bScrollListBottom = false --设定不要重复显示
        matchRecordProxy:getData().bScrollListTop = false --设定不要重复显示

        if body == false then  --返回结果失败
          platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "服务器未返回战绩列表数据")
        else
            self:showRecordList()
        end
    elseif name == PlatformConstants.GET_MATCHRECORDDETAIL then --显示战局详细信息
        if body == true then
           print("body = true")
           platformFacade:sendNotification(PlatformConstants.START_MATCHRECORDDETAIL)
        else
            platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "服务器未返回此房间战局详情数据")
        end
    end
end

function MatchRecordsMediator:showRecordList()
    print("MatchRecordsMediator:showRecordList")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	  local PlatformConstants = cc.exports.PlatformConstants
    local matchRecordProxy = platformFacade:retrieveProxy("MatchRecordsProxy")
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")
    local gameList = platformFacade:retrieveProxy("GameListProxy")  --游戏列表配置
    local vecRecord = matchRecordProxy:getData().vRecordList
    dump(vecRecord, "showRecordList 显示战绩列表数据")
    local min = matchRecordProxy:getData().nMinIndex+1
    local max = matchRecordProxy:getData().nMaxIndex+1
    -- local max = #vecRecord
    print("showRecordList min:" .. min)
    print("showRecordList max:" .. max)
    local userName = userinfo:getData().nickName  --用户名
    local roomKey = ""    --房间key
    local gameId = 0       --游戏id
    local gameName = "转转麻"   --游戏名
    local disTime = 0     --解散时间
    local strTime = ""
    local scoreChange = 0  --玩家得分
    local idx = 0       --索引
    local vecUserSums = {}   --房间用户战绩列表
    local annItem = nil
    local roomNo = ""
   -- for i=1,#vecRecord do
    for i = min, max do
        -- dump(vecRecord[i], "vecRecord[".. i .. "]")
        idx = vecRecord[i].iIndex  --index
        roomKey = vecRecord[i].sRoomKey --房间号码
        gameId = vecRecord[i].iGameID
        gameName = self:getGameNameById(gameId)  --获取游戏名
        roomNo = vecRecord[i].sRoomNo   --room No
        --print("gameName:" .. gameName)
        disTime = vecRecord[i].lDisMissTime
        -- print("disTime:" .. disTime)
       -- local time = os.time()
       -- print("os.time:" .. time)
        --strTime = os.date("%c", disTime/1000) --时间
        --local tTime = os.date("*t", disTime/1000)
        --local strDate = tostring(tTime.year) .. "-" .. tostring(tTime.month) .. "-" .. tostring(tTime.day) .. " " .. tostring(tTime.hour)..":"..tostring(tTime.min) 
        local strDate = tostring(os.date("%Y-%m-%d %H:%m", disTime/1000))
        vecUserSums = vecRecord[i].vecSumStands
        -- dump(vecUserSums, "vecUserSums")
        scoreChange = self:getUserScore(vecUserSums)

        annItem = self.usrTemplate:clone()
        if annItem== nil then
          return
        end
        annItem:setVisible(true)
        local txtNo = seekNodeByName(annItem, "txtNo") --索引
        txtNo:setString(tostring(idx+1))
        local txtUser = seekNodeByName(annItem, "txtUser") --用户名
        if userName==nil then
           print("服务器未返回用户昵称")
           userName = ""
        end
        if userName~="" then
           txtUser:setString(userName)
        end
        
        local imgScore = seekNodeByName(annItem, "imgScore")
        local txtScore = seekNodeByName(imgScore, "txtScore") --得分
        local strScore = ""
        if scoreChange>0 then
           strScore = "+"..tostring(scoreChange)
        elseif scoreChange<0 then
           strScore = "-" .. tostring(math.abs(scoreChange))
        else
           strScore = "0"
        end
        txtScore:setString(strScore)
        local txtRoomNo = seekNodeByName(annItem, "txtRoomNo") --房间key
        if roomKey~="" then
           txtRoomNo:setString(roomKey)
        end
        local txtGameName = seekNodeByName(annItem, "txtGameName")  --游戏名
        txtGameName:setString(gameName)

        local txtEndTime = seekNodeByName(annItem, "txtEndTime")  --解散时间
        txtEndTime:setString(strDate)

        local btnDetail = seekNodeByName(annItem, "btnDetail")  --查看详情
        if btnDetail then
            btnDetail.roomNo = roomNo --设定按钮的房间号
            btnDetail.vecUserStands = vecUserSums
            btnDetail:addClickEventListener(function()
              matchRecordProxy:getData().curIndex = i
              local sRoomNo = btnDetail.roomNo
              local vecUserRecords = btnDetail.vecUserStands
              -- print("btnGetTag:"..sRoomNo)
              dump(vecUserRecords, "房间用户战绩列表")
              local tRoomDetail = {roomNo=sRoomNo, vecRecord = vecUserRecords}
              platformFacade:sendNotification(PlatformConstants.REQUEST_MATCHRECORDDETAIL, tRoomDetail)  --向服务器请求战绩详情
		        end)
        else
            print("btnDetail is nil")
        end
        
        --给整 个项加上点击事件
        annItem.roomNo = roomNo --设定按钮的房间号
        annItem.vecUserStands = vecUserSums
        annItem:addClickEventListener(function()
            local sRoomNo = annItem.roomNo
            local vecUserRecords = annItem.vecUserStands
            local tRoomDetail = {roomNo=sRoomNo, vecRecord = vecUserRecords}
            dump(tRoomDetail, "tRoomDetail")
            platformFacade:sendNotification(PlatformConstants.REQUEST_MATCHRECORDDETAIL, tRoomDetail)  --向服务器请求战绩详情
		    end)
           
        self.list:pushBackCustomItem(annItem)  --列表里加上列表项
    end
    
end

--由游戏id获取游戏名字
function MatchRecordsMediator:getGameNameById(gameId)
    print("由游戏id获取游戏名字 id:" .. gameId)
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local gameList = platformFacade:retrieveProxy("GameListProxy")  --游戏列表配置
    local gameVec = gameList:getData().private
    --dump(gameVec, "gameList.private")
    --[[for i=1,#gameVec do
        if gameVec[i].gameId == gameId then
          return gameVec[i].gameName
        end
    end--]]
     for _,game in ipairs(gameVec) do
       --dump(game, "gameVec game")
        if game.gameId == gameId then
          print("找到了此ID的游戏")
          return game.gameName
        end
     end
    return "无名游戏"
end

--获取玩家自己的得分
function MatchRecordsMediator:getUserScore(vecUserSums)
    print("MatchRecordsMediator:getUserScore")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local login = platformFacade:retrieveProxy("LoginProxy")
    local iUid = login:getData().uid  --获取用户id
    for i=1,#vecUserSums do
       if vecUserSums[i].lUid == iUid then
          return vecUserSums[i].lChangeValue
       end
    end
    return 0
end

function MatchRecordsMediator:onRemove()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
    platformFacade:removeCommand(PlatformConstants.REQUEST_MATCHRECORDNUM)
    platformFacade:removeCommand(PlatformConstants.REQUEST_MATCHRECORDLIST)
    platformFacade:removeCommand(PlatformConstants.START_MATCHRECORDDETAIL)
    platformFacade:removeCommand(PlatformConstants.REQUEST_MATCHRECORDDETAIL)
    

    self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)

end

return MatchRecordsMediator
--endregion
