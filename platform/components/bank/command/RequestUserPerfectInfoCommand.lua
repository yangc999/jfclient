--region *.lua 请求用户信息完善情况 是否手机已经绑定，是否设置保险箱存钱密码, 是否实名认证等
--Date
--此文件由[BabeLua]插件自动生成

local BankProxy = import("..proxy.BankProxy")
local SetBankPassMediator = import("..mediator.SetBankPassMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestUserPerfectInfoCommand = class("RequestUserPerfectInfoCommand", SimpleCommand)

function RequestUserPerfectInfoCommand:execute(notification)
    print("RequestUserPerfectInfoCommand:execute")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    local bankProxy = platformFacade:retrieveProxy("BankProxy") --获取银行数据
    local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")

    local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."userinfo")   --设定请求地址 local testUrl = "http://192.168.0.242:18890/" 在LoadProxy.lua文件中

    local function onReadyStateChange()
       print("onReadyStateChange")
       if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
          local tarslib = cc.load("jfutils").Tars
		      local str = xhr.response
          print("str:" .. str)
          local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
          dump(res1,"res1")
		      local _, res2 = tarslib.decode(res1.vecData, "userinfo::TUserInfoMsg")
          dump(res2,"res2")
		      local _, res3 = tarslib.decode(res2.vecData, "userinfo::TRspPerfectInfo")
          dump(res3, "res3")
          if res3.iRetCode == 0 then --获取用户设置信息成功
             print("获取用户设置信息成功")
             userinfo:getData().bSafePwdSet = res3.bSafePwdSet
             userinfo:getData().bRealNameSet = res3.bRealNameSet
             userinfo:getData().bMobileBind = res3.bMobileBind
             userinfo:getData().bAgcBelong = res3.bAgcBelong
          else
             print("获取用户设置信息失败")
          end
      else
        print("网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
        platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")            
       end
       xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(onReadyStateChange)
    
    --请求用户信息
    local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		lUid = login:getData().uid, 
	}
	local req1 = tarslib.encode(pak1, "userinfo::TReqPerfectInfo")
	local pak2 = {
		eAct = 6, 
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

return RequestUserPerfectInfoCommand

--endregion
