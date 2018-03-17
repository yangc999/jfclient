
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestLogoutCommand = class("RequestLogoutCommand", SimpleCommand)

function RequestLogoutCommand:execute(notification)	
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local load = platformFacade:retrieveProxy("LoadProxy")
	local login = platformFacade:retrieveProxy("LoginProxy")

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."login")
	local function onReadyStateChange()
		if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
			local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
			local _, res2 = tarslib.decode(res1.vecData, "JFGame::TLoginMsg")
			local _, res3 = tarslib.decode(res2.vecData, "JFGame::TRspLogout")
			if res3.iRetCode == 0 then
				platformFacade:registerCommand(PlatformConstants.START_LOGOUT, cc.exports.StartLogoutCommand)
				local scene = platformFacade:retrieveMediator("HallMediator").scene
				platformFacade:sendNotification(PlatformConstants.START_LOGOUT, scene)
				platformFacade:removeCommand(PlatformConstants.START_LOGOUT)
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
	}
	local req1 = tarslib.encode(pak1, "JFGame::TReqLogout")
	local pak2 = {
		eAct = 0, 
		vecData = req1, 
	}
	local req2 = tarslib.encode(pak2, "JFGame::TLoginMsg")
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

return RequestLogoutCommand