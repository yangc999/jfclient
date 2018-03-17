
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestQuickQueueCommand = class("RequestQuickQueueCommand", SimpleCommand)

function RequestQuickQueueCommand:execute(notification)
	print("RequestQuickQueueCommand execute")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local quick = gameFacade:retrieveProxy("QuickRoomProxy")

	gameFacade:sendNotification(GameConstants.SEND_SOCKET, "", 301)
end

return RequestQuickQueueCommand