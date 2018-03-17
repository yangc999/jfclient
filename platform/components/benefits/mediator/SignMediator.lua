
local Mediator = cc.load("puremvc").Mediator
local SignMediator = class("SignMediator", Mediator)

function SignMediator:ctor(root)
	SignMediator.super.ctor(self, "SignMediator", root)
    self.root = root
end

function SignMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
        PlatformConstants.UPDATE_TASKINFO, 
	}
end

function SignMediator:hideSignTips()
    if self.signTips ~= nil then
        self.signTips:removeFromParent()
        self.signTips = nil
    end

    self.idx = nil
end

function SignMediator:showSignTips(idx, taskInfo)
    
    if self.idx == idx then 
        return 
    end 

    self.idx = idx

    print("aaaa")
    print(idx)
    print("vbbbb")
    if self.signTips ~= nil then
        self.signTips:removeFromParent()
        self.signTips = nil
    end

    self.signTips = cc.CSLoader:createNode("hall_res/sign/SignTipsNode.csb")  
	self.root:addChild(self.signTips)

    self.Text_money = seekNodeByName(self.signTips, "Text_money")
    self.Text_money:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果
    self.Text_money:setVisible(false)

    self.Text_money:removeFromParent()
    self.signTips:setPosition(cc.p(145 + 135 * (idx), 450))

	dump(taskInfo)
	local i = 0
    for k, v in pairs(taskInfo) do
        if v.iTriggerValue == idx then
            print(k)
            local text = self.Text_money:clone()
            text:setVisible(true)
            print(text)
            text:setString( tostring(v.iRewardCount.."金币" ) )
            if v.iIrewardType == 2 then
                text:setString(tostring(v.iRewardCount.."房卡"))
            end

            text:setPositionY(i*(-30)+20)
            text:setPositionX(0)
            i = i + 1
            self.signTips:addChild(text)
        end
    end
    
    
    
end



function SignMediator:onRegister()

	print("SignMediator:onRegister")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
	local benefits = platformFacade:retrieveProxy("BenefitsProxy")

    local taskList = benefits:getData().taskInfo
    dump(taskList,"taskList onRegister")

    local ui = cc.CSLoader:createNode("hall_res/sign/signLayer.csb")  
	self:setViewComponent(ui)

	self.root:addChild(self:getViewComponent()) 

    self.Panel_1 = seekNodeByName(ui, "Panel_1")

    self.Panel_1:addClickEventListener(function()
--	    print("touch 11111111111111111111111111111111111111111111111111")
        self:hideSignTips()
	end)

    self.bgImg = self.Panel_1:getChildByName("bg")
    self.btnSign = seekNodeByName(self.bgImg, "btn_sign")
    self.textBtn = seekNodeByName(self.btnSign, "Text_26")

    local dayStr = {"第一天","第二天","第三天","第四天","第五天","第六天","第七天"}

    local signTaskId = 3
    for i = 1,#taskList do
        if taskList[i].iTaskId == signTaskId then
            local taskObj = taskList[i]
            dump(taskObj,"taskObj onRegister")
            -- if taskObj.vTaskrelative ~= nil then
                -- dump(taskObj.vTaskrelative)
            if taskObj ~= nil then
                for j = 1, 7 do

                    local daynode = seekNodeByName(self.bgImg, "DayNode_"..j)
                    local Image_icon = seekNodeByName(daynode, "Image_icon")
                    local Text_day = seekNodeByName(daynode, "Text_day")
                    local Text_money = seekNodeByName(daynode, "Text_money")
                    local Image_hasSign = seekNodeByName(daynode, "Image_hasSign")
                    Image_hasSign:setVisible(false)

                    Text_day:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果
                    Text_money:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果

                    Image_icon:loadTexture( string.format("platform_res/sign/jinbi-%d.png",j))
                    Text_day:setString(dayStr[j])
                    if taskObj.vTaskrelative ~= nil then
                        for k, v in pairs(taskObj.vTaskrelative) do
                            if v.iTriggerValue == j then
                                Text_money:setString(tostring(v.iRewardCount.."金币"))

                                if v.iIrewardType == 2 then
                                    Text_money:setString(tostring(v.iRewardCount.."房卡"))
                                end

                                if v.iIsBox == 1 then
                                    Text_money:setString("神秘礼包")
                                    Image_icon:loadTexture( "platform_res/sign/lihe-1.png" )

                                    Image_icon:addClickEventListener(function()
    	                                print("touch imageicon")

                                        self:showSignTips(j, taskObj.vTaskrelative)

    	                            end)
                                else 
                                    Image_icon:addClickEventListener(function()
                                        self:hideSignTips()
    	                            end)                                

                                end

                                break
                            end
                        end
                    end

                    if Image_icon then
                        --发送领取消息
                        Image_icon:addClickEventListener(function()
                            print("can get taskList")
                            platformFacade:sendNotification(PlatformConstants.REQUEST_TASK_INFO, 3)
                        end)
                    end

                    if j <= taskObj.iCurrentCount then
                        print("##############0",taskObj.iExcution)
                        Image_hasSign:setVisible(true)
                    end

                    if taskObj.iExcution == 1 then
                        self.btnSign:setEnabled(false)
                        self.textBtn:setString("已领取")

                        if self.textBtn then
                --                    self.textBtn:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果
                            self.textBtn:enableOutline(cc.c3b(93, 93, 93), 2)  --设置字体描边效果
                        end

                    end


                end 

            end
            break
        end
    end 

    



    local btnClose = seekNodeByName(self.bgImg, "btn_close")
	if btnClose then
		btnClose:setZoomScale(-0.1)
		btnClose:addClickEventListener(function()
			platformFacade:removeMediator("SignMediator")
		end)
	end

    
	if self.btnSign then
		--发送领取消息
		self.btnSign:addClickEventListener(function()
			platformFacade:sendNotification(PlatformConstants.REQUEST_TASK_INFO, 3)
		end)

        --[[
        self.textBtn = seekNodeByName(self.btnSign, "Text_26")
        if self.textBtn then
            self.textBtn:enableOutline(cc.c3b(93, 93, 93), 2)  --设置字体描边效果
        end
        --]]
	end

