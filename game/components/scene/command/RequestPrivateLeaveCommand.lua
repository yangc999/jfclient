
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestPrivateLeaveCommand = class("RequestPrivateLeaveCommand", SimpleCommand)

function RequestPrivateLeaveCommand:execute(notification)
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	gameFacade:sendNotification(GameConstants.SEND_SOCKET, "", 104)
end

return RequestPrivateLeaveCommand