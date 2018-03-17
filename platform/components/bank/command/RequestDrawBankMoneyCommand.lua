--region *.lua 取钱到银行命令
--Date  2017、11、17
--此文件由[BabeLua]呆呆座的小宇宙编写
local BankProxy = import("..proxy.BankProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestDrawBankMoneyCommand = class("RequestDrawBankMoneyCommand", SimpleCommand)

function RequestDrawBankMoneyCommand:execute(notification)
    print("RequestDrawBankMoneyCommand:execute")
    --local money = notification:getBody()  --取的钱

    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    local bankProxy = platformFacade:retrieveProxy("BankProxy") --获取银行数据
    local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy") --获取用户数据

    local money = bankProxy:getData().drawMoney
    print("要取的money:" .. money)
    local password = bankProxy:getData().password
    print("用户输入的密码:" .. password)

    local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."userinfo")   --设定请求地址 local testUrl = "http://192.168.0.242:18890/" 在LoadProxy.lua文件中

    --取钱的回调函数
    local function onReadyStateChange()
        --取钱结果
        if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
            local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
            local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
		    local _, res2 = tarslib.decode(res1.vecData, "userinfo::TUserInfoMsg")
			local _, res3 = tarslib.decode(res2.vecData, "userinfo::TRspSafeBox")
            dump(res3, "res3")
            local resultDraw = {succ = true, desc = ""}
            if res3.iRetCode == 0 then
                --bankProxy:getData().password = password
                print("取钱成功")
                userinfo:getData().gold = res3.lGold --银行里的金币
                userinfo:getData().safeGold = res3.lSafeGold --用户身上的金币
                resultDraw.succ = true
                resultDraw.desc = "取钱成功"
                platformFacade:sendNotification(PlatformConstants.RESULT_DRAWBANKMONEY, resultDraw)
                platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "成功取出"..money)
            else
                print("取钱失败!,结果码iRetCode:" .. res3.iRetCode)
                resultDraw.succ = false
                if res3.iRetCode == 301 then
                   resultDraw.desc = "取钱未成功，余额不足"
                elseif res3.iRetCode == 304 then
                   resultDraw.desc = "取钱未成功，密码错误"
                else
                   resultDraw.desc = "取钱未成功，其他未知原因"
                end
                
                platformFacade:sendNotification(PlatformConstants.RESULT_DRAWBANKMONEY, resultDraw)
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
		eSafeOperate = 1,      --操作取钱  E_SO_WITHDRAW
        sPassWord = password, --输入的钱
        lAmount = money,      --取出的钱
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

return RequestDrawBankMoneyCommand

--endregion
