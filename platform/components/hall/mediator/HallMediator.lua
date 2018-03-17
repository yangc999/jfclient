
local TitleMediator = import(".TitleMediator")
local TitleRoomMediator = import(".TitleRoomMediator")

local Mediator = cc.load("puremvc").Mediator

local HallMediator = class("HallMediator", Mediator)

function HallMediator:ctor(scene)
	HallMediator.super.ctor(self, "HallMediator")
	self.scene = scene
end

function HallMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.START_LOGOUT, 
        PlatformConstants.SHOW_GAMELIST, 
        PlatformConstants.SHOW_ROOMLIST,
        PlatformConstants.UPDATE_SETREALNAME,
        PlatformConstants.RESULT_REALNAME,
	}
end

function HallMediator:onRegister()
    print("HallMediator:onRegister")
  	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
  	local PlatformConstants = cc.exports.PlatformConstants
    local hallProxy = platformFacade:retrieveProxy("HallProxy")

  	platformFacade:registerCommand(PlatformConstants.REQUEST_LOGOUT, cc.exports.RequestLogoutCommand)
  	platformFacade:registerCommand(PlatformConstants.UPDATE_ROOMLIST, cc.exports.UpdateRoomListCommand)
  	platformFacade:registerCommand(PlatformConstants.SHOW_USERINFO, cc.exports.ShowUserInfoCommand)
  	platformFacade:registerCommand(PlatformConstants.START_GAMELIST, cc.exports.StartGameListCommand)
  	platformFacade:registerCommand(PlatformConstants.START_ROOMLIST, cc.exports.StartRoomListCommand)
  	platformFacade:registerCommand(PlatformConstants.SHOW_PRIVATEROOM, cc.exports.ShowPrivateRoomCommand)
    platformFacade:registerCommand(PlatformConstants.START_BANKLAYER, cc.exports.StartBankUICommand)   --开启银行界面
    platformFacade:registerCommand(PlatformConstants.START_HORSELAMP, cc.exports.StartHorseLampCommand)
    platformFacade:registerCommand(PlatformConstants.START_ANNOUNCELIST, cc.exports.StartAnnounceListCommand) --开启公告列表
    platformFacade:registerCommand(PlatformConstants.START_SHOPLAYER, cc.exports.StartShopLayerCommand) --开启商城界面
    platformFacade:registerCommand(PlatformConstants.START_LOTTERYLAYER, cc.exports.StartLotteryCommand) --开启抽奖界面
    platformFacade:registerCommand(PlatformConstants.START_REALNAMELAYER, cc.exports.StartRealNameCommand) --开启实名认证界面
    platformFacade:registerCommand(PlatformConstants.START_SYSSETLAYER, cc.exports.StartSysSetUiCommand)  --启动系统设置界面
    platformFacade:registerCommand(PlatformConstants.REQUEST_BENEFITS, cc.exports.RequestBenefitsCommand)
    platformFacade:registerCommand(PlatformConstants.SHOW_BENEFITS, cc.exports.ShowBenefitsCommand) --任务数据
    platformFacade:registerCommand(PlatformConstants.REQUEST_TASKSHARE, cc.exports.RequestTaskSharesCommand) --请求任务配置数据
    platformFacade:registerCommand(PlatformConstants.START_TASKSHARE, cc.exports.StartTasksCommand) --启动任务分享UI
    platformFacade:registerCommand(PlatformConstants.START_CUSTOMHELPLAYER, cc.exports.StartCustomHelpLayerCommand) --启动客服
    platformFacade:registerCommand(PlatformConstants.START_MATCHRECORDSLAYER, cc.exports.StartMatchRecordsCommand)  --启动战绩
    platformFacade:registerCommand(PlatformConstants.START_COMPETITIONLIST, cc.exports.StartCptListCommand) --启动比赛界面
    platformFacade:registerCommand(PlatformConstants.START_MATCHHOME, cc.exports.StartMatchHomeCommand)  --启动比赛首页

  	local ui = cc.CSLoader:createNode("hall_res/hall/hallLayer.csb")
  	self:setViewComponent(ui)
  	self.scene:addChild(ui)

    local animator = seekNodeByName(ui, "shangcheng_animal")
  	local animation = cc.CSLoader:createTimeline("hall_res/hall/shangcheng/shangcheng.csb")
  	animation:gotoFrameAndPlay(0, true)
  	animator:runAction(animation)

    local animator_club = seekNodeByName(ui, "club_animal")
  	local animaton_club = cc.CSLoader:createTimeline("hall_res/hall/club/club.csb")
  	animaton_club:gotoFrameAndPlay(0, true)
  	animator_club:runAction(animaton_club)

    local animator_fight = seekNodeByName(ui, "fight_animal")
  	local animation_fight = cc.CSLoader:createTimeline("hall_res/hall/friend/friendfight.csb")
  	animation_fight:gotoFrameAndPlay(0, true)
  	animator_fight:runAction(animation_fight)

  	local panelTable = seekNodeByName(ui, "FileNode_table")
  	platformFacade:sendNotification(PlatformConstants.START_GAMELIST, panelTable)

  	local panelList = seekNodeByName(ui, "FileNode_list")
  	platformFacade:sendNotification(PlatformConstants.START_ROOMLIST, panelList)

    --新的顶部
  	self.panelTop = seekNodeByName(ui, "FileNode_top")
  	platformFacade:registerMediator(TitleMediator.new(self.panelTop))

    --只用于房间列表顶部
  	self.panelTopRoom = seekNodeByName(ui, "FileNode_top_room")
    self.panelTopRoom:removeAllChildren()
  	platformFacade:registerMediator(TitleRoomMediator.new(self.panelTopRoom))
    self.panelTopRoom:setVisible(false)

    self.panelBottom = seekNodeByName(ui, "FileNode_bottom") --取得底部工具栏 包含商城 活动 任务等
    self:buttonListener(ui) --添加底部工具栏按钮响应

    local horseLamp = seekNodeByName(ui, "FileNode_horselamp")
  	platformFacade:sendNotification(PlatformConstants.START_HORSELAMP, horseLamp)

  	platformFacade:removeCommand(PlatformConstants.START_GAMELIST)
  	platformFacade:removeCommand(PlatformConstants.START_ROOMLIST)

    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local GameConstants = cc.exports.GameConstants
    gameFacade:sendNotification(GameConstants.START_TCP)
    gameFacade:sendNotification(GameConstants.START_REDDOT)

    performWithDelay(self:getViewComponent() , function()
        self:startCountDown()
     end, 2)

    local musicID=ccexp.AudioEngine:play2d(PlatformConstants.HALL_MUSIC_PATH, true)   --播放大厅背景音乐
    hallProxy:getData().bgMusicID=musicID
    print("musicID:"..musicID)
