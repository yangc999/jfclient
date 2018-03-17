--region *.lua
--Date
--幸运转盘的UI
local Mediator = cc.load("puremvc").Mediator
local BandPhoneMediator = import(".BandPhoneMediator")
local LotteryMediator = class("LotteryMediator", Mediator)
local ShareFriendUrl = "http://share.game4588.com"  --好友分享网址
--local scheduler = require("framework.scheduler")   --引入定时器模块

function LotteryMediator:ctor(root)
	LotteryMediator.super.ctor(self, "LotteryMediator")
	self.root = root
    self.curType = 1      --当前旋转的类型 1.免费转盘  2.付费转盘
    self.lastAngle = 0  --上次旋转的角度
    self.targetRotate = 0 --目标旋转到的位置
    self.recordType = 1 --当前的纪录类型，1.用户自己的纪录  2.玩家所有的纪录
    self.orginZorder = 0 --当前纪录和用户纪录的ZOrder值
    self.TemplateList = nil --列表模板
    cc.UserDefault:getInstance():setIntegerForKey("lotteryCurrentType", 1)
end

--构造免费抽奖假数据
function LotteryMediator:buildFreeAwardList()
    local lotteryList = {}
    local lottery1 = {iAwardId="1",sPropName="51钻",iIconId = "205", sIcon="101",iRollerType=1, lTime = 0}
    local lottery2 = {iAwardId="2",sPropName="28钻",iIconId = "203", sIcon="101",iRollerType=1, lTime = 0}
    local lottery3 = {iAwardId="3",sPropName="55钻",iIconId = "201", sIcon="101",iRollerType=1, lTime = 0}
    local lottery4 = {iAwardId="4",sPropName="89钻",iIconId = "204", sIcon="101",iRollerType=1, lTime = 0}
    local lottery5 = {iAwardId="5",sPropName="13房卡",iIconId = "301", sIcon="101",iRollerType=1, lTime = 0}
    local lottery6 = {iAwardId="6",sPropName="22房卡",iIconId = "304", sIcon="101",iRollerType=1, lTime = 0}
    local lottery7 = {iAwardId="7",sPropName="56房卡",iIconId = "303", sIcon="101",iRollerType=1, lTime = 0}
    local lottery8 = {iAwardId="8",sPropName="88房卡",iIconId = "302", sIcon="101",iRollerType=1, lTime = 0}
    local lottery9 = {iAwardId="9",sPropName="101金币",iIconId = "101", sIcon="101",iRollerType=1, lTime = 0}
    local lottery10 = {iAwardId="10",sPropName="1020金币",iIconId = "104", sIcon="101",iRollerType=1, lTime = 0}
    local lottery11 = {iAwardId="11",sPropName="5005金币",iIconId = "103", sIcon="101",iRollerType=1, lTime = 0}
    local lottery12 = {iAwardId="12",sPropName="2万金币",iIconId = "104", sIcon="101",iRollerType=1, lTime = 0}
    table.insert(lotteryList, lottery1)
    table.insert(lotteryList, lottery2)
    table.insert(lotteryList, lottery3)
    table.insert(lotteryList, lottery4)
    table.insert(lotteryList, lottery5)
    table.insert(lotteryList, lottery6)
    table.insert(lotteryList, lottery7)
    table.insert(lotteryList, lottery8)
    table.insert(lotteryList, lottery9)
    table.insert(lotteryList, lottery10)
    table.insert(lotteryList, lottery11)
    table.insert(lotteryList, lottery12)
    return lotteryList
end

