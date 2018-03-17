
local CompetitionListMediator=class("CompetitionListMediator",cc.load("puremvc").Mediator)

function CompetitionListMediator:ctor()
    CompetitionListMediator.super.ctor(self, "CompetitionListMediator")
end	

function CompetitionListMediator:listNotificationInterests()
  	local PlatformConstants = cc.exports.PlatformConstants
  	return {
      PlatformConstants.UPDATE_SHOWCOMPETITIONLIST,
      PlatformConstants.UPDATE_COMPETITIONLISTPLAYERNUM,
  	}
end

function CompetitionListMediator:onRegister()
  	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
  	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
  	local GameConstants = cc.exports.GameConstants

  	local scene = platformFacade:retrieveMediator("HallMediator").scene
  	local ui = cc.CSLoader:createNode("hall_res/competitionList/CompetitionListLayer.csb")
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")

    platformFacade:registerCommand(PlatformConstants.START_MATCHSHARE, cc.exports.StartMatchShareCommand)

  	self:setViewComponent(ui)
  	scene:addChild(ui)
  	self.loop = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
          if platformFacade:retrieveProxy("CompetitionListProxy")==nil then return end
  		if #platformFacade:retrieveProxy("CompetitionListProxy"):getData().templateIdList>0 then 
          platformFacade:sendNotification(PlatformConstants.REQUEST_COMPETITIONLISTPLAYERNUM,platformFacade:retrieveProxy("CompetitionListProxy"):getData().templateIdList) 
          end
  	end, 2, false)	
    
    self.list = seekNodeByName(ui, "competition_list")
	  self.itemTemp = seekNodeByName(ui, "itemtempl")
    local btn_back = seekNodeByName(ui, "btn_back") --关闭按钮
    btn_back:addClickEventListener(function ()
        platformFacade:removeMediator("CompetitionListMediator")
    end)

    --金币面板
    local gold_panel = seekNodeByName(ui, "img_jidou_bg")
    if gold_panel then
        local btnAddGold = seekNodeByName(diamond_panel, "btn_addjindou")
        btnAddGold:addClickEventListener(function()
            platformFacade:sendNotification(PlatformConstants.START_SHOPLAYER, 4)  --启动商城 
        end)
        self.txtGold = seekNodeByName(ui, "usermoney")
        if userinfo:getData().gold then
            local goldStr=cc.exports.formatLongNum(userinfo:getData().gold)
            self.txtGold:setString(goldStr)
        else
            self.txtGold:setString(0)
        end
    end


    --钻石面板
    local diamond_panel = seekNodeByName(ui, "img_diamond_bg")
    if diamond_panel then
        local btnAddDiamond = seekNodeByName(diamond_panel, "btn_adddiamond")
        btnAddDiamond:addClickEventListener(function()
            print("click btn_adddiamond")
            platformFacade:sendNotification(PlatformConstants.START_SHOPLAYER, 2)  --启动商城钻石页面
        end)

        self.txtDiamond = seekNodeByName(ui, "userdiamond")
        if userinfo:getData().diamond then
            local diamondStr=cc.exports.formatLongNum(userinfo:getData().diamond)
            self.txtDiamond:setString(diamondStr)
        else
            self.txtDiamond:setString(0)
        end
    end

    --房卡面板
    local fangka_panel = seekNodeByName(ui, "img_fangka_bg")
    if fangka_panel then
        local btnAddRoomCard = seekNodeByName(diamond_panel, "btn_addfangka")
        btnAddRoomCard:addClickEventListener(function()
          print("click btn_AddRoomCard")
          platformFacade:sendNotification(PlatformConstants.START_SHOPLAYER, 3)  --启动商城房卡页面
        end)
        self.txtRoomCard = seekNodeByName(ui, "userfangka")
        if userinfo:getData().roomCard then
            local roomCardStr=cc.exports.formatLongNum(userinfo:getData().roomCard)
            self.txtRoomCard:setString(roomCardStr)
        else
            self.txtRoomCard:setString(0)
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

    platformFacade:registerCommand(PlatformConstants.REQUEST_COMPETITIONLISTPLAYERNUM,cc.exports.RequestUpdateCptListCommand)
    platformFacade:registerCommand(PlatformConstants.REQUEST_COMPETITIONDETAIL,cc.exports.RequestCptListDetailCommand)
    platformFacade:registerCommand(PlatformConstants.REQUEST_JOINCOMPETITION,cc.exports.RequestJoinCptCommand)
    platformFacade:registerCommand(PlatformConstants.START_COMPETITIONDETAIL,cc.exports.StartCptDetailCommand)
  	self.list:setScrollBarEnabled(false)
  	self.list:addScrollViewEventListener(function(sender, eventType)
--		if eventType == ccui.ScrollviewEventType.containerMoved then
--			local innerY = self.list:getInnerContainerPosition().y
--			local innerHeight = self.list:getInnerContainerSize().height
--			local outHeight = self.list:getContentSize().height
--			local edge = 10
--			if innerY >= 0-edge then
--				if competitionList:getData().showTo < 5 then
--					self.list:getInnerContainer():setPositionY(innerY-self.itemTemp:getContentSize().height)
--					competitionList:getData().showFrom = competitionList:getData().showFrom + 1
--					competitionList:getData().showTo = competitionList:getData().showTo + 1
--					competitionList:present()
--				end
--			elseif innerY <= outHeight-innerHeight+edge then
--				if competitionList:getData().showFrom > 1 then
--					self.list:getInnerContainer():setPositionY(innerY+self.itemTemp:getContentSize().height)
--					competitionList:getData().showFrom = competitionList:getData().showFrom - 1
--					competitionList:getData().showTo = competitionList:getData().showTo - 1
--					competitionList:present()
--				end
--			end
		if eventType == ccui.ScrollviewEventType.scrollingEnded and  #competitionList:getData().templateIdList>0 then
			self.loop = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
				platformFacade:sendNotification(PlatformConstants.REQUEST_COMPETITIONLISTPLAYERNUM,competitionList:getData().templateIdList)
			end, 2, false)			
		elseif eventType == ccui.ScrollviewEventType.scrollingBegan then
			if self.loop then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.loop)
			end
		end
	end)
    platformFacade:registerCommand(PlatformConstants.REQUEST_COMPETITIONLIST,cc.exports.RequestCptListCommand)
    platformFacade:sendNotification(PlatformConstants.REQUEST_COMPETITIONLIST)
