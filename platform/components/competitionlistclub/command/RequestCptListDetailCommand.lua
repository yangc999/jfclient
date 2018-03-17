
local CptListDetailProxy = import("..proxy.CptListDetailProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestCptListDetailCommand = class("RequestCptListDetailCommand", SimpleCommand)

function RequestCptListDetailCommand:execute(notification)
	print("RequestCptListDetailCommand")
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local login = platformFacade:retrieveProxy("LoginProxy")
    local loadproxy = platformFacade:retrieveProxy("LoadProxy")
    local cptList = platformFacade:retrieveProxy("CompetitionListProxy")
    
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", loadproxy:getData().serviceUrl.."gamematch")
	local function onReadyStateChange()
		if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
			local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
			local _, res2 = tarslib.decode(res1.vecData, "commonstruct::CommonRespHead")
			local _, res3 = tarslib.decode(res2.respBodyBytes, "gamematch::ListMatchAwardByMatchIdResp")
          
			platformFacade:registerProxy(CptListDetailProxy.new())
			local cptListDetail= platformFacade:retrieveProxy("CptListDetailProxy")
            cptListDetail:getData().matchAwardList={
            {rank=1,gainType=1,gainValue=20},
            {rank=2,gainType=2,gainValue=20},
            {rank=3,gainType=2,gainValue=20},
            {rank=4,gainType=2,gainValue=15},
            {rank=5,gainType=2,gainValue=15},
            {rank=6,gainType=3,gainValue=20},
            {rank=7,gainType=3,gainValue=20},
            }
            cptListDetail:present()
            dump(res3,"matchAwardList")
            platformFacade:registerCommand(PlatformConstants.START_COMPETITIONDETAIL,cc.exports.StartCptDetailCommand)
			platformFacade:sendNotification(PlatformConstants.START_COMPETITIONDETAIL)
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onReadyStateChange)

	local tarslib = cc.load("jfutils").Tars
    
	local pak1 = {
		matchId = cptList:getData().templateIdTomatchIdList[body.templateId].matchId,
	}
 

	local req1 = tarslib.encode(pak1, "gamematch::ListMatchAwardByMatchIdReq")
	local pak2 = {
		actionName = 101, 
		reqBodyBytes = req1, 
	}
	local req2 = tarslib.encode(pak2, "commonstruct::CommonReqHead")
	local pak3 = {
		iVer = loadproxy:getData().version, 
		iSeq = loadproxy:getData().sequence, 
		stUid = {
			lUid = login:getData().uid, 
			sToken = login:getData().token, 
		}, 
		vecData = req2,
	}
	local req3 = tarslib.encode(pak3, "JFGame::THttpPackage")
	xhr:send(req3)
end

return RequestCptListDetailCommand