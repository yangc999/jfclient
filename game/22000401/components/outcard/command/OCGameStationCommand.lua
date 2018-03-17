
local SimpleCommand = cc.load("puremvc").SimpleCommand
local OCGameStationCommand = class("OCGameStationCommand", SimpleCommand)

function OCGameStationCommand:execute(notification)
    print("-------------->OCGameStationCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
	
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("OutCardProxy"):getData()
    if name == MyGameConstants.GAME_STATION then
        if body.eMJState >= 16 and body.eMJState < 24 then
            local lastOutCardData = {}
            lastOutCardData.iCID = body.mj_iLastOuterCID
            lastOutCardData.iDisCardCounts = body.mj_iLastTilepos
            data.LastOutCardData = lastOutCardData
        end
        data.GameStationData = body
    end
end

return OCGameStationCommand