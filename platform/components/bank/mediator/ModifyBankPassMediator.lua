--region *.lua
--Date
--修改银行密码对话框
local Mediator = cc.load("puremvc").Mediator
local ModifyBankPassMediator = class("ModifyBankPassMediator", Mediator)

function ModifyBankPassMediator:ctor(root)
	ModifyBankPassMediator.super.ctor(self, "ModifyBankPassMediator")
	self.root = root  --设置根结点
end

function ModifyBankPassMediator:listNotificationInterests()
    local PlatformConstants = cc.exports.PlatformConstants
	return {
        PlatformConstants.RESULT_BANKPASSMODIFY,
	}
end

function ModifyBankPassMediator:onRegister()
    print("ModifyBankPassMediator:onRegister")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local bankProxy = platformFacade:retrieveProxy("BankProxy")

    platformFacade:registerCommand(PlatformConstants.REQUEST_MODIFYBANKPASS, cc.exports.RequestModifyBankPassCommand) --注册请求修改银行取款密码界面
    

    local ui = cc.CSLoader:createNode("hall_res/bank/changeUsePass.csb")  --设置UI的csb
	self:setViewComponent(ui)
    --local scene = platformFacade:retrieveMediator("BankMediator").scene
	self.root:addChild(self:getViewComponent())

     self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--获取背景

    --获取关闭按钮
    local btnClose = seekNodeByName(self.bgImg, "btn_close")
	if btnClose then
		btnClose:setZoomScale(-0.1)
		btnClose:addClickEventListener(function()
			platformFacade:removeMediator("ModifyBankPassMediator")  --移除本身
		end)
	end

     --获取原密码输入框
    local txtPassWord = self.bgImg:getChildByName("txtOldPass")
    local sizePassWord = txtPassWord:getContentSize()
    local positionx2,positiony2 = txtPassWord:getPosition()
    txtPassWord:setVisible(false)
    --替换成自己定义的EditBox 
    self.Edt_PassWord = cc.EditBox:create(cc.size(sizePassWord.width,sizePassWord.height),"platform_res/forgetpwd/inputeidtbox.png")
	self.Edt_PassWord:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.Edt_PassWord:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self.Edt_PassWord:setPosition(cc.p(positionx2,positiony2 ))
    self.Edt_PassWord:setContentSize(sizePassWord)
    self.Edt_PassWord:setAnchorPoint(cc.p(0.5, 0.5))
    self.Edt_PassWord:setPlaceHolder('请输入密码 6-12位')
    self.Edt_PassWord:setPlaceholderFontSize(30)
    self.Edt_PassWord:setFontColor(cc.c3b(33,38,48))
    self.Edt_PassWord:setFontSize(30)
    self.Edt_PassWord:setMaxLength(16)
	self.Edt_PassWord:setIgnoreAnchorPointForPosition(false)
    self.bgImg:addChild(self.Edt_PassWord)

     --获取新密码输入框
    local txtNewPassWord = self.bgImg:getChildByName("txtNewPass")
    local sizeNewPassWord = txtNewPassWord:getContentSize()
    local positionx3,positiony3 = txtNewPassWord:getPosition()
    txtNewPassWord:setVisible(false)
    --替换成自己定义的EditBox 
    self.Edt_NewPassWord = cc.EditBox:create(cc.size(sizePassWord.width,sizePassWord.height),"platform_res/forgetpwd/inputeidtbox.png")
	self.Edt_NewPassWord:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.Edt_NewPassWord:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self.Edt_NewPassWord:setPosition(cc.p(positionx3,positiony3 ))
    self.Edt_NewPassWord:setContentSize(sizeNewPassWord)
    self.Edt_NewPassWord:setAnchorPoint(cc.p(0.5, 0.5))
    self.Edt_NewPassWord:setPlaceHolder('请输入新密码 6-12位')
    self.Edt_NewPassWord:setPlaceholderFontSize(30)
    self.Edt_NewPassWord:setFontColor(cc.c3b(33,38,48))
    self.Edt_NewPassWord:setFontSize(30)
    self.Edt_NewPassWord:setMaxLength(16)
	self.Edt_NewPassWord:setIgnoreAnchorPointForPosition(false)
    self.bgImg:addChild(self.Edt_NewPassWord)

     --获取确认密码输入框
    local txtPassConWord = self.bgImg:getChildByName("txtConfrmPass")
    local sizePassConWord = txtPassConWord:getContentSize()
    local positionx4,positiony4 = txtPassConWord:getPosition()
    txtPassConWord:setVisible(false)
    --替换成自己定义的EditBox 
    self.Edt_PassConWord = cc.EditBox:create(cc.size(sizePassConWord.width,sizePassConWord.height),"platform_res/forgetpwd/inputeidtbox.png")
	self.Edt_PassConWord:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.Edt_PassConWord:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self.Edt_PassConWord:setPosition(cc.p(positionx4, positiony4 ))
    self.Edt_PassConWord:setContentSize(sizePassConWord)
    self.Edt_PassConWord:setAnchorPoint(cc.p(0.5, 0.5))
    self.Edt_PassConWord:setPlaceHolder('请再次输入密码')
    self.Edt_PassConWord:setPlaceholderFontSize(30)
    self.Edt_PassConWord:setFontColor(cc.c3b(33,38,48))
    self.Edt_PassConWord:setFontSize(30)
    self.Edt_PassConWord:setMaxLength(16)
	self.Edt_PassConWord:setIgnoreAnchorPointForPosition(false)
    self.bgImg:addChild(self.Edt_PassConWord)

    --获取结果显示码
    self.txtResult =  self.bgImg:getChildByName("txtInfo") --获取结果显示框
    self.txtResult:setVisible(false)

     --获取确认按钮
    local btnOk = seekNodeByName(self.bgImg, "btnOK")
    local txtOK = seekNodeByName(btnOk, "txtOK")
    txtOK:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果
    if btnOk then
        btnOk:addClickEventListener(function()
            print("click 确认按钮")
            btnOk:setZoomScale(-0.1) 
            
            --判断老密码是否合法
            local strPassWord = string.trim(self.Edt_PassWord:getText())
            local lenPass = #strPassWord
            if lenPass < 6 or  lenPass >16 then
               print("密码必须6到16位")
               --self.txtResult:setString("密码必须6到16位")
               platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "密码必须6到12位")
               return
            end

            --判断新密码是否合法
            local strNewPassWord = string.trim(self.Edt_NewPassWord:getText())
            local lenNewPass = #strNewPassWord
            if lenNewPass < 6 or  lenNewPass >12 then
               print("新密码必须6到16位")
               --self.txtResult:setString("密码必须6到12位")
               platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "密码必须6到12位")
               return
            end

             --判断确认密码是否合法
            local strConPassWord = string.trim(self.Edt_PassConWord:getText())
            local lenConPass = #strConPassWord
            if lenConPass < 6 or lenConPass >12 then
               print("新密码必须6到16位")
               --self.txtResult:setString("密码必须6到12位")
               platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "密码必须6到12位")
               return
            end

             --判断密码与确认密码字符串是否相等
            if strNewPassWord ~= strConPassWord then
               print("两次密码输入不相同")
               --self.txtResult:setString("两次密码输入不相同")
               platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "两次密码输入不相同")
               return
            end

            print("全部数据输入正确，开始发送修改密码请求")
            --self.txtResult:setString("开始修改取款密码")
            local reqSetPass = {sPassword = strNewPassWord, sOldPassWord = strPassWord}
            platformFacade:sendNotification(PlatformConstants.REQUEST_MODIFYBANKPASS, reqSetPass)
        end)
    end

end

function ModifyBankPassMediator:handleNotification(notification)
    local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")
    if name == PlatformConstants.RESULT_BANKPASSMODIFY then
         if body == true then
           --应该弹出个提示框，但提示框还没做
           self.txtResult:setString("密码修改成功")
           platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "密码修改成功")
           platformFacade:removeMediator("ModifyBankPassMediator")  --关闭掉设置密码提示框
        else
            --self.txtResult:setString("密码设置失败, 请检查下原密码是否正确")
            print("密码设置失败,老密码错误？")
            platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "原密码输入错误！")
            self.Edt_PassWord:setText("")
            self.Edt_NewPassWord:setText("")
            self.Edt_PassConWord:setText("")
        end
    end
end

function ModifyBankPassMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
	platformFacade:removeCommand(PlatformConstants.REQUEST_MODIFYBANKPASS)
    

	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

return ModifyBankPassMediator
--endregion
