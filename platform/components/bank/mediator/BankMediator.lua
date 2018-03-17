--region *.lua  银行Mediator
--Date 2017/11/10
--yangyisong
local Mediator = cc.load("puremvc").Mediator
local BankMediator = class("BankMediator", Mediator)

function BankMediator:ctor(root)
	BankMediator.super.ctor(self, "BankMediator")
	self.root = root
end

function BankMediator:listNotificationInterests()
    local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.UPDATE_GOLD, 
        PlatformConstants.UPDATE_SAFEGOLD,
        PlatformConstants.UPDATE_USERWEALTH,  --这个通知已经弃用
        PlatformConstants.RESULT_BANKPASSSET, --设置密码结果通知
        PlatformConstants.RESULT_BANKPASSMODIFY, --修改密码结果通知
        PlatformConstants.RESULT_SAVEBANKMONEY, --存钱结果
        PlatformConstants.RESULT_DRAWBANKMONEY, --取钱结果
	}
end

function BankMediator:onRegister()
    print("BankMediator:onRegister")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy") --获取用户个人信息
    local bankProxy = platformFacade:retrieveProxy("BankProxy") --获取银行数据
    --
    platformFacade:registerCommand(PlatformConstants.START_SETBANKPASS, cc.exports.StartSetBankPassUICommand) --注册启动设置银行取款密码界面
    platformFacade:registerCommand(PlatformConstants.START_INPUTBANKPASS, cc.exports.StartInputPassUICommand) --注册启动输入银行取款密码界面
    platformFacade:registerCommand(PlatformConstants.REQUEST_SAVEBANKMONEY, cc.exports.RequestSaveBankMoneyCommand)  --请求存钱命令
    platformFacade:registerCommand(PlatformConstants.REQUEST_DRAWBANKMONEY, cc.exports.RequestDrawBankMoneyCommand)  --请求取钱命令
    platformFacade:registerCommand(PlatformConstants.START_BINDMOBILE, cc.exports.StartBindMobileCommand)  --启动绑定手机号界面 
    platformFacade:registerCommand(PlatformConstants.START_MODIFYBANKPASS, cc.exports.StartModifyBankPassUICommand)  --启动修改银行密码界面 
    platformFacade:registerCommand(PlatformConstants.START_FORGETBANKPASS, cc.exports.StartForgetBankPassUICommand) --启动找回银行密码界面
    

    local ui = cc.CSLoader:createNode("hall_res/bank/bankLayer1.csb")  --设置UI的csb
	self:setViewComponent(ui)
    local scene = platformFacade:retrieveMediator("HallMediator").scene --获取要加载上的场景
	scene:addChild(self:getViewComponent()) --获取大厅的Mediator，银行UI要加载这个公告场景s

    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--获取背景
    local testmessage = self.bgImg:getChildByName("Image_inputbg") --获取输入框背景
    local sizetextmessage1 = testmessage:getContentSize()
    sizetextmessage1.width = sizetextmessage1.width*0.7
    sizetextmessage1.height = sizetextmessage1.height*0.85
    local positionx,positiony = testmessage:getPosition()
    testmessage:setVisible(false)
    --替换成自己定义的EditBox
    self.TextField_input = cc.EditBox:create(cc.size(sizetextmessage1.width,sizetextmessage1.height),"platform_res/bank/shurukuang-big.png")
    self.TextField_input:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)--cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_SENTENCE)
	  self.TextField_input:setInputMode(cc.EDITBOX_INPUT_MODE_DECIMAL) 
    self.TextField_input:setPosition(cc.p(positionx,positiony+2 ))
    self.TextField_input:setAnchorPoint(cc.p(0.5, 0.5))
    self.TextField_input:setPlaceHolder('请输入存入/取出金额')
    self.TextField_input:setPlaceholderFontSize(24)
    self.TextField_input:setFontColor(cc.c3b(33,38,48))
    self.TextField_input:setFontSize(24)
    self.TextField_input:setMaxLength(100)
	  self.TextField_input:setIgnoreAnchorPointForPosition(false)
    self.bgImg:addChild(self.TextField_input)
    

    self.txtCoin = seekNodeByName(self.bgImg, "Text_nowCoin")  --用户当前金币标签
    self.txtCoin:setTextHorizontalAlignment(0)
    self.txtCoinBank = seekNodeByName(self.bgImg, "Text_bankCoin") --用户当前银行的金币标签
    self.txtCoinBank:setTextHorizontalAlignment(0)
    local posCoinX = self.txtCoin:getPositionX()
    --self.txtCoin:setPositionX(posCoinX-70)
    local posBankCoinX = self.txtCoinBank:getPositionX()
    --self.txtCoinBank:setPositionX(posBankCoinX-70)
    local userCoin = userinfo:getData().gold --用户金币数
    local userSafeCoin = userinfo:getData().safeGold  --用户保险箱金币数
    if userCoin==nil then
       print("服务器没返回 userinfo:getData().gold")
       self.txtCoin:setString("0")
    else
       self.txtCoin:setString(tostring(userCoin))
    end
    
    if userSafeCoin==nil then
      print("服务器没返回 userinfo:getData().userSafeCoin")
      self.txtCoinBank:setString("0")
    else
      self.txtCoinBank:setString(tostring(userSafeCoin)) 
    end
    

    self.txtResut = seekNodeByName(self.bgImg, "Text_Result") --用来显示操作结果用

    --获取关闭按钮
    local btnClose = seekNodeByName(self.bgImg, "btn_close")
  	if btnClose then
  		btnClose:addClickEventListener(function()
              btnClose:setZoomScale(-0.1)
  			platformFacade:removeMediator("BankMediator")
  		end)
  	end


    local function IsTrueNumber(str)
      local first_str = string.sub(str,1,2)
      --print("-->",first_str)
      if first_str == "0" then
          return false
      else
          return true
      end
  end

  local function EditBoxEvent(eventType,pSender)  
      local edit = pSender -- 编辑框本身  
      if eventType == "began" then  
          print("开始")  
                
      --变化事件类型： 如，在window下，输入完成后点击  OK 则触发此类型  
      --若点击  CANCEL 则不触发此类型  
      elseif eventType == "changed" then  
          print("变化")  
          local idCardNum = self.TextField_input:getText()
          --print("==========>",#idCardNum,IsNumberOrLetter(idCardNum))
          if not IsTrueNumber(idCardNum) then
              print("钱数错了,idCardNum:",idCardNum)
              self.TextField_input:setText("")
          end
      elseif eventType == "ended" then  
          print("结束")  
      elseif eventType == "return" then  
          print("返回")  
      end  
  end

    --绑定监听
  self.TextField_input:registerScriptEditBoxHandler(EditBoxEvent) 

    --获取自定义存钱按钮
    local btnSaveMoney = seekNodeByName(self.bgImg, "btnSaveCustom")
    local txtSaveCustom = seekNodeByName(btnSaveMoney, "txtSaveCustom")
    txtSaveCustom:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果
	if btnSaveMoney then
		btnSaveMoney:setZoomScale(-0.1)
		btnSaveMoney:addClickEventListener(function()
			--platformFacade:removeMediator("BankMediator")
            print("btnSaveMoney:addClickEventListener")
            local strSaveMoney = string.trim(self.TextField_input:getText())
            if strSaveMoney == "" then
                print("没有输入自定义金额")
                --self.txtResut:setString("没有输入自定义金额")
                platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "没有输入自定义金额")
                return
            end
            local saveMoney = tonumber(self.TextField_input:getText())
            local userMoney = userinfo:getData().gold  --获取玩家身上的钱
            if saveMoney>userMoney then
                print("存钱金额大于玩家身上的钱，默认存入全部金额")
                saveMoney = userMoney
            end
            --进行存钱操作
            self:saveBankMoney(saveMoney)
		end)
    else
       print("btnSaveMoney is nil")
	end

    --获取存入10万金币的按钮
    local btnSave10 = seekNodeByName(self.bgImg, "btnSave_10")
    local txtSave10 = seekNodeByName(btnSave10, "txt10Save")
    txtSave10:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果

    if btnSave10 then
       btnSave10:setZoomScale(-0.1)
       btnSave10:addClickEventListener(function()
          print("btnSave10:addClickEventListener")
          local money = 100000
          local userMoney = userinfo:getData().gold --用户现在的金币数
          if money>userMoney then
             money = userMoney
          end
          --进行存钱操作
          self:saveBankMoney(money)
       end)
    else
       print("存10万金币的按钮找不到")
    end

    --获取存入100万金币的按钮
    local btnSave100 = seekNodeByName(self.bgImg, "btnSave_100")
    local txtSave100 = seekNodeByName(btnSave100, "txt100Save")
    txtSave100:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果
    if btnSave100 then
       btnSave100:setZoomScale(-0.1)
       btnSave100:addClickEventListener(function()
          print("btnSave10:addClickEventListener")
          local money = 1000000
          local userMoney = userinfo:getData().gold --用户现在的金币数
          if money>userMoney then  --如果要存的钱比用户身上所有的钱还多，则将用户身上所有的钱都存入银行
             money = userMoney
          end
          --进行存钱操作
          self:saveBankMoney(money)
       end)
    else
       print("存100万金币的按钮找不到")
    end

    --获取存入1000万金币的按钮
    local btnSave1000 = seekNodeByName(self.bgImg, "btnSave_1000")
    local txtSave1000 = seekNodeByName(btnSave1000, "txt1000Save")
    txtSave1000:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果
    if btnSave1000 then
       btnSave1000:setZoomScale(-0.1)
       btnSave1000:addClickEventListener(function()
          print("btnSave1000:addClickEventListener")
          local money = 10000000
          local userMoney = userinfo:getData().gold --用户现在的金币数
          if money>userMoney then  --如果要存的钱比用户身上所有的钱还多，则将用户身上所有的钱都存入银行
             money = userMoney
          end
          --进行存钱操作
          self:saveBankMoney(money)
       end)
    else
       print("存1000万金币的按钮找不到")
    end

    --获取存入全部金币的按钮
    local btnSaveAll = seekNodeByName(self.bgImg, "btnSaveAll")
    local txtSaveAll = seekNodeByName(btnSaveAll, "txtSaveAll")
    txtSaveAll:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果
    if btnSaveAll then
       btnSaveAll:setZoomScale(-0.1)
       btnSaveAll:addClickEventListener(function()
          print("btnSaveAll:addClickEventListener")
          
          local userMoney = userinfo:getData().gold --用户现在的金币数
          
          --进行存钱操作
          self:saveBankMoney(userMoney)
       end)
    else
       print("存全部金币金币的按钮找不到")
    end

    --获取自定义取出金币按钮
    local btnDrawCustom = seekNodeByName(self.bgImg, "btnDrawCustom")
    local txtDrawCustom = seekNodeByName(btnDrawCustom, "txtDrawCustom")
    txtDrawCustom:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果
    if btnDrawCustom then
        btnDrawCustom:setZoomScale(-0.1)
        btnDrawCustom:addClickEventListener(function()
           print("btnSaveMoney:addClickEventListener")
            local strSaveMoney = string.trim(self.TextField_input:getText())
            if strSaveMoney == "" then
                print("没有输入自定义金额")
                --self.txtResut:setString("没有输入自定义金额")
                platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "没有输入自定义金额")
                return
            end
            local drawMoney = tonumber(self.TextField_input:getText())
            local bankMoney = userinfo:getData().safeGold  --获取玩家银行里的钱
            if drawMoney>bankMoney then
                print("取钱金额大于玩家银行里的钱，默认取出全部金额")
                drawMoney = bankMoney
            end
            --进行取钱操作
            self:drawBankMoney(drawMoney)
       end)
    end

     --获取取出10万金币的按钮
    local btnDraw10 = seekNodeByName(self.bgImg, "btnDraw_10")
    local txtDraw10 = seekNodeByName(btnDraw10, "txt10Draw")
    txtDraw10:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果
    if btnDraw10 then
       btnDraw10:setZoomScale(-0.1)
       btnDraw10:addClickEventListener(function()
          print("btnSave10:addClickEventListener")
          local bankMoney = userinfo:getData().safeGold  --获取玩家银行里的钱
          local drawMoney = 100000
          --local userMoney = userinfo:getData().gold --用户现在的金币数
          if drawMoney>bankMoney then
             print("取钱金额大于玩家银行里的钱，默认取出全部金额")
             drawMoney = bankMoney
          end
          --进行存钱操作
          self:drawBankMoney(drawMoney)
       end)
    else
       print("存10万金币的按钮找不到")
    end

    --获取取出100万金币的按钮
    local btnDraw100 = seekNodeByName(self.bgImg, "btnDraw_100")
    local txtDraw100 = seekNodeByName(btnDraw100, "txt100Draw")
    txtDraw100:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果
    if btnDraw100 then
       btnDraw100:setZoomScale(-0.1)
       btnDraw100:addClickEventListener(function()
          print("btnSave10:addClickEventListener")
          local bankMoney = userinfo:getData().safeGold  --获取玩家银行里的钱
          local drawMoney = 1000000
          if drawMoney>bankMoney then
             print("取钱金额大于玩家银行里的钱，默认取出全部金额")
             drawMoney = bankMoney
          end
          --进行存钱操作
          self:drawBankMoney(drawMoney)
       end)
    else
       print("存100万金币的按钮找不到")
    end

    --获取取出1000万金币的按钮
    local btnDraw1000 = seekNodeByName(self.bgImg, "btnDraw_1000")
    local txtDraw1000 = seekNodeByName(btnDraw1000, "txt1000Draw")
    txtDraw1000:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果
    if btnDraw1000 then
       btnDraw1000:setZoomScale(-0.1)
       btnDraw1000:addClickEventListener(function()
          print("btnSave10:addClickEventListener")
          local bankMoney = userinfo:getData().safeGold  --获取玩家银行里的钱
          local drawMoney = 10000000
          if drawMoney>bankMoney then
             print("取钱金额大于玩家银行里的钱，默认取出全部金额")
             drawMoney = bankMoney
          end
          --进行存钱操作
          self:drawBankMoney(drawMoney)
       end)
    else
       print("取1000万金币的按钮找不到")
    end

     --获取存入全部金币的按钮
    local btnDrawAll = seekNodeByName(self.bgImg, "btnDrawAll")
    local txtDrawAll = seekNodeByName(btnDrawAll, "txtDrawAll")
    txtDrawAll:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果
    if btnDrawAll then
       btnDrawAll:setZoomScale(-0.1)
       btnDrawAll:addClickEventListener(function()
          print("btnDrawAll:addClickEventListener")
          local bankMoney = userinfo:getData().safeGold  --获取玩家银行里的钱
          
          --进行存钱操作
          self:drawBankMoney(bankMoney)
       end)
    else
       print("存全部金币金币的按钮找不到")
    end

    --获取绑定手机号按钮
    local btnBindMobile = seekNodeByName(self.bgImg, "btn_bindMobile")
    if btnBindMobile then
        btnBindMobile:setZoomScale(-0.1)
        btnBindMobile:addClickEventListener(function()
            --开始绑定手机号
            platformFacade:sendNotification(PlatformConstants.START_BINDMOBILE, self:getViewComponent())
        end)
    end

    --获取修改密码按钮
    local btnModifyPass = seekNodeByName(self.bgImg, "btnModifyPass")
    local txtModifyPass = seekNodeByName(btnModifyPass, "txtModifyPass")
    txtModifyPass:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果
    if btnModifyPass then
        btnModifyPass:setZoomScale(-0.1)
        btnModifyPass:addClickEventListener(function()
            print("开始显示修改密码UI")
            platformFacade:sendNotification(PlatformConstants.START_MODIFYBANKPASS, self:getViewComponent())
        end)
    end

    --获取忘记密码按钮
    local btnForgetPass = seekNodeByName(self.bgImg, "btnForgetPass")
    local txtForgetPass = seekNodeByName(btnForgetPass, "txtForgetPass")
    txtForgetPass:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果
    if btnForgetPass then
        btnForgetPass:setZoomScale(-0.1)
        btnForgetPass:addClickEventListener(function()
            print("开始显示找回密码UI")
            platformFacade:sendNotification(PlatformConstants.START_FORGETBANKPASS, self:getViewComponent())
        end)
    end
    
     --银行界面启动时请求用户财富
     print("end BankMediator:onRegister")
