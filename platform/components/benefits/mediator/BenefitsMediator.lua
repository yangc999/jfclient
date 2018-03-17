
local Mediator = cc.load("puremvc").Mediator
local BenefitsMediator = class("BenefitsMediator", Mediator)

function BenefitsMediator:ctor(root)
	BenefitsMediator.super.ctor(self, "BenefitsMediator", root)
end

function BenefitsMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
        PlatformConstants.UPDATE_TASKINFO, 
        PlatformConstants.UPDATE_ASSISTANCE_TIMES,
        PlatformConstants.UPDATE_MOBILEBIND,
	}
end

function BenefitsMediator:onRegister()

	print("BenefitsMediator:onRegister")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    platformFacade:registerCommand(PlatformConstants.REQUEST_BENEFITS, cc.exports.RequestBenefitsCommand)
    platformFacade:registerCommand(PlatformConstants.REQUEST_BENEFITS_CONFIG, cc.exports.RequestBenefitsConfigCommand)  --根据ID显示公告
    platformFacade:registerCommand(PlatformConstants.SHOW_SIGN, cc.exports.ShowSignCommand)  --根据ID显示公告
    platformFacade:registerCommand(PlatformConstants.SHOW_BINDPHONENUMBER, cc.exports.StartBindMobileCommand)  --显示绑定手机
    platformFacade:registerCommand(PlatformConstants.SHOW_ASSISTANCE_TIPS, cc.exports.ShowAssistanceTipsCommand)  --显示破产补助提示
    platformFacade:registerCommand(PlatformConstants.REQUEST_TASK_INFO, cc.exports.RequestGetTaskAwardCommand)  --完成任务请求


    local ui = cc.CSLoader:createNode("hall_res/benefits/benefitsLayer.csb")  --设置UI的csb
	self:setViewComponent(ui)
    local scene = platformFacade:retrieveMediator("HallMediator").scene --获取要加载上的场景
	scene:addChild(self:getViewComponent()) --获取大厅的Mediator，加载这个公告场景s

    --公告栏的滚动列表
    --self.bgImg = self:getChildByName("Panel_1"):getChildByName("bg") --背景
    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--背景
    self.list = seekNodeByName(self.bgImg, "ListView_1")
	self.list:setScrollBarEnabled(false)
    self.list:removeAllItems()


    --获取关闭按钮
    local btnClose = seekNodeByName(self.bgImg, "btn_close")
	if btnClose then
		btnClose:setZoomScale(-0.1)
		btnClose:addClickEventListener(function()
			platformFacade:removeMediator("BenefitsMediator")
		end)
	end

    --先请求下看能否领取

    --大厅启动时请求公告列表
    self:updateListView()
    print("BenefitsMediator:End OnRegister")
end

function BenefitsMediator:startCountDown()

end

function BenefitsMediator:stopCountDown()

end 

function BenefitsMediator:onRemove()

	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
	platformFacade:removeCommand(PlatformConstants.REQUEST_BENEFITS)
	platformFacade:removeCommand(PlatformConstants.REQUEST_BENEFITS_CONFIG)
	platformFacade:removeCommand(PlatformConstants.SHOW_SIGN)
	platformFacade:removeCommand(PlatformConstants.SHOW_BINDPHONENUMBER)
    platformFacade:removeCommand(PlatformConstants.SHOW_ASSISTANCE_TIPS)
    platformFacade:removeCommand(PlatformConstants.REQUEST_TASK_INFO)

    self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

