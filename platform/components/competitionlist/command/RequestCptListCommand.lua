
local CompetitionListProxy = import("..proxy.CompetitionListProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestCptListCommand = class("RequestCptListCommand", SimpleCommand)
local HttpSender=cc.load("jfutils").HttpSender
function RequestCptListCommand:execute(notification)
	print("RequestCptListCommand")
    
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    if not platformFacade:hasProxy("CompetitionListProxy") then
    platformFacade:registerProxy(CompetitionListProxy.new())
    end
    local cptList = platformFacade:retrieveProxy("CompetitionListProxy")

    local sendData = {
		hostId = 1,
        gameId= body, 
	}
    HttpSender:post({"gamematch","ListCurrentMatch",100},sendData,function(revData)
    	cptList:getData().currentMatchList = revData.currentMatchList
   end)
end

return RequestCptListCommand