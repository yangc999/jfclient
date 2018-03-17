
local SimpleCommand = cc.load("puremvc").SimpleCommand
local UpdateUserWealthCommand = class("UpdateUserWealthCommand", SimpleCommand)

function UpdateUserWealthCommand:execute(notification)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local load = platformFacade:retrieveProxy("LoadProxy")
	local login = platformFacade:retrieveProxy("LoginProxy")
	local userinfo = platformFacade:retrieveProxy("UserInfoProxy")

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."userinfo")
	local function onReadyStateChange()
		if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
			local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
			local _, res2 = tarslib.decode(res1.vecData, "userinfo::TUserInfoMsg")
			local _, res3 = tarslib.decode(res2.vecData, "userinfo::TRspReadUserWealth")
			if res3.iRetCode == 0 then
                print("重新获取用户财富成功")
				local info = res3.eUserWealth
                dump(info, "用户财富")
				userinfo:getData().gold = info.lGold
				userinfo:getData().safeGold = info.lSafesGold
				userinfo:getData().roomCard = info.iRoomCard
				userinfo:getData().diamond = info.iDiamond
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
	local req1 = tarslib.encode(pak1, "userinfo::TReqReadUserWealth")
	local pak2 = {
		eAct = 2, 
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

return UpdateUserWealthCommand