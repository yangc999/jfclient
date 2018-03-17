
local SimpleCommand = cc.load("puremvc").SimpleCommand
local CPActNotifyCommand = class("CPActNotifyCommand", SimpleCommand)

function CPActNotifyCommand:execute(notification)
    print("-------------->CPActNotifyCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants

    if GameUtils:getInstance():getGameType() == 10 then
        return
    end
	
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("CPGMenuProxy"):getData()

    if name == MyGameConstants.ACT_NOTIFY then
        data.ActNotifyData = body
    end
end

return CPActNotifyCommand