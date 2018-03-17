local CompetitionMoreGameMediator = import("..mediator.CompetitionMoreGameMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartCptMoreGameCommand = class("StartCptMoreGameCommand", SimpleCommand)

function StartCptMoreGameCommand:execute(notification)
    print("StartCptMoreGameCommand")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerMediator(CompetitionMoreGameMediator.new())
end

return StartCptMoreGameCommand