end

--存钱到银行
function BankMediator:saveBankMoney(money)
    print("存钱操作 BankMediator:saveBankMoney money:" .. money)
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy") --获取用户个人信息
    local bankProxy = platformFacade:retrieveProxy("BankProxy") --获取银行数据
    local bSetPass = userinfo:getData().bSafePwdSet  --是否设置过银行密码

    local bindedMobile = userinfo:getData().mobile  --绑定的手机号
    local bindedPhone = userinfo:getData().bMobileBind  --是否绑定
    if bindedPhone~=false and bindedMobile~="" and bSetPass == false then
            print("未设置密码")
            local strMsg = "首次使用银行功能需要先设置密码"
            local function okCall()  --确定按钮回调
              --发送领取破产补助消息
              platformFacade:sendNotification(PlatformConstants.START_SETBANKPASS, self:getViewComponent())
            end 
            local tMsg = {mType = 2, code = 1, msg = strMsg, okCallback = okCall,leftText = "去设置",rightText = "再想想"} --类型为2，code无用，msg为显示的描述，okCallback为按确定按钮的回调函数
            platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX_EX, tMsg)  


    elseif bSetPass == false then
            print("已经设置手机但未设置密码")
            local strMsg = "首次使用银行功能需要先绑定手机"
            local function okCall()  --确定按钮回调
              --发送领取破产补助消息
              platformFacade:sendNotification(PlatformConstants.START_SETBANKPASS, self:getViewComponent())
            end 
            local tMsg = {mType = 2, code = 1, msg = strMsg, okCallback = okCall,leftText = "去绑定",rightText = "再想想"} --类型为2，code无用，msg为显示的描述，okCallback为按确定按钮的回调函数
            platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX_EX, tMsg)  
            --platformFacade:sendNotification(PlatformConstants.START_SETBANKPASS, self:getViewComponent())
    else
            print("取款密码已存在！")
            --进行下一步取款操作
            platformFacade:sendNotification(PlatformConstants.REQUEST_SAVEBANKMONEY, money)
    end
