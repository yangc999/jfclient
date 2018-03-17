
local SimpleCommand = cc.load("puremvc").SimpleCommand
local OCActNotifyCommand = class("OCActNotifyCommand", SimpleCommand)

function OCActNotifyCommand:execute(notification)
    print("-------------->OCActNotifyCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
	
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("OutCardProxy"):getData()

    if name == MyGameConstants.ACT_NOTIFY then
        
    end
end

return OCActNotifyCommand