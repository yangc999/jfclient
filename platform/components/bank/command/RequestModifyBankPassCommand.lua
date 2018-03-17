--region *.lua
--Date
--修改银行密码
local BankProxy = import("..proxy.BankProxy")
--local SetBankPassMediator = import("..mediator.SetBankPassMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestModifyBankPassCommand = class("RequestModifyBankPassCommand", SimpleCommand)

function RequestModifyBankPassCommand:execute(notification)
    local reqSetPass = notification:getBody()
    dump(reqSetPass, "reqSetPass")
    local password = reqSetPass.sPassword            --获取设置的密码
    local oldPassword = reqSetPass.sOldPassWord  --获取旧密码
    --local mobileCode = reqSetPass.sMobileCode      --获取手机验证码
    print("RequestModifyBankPassCommand:execute password:" .. password .. "旧密码:" .. oldPassword)
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
            dump(res3, "res3")
            if res3.iRetCode == 0 then
               -- print("开始用户密码设置")
               -- bankProxy:getData().password = password
               -- userinfo:getData().safePassword = password
                userinfo:getData().bSafePwdSet = true
                print("用户密码修改成功")
                platformFacade:sendNotification(PlatformConstants.RESULT_BANKPASSMODIFY, true)
            else
                print("用户密码设置失败,结果码："..res3.iRetCode)
                platformFacade:sendNotification(PlatformConstants.RESULT_BANKPASSMODIFY, false)
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
		eSafeOperate = 3,  --Eum_SafeOperate.E_SO_MODIFPASS  --操作是修改密码
        sPassWord = password,  --新密码
        sOldPassWord = oldPassword, --旧密码
        --sMobileCode = mobileCode, --验证码
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

return RequestModifyBankPassCommand
--endregion