--    platformFacade:sendNotification(PlatformConstants.UPDATE_TASKINFO)
    --platformFacade:sendNotification(PlatformConstants.REQUEST_TASK_INFO, 0)
    print("SignMediator:End OnRegister")
end

function SignMediator:updateDateView()
    --更新信息
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
	local benefits = platformFacade:retrieveProxy("BenefitsProxy")

    local taskList = benefits:getData().taskInfo
    dump(taskList,"signData")

    local signTaskId = 3
    for i = 1,#taskList do
        if taskList[i].iTaskId == signTaskId then
            local taskObj = taskList[i]
            if taskObj.vTaskrelative ~= nil then
                dump(taskObj.vTaskrelative)

                local diplayCount = 0
                for j = 1, 7 do
                    local daynode = seekNodeByName(self.bgImg, "DayNode_"..j)
                    local Image_hasSign = seekNodeByName(daynode, "Image_hasSign")
                    --Image_hasSign:setVisible(false)
                    diplayCount = 1 + diplayCount

                    --if j <= taskObj.iCurrentCount then
                        --Image_hasSign:setVisible(true)  
                    --end
                    if taskObj.iCurrentCount == diplayCount then
                        Image_hasSign:setVisible(true) 
                        break
                    end
                end 

            end
            if taskObj.iExcution == 1 then
                self.btnSign:setEnabled(false)
                self.textBtn:setString("已领取")
                if self.textBtn then
--                    self.textBtn:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果
                    self.textBtn:enableOutline(cc.c3b(93, 93, 93), 2)  --设置字体描边效果
                end

            end

            break
        end
    end 

end

function SignMediator:startCountDown()

end

function SignMediator:stopCountDown()
    print("退出")

end 

function SignMediator:onRemove()
    self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
    self:hideSignTips()
end

function SignMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    print(name)
	if name == PlatformConstants.UPDATE_TASKINFO then
        print("PlatformConstants.UPDATE_TASKINFO")
        self:updateDateView()
        cc.exports.showGetAnimation(self:getViewComponent())  --显示获得物品动画
	end	
end

return SignMediator
