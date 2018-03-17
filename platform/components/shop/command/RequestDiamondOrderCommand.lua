--region *.lua
--Date
--请求钻石购买商品
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestDiamondOrderCommand = class("RequestDiamondOrderCommand", SimpleCommand)

function RequestDiamondOrderCommand:execute(notification)
	print("RequestDiamondOrderCommand Start")
	local body = notification:getBody()
    print("body = " .. body)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local load = platformFacade:retrieveProxy("LoadProxy")
	local login = platformFacade:retrieveProxy("LoginProxy")
	local shop = platformFacade:retrieveProxy("ShopProxy")

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."pay")
	local function onReadyStateChange()
		if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
			local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
			local _, res2 = tarslib.decode(res1.vecData, "pay::TPayMsg")
			local _, res3 = tarslib.decode(res2.vecData, "pay::TRspDiamondPay")
			dump(res3, "res3")
			if res3.iRetCode == 0 then  --购买成功
                local tBuyResult = {succ=true, iAfterDiamond = res3.iAfterDiamond, lAfterValue = res3.lAfterValue, iRet = 0 }
				
				platformFacade:sendNotification(PlatformConstants.RESULT_SHOPDIAMONDBUY, tBuyResult)
            else
                local tBuyResult = {succ=false, iAfterDiamond = nil, lAfterValue = nil, iRet = res3.iRetCode }
                platformFacade:sendNotification(PlatformConstants.RESULT_SHOPDIAMONDBUY, tBuyResult)
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
		iOid = body, 
	}
	local req1 = tarslib.encode(pak1, "pay::TReqDiamondPay")
	local pak2 = {
		eAct = 1,           --E_A_DIAMOND=0,		//钻石购买 
		vecData = req1, 
	}
	local req2 = tarslib.encode(pak2, "pay::TPayMsg")
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

return RequestDiamondOrderCommand


--endregion
