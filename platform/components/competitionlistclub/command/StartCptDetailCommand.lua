local CompetitionDetailMediator = import("..mediator.CompetitionDetailMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartCptDetailCommand = class("StartCptDetailCommand", SimpleCommand)

function StartCptDetailCommand:execute(notification)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerMediator(CompetitionDetailMediator.new())
end

return StartCptDetailCommand