--region *.lua
--Date
--任务分享的UI
local Mediator = cc.load("puremvc").Mediator
local TaskShareMediator = class("TaskShareMediator", Mediator)
local ShareFriendUrl = "http://share.game4588.com"  --好友分享网址

--优先分享好友
local shareFriend = 4   --分享朋友圈
local inviteFriend = 5   --邀请好友
local bindPhoneId = 9  --绑定手机

local rewardGold=11  --金币
local rewardRoomCard=12 --房卡
local rewardDiamond=13  --钻石

function TaskShareMediator:ctor()
    TaskShareMediator.super.ctor(self, "TaskShareMediator")
    --self.root = root
    --self.oldItem = nil
    --self.curIndex = -1
end

function TaskShareMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
        PlatformConstants.START_LOGOUT,  --退出
        PlatformConstants.UPDATE_TASKSHARE_INFO,  --更新任务共享的信息
        PlatformConstants.SHARE_FINISH,
        PlatformConstants.BIND_SUCCESS,
	}
end

function TaskShareMediator:onRegister()
	print("TaskShareMediator:onRegister")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    --RequestGetTaskShareAwardCommand
    platformFacade:registerCommand(PlatformConstants.REQUEST_TASKSHARE, cc.exports.RequestTaskSharesCommand)  --请求分享任务信息
    platformFacade:registerCommand(PlatformConstants.REQUEST_TASKSHARE_CONFIG, cc.exports.RequestTaskShareConfigCommand)  --请求任务配置信息
    -- platformFacade:registerCommand(PlatformConstants.REQUEST_TASKSHARE_AWARD, cc.exports.RequestGetTaskShareAwardCommand)  --完成任务请求,领取奖励
    platformFacade:registerCommand(PlatformConstants.BINDFRIENDCODE_START, cc.exports.StartBindFriendInviteCodeCommand) --启动绑定朋友邀请码UI

    local ui = cc.CSLoader:createNode("hall_res/share/taskshare.csb")  --设置UI的csb
	self:setViewComponent(ui)
    local scene = platformFacade:retrieveMediator("HallMediator").scene --获取要加载上的场景
	scene:addChild(self:getViewComponent()) --获取大厅的Mediator

    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--背景
    self.list = seekNodeByName(self.bgImg, "lstTask")  --获取滚动列表
	self.list:setScrollBarEnabled(false)
    self.list:removeAllItems()

     --获取关闭按钮
    local btnClose = seekNodeByName(self.bgImg, "btn_close")
	if btnClose then
		btnClose:addClickEventListener(function()
            btnClose:setZoomScale(-0.1)
			platformFacade:removeMediator("TaskShareMediator")
		end)
	end

    --启动时刷新任务列表
    self:updateListView()
end

