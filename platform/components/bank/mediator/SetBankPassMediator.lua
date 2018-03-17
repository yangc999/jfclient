--region *.lua  设置银行密码Mediator
--Date 2017/11/14
--yangyisong
local Mediator = cc.load("puremvc").Mediator
local SetBankPassMediator = class("SetBankPassMediator", Mediator)

local TOTALTIME = 60 --重发短信的倒计时
local SchID = nil

function SetBankPassMediator:ctor(root)
	SetBankPassMediator.super.ctor(self, "SetBankPassMediator")
	self.root = root  --设置根结点

	self.totalTime = TOTALTIME --总时间60秒
    self.scheduler = cc.Director:getInstance():getScheduler()
    self.schedulerID = nil  --倒计时的更新函数ID
    self.phone = ""
end


--将手机号转为 139****5581形式
function SetBankPassMediator:getPhoneStr(phone)
    if phone==nil then
       print("phone输入为空")
       return ""
    else
       local strPhone = tostring(phone)
       if strPhone == nil then
         print("phone无法转为字符串")
         return ""
       end
       strPhone = string.trim(strPhone)
       local len = #strPhone
       if len~=11 then 
         print("手机号格式不正确")
         return ""
       end
       local strHead = string.sub(strPhone, 1, 3)
       print("strHead 手机号头:" .. strHead)
       local strTail = string.sub(strPhone, -4, -1)
       print("strTail 手机号尾:" .. strTail)
       local strResult = strHead .. "****" .. strTail
       return strResult
    end
end

--倒计时的更新函数
function SetBankPassMediator:antiClockwiseUpdate(time)
    self.totalTime = self.totalTime - 1
    if self.totalTime>=0 then
       if self.txtTimeOut then  --设置倒计时时间显示
          self.txtTimeOut:setString("( " .. self.totalTime.."s )")
       end
    elseif self.schedulerID~=nil then  --倒计时时间到停止计时
         self.scheduler:unscheduleScriptEntry(self.schedulerID)
         self.schedulerID = nil
         if self.btnMobileCode then
            self.btnMobileCode:setEnabled(true)
            self.btnMobileCode:setVisible(true)
         end
         if self.txtTimeOut then  --设置倒计时时间显示
           self.txtTimeOut:setVisible(false)
         end
         self.totalTime = TOTALTIME
    end   
end

--开始倒计时函数
function SetBankPassMediator:scheduleFunc()
   --每隔一秒刷新一下函数
   self.schedulerID = self.scheduler:scheduleScriptFunc(handler(self, self.antiClockwiseUpdate),1,false)
   SchID = self.schedulerID
end


function SetBankPassMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.UPDATE_GOLD, 
		PlatformConstants.RESULT_BANKPASSSET,
		PlatformConstants.PHONE_VALID,
	}
end