--构造花钱抽奖假数据
function LotteryMediator:buildVipAwardList()
    local lotteryList = {}
    local lottery1 = {iAwardId="1",sPropName="50钻石",iIconId = 201, sIcon="101",iRollerType=2, lTime = 0}
    local lottery2 = {iAwardId="2",sPropName="200钻石",iIconId = 202, sIcon="101",iRollerType=2, lTime = 0}
    local lottery3 = {iAwardId="3",sPropName="500钻石",iIconId = 203, sIcon="101",iRollerType=2, lTime = 0}
    local lottery4 = {iAwardId="4",sPropName="800钻石",iIconId = 204, sIcon="101",iRollerType=2, lTime = 0}
    local lottery5 = {iAwardId="5",sPropName="100房卡",iIconId = 301, sIcon="101",iRollerType=2, lTime = 0}
    local lottery6 = {iAwardId="6",sPropName="200房卡",iIconId = 302, sIcon="101",iRollerType=2, lTime = 0}
    local lottery7 = {iAwardId="7",sPropName="500房卡",iIconId = 303, sIcon="101",iRollerType=2, lTime = 0}
    local lottery8 = {iAwardId="8",sPropName="800房卡",iIconId = 304, sIcon="101",iRollerType=2, lTime = 0}
    local lottery9 = {iAwardId="9",sPropName="1000金币",iIconId = 101, sIcon="101",iRollerType=2, lTime = 0}
    local lottery10 = {iAwardId="10",sPropName="5000金币",iIconId = 102, sIcon="101",iRollerType=2, lTime = 0}
    local lottery11 = {iAwardId="11",sPropName="5万金币",iIconId = 103, sIcon="101",iRollerType=2, lTime = 0}
    local lottery12 = {iAwardId="12",sPropName="10万金币",iIconId = 104, sIcon="101",iRollerType=2, lTime = 0}
    table.insert(lotteryList, lottery1)
    table.insert(lotteryList, lottery2)
    table.insert(lotteryList, lottery3)
    table.insert(lotteryList, lottery4)
    table.insert(lotteryList, lottery5)
    table.insert(lotteryList, lottery6)
    table.insert(lotteryList, lottery7)
    table.insert(lotteryList, lottery8)
    table.insert(lotteryList, lottery9)
    table.insert(lotteryList, lottery10)
    table.insert(lotteryList, lottery11)
    table.insert(lotteryList, lottery12)
    return lotteryList
end

--构造用户个人自己的抽奖结果假数据
function LotteryMediator:buildUserAwardList()
    local lotteryList = {}
    local lottery1 = {iAwardId="1",sPropName="50钻石",iIconId = 201, sIcon="101",iRollerType=2, lTime = 1512465800}
    local lottery2 = {iAwardId="2",sPropName="200钻石",iIconId = 202, sIcon="101",iRollerType=2, lTime = 1512316800}
    local lottery3 = {iAwardId="3",sPropName="500钻石",iIconId = 203, sIcon="101",iRollerType=2, lTime = 1512230400}
    local lottery4 = {iAwardId="4",sPropName="800钻石",iIconId = 204, sIcon="101",iRollerType=2, lTime = 1512144000}
    local lottery5 = {iAwardId="5",sPropName="100房卡",iIconId = 301, sIcon="101",iRollerType=2, lTime = 1512057600}
    local lottery6 = {iAwardId="6",sPropName="200房卡",iIconId = 302, sIcon="101",iRollerType=2, lTime = 1511884800}
    local lottery7 = {iAwardId="7",sPropName="500房卡",iIconId = 303, sIcon="101",iRollerType=2, lTime = 1511798400}
    local lottery8 = {iAwardId="8",sPropName="800房卡",iIconId = 304, sIcon="101",iRollerType=2, lTime = 1511712000}
   
    table.insert(lotteryList, lottery1)
    table.insert(lotteryList, lottery2)
    table.insert(lotteryList, lottery3)
    table.insert(lotteryList, lottery4)
    table.insert(lotteryList, lottery5)
    table.insert(lotteryList, lottery6)
    table.insert(lotteryList, lottery7)
    table.insert(lotteryList, lottery8)
    
    return lotteryList
end
--构造抽奖结果假数据
function LotteryMediator:buildDrawResult()
    local rollData = {iAwardId=2, sPropName = "50金币", iIconId = 102, sIcon="", iRollerType = 1, lTime = 0}
    return rollData
end
--求一个精灵旋转的真实角度(不计转了N圈的总角度，只考虑与初始位置的角度)
function LotteryMediator:getRotationAbs(spr)
    local rotation = spr:getRotation()
    rotation = math.abs(rotation)
    while rotation>360 do
        rotation = rotation - 360
    end
    return rotation
end

