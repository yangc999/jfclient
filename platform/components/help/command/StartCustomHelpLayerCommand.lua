--region *.lua
--Date
--启动客服常见问题回答的UI
local CustomHelpMediator = import("..mediator.CustomHelpMediator")
--local GameHelpProxy = import("..proxy.GameHelpProxy")
local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartCustomHelpLayerCommand = class("StartCustomHelpLayerCommand", SimpleCommand)

function StartCustomHelpLayerCommand:execute(notification)
    print("StartCustomHelpLayerCommand:execute")

	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	--platformFacade:registerProxy(GameHelpProxy.new())
	platformFacade:registerMediator(CustomHelpMediator.new())
end

return StartCustomHelpLayerCommand


--endregion
