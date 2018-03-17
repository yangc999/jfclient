
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestQuickCancelQueueCommand = class("RequestQuickCancelQueueCommand", SimpleCommand)

function RequestQuickCancelQueueCommand:execute(notification)
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local quick = gameFacade:retrieveProxy("QuickRoomProxy")
	
	gameFacade:sendNotification(GameConstants.SEND_SOCKET, "", 304)
end

return RequestQuickCancelQueueCommand