
local Mediator = cc.load("puremvc").Mediator
local BindPhoneNumberMediator = class("BindPhoneNumberMediator", Mediator)

function BindPhoneNumberMediator:ctor(root)
	BindPhoneNumberMediator.super.ctor(self, "BindPhoneNumberMediator", root)
    self.root = root
end

function BindPhoneNumberMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
--		PlatformConstants.REQUEST_TASKINFO, 
--        PlatformConstants.UPDATE_TASKINFO, 
--        PlatformConstants.SHOW_SIGN,
--        PlatformConstants.SHOW_BINDPHONENUMBER, 
	}
end

function BindPhoneNumberMediator:onRegister()

	print("BindPhoneNumberMediator:onRegister")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    platformFacade:registerCommand(PlatformConstants.REQUEST_BENEFITS, cc.exports.RequestBenefitsCommand)
    platformFacade:registerCommand(PlatformConstants.REQUEST_BENEFITS_CONFIG, cc.exports.RequestBenefitsConfigCommand)  --根据ID显示公告

    local ui = cc.CSLoader:createNode("hall_res/benefits/benefitsLayer.csb")  --设置UI的csb
	self:setViewComponent(ui)

    print(self.root)

	self.root:addChild(self:getViewComponent()) --获取大厅的Mediator，加载这个公告场景s

    --公告栏的滚动列表
    --self.bgImg = self:getChildByName("Panel_1"):getChildByName("bg") --背景
    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--背景
    self.list = seekNodeByName(self.bgImg, "ListView_1")
	self.list:setScrollBarEnabled(false)


    --获取关闭按钮
    local btnClose = seekNodeByName(self.bgImg, "btn_close")
	if btnClose then
		btnClose:setZoomScale(-0.1)
		btnClose:addClickEventListener(function()
			platformFacade:removeMediator("BindPhoneNumberMediator")
		end)
	end

    --大厅启动时请求公告列表
    --platformFacade:sendNotification(PlatformConstants.REQUEST_BENEFITS_CONFIG)
    print("BindPhoneNumberMediator:End OnRegister")
end

function BindPhoneNumberMediator:startCountDown()

end

function BindPhoneNumberMediator:stopCountDown()
    print("关闭跑马灯 ")

end 

function BindPhoneNumberMediator:onRemove()
    self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

function BindPhoneNumberMediator:handleNotification(notification)
--	local name = notification:getName()
--	local body = notification:getBody()
--	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
--	local PlatformConstants = cc.exports.PlatformConstants
--    print(name)
--	if name == PlatformConstants.REQUEST_TASKINFO then
--        --获取到任务id后获取任务具体信息
--        platformFacade:sendNotification(PlatformConstants.REQUEST_BENEFITS)
--    elseif name == PlatformConstants.UPDATE_TASKINFO then
--        print("PlatformConstants.UPDATE_TASKINFO")
--	end	
end

return BindPhoneNumberMediator
