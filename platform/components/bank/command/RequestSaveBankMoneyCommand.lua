--region *.lua 存钱到银行命令
--Date  2017、11、15
--此文件由[BabeLua]插件自动生成

local BankProxy = import("..proxy.BankProxy")
local SetBankPassMediator = import("..mediator.SetBankPassMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestSaveBankMoneyCommand = class("RequestSaveBankMoneyCommand", SimpleCommand)

function RequestSaveBankMoneyCommand:execute(notification)
    print("RequestSaveBankMoneyCommand:execute")
    local money = notification:getBody()  --存的钱
    print("存入的money:" .. money)

    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    local bankProxy = platformFacade:retrieveProxy("BankProxy") --获取银行数据
    local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy") --获取用户数据

    local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."userinfo")   --设定请求地址 local testUrl = "http://192.168.0.242:18890/" 在LoadProxy.lua文件中

    --存钱的回调函数
    local function onReadyStateChange()
        --存钱结果
        print("存钱回调 readyState:"..xhr.readyState,"xhr.status:"..xhr.status)
        if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
            local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
            local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
		    local _, res2 = tarslib.decode(res1.vecData, "userinfo::TUserInfoMsg")
			local _, res3 = tarslib.decode(res2.vecData, "userinfo::TRspSafeBox")
            dump(res3, "res3")
            if res3.iRetCode == 0 then
                --bankProxy:getData().password = password
                print("存钱成功")
                userinfo:getData().gold = res3.lGold --银行里的金币
                userinfo:getData().safeGold = res3.lSafeGold --用户身上的金币
                platformFacade:sendNotification(PlatformConstants.RESULT_SAVEBANKMONEY, true)
                platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "成功存入"..money)
            else
                print("存钱失败!,结果码iRetCode:" .. res3.iRetCode)
                platformFacade:sendNotification(PlatformConstants.RESULT_SAVEBANKMONEY, false)
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
		eSafeOperate = 0,      --操作存钱
        lAmount = money,      --存入的钱
	}
	local req1 = tarslib.encode(pak1, "userinfo::TReqSafeBox")  --请求手机验证码
    local pak2 = {
		eAct = 3,   --E_A_SAFE=3  操作是保险箱之类
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
    print("send msg:存钱:" .. money)
	xhr:send(req3)
    print("end xhr:send")

end

return RequestSaveBankMoneyCommand
--endregion
