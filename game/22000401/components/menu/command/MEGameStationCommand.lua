
local SimpleCommand = cc.load("puremvc").SimpleCommand
local MEGameStationCommand = class("MEGameStationCommand", SimpleCommand)

function MEGameStationCommand:execute(notification)
    print("-------------->MEGameStationCommand:execute")
    if GameUtils:getInstance():getGameType() == 10 then
        return
    end

	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("MenuProxy"):getData()
    if name == MyGameConstants.GAME_STATION then
        data.GameStationData = body
    end
end

return MEGameStationCommand