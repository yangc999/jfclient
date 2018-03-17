
local SimpleCommand = cc.load("puremvc").SimpleCommand
local DIMakeNtCommand = class("DIMakeNtCommand", SimpleCommand)

function DIMakeNtCommand:execute(notification)
    print("-------------->DIMakeNtCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
	
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("DeskInfoProxy"):getData()

    if name == MyGameConstants.MAKE_NT then
        if body.nBankerCID then
            GameUtils:getInstance():setNTServerChair(body.nBankerCID)
        end
        data.MakeNTData = body
    end
end

return DIMakeNtCommand