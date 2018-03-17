
local LoaderMediator = import("..mediator.LoaderMediator")
local SimpleCommand = cc.load("puremvc").SimpleCommand
local LoadingCommand = class("LoadingCommand", SimpleCommand)

function LoadingCommand:execute(notification)
    print("-------------->LoadingCommand:execute")
	local root = notification:getBody()

    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local loadingMm = LoaderMediator.new()
    print("内存111", string.format("%p", loadingMm))
    gameFacade:registerMediator(loadingMm)
end

return LoadingCommand