function BenefitsMediator:updateListView()

    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
	local benefits = platformFacade:retrieveProxy("BenefitsProxy")
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")

    local bindedMobile = userinfo:getData().mobile  --绑定的手机号
    local bindedPhone = userinfo:getData().bMobileBind  --是否绑定
   

    self.list:removeAllItems()

    local taskList = benefits:getData().taskInfo

    dump("--------------------------------------->",taskList)

    if bindedPhone==true then
        print("BenefitsMediator bindedMobile:"..bindedMobile,"已经绑定手机")

    -- elseif then
    --     print("BenefitsMediator bindedMobile:"..bindedMobile)

    end
    --优先添加签到
    local signTaskId = 3
    local bindPhoneId = 1
    local assistanceId = 2

    local taskObj = nil
    for i =1, #taskList do
        if taskList[i].iTaskId == signTaskId then
            taskObj = taskList[i]
            local itemDemo = cc.CSLoader:createNode("hall_res/benefits/benefitsItem.csb")  --设置UI的csb
            local item = seekNodeByName(itemDemo,"item")
            item:removeFromParent(false)

            local message_nowatch_2 = seekNodeByName(item, "message_nowatch_2")
            local Text_1 = seekNodeByName(item, "Text_1")
            local Text_2 = seekNodeByName(item, "Text_2")
            local Text_3 = seekNodeByName(item, "Text_3")

            Text_3:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果

            message_nowatch_2:loadTexture( string.format("platform_res/benefits/tubiao-%d.png", signTaskId))

            Text_1:setString(taskObj.sTaskName)
            Text_2:setString(taskObj.sTaskDetail)
            Text_3:setString( "打开" )

            local btn = seekNodeByName(item, "Button")
            if btn then
		        btn:addClickEventListener(function()
			        self:btnCallBack(signTaskId)
		        end)
	        end

            if taskObj.iExcution == 1 then
                Text_3:setString( "查看" )
                -- btn:setEnabled(false)   -- 让每日签到不能领取但是还可以点击进去看
                Text_3:enableOutline(cc.c3b(93, 93, 93), 2)  --设置字体描边效果
                
            end

            self.list:pushBackCustomItem(item)    
            
            break    
        end    
    end

    for i = 1,#taskList do
        if taskList[i].iTaskId ~= signTaskId then
            local itemDemo = cc.CSLoader:createNode("hall_res/benefits/benefitsItem.csb")  --设置UI的csb
            local item = seekNodeByName(itemDemo,"item")
            item:removeFromParent(false)

            local message_nowatch_2 = seekNodeByName(item, "message_nowatch_2")
            local Text_1 = seekNodeByName(item, "Text_1")
            local Text_2 = seekNodeByName(item, "Text_2")
            local Text_3 = seekNodeByName(item, "Text_3")

            Text_3:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果

            message_nowatch_2:loadTexture( string.format("platform_res/benefits/tubiao-%d.png", i))
            Text_1:setString(taskList[i].sTaskName)
            Text_2:setString(taskList[i].sTaskDetail)
            Text_3:setString( "打开" )

            local btn = seekNodeByName(item, "Button")
            if btn then
		        btn:addClickEventListener(function()
			        self:btnCallBack(i)
		        end)
	        end

            if taskList[i].iTaskId == bindPhoneId then
                --如果已经绑定了
                --if taskList[i].iTaskAvailableCount <= taskList[i].iCurrentCount then
                if bindedPhone==true and #bindedMobile==11 then
                    Text_3:setString( "已绑定" )
                    btn:setEnabled(false)   
                    Text_3:enableOutline(cc.c3b(93, 93, 93), 2)  --设置字体描边效果     
                end
            end

            if taskList[i].iTaskId == assistanceId then
                --破产补助领取
                Text_3:setString( string.format("领取(%d/%d)",taskList[i].iCurrentCount, taskList[i].iTaskAvailableCount) )
                if taskList[i].iTaskAvailableCount <= taskList[i].iCurrentCount then
                    btn:setEnabled(false) 
                    Text_3:enableOutline(cc.c3b(93, 93, 93), 2)  --设置字体描边效果       
                end            

                --钱数少于taskList[i].sTValue（包括银行里面的钱），即可领低保，否则置灰
                local userinfo = platformFacade:retrieveProxy("UserInfoProxy") --获取用户数据
                local userCoin = userinfo:getData().gold + userinfo:getData().safeGold --用户金币数

                local assistLimit = taskList[i].sTValue
                local t = type(assistLimit)
                if t == "string" then
                    assistLimit = tonumber(assistLimit)
                end
                --判断低保按钮是否可以点击
                if userCoin > assistLimit then
                    btn:setEnabled(false) 
                    Text_3:enableOutline(cc.c3b(93, 93, 93), 2)  --设置字体描边效果     
                end
            end

            self.list:pushBackCustomItem(item)
        end
    end

end

function BenefitsMediator:btnCallBack(idx)
    print("haha"..idx)
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    if idx == 3 then
        --发送领取每日签到消息
        platformFacade:sendNotification(PlatformConstants.SHOW_SIGN, self:getViewComponent())    

    elseif idx == 2 then 
        --[[
        local strMsg = "今天第一次送您1000金币"
        local function okCall()  --确定按钮回调
            --发送领取破产补助消息
             platformFacade:sendNotification(PlatformConstants.REQUEST_TASK_INFO, 2)
        end 
        local tMsg = {mType = 2, code = 1, msg = strMsg, okCallback = okCall} --类型为2，code无用，msg为显示的描述，okCallback为按确定按钮的回调函数
        platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX_EX, tMsg)  
        --]]
        --发送领取破产补助消息
        platformFacade:sendNotification(PlatformConstants.REQUEST_TASK_INFO, 2)
    elseif idx == 1 then 
        platformFacade:sendNotification(PlatformConstants.SHOW_BINDPHONENUMBER, self:getViewComponent())
    end
end

function BenefitsMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    print(name)
	if name == PlatformConstants.UPDATE_TASKINFO then
        print("PlatformConstants.UPDATE_TASKINFO")
        self:updateListView()
    elseif name == PlatformConstants.UPDATE_ASSISTANCE_TIMES then 
        platformFacade:sendNotification(PlatformConstants.SHOW_ASSISTANCE_TIPS, self:getViewComponent())
    elseif name == PlatformConstants.UPDATE_MOBILEBIND then 
        platformFacade:sendNotification(PlatformConstants.REQUEST_BENEFITS)
	end	
end

return BenefitsMediator
