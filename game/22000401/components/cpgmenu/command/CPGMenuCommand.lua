
local CPGMenuMediator = import("..mediator.CPGMenuMediator")
local CPGMenuProxy = import("..proxy.CPGMenuProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local CPGMenuCommand = class("CPGMenuCommand", SimpleCommand)

function CPGMenuCommand:execute(notification)
    print("-------------->CPGMenuCommand:execute")
	local root = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    gameFacade:registerProxy(CPGMenuProxy.new())
	gameFacade:registerMediator(CPGMenuMediator.new(root))
end

return CPGMenuCommand