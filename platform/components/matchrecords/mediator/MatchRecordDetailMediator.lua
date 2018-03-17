--region *.lua
--Date
--战绩详情页面
local Mediator = cc.load("puremvc").Mediator
local MatchRecordDetailMediator = class("MatchRecordDetailMediator", Mediator)

function MatchRecordDetailMediator:ctor()
	MatchRecordDetailMediator.super.ctor(self, "MatchRecordDetailMediator")
    self.list = nil
end	

function MatchRecordDetailMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.START_LOGOUT,
	}
end

function MatchRecordDetailMediator:onRegister()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	  local PlatformConstants = cc.exports.PlatformConstants

    --platformFacade:registerCommand(PlatformConstants.REQUEST_MATCHRECORDNUM, cc.exports.RequestRecordsNumCommand) --请求战绩总数
    platformFacade:registerCommand(PlatformConstants.REQUEST_MATCHRECORDVIDEOURL, cc.exports.RequestVideoUrlComman) --请求战绩列表
    


  	local ui = cc.CSLoader:createNode("hall_res/openRoom/matchRecordDetail.csb")
  	self:setViewComponent(ui)
  	local scene = platformFacade:retrieveMediator("HallMediator").scene
  	scene:addChild(self:getViewComponent())

      self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--背景
      --获取关闭按钮
      local btnClose = seekNodeByName(self.bgImg, "btn_close")
  	if btnClose then
  		btnClose:addClickEventListener(function()
              btnClose:setZoomScale(-0.1)
  			platformFacade:removeMediator("MatchRecordDetailMediator")
  		end)
  	end

    self.usrTemplate = seekNodeByName(ui, "imgTemplate")
    self.usrTemplate:setVisible(false)

    self.list = seekNodeByName(ui, "ListView") --列表框
    self.list:setItemsMargin(4)
    --四个玩家的标签
    self.txtPlayerA = seekNodeByName(ui, "txtPlayerA")  --玩家A
    self.txtPlayerB = seekNodeByName(ui, "txtPlayerB")  --玩家B
    self.txtPlayerC = seekNodeByName(ui, "txtPlayerC")  --玩家C
    self.txtPlayerD = seekNodeByName(ui, "txtPlayerD")  --玩家C
    --4个玩家的ID
    self.playerAID = 0
    self.playerBID = 0
    self.playerCID = 0
    self.playerDID = 0

    self:showGameDetailList()   --显示战局详细信息
end