function SetBankPassMediator:onRegister()
	print("SetBankPassMediator:onRegister")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	local bankProxy = platformFacade:retrieveProxy("BankProxy")
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")

	platformFacade:registerCommand(PlatformConstants.REQUEST_MOBILECODE, cc.exports.RequestMobileCodeCommand) --注册启动设置银行取款密码界面
	platformFacade:registerCommand(PlatformConstants.REQUEST_SETBANKPASS, cc.exports.RequestSetBankPassCommand) --注册启动设置银行取款密码界面
	

	local ui = cc.CSLoader:createNode("hall_res/bank/setUserpass.csb")  --设置UI的csb
	self:setViewComponent(ui)
	--local scene = platformFacade:retrieveMediator("BankMediator").scene
	self.root:addChild(self:getViewComponent())

	 self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--获取背景

	--获取关闭按钮
	local btnClose = seekNodeByName(self.bgImg, "btn_close")
	if btnClose then
		btnClose:setZoomScale(-0.1)
		btnClose:addClickEventListener(function()
			platformFacade:removeMediator("SetBankPassMediator")
		end)
	end

	--获取手机号输入框
	local txtPhoneNum = self.bgImg:getChildByName("txtPhoneNum")
    local txtMobileBind = self.bgImg:getChildByName("txtMobileBind")  --绑定过的手机号
	local sizePhoneNum = txtPhoneNum:getContentSize()
	local positionx1,positiony1 = txtPhoneNum:getPosition()
    local bindedMobile = userinfo:getData().mobile  --绑定的手机号
    local bindedPhone = userinfo:getData().bMobileBind  --是否绑定
	txtPhoneNum:setVisible(false)
	--替换成自己定义的EditBox 
	self.Edt_PhoneNum = cc.EditBox:create(cc.size(sizePhoneNum.width,sizePhoneNum.height),"platform_res/forgetpwd/inputeidtbox.png")
	self.Edt_PhoneNum:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
	self.Edt_PhoneNum:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_SENTENCE)
	self.Edt_PhoneNum:setPosition(cc.p(positionx1,positiony1 ))
	self.Edt_PhoneNum:setAnchorPoint(cc.p(0.5, 0.5))
	self.Edt_PhoneNum:setPlaceHolder('请输入您的手机号码')
	self.Edt_PhoneNum:setPlaceholderFontSize(30)
	self.Edt_PhoneNum:setFontColor(cc.c3b(33,38,48))
	self.Edt_PhoneNum:setFontSize(30)
	self.Edt_PhoneNum:setMaxLength(11)
	self.Edt_PhoneNum:setIgnoreAnchorPointForPosition(false)
	self.bgImg:addChild(self.Edt_PhoneNum)
    --如果绑定了手机号，就直接显示而不用 用户再输入手机号
    if bindedPhone~=false and bindedMobile~="" then
       self.Edt_PhoneNum:setVisible(false)
       txtMobileBind:setVisible(true)
       local strPhone = self:getPhoneStr(bindedMobile)
       txtMobileBind:setString(strPhone)
    else
       self.Edt_PhoneNum:setVisible(true)
       txtMobileBind:setVisible(false)
    end

    --手机号监听函数
    local function EditBoxEvent(eventType,pSender)   
        --变化事件类型： 如，在window下，输入完成后点击  OK 则触发此类型  
        --若点击  CANCEL 则不触发此类型  
        if eventType == "changed" then  
            print("变化")  
            local phoneNum = self.Edt_PhoneNum:getText()
            --判断手机号是否纯数字，剔除数字外的字符
       		local strPhone = cc.exports.phoneIsNum(phoneNum)
            if strPhone then
                print("手机号错了,phoneNum:",phoneNum)
                self.Edt_PhoneNum:setText(strPhone)
            end 
        end  
    end

    --绑定手机号监听
    self.Edt_PhoneNum:registerScriptEditBoxHandler(EditBoxEvent) 


	--获取密码输入框
	local txtPassWord = self.bgImg:getChildByName("txtNewPass")
	local sizePassWord = txtPassWord:getContentSize()
	local positionx2,positiony2 = txtPassWord:getPosition()
	txtPassWord:setVisible(false)
	--替换成自己定义的EditBox 
	self.Edt_PassWord = cc.EditBox:create(cc.size(sizePassWord.width,sizePassWord.height),"platform_res/forgetpwd/inputeidtbox.png")
	self.Edt_PassWord:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.Edt_PassWord:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	self.Edt_PassWord:setPosition(cc.p(positionx2,positiony2 ))
	self.Edt_PassWord:setAnchorPoint(cc.p(0.5, 0.5))
	self.Edt_PassWord:setPlaceHolder('请输入密码 6-16位')
	self.Edt_PassWord:setPlaceholderFontSize(30)
	self.Edt_PassWord:setFontColor(cc.c3b(33,38,48))
	self.Edt_PassWord:setFontSize(30)
	self.Edt_PassWord:setMaxLength(16)
	self.Edt_PassWord:setIgnoreAnchorPointForPosition(false)
	self.bgImg:addChild(self.Edt_PassWord)

	--获取确认密码输入框
	local txtPassConWord = self.bgImg:getChildByName("txtConfrmPass")
	local sizePassConWord = txtPassConWord:getContentSize()
	local positionx3,positiony3 = txtPassConWord:getPosition()
	txtPassConWord:setVisible(false)
	--替换成自己定义的EditBox 
	self.Edt_PassConWord = cc.EditBox:create(cc.size(sizePassConWord.width,sizePassConWord.height),"platform_res/forgetpwd/inputeidtbox.png")
	self.Edt_PassConWord:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.Edt_PassConWord:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	self.Edt_PassConWord:setPosition(cc.p(positionx3, positiony3 ))
	self.Edt_PassConWord:setAnchorPoint(cc.p(0.5, 0.5))
	self.Edt_PassConWord:setPlaceHolder('请再次输入密码')
	self.Edt_PassConWord:setPlaceholderFontSize(30)
	self.Edt_PassConWord:setFontColor(cc.c3b(33,38,48))
	self.Edt_PassConWord:setFontSize(30)
	self.Edt_PassConWord:setMaxLength(16)
	self.Edt_PassConWord:setIgnoreAnchorPointForPosition(false)
	self.bgImg:addChild(self.Edt_PassConWord)

	--获取验证码编辑框
	local txtVerfyCode = self.bgImg:getChildByName("txtVerfyCode") --获取输入框背景
	local sizeVerfyCode = txtVerfyCode:getContentSize()
	local positionx,positiony = txtVerfyCode:getPosition()
	txtVerfyCode:setVisible(false)
	--替换成自己定义的EditBox 
	self.Edt_VerfyCode = cc.EditBox:create(cc.size(sizeVerfyCode.width,sizeVerfyCode.height),"platform_res/forgetpwd/inputeidtbox_short.png")
	--self.Edt_VerfyCode:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)--cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_SENTENCE)
	self.Edt_VerfyCode:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
	self.Edt_VerfyCode:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_SENTENCE)
	--self.Edt_VerfyCode:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.Edt_VerfyCode:setPosition(cc.p(positionx,positiony ))
	self.Edt_VerfyCode:setAnchorPoint(cc.p(0.5, 0.5))
	self.Edt_VerfyCode:setPlaceHolder('请输入收到的验证码')
	self.Edt_VerfyCode:setPlaceholderFontSize(30)
	self.Edt_VerfyCode:setFontColor(cc.c3b(33,38,48))
	self.Edt_VerfyCode:setFontSize(30)
	self.Edt_VerfyCode:setMaxLength(6)
	self.Edt_VerfyCode:setIgnoreAnchorPointForPosition(false)
	self.bgImg:addChild(self.Edt_VerfyCode)

	--验证码监听函数
    local function VerfyCodeEditBoxEvent(eventType,pSender)   
        print("SetBankPassMediator VerfyCodeEditBoxEvent eventType:"..eventType)
        if eventType == "changed" then  
            local codeNum = self.Edt_VerfyCode:getText()
            --判断手机号是否纯数字，剔除数字外的字符
            local strCode = cc.exports.phoneIsNum(codeNum)
            if strCode then
                self.Edt_VerfyCode:setText(strCode)
            end 
        end  
    end
    --绑定验证码监听
    self.Edt_VerfyCode:registerScriptEditBoxHandler(VerfyCodeEditBoxEvent)
	txtVerfyCode:setVisible(false)


    self.txtTimeOut = seekNodeByName(self.bgImg, "txtTimeCount")  --倒计时文字标签
    if self.txtTimeOut then  --设置倒计时时间显示
       self.txtTimeOut:setVisible(false)
    end

	--获取手机验证码按钮
	self.btnMobileCode = seekNodeByName(self.bgImg, "btn_getcode")
	if self.btnMobileCode then
		self.btnMobileCode:setZoomScale(-0.1)

		self.btnMobileCode:addClickEventListener(function()
			--platformFacade:removeMediator("SetBankPassMediator")
			print("click btnMobileCode")
            local phoneNum = ""
            if bindedMobile~="" then
              phoneNum = bindedMobile
            else
              phoneNum = string.trim(self.Edt_PhoneNum:getText())
            end
			--local phoneNum = string.trim(self.Edt_PhoneNum:getText())
			if phoneNum == "" then
				print("手机号末输入")
				platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "手机号未输入")
				return			
			else
			   print("phoneNum:"..phoneNum)
               local tMobile = {mobile = phoneNum, action = 0}
			   platformFacade:sendNotification(PlatformConstants.REQUEST_MOBILECODE, tMobile)
			end

		end)
		
	else
		print("btnMobileCode 找不到")
	end

	--获取结果显示码
	self.txtResult =  self.bgImg:getChildByName("txtInfo") --获取结果显示框

	--获取确认按钮
	local btnOk = seekNodeByName(self.bgImg, "btnOK")
	if btnOk then
		local txtOK = seekNodeByName(btnOk, "txtOK")
		if txtOk~=nil then
		   txtOK:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果
		end
		
		btnOk:addClickEventListener(function()
			print("click 确认按钮")
			btnOk:setZoomScale(-0.1)
			--判断手机号是否输入正确
			local phoneNum = ""
            if bindedMobile~="" then
              phoneNum = bindedMobile
            else
              phoneNum = string.trim(self.Edt_PhoneNum:getText())
            end
			if phoneNum == "" then
				print("手机号末输入----")
				--self.txtResult:setString("手机号未输入")
				--platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX, "手机号未输入")
				platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "手机号未输入")
				return
			else
			   local phoneLen = #phoneNum
			   if phoneLen~= 11 then
				 print("手机号格式不正确，必须11位")
				 --self.txtResult:setString("手机号格式不正确，必须11位")
				 platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "手机号格式不正确，必须11位")
				 return
			   end 
			   print("phoneNum:"..phoneNum)
			end
			--判断密码是否合法
			local strPassWord = string.trim(self.Edt_PassWord:getText())
			local lenPass = #strPassWord
			if lenPass < 6 or lenPass>12 then
			   print("密码必须6到12位")
			   --self.txtResult:setString("密码必须6到12位")
			   --platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX, "密码必须6到12位")
			   platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "您输入的密码有误，请重新输入")
			   return
			end
			--判断确认密码是否合法
			local passWordCon = string.trim(self.Edt_PassConWord:getText())
			local lenPassCon = #passWordCon
			if lenPassCon < 6 or lenPassCon > 12 then
			   print("确认密码必须6到12位")
			   --self.txtResult:setString("确认密码必须6到12位")
			   --platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX, "确认密码必须6到12位")
			   platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "您输入的确认密码有误，请重新输入")
			   return
			end
			--判断密码与确认密码字符串是否相等
			if strPassWord ~= passWordCon then
			   print("两次密码输入不相同")
			   --self.txtResult:setString("两次密码输入不相同")
			   --platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX, "两次密码输入不相同")
			   platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "两次密码输入不相同")
			   return
			end

			--判断手机验证码是否合法
			local txtVerCode = string.trim(self.Edt_VerfyCode:getText())
			local lenVerCode = #txtVerCode
			if lenVerCode <= 0 then
			   print("验证码没有输入")
			   --self.txtResult:setString("验证码没输入")
			   platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "验证码没输入")
			   return
			end

			print("全部数据输入正确，开始发送设定密码请求")
			--self.txtResult:setString("开始设置取款密码")
			local reqSetPass = {password = strPassWord, mobileCode = txtVerCode}
			 platformFacade:sendNotification(PlatformConstants.REQUEST_SETBANKPASS, reqSetPass)
		end)
	else
		print("btnOK 找不到")
	end 

