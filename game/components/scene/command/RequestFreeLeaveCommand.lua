
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestFreeLeaveCommand = class("RequestFreeLeaveCommand", SimpleCommand)

function RequestFreeLeaveCommand:execute(notification)
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	gameFacade:sendNotification(GameConstants.SEND_SOCKET, "", 207)
end

return RequestFreeLeaveCommand