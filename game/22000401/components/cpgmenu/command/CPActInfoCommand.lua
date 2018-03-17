
local SimpleCommand = cc.load("puremvc").SimpleCommand
local CPActInfoCommand = class("CPActInfoCommand", SimpleCommand)

function CPActInfoCommand:execute(notification)
    print("-------------->CPActInfoCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
	
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("CPGMenuProxy"):getData()

    if name == MyGameConstants.ACT_INFO then
        data.ActInfoData = body
    end
end

return CPActInfoCommand