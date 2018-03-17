
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestDeskDetailCommand = class("RequestDeskDetailCommand", SimpleCommand)

function RequestDeskDetailCommand:execute(notification)
	--print("RequestDeskDetailCommand")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local load = platformFacade:retrieveProxy("LoadProxy")
	local login = platformFacade:retrieveProxy("LoginProxy")
	local desklist = platformFacade:retrieveProxy("DeskListProxy")

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."roomdynamic")
	local function onReadyStateChange()
		if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
			local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
			local _, res2 = tarslib.decode(res1.vecData, "commonstruct::CommonRespHead")
			local _, res3 = tarslib.decode(res2.respBodyBytes, "roomdynamic::ListDeskInfoByDeskIdListResp")
			for i,v in ipairs(res3.deskInfoList) do
				--dump(v, "deskDetail")
				desklist:getData().deskList[v.deskId+1] = v
			end
			desklist:present()
		else
			print("网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
			platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onReadyStateChange)

	local from = desklist:getData().showFrom
	local to = desklist:getData().showTo
	local list = {}
	for i=from,to do
		table.insert(list, i-1)
	end
	local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		roomId = desklist:getData().roomId, 
		deskIdList = list, 
	}
	local req1 = tarslib.encode(pak1, "roomdynamic::ListDeskInfoByDeskIdListReq")
	local pak2 = {
		actionName = 51, 
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

return RequestDeskDetailCommand