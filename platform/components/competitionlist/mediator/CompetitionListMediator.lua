
local CompetitionListMediator=class("CompetitionListMediator",cc.load("puremvc").Mediator)
local CptGameListMediator=import(".CptGameListMediator")
local CptTopBarMediator=import(".CptTopBarMediator")

function CompetitionListMediator:ctor()
	CompetitionListMediator.super.ctor(self, "CompetitionListMediator")
end	

function CompetitionListMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
    local GameConstants = cc.exports.GameConstants
	return {
    PlatformConstants.UPDATE_SHOWCOMPETITIONLIST,
    PlatformConstants.UPDATE_COMPETITIONLISTPLAYERNUM,
    PlatformConstants.UPDATE_COMPETITIONBMSTATE,
    GameConstants.START_GAME,
    PlatformConstants.START_LOGOUT,
	}
end

function CompetitionListMediator:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants

	local scene = platformFacade:retrieveMediator("HallMediator").scene
	local ui = cc.CSLoader:createNode("hall_res/competitionList/CompetitionListLayer.csb")
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")


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
    self.listTemp={}

    platformFacade:registerCommand(PlatformConstants.REQUEST_COMPETITIONLISTPLAYERNUM,cc.exports.RequestUpdateCptListCommand)
    platformFacade:registerCommand(PlatformConstants.REQUEST_COMPETITIONDETAIL,cc.exports.RequestCptListDetailCommand)
    platformFacade:registerCommand(GameConstants.REQUEST_JOINCOMPETITION,cc.exports.RequestJoinCptCommand)
    platformFacade:registerCommand(GameConstants.REQUEST_QUITCOMPETITION,cc.exports.RequsetQuitCptCommand)

    platformFacade:registerCommand(PlatformConstants.START_COMPETITIONDETAIL,cc.exports.StartCptDetailCommand)
    platformFacade:registerCommand(PlatformConstants.REQUEST_COMPETITIONGAMELIST,cc.exports.RequestMGameListCommand)
    platformFacade:registerCommand(PlatformConstants.START_COMPETITIONMOREGAME,cc.exports.StartCptMoreGameCommand)
    platformFacade:sendNotification(PlatformConstants.REQUEST_COMPETITIONGAMELIST)

    platformFacade:registerMediator(CptGameListMediator.new(self:getViewComponent()))
    platformFacade:registerMediator(CptTopBarMediator.new(self:getViewComponent()))
    local moregameBtn=seekNodeByName(ui, "moregame_btn")
    moregameBtn:addClickEventListener(function()
    platformFacade:sendNotification(PlatformConstants.START_COMPETITIONMOREGAME)
    end)
	self.list:setScrollBarEnabled(false)

    --金币面板
    local gold_panel = seekNodeByName(ui, "img_jidou_bg")
    if gold_panel then
        local btnAddGold = seekNodeByName(ui, "btn_addjindou")
        if btnAddGold then
            btnAddGold:addClickEventListener(function()
                print("click btnAddGold")
                platformFacade:sendNotification(PlatformConstants.START_SHOPLAYER, 4)  --启动商城 
            end)
        end
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
        local btnAddDiamond = seekNodeByName(ui, "btn_adddiamond")
        if btnAddDiamond then
            btnAddDiamond:addClickEventListener(function()
                print("click btnAddDiamond")
                platformFacade:sendNotification(PlatformConstants.START_SHOPLAYER, 2)  --启动商城钻石页面 
            end)
        end
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
        local btnAddRoomCard = seekNodeByName(ui, "btn_addfangka")
        if btnAddRoomCard then
            btnAddRoomCard:addClickEventListener(function()
                print("click btnAddRoomCard")
                platformFacade:sendNotification(PlatformConstants.START_SHOPLAYER, 3)  --启动商城房卡页面
            end)
        end
        self.txtRoomCard = seekNodeByName(ui, "userfangka")
        if userinfo:getData().roomCard then
            local roomCardStr=cc.exports.formatLongNum(userinfo:getData().roomCard)
            self.txtRoomCard:setString(roomCardStr)
        else
            self.txtRoomCard:setString(0)
        end
    end
    
--	self.list:addScrollViewEventListener(function(sender, eventType)
--		if eventType == ccui.ScrollviewEventType.scrollingEnded and  #competitionList:getData().templateIdList>0 then
--			self.loop = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
--				platformFacade:sendNotification(PlatformConstants.REQUEST_COMPETITIONLISTPLAYERNUM,competitionList:getData().templateIdList)
--			end, 2, false)			
--		elseif eventType == ccui.ScrollviewEventType.scrollingBegan then
--			if self.loop then
--				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.loop)
--			end
--		end
--	end)
end 

function CompetitionListMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	--platformFacade:removeProxy("CompetitionListProxy")
    if self.loop then
	   cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.loop)
	end
    platformFacade:removeMediator("CptGameListMediator")
    platformFacade:removeMediator("CptTopBarMediator")
    self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

function CompetitionListMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
    local types = notification:getType()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local GameConstants = cc.exports.GameConstants
	if name == PlatformConstants.UPDATE_SHOWCOMPETITIONLIST then
   
    local competitionList = platformFacade:retrieveProxy("CompetitionListProxy")
    competitionList:present()
    local matchList=competitionList:getData().currentMatchList
    local templateIdTomatchIdList=competitionList:getData().templateIdTomatchIdList
    dump(templateIdTomatchIdList,"1478")
        self.list:removeAllChildren()
		for i,v in ipairs(templateIdTomatchIdList) do
        local item=self.itemTemp:clone()
        self.list:pushBackCustomItem(item)
        self.listTemp[matchList[i].matchId]=item    
        item:setVisible(true)
        seekNodeByName(item, "competitionName"):setString(templateIdTomatchIdList[i].matchName)
        local gainType=""
        if templateIdTomatchIdList[i].gainType==1 then gainType="房卡" end
        if templateIdTomatchIdList[i].gainType==2 then gainType="钻石" end
        if templateIdTomatchIdList[i].gainType==3 then gainType="房卡" end
        if templateIdTomatchIdList[i].gainType==4 then gainType="金币" end
        seekNodeByName(item, "rewardText"):setString("第一名\n"..gainType.."×15"..templateIdTomatchIdList[i].gainValue)
        seekNodeByName(item, "openNum"):setString("满"..templateIdTomatchIdList[i].players.."人开赛")
        seekNodeByName(item, "cardNum"):setString("×"..templateIdTomatchIdList[i].costValue)
        seekNodeByName(item, "btn_detail"):addClickEventListener(function ()
        platformFacade:sendNotification(PlatformConstants.REQUEST_COMPETITIONDETAIL,{templateId=i})
        end)
        seekNodeByName(item, "btn_baoming"):addClickEventListener(function ()
            competitionList:getData().templateId = i
            platformFacade:sendNotification(GameConstants.REQUEST_JOINCOMPETITION,{templateId=i})
        end)
        seekNodeByName(item, "btn_tuisai"):addClickEventListener(function ()
            platformFacade:sendNotification(GameConstants.REQUEST_QUITCOMPETITION,{templateId=i})
        end)
        end
        if #platformFacade:retrieveProxy("CompetitionListProxy"):getData().templateIdList>0 then 
        platformFacade:sendNotification(PlatformConstants.REQUEST_COMPETITIONLISTPLAYERNUM,platformFacade:retrieveProxy("CompetitionListProxy"):getData().templateIdList) 
        end
    end
    if name == PlatformConstants.UPDATE_COMPETITIONLISTPLAYERNUM then
      local templateIdTomatchIdList = platformFacade:retrieveProxy("CompetitionListProxy"):getData().templateIdTomatchIdList

      local list=self.list:getItems()
      if list~=nil and #list>0 then 
         for i,v in ipairs(templateIdTomatchIdList) do
         local isshow=true
             if v.matchId==0 then
                isshow=false
             else
                isshow=true
             end
             seekNodeByName(list[i], "playersNum"):setVisible(isshow)
             seekNodeByName(list[i], "playersNum"):setString(v.numOfPlayer)
         end
      end

    end
    if name == PlatformConstants.UPDATE_COMPETITIONBMSTATE then
    dump(self.listTemp,"listTemp",10)
    local templateIdTomatchIdList=platformFacade:retrieveProxy("CompetitionListProxy"):getData().templateIdTomatchIdList
    print(body.matchId,"matchId")
    print(body.types,"types")
    local listk=self.list:getItems()
--    dump(self.listTemp,"self.listTemp",10)       
--    seekNodeByName(self.listTemp[body.matchId], "btn_baoming"):setVisible(not body.types)
--    seekNodeByName(self.listTemp[body.matchId], "btn_tuisai"):setVisible(body.types)
    for k, v in ipairs(templateIdTomatchIdList) do
        if body.matchId==v.matchId then
        seekNodeByName(listk[k], "btn_baoming"):setVisible(not body.types)
        seekNodeByName(listk[k], "btn_tuisai"):setVisible(body.types)
        return 
        end
    end

    end
    if name == GameConstants.START_GAME then  --开始游戏
    print("开始游戏,yyichu")
       platformFacade:removeMediator("CompetitionListMediator")
       platformFacade:sendNotification(PlatformConstants.CLOSE_MSGBOX)
    end
    if name == PlatformConstants.START_LOGOUT then  --登出消息
	    platformFacade:removeProxy("CompetitionListProxy")
		platformFacade:removeMediator("CompetitionListMediator")
    end
end
return CompetitionListMediator