function TaskShareMediator:updateListView()
    print("TaskShareMediator:updateListView")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
	local taskProxy = platformFacade:retrieveProxy("TaskProxy")
    --local bindProxy = platformFacade:retrieveProxy("BindInviteCodeProxy")

    self.list:removeAllItems()

    local taskList = taskProxy:getData().taskInfo  --获取任务数据
    dump(taskList,"任务分享列表")

    local taskObj = nil
    local strInviteCode = ""  --邀请码
    for i =1, #taskList do
        taskObj = taskList[i]
        dump(taskObj, "taskObj share:")
        local itemDemo = cc.CSLoader:createNode("hall_res/share/taskitem.csb")  --设置UI的csb
        local item = seekNodeByName(itemDemo,"item")
        item:removeFromParent(false)

        local message_nowatch_2 = seekNodeByName(item, "message_nowatch_2")  --任务图标
        local txtTaskName = seekNodeByName(item, "txtName")         --任务名
        local txtCoin = seekNodeByName(item, "txtCoin")                    --奖励金币
        local txtTaskProgress = seekNodeByName(item, "txtDesc")      --任务进度
        local awardIcon = seekNodeByName(item, "imgCoin")              --任务图标
        local slidProgress = seekNodeByName(item, "slidProgress")       --滑动进度条

        local taskId = taskObj.iTaskId
        message_nowatch_2:loadTexture( string.format("platform_res/share/task-%d.png", taskId))  --设置任务图标

        txtTaskName:setString(taskObj.sTaskName)
        txtCoin:setString(tostring(taskObj.iRewardValue))

        print("reward type:".. tostring(taskObj.iRewardType))  --奖励类型
        local iAwardType = taskObj.iRewardType
        if iAwardType == rewardGold then --奖励为金币
           awardIcon:loadTexture("platform_res/share/jinbi.png")  --设置奖励的图标
        elseif iAwardType == rewardRoomCard then --奖励为房卡
           awardIcon:loadTexture("platform_res/share/fangka.png")
        elseif iAwardType == rewardDiamond then --奖励为钻石
           awardIcon:loadTexture("platform_res/share/diamond.png")
        end

        local iCurrCount = taskObj.iCurrentCount --当前任务完成次数
        local iTaskTotalCount = taskObj.iTaskAvailableCount  --当前任务总可完成次数
        print("shareData 任务当前完成数 : " .. iCurrCount)
        print("shareData 任务总可完成数 : " .. iTaskTotalCount)
        if iCurrCount==nil then --防空判断
            iCurrCount = 0
        end
        if iTaskTotalCount==nil then
           iTaskTotalCount = 1
        end

        local strProgress = string.format("%d/%d", iCurrCount, iTaskTotalCount) --当前任务完成进度
        txtTaskProgress:setString(strProgress)
        local percent = iCurrCount/iTaskTotalCount
        percent = percent * 100
        percent = math.ceil(percent)

        slidProgress:setPercent(percent)

        local btnShare = seekNodeByName(item, "btnShare")
        local txtBtnShare = seekNodeByName(btnShare, "txtShare")
        local strImgPath = cc.FileUtils:getInstance():fullPathForFilename("platform_res/share/share.png") --图标
        
        --邀请码
        if taskId == inviteFriend then
           strInviteCode = taskObj.sTValue
           taskProxy:getData().friendCode = strInviteCode --设定邀请码
        end
        if iCurrCount < iTaskTotalCount then  --未成功完执行任务
            if taskId== shareFriend then
                txtBtnShare:setString("分 享")
                btnShare:addClickEventListener(function()
                   self:shareFriends()
                end)
            elseif taskId== inviteFriend then
                txtBtnShare:setString("邀 请")
                btnShare:addClickEventListener(function() 
                    print("执行 self:inviteFriends")
                    self:inviteFriends(strInviteCode)
                end)
            elseif taskId== bindPhoneId then
                txtBtnShare:setString("绑定邀请码")
                btnShare:addClickEventListener(function() 
                    self:showBindInviteCodeUI()
                end) 
            end
        else  --iCurrCount >= iTaskTotalCount  这个任务已经完成所有要求的任务数
             if taskObj.iRewardStatus == 1 then --成功末领取
                txtBtnShare:setString("领 取")
                btnShare:addClickEventListener(function()
                    platformFacade:sendNotification(PlatformConstants.REQUEST_TASK_INFO, taskId)  --发送领取奖励的请求
                end)
             elseif taskObj.iRewardStatus == 3 then --成功且领取了奖励
                btnShare:setEnabled(false)
                
                if taskId== shareFriend then
                    txtBtnShare:setString("已分享")
                elseif taskId == inviteFriend then
                    txtBtnShare:setString("已邀请")
                elseif taskId == bindPhoneId then
                    txtBtnShare:setString("已绑定")
                end
                txtBtnShare:enableOutline(cc.c3b(93, 93, 93), 2)  --设置字体描边效果
             end  -- end if taskObj.iRewardStatus == 1 then --成功末领取
        end -- end  if iCurrCount < iTaskTotalCount the
       

         if taskObj.iExcution == 1 then
            btnShare:setEnabled(false)
            if taskId ==  bindPhoneId then
               txtBtnShare:setString("已绑定")
               txtBtnShare:enableOutline(cc.c3b(93, 93, 93), 2)  --设置字体描边效果
            end
        end

        self.list:pushBackCustomItem(item)
    end
end

function TaskShareMediator:shareFriends() --分享好友
    print("分享好友开始 shareFriends")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local weixin = plugin.PluginManager:getInstance():loadPlugin("ShareWeixin")
    local gameName = cc.exports.getProductName()
    local strDesc = "长按二维码免费领房卡礼包并可参与" .. gameName .."所有活动。\n" .. gameName .."戏活动，日送十万豪礼"
    local tVisit = {url = ShareFriendUrl,
        title="分享好友",
        desc = strDesc,
        imgPath =  strImgPath,
        scene = "1"  --0是分享好友，1是朋友圈
    }
	if weixin then
		weixin:setDebugMode(true)
		weixin:configDeveloperInfo({AppId="wx41d5f85d4cde056b"})
		weixin:share(tVisit, function(code, msg)
			if code == 0 then
                print("shareData 分享朋友圈成功")

                -- platformFacade:sendNotification(PlatformConstants.REQUEST_TASKSHARE_AWARD, shareFriend) --请求完成任务
           else
               print("shareData code = " .. code)
               print("shareData 分享朋友圈失败")
               platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "分享失败，请重新尝试")
			end
		end)
	end
