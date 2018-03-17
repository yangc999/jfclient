
local SimpleCommand = cc.load("puremvc").SimpleCommand
local PIMakeNTCommand = class("PIMakeNTCommand", SimpleCommand)

function PIMakeNTCommand:execute(notification)
    print("-------------->PIMakeNTCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
	
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("PlayerInfoProxy"):getData()

    if name == MyGameConstants.MAKE_NT then
        data.MakeNTData = body
    end
end

return PIMakeNTCommand