end

function HallMediator:onRemove()
  	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
  	local PlatformConstants = cc.exports.PlatformConstants
  	
  	platformFacade:removeCommand(PlatformConstants.REQUEST_LOGOUT)
  	platformFacade:removeCommand(PlatformConstants.UPDATE_ROOMLIST)
  	platformFacade:removeCommand(PlatformConstants.SHOW_USERINFO)
  	platformFacade:removeCommand(PlatformConstants.SHOW_PRIVATEROOM)
    platformFacade:removeCommand(PlatformConstants.START_BANKLAYER)
    platformFacade:removeCommand(PlatformConstants.START_SHOPLAYER)
    platformFacade:removeCommand(PlatformConstants.START_ANNOUNCELIST)
    platformFacade:removeCommand(PlatformConstants.SHOW_BENEFITS)
    platformFacade:removeCommand(PlatformConstants.START_LOTTERYLAYER)
    platformFacade:removeCommand(PlatformConstants.START_REALNAMELAYER)
    platformFacade:removeCommand(PlatformConstants.START_SYSSETLAYER)
    platformFacade:removeCommand(PlatformConstants.REQUEST_TASKSHARE)
    platformFacade:removeCommand(PlatformConstants.START_TASKSHARE) 
    platformFacade:removeCommand(PlatformConstants.START_CUSTOMHELPLAYER) 
    platformFacade:removeCommand(PlatformConstants.START_MATCHRECORDSLAYER)
    platformFacade:removeCommand(PlatformConstants.START_MATCHHOME)

  	self:getViewComponent():removeFromParent()
  	self:setViewComponent(nil)

    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local GameConstants = cc.exports.GameConstants
    gameFacade:removeMediator("TcpMediator")
    
    self:stopCountDown() 