--旋转精灵方法 sprite:精灵 time:旋转时间 rotateAngle:旋转角度
function LotteryMediator:rotateSprite(sprite, time, rotateAngle)
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local action = cc.RotateBy:create(time, rotateAngle)
    local easeAction = cc.EaseCubicActionInOut:create(action)

    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local lotteryProxy = platformFacade:retrieveProxy("LotteryProxy")
    self.txtRotateResult:setString(tostring(self.bCanSwitchType))
    local function enableStartBtn() --转动完成之后，设置一些按钮状态
        self.btnStart:setEnabled(true)
        --self.bCanSwitchType = true  --可以切换抽奖模式
        self.imgTitle:setEnabled(true)
        platformFacade:sendNotification(PlatformConstants.REQUEST_LOTTERYLISTTOTAL)  --刷新中奖列表
        platformFacade:sendNotification(PlatformConstants.REQUEST_LOTTERYLISTUSER)
        local numFreeTimes = lotteryProxy:getData().freeTimes
        if numFreeTimes == 0 then --如果免费抽奖次数为0,切为付费抽奖
              print("if numFreeTimes = 0")
              if self.curType==1 then --当前是免费抽奖,切为付费抽奖
                 self.imgTitle:loadTexture("platform_res/lottery/zzl.png")
                 self.curType = 2
                 --设置剩余抽奖次数
                 local nums = lotteryProxy:getData().payTimes
                 self.txtStart:setString(tostring(nums).."次")
                 --刷新转盘奖品
                 local listAward = lotteryProxy:getData().vipGiftList
                 self:showAwardList(listAward) --刷新显示出付费抽奖
              end
         end
         --延时0.5秒出音效
         performWithDelay(self:getViewComponent() , function() 
           print("performWithDelay 出现动画")
           audio.playSound("sound/getreward.mp3")
           --出现抽奖中奖动画
           platformFacade:sendNotification(PlatformConstants.START_LOTTERYGIFTANIM, 1)
         end, 0.2)
    end
    local sequenceAct = cc.Sequence:create(easeAction, cc.CallFunc:create(enableStartBtn))
    sprite:runAction(sequenceAct)
end

--旋转到目标角度
function LotteryMediator:lotteryRotate(targetIndex)
    if targetIndex>12 or targetIndex<0 then
        print("目标不合适")
        --self.bCanSwitchType = true
        sef.imgTitle:setEnabled(true)
        return
    end
    --播放转动音效
    audio.playSound("sound/rotate.mp3")
     --转动期间不能切换抽奖模式

    local ALLROTATE = 360       --360度
    local num = 12                   --总共12个格子
    local zhuanpanData =  -- 12个格子的角度范围
    {
        {start = (num-1)*ALLROTATE/num + 1,  ended = (num - 0)*ALLROTATE/num},
        {start = (num-2)*ALLROTATE/num + 1,  ended = (num - 1)*ALLROTATE/num},
        {start = (num-3)*ALLROTATE/num + 1,  ended = (num - 2)*ALLROTATE/num},
        {start = (num-4)*ALLROTATE/num + 1,  ended = (num - 3)*ALLROTATE/num},
        {start = (num-5)*ALLROTATE/num + 1,  ended = (num - 4)*ALLROTATE/num},
        {start = (num-6)*ALLROTATE/num + 1,  ended = (num - 5)*ALLROTATE/num},
        {start = (num-7)*ALLROTATE/num + 1,  ended = (num - 6)*ALLROTATE/num},
        {start = (num-8)*ALLROTATE/num + 1,  ended = (num - 7)*ALLROTATE/num},
        {start = (num-9)*ALLROTATE/num + 1,  ended = (num - 8)*ALLROTATE/num},
        {start = (num-10)*ALLROTATE/num + 1,  ended = (num - 9)*ALLROTATE/num},
        {start = (num-11)*ALLROTATE/num + 1,  ended = (num - 10)*ALLROTATE/num},
        {start = (num-12)*ALLROTATE/num + 0,  ended = (num - 11)*ALLROTATE/num},
    }

    local duration = 3 --转动时间
    local rotateNum = 3 --转动圈数
    local lastAngle = 0
    
   -- dump(self, "1 self")
   local rotation = self:getRotationAbs(self.panHandler)  --求指针与初始指向0点的位置角度，不考虑转了N圈的情况
   print("角色与0点位置的角度:" .. rotation)
   performWithDelay( self:getViewComponent() , function()
        print("performWithDelay 转盘")
        local targetData = zhuanpanData[targetIndex]
        --self.targetRotate = math.random(targetData.start, targetData.ended)  --目标格子到0点的角度
        self.targetRotate = (targetData.start + targetData.ended)/2.0
        print("self.targetRotate:" .. self.targetRotate)
        local rotateAngle =  self.targetRotate + 360 * rotateNum --总共打算要旋转角度(目标格子到0点的角度+旋转N圈的角度)
        print("将要旋转的随机角度 rotateAngle:" .. rotateAngle)
        --不是第一次旋转，之前已经转过了
        if rotation >  0 then  --第二次转 
            local rotateAngleee= rotateAngle - rotation  --旋转的角度里要去掉上次转过的角度，使重新从0点位置计算
            print("第二次旋转角度:" .. rotateAngleee)
            self:rotateSprite(self.panHandler, duration, rotateAngleee)
        else --第一次旋转
            print("第一次随机角度:" .. rotateAngle)
            self:rotateSprite(self.panHandler, duration, rotateAngle)
        end
        
    end , 0.1)
       