end

--从银行取钱
function BankMediator:drawBankMoney(money)
    print("取钱操作 BankMediator:drawBankMoney money:" .. money)
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy") --获取用户个人信息
    local bankProxy = platformFacade:retrieveProxy("BankProxy") --获取银行数据
    local bSetPass = userinfo:getData().bSafePwdSet  --是否设置过银行密码

    local bindedMobile = userinfo:getData().mobile  --绑定的手机号
    local bindedPhone = userinfo:getData().bMobileBind  --是否绑定

    if bindedPhone~=false and bindedMobile~="" and bSetPass == false then
            print("未设置密码")
            local strMsg = "首次使用银行功能需要先设置密码"
            local function okCall()  --确定按钮回调
              --发送领取破产补助消息
              platformFacade:sendNotification(PlatformConstants.START_SETBANKPASS, self:getViewComponent())
            end 
            local tMsg = {mType = 2, code = 1, msg = strMsg, okCallback = okCall,leftText = "去设置",rightText = "再想想"} --类型为2，code无用，msg为显示的描述，okCallback为按确定按钮的回调函数
            platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX_EX, tMsg) 

    elseif bSetPass == false then
            print("未设置密码")

            local strMsg = "首次使用银行功能需要先绑定手机"
            local function okCall()  --确定按钮回调
              --发送领取破产补助消息
              platformFacade:sendNotification(PlatformConstants.START_SETBANKPASS, self:getViewComponent())
            end 
            local tMsg = {mType = 2, code = 1, msg = strMsg, okCallback = okCall,leftText = "去绑定",rightText = "再想想"} --类型为2，code无用，msg为显示的描述，okCallback为按确定按钮的回调函数
            platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX_EX, tMsg)  
            --platformFacade:sendNotification(PlatformConstants.START_SETBANKPASS, self:getViewComponent())
    else
            print("开始启动密码输入")
            bankProxy:getData().drawMoney = money
           -- userinfo:getData().userName
            --启动密码输入框
            platformFacade:sendNotification(PlatformConstants.START_INPUTBANKPASS, self:getViewComponent())
    end