end

-- 播放按钮音乐
function HallMediator:playBtnMusic()
  local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
  local PlatformConstants = cc.exports.PlatformConstants
  local hallProxy = platformFacade:retrieveProxy("HallProxy")

  if hallProxy:getData().effectMusicCanPlay==1 then
      local voiceNum = cc.UserDefault:getInstance():getIntegerForKey("bgEffectVolume")
      local vol = voiceNum/100.0
      if vol > 1.0 then vol = 1.0 end
      if vol < 0.0 then vol = 0.0 end
      local btnMusicID=ccexp.AudioEngine:play2d(PlatformConstants.BUTTON_MUSIC_PATH,false,vol)  
      print("playBtnMusic vol:" .. vol,"id:",btnMusicID)
  end
end

--大厅按钮响应
function HallMediator:buttonListener(ui)
    print("HallMediator:buttonListener")

    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")

    local btn_bank = seekNodeByName(ui, "btn_baoxianxiang")
    if btn_bank then
        btn_bank:addClickEventListener(function()
            print("click btn_bank") 
            platformFacade:sendNotification(PlatformConstants.START_BANKLAYER)  --启动银行界面
            local effectMusicID=ccexp.AudioEngine:play2d(PlatformConstants.BUTTON_MUSIC_PATH, false)   --播放按钮音乐
            print("click btn_bank effectMusicID："..effectMusicID) 
            -- hallProxy:getData().effectMusicID=effectMusicID
        end)
    end
    --启动公告页面
    local btn_Activity = seekNodeByName(ui, "btn_message")
    if btn_Activity then
        btn_Activity:addClickEventListener(function()
            print("click btn_Activity")
            platformFacade:sendNotification(PlatformConstants.START_ANNOUNCELIST)  --启动公告
        end)
    end

    --每日赚金
    local btn_task = seekNodeByName(ui,"btn_task")
    if btn_task ~= nil then
        btn_task:addClickEventListener(function()
            print("click btn_task")
            local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
--            platformFacade:sendNotification(PlatformConstants.START_BENEFITS)  --每日赚金
            platformFacade:sendNotification(PlatformConstants.SHOW_BENEFITS)
        end)
    else
        print("btn_Activity is nil")
    end

    --启动商城页面
    local btn_Shop = seekNodeByName(ui, "btn_mark")
    if btn_Shop then
        btn_Shop:addClickEventListener(function()
            print("click btn_Shop")
            platformFacade:sendNotification(PlatformConstants.START_SHOPLAYER)  --启动商城界面
        end)
    end
    --启动抽奖页面
    local btn_Lottery = seekNodeByName(ui, "img_shouchong")
    if btn_Lottery then
        btn_Lottery:addClickEventListener(function()
            print("click hallMediator btn_Lottery")
            -- self:animationTest(ui)
            -- local  logoImg = ImageView:new()
            -- logoImg:loadTexture("platform_res/icons/2-1.png")
            -- ui.addChild(logoImg)
            platformFacade:sendNotification(PlatformConstants.START_LOTTERYLAYER)  --启动抽奖界面
        end)
    end

    --点击实名认证按钮
    self.btn_RealName = seekNodeByName(ui, "btnRealName")
    if self.btn_RealName~=nil then
       self.btn_RealName:setVisible(false)  --默认不显示
       self.btn_RealName:addClickEventListener(function()
         print("click btn_RealName")
         platformFacade:sendNotification(PlatformConstants.START_REALNAMELAYER)
       end)
    end

    --金币面板
    local coin_panel = seekNodeByName(ui, "img_jidou_bg")
    if coin_panel then
       local btn_AddCoin = seekNodeByName(coin_panel, "btn_addjindou")
       if btn_AddCoin then
          btn_AddCoin:addClickEventListener(function()
            print("click coin_panel")
            platformFacade:sendNotification(PlatformConstants.START_SHOPLAYER, 4)  --启动商城 
          end)
       end
    end
    --房卡面板
    local roomCard_panel = seekNodeByName(ui, "img_fangka_bg")
    if roomCard_panel then
       local btn_AddRoomCard = seekNodeByName(roomCard_panel, "btn_addfangka")
       btn_AddRoomCard:addClickEventListener(function()
         print("click btn_AddRoomCard")
         platformFacade:sendNotification(PlatformConstants.START_SHOPLAYER, 3)  --启动商城
       end)
    end
    --钻石面板
    local diamond_panel = seekNodeByName(ui, "img_diamond_bg")
    if diamond_panel then
       local btn_adddiamond = seekNodeByName(diamond_panel, "btn_adddiamond")
       btn_adddiamond:addClickEventListener(function()
         print("click btn_adddiamond")
         platformFacade:sendNotification(PlatformConstants.START_SHOPLAYER, 2)  --启动商城 
       end)
    end
    local btn_huodong = seekNodeByName(ui, "btn_huodong") --分享按钮
    if btn_huodong then
        btn_huodong:addClickEventListener(function()
            platformFacade:sendNotification(PlatformConstants.START_TASKSHARE)
        end)
    end

    local btn_ranking = seekNodeByName(ui, "btn_paihang")   --排行
    if btn_ranking then
        btn_ranking:addClickEventListener(function()
           platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "功能待开放")
        end)
    end
   --设置按钮
   local btn_setting = seekNodeByName(ui, "btn_setting")
    if btn_setting then
        btn_setting:addClickEventListener(function()

            self:playBtnMusic()
            platformFacade:sendNotification(PlatformConstants.START_SYSSETLAYER)
        end)
    end

    --战绩按钮
    local btn_zhanji = seekNodeByName(ui, "btn_fightrecord")   --战绩按钮
    if btn_zhanji then
        btn_zhanji:addClickEventListener(function()
            print("点击战绩按钮")
            platformFacade:sendNotification(PlatformConstants.START_MATCHRECORDSLAYER)
        end)
    end

   --客服按钮
   local btn_customer = seekNodeByName(ui, "btn_customer")
    if btn_customer then
        btn_customer:addClickEventListener(function()
        print("click customer button  点击客服按钮")
        platformFacade:sendNotification(PlatformConstants.START_CUSTOMHELPLAYER)
        end)
    else
        print("客服按钮不存在")
    end

    --俱乐部按钮
    local btn_club = seekNodeByName(ui, "btn_club")
    if btn_club then
       btn_club:addClickEventListener(function()
            --platformFacade:sendNotification(PlatformConstants.START_MATCHHOME)
            --platformFacade:sendNotification(PlatformConstants.START_COMPETITIONLIST)
            platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "努力研发中，敬请期待！")
        end)
    end

    --比赛按钮
    local btn_match = seekNodeByName(ui, "btn_match")
    if btn_match then
       btn_match:addClickEventListener(function()
            --platformFacade:sendNotification(PlatformConstants.START_MATCHHOME)
            platformFacade:sendNotification(PlatformConstants.START_COMPETITIONLIST)
        end)
    end

    --邀请码按钮
    local btn_inviteCode = seekNodeByName(ui, "btn_invitecode")
    if btn_inviteCode then
       btn_inviteCode:addClickEventListener(function()
            --platformFacade:sendNotification(PlatformConstants.START_MATCHHOME)
            --cc.exports.showLoadingAnim("正在网络请求...","请求超时")
        end)
    end