end

--获取当前抽奖礼品的转盘下标
function LotteryMediator:getCurDrawRollerIdx(iGiftId)
    print("LotteryMediator:getCurDrawRollerIdx")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local lotteryProxy = platformFacade:retrieveProxy("LotteryProxy")
    if iGiftId==nil then
       return -1
    end

    local listAward = {}
    if self.curType == 1 then   --免费抽奖
             print("免费抽奖")
            listAward = lotteryProxy:getData().freeGiftList --获取抽奖列表
            dump(listAward, "freeGiftList")        
    elseif self.curType == 2 then --付费抽奖
            print("付费抽奖")
            listAward = lotteryProxy:getData().vipGiftList
            --dump(listAward, "vipGiftList")
    end
    local len = #listAward
    for i=1,len do
        local award = listAward[i]
        if award.iAwardId == iGiftId then
            print("第"..i.."号奖品中奖")
            return i
        end 
    end

    print("末找到抽奖奖品")
    return -1   --找不到，返回-1
end

function LotteryMediator:listNotificationInterests()
    local PlatformConstants = cc.exports.PlatformConstants
	return {
        PlatformConstants.START_LOGOUT,
        PlatformConstants.UPDATE_LOTTERYFREELIST,
        PlatformConstants.UPDATE_LOTTERYVIPLIST,
        PlatformConstants.UPDATE_LOTTERYLIST,
        PlatformConstants.UPDATE_FREETIMES,
        PlatformConstants.UPDATE_PAYTIMES,
        PlatformConstants.RESULT_ROLLER,
        PlatformConstants.UPDATE_USERLOTTERYLIST,
        PlatformConstants.RESULT_WEIXINSHARE,
	}
end

