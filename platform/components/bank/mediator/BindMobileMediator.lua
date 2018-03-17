--region *.lua
--Date
--此文件由[BabeLua] 绑定手机号
local Mediator = cc.load("puremvc").Mediator
local BindMobileMediator = class("BindMobileMediator", Mediator)
local TOTALTIME = 60 --重发短信的倒计时
local SchID = nil

function BindMobileMediator:ctor(root)
	BindMobileMediator.super.ctor(self, "BindMobileMediator")
	self.root = root  --设置根结点

    self.totalTime = TOTALTIME --总时间60秒
    self.scheduler = cc.Director:getInstance():getScheduler()
    self.schedulerID = nil  --倒计时的更新函数ID
    self.phone = ""
end

--倒计时的更新函数
function BindMobileMediator:antiClockwiseUpdate(time)
    self.totalTime = self.totalTime - 1
    if self.totalTime>=0 then
       if self.txtTimeOut then  --设置倒计时时间显示
          self.txtTimeOut:setString("( " .. self.totalTime.."s )")
       end
    elseif self.schedulerID~=nil then  --倒计时时间到停止计时
         self.scheduler:unscheduleScriptEntry(self.schedulerID)
         self.schedulerID = nil
         if self.btnGetCodeAgain then
            self.btnGetCodeAgain:setEnabled(true)
            self.btnGetCodeAgain:setVisible(true)
         end
         if self.txtTimeOut then  --设置倒计时时间显示
           self.txtTimeOut:setVisible(false)
         end
         self.totalTime = TOTALTIME
    end   
end

--开始倒计时函数
function BindMobileMediator:scheduleFunc()
   --每隔一秒刷新一下函数
   print("BindMobileMediator:scheduleFunc")
  -- local bandProxy = platformFacade:retrieveProxy("BandMobileProxy") --获取数据
   self.schedulerID = self.scheduler:scheduleScriptFunc(handler(self, self.antiClockwiseUpdate),1,false)
   --bandProxy:getData().scheduleID = self.schedulerID
   print("schedluerID : " .. self.schedulerID)
   SchID = self.schedulerID
end

function BindMobileMediator:listNotificationInterests()
    local PlatformConstants = cc.exports.PlatformConstants
	return {
        PlatformConstants.RESULT_BINDMOBILE,
        PlatformConstants.PHONE_VALID,
	}
end

function BindMobileMediator:onRegister()
    print("BindMobileMediator:onRegister")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	  local PlatformConstants = cc.exports.PlatformConstants
    local bandProxy = platformFacade:retrieveProxy("BandMobileProxy") --获取数据

    platformFacade:registerCommand(PlatformConstants.REQUEST_BINDMOBILE, cc.exports.RequestBindMobileCommand) --注册启动设置银行取款密码界面
    platformFacade:registerCommand(PlatformConstants.REQUEST_MOBILECODE, cc.exports.RequestMobileCodeCommand) --注册发送手机验证码命令
    

    local ui = cc.CSLoader:createNode("hall_res/useraccount/bangUseraccount.csb")  --设置UI的csb
	self:setViewComponent(ui)
    --local scene = platformFacade:retrieveMediator("BankMediator").scene
	self.root:addChild(self:getViewComponent())

    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--获取背景

    --获取关闭按钮
    local btnClose = seekNodeByName(self.bgImg, "btn_close")
	if btnClose then
		btnClose:setZoomScale(-0.1)
		btnClose:addClickEventListener(function()
			platformFacade:removeMediator("BindMobileMediator")
		end)
	end

    --获取手机号输入框
    local txtPhoneNum = self.bgImg:getChildByName("phone_input")
    local sizePhoneNum = txtPhoneNum:getContentSize()
    local positionx1,positiony1 = txtPhoneNum:getPosition()
    txtPhoneNum:setVisible(false)
    --替换成自己定义的EditBox 
    self.Edt_PhoneNum = cc.EditBox:create(cc.size(sizePhoneNum.width,sizePhoneNum.height),"platform_res/userinfo/inputeidtbox.png")
	  self.Edt_PhoneNum:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    self.Edt_PhoneNum:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_SENTENCE)
    self.Edt_PhoneNum:setPosition(cc.p(positionx1,positiony1 ))
    self.Edt_PhoneNum:setAnchorPoint(cc.p(0.5, 0.5))
    self.Edt_PhoneNum:setPlaceHolder('请输入您的电话号码')
    self.Edt_PhoneNum:setPlaceholderFontSize(30)
    self.Edt_PhoneNum:setFontColor(cc.c3b(33,38,48))
    self.Edt_PhoneNum:setFontSize(30)
    self.Edt_PhoneNum:setMaxLength(11)
	  self.Edt_PhoneNum:setIgnoreAnchorPointForPosition(false)
    self.bgImg:addChild(self.Edt_PhoneNum)

    --手机号监听函数
    local function PhoneEditBoxEvent(eventType,pSender)   
        print("bindMobileMediator PhoneEditBoxEvent eventType:"..eventType)
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
    self.Edt_PhoneNum:registerScriptEditBoxHandler(PhoneEditBoxEvent) 

     --获取验证码编辑框
    local txtVerfyCode = self.bgImg:getChildByName("yanzheng_input") --获取输入框背景
    local sizeVerfyCode = txtVerfyCode:getContentSize()
    local positionx,positiony = txtVerfyCode:getPosition()
    txtVerfyCode:setVisible(false)
    --替换成自己定义的EditBox 
    self.Edt_VerfyCode = cc.EditBox:create(cc.size(sizeVerfyCode.width,sizeVerfyCode.height),"platform_res/userinfo/inputeidtbox_short.png")
	self.Edt_VerfyCode:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.Edt_VerfyCode:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_SENTENCE)
    self.Edt_VerfyCode:setPosition(cc.p(positionx,positiony ))
    self.Edt_VerfyCode:setContentSize(cc.size(sizeVerfyCode.width*0.6, sizeVerfyCode.height))
    self.Edt_VerfyCode:setAnchorPoint(cc.p(0.5, 0.5))
    self.Edt_VerfyCode:setPlaceHolder('请输入验证码')
    self.Edt_VerfyCode:setPlaceholderFontSize(30)
    self.Edt_VerfyCode:setFontColor(cc.c3b(33,38,48))
    self.Edt_VerfyCode:setFontSize(30)
    self.Edt_VerfyCode:setMaxLength(6)
	self.Edt_VerfyCode:setIgnoreAnchorPointForPosition(false)
    self.bgImg:addChild(self.Edt_VerfyCode)

    --验证码监听函数
    local function VerfyCodeEditBoxEvent(eventType,pSender)   
        print("bindMobileMediator VerfyCodeEditBoxEvent eventType:"..eventType)
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
    self.btnGetCodeAgain = seekNodeByName(self.bgImg, "btn_getcode")
    if self.btnGetCodeAgain then
		self.btnGetCodeAgain:setZoomScale(-0.1)
		self.btnGetCodeAgain:addClickEventListener(function()
			--platformFacade:removeMediator("SetBankPassMediator")
            print("click btnMobileCode手机验证码")
            local phoneNum = string.trim(self.Edt_PhoneNum:getText())
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
    --self.txtResult =  self.bgImg:getChildByName("txtInfo") --获取结果显示框

     --获取确认按钮
    local btnOk = seekNodeByName(self.bgImg, "btn_ok")
    if btnOk then
       btnOk:setZoomScale(-0.1)
		btnOk:addClickEventListener(function()  
        print("click 确认按钮")
       -- local schedulerID = bandProxy:getData().scheduleID
        

        --判断手机号是否输入正确
        local phoneNum = string.trim(self.Edt_PhoneNum:getText())
        if phoneNum == "" then
            print("手机号末输入")
            --self.txtResult:setString("手机号未输入")
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

         --判断手机验证码是否合法
        local txtVerCode = string.trim(self.Edt_VerfyCode:getText())
        local lenVerCode = #txtVerCode
        if lenVerCode <= 0 then
            print("验证码没有输入")
            --self.txtResult:setString("验证码没输入")
            platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "验证码没输入")
            return
        end

        print("全部数据输入正确，开始发送绑定手机请求")
        --self.txtResult:setString("开始设置绑定密码")
        local reqbindMobile = {phone = phoneNum, inputCode = txtVerCode}
        self.phone = phoneNum
        platformFacade:sendNotification(PlatformConstants.REQUEST_BINDMOBILE, reqbindMobile)

      end)
    else
        print("btnOK 找不到")
    end

