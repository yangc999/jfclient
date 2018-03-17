
local SimpleCommand = cc.load("puremvc").SimpleCommand
local PlayerAgreeCommand = class("PlayerAgreeCommand", SimpleCommand)

function PlayerAgreeCommand:execute(notification)
    print("-------------->PlayerAgreeCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("PlayerInfoProxy"):getData()

    if name == MyGameConstants.AGREE_GAME then
        data.AgreeGameUser = body.iCID

        if GameUtils:getInstance():getGameType() == 3 then
            data.BFreUserleave = false
        end
    end
end

return PlayerAgreeCommand