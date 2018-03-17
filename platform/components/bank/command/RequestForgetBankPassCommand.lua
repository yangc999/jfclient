--region *.lua
--Date
--此文件由[BabeLua]忘记密码请求找回
local BankProxy = import("..proxy.BankProxy")
local ForgetBankPassMediator = import("..mediator.ForgetBankPassMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestForgetBankPassCommand = class("RequestForgetBankPassCommand", SimpleCommand)

function RequestForgetBankPassCommand:execute(notification)
    local mobileCode = tostring(notification:getBody())  --传递过来的验证码
    print("RequestForgetBankPassCommand:execute :"..",验证码:" .. mobileCode)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    local bankProxy = platformFacade:retrieveProxy("BankProxy") --获取银行数据
    local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")

    local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."userinfo")   --设定请求地址 local testUrl = "http://192.168.0.242:18890/" 在LoadProxy.lua文件中

    --请求找回密码的回调函数
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
		      local _, res3 = tarslib.decode(res2.vecData, "userinfo::TRspSafeBox")
          if res3.iRetCode == 0 then --找回密码成功
             print("找回密码成功，请在手机上查看")
             bankProxy:getData().password = res3.sNewPass
             print("重置后的密码:"..bankProxy:getData().password)
             --发送重置密码成功的消息
             platformFacade:sendNotification(PlatformConstants.RESULT_FORGETBANKPASS, true)
          else
             print("找回密码失败，是否手机号格式错误?")
             platformFacade:sendNotification(PlatformConstants.RESULT_FORGETBANKPASS, false)
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
		eSafeOperate = 4,  --Eum_SafeOperate.E_SO_RESETPASS  --操作是找回密码
        sMobileCode = mobileCode,
	}
	local req1 = tarslib.encode(pak1, "userinfo::TReqSafeBox")
	local pak2 = {
		eAct = 3, 
		vecData = req1, 
	}
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
	xhr:send(req3)
end

return RequestForgetBankPassCommand
--endregion
