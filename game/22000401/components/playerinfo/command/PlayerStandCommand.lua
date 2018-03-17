
local SimpleCommand = cc.load("puremvc").SimpleCommand
local PlayerStandCommand = class("PlayerStandCommand", SimpleCommand)

function PlayerStandCommand:execute(notification)
    print("-------------->PlayerStandCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("PlayerInfoProxy"):getData()

    if name == MyGameConstants.PLAYER_STAND then
        data.CurStandPlayer = body
        data.CurPlayerNums = data.CurPlayerNums - 1
        if GameUtils:getInstance():getGameType() == 3 then
            data.BFreUserleave = true
        end
    end
end

return PlayerStandCommand