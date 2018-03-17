
local SimpleCommand = cc.load("puremvc").SimpleCommand
local OCActInfoCommand = class("OCActInfoCommand", SimpleCommand)

function OCActInfoCommand:execute(notification)
    print("-------------->OCActInfoCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
	
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("OutCardProxy"):getData()

    if name == MyGameConstants.ACT_INFO then
        data.ActInfoData = body
    end
end

return OCActInfoCommand