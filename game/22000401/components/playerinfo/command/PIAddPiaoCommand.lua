
local SimpleCommand = cc.load("puremvc").SimpleCommand
local PIAddPiaoCommand = class("PIAddPiaoCommand", SimpleCommand)

function PIAddPiaoCommand:execute(notification)
    print("-------------->PIAddPiaoCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
	
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("PlayerInfoProxy"):getData()

    if name == MyGameConstants.PIAO_RESP then
        data.PiaoData = body
    end
end

return PIAddPiaoCommand