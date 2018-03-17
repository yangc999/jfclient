
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestRoomConfigCommand = class("RequestRoomConfigCommand", SimpleCommand)

function RequestRoomConfigCommand:execute(notification)
	local gameId = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local load = platformFacade:retrieveProxy("LoadProxy")
	local login = platformFacade:retrieveProxy("LoginProxy")
	local roomCfg = platformFacade:retrieveProxy("RoomConfigProxy")

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."config")
	local function onReadyStateChange()
		if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
			local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
			local _, res2 = tarslib.decode(res1.vecData, "commonstruct::CommonRespHead")
			local _, res3 = tarslib.decode(res2.respBodyBytes, "systemconfig::ListGameConfByGameIdResp")
			if res3.gameConfigList and # res3.gameConfigList > 0 then
				roomCfg:getData().config = res3.gameConfigList
				local default = {}
				for i,v in ipairs(res3.gameConfigList) do
					if v.optionType == 1 then
						local column = {
							id = v.id, 
							code = v.optionCode, 
							tp = v.optionType, 
							choice = 1, 
						}
						table.insert(default, column)
					elseif v.optionType == 2 then
						local column = {
							id = v.id, 
							code = v.optionCode, 
							tp = v.optionType, 
							choice = {}, 
						}
						table.insert(default, column)
					end
				end
				roomCfg:getData().choice = default
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
		gameId = gameId, 
	}
	local req1 = tarslib.encode(pak1, "systemconfig::ListGameConfByGameIdReq")
	local pak2 = {
		actionName = 2, 
		reqBodyBytes = req1, 
	}
	local req2 = tarslib.encode(pak2, "commonstruct::CommonReqHead")
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

return RequestRoomConfigCommand