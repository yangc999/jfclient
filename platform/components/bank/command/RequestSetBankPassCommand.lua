--region *.lua 第一次设置银行取钱密码
--Date 2017/11/15
--此文件由[BabeLua]插件自动生成 yangyisong
local BankProxy = import("..proxy.BankProxy")
local SetBankPassMediator = import("..mediator.SetBankPassMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestSetBankPassCommand = class("RequestSetBankPassCommand", SimpleCommand)

function RequestSetBankPassCommand:execute(notification)
    local reqSetPass = notification:getBody()
    dump(reqSetPass, "reqSetPass")
    local password = reqSetPass.password  --获取设置的密码
    local mobileCode = reqSetPass.mobileCode --获取手机验证码
    print("RequestSetBankPassCommand:execute password:" .. password .. ",验证码:" .. mobileCode)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    local bankProxy = platformFacade:retrieveProxy("BankProxy") --获取银行数据
    local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")

    local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."userinfo")   --设定请求地址 local testUrl = "http://192.168.0.242:18890/" 在LoadProxy.lua文件中

    --请求设置密码的回调函数
    local function onReadyStateChange()
        if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
            local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
            local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
		    local _, res2 = tarslib.decode(res1.vecData, "userinfo::TUserInfoMsg")
			local _, res3 = tarslib.decode(res2.vecData, "userinfo::TRspSafeBox")
            if res3.iRetCode == 0 then
               -- print("开始用户密码设置")
               -- bankProxy:getData().password = password
               -- userinfo:getData().safePassword = password
               userinfo:getData().bSafePwdSet = true
                print("用户密码设置成功")
                platformFacade:sendNotification(PlatformConstants.RESULT_BANKPASSSET, true)             
            else
                print("用户密码设置失败,结果码："..res3.iRetCode)
                platformFacade:sendNotification(PlatformConstants.RESULT_BANKPASSSET, false)
            end
        else
            print("网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
            platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请您重新检查网络") 
       end
       xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(onReadyStateChange)

    local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		lUid = login:getData().uid, 
		eSafeOperate = 2,  --Eum_SafeOperate.E_SO_SETPASS  --操作是设置密码
        sPassWord = password,
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

return RequestSetBankPassCommand
--endregion
