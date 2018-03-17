
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestQuickLeaveCommand = class("RequestQuickLeaveCommand", SimpleCommand)

function RequestQuickLeaveCommand:execute(notification)
    print("sss")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	gameFacade:sendNotification(GameConstants.SEND_SOCKET, "", 310)
end

return RequestQuickLeaveCommand