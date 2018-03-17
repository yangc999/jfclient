--region *.lua
--Date
--绑定朋友邀请码
local Mediator = cc.load("puremvc").Mediator
local BindFriendInviteCodeMediator = class("BindFriendInviteCodeMediator", Mediator)

function BindFriendInviteCodeMediator:ctor()
	BindFriendInviteCodeMediator.super.ctor(self, "BindFriendInviteCodeMediator")
end

function BindFriendInviteCodeMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
        PlatformConstants.START_LOGOUT,
	}
end

function BindFriendInviteCodeMediator:onRegister()
    print(" BindFriendInviteCodeMediator:onRegister")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local taskProxy = platformFacade:retrieveProxy("TaskProxy")

    platformFacade:registerCommand(PlatformConstants.REQUEST_BINDINVITECODE, cc.exports.RequestBindInviteCodeCommand)  --请求绑定邀请码
    -- platformFacade:registerCommand(PlatformConstants.REQUEST_TASKSHARE_AWARD, cc.exports.RequestGetTaskShareAwardCommand)  --完成任务请求,领取奖励

    local ui = cc.CSLoader:createNode("hall_res/bandViteCode/bandfriendcode.csb")  --设置UI的csb
	self:setViewComponent(ui)
    --local scene = platformFacade:retrieveMediator("HallMediator").scene --获取要加载上的场景
    local scene = cc.Director:getInstance():getRunningScene()
	scene:addChild(self:getViewComponent()) --获取大厅的Mediator，加载这个公告场景

    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--背景

    --获取关闭按钮
    local btnClose = seekNodeByName(self.bgImg, "btn_close")
	if btnClose then
		btnClose:addClickEventListener(function()
            btnClose:setZoomScale(-0.1)
			platformFacade:removeMediator("BindFriendInviteCodeMediator")
		end)
	end
    local textMessage = seekNodeByName(self.bgImg,"text_message")
    print("bindFriend_jay textMessage:",textMessage)
    if textMessage then
        local msgContent = "绑定邀请码赠送"
        local taskList = taskProxy:getData().taskInfo  --获取任务数据
        local taskObj = nil
        for i =1, #taskList do
            taskObj = taskList[i]
            local taskId = taskObj.iTaskId
            if taskId==9 then  --绑定
                local iAwardType = taskObj.iRewardType
                if iAwardType == 11 then --奖励为金币
                    msgContent = msgContent.."金币"
                elseif iAwardType == 12 then --奖励为房卡
                    msgContent = msgContent.."房卡"
                elseif iAwardType == 13 then --奖励为钻石
                    msgContent = msgContent.."钻石"
                end
                msgContent = msgContent..tostring(taskObj.iRewardValue)
            end
        end
        print("bindFriend_jay msgContent:"..msgContent)
        textMessage:setString(msgContent)
    end

    --获取输入邀请码文本框
    local testmessage = self.bgImg:getChildByName("inputID") --获取输入框背景
    local sizetextmessage1 = testmessage:getContentSize()
    sizetextmessage1.width = sizetextmessage1.width
    sizetextmessage1.height = sizetextmessage1.height
    local positionx,positiony = testmessage:getPosition()
    testmessage:setVisible(false)
    --替换成自己定义的EditBox
    self.TextField_input = cc.EditBox:create(cc.size(sizetextmessage1.width,sizetextmessage1.height),"platform_res/forgetpwd/inputeidtbox.png")
    self.TextField_input:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)--cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_SENTENCE)platform_res/common/shurukuang-big.png
    self.TextField_input:setInputMode(cc.EDITBOX_INPUT_MODE_DECIMAL) 
    self.TextField_input:setPosition(cc.p(positionx,positiony))
    self.TextField_input:setAnchorPoint(cc.p(0.5, 0.5))
    self.TextField_input:setPlaceHolder('请输入邀请码')
    self.TextField_input:setPlaceholderFontSize(30)
    self.TextField_input:setFontColor(cc.c3b(33,38,48))
    self.TextField_input:setFontSize(30)
    self.TextField_input:setMaxLength(8)
	self.TextField_input:setIgnoreAnchorPointForPosition(false)
    self.bgImg:addChild(self.TextField_input)

    local btnBind = seekNodeByName(self.bgImg, "btn_band")  --获取绑定按钮
    if btnBind then
       btnBind:addClickEventListener(function()
            btnBind:setZoomScale(-0.1)
			--platformFacade:removeMediator("BindFriendInviteCodeMediator")
            local strInviteCode = string.trim(self.TextField_input:getText())
            if #strInviteCode > 0 then
                local taskId = 9   --绑定朋友圈的任务ID
                local tReqBody = {taskID = taskId, inviteCode = strInviteCode}
                platformFacade:sendNotification(PlatformConstants.REQUEST_BINDINVITECODE, tReqBody)
                --延时0.5秒关闭界面
                performWithDelay(self:getViewComponent() , function() 
                   print("performWithDelay close BindInviteCodeUI")
                   platformFacade:removeMediator("BindFriendInviteCodeMediator")
                end, 0.5)
            else
                platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "请输入邀请码再进行尝试噢~")
            end

      end)
    end
end

function BindFriendInviteCodeMediator:handleNotification(notification)
    local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local bindProxy = platformFacade:retrieveProxy("BindInviteCodeProxy")  --
    if name == PlatformConstants.START_LOGOUT then
		platformFacade:removeMediator("BindFriendInviteCodeMediator")
	end

end

function BindFriendInviteCodeMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
	platformFacade:removeCommand(PlatformConstants.REQUEST_BINDINVITECODE)
    -- platformFacade:removeCommand(PlatformConstants.REQUEST_TASKSHARE_AWARD)

	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

return BindFriendInviteCodeMediator


--endregion
