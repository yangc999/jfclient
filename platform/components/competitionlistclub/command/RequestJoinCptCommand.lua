
local CptListDetailProxy = import("..proxy.CptListDetailProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestJoinCptCommand = class("RequestJoinCptCommand", SimpleCommand)

function RequestJoinCptCommand:execute(notification)
	print("RequestJoinCptCommand")
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local cptList = platformFacade:retrieveProxy("CompetitionListProxy")
	local login = platformFacade:retrieveProxy("LoginProxy")
    local loadproxy=platformFacade:retrieveProxy("LoadProxy")

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", loadproxy:getData().serviceUrl.."competitionList")
	local function onReadyStateChange()
		if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
			local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
			local _, res2 = tarslib.decode(res1.vecData, "commonstruct::CommonRespHead")
			local _, res3 = tarslib.decode(res2.respBodyBytes, "roomdynamic::GetDeskConfByRoomIdResp")

			platformFacade:registerProxy(CptListDetailProxy.new())
			local cptList = platformFacade:retrieveProxy("CptListDetailProxy")
			cptList:getData().roomId = body.roomId
			cptList:getData().lv = body.lv
			cptList:getData().entry = body.entry
			cptList:getData().deskNum = res3.deskNum
			cptList:getData().playerNum = res3.playerNum

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
			cptList:getData().deskList = fakeList
			cptList:getData().showFrom = 1
			cptList:getData().showTo = 5

			platformFacade:sendNotification(PlatformConstants.START_DESKLIST)
			desklist:present()
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

return RequestJoinCptCommand