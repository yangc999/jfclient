
local CptListDetailProxy = import("..proxy.CptListDetailProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestCptListDetailCommand = class("RequestCptListDetailCommand", SimpleCommand)
local HttpSender=cc.load("jfutils").HttpSender

function RequestCptListDetailCommand:execute(notification)
	print("RequestCptListDetailCommand")
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local login = platformFacade:retrieveProxy("LoginProxy")
    local loadproxy = platformFacade:retrieveProxy("LoadProxy")
    local cptList = platformFacade:retrieveProxy("CompetitionListProxy")
    local sendData = {
		matchId = cptList:getData().templateIdTomatchIdList[body.templateId].matchId,
	}
    HttpSender:post({"gamematch","ListMatchAwardByMatchId",101},sendData,function(revData)
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
            {rank=8,gainType=3,gainValue=20},
            {rank=9,gainType=3,gainValue=20},
            }
            cptListDetail:present()
            platformFacade:registerCommand(PlatformConstants.START_COMPETITIONDETAIL,cc.exports.StartCptDetailCommand)
			platformFacade:sendNotification(PlatformConstants.START_COMPETITIONDETAIL)
   end)
end

return RequestCptListDetailCommand