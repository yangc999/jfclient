
local SimpleCommand = cc.load("puremvc").SimpleCommand
local OCOutCardCommand = class("OCOutCardCommand", SimpleCommand)

function OCOutCardCommand:execute(notification)
    print("-------------->OCOutCardCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
	
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("OutCardProxy"):getData()

    if name == MyGameConstants.OUTCARD_INFO then
        data.OutCardData = body
        data.LastOutCardData = body
    end

end

return OCOutCardCommand