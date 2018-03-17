--region *.lua
--Date
--此文件由[BabeLua]找回密码的Mediator1
local Mediator = cc.load("puremvc").Mediator
local ForgetBankPassMediator = class("ForgetBankPassMediator", Mediator)
local TOTALTIME = 40 --重发短信的倒计时
local SchID = nil  --定时器ID

function ForgetBankPassMediator:ctor(root)
	ForgetBankPassMediator.super.ctor(self, "ForgetBankPassMediator")
	self.root = root  --设置根结点
    self.phaseUI = 1 --显示阶段
    self.totalTime = TOTALTIME --总时间20秒
    self.scheduler = cc.Director:getInstance():getScheduler()
    self.schedulerID = nil  --倒计时的更新函数ID
end

--倒计时的更新函数
function ForgetBankPassMediator:antiClockwiseUpdate(time)
    self.totalTime = self.totalTime - 1
    if self.totalTime>=0 then
       if self.txtTimeOut then  --设置倒计时时间显示
          self.txtTimeOut:setString(self.totalTime.."秒后")
       end
    elseif self.schedulerID~=nil then  --倒计时时间到停止计时
         self.scheduler:unscheduleScriptEntry(self.schedulerID)
         self.schedulerID = nil
         if self.btnGetCodeAgain then
            self.btnGetCodeAgain:setEnabled(true)
         end  
         self.totalTime = TOTALTIME
    end
      
end

--开始倒计时函数
function ForgetBankPassMediator:scheduleFunc()
   --每隔一秒刷新一下函数
   self.schedulerID = self.scheduler:scheduleScriptFunc(handler(self, self.antiClockwiseUpdate),1,false)
   SchID = self.schedulerID
end

--将手机号转为 139****5581形式
function ForgetBankPassMediator:getPhoneStr(phone)
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

function ForgetBankPassMediator:listNotificationInterests()
    local PlatformConstants = cc.exports.PlatformConstants
	return {
        PlatformConstants.RESULT_BANKPASSSET,
        PlatformConstants.RESULT_MOBILECODE,
        PlatformConstants.RESULT_FORGETBANKPASS,
	}
end