end

function SetBankPassMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	local userinfo = platformFacade:retrieveProxy("UserInfoProxy")
	if name == PlatformConstants.RESULT_BANKPASSSET then
		-- print("密码设置成功")
        -- if SchID~=nil then  --self.schedulerID
        --      print("self.schedulerID 存在，停止计时器:" .. SchID)
        --      self.scheduler:unscheduleScriptEntry(SchID)  --停止定时器
        --      self.schedulerID = nil
        --      SchID = nil
        --     -- bandProxy:getData().scheduleID = nil
        -- else
        --      print("self.schedulerID == NIL")
        -- end
		if body == true then
		   --应该弹出个提示框，但提示框还没做
		   --self.txtResult:setString("密码设置成功")
		   --platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX, "密码设置成功")
		   platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "您的密码设置已设置成功啦！")
		   platformFacade:removeMediator("SetBankPassMediator")  --关闭掉设置密码提示框
		else
			--self.txtResult:setString("密码设置失败")
			--platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX, "密码设置失败")
			platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "密码设置失败")
            self.btnMobileCode:setEnabled(true)
            self.btnMobileCode:setVisible(true)
            self.txtTimeOut:setVisible(false)
		end
	elseif name == PlatformConstants.PHONE_VALID then
        print("PHONE_VALID")
        self.btnMobileCode:setEnabled(false)
        self.btnMobileCode:setVisible(false)
        print("开始倒计时")
        if self.txtTimeOut then  --设置倒计时时间显示
            self.txtTimeOut:setVisible(true)
        end
        self:scheduleFunc() --开始倒计时
	end
end

function SetBankPassMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
	--platformFacade:removeCommand(PlatformConstants.REQUEST_MOBILECODE)
	platformFacade:removeCommand(PlatformConstants.REQUEST_SETBANKPASS)
	
   if SchID~=nil then  --self.schedulerID
     print("self.schedulerID 存在，停止计时器:" .. SchID)
     self.scheduler:unscheduleScriptEntry(SchID)  --停止定时器
     self.schedulerID = nil
     SchID = nil
    -- bandProxy:getData().scheduleID = nil
   else
             print("self.schedulerID == NIL")
   end

	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

return SetBankPassMediator
--endregion
