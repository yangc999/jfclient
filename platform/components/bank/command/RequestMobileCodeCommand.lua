--region *.lua 请求手机验证码
--Date 2017、11、15
--此文件由[BabeLua] yangyisong
local BankProxy = import("..proxy.BankProxy")
local SetBankPassMediator = import("..mediator.SetBankPassMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestMobileCodeCommand = class("RequestMobileCodeCommand", SimpleCommand)

function RequestMobileCodeCommand:execute(notification)
    local tMobile = notification:getBody()
    dump(tMobile, "mobile code body") --tMobile = {mobile = phoneNum, action = 0}
    local phone = tostring(tMobile.mobile)  --传递过来的手机号
    local iAction = tMobile.action
   
    print("RequestMobileCodeCommand:execute phone:" .. phone)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    local bankProxy = platformFacade:retrieveProxy("BankProxy") --获取银行数据
    local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
    -- local userinfo = platformFacade:retrieveProxy("UserInfoProxy")

    print("phoneNum------>:"..phone)
    local res = cc.exports.isPhoneValid(phone)
    print("res:",res,res==false)
    if res == false then
      platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "手机号格式不正确")
      
      return
    end

    local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."userinfo")   --设定请求地址 local testUrl = "http://192.168.0.242:18890/" 在LoadProxy.lua文件中

    --请求验证码的回调函数
    local function onReadyStateChange()
       print("RequestMobileCodeCommand onReadyStateChange")
       if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
          local tarslib = cc.load("jfutils").Tars
		      local str = xhr.response
          print("str:" .. str)
          local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
          dump(res1,"res1")
		      local _, res2 = tarslib.decode(res1.vecData, "userinfo::TUserInfoMsg")
          dump(res2,"res2")
		      local _, res3 = tarslib.decode(res2.vecData, "userinfo::TRspBindMobile")
          if res3.iRetCode == 0 then --获取验证码成功
             print("获取手机验证码成功，请在手机上查看")
             --platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "获取手机验证码成功，请在手机上查看")
             platformFacade:sendNotification(PlatformConstants.RESULT_MOBILECODE, true)
             -- userinfo:getData().bMobileBind = true
             -- userinfo:getData().mobile = phone
          elseif res3.iRetCode == 308 then
             print("手机绑定账号数已达上限")
             platformFacade:sendNotification(PlatformConstants.RESULT_MOBILECODE, false)
             platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "手机绑定账号数已达上限")
          else
             print("获取验证码失败，是否手机号格式错误?")
             --platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "获取验证码失败，是否手机号格式错误?")
             platformFacade:sendNotification(PlatformConstants.RESULT_MOBILECODE, false)
             platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "获取验证码失败，返回码:" .. tostring(res3.iRetCode))
          end
      else
        print("网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
        platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")            
       end
       xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(onReadyStateChange)

    local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		lUid = login:getData().uid, 
		iTplType = iAction,  --操作是发送手机验证码
        sMoblieNo = phone,  --玩家手机号
	}
	local req1 = tarslib.encode(pak1, "userinfo::TReqMoblieCode")  --请求手机验证码
    local pak2 = {
		eAct = 0,   --E_A_MOBILE_CODE=-1  操作是手机绑定验证之类
		vecData = req1, 
	}
    dump(pak2,"pak2")
	local req2 = tarslib.encode(pak2, "userinfo::TUserInfoMsg")
	local pak3 = {
		iVer = load:getData().version, 
		iSeq = load:getData().sequence, 
		stUid = {
			lUid = login:getData().uid, 
			sToken = login:getData().token, 
		}, 
		vecData = req2, 
	}
	local req3 = tarslib.encode(pak3, "JFGame::THttpPackage")
    print("send msg")
	xhr:send(req3)
    print("end xhr:send")
    platformFacade:sendNotification(PlatformConstants.PHONE_VALID)    --手机验证码已发送,通知改变界面
end

function RequestMobileCodeCommand:onRemove()
  local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
  local PlatformConstants = cc.exports.PlatformConstants

  self:getViewComponent():removeFromParent()
  self:setViewComponent(nil)
end

return RequestMobileCodeCommand
--endregion
