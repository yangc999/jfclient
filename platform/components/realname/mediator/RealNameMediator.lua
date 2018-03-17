--region *.lua
--Date
--实名认证申请UI

local Mediator = cc.load("puremvc").Mediator
local RealNameMediator = class("RealNameMediator", Mediator)
local RealNameProxy = import("..proxy.RealNameProxy")

--//wi = 2(n-1)(mod 11)
local wi = {7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2, 1}
--//verify digit
local vi = { '1', '0', 'X', '9', '8', '7', '6', '5', '4', '3', '2'}

local function isBirthDate(date)
    local year = tonumber(date:sub(1,4))
    local month = tonumber(date:sub(5,6))
    local day = tonumber(date:sub(7,8))
    --判断年份
    if year < 1900 or year > 2100 or month >12 or month < 1 then
        return false
    end
    --月份天数
    local month_days = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    local bLeapYear = (year%4==0 and year%100~=0) or (year%400==0) --是否云年
    if bLeapYear then
       month_days[2] = 29
    end
    --判断日是否合法
    if day > month_days[month] or day < 1 then
        return false
    end

    return true
end

local function isBirthDate15(date)  --15位身份证校验
    local year = tonumber(date:sub(1,2)) + 1900
    local month = tonumber(date:sub(3,4))
    local day = tonumber(date:sub(5,6))
    --判断年份
    if year < 1900 or year > 2000 or month >12 or month < 1 then
        return false
    end
    --月份天数
    local month_days = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    local bLeapYear = (year%4==0 and year%100~=0) or (year%400==0) --是否云年
    if bLeapYear then
       month_days[2] = 29
    end
    --判断日是否合法
    if day > month_days[month] or day < 1 then
        return false
    end

    return true
end
--检查输入字符串是否是数字或结尾是X格式
local function isAllNumberOrWithXInEnd(str)
    str = string.upper(str)
    local ret = string.match(str, "%d+X?")
    return ret == str
end

--计算身份证检验码
local function checkSum(idcard)
    local nums = {}
    local _idcard = idcard:sub(1,17)
    for ch in string.gmatch(_idcard, ".") do
         table.insert(nums, tonumber(ch))
    end
    local sum = 0
    for i,k in ipairs(nums) do
        sum = sum + k * wi[i]
    end
    
    return  vi[sum % 11+1] == idcard:sub(18,18)
end

local err_success = 0   --校验成功
local err_length = 1      --长度不对
local err_province = 2   --省区码不对
local err_birth_date = 3 --出生日期不对
local err_code_sum = 4  --校验码不对
local err_unknow_charactor = 5  --存在非法字符

