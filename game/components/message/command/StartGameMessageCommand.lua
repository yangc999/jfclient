
local MessageMediator = import("..mediator.MessageMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartGameMessageCommand = class("StartGameMessageCommand", SimpleCommand)

function StartGameMessageCommand:execute(notification)
	local scene = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local MyGameConstants = cc.exports.MyGameConstants
	gameFacade:registerMediator(MessageMediator.new(scene))
end

return StartGameMessageCommand