function ForgetBankPassMediator:onRegister()
    print("ForgetBankPassMediator:onRegister")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	  local PlatformConstants = cc.exports.PlatformConstants
    local bankProxy = platformFacade:retrieveProxy("BankProxy")
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")
    local bphoneBind = userinfo:getData().bMobileBind  --是否绑定手机
    local sBindPhone = userinfo:getData().mobile --绑定的手机号
    print("ForgetBankPassMediator  bphoneBind:",bphoneBind,"sBindPhone:",sBindPhone)

    platformFacade:registerCommand(PlatformConstants.REQUEST_FORGETBANKPASS, cc.exports.RequestForgetBankPassCommand) --注册找回银行密码命令
    platformFacade:registerCommand(PlatformConstants.REQUEST_MOBILECODE, cc.exports.RequestMobileCodeCommand) --注册发送手机验证码命令

    local ui = cc.CSLoader:createNode("hall_res/bank/forgetPwd.csb")  --设置UI的csb
	self:setViewComponent(ui)
    --local scene = platformFacade:retrieveMediator("BankMediator").scene
	self.root:addChild(self:getViewComponent())

    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--获取背景

    --获取关闭按钮
    local btnClose = seekNodeByName(self.bgImg, "btn_close")
	if btnClose then
		btnClose:addClickEventListener(function()
            btnClose:setZoomScale(-0.1)
            if self.schedulerID~=nil then  --倒计时时间到停止计时
                 self.scheduler:unscheduleScriptEntry(self.schedulerID)
                 self.schedulerID = nil
            end
			platformFacade:removeMediator("ForgetBankPassMediator")
		end)
	end

    self.btnPhone = seekNodeByName(self.bgImg, "btnPhone")  --获取点击发送验证码的电话按钮

    self.frame2 = seekNodeByName(self.bgImg, "Frame_2") --获取Frame2框
    if self.frame2 then
       local txtPhone2 = seekNodeByName(self.frame2, "txtPhone") --获取第二版面上的手机号
       if txtPhone2 then
          local strPhone = self:getPhoneStr(sBindPhone)
          txtPhone2:setString(strPhone)
       end
       self.txtTimeOut = seekNodeByName(self.frame2, "txtTimeOut")  --倒计时的时间标签
       self.txtTimeOut:setString(TOTALTIME .. "秒后")
       --获取手机验证码输入框
       --获取验证码编辑框
        local txtVerfyCode = self.frame2:getChildByName("sprInputCode") --获取输入框背景
        local sizeVerfyCode = txtVerfyCode:getContentSize()
        local positionx,positiony = txtVerfyCode:getPosition()
        txtVerfyCode:setVisible(false)
        --替换成自己定义的EditBox 
        self.Edt_VerfyCode = cc.EditBox:create(cc.size(sizeVerfyCode.width,sizeVerfyCode.height),"platform_res/common/com_input_bg.png")
        --self.Edt_VerfyCode:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)--cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_SENTENCE)
	    self.Edt_VerfyCode:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        self.Edt_VerfyCode:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_SENTENCE)
        --self.Edt_VerfyCode:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        self.Edt_VerfyCode:setPosition(cc.p(positionx,positiony ))
        self.Edt_VerfyCode:setContentSize(cc.size(sizeVerfyCode.width*0.55, sizeVerfyCode.height*0.65))
        self.Edt_VerfyCode:setAnchorPoint(cc.p(0.5, 0.5))
        self.Edt_VerfyCode:setPlaceHolder('请输入收到的验证码')
        self.Edt_VerfyCode:setPlaceholderFontSize(26)
        self.Edt_VerfyCode:setFontColor(cc.c3b(33,38,48))
        self.Edt_VerfyCode:setFontSize(30)
        self.Edt_VerfyCode:setMaxLength(6)
	    self.Edt_VerfyCode:setIgnoreAnchorPointForPosition(false)
        self.frame2:addChild(self.Edt_VerfyCode)
        txtVerfyCode:setVisible(false)
        --获取二级面板上的重发验证码按钮
        self.btnGetCodeAgain = seekNodeByName(self.frame2, "btnGetCodeAgain")
        self.btnGetCodeAgain:setEnabled(false)
        if self.btnGetCodeAgain then
           self.btnGetCodeAgain:addClickEventListener(function()
           print("找回密码按钮点击")
           self.btnGetCodeAgain:setZoomScale(-0.1)
           if bphoneBind==false then --如果未绑定手机
              print("还没绑定手机")
              --开始绑定手机号
              platformFacade:sendNotification(PlatformConstants.START_BINDMOBILE, self.root) --显示出绑定手机号UI
              platformFacade:removeMediator("ForgetBankPassMediator") --关掉自身界面
           else
              print("已经绑定手机,开始发验证码")
              --self.phaseUI = 2
              --self:setUIState(self.phaseUI)
              self:scheduleFunc() --开始倒计时
              if sBindPhone~="" then
                 local tMobile = {mobile = sBindPhone, action = 1}
                 platformFacade:sendNotification(PlatformConstants.REQUEST_MOBILECODE, tMobile) --去请求手机验证码
                 --platformFacade:sendNotification(PlatformConstants.REQUEST_MOBILECODE, sBindPhone) --去请求手机验证码
                 self.btnGetCodeAgain:setEnabled(false) --设置手机验证码按钮不可用
              else
                 print("获取绑定手机号失败，请重新绑定手机")
                 self.btnGetCodeAgain:setEnabled(true)
              end
            end
          end)
        end

        --获取二级面板上的下一步按钮
        self.btnSecondStep = seekNodeByName(self.frame2, "btnNextStep")
        if self.btnSecondStep then
           self.btnSecondStep:addClickEventListener(function()
               print("下一步按钮点击，发送密码重置命令")
               self.btnSecondStep:setZoomScale(-0.1)
               local mobileCode = string.trim(self.Edt_VerfyCode:getText())
               if #mobileCode==0 then
                  print("没有输入验证码")
                  return
               end
               if self.schedulerID~=nil then  --停止倒计时
                 self.scheduler:unscheduleScriptEntry(self.schedulerID)
                 self.schedulerID = nil
                 SchID = nil
               end
               platformFacade:sendNotification(PlatformConstants.REQUEST_FORGETBANKPASS, mobileCode)
           end)
        end
    end

    self.frame3 = seekNodeByName(self.bgImg, "Frame_3") --获取Frame3框 找回密码最后一步面板
    if self.frame3 then
       self.txtPhoneFound = seekNodeByName(self.frame3, "txtPhone") --获取找回密码文本框
       local btnFoundOk = seekNodeByName(self.frame3, "btnStepOk") --获取确定按钮
       if btnFoundOk then
          btnFoundOk:addClickEventListener(function()
            print("点击找回密码确定按钮")
            platformFacade:removeMediator("ForgetBankPassMediator") --关掉自身界面
         end)
       end
    end
    --bphoneBind = false
    self.phaseUI = 1 --显示阶段
    self:setUIState(self.phaseUI)

    if self.btnPhone then
       local txtPhoneDesc = seekNodeByName(self.btnPhone, "txtPhone")
       if bphoneBind==false then
            txtPhoneDesc:setFontSize(30)
            txtPhoneDesc:setString("您还没绑定手机号，请先绑定手机")       
      else
           local strPhone = self:getPhoneStr(sBindPhone)
           print("获取到玩家的绑定手机号：" .. strPhone)
           local strPhoneDesc = ""
           strPhoneDesc = "通过" .. strPhone .. "重置密码"
           if strPhone=="" then
              strPhoneDesc = "无法获取手机号,请重新绑定"
           end
           
           txtPhoneDesc:setFontSize(36)
           txtPhoneDesc:setString(strPhoneDesc)
       end
       self.btnPhone:addClickEventListener(function()
           print("找回密码按钮点击")
           self.btnPhone:setZoomScale(-0.1)
           if bphoneBind==false then --如果未绑定手机
              print("还没绑定手机")
              --开始绑定手机号
              platformFacade:sendNotification(PlatformConstants.START_BINDMOBILE, self.root) --显示出绑定手机号UI
              platformFacade:removeMediator("ForgetBankPassMediator") --关掉自身界面
           elseif #sBindPhone==0 then  --无法获取绑定手机
              print("无法获取绑定手机号")
              --开始绑定手机号
              platformFacade:sendNotification(PlatformConstants.START_BINDMOBILE, self.root) --显示出绑定手机号UI
              platformFacade:removeMediator("ForgetBankPassMediator") --关掉自身界面
           else
              print("已经绑定手机")
              --self.phaseUI = 2
              --self:setUIState(self.phaseUI)
              local tMobile = {mobile = sBindPhone, action = 1}
              platformFacade:sendNotification(PlatformConstants.REQUEST_MOBILECODE, tMobile) --去请求手机验证码
              self.btnPhone:setTouchEnabled(false) --设置手机验证码按钮不可用              
           end
       end)
    end
