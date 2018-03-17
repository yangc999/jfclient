
local SimpleCommand = cc.load("puremvc").SimpleCommand
local MEAutoInfoCommand = class("MEAutoInfoCommand", SimpleCommand)

function MEAutoInfoCommand:execute(notification)
    print("-------------->MEAutoInfoCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
	
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("MenuProxy"):getData()

    if name == MyGameConstants.AUTO_INFO then
        data.AutoData = body
    end
end

return MEAutoInfoCommand