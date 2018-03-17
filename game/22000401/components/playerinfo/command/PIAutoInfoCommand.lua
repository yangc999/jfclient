
local SimpleCommand = cc.load("puremvc").SimpleCommand
local PIAutoInfoCommand = class("PIAutoInfoCommand", SimpleCommand)

function PIAutoInfoCommand:execute(notification)
    print("-------------->PIAutoInfoCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
	
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("PlayerInfoProxy"):getData()

    if name == MyGameConstants.AUTO_INFO then
        data.AutoData = body
        data.IsAuto = body.bAuto
    end
end

return PIAutoInfoCommand