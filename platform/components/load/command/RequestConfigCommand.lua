
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestConfigCommand = class("RequestConfigCommand", SimpleCommand)

function RequestConfigCommand:execute(notification)
    print("RequestConfigCommand:execute")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	--local scene = platformFacade:retrieveMediator("LoadMediator").scene	
	--platformFacade:sendNotification(PlatformConstants.START_UPDATE, scene)

	local load = platformFacade:retrieveProxy("LoadProxy")

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."configfree")
	local function onReadyStateChange()
		if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
			local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
			local _, res2 = tarslib.decode(res1.vecData, "commonstruct::CommonRespHead")
			local _, res3 = tarslib.decode(res2.respBodyBytes, "systemconfig::ListConfigByKeyGroupResp")
			for i,v in ipairs(res3.configList) do
				if v.keyName == "loginSwitch" then
					local guest = string.sub(v.value, 1, 1)
					local weixin = string.sub(v.value, 2, 2)
					local phone = string.sub(v.value, 3, 3)
					local cfg = {}
					if tonumber(guest) == 1 then
						table.insert(cfg, "guest")
					end
					if tonumber(weixin) == 1 then
						table.insert(cfg, "wx")
					end
					load:getData().loginMethod = cfg
				elseif v.keyName == "gameIdList_test" then
					local list = string.split(v.value, ";")
					table.map(list, function(value, _)
						return tonumber(value)
					end)
					load:getData().availableGame = list
				elseif v.keyName == "official_contact" then
					local list = string.split(v.value, ";")
					load:getData().officialPhoneNum = list[1]
					load:getData().officialWxAccount = list[2]
				elseif v.keyName == "payMethod" then
					local list = string.split(v.value, ",")
					dump(list, "payMethod")
					load:getData().payMethod = list
				end
			end
			local scene = platformFacade:retrieveMediator("LoadMediator").scene
			platformFacade:sendNotification(PlatformConstants.START_UPDATE, scene)
		else
			print("网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
			platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onReadyStateChange)

	local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		keyList = {
			"loginSwitch", 
			"gameIdList_test", 
			"official_contact", 
			"payMethod", 
		}
	}
	local req1 = tarslib.encode(pak1, "systemconfig::ListConfByKeyListReq")
	local pak2 = {
		actionName = 3, 
		reqBodyBytes = req1, 
	}
	local req2 = tarslib.encode(pak2, "commonstruct::CommonReqHead")
	local pak3 = {
		iVer = load:getData().version, 
		iSeq = load:getData().sequence, 
		stUid = {
			lUid = 0, 
			sToken = "", 
		}, 
		vecData = req2,
	}
	local req3 = tarslib.encode(pak3, "JFGame::THttpPackage")
	xhr:send(req3)
end

return RequestConfigCommand