--region *.lua
--Date
--此文件由[BabeLua]启动系统设置的命令
local SysSetMediator = import("..mediator.SysSetMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartSysSetUiCommand = class("StartSysSetUiCommand", SimpleCommand)

function StartSysSetUiCommand:execute(notification)
    print("StartSysSetUiCommand:execute")
    --dump(notification,"StartShopLayerCommand notification")

	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	--platformFacade:registerProxy(ShopProxy.new())
	platformFacade:registerMediator(SysSetMediator.new())
end

return StartSysSetUiCommand

--endregion
