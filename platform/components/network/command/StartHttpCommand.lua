
local HttpMediator = import("..mediator.HttpMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartHttpCommand = class("StartHttpCommand", SimpleCommand)

function StartHttpCommand:execute(notification)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerMediator(HttpMediator.new())
end

return StartHttpCommand