function LotteryMediator:onRegister()
    print("LotteryMediator:onRegister")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local lotteryProxy = platformFacade:retrieveProxy("LotteryProxy")
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")
    
    platformFacade:registerCommand(PlatformConstants.REQUEST_LOTTERYLIST, cc.exports.RequestLotteryListCommand) --注册请求抽奖列表的命令
    platformFacade:registerCommand(PlatformConstants.REQUEST_DRAWLOTTER, cc.exports.RequestDrawLotteryCommand) --注册请求用户抽奖结果的命令
    platformFacade:registerCommand(PlatformConstants.REQUEST_LOTTERYLISTUSER, cc.exports.RequestListUserCommand) --注册请求用户自己抽奖列表的命令
    platformFacade:registerCommand(PlatformConstants.REQUEST_LOTTERYLISTTOTAL, cc.exports.RequestListTotalCommand) --注册请求所有用户抽奖列表的命令
    --platformFacade:registerCommand(PlatformConstants.REQUEST_USERINFO, cc.exports.RequestUserInfoCommand) --请求用户的所有信息，以更新钱，房卡
    platformFacade:registerCommand(PlatformConstants.START_LOTTERYBANDPHONE, cc.exports.StartBandPhoneCommand)  --请求打开绑定手机号
    platformFacade:registerCommand(PlatformConstants.START_LOTTERYGIFTANIM, cc.exports.StartGiftAnimCommand)  --请求抽奖动画


    local ui = cc.CSLoader:createNode("hall_res/lottery/lottery.csb")  --设置UI的csb
	self:setViewComponent(ui)
    local scene = platformFacade:retrieveMediator("HallMediator").scene --获取要加载上的场景
	scene:addChild(self:getViewComponent())

    --转盘灯的动画
    local animator = seekNodeByName(ui, "light_anim")
	local animation = cc.CSLoader:createTimeline("hall_res/lottery/light/zhuanpan.csb")
	animation:gotoFrameAndPlay(0, true)
	--animator:runAction(animation)

    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--背景
    --获取关闭按钮
    local btnClose = seekNodeByName(self.bgImg, "btn_close")
	if btnClose then
		btnClose:addClickEventListener(function()
            btnClose:setZoomScale(-0.1)
			platformFacade:removeMediator("LotteryMediator")
		end)
	end

    local imgWheel = seekNodeByName(self.bgImg, "imgWheel")   --获取转盘
    self.btnStart = seekNodeByName(imgWheel, "btnStart")  --开始按钮

    if self.btnStart then
       self.txtStart = seekNodeByName(self.btnStart, "txtStart")
       self.btnStart:addClickEventListener(function()
            self.btnStart:setZoomScale(-0.1)
            print("self.curType(当前抽奖类型) = " .. self.curType)
            --启动抽奖绑定手机界面
            print("启动抽奖绑定手机界面")
            local bBindPhone =  userinfo:getData().bMobileBind --是否绑定手机？
            local strMobile = userinfo:getData().mobile
            dump(userinfo:getData().bMobileBind, "bBindPhone")
            dump(userinfo:getData().mobile, "mobile")
            
            if bBindPhone==false or strMobile=="" then   --没有绑定手机(收费模式才要绑定)
                platformFacade:registerMediator(BandPhoneMediator.new(self:getViewComponent()))
                return
            end
            --已经绑定过手机
            local numDraw = 0  --剩余抽奖次数
            if self.curType == 1 then --免费抽奖
                numDraw = lotteryProxy:getData().freeTimes
            else
                numDraw = lotteryProxy:getData().payTimes
            end
            if numDraw <=0 then
                print("今日抽奖次数已经用完")
                platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "今日抽奖次数已经用完")
                return
            end
            
            --local drawResult = self:buildDrawResult()
            --lotteryProxy:getData().rollerResult = drawResult
            --platformFacade:sendNotification(PlatformConstants.RESULT_ROLLER, true)
            --发起抽奖请求 要的
            platformFacade:sendNotification(PlatformConstants.REQUEST_DRAWLOTTER, self.curType) --发送抽奖请求
            self.btnStart:setEnabled(false)
		end)
       
    else
       print("btnStart is nil")
    end
    self.panHandler = seekNodeByName(imgWheel, "imgHander")  --转盘指针
    --我的抽奖纪录按钮
    self.imgMyRecord = seekNodeByName(self.bgImg, "imgMyRecord")
    --所有人的抽奖纪录按钮
    self.imgAwardRecord = seekNodeByName(self.bgImg, "imgAwardRecord")
    self.orginZorder = self.imgMyRecord:getLocalZOrder()
    self.imgMyRecord:addClickEventListener(function() 
        if self.recordType==1 then
           return  --当前已经是用户自己的纪录模式
        else
           self.recordType = 1
           self.imgMyRecord:loadTexture("platform_res/lottery/jl-2.png") --设置图片
           self.imgAwardRecord:loadTexture("platform_res/lottery/jl-3.png")
           --交换下我的纪录和所有纪录的ZOrder
           local myOrder = self.imgMyRecord:getLocalZOrder()
           local allOrder = self.imgAwardRecord:getLocalZOrder()
           --local tempOrder = myOrder
           myOrder = self.orginZorder +1
           allOrder = self.orginZorder
           self.imgMyRecord:setLocalZOrder(myOrder)
           self.imgAwardRecord:setLocalZOrder(allOrder)

           --显示用户抽奖纪录列表
           self:showRecordList()
        end
    end)

    self.imgAwardRecord:addClickEventListener(function()
        print("self.recordType:" .. self.recordType)
        if self.recordType==2 then
           return
        else
           self.recordType = 2
           self.imgMyRecord:loadTexture("platform_res/lottery/jl-1.png") --设置图片
           self.imgAwardRecord:loadTexture("platform_res/lottery/jl-4.png")
           --交换下我的纪录和所有纪录的ZOrder
           local myOrder = self.imgMyRecord:getLocalZOrder()
           local allOrder = self.imgAwardRecord:getLocalZOrder()
           --local tempOrder = myOrder
           myOrder = self.orginZorder
           allOrder = self.orginZorder + 1
           self.imgMyRecord:setLocalZOrder(myOrder)
           self.imgAwardRecord:setLocalZOrder(allOrder)
           --发送请求用户抽奖纪录的请求
           --platformFacade:sendNotification(PlatformConstants.REQUEST_LOTTERYLISTTOTAL)
           print("click imgAwardRecord")
           self:showRecordList()
        end
    end)

    local listBg = seekNodeByName(self.bgImg, "imgRank")  --列表背景
    if listBg == nil then
       print("listBg = nil")
    end
    self.listAward = seekNodeByName(listBg, "listAward") --列表控件
     if self.listAward == nil then
       print("self.listAward = nil")
    end
    self.TemplateList = seekNodeByName(listBg, "PanelAward") --列板模板
    self.TemplateList:setVisible(false)

    self.imgTitle = seekNodeByName(self.bgImg, "img_title")
    self.btnLeftSelect = seekNodeByName(self.bgImg, "panel_left")  --转盘类型左选择按钮
    self.btnRightSelect = seekNodeByName(self.bgImg, "panel_right")  --转盘类型右选择按钮
    self.curType = cc.UserDefault:getInstance():getIntegerForKey("lotteryCurrentType",1)

    self.btnLeftSelect:addClickEventListener(function()   
       if self.curType==1 then --当前是免费抽奖,切为付费抽奖
          self.imgTitle:loadTexture("platform_res/lottery/zzl.png")
          self.curType = 2
          cc.UserDefault:getInstance():setIntegerForKey("lotteryCurrentType", 2)
          --设置剩余抽奖次数
          local nums = lotteryProxy:getData().payTimes
          self.txtStart:setString(tostring(nums).."次")
          self.txtDrawNum:setString(tostring(nums).."次")
         --刷新转盘奖品
          local listAward = lotteryProxy:getData().vipGiftList
          self:showAwardList(listAward) --刷新显示出付费抽奖
        end
    end)
    self.btnRightSelect:addClickEventListener(function()
        if self.curType==2 then  --切为免费抽奖
          self.imgTitle:loadTexture("platform_res/lottery/xycj.png")
          --设置剩余抽奖次数
          local nums = lotteryProxy:getData().freeTimes
          self.txtStart:setString(tostring(nums).."次")
          self.txtDrawNum:setString(tostring(nums).."次")
          local listAward = lotteryProxy:getData().freeGiftList
          self.curType = 1
          cc.UserDefault:getInstance():setIntegerForKey("lotteryCurrentType", 1)
          self:showAwardList(listAward)
       end
    end)


    --抽奖次数
    self.txtDrawNum = seekNodeByName(self.bgImg, "txtDrawNum")
    self.txtRotateResult = seekNodeByName(self.bgImg, "txtRotateResult")

    local btnShare = seekNodeByName(self.bgImg, "btnShare")
    if btnShare then
       btnShare:addClickEventListener(function()
          print("click btnShare")
          --platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX, "功能尚未开放")          
          --发送分享
            local gameName = cc.exports.getProductName()
            local strImgPath = cc.FileUtils:getInstance():fullPathForFilename("platform_res/share/share.png") --图标
            local strTitle = "分享好友"
            local strDesc = "长按二维码免费领房卡礼包并可参与" .. gameName .."所有活动。\n" .. gameName .."戏活动，日送十万豪礼。"
            local strScene = "1"  --0 分享到好友   1 分享到朋友圈
            cc.exports.wxShareFriends(ShareFriendUrl, strTitle, strDesc, strImgPath, strScene)  --发送请求微信分享的请求

       end)
    end

    --抽奖启动时请求抽奖的奖品列表
    platformFacade:sendNotification(PlatformConstants.REQUEST_LOTTERYLIST)
    platformFacade:sendNotification(PlatformConstants.REQUEST_LOTTERYLISTTOTAL)
    platformFacade:sendNotification(PlatformConstants.REQUEST_LOTTERYLISTUSER)
   --显示玩家自己的中奖列表
   --self:showRecordList()