end

function BankMediator:handleNotification(notification)
    local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local bankProxy = platformFacade:retrieveProxy("BankProxy")  --公告数据模型
	if name == PlatformConstants.START_LOGOUT then
		platformFacade:removeMediator("BankMediator")
		platformFacade:removeProxy("BankProxy")
    elseif name == PlatformConstants.UPDATE_GOLD then  --用户金币更新
		self.txtCoin:setString(body)
	elseif name == PlatformConstants.UPDATE_SAFEGOLD then --用户保险箱金币更新
		self.txtCoinBank:setString(body)
    elseif name == PlatformConstants.UPDATE_USERWEALTH then --用户财富更新
        self.txtCoinBank:setString(bankProxy:getData().safeGold)
        self.txtCoin:setString(bankProxy:getData().gold)
    elseif name == PlatformConstants.RESULT_BANKPASSSET then --设置银行密码结果通知
        if body == true then
          --self.txtResut:setString("设置取款密码成功")
          platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "设置取款密码成功")
        else
          --self.txtResut:setString("设置取款密码失败")
          platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "设置取款密码失败")
        end
    elseif name == PlatformConstants.RESULT_SAVEBANKMONEY then  --存钱结果通知
         if body == true then
          --self.txtResut:setString("存钱成功")
          platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "存钱成功")
          self.TextField_input:setText("")
        else
          --self.txtResut:setString("存钱失败")
          platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "存钱失败")
          self.TextField_input:setText("")
        end
    elseif name == PlatformConstants.RESULT_DRAWBANKMONEY then  --存钱结果通知
         local drawResult = body
         local bSucc = drawResult.succ
         local desc = drawResult.desc
         --self.txtResut:setString(desc)
         platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, desc)
         self.TextField_input:setText("")
         --[[
         if body == true then
          self.txtResut:setString("取钱成功")
        else
          self.txtResut:setString("取钱失败,密码错误！")
        end--
        ]]
    elseif name == PlatformConstants.RESULT_BANKPASSMODIFY then --修改密码通知
        if body == true then
           --self.txtResut:setString("修改密码成功")
           platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "修改密码成功")
        else
           --self.txtResut:setString("修改密码失败")
           platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "修改密码失败")
        end
    end
end

function BankMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
    platformFacade:removeCommand(PlatformConstants.START_INPUTBANKPASS)
    platformFacade:removeCommand(PlatformConstants.START_SETBANKPASS) --
    platformFacade:removeCommand(PlatformConstants.REQUEST_SAVEBANKMONEY)
    platformFacade:removeCommand(PlatformConstants.REQUEST_DRAWBANKMONEY)
    platformFacade:removeCommand(PlatformConstants.START_MODIFYBANKPASS) --
    platformFacade:removeCommand(PlatformConstants.START_FORGETBANKPASS)
    

	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

return BankMediator
--endregion