end 

function CompetitionListMediator:onRemove()
  	self:getViewComponent():removeFromParent()
  	self:setViewComponent(nil)

  	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
  	platformFacade:removeProxy("CompetitionListProxy")
      if self.loop then
  	   cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.loop)
  	end
  	platformFacade:removeCommand(PlatformConstants.REQUEST_COMPETITIONLIST)
    platformFacade:removeCommand(PlatformConstants.START_MATCHSHARE)
    
end

function CompetitionListMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	if name == PlatformConstants.UPDATE_SHOWCOMPETITIONLIST then
   
    local competitionList = platformFacade:retrieveProxy("CompetitionListProxy")
    competitionList:present()
    local matchList=competitionList:getData().currentMatchList
    self.list:removeAllChildren()
		for i,v in ipairs(body) do
        local item=self.itemTemp:clone()
        self.list:pushBackCustomItem(item)
        item:setVisible(true)
        seekNodeByName(item, "competitionName"):setString(matchList[i].matchName)
        local gainType=""
        if body[i].gainType==1 then gainType="房卡" end
        if body[i].gainType==2 then gainType="钻石" end
        if body[i].gainType==3 then gainType="房卡" end
        if body[i].gainType==4 then gainType="金币" end
        seekNodeByName(item, "rewardText"):setString("第一名\n"..gainType.."×15"..matchList[i].gainValue)
        seekNodeByName(item, "openNum"):setString("满"..matchList[i].players.."人开赛")
        seekNodeByName(item, "cardNum"):setString("×"..matchList[i].costValue)
        seekNodeByName(item, "btn_detail"):addClickEventListener(function ()
        platformFacade:sendNotification(PlatformConstants.REQUEST_COMPETITIONDETAIL,{templateId=matchList[i].templateId})
        end)
        seekNodeByName(item, "btn_baoming"):addClickEventListener(function ()
        platformFacade:sendNotification(PlatformConstants.REQUEST_JOINCOMPETITION,{templateId=matchList[i].templateId})
        end)
        end
    end
    if name == PlatformConstants.UPDATE_COMPETITIONLISTPLAYERNUM then
      local templateIdTomatchIdList = platformFacade:retrieveProxy("CompetitionListProxy"):getData().templateIdTomatchIdList

      local list=self.list:getItems()
      if list~=nil and #list>0 then 
         for i,v in ipairs(templateIdTomatchIdList) do
             seekNodeByName(list[i], "playersNum"):setString(v.numOfPlayer)
         end
      end

--      local list=self.list:getItems()
--      for i,v in ipairs(templateIdTomatchIdList) do
--          for k,vl in ipairs(list) do
--            if vl.getName()==i then
--               seekNodeByName(vl, "playersNum"):setString(v.numOfPlayer)
--            end
--          end
--      end
    end
    if name == PlatformConstants.START_LOGOUT then  --登出消息
		    platformFacade:removeMediator("MatchHomeMediator")
        --platformFacade:removeProxy("AnnounceProxy")
    elseif name == PlatformConstants.UPDATE_NICKNAME then  --更新昵称消息
		    self.txtName:setString(tostring(body))
    elseif name == PlatformConstants.UPDATE_HEADID then
    		local id = body or 0
    		local img = string.format("%s%d.png", id < 6 and "boy" or "girl", id < 6 and id or id-6)
    		local path = "platform_res/common/" .. img
    		self.imgHead:loadTexture(path)
  	elseif name == PlatformConstants.UPDATE_HEADSTR then --更新头像
    		if body and string.len(body) > 1 then
    			self.imgHead:loadTexture(body)
    		end
  	elseif name == PlatformConstants.UPDATE_DIAMOND then --更新钻石消息
  		  self.txtDiamond:setString(tostring(body))
  	elseif name == PlatformConstants.UPDATE_ROOMCARD then --更新房卡消息
  		  self.txtRoomCard:setString(tostring(body))
    end
end
return CompetitionListMediator