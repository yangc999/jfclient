--region *.lua
--Date
--此文件由[BabeLua]输入密码
local Mediator = cc.load("puremvc").Mediator
local InputPasswordMediator = class("InputPasswordMediator", Mediator)

function InputPasswordMediator:ctor(root)
	InputPasswordMediator.super.ctor(self, "InputPasswordMediator")
	self.root = root
end

function InputPasswordMediator:listNotificationInterests()
    local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.UPDATE_GOLD,
        PlatformConstants.RESULT_DRAWBANKMONEY,
        
	}
end

function InputPasswordMediator:onRegister()
    print("InputPasswordMediator:onRegister")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local bankProxy = platformFacade:retrieveProxy("BankProxy")
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy") --获取用户个人信息

    platformFacade:registerCommand(PlatformConstants.REQUEST_DRAWBANKMONEY, cc.exports.RequestDrawBankMoneyCommand) --注册启动设置银行取款密码界面
    --platformFacade:registerCommand(PlatformConstants.REQUEST_SETBANKPASS, cc.exports.RequestSetBankPassCommand) --注册启动设置银行取款密码界面

    local ui = cc.CSLoader:createNode("hall_res/bank/inputPwd.csb")  --设置UI的csb
	self:setViewComponent(ui)
    --local scene = platformFacade:retrieveMediator("BankMediator").scene
	self.root:addChild(self:getViewComponent())

    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--获取背景

     --获取关闭按钮
    local btnClose = seekNodeByName(self.bgImg, "btn_close")
	if btnClose then
		btnClose:setZoomScale(-0.1)
		btnClose:addClickEventListener(function()
			platformFacade:removeMediator("InputPasswordMediator")
		end)
	end

    --获取密码输入框
    local txtPassWord = self.bgImg:getChildByName("inputPassword")
    local sizePassWord = txtPassWord:getContentSize()
    local positionx, positiony = txtPassWord:getPosition()
    txtPassWord:setVisible(false)
    --替换成自己定义的密码输入EditBox 
    self.Edt_PassWord = cc.EditBox:create(cc.size(sizePassWord.width,sizePassWord.height),"platform_res/common/com_input_bg.png")
	self.Edt_PassWord:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.Edt_PassWord:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self.Edt_PassWord:setPosition(cc.p(positionx, positiony ))
    self.Edt_PassWord:setAnchorPoint(cc.p(0.5, 0.5))
    self.Edt_PassWord:setPlaceHolder('请输入您的取款密码')
    self.Edt_PassWord:setPlaceholderFontSize(30)
    self.Edt_PassWord:setFontColor(cc.c3b(33,38,48))
    self.Edt_PassWord:setFontSize(30)
    self.Edt_PassWord:setMaxLength(16)
	self.Edt_PassWord:setIgnoreAnchorPointForPosition(false)
    self.bgImg:addChild(self.Edt_PassWord)

    --获取结果显示码
    self.txtResult =  self.bgImg:getChildByName("txtInfo") --获取结果显示框

     --获取确定按钮
    local btnOK = seekNodeByName(self.bgImg, "btnOK")
    local txtOK = seekNodeByName(btnOK, "txtOK")
    txtOK:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果

     if btnOK then
		btnOK:setZoomScale(-0.1)
		btnOK:addClickEventListener(function()
			--platformFacade:removeMediator("SetBankPassMediator")
            print("click btnOK")
            local password = string.trim(self.Edt_PassWord:getText())
            if password == "" then
                print("密码末输入")
                --self.txtResult:setString("密码末输入")
                platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "您输入的密码有误，请重新输入")
                return
            else
                local lenPass = #password
                if lenPass < 6 or lenPass>12 then
                  print("密码必须6到12位")
                  --self.txtResult:setString("密码必须6到12位")
                  platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "您输入的密码有误，请重新输入")
                  return
                 end
               print("password:"..password)
               bankProxy:getData().password = password
               platformFacade:sendNotification(PlatformConstants.REQUEST_DRAWBANKMONEY)
            end

		end)
    else
        print("btnMobileCode 找不到")
	end
end

function InputPasswordMediator:handleNotification(notification)
    local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")

    if name == PlatformConstants.RESULT_DRAWBANKMONEY then
        platformFacade:removeMediator("InputPasswordMediator")
    end
end

function InputPasswordMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
	platformFacade:removeCommand(PlatformConstants.REQUEST_DRAWBANKMONEY)
   -- platformFacade:removeCommand(PlatformConstants.REQUEST_SETBANKPASS)

	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end
return InputPasswordMediator
--endregion
