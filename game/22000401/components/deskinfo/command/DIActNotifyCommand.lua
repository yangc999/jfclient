local SimpleCommand = cc.load("puremvc").SimpleCommand
local DIActNotifyCommand = class("DIActNotifyCommand", SimpleCommand)

function DIActNotifyCommand:execute(notification)
    print("-------------->DIActNotifyCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
   
    if name == MyGameConstants.ACT_NOTIFY then
        
    end
end

return DIActNotifyCommand