
local EliminateMediator = import("..mediator.EliminateMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartEliminateCommand = class("StartEliminateCommand", SimpleCommand)

function StartEliminateCommand:execute(notification)
	local scene = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	gameFacade:registerMediator(EliminateMediator.new())
end

return StartEliminateCommand