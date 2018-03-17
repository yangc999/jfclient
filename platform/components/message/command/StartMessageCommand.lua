
local MessageMediator = import("..mediator.MessageMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartMessageCommand = class("StartMessageCommand", SimpleCommand)

function StartMessageCommand:execute(notification)
	local scene = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	platformFacade:registerMediator(MessageMediator.new(scene))
end

return StartMessageCommand