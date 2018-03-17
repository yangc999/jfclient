
local DeskListMediator = import("..mediator.DeskListMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartDeskListCommand = class("StartDeskListCommand", SimpleCommand)

function StartDeskListCommand:execute(notification)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerMediator(DeskListMediator.new())
end

return StartDeskListCommand