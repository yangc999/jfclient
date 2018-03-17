
local SimpleCommand = cc.load("puremvc").SimpleCommand
local CheckOrderCommand = class("CheckOrderCommand", SimpleCommand)

function CheckOrderCommand:execute(notification)
	print("CheckOrderCommand execute")
	local body = notification:getBody()
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
			local _, res3 = tarslib.decode(res2.vecData, "pay::TRspPayOrderStatus")
			if res3.iRetCode == 0 and res3.bIsDone then
				platformFacade:sendNotification(PlatformConstants.REQUEST_USERINFO)
				if shop:getData().loop then
					cc.Director:getInstance():getScheduler():unscheduleScriptEntry(shop:getData().loop)
					shop:getData().loop = nil
				end
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
		sOrderNo = body,
	}
	local req1 = tarslib.encode(pak1, "pay::TReqPayOrderStatus")
	local pak2 = {
		eAct = 6, 
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

return CheckOrderCommand