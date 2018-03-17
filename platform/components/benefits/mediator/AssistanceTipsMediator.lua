
local Mediator = cc.load("puremvc").Mediator
local AssistanceTipsMediator = class("AssistanceTipsMediator", Mediator)

function AssistanceTipsMediator:ctor(root)
    print("AssistanceTipsMediator")
	AssistanceTipsMediator.super.ctor(self, "AssistanceTipsMediator")
    self.root = root
end

function AssistanceTipsMediator:listNotificationInterests()
    return {}
end

function AssistanceTipsMediator:onRegister()

	print("AssistanceTipsMediator:onRegister")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
	local benefits = platformFacade:retrieveProxy("BenefitsProxy")
    dump(benefits:getData().taskInfo,"jaybenefits")
    local rewardString = ""
    local coinTypeString = {"金币","房卡"}
    for k,v in pairs(benefits:getData().taskInfo) do
        print("jaybenefits",k,v)
        if v.iTaskId == 2 then
            if v.vTaskrelative ~= nil then 
                dump(v.vTaskrelative,"jayTaskrelative")
                for k1, v1 in pairs(v.vTaskrelative) do
                    rewardString = string.format( " %d%s", v1.iRewardValue, coinTypeString[v1.iRewardType] )
                end
            end  
        end 
    end


    local ui = cc.CSLoader:createNode("hall_res/benefits/assistanceLayer.csb")  
	self:setViewComponent(ui)

	self.root:addChild(self:getViewComponent()) 
    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")
    print("jaybenefits rewardString:",rewardString)
    self.textGold = seekNodeByName(self.bgImg, "Text_1")
    if self.textGold ~= nil then
        self.textGold:setString( string.format("今天第%d次送你%s", benefits:getData().assistanceCurrentTimes, rewardString) )
    end
    self.textTimes = seekNodeByName(self.bgImg, "Text_3")
    if self.textTimes ~= nil then
        self.textTimes:setString( string.format("%d次", benefits:getData().assistanceTimes) ) 
    end

    local btnClose = seekNodeByName(self.bgImg, "btn_close")
	if btnClose then
		btnClose:setZoomScale(-0.1)
		btnClose:addClickEventListener(function()
			platformFacade:removeMediator("AssistanceTipsMediator")
		end)
	end

    local btn_commit = seekNodeByName(self.bgImg, "btn_commit")
	if btn_commit then
		--发送领取消息
		btn_commit:addClickEventListener(function()
			platformFacade:removeMediator("AssistanceTipsMediator")
		end)
	end

--    platformFacade:sendNotification(PlatformConstants.UPDATE_TASKINFO)
    print("AssistanceTipsMediator:End OnRegister")
end

function AssistanceTipsMediator:startCountDown()

end

function AssistanceTipsMediator:stopCountDown()
    print("退出")

end 

function AssistanceTipsMediator:onRemove()
    self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

function AssistanceTipsMediator:handleNotification(notification)

end

return AssistanceTipsMediator
