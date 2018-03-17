local CompetitionListMediator = import("..mediator.CompetitionListMediator")
local CompetitionListProxy = import("..proxy.CompetitionListProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartCptListCommand = class("StartCptListCommand", SimpleCommand)

function StartCptListCommand:execute(notification)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    if not platformFacade:hasProxy("CompetitionListProxy") then
    platformFacade:registerProxy(CompetitionListProxy.new())
    end
	platformFacade:registerMediator(CompetitionListMediator.new())
end

return StartCptListCommand