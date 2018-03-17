
local ChatProxy = import("..proxy.ChatProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartChatCommand = class("StartChatCommand", SimpleCommand)

function StartChatCommand:execute(notification)
	local info = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("game")
	platformFacade:registerProxy(ChatProxy.new())
end

return StartChatCommand