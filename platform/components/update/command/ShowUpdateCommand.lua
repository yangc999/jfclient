
local UpdateMediator = import("..mediator.UpdateMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local ShowUpdateCommand = class("ShowUpdateCommand", SimpleCommand)

function ShowUpdateCommand:execute(notification)
	local scene = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    platformFacade:registerMediator(UpdateMediator.new(scene))    
end

return ShowUpdateCommand