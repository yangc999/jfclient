local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestUpdateCptListCommand = class("RequestUpdateCptListCommand", SimpleCommand)

function RequestUpdateCptListCommand:execute(notification)
	print("RequestUpdateCptListCommand")
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

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
			local _, res3 = tarslib.decode(res2.respBodyBytes, "gamematch::BatchGetMatchIdAndPlayers")
            local templateIdTomatchIdList=cptList:getData().templateIdTomatchIdList
            for i,v in ipairs(res3.matchDynamicList) do
                templateIdTomatchIdList[v.templateId]["matchId"]=v.matchId
                templateIdTomatchIdList[v.templateId]["numOfPlayer"]=v.numOfPlayer
            end
        cptList:getData().templateIdTomatchIdList=templateIdTomatchIdList
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onReadyStateChange)

	local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		templateIdList = body,
	}
	local req1 = tarslib.encode(pak1, "gamematch::BatchGetMatchIdAndPlayersReq")
	local pak2 = {
		actionName = 103, 
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

return RequestUpdateCptListCommand