end

function BindMobileMediator:handleNotification(notification)
    local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")  --
     if name == PlatformConstants.RESULT_BINDMOBILE then
         
         if body == true then
            print("手机绑定成功")
           --应该弹出个提示框，但提示框还没做
           --self.txtResult:setString("手机绑定成功")
           platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "手机绑定成功")
           
           --延后0.3秒再删去mediator,防止过早删定时器来不及停止
           performWithDelay( self:getViewComponent() , function()
              platformFacade:removeMediator("BindMobileMediator")  --关闭掉设置密码提示框
           end , 0.3)
           
           --更新玩家身上的金币，钻石，房卡,绑定手机状态
           --platformFacade:sendNotification(PlatformConstants.REQUEST_USERINFO)
           userinfo:getData().bMobileBind = true
           userinfo:getData().mobile = self.phone
        else
            --self.txtResult:setString("手机绑定失败")
            --platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "手机绑定失败")
            print("手机绑定失败")
        end
    elseif name == PlatformConstants.PHONE_VALID then
        print("PHONE_VALID")
        self.btnGetCodeAgain:setEnabled(false)
        self.btnGetCodeAgain:setVisible(false)
        print("开始倒计时")
        -- if SchID~=nil then  --self.schedulerID
        --      print("self.schedulerID 存在，停止计时器:" .. SchID)
        --      self.scheduler:unscheduleScriptEntry(SchID)  --停止定时器
        --      self.schedulerID = nil
        --      SchID = nil
        --     -- bandProxy:getData().scheduleID = nil
        -- else
        --      print("self.schedulerID == NIL")
        -- end
        if self.txtTimeOut then  --设置倒计时时间显示
            self.txtTimeOut:setVisible(true)
        end
        self:scheduleFunc() --开始倒计时
    end

end

function BindMobileMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local bandProxy = platformFacade:retrieveProxy("BandMobileProxy")
	
	platformFacade:removeCommand(PlatformConstants.REQUEST_BINDMOBILE)
    platformFacade:removeCommand(PlatformConstants.REQUEST_MOBILECODE)

    if SchID~=nil then  --倒计时时间到停止计时
         self.scheduler:unscheduleScriptEntry(SchID)
         self.schedulerID = nil
         SchID = nil
         --bandProxy:getData().scheduleID = nil
    end
   
	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

return BindMobileMediator

--endregion
