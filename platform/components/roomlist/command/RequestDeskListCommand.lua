
local DeskListProxy = import("..proxy.DeskListProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestDeskListCommand = class("RequestDeskListCommand", SimpleCommand)

function RequestDeskListCommand:execute(notification)
	print("RequestDeskListCommand")
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local load = platformFacade:retrieveProxy("LoadProxy")
	local login = platformFacade:retrieveProxy("LoginProxy")

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."roomdynamic")

    --显示loadingUI
    cc.exports.showLoadingAnim("正在请求桌子列表...","请求列表失败")

	local function onReadyStateChange()
		if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
			local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
			local _, res2 = tarslib.decode(res1.vecData, "commonstruct::CommonRespHead")
			local _, res3 = tarslib.decode(res2.respBodyBytes, "roomdynamic::GetDeskConfByRoomIdResp")

             cc.exports.hideLoadingAnim()

			platformFacade:registerProxy(DeskListProxy.new())
			local desklist = platformFacade:retrieveProxy("DeskListProxy")
			desklist:getData().roomId = body.roomId
			desklist:getData().lv = body.lv
			desklist:getData().entry = body.entry
			desklist:getData().deskNum = res3.deskNum
			desklist:getData().playerNum = res3.playerNum

			local fakeList = {}
			local fakeSeat = {}
			for i=1,res3.playerNum do
				table.insert(fakeSeat, {position=i-1, uid=0})
			end
			for i=1,res3.deskNum do
				fakeList[i] = {
					deskId = i-1, 
					status = 0, 
					playerList = fakeSeat, 
					serverId = 0, 
    			}
			end
			desklist:getData().deskList = fakeList
			desklist:getData().showFrom = 1
			desklist:getData().showTo = 5

			platformFacade:sendNotification(PlatformConstants.START_DESKLIST)
			desklist:present()
		else
			print("网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
			platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
            cc.exports.hideLoadingAnim()
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onReadyStateChange)

	local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		roomId = body.roomId, 
	}
	dump(pak1, "pak")
	local req1 = tarslib.encode(pak1, "roomdynamic::GetDeskConfByRoomIdReq")
	local pak2 = {
		actionName = 50, 
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

return RequestDeskListCommand