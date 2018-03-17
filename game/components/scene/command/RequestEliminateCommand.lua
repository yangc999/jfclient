
local EliminateProxy = import("..proxy.EliminateProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestEliminateCommand = class("RequestEliminateCommand", SimpleCommand)
local HttpSender=cc.load("jfutils").HttpSender
function RequestEliminateCommand:execute(notification)
	print("RequestEliminateCommand")
    
	local body = notification:getBody()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    if not gameFacade:hasProxy("EliminateProxy") then
	    gameFacade:registerProxy(EliminateProxy.new())
	end
    local eliminateData = gameFacade:retrieveProxy("EliminateProxy")

--    local sendData = {
--		matchId = body.matchId,
--        rank= body.rank,
--	}
    
    local load = platformFacade:retrieveProxy("LoadProxy")
	local login = platformFacade:retrieveProxy("LoginProxy")
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."gamematch1")
    local url = load:getData().serviceUrl.."gamematch1"
    print(url)
	local function onReadyStateChange()
        print("readyState = " .. xhr.readyState)
        print("status = " .. xhr.status)
		if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
			local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
            dump(res1,"res1")
			local _, res2 = tarslib.decode(res1.vecData, "gamematch::MatchrecordServiceMsg")
            dump(res2,"res2")
			local _, res3 = tarslib.decode(res2.vecData, "gamematch::TRspMatchRankAward")
			dump(res3, "res3")
                if res3.iRetCode == 0 then
                    local revData = { }
                    if res3.vecMatchAwards ~= nil then
                        revData.vecMatchAwards = res3.vecMatchAwards[1]
                    end
                    revData.iPlayers = res3.iPlayers
                    revData.sMatchName = res3.sMatchName
                    eliminateData:getData().matchMsg = revData
                    gameFacade:registerCommand(GameConstants.START_ELIMINATE, cc.exports.StartEliminateCommand)
                    gameFacade:sendNotification(GameConstants.START_ELIMINATE)
                end
		else
			print("网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
			platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onReadyStateChange)

    dump(body,"body")
	local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		sMatchNo = body.sMatchNo, 
		iRank = body.rank, 
	}
	local req1 = tarslib.encode(pak1, "gamematch::TReqMatchRankAward")
	local pak2 = {
		eAct = 1, 
		vecData = req1 
	}
	local req2 = tarslib.encode(pak2, "gamematch::MatchrecordServiceMsg")
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
--    HttpSender:post({"gamematch","GetMatchKnockOutInfo",105},sendData,function(revData)
--        dump(revData,"revData")
--    	--eliminateData:getData().matchMsg = revData
--        gameFacade:registerCommand(GameConstants.START_ELIMINATE, cc.exports.StartEliminateCommand)
--        gameFacade:sendNotification(GameConstants.START_ELIMINATE)
--   end)


end

return RequestEliminateCommand