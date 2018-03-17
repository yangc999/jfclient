--region *.lua
--Date
--此文件由[BabeLua]绑定手机

local Mediator = cc.load("puremvc").Mediator
local BandPhoneMediator = class("BandPhoneMediator", Mediator)

function BandPhoneMediator:ctor(root)
	BandPhoneMediator.super.ctor(self, "BandPhoneMediator")
	self.root = root  --设置根结点
end

function BandPhoneMediator:listNotificationInterests()
    local PlatformConstants = cc.exports.PlatformConstants
	return {
        PlatformConstants.RESULT_BINDMOBILE,
	}
end

function BandPhoneMediator:onRegister()
    print("BandPhoneMediator:onRegister")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    --local bankProxy = platformFacade:retrieveProxy("BankProxy")

    platformFacade:registerCommand(PlatformConstants.START_BINDMOBILE, cc.exports.StartBindMobileCommand) --注册启动设置银行取款密码界面

    local ui = cc.CSLoader:createNode("hall_res/lottery/tipBandPhone.csb")  --设置UI的csb
	self:setViewComponent(ui)
	self.root:addChild(self:getViewComponent())

    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--获取背景

     --获取关闭按钮
    local btnClose = seekNodeByName(self.bgImg, "btn_close")
	if btnClose then
		btnClose:setZoomScale(-0.1)
		btnClose:addClickEventListener(function()
			platformFacade:removeMediator("BandPhoneMediator")
		end)
	end

    --获取绑定手机按钮
    local btnBindPhone = seekNodeByName(self.bgImg, "btn_band")
    if btnBindPhone then
       local txtBind = seekNodeByName(btnBindPhone, "txtBind")
       txtBind:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果
       btnBindPhone:addClickEventListener(function()
            --开始绑定手机号
            platformFacade:sendNotification(PlatformConstants.START_BINDMOBILE, self.root)
			platformFacade:removeMediator("BandPhoneMediator")
		end)
    end
    
end

function BandPhoneMediator:handleNotification(notification)
    local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
end

function BandPhoneMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
	platformFacade:removeCommand(PlatformConstants.START_BINDMOBILE)

	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

return BandPhoneMediator
--endregion
