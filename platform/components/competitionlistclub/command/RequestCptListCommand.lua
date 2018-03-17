
local CompetitionListProxy = import("..proxy.CompetitionListProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestCptListCommand = class("RequestCptListCommand", SimpleCommand)

function RequestCptListCommand:execute(notification)
	print("RequestCptListCommand")
    
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    platformFacade:registerProxy(CompetitionListProxy.new())
    local cptList = platformFacade:retrieveProxy("CompetitionListProxy")
     
	local login = platformFacade:retrieveProxy("LoginProxy")

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    local loadprox=platformFacade:retrieveProxy("LoadProxy")
	xhr:open("POST", loadprox:getData().serviceUrl.."gamematch")
	local function onReadyStateChange()
		if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
			local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
 
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
			local _, res2 = tarslib.decode(res1.vecData, "commonstruct::CommonRespHead")
			local _, res3 = tarslib.decode(res2.respBodyBytes, "gamematch::ListCurrentMatchResp")
            dump(res2,"comehere1",10)
            dump(res3,"comehere1",10)
			cptList:getData().currentMatchList = res3.currentMatchList
			cptList:getData().showFrom = 1
			cptList:getData().showTo = 5


		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onReadyStateChange)

	local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		hostId = 1,
        gameId= 22000401, 
	}

	local req1 = tarslib.encode(pak1, "gamematch::ListCurrentMatchReq")
	local pak2 = {
		actionName = 100, 
		reqBodyBytes = req1, 
	}
	local req2 = tarslib.encode(pak2, "commonstruct::CommonReqHead")
	local pak3 = {
		iVer = loadprox:getData().version, 
		iSeq = loadprox:getData().sequence, 
		stUid = {
			lUid = login:getData().uid, 
			sToken = login:getData().token, 
		}, 
		vecData = req2,
	}
	local req3 = tarslib.encode(pak3, "JFGame::THttpPackage")
	xhr:send(req3)
end

return RequestCptListCommand