end

-- 抽奖动画测试
function HallMediator:animationTest(ui)
  print("animationTest start")
  -- ccdb.CCFactory:getInstance():loadDragonBonesData("platform_res/lottery/mririhuo/aa-baiban_ske.json")
  -- ccdb.CCFactory:getInstance():loadTextureAtlasData("platform_res/lottery/mririhuo/aa-baiban_tex.json")
  -- local testdb = ccdb.CCFactory:getInstance():buildArmatureDisplay("Armature", "aa-baiban")
  ccdb.CCFactory:getInstance():loadDragonBonesData("platform_res/lottery/xianshi/aa-baiban22_ske.json")
  ccdb.CCFactory:getInstance():loadTextureAtlasData("platform_res/lottery/xianshi/aa-baiban22_tex.json")
  local testdb = ccdb.CCFactory:getInstance():buildArmatureDisplay("Armature", "aa-baiban22")
  local ani = testdb:getArmature():getAnimation():play("newAnimation", 1)

  --ani.timeScale = 0.5
  testdb:setPosition(display.cx, display.cy)
  ui:addChild(testdb)
  print("animationTest addChild after")
  -- testdb:addEvent("complete", function()
  --   self.loop = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
  --     -- platformFacade:sendNotification(PlatformConstants.REQUEST_CONFIG)
  --     -- print("animationTest scheduleScriptFunc")
  --     -- testdb.removeFromParent()
  --   end, 0.5, false)
  -- end)