end

--显示抽奖列表
function LotteryMediator:showAwardList(lotteryList)
    print("LotteryMediator:showFreeAwardList")
    --local lotteryList = self:buildFreeAwardList()   --获取免费抽奖列表
    local len = #lotteryList
    if len <= 0 then
        print("抽奖列表为空")
        return
    end
    --local ui = self:getViewComponent()
    local imgWheel = seekNodeByName(self.bgImg, "imgWheel")   --获取转盘
    
    local imgAward = nil
    local txtAward = nil
    for i=1, len do
        local sAwardImg = "imgAward"
        local iconPath = "platform_res/icons/"   --图标路径
        local sTxtAward = "txtAward"
        sAwardImg = sAwardImg .. tostring(i)
        --转盘上的图片
        imgAward = seekNodeByName(imgWheel, sAwardImg)
        if imgAward==nil then
           print("imgAward:".. sAwardImg .. " = nil")
           break
        end
        iconPath = iconPath .. tostring(lotteryList[i].sIcon)
        --print("iconPath = " .. iconPath)
        imgAward:loadTexture(iconPath)
        --转盘上的文字
        sTxtAward = sTxtAward .. tostring(i)
        txtAward = seekNodeByName(imgWheel, sTxtAward)
        if txtAward == nil then
           print("txtAward:" .. sTxtAward .. " = nil")
           return
        end
        --设置居中对齐，0：左对齐，1：居中， 2：右对齐
        txtAward:setTextHorizontalAlignment(1)
        txtAward:setString(lotteryList[i].sPropName)     
    end
