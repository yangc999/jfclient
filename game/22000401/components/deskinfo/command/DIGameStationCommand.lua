
local SimpleCommand = cc.load("puremvc").SimpleCommand
local DIGameStationCommand = class("DIGameStationCommand", SimpleCommand)

function DIGameStationCommand:execute(notification)
    print("-------------->DIGameStationCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
	
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("DeskInfoProxy"):getData()

    if name == MyGameConstants.GAME_STATION then
        data.GameStationData = body
        if body.eMJState >= 16 and body.eMJState < 24 then
            local tokenData = {}
            tokenData.iTileWallNums = body.wallNumas
            tokenData.iCID = body.iTokenOwnerCID
            data.TokenData = tokenData
        end

        if body.eMJState >= 16 and body.eMJState <= 24 then
            if gameFacade:hasProxy("GameRoomProxy") then
                local gameRoom = gameFacade:retrieveProxy("GameRoomProxy")
                gameRoom:getData().gameState = MyGameConstants.GameStation.GS_WAIT_PLAYING
                if body.eMJState == 24 then
                    gameRoom:getData().gameState = MyGameConstants.GameStation.GS_WAIT_NEXT_ROUND
                end
            end
        end
    end
end

return DIGameStationCommand