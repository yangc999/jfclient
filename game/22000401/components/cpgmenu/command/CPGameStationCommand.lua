
local SimpleCommand = cc.load("puremvc").SimpleCommand
local CPGameStationCommand = class("CPGameStationCommand", SimpleCommand)

function CPGameStationCommand:execute(notification)
    print("-------------->CPGameStationCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("CPGMenuProxy"):getData()

    if name == MyGameConstants.GAME_STATION then
        if body.eMJState >= 16 and body.eMJState < 24 then
            data.ActNotifyData = body.sCanAct
        end
    end
end

return CPGameStationCommand