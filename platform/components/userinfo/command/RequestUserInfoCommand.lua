
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestUserInfoCommand = class("RequestUserInfoCommand", SimpleCommand)

function RequestUserInfoCommand:execute(notification)
    print("RequestUserInfoCommand:execute")
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
			local _, res3 = tarslib.decode(res2.vecData, "userinfo::TRspUserInfo")
			if res3.iRetCode == 0 then
				local info = res3.eUserInfo
				userinfo:getData().userName = info.sUserName
				userinfo:getData().nickName = info.sNickName
				userinfo:getData().headId = info.iHeadId
				userinfo:getData().gender = info.nGender
				userinfo:getData().mobile = info.sMobile
				userinfo:getData().sign = info.sSignature
				userinfo:getData().gold = info.lGold
				userinfo:getData().safeGold = info.lSafesGold
				userinfo:getData().roomCard = info.iRoomCard
				userinfo:getData().diamond = info.iDiamond
				userinfo:getData().exp = info.iExperience
				userinfo:getData().vipLevel = info.iVipLevel
				userinfo:getData().regTime = info.sRegTime

				if info.sHeadStr and string.len(info.sHeadStr) > 0 then
					local url = cc.UserDefault:getInstance():getStringForKey(string.format("url_%d", login:getData().uid))
					if not url or string.len(url) == 0 then
						cc.UserDefault:getInstance():setStringForKey(string.format("url_%d", login:getData().uid), info.sHeadStr)
						platformFacade:sendNotification(PlatformConstants.DOWNLOAD_HEAD, info.sHeadStr)
					elseif url ~= info.sHeadStr then
						cc.UserDefault:getInstance():setStringForKey(string.format("url_%d", login:getData().uid), info.sHeadStr)
						platformFacade:sendNotification(PlatformConstants.DOWNLOAD_HEAD, info.sHeadStr)
					else
						local path = cc.UserDefault:getInstance():getStringForKey(string.format("save_%d", login:getData().uid))
						if path and string.len(path) > 0 then
							if cc.FileUtils:getInstance():isFileExist(path) then
								userinfo:getData().headStr = path
							else
								platformFacade:sendNotification(PlatformConstants.DOWNLOAD_HEAD, info.sHeadStr)
							end
						else
							platformFacade:sendNotification(PlatformConstants.DOWNLOAD_HEAD, info.sHeadStr)
						end
					end
				end
			end
		else
			print("请求用户信息失败~")
			platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onReadyStateChange)

	local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		lUid = login:getData().uid, 
		iModif = 0,
	}
	local req1 = tarslib.encode(pak1, "userinfo::TReqUserInfo")
	local pak2 = {
		eAct = 1, 
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

return RequestUserInfoCommand