function MatchRecordDetailMediator:showGameDetailList()
    print("MatchRecordDetailMediator:showGameDetailList")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	  local PlatformConstants = cc.exports.PlatformConstants
    local matchRecordProxy = platformFacade:retrieveProxy("MatchRecordsProxy")
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")
    local recordList = matchRecordProxy:getData().vCurRoundList
    local recordDetal = matchRecordProxy:getData().vCurRecordDetail
    dump(recordDetal, "房间详细战绩")
    local recordFirst = recordList[1]
    if recordFirst==nil then
       print("查找不到战绩详情recordList[1]")
       return
    end
    local recordRoomDetail = recordFirst.vecUserStands
    if recordRoomDetail==nil then
       print("查找不到战绩详情vecUserStands")
       return
    end
    --设定玩家A, 玩家B, 玩家C标签
    if recordRoomDetail[1] then
       self.txtPlayerA:setString(recordRoomDetail[1].sNickName)
       self.playerAID = recordRoomDetail[1].lUid
    else
       print("找不到玩家A的战绩")
    end
    if recordRoomDetail[2] then
       self.txtPlayerB:setString(recordRoomDetail[2].sNickName)
       self.playerBID = recordRoomDetail[2].lUid
    else
      print("找不到玩家B的战绩")
    end
    if recordRoomDetail[3] then
       self.txtPlayerC:setString(recordRoomDetail[3].sNickName)
       self.playerCID = recordRoomDetail[3].lUid
    else
       print("找不到玩家C的战绩")
    end
    if recordRoomDetail[4] then
       self.txtPlayerD:setString(recordRoomDetail[4].sNickName)
       self.playerDID = recordRoomDetail[4].lUid
    else
       print("找不到玩家D的战绩")
    end
    dump(recordList, "战局详情")
    --先清除所有的孩子结点
    self.list:removeAllChildren()
    local annItem = nil  --复制的模板类
    for _,record in ipairs(recordList) do
        dump(record, "record")

        local nRoundNo = record.iRoundNo  --结束
        print("局数："..nRoundNo)
        local disTime = record.lEndTime  --结束时间
        --local tTime = os.date("*t", disTime/1000)
        --local strDate = tostring(tTime.month) .. "-" .. tostring(tTime.day) .. " " .. tostring(tTime.hour)..":"..tostring(tTime.min)
        local strDate = tostring(os.date("%Y-%m-%d %H:%m", disTime/1000))

        annItem = self.usrTemplate:clone()
        annItem:setVisible(true)
        local txtNo = seekNodeByName(annItem, "txtNo") --局数索引
        txtNo:setString(tostring(nRoundNo))
        local txtTime = seekNodeByName(annItem, "txtTime") --解散时间
        txtTime:setString(strDate)
        --玩家得分
        local txtPlayAScore = seekNodeByName(annItem, "txtPlayAScore")
        local txtPlayBScore = seekNodeByName(annItem, "txtPlayBScore")
        local txtPlayCScore = seekNodeByName(annItem, "txtPlayCScore")
        local txtPlayDScore = seekNodeByName(annItem, "txtPlayDScore")
        local scoreA = 0
        local scoreB = 0
        local scoreC = 0
        local scoreD = 0
        local vecUserRecord = record.vecUserStands  --用户战绩
        dump(vecUserRecord, "一局得分详情")
        --设定4个玩家的得分
        for i=1,#vecUserRecord do
          if vecUserRecord[i].lUid == self.playerAID then --设定玩家A的分数
            scoreA = vecUserRecord[i].lChangeValue
            self:showScoreText(txtPlayAScore, scoreA)
          end
          if vecUserRecord[i].lUid == self.playerBID then --设定玩家B的分数
            scoreB = vecUserRecord[i].lChangeValue
            self:showScoreText(txtPlayBScore, scoreB)
          end
          if vecUserRecord[i].lUid == self.playerCID then --设定玩家C的分数
            scoreC = vecUserRecord[i].lChangeValue
            self:showScoreText(txtPlayCScore, scoreC)
          end
          if vecUserRecord[i].lUid == self.playerDID then --设定玩家D的分数
            scoreD = vecUserRecord[i].lChangeValue
            self:showScoreText(txtPlayDScore, scoreD)
          end
          
        end  -- end for

        --分享按钮
        local btnShare = seekNodeByName(annItem, "btnShare")
        if btnShare then
           btnShare.roundNo = nRoundNo  --附加上数据
           btnShare:addClickEventListener(function()
			  --platformFacade:removeMediator("BandPhoneMediator")
              local roundNo = btnShare.roundNo
              print("btnShare Tag:"..roundNo)
             -- platformFacade:sendNotification(PlatformConstants.REQUEST_MATCHRECORDDETAIL, sRoomNo)  --向服务器请求战绩详情
               platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "功能在开发中...")
		   end)
        end
        
        --查看录像按钮
        local btnView = seekNodeByName(annItem, "btnCheck")
        if btnView then
            btnView.roundNo = nRoundNo  --附加上数据
            btnView:addClickEventListener(function()
              local rsqVideo = {roundNo = btnView.roundNo, roomNo = matchRecordProxy:getData().sRoomNo}
              platformFacade:sendNotification(PlatformConstants.REQUEST_MATCHRECORDVIDEOURL, rsqVideo)  --向服务器请求录像回放地址
              -- platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "功能在开发中...")
		   end)
        end

         self.list:pushBackCustomItem(annItem)  --列表里加上列表项
    end
end

function MatchRecordDetailMediator:showScoreText(txtText, score)
    local strScore = ""
    if score>0 then
        strScore = "+"..tostring(score)
        txtText:setString(strScore)
        txtText:setTextColor(cc.c3b(255,0,0)) --正数和大于0显示为红色  cc.c3b(255,0,0)
    elseif score<0 then
        strScore = "-" .. tostring(math.abs(score))
        txtText:setString(strScore)
        txtText:setTextColor(cc.c3b(8,196,40)) --负数数显示为绿色 --cc.c3b(8,196,40)
    else
        strScore = "0"
        txtText:setString(strScore)
        txtText:setTextColor(cc.c3b(255,0,0)) --正数和大于0显示为红色  cc.c3b(255,0,0)
    end
    txtText:setTextHorizontalAlignment(2)
end

function MatchRecordDetailMediator:handleNotification(notification)
    print("MatchRecordsMediator:handleNotification")
    local name = notification:getName()
  	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
  	local PlatformConstants = cc.exports.PlatformConstants
    local body = notification:getBody()
    local matchRecordProxy = platformFacade:retrieveProxy("MatchRecordsProxy")
    if name == PlatformConstants.START_LOGOUT then
		    platformFacade:removeMediator("MatchRecordDetailMediator")
        --platformFacade:removeProxy("LotteryProxy")
    end
end

function MatchRecordDetailMediator:onRemove()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	  local PlatformConstants = cc.exports.PlatformConstants
	
    --platformFacade:removeCommand(PlatformConstants.REQUEST_MATCHRECORDNUM)
    platformFacade:removeCommand(PlatformConstants.REQUEST_MATCHRECORDVIDEOURL)
    
    self:getViewComponent():removeFromParent()
  	self:setViewComponent(nil)

end

return MatchRecordDetailMediator
--endregion