end

function LotteryMediator:showRecordList()
    print("LotteryMediator:showRecordList")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	local lotteryProxy = platformFacade:retrieveProxy("LotteryProxy")
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")
    local list = {}
    if self.recordType==1 then --用户列表
       --list = self:buildUserAwardList()
       print("用户列表")
       list = lotteryProxy:getData().vlogList
       dump(list, "lotteryProxy:getData().vlogList")
    else --全体用户列表
       --list = self.buildUserAwardList()
       print("全体用户列表")
       local lstTotal = lotteryProxy:getData().vTotalList
       dump(lstTotal," lotteryProxy:getData().vTotalList")
       for _,v in ipairs(lstTotal) do
		 table.insert(list, v.rData)
	   end
    end
    
    self.listAward:removeAllChildren()
    for i=1,#list do
       local awardItem = self.TemplateList:clone()
       awardItem:setVisible(true)
       local txtUser = seekNodeByName(awardItem, "txtUser")
       local txtDate = seekNodeByName(awardItem, "txtDate")
       local txtGift = seekNodeByName(awardItem, "txtGift")
       --设置居中对齐，0：左对齐，1：居中， 2：右对齐
       txtUser:setTextHorizontalAlignment(1)
       txtDate:setTextHorizontalAlignment(1)
       txtGift:setTextHorizontalAlignment(1)

       local strDate = os.date("%Y/%m/%d", list[i].lTime)
       local strUsrName = list[i].sNickName
       local strGiftName = list[i].sPropName

       txtUser:setString(strUsrName)
       txtDate:setString(strDate)
       txtGift:setString(strGiftName)
       self.listAward:pushBackCustomItem(awardItem)
    end
    
    
end