end

--根据玩家当前点选步骤的不同显示不同的区域
function ForgetBankPassMediator:setUIState(phaseUI)
    if phaseUI == 1 then
        if self.btnPhone then
          self.btnPhone:setVisible(true)
        end
        if self.frame2 then
          self.frame2:setVisible(false)
        end
        if self.frame3 then
          self.frame3:setVisible(false)
        end
     elseif phaseUI == 2 then
        if self.btnPhone then
          self.btnPhone:setVisible(false)
        end
        if self.frame2 then
          self.frame2:setVisible(true)
          self.btnGetCodeAgain:setEnabled(false)
          self:scheduleFunc()
        end
        if self.frame3 then
          self.frame3:setVisible(false)
        end
     elseif phaseUI == 3 then
        if self.btnPhone then
          self.btnPhone:setVisible(false)
        end
        if self.frame2 then
          self.frame2:setVisible(false)
        end
        if self.frame3 then
          self.frame3:setVisible(true)
        end
    else
       if self.btnPhone then
          self.btnPhone:setVisible(true)
        end
        if self.frame2 then
          self.frame2:setVisible(false)
        end
        if self.frame3 then
          self.frame3:setVisible(false)
        end
    end
end

function ForgetBankPassMediator:handleNotification(notification)
    local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local bankProxy = platformFacade:retrieveProxy("BankProxy")  --公告数据模型
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")

    if name == PlatformConstants.RESULT_MOBILECODE then --请求手机验证码结果
       -- if SchID~=nil then  --先停止倒计时
       --       print("self.schedulerID 存在，停止计时器:" .. SchID)
       --       self.scheduler:unscheduleScriptEntry(SchID)  --停止定时器
       --       self.schedulerID = nil
       --       SchID = nil
       --      -- bandProxy:getData().scheduleID = nil
       --  else
       --       print("self.schedulerID == NIL")
       --  end
       if body == true then  --获取验证码成功
           if self.btnPhone then
              self.btnPhone:setTouchEnabled(true)
           end
           
           if self.phaseUI==1 then
              self.phaseUI = 2 --进入第2阶段
              self:setUIState(self.phaseUI)
           end
           
        else --获取验证码失败
           if self.btnPhone then
               local txtPhoneDesc = seekNodeByName(self.btnPhone, "txtPhone")
               if txtPhoneDesc then
                  txtPhoneDesc:setString("获取验证码失败，请重新获取")
               end
           end
           self.btnPhone:setEnabled(true)
           self.btnGetCodeAgain:setEnabled(true)
       end
    elseif name == PlatformConstants.RESULT_FORGETBANKPASS then --如果收到重置密码成功的结果
          self.phaseUI =3
          self:setUIState(self.phaseUI)
        if body == true then
           --进入第三阶段  
          local passNew = bankProxy:getData().password
          if #passNew~=0 then
            self.txtPhoneFound:setString(passNew)
         else
            self.txtPhoneFound:setString("重置银行密码失败，请重新请求验证码")
         end
        else
          print("重置银行密码失败，请重新请求验证码")
          self.txtPhoneFound:setString("重置银行密码失败，请重新请求验证码")
        end
    end
end

function ForgetBankPassMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
    if SchID~=nil then  --self.schedulerID
     print("self.schedulerID 存在，停止计时器:" .. SchID)
     self.scheduler:unscheduleScriptEntry(SchID)  --停止定时器
     self.schedulerID = nil
     SchID = nil
    -- bandProxy:getData().scheduleID = nil
    else
             print("self.schedulerID == NIL")
    end

	platformFacade:removeCommand(PlatformConstants.REQUEST_FORGETBANKPASS)
    --platformFacade:removeCommand(PlatformConstants.REQUEST_MOBILECODE)

	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

return ForgetBankPassMediator
--endregion
