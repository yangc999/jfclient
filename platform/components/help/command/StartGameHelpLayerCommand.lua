--region *.lua
--Date
--开启游戏帮助页面
local GameHelpMediator = import("..mediator.GameHelpMediator")
local GameHelpProxy = import("..proxy.GameHelpProxy")
local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartGameHelpLayerCommand = class("StartGameHelpLayerCommand", SimpleCommand)

function StartGameHelpLayerCommand:execute(notification)
    print("StartGameHelpLayerCommand:execute")
    --dump(notification,"StartShopLayerCommand notification")

	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerProxy(GameHelpProxy.new())
	platformFacade:registerMediator(GameHelpMediator.new())
end

return StartGameHelpLayerCommand


--endregion