function LotteryMediator:handleNotification(notification)
    print("LotteryMediator:handleNotification")
    local name = notification:getName()
    local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	local lotteryProxy = platformFacade:retrieveProxy("LotteryProxy")
    local numFreeTimes = 0  --免费抽奖次数
    local numPayTimes = 0   --付费抽奖次数
    local listAward = {}
    if name == PlatformConstants.START_LOGOUT then
		platformFacade:removeMediator("LotteryMediator")
        platformFacade:removeProxy("LotteryProxy")
    elseif name == PlatformConstants.UPDATE_LOTTERYLIST then  --获取到奖品列表的更新
        print("name == PlatformConstants.UPDATE_LOTTERYLIST")
        if self.curType == 1 then   --免费抽奖
             print("免费抽奖")
            listAward = lotteryProxy:getData().freeGiftList
            --listAward = self:buildFreeAwardList()  --构造的假数据
            --dump(listAward, "freeGiftList")
            self:showAwardList(listAward)
        elseif self.curType == 2 then --付费抽奖
            print("付费抽奖")
            listAward = lotteryProxy:getData().vipGiftList
            --dump(listAward, "vipGiftList")
            self:showAwardList(listAward)
        end    
    elseif name == PlatformConstants.UPDATE_FREETIMES then  --更新免费抽奖次数
        print("name == PlatformConstants.UPDATE_FREETIMES")
        numFreeTimes = lotteryProxy:getData().freeTimes
        print("numFreeTimes = " .. numFreeTimes)
        if self.curType == 1 then   --当前是免费转盘
           self.txtStart:setString(tostring(numFreeTimes).."次")
           self.txtDrawNum:setString(tostring(numFreeTimes).."次")
        end
        
    elseif name == PlatformConstants.UPDATE_PAYTIMES then
        print("name == PlatformConstants.UPDATE_PAYTIMES")
        numPayTimes = lotteryProxy:getData().payTimes
        if self.curType == 2 then   --当前是付费转盘
           self.txtStart:setString(tostring(numPayTimes).."次")
           self.txtDrawNum:setString(tostring(numPayTimes).."次")
        end
        
    elseif name == PlatformConstants.RESULT_ROLLER then --抽奖结果
       --隐藏loading界面
       cc.exports.hideLoadingAnim()
       local bSucc = notification:getBody()
       if bSucc == true then
           print("draw succ")
           dump(lotteryProxy:getData().rollerResult, "rollResult")
           local rollerData =  lotteryProxy:getData().rollerResult
           if rollerData==nil then
              print("末能获得抽奖结果")
              self.btnStart:setEnabled(true)
              self.imgTitle:setEnabled(true)
              return
           end
           local iAwardId = rollerData.iAwardId  --获取奖品ID
           print("iAwardId = " .. iAwardId)
           local index = self:getCurDrawRollerIdx(iAwardId)
           if index==-1 then
              print("没找到此抽奖物品")
              self.btnStart:setEnabled(true)
              self.imgTitle:setEnabled(true)
              return
           end
           --开始转动
           --self.bCanSwitchType = false
           --self.txtRotateResult:setString(tostring(self.bCanSwitchType))
           print("开始转动")
           self.imgTitle:setEnabled(false)  --转动时不让Title可以来回切换
           self:lotteryRotate(index)
           --更新玩家身上的金币，钻石，房卡
           platformFacade:sendNotification(PlatformConstants.UPDATE_USERWEALTH)
       else
           print("draw failed!")
           self.btnStart:setEnabled(true)
           self.imgTitle:setEnabled(true)
       end
    elseif name == PlatformConstants.UPDATE_USERLOTTERYLIST then
        print("receive UPDATE_USERLOTTERYLIST")
        self:showRecordList() --显示纪录列表
    elseif name == PlatformConstants.UPDATE_TOTALLOTTERYLIST then
        print("receive UPDATE_TOTALLOTTERYLIST")
        self:showRecordList() --显示纪录列表
    elseif name == PlatformConstants.RESULT_WEIXINSHARE then
        print("RESULT_WEIXINSHARE 微信分享结果")
        if body == 0 then
           print("抽奖分享好友成功")
           platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "抽奖分享朋友圈成功")
        else
          print("抽奖分享好友失败，错误码:" .. tostring(body))
          platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "抽奖分享朋友圈失败")
        end
	end
end

function LotteryMediator:onRemove()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
	platformFacade:removeCommand(PlatformConstants.REQUEST_LOTTERYLIST)
    platformFacade:removeCommand(PlatformConstants.REQUEST_DRAWLOTTER)
    platformFacade:removeCommand(PlatformConstants.REQUEST_LOTTERYLISTUSER)
    platformFacade:removeCommand(PlatformConstants.REQUEST_LOTTERYLISTTOTAL) 
    --platformFacade:removeCommand(PlatformConstants.REQUEST_USERINFO)
    platformFacade:removeCommand(PlatformConstants.START_LOTTERYBANDPHONE)
    platformFacade:removeCommand(PlatformConstants.START_LOTTERYGIFTANIM)
    

    self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)

end

return LotteryMediator
--endregion
