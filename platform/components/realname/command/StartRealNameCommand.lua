--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local RealNameProxy = import("..proxy.RealNameProxy")
local RealNameMediator = import("..mediator.RealNameMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartRealNameCommand = class("StartRealNameCommand", SimpleCommand)

function StartRealNameCommand:execute(notification)
    print("StartRealNameCommand:execute")

	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerProxy(RealNameProxy.new())
	platformFacade:registerMediator(RealNameMediator.new())
end

return StartRealNameCommand


--endregion