local function verifyIDCard(idCard)
     print("身份证验证：" .. idCard)
     local lenStr = #idCard
     print("身份证长度:" .. lenStr)
     if lenStr ~=18 and lenStr~=15 then  --位数不是18位或15位
        print("err_length")
        return err_length     
     end
     
     if lenStr == 18 then
       if not isAllNumberOrWithXInEnd(idCard) then --18位身份证最后一位
         print("isAllNumberOrWithXInEnd err_unknow_charactor")
         return err_unknow_charactor
       end
     end
     
     --第1-2位为省级行政区划代码，[11, 65] (第一位华北区1，东北区2，华东区3，中南区4，西南区5，西北区6
     local nProvince = tonumber(string.sub(idCard, 1, 2))
     if nProvince<11 or nProvince>65 then
        print("err_province")
        return err_province
     end
     -- //第3-4为为地级行政区划代码，第5-6位为县级行政区划代码因为经常有调整，这块就不做校验

     -- //第7-10位为出生年份；//第11-12位为出生月份 //第13-14为出生日期
     if lenStr == 18 then
        if not isBirthDate(string.sub(idCard, 7, 14)) then
          print("err_birth_date")
          return err_birth_date
        end
     end
     
     if lenStr == 15 then
        if not isBirthDate15(string.sub(idCard, 7, 12)) then
           print("err_birth_date 15")
           return err_birth_date
        end
     end
     

     if not checkSum(idCard) then
        print("err_code_sum")
       -- return err_code_sum
     end

     print("idcard is right!")
     return err_success
end

function RealNameMediator:ctor(root)
	RealNameMediator.super.ctor(self, "RealNameMediator")
	self.root = root
    
end

function RealNameMediator:listNotificationInterests()
    local PlatformConstants = cc.exports.PlatformConstants
	return {
        PlatformConstants.START_LOGOUT,
        PlatformConstants.RESULT_REALNAME,
	}
end

function RealNameMediator:onRegister()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	  local PlatformConstants = cc.exports.PlatformConstants
    local realNameProxy = platformFacade:retrieveProxy("RealNameProxy")

    platformFacade:registerCommand(PlatformConstants.REQUEST_REALNAME, cc.exports.RequestRealNameCommand) --注册请求实名认证的命令
    
    local ui = cc.CSLoader:createNode("hall_res/realname/realname.csb")  --设置UI的csb
	  self:setViewComponent(ui)
    local scene = platformFacade:retrieveMediator("HallMediator").scene --获取要加载上的场景
	  scene:addChild(self:getViewComponent())

    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--背景
    --获取关闭按钮
    local btnClose = seekNodeByName(self.bgImg, "btn_close")
  	if btnClose then
    		btnClose:addClickEventListener(function()
                btnClose:setZoomScale(-0.1)
    			platformFacade:removeMediator("RealNameMediator")
    		end)
  	end

   --获取姓名输入框
    local txtRealName = self.bgImg:getChildByName("imgEdtName")
    local sizeRealName = txtRealName:getContentSize()
    local positionx,positiony = txtRealName:getPosition()
    txtRealName:setVisible(false)
    --替换成自己定义的EditBox 
    self.Edt_RealName = cc.EditBox:create(cc.size(sizeRealName.width+8,sizeRealName.height),"platform_res/common/shurukuang-big.png")
	  self.Edt_RealName:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.Edt_RealName:setPosition(cc.p(positionx,positiony ))
    self.Edt_RealName:setContentSize(cc.size(sizeRealName.width+8, sizeRealName.height))
    self.Edt_RealName:setAnchorPoint(cc.p(0.5, 0.5))
    self.Edt_RealName:setPlaceHolder('请输入您的身份证姓名')
    self.Edt_RealName:setPlaceholderFont("font/fangzhenyuanstatic.ttf", 30)
    self.Edt_RealName:setFontColor(cc.c3b(160,160,160))
    self.Edt_RealName:setFontSize(30)
    self.Edt_RealName:setMaxLength(16)
	  self.Edt_RealName:setIgnoreAnchorPointForPosition(false)
    self.bgImg:addChild(self.Edt_RealName)

    --获取身份证输入框
    local txtIDCard = self.bgImg:getChildByName("imgEdtPass")
    local sizeTxtID = txtIDCard:getContentSize()
    local positionx2,positiony2 = txtIDCard:getPosition()
    txtIDCard:setVisible(false)
    --替换成自己定义的EditBox 
    self.Edt_IDCard = cc.EditBox:create(cc.size(sizeTxtID.width+8,sizeTxtID.height),"platform_res/common/shurukuang-big.png")
	  self.Edt_IDCard:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.Edt_IDCard:setPosition(cc.p(positionx2,positiony2 ))
    self.Edt_RealName:setContentSize(cc.size(sizeTxtID.width+8, sizeTxtID.height))
    self.Edt_IDCard:setAnchorPoint(cc.p(0.5, 0.5))
    self.Edt_IDCard:setPlaceHolder('请输入您的身份证号码')
    self.Edt_IDCard:setPlaceholderFont("font/fangzhenyuanstatic.ttf", 30)
    self.Edt_IDCard:setFontColor(cc.c3b(160,160,160))
    self.Edt_IDCard:setFontSize(30)
    self.Edt_IDCard:setMaxLength(18)
	  self.Edt_IDCard:setIgnoreAnchorPointForPosition(false)
    self.bgImg:addChild(self.Edt_IDCard)
    
    local function validStr(str)
        local func_itor = string.gmatch(str,"%d+")
        local res = ""
        while true do
          local ret = func_itor()
          if ret ~= nil then
            res = res..ret
          else
            break
          end
        end
        return res
    end
    --判断是都数字或者字母
    local function IsNumberOrLetter(str)
        str = string.upper(str)
        local t = type(str)

        local first_str = string.sub(str,0,1)
        local last_str = string.sub(str,#str,#str+1)
        local before_str = str
        if last_str == "X" then
          before_str = string.sub(str,1,#str-1)
        end

        if first_str == "0" then
          return string.sub(str,2,#str)
        elseif last_str == " " or last_str == '\n' then
            return before_str
        elseif t == "number" then
            return false
        elseif t == "string" and last_str == "X" then
          local retStr = validStr(before_str)
            return retStr.."x"
        else
            return validStr(before_str)
        end
    end

    --身份证号监听函数
    local function EditBoxEvent(eventType,pSender)  
        local edit = pSender -- 编辑框本身  
        if eventType == "began" then  
            print("开始")  
                  
        --变化事件类型： 如，在window下，输入完成后点击  OK 则触发此类型  
        --若点击  CANCEL 则不触发此类型  
        elseif eventType == "changed" then  
            print("变化")  
            local idCardNum = self.Edt_IDCard:getText()
            --print("==========>",#idCardNum,IsNumberOrLetter(idCardNum))
            local retStr = IsNumberOrLetter(idCardNum)
            if retStr then
                print("身份证号错了,idCardNum:",idCardNum)
                self.Edt_IDCard:setText(retStr)
            end
        elseif eventType == "ended" then  
            print("结束")  
        elseif eventType == "return" then  
            print("返回")  
        end  
    end

    --绑定身份证号监听
    self.Edt_IDCard:registerScriptEditBoxHandler(EditBoxEvent) 

    --[[
    --身份证名字监听函数
    local function NameEditBoxEvent(eventType,pSender)  
        local edit = pSender -- 编辑框本身  
        if eventType == "began" then  
            print("开始")  
                  
        --变化事件类型： 如，在window下，输入完成后点击  OK 则触发此类型  
        --若点击  CANCEL 则不触发此类型  
        elseif eventType == "changed" then  
            print("变化")  
            local sRealName = string.trim(self.Edt_RealName:getText())  --用户输入的姓名
            if not cc.exports.isHanzi(sRealName) then
                print("身份证名字错了,sRealName:",sRealName)
                self.Edt_RealName:setText(string.sub(sRealName,0,#sRealName-1))
            end
        elseif eventType == "ended" then  
            print("结束")  
        elseif eventType == "return" then  
            print("返回")  
        end  
    end

    --绑定身份证名字监听
    self.Edt_RealName:registerScriptEditBoxHandler(NameEditBoxEvent) 
    --]]
    local btnOK = seekNodeByName(self.bgImg, "btnOk")
    if btnOK then
        local txtOK = seekNodeByName(btnOK, "txtOk")
        txtOK:enableOutline(cc.c3b(173, 35, 0), 2)  --设置字体描边效果
        btnOK:addClickEventListener(function() 
            --发出申请实名认证请求
            local sRealName = string.trim(self.Edt_RealName:getText())  --用户输入的姓名
            local idCardNum = string.trim(self.Edt_IDCard:getText())  --用户输入的身份证
            print("名字:" .. sRealName)
            print("身份证号:" .. idCardNum)
            if #sRealName<1 then
                platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE,"姓名不能为空")
                return
            end
            if #idCardNum<1 then
                platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE,"身份证号码不能为空")
                return
            end

            print("开始实名验证")
            local err_result = verifyIDCard(idCardNum)
            if err_result~=err_success or (not cc.exports.isHanzi(sRealName)) then
                platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE,"姓名或身份证号码不正确")
                return
            end

            local tRealName = {realName = sRealName, idNum = idCardNum}
            platformFacade:sendNotification(PlatformConstants.REQUEST_REALNAME, tRealName)
        end)
    end

    self.txtResult = seekNodeByName(self.bgImg, "txtResult")
end

function RealNameMediator:handleNotification(notification)
    print("RealNameMediator:handleNotification")
    local name = notification:getName()
    local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	local realNameProxy = platformFacade:retrieveProxy("RealNameProxy")
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")

    if name == PlatformConstants.START_LOGOUT then
        platformFacade:removeMediator("RealNameMediator")
        platformFacade:removeProxy("RealNameProxy")
    elseif name == PlatformConstants.RESULT_REALNAME then
        if body == true then
           self.txtResult:setString("实名认证成功")
           platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "实名认证成功")
           userinfo:getData().bRealNameSet = true
           platformFacade:removeMediator("RealNameMediator")
        else
           self.txtResult:setString("实名认证失败")
           platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "实名认证失败")
           --userinfo:getData().bRealNameSet = false
        end
    end
end

function RealNameMediator:onRemove()
    print("RealNameMediator:onRemove")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
	platformFacade:removeCommand(PlatformConstants.REQUEST_REALNAME)
    

    platformFacade:removeMediator("RealNameMediator")
    platformFacade:removeProxy("RealNameProxy")
    self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

return RealNameMediator

--endregion
