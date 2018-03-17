
local SimpleCommand = cc.load("puremvc").SimpleCommand
local PlayerOfflineCommand = class("PlayerOfflineCommand", SimpleCommand)

function PlayerOfflineCommand:execute(notification)
    print("-------------->PlayerOfflineCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("PlayerInfoProxy"):getData()

    if name == MyGameConstants.PLAYER_OFFLINE then
        data.CurOfflinePlayer = body
    end
end

return PlayerOfflineCommand