end

function HallMediator:startCountDown()
    print("HallMediator:startCountDown")
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc( handler(self , self.update ) , 30.0 ,false)
end

function HallMediator:stopCountDown()
    print("HallMediator:stopCountDown")
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry( self.schedulerID )
        self.schedulerID = nil
    end
end

function HallMediator:update()
    print("HallMediator update")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    
    self:updateNetworkState()
end

--监控网络状态改变
function HallMediator:updateNetworkState()
    print("HallMediator:updateNetworkState")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local hallProxy = platformFacade:retrieveProxy("HallProxy")
    local networkType = cc.exports.getNetworkType()
    local oldNetType = hallProxy:getData().netstate
    if networkType == "WIFI" then
       if oldNetType == "WIFI" then
         return
       else
          hallProxy:getData().netstate = "WIFI"
          platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络切换为WIFI状态")
       end
    elseif networkType == "MOBILE" then
       if oldNetType == "MOBILE" then
         return
       else
          hallProxy:getData().netstate = "MOBILE"
          platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络切换为4G状态")
       end
    end
end

function HallMediator:handleNotification(notification)
	local name = notification:getName()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")
    local ui = self:getViewComponent()
    local root = seekNodeByName(ui, "FileNode_table")
    local body = notification:getBody()
	if name == PlatformConstants.START_LOGOUT then
		platformFacade:removeMediator("HallMediator")
		platformFacade:removeMediator("TitleMediator")
        platformFacade:removeMediator("TitleRoomMediator")
    elseif name == PlatformConstants.SHOW_GAMELIST then
        self.panelBottom:setVisible(true)
        self.panelTopRoom:setVisible(false)
        self.panelTop:setVisible(true)
    elseif name == PlatformConstants.SHOW_ROOMLIST then
        self.panelBottom:setVisible(false)
        self.panelTopRoom:setVisible(true)  --room顶部栏出现
        self.panelTop:setVisible(false) --普通顶部栏消失
    elseif name == PlatformConstants.UPDATE_SETREALNAME then
       local bRealSet = userinfo:getData().bRealNameSet
       print("bRealSet updated value = " .. tostring(bRealSet))
       if bRealSet then  --根据是否实名认证来决定此按钮显示与否
          self.btn_RealName:setVisible(false)   --如果已经实名认证了，这个按钮不再显示
       else
          self.btn_RealName:setVisible(true)
       end
    elseif name == PlatformConstants.RESULT_REALNAME then
       if body == true then
          print("实名认证成功")
          self.btn_RealName:setVisible(false)  --实名认证成功，按钮消失
       else
          print("实名认证失败")
          self.btn_RealName:setVisible(true)
       end
	end
end

function HallMediator:showRoomList()
	
end

return HallMediator