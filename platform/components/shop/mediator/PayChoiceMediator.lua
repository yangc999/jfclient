--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local Mediator = cc.load("puremvc").Mediator
local PayChoiceMediator = class("PayChoiceMediator", Mediator)

function PayChoiceMediator:ctor(payno)
	PayChoiceMediator.super.ctor(self, "PayChoiceMediator")
	self.payno = payno  --设置根结点
end

function PayChoiceMediator:listNotificationInterests()
    local PlatformConstants = cc.exports.PlatformConstants
	return {
       -- PlatformConstants.RESULT_BINDMOBILE,
	}
end

function PayChoiceMediator:onRegister()
    print("PayChoiceMediator:onRegister")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    --platformFacade:registerCommand(PlatformConstants.START_BINDMOBILE, cc.exports.StartBindMobileCommand) --注册启动设置银行取款密码界面

    local ui = cc.CSLoader:createNode("hall_res/mall/mall_paytip.csb")  --设置UI的csb
	self:setViewComponent(ui)
	local scene = platformFacade:retrieveMediator("HallMediator").scene --获取要加载上的场景
	scene:addChild(self:getViewComponent())

    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--获取背景
     --获取关闭按钮
    local btnClose = seekNodeByName(self.bgImg, "btn_close")
	if btnClose then
		btnClose:setZoomScale(-0.1)
		btnClose:addClickEventListener(function()
			platformFacade:removeMediator("PayChoiceMediator")
		end)
	end

    --获取微信支付的按钮
    local btnWX = seekNodeByName(self.bgImg, "btn_WX")
    if btnWX then
       btnWX:addClickEventListener(function()
            print("开始微信支付")
			platformFacade:sendNotification("wx_order", self.payno)
			platformFacade:removeMediator("PayChoiceMediator")
		end)
    end

    --获取支付宝支付的按钮
    local btnALI = seekNodeByName(self.bgImg, "btn_ALI")
    if btnALI then
       btnALI:addClickEventListener(function()
            print("开始支付宝支付")
			platformFacade:sendNotification("ali_order", self.payno)
			platformFacade:removeMediator("PayChoiceMediator")
		end)
    end
end

function PayChoiceMediator:handleNotification(notification)
    local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

end

function PayChoiceMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
	--platformFacade:removeCommand(PlatformConstants.START_BINDMOBILE)

	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

return PayChoiceMediator
--endregion