end

--邀请好友
function TaskShareMediator:inviteFriends(strInviteCode)
    print("邀请好友 TaskShareMediator:inviteFriends code:" .. tostring(strInviteCode))
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local weixin = plugin.PluginManager:getInstance():loadPlugin("ShareWeixin")
    local gameName = cc.exports.getProductName()
    local strDesc = "在" .. gameName .."，输入我的邀请码【" .. strInviteCode .."】，既有好礼赠送哟"
    local tVisit = {url = ShareFriendUrl,
        desc = strDesc,
        imgPath =  strImgPath,
        title = "邀请好友",
        scene = "0",
    }
	if weixin then
		weixin:setDebugMode(true)
		weixin:configDeveloperInfo({AppId="wx41d5f85d4cde056b"})
		weixin:share(tVisit, function(code, msg)
			if code == 0 then
                print("邀请好友成功")
                --platformFacade:sendNotification(PlatformConstants.UPDATE_TASKSHARE_INFO)  --发消息更新任务列表
                --platformFacade:sendNotification(PlatformConstants.REQUEST_TASKSHARE_AWARD, inviteFriend)
			end
		end)
	end
end

function TaskShareMediator:showBindInviteCodeUI()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    platformFacade:sendNotification(PlatformConstants.BINDFRIENDCODE_START)  --启动绑定朋友邀请码
end

function TaskShareMediator:handleNotification(notification)
    local name = notification:getName()
	local body = notification:getBody()
    print("TaskShareJAY",name,"body:",body)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    if name == PlatformConstants.START_LOGOUT then  --登出游戏
        platformFacade:removeMediator("TaskShareMediator")
    elseif name == PlatformConstants.UPDATE_TASKSHARE_INFO then  --更新任务
        self:updateListView()
    elseif name == PlatformConstants.SHARE_FINISH then  --领取金币完成弱提示
        self:updateListView()
        self:shareFinish(body)
    elseif name == PlatformConstants.BIND_SUCCESS then  --绑定成功
        -- platformFacade:removeMediator("BindFriendInviteCodeMediator") --关闭绑定邀请码UI
        -- print("BIND_SUCCESS")
        -- platformFacade:sendNotification(PlatformConstants.REQUEST_TASKSHARE_AWARD, bindPhoneId)--绑定成功发送领取金币请求
	end	
end

function TaskShareMediator:shareFinish(finishTaskId)

    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
    local taskProxy = platformFacade:retrieveProxy("TaskProxy")
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")
    local taskList = taskProxy:getData().taskInfo  --获取任务数据
    local taskName = nil

    if finishTaskId==shareFriend then
        taskName="分享任务完成"
    elseif finishTaskId==inviteFriend then
        taskName="邀请任务完成"
    elseif finishTaskId==bindPhoneId then
        taskName="绑定邀请码成功"
    end

    for i =1, #taskList do
        local taskObj = taskList[i]
        local taskId = taskObj.iTaskId
        if finishTaskId==taskId then 
            local rewardValue=tostring(taskObj.iRewardValue)
            local rewardTypeName=nil
            local iAwardType = taskObj.iRewardType
            if iAwardType == rewardGold then
                rewardTypeName="金币"
                platformFacade:sendNotification(PlatformConstants.UPDATE_GOLD,userinfo:getData().gold+taskObj.iRewardValue)
            elseif iAwardType == rewardRoomCard then
                rewardTypeName="房卡"
                platformFacade:sendNotification(PlatformConstants.UPDATE_GOLD,userinfo:getData().roomCard+taskObj.iRewardValue)
            elseif iAwardType == rewardDiamond then
                rewardTypeName="钻石"
                platformFacade:sendNotification(PlatformConstants.UPDATE_GOLD,userinfo:getData().diamond+taskObj.iRewardValue)
            end
            print("TaskShareJAY finishTaskId:",finishTaskId,"taskName:",taskName,"rewardValue:",rewardValue,"rewardTypeName:",rewardTypeName)
            platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, taskName.."，恭喜获得"..rewardValue..rewardTypeName)
        end
    end

end

function TaskShareMediator:onRemove()

	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
	platformFacade:removeCommand(PlatformConstants.REQUEST_TASKSHARE)
	platformFacade:removeCommand(PlatformConstants.REQUEST_TASKSHARE_CONFIG)
    -- platformFacade:removeCommand(PlatformConstants.REQUEST_TASKSHARE_AWARD) 
    platformFacade:removeCommand(PlatformConstants.BINDFRIENDCODE_START)

    self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

return TaskShareMediator

--endregion
