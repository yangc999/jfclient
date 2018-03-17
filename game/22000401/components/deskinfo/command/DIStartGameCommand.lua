
local SimpleCommand = cc.load("puremvc").SimpleCommand
local DIStartGameCommand = class("DeskInfoCommand", SimpleCommand)

function DIStartGameCommand:execute(notification)
    print("-------------->DIStartGameCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
	
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("DeskInfoProxy"):getData()

    if name == MyGameConstants.START_GAME then
        data.Round = body
        if gameFacade:hasProxy("GameRoomProxy") then
            local gameRoom = gameFacade:retrieveProxy("GameRoomProxy")
            gameRoom:getData().gameState = MyGameConstants.GameStation.GS_WAIT_PLAYING

             -- 初始化准备状态
            local data = gameFacade:retrieveProxy("PlayerInfoProxy"):getData()
            data.IsPrepare = false
        end
    end
end

return DIStartGameCommand