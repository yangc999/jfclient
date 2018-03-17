
local VoiceProxy = import("..proxy.VoiceProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartVoiceCommand = class("StartVoiceCommand", SimpleCommand)

function StartVoiceCommand:execute(notification)
	local info = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("game")
	platformFacade:registerProxy(VoiceProxy.new())
end

